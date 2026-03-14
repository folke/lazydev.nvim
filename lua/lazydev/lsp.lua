local Workspace = require("lazydev.workspace")

---@class lazydev.Lsp
---@field client_id number
---@field updates number
---@field toggled_diagnostics table<number,boolean>

local M = {}
M.attached = {} ---@type table<number,lazydev.Lsp>
M.did_global_handler = false
M.supported_clients = { "lua_ls", "emmylua_ls" }

---@param client? vim.lsp.Client
function M.assert(client)
  assert(M.supports(client), "lazydev: Not a lua_ls client??")
end

---@param client? vim.lsp.Client
function M.supports(client)
  return client and vim.tbl_contains(M.supported_clients, client.name)
end

---@param client vim.lsp.Client
function M.attach_or_update(client)
  M.assert(client)

  if M.attached[client.id] then
    local lsp = M.attached[client.id]

    -- Temprorarily disable diagnostics on attached buffers
    if vim.fn.has("nvim-0.10") == 1 then
      for bufnr in pairs(client.attached_buffers) do
        if vim.api.nvim_buf_is_valid(bufnr) and vim.diagnostic.is_enabled({ bufnr = bufnr }) then
          lsp.toggled_diagnostics[bufnr] = true
          vim.diagnostic.enable(false, { bufnr = bufnr })
        end
      end
    end

    if vim.fn.has("nvim-0.11") == 1 then
      client:notify("workspace/didChangeConfiguration", {
        settings = { Lua = {} },
      })
    else
      ---@diagnostic disable-next-line: param-type-mismatch
      client.notify("workspace/didChangeConfiguration", {
        settings = { Lua = {} },
      })
    end
  else
    M.attached[client.id] = {
      client_id = client.id,
      updates = 0,
      toggled_diagnostics = {},
    }

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

return M
