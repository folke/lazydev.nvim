---@class lazydev.Config.mod: lazydev.Config
local M = {}

---@alias lazydev.Library {path:string, words:string[], mods:string[]}
---@alias lazydev.Library.spec string|{path:string, words?:string[], mods?:string[]}
---@class lazydev.Config
local defaults = {
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type lazydev.Library.spec[]
  ---@type boolean|(fun(root:string):boolean?)
  enabled = function(root_dir)
    return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
  -- add the cmp source for completion of:
  -- `require "modname"`
  -- `---@module "modname"`
  cmp = true,
  debug = false,
}

M.libs = {} ---@type lazydev.Library[]
M.words = {} ---@type table<string, string[]>
M.mods = {} ---@type table<string, string[]>

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

---@param opts? lazydev.Config
function M.setup(opts)
  if vim.fn.has("nvim-0.10") == 0 then
    local msg = "lazydev.nvim requires Neovim >= 0.10"
    vim.notify_once(msg, vim.log.levels.ERROR, { title = "lazydev.nvim" })
    error(msg)
    return
  end

  options = vim.tbl_deep_extend("force", {}, options or defaults, opts or {})

  M.libs, M.words, M.mods = {}, {}, {}
  local runtime = require("lazydev.util").norm(options.runtime)
  table.insert(M.libs, {
    path = vim.uv.fs_stat(runtime) and runtime or vim.env.VIMRUNTIME,
    words = {},
    mods = {},
  })
  for _, lib in pairs(M.library) do
    table.insert(M.libs, {
      path = type(lib) == "table" and lib.path or lib,
      words = type(lib) == "table" and lib.words or {},
      mods = type(lib) == "table" and lib.mods or {},
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
    require("lazydev.cmp").setup()
  end)
  return options
end

return setmetatable(M, {
  __index = function(_, key)
    options = options or M.setup()
    return options[key]
  end,
})
