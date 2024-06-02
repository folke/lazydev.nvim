---@class lazydev.Config.mod: lazydev.Config
local M = {}

---@class lazydev.Config
local defaults = {
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type string[]
  ---@type boolean|(fun(client:vim.lsp.Client):boolean?)
  enabled = function(client)
    if vim.g.lazydev_enabled ~= nil then
      return vim.g.lazydev_enabled
    end
    return client.root_dir and vim.uv.fs_stat(client.root_dir .. "/lua") and true or false
  end,
  debug = false,
  -- add the cmp source for completion of:
  -- `require "modname"`
  -- `---@module "modname"`
  cmp = true,
}

---@type lazydev.Config
local options

---@return boolean
function M.is_enabled(client)
  local enabled = M.enabled
  if type(enabled) == "function" then
    return enabled(client) and true or false
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
