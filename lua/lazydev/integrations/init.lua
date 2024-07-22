local Config = require("lazydev.config")

local M = {}

M.plugins = {
  ["nvim-cmp"] = "cmp",
  ["coq_nvim"] = "coq",
  lspconfig = "lspconfig",
}

---@type table<string, boolean>
M.loaded = {}

function M.setup()
  if package.loaded.lazy then
    local LazyConfig = require("lazy.core.config")
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("lazydev-integrations", { clear = true }),
      pattern = "LazyLoad",
      callback = function(event)
        local name = M.plugins[event.data]
        if name then
          M.load(name)
        end
      end,
    })
    for name, enabled in pairs(Config.integrations) do
      if enabled then
        local plugin = LazyConfig.plugins[M.plugins[name]]
        local is_loaded = plugin and plugin._.loaded
        if is_loaded then
          M.load(name)
        end
      end
    end
  else
    for name, enabled in pairs(Config.integrations) do
      if enabled then
        M.load(name)
      end
    end
  end
end

---@param name string
function M.load(name)
  if not M.loaded[name] then
    M.loaded[name] = true
    require("lazydev.integrations." .. name).setup()
  end
end

return M
