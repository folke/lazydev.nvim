local Config = require("lazydev.config")

---@class lazydev.Workspace
---@field root string
---@field client_id number
---@field settings table
---@field library string[]
local M = {}
M.__index = M

---@type table<string,lazydev.Workspace>
M.workspaces = {}

---@param client_id number
---@param root string
function M.new(client_id, root)
  local self = setmetatable({
    root = root,
    client_id = client_id,
    settings = {},
    library = {},
  }, M)
  return self
end

---@param client vim.lsp.Client|number
---@param root string
function M.get(client, root)
  local client_id = type(client) == "number" and client or client.id
  local id = client_id .. root
  if not M.workspaces[id] then
    M.workspaces[id] = M.new(client_id, root)
  end
  return M.workspaces[id]
end

function M.global()
  return M.get(-1, "global")
end

function M.find(buf)
  local client = vim.lsp.get_clients({
    name = "lua_ls",
    bufnr = buf,
  })[1]
  return client and M.get(client.id, M.get_root(client, buf))
end

---@param client vim.lsp.Client
---@param buf number
function M.get_root(client, buf)
  local uri = vim.uri_from_bufnr(buf)
  for _, ws in ipairs(client.workspace_folders or {}) do
    if (uri .. "/"):sub(1, #ws.uri + 1) == ws.uri .. "/" then
      return ws.name
    end
  end
  return client.root_dir or vim.api.nvim_buf_get_name(buf)
end

---@param path string
function M:add(path)
  if not vim.tbl_contains(self.library, path) then
    table.insert(self.library, path)
    return true
  end
end

function M:client()
  return vim.lsp.get_client_by_id(self.client_id)
end

function M:update()
  local client = self:client()
  if not client then
    return
  end
  local settings = vim.deepcopy(client.settings or {})

  local libs = {} ---@type string[]
  vim.list_extend(libs, M.global().library)
  vim.list_extend(libs, self.library)

  ---@type string[]
  local library = vim.tbl_get(settings, "Lua", "workspace", "library") or {}
  for _, path in ipairs(libs) do
    if not vim.tbl_contains(library, path) then
      table.insert(library, path)
    end
  end

  settings = vim.tbl_deep_extend("force", settings, {
    Lua = {
      runtime = {
        version = "LuaJIT",
        path = { "?.lua", "?/init.lua" },
        pathStrict = true,
      },
      workspace = {
        checkThirdParty = false,
        library = library,
      },
    },
  })

  if not vim.deep_equal(settings, self.settings) then
    self.settings = settings
    return true
  end
end

function M:debug()
  local Util = require("lazy.core.util")
  local Plugin = require("lazy.core.plugin")
  local lines = { "# " .. self.root }
  ---@type string[]
  local library = vim.tbl_get(self.settings, "Lua", "workspace", "library") or {}
  for _, lib in ipairs(library) do
    local plugin = Plugin.find(lib .. "/")
    table.insert(lines, "- " .. (plugin and "**" .. plugin.name .. "** " or "") .. ("`" .. lib .. "`"))
  end
  Util.info(lines, { title = "lazydev.nvim" })
end

return M
