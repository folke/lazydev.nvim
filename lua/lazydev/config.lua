---@class lazydev.Config.mod: lazydev.Config
local M = {}

---@alias lazydev.Library {path:string, words:string[], mods:string[], files:string[]}
---@alias lazydev.Library.spec string|{path:string, words?:string[], mods?:string[], files?:string[]}
---@class lazydev.Config
local defaults = {
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type lazydev.Library.spec[]
  integrations = {
    -- Fixes lspconfig workspace management for LuaLS
    -- Only create a new workspace if the buffer is not part
    -- of an existing workspace or one of its libraries
    lspconfig = true,
    -- add the cmp source for completion of:
    -- `require "modname"`
    -- `---@module "modname"`
    cmp = true,
    -- same, but for Coq
    coq = false,
  },
  ---@type boolean|(fun(root:string):boolean?)
  enabled = function(root_dir)
    return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
  debug = false,
}

M.libs = {} ---@type lazydev.Library[]
M.words = {} ---@type table<string, string[]>
M.mods = {} ---@type table<string, string[]>
M.files = {} ---@type table<string, string[]>

---@type lazydev.Config
local options

---@param root string
---@return boolean
function M.is_enabled(root)
  local enabled = M.enabled
  if type(enabled) == "function" then
    return enabled(root) and true or false
  end
  return enabled
end

M.have_0_10 = vim.fn.has("nvim-0.10") == 1
M.lua_root = true

---@param opts? lazydev.Config
function M.setup(opts)
  if not M.have_0_10 then
    local msg = "lazydev.nvim requires Neovim >= 0.10"
    vim.notify_once(msg, vim.log.levels.ERROR, { title = "lazydev.nvim" })
    error(msg)
    return
  end

  ---@type lazydev.Config
  options = vim.tbl_deep_extend("force", {}, options or defaults, opts or {})

  M.libs, M.words, M.mods, M.files = {}, {}, {}, {}
  local runtime = require("lazydev.util").norm(options.runtime)
  table.insert(M.libs, {
    path = vim.uv.fs_stat(runtime) and runtime or vim.env.VIMRUNTIME,
    words = {},
    mods = {},
    files = {},
  })
  for _, lib in pairs(M.library) do
    table.insert(M.libs, {
      path = type(lib) == "table" and lib.path or lib,
      words = type(lib) == "table" and lib.words or {},
      mods = type(lib) == "table" and lib.mods or {},
      files = type(lib) == "table" and lib.files or {},
    })
  end

  for _, lib in ipairs(M.libs) do
    for _, word in ipairs(lib.words) do
      M.words[word] = M.words[word] or {}
      table.insert(M.words[word], lib.path)
    end
    for _, mod in ipairs(lib.mods) do
      M.mods[mod] = M.mods[mod] or {}
      table.insert(M.mods[mod], lib.path)
    end
    for _, file in ipairs(lib.files) do
      M.files[file] = M.files[file] or {}
      table.insert(M.files[file], lib.path)
    end
  end

  vim.api.nvim_create_user_command("LazyDev", function(...)
    require("lazydev.cmd").execute(...)
  end, {
    nargs = "*",
    complete = function(...)
      return require("lazydev.cmd").complete(...)
    end,
    desc = "lazydev.nvim",
  })

  vim.schedule(function()
    require("lazydev.buf").setup()
    require("lazydev.integrations").setup()
  end)
  return options
end

return setmetatable(M, {
  __index = function(_, key)
    options = options or M.setup()
    return options[key]
  end,
})
