local Workspace = require("lazydev.workspace")

local M = {}
M.attached = {} ---@type table<number,number>
M.did_global_handler = false

---@param client? vim.lsp.Client
function M.assert(client)
  assert(M.supports(client), "lazydev: Not a lua_ls client??")
end

---@param client? vim.lsp.Client
function M.supports(client)
  return client and vim.tbl_contains({ "lua_ls", "emmylua-analyzer-rust" }, client.name)
end

---@param client vim.lsp.Client
function M.attach(client)
  if M.attached[client.id] then
    return
  end

  M.assert(client)

  M.attached[client.id] = client.id

  -- lspconfig uses the same empty table for all clients.
  -- We need to make sure that each client has its own handlers table.
  client.handlers = vim.tbl_extend("force", {}, client.handlers or {})

  if vim.fn.has("nvim-0.10") == 0 then
    if M.did_global_handler then
      return
    end
    M.did_global_handler = true
    local orig = vim.lsp.handlers["workspace/configuration"]
    vim.lsp.handlers["workspace/configuration"] = function(err, params, ctx, cfg)
      if M.attached[ctx.client_id] then
        return M.on_workspace_configuration(err, params, ctx, cfg)
      end
      return orig(err, params, ctx, cfg)
    end
  else
    client.handlers["workspace/configuration"] = M.on_workspace_configuration
  end
end

---@param params lsp.ConfigurationParams
function M.on_workspace_configuration(err, params, ctx, cfg)
  local client = vim.lsp.get_client_by_id(ctx.client_id)
  M.assert(client)
  if not client or not params.items or #params.items == 0 then
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
        local ws = item.scopeUri and Workspace.get(client, vim.uri_to_fname(item.scopeUri)) or Workspace.single(client)
        if ws:enabled() then
          settings = ws.settings
        end
      end

      local keys = vim.split(item.section, ".", { plain = true }) --- @type string[]
      local value = vim.tbl_get(settings or {}, unpack(keys))
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

---@param client vim.lsp.Client
function M.update(client)
  M.assert(client)
  client.notify("workspace/didChangeConfiguration", {
    settings = { Lua = {} },
  })
end

return M
