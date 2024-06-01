local M = {}

---@param opts? lazydev.Config
function M.setup(opts)
  require("lazydev.config").setup(opts)
end

return M
