---@class lazydev.Pkg
local M = {}

M.PAT_MODULE_BASE = "%-%-%-%s*@module%s*[\"']([%w%.%-_/]*)"
M.PAT_REQUIRE_BASE = "require%s*,?%s*%(?%s*['\"]([%w%.%-_/]*)"
M.PAT_MODULE_BEFORE = M.PAT_MODULE_BASE .. "$"
M.PAT_REQUIRE_BEFORE = M.PAT_REQUIRE_BASE .. "$"
M.PAT_MODULE = M.PAT_MODULE_BASE .. "[\"']"
M.PAT_REQUIRE = M.PAT_REQUIRE_BASE .. "[\"']"

local is_lazy = type(package.loaded.lazy) == "table"
M.resolved = {} ---@type table<string, { root:string, target:string }|false>

--- resolves the current cwd to the main worktree root
function M.resolve_root()
  local cwd = vim.fs.normalize(assert(vim.uv.cwd()))
  local root = cwd -- git root
  local target = cwd -- git worktree main
  if M.resolved[cwd] ~= nil then
    return M.resolved[cwd]
  end
  local git_root = vim.fs.find(".git", { path = target, upward = true })[1]
  if git_root then
    root = vim.fs.dirname(git_root)
    target = root
    if vim.fn.isdirectory(git_root) == 0 then
      -- resolve worktree
      git_root =
        vim.fn.systemlist({ "git", "-C", target, "rev-parse", "--path-format=absolute", "--git-common-dir" })[1]
      if git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1 then
        target =
          vim.fn.systemlist({ "git", "-C", git_root, "rev-parse", "--path-format=absolute", "--show-toplevel" })[1]
      end
    end
  end
  target = vim.fs.normalize(target)
  M.resolved[cwd] = root ~= target and { root = root, target = target } or false
  return M.resolved[cwd]
end

---@param path string
function M.rewrite(path)
  path = vim.fs.normalize(path)
  local r = M.resolve_root()
  if
    r
    and path:sub(1, #r.target) == r.target
    and (#path == #r.target or path:sub(#r.target + 1, #r.target + 1) == "/")
  then
    path = r.root .. path:sub(#r.target + 1)
  end
  return path
end

---@param modname string
---@return string[]
function M.lazy_unloaded(modname)
  local Util = require("lazy.core.util")
  local ret = Util.get_unloaded_rtp(modname)
  return vim.tbl_map(M.rewrite, ret)
end

---@type string[]
local packs = nil

function M.pack_unloaded()
  if packs then
    return packs
  end

  local sites = vim.opt.packpath:get() ---@type string[]
  local default_site = vim.fn.stdpath("data") .. "/site"
  if not vim.tbl_contains(sites, default_site) then
    sites[#sites + 1] = default_site
  end
  local Util = require("lazydev.util")
  packs = {} ---@type string[]
  for _, site in pairs(sites) do
    for _, pack in ipairs(vim.fn.expand(site .. "/pack/*/opt/*", false, true)) do
      if not pack:find("*", 1, true) then
        packs[#packs + 1] = M.rewrite(Util.norm(pack))
      end
    end
  end
  return packs
end

---@param modname string
---@return string[]
function M.get_unloaded(modname)
  return is_lazy and M.lazy_unloaded(modname) or M.pack_unloaded()
end

function M.get_plugin_path(name)
  if is_lazy then
    local Config = require("lazy.core.config")
    local plugin = Config.spec.plugins[name]
    return plugin and M.rewrite(plugin.dir)
  else
    for _, dir in
      ipairs(vim.opt.rtp:get() --[[@as string[] ]])
    do
      local basename = vim.fs.basename(dir)
      if basename == name then
        return M.rewrite(dir)
      end
    end
    for _, dir in ipairs(M.pack_unloaded()) do
      local basename = vim.fs.basename(dir)
      if basename == name then
        return M.rewrite(dir)
      end
    end
  end
end

function M.find_rock(modname)
  if not is_lazy then
    return
  end
  local Config = require("lazy.core.config")
  for _, plugin in pairs(Config.spec.plugins) do
    if plugin._.pkg and plugin._.pkg.source == "rockspec" then
      local root = Config.options.rocks.root .. "/" .. plugin.name
      root = root .. "/share/lua/5.1"
      for _, p in ipairs({ "/init.lua", ".lua" }) do
        if vim.uv.fs_stat(root .. "/" .. modname:gsub("%.", "/") .. p) then
          return root
        end
      end
    end
  end
end

---@param modname string
---@return string[]
function M.find_roots(modname)
  local ret = vim.loader.find(modname, {
    rtp = true,
    paths = M.get_unloaded(modname),
    patterns = { "", ".lua" },
    all = true,
  })
  return vim.tbl_map(
    ---@param mod vim.loader.ModuleInfo
    function(mod)
      local path = mod.modpath:gsub("/init%.lua$", ""):gsub("%.lua$", "")
      return path
    end,
    ret
  )
end

---@param fn fun(modname:string, modpath:string)
function M.topmods(fn)
  local ret = vim.loader.find("*", {
    all = true,
    rtp = true,
    paths = M.get_unloaded(""),
  })
  for _, mod in ipairs(ret) do
    fn(mod.modname, mod.modpath)
  end
end

--- Get the module name from a line,
--- either `---@module "modname"` or `require "modname"`
---@param line string
---@param opts? {before?:boolean}
---@return string?, boolean? forward_slash
function M.get_module(line, opts)
  local patterns = opts and opts.before and {
    M.PAT_MODULE_BEFORE,
    M.PAT_REQUIRE_BEFORE,
  } or {
    M.PAT_MODULE,
    M.PAT_REQUIRE,
  }
  for _, pat in ipairs(patterns) do
    local match = line:match(pat)
    if match then
      return match:gsub("/", "."), match:find("/", 1, true)
    end
  end
end

---@param path string
---@return string?
function M.get_plugin_name(path)
  local lua = path:find("/lua/", 1, true)
  if lua then
    local name = path:sub(1, lua - 1)
    local slash = name:reverse():find("/", 1, true)
    if slash then
      name = name:sub(#name - slash + 2)
      return name
    end
  end
end

---@param modname string
---@param fn fun(modname:string, modpath:string)
function M.lsmod(modname, fn)
  local roots = M.find_roots(modname)
  for _, root in ipairs(roots) do
    for name, type in vim.fs.dir(root) do
      local path = vim.fs.joinpath(root, name)
      if name == "init.lua" then
        -- fn(modname, path)
      elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
        fn(modname .. "." .. name:sub(1, -5), path)
      elseif type == "directory" and vim.uv.fs_stat(path .. "/init.lua") then
        fn(modname .. "." .. name, path .. "/init.lua")
      end
    end
  end
end

return M
