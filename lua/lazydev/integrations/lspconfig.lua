local M = {}

function M.setup()
  local ok, Manager = pcall(require, "lspconfig.manager")
  if not ok then
    return
  end
  local Lsp = require("lazydev.lsp")

  local try_add = Manager.try_add

  --- @param buf integer
  --- @param project_root? string
  function Manager:try_add(buf, project_root)
    local is_supported = false
    for _, ids in pairs(self._clients) do
      for _, client_id in ipairs(ids) do
        local client = vim.lsp.get_client_by_id(client_id)
        if client and Lsp.supports(client) then
          is_supported = true
          break
        end
      end
    end
    if is_supported and not project_root then
      local root = require("lazydev").find_workspace(buf)
      if root then
        return self:add(root, false, buf)
      end
    end
    return try_add(self, buf, project_root)
  end
end

return M
