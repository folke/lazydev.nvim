local M = {}

function M.setup()
  if vim.fn.has("nvim-0.11.2") == 0 or not vim.lsp.is_enabled then
    return
  end
  for _, server in ipairs(require("lazydev.lsp").supported_clients) do
    if vim.lsp.is_enabled(server) then
      vim.lsp.config(server, {
        root_dir = function(bufnr, on_dir)
          on_dir(require("lazydev").find_workspace(bufnr))
        end,
      })
    end
  end
end

return M
