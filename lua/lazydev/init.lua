local M = {}

---@param opts? lazydev.Config
function M.setup(opts)
  require("lazydev.config").setup(opts)
end

--- Checks if the current buffer is in a workspace:
--- * part of the workspace root
--- * part of the workspace libraries
--- Returns the workspace root if found
---@param buf? integer
function M.find_workspace(buf)
  local fname = vim.api.nvim_buf_get_name(buf or 0)
  local Workspace = require("lazydev.workspace")
  local ws = Workspace.find({ path = fname })
  return ws and ws.root or nil
end

return M
