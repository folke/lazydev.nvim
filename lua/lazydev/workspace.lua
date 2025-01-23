local Config = require("lazydev.config")
local Pkg = require("lazydev.pkg")
local Util = require("lazydev.util")

---@class lazydev.Workspace
---@field root string
---@field client_id number
---@field settings table
---@field library string[]
local M = {}
M.__index = M
M.SINGLE = "single"
M.GLOBAL = "global"

---@type table<string,lazydev.Workspace>
M.workspaces = {}

function M.is_special(root)
  return root == M.SINGLE or root == M.GLOBAL
end

---@param client_id number
---@param root string
function M.new(client_id, root)
  local self = setmetatable({
    root = root,
    client_id = client_id,
    settings = {},
    library = {},
  }, M)
  if not M.is_special(root) then
    self:add(root)
  end
  return self
end

---@param client vim.lsp.Client|number
---@param root string
function M.get(client, root)
  root = M.is_special(root) and root or Util.norm(root)
  local client_id = type(client) == "number" and client or client.id
  local id = client_id .. root
  if not M.workspaces[id] then
    M.workspaces[id] = M.new(client_id, root)
  end
  return M.workspaces[id]
end

function M.global()
  return M.get(-1, M.GLOBAL)
end

---@param client vim.lsp.Client
function M.single(client)
  return M.get(client, M.SINGLE)
end

---@param opts {buf?:number, path?:string}
function M.find(opts)
  if opts.buf then
    local Lsp = require("lazydev.lsp")
    local clients = Util.get_clients({ bufnr = opts.buf })
    clients = vim.tbl_filter(function(client)
      return client and Lsp.supports(client)
    end, clients)
    local client = clients[1]
    return client and M.get(client.id, M.get_root(client, opts.buf))
  elseif opts.path then
    for _, ws in pairs(M.workspaces) do
      if not M.is_special(ws.root) and ws:has(opts.path) then
        return ws
      end
    end
  end
end

---@param path string
---@param opts? {library?:boolean}
function M:has(path, opts)
  opts = opts or {}
  path = Util.norm(path)
  local dirs = { self.root } ---@type string[]
  if opts.library ~= false then
    vim.list_extend(dirs, self.library)
    vim.list_extend(dirs, M.global().library)
  end
  for _, dir in ipairs(dirs) do
    if (path .. "/"):sub(1, #dir + 1) == dir .. "/" then
      return true
    end
  end
end

---@param client vim.lsp.Client
---@param buf number
function M.get_root(client, buf)
  local uri = vim.uri_from_bufnr(buf)
  for _, ws in ipairs(client.workspace_folders or {}) do
    if (uri .. "/"):sub(1, #ws.uri + 1) == ws.uri .. "/" then
      return ws.name
    end
  end
  return client.root_dir or "single"
end

---@param path string|string[]
function M:add(path)
  if type(path) == "table" then
    for _, p in ipairs(path) do
      self:add(p)
    end
    return
  end
  ---@cast path string
  -- ignore special workspaces
  if M.is_special(path) then
    return
  end
  -- normalize
  path = Util.norm(path)

  -- try to resolve to a plugin path
  if not Util.is_absolute(path) and not vim.uv.fs_stat(path) then
    local name, extra = path:match("([^/]+)(/?.*)")
    if name then
      local pp = Pkg.get_plugin_path(name)
      path = pp and (pp .. extra) or path
    end
  end

  path = vim.uv.fs_realpath(path) or path
  path = Util.norm(path) -- normalize again
  -- append /lua if it exists
  if Config.lua_root and not path:find("/lua/?$") and vim.uv.fs_stat(path .. "/lua") then
    path = path .. "/lua"
  end
  if path ~= self.root and not vim.tbl_contains(self.library, path) then
    table.insert(self.library, path)
    if self.root ~= M.GLOBAL then
      require("lazydev.buf").update()
    end
  end
end

function M:client()
  return vim.lsp.get_client_by_id(self.client_id)
end

function M:enabled()
  return self.root == M.GLOBAL or Config.is_enabled(self.root)
end

function M:update()
  local client = self:client()
  if not client then
    return
  end
  if not self:enabled() then
    return
  end
  local settings = vim.deepcopy(client.settings or {})

  local libs = {} ---@type string[]
  vim.list_extend(libs, M.global().library)
  vim.list_extend(libs, self.library)

  ---@type string[]
  local library = vim.tbl_get(settings, "Lua", "workspace", "library") or {}
  for _, path in ipairs(libs) do
    if not vim.tbl_contains(library, path) then
      table.insert(library, path)
    end
  end

  settings = vim.tbl_deep_extend("force", settings, {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = Config.lua_root and { "?.lua", "?/init.lua" } or { "lua/?.lua", "lua/?/init.lua" },
        pathStrict = true,
      },
      workspace = {
        checkThirdParty = false,
        library = library,
        ignoreDir = Config.lua_root and { "/lua" } or nil,
      },
    },
  })

  if not vim.deep_equal(settings, self.settings) then
    self.settings = settings
    if Config.debug then
      self:debug()
    end
    return true
  end
end

---@param opts? {details: boolean}
function M:debug(opts)
  local rc = not M.is_special(self.root) and vim.fs.find(".luarc.json", { upward = true, path = self.root })[1]
  if rc then
    Util.warn("Found `.luarc.json` in workspace. This may break **lazydev.nvim**\n- `" .. rc .. "`")
  end
  opts = opts or {}
  local root = M.is_special(self.root) and "[" .. self.root .. "]" or vim.fn.fnamemodify(self.root, ":~")
  local lines = { "## " .. root }
  ---@type string[]
  local library = vim.tbl_get(self.settings, "Lua", "workspace", "library") or {}
  for _, lib in ipairs(library) do
    lib = vim.fn.fnamemodify(lib, ":~")
    local plugin = Pkg.get_plugin_name(lib .. "/")
    table.insert(lines, "- " .. (plugin and "**" .. plugin .. "** " or "") .. ("`" .. lib .. "`"))
  end
  if opts.details then
    lines[#lines + 1] = "```lua"
    lines[#lines + 1] = "settings = " .. vim.inspect(self.settings)
    lines[#lines + 1] = "```"
  end
  Util.info(lines)
end

return M
