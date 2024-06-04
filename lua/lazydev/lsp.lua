local Workspace = require("lazydev.workspace")

local M = {}
M.attached = {} ---@type table<number,number>

---@param client vim.lsp.Client
function M.attach(client)
  if M.attached[client.id] then
    return
  end
  M.attached[client.id] = client.id
  ---@param params lsp.ConfigurationParams
  client.handlers["workspace/configuration"] = function(err, params, ctx, cfg)
    if not params.items or #params.items == 0 then
      return {}
    end

    -- fallback scope
    if #(client.workspace_folders or {}) > 0 and not params.items[1].scopeUri then
      return {}
    end

    local response = {}
    for _, item in ipairs(params.items) do
      if item.section then
        local settings = client.settings
        if item.section == "Lua" then
          local ws = item.scopeUri and Workspace.get(client, vim.uri_to_fname(item.scopeUri))
            or Workspace.single(client)
          if ws:enabled() then
            settings = ws.settings
          end
        end

        local keys = vim.split(item.section, ".", { plain = true }) --- @type string[]
        local value = vim.tbl_get(settings, unpack(keys))
        -- For empty sections with no explicit '' key, return settings as is
        if value == nil and item.section == "" then
          value = settings
        end
        if value == nil then
          value = vim.NIL
        end
        table.insert(response, value)
      end
    end
    return response
  end
end

---@param client vim.lsp.Client
function M.update(client)
  client.notify("workspace/didChangeConfiguration", {
    settings = { Lua = {} },
  })
end

return M
