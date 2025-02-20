local Config = require("lazydev.config")
local Lsp = require("lazydev.lsp")
local Pkg = require("lazydev.pkg")
local Util = require("lazydev.util")
local Workspace = require("lazydev.workspace")

local M = {}

---@type table<number,number>
M.attached = {}

---@type table<string, vim.loader.ModuleInfo|false>
M.modules = {}

function M.setup()
  for _, lib in ipairs(Config.libs) do
    if #lib.words == 0 and #lib.mods == 0 and #lib.files == 0 then
      Workspace.global():add(lib.path)
    end
  end

  -- debounce updates
  local update = vim.schedule_wrap(M.update)
  local timer = assert(vim.uv.new_timer())
  M.update = function()
    timer:start(100, 0, update)
  end

  local group = vim.api.nvim_create_augroup("lazydev", { clear = true })

  vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
    group = group,
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and Lsp.supports(client) then
        if ev.event == "LspAttach" then
          M.on_attach(client, ev.buf)
        else
          M.attached[ev.buf] = nil
        end
      end
    end,
  })

  -- Attach to all existing clients
  for _, client in ipairs(M.get_clients()) do
    for buf in pairs(client.attached_buffers) do
      M.on_attach(client, buf)
    end
  end

  -- Check for library changes
  M.update()
end

--- Gets all LuaLS clients that are enabled
---@return vim.lsp.Client[]
function M.get_clients()
  local ret = Util.get_clients()
  return vim.tbl_filter(function(client)
    return Lsp.supports(client)
  end, ret)
end

--- Attach to the buffer
---@param client vim.lsp.Client
function M.on_attach(client, buf)
  local root = Workspace.get_root(client, buf)
  if not Config.is_enabled(root) then
    return
  end
  if M.attached[buf] then
    return
  end
  M.attached[buf] = buf
  -- Attach to buffer events
  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function(_, b, _, first, _, last)
      M.on_lines(b, first, last)
    end,
    on_detach = function()
      M.attached[buf] = nil
    end,
    on_reload = function()
      M.on_lines(buf, 0, vim.api.nvim_buf_line_count(buf))
    end,
  })
  -- Trigger initial scan
  M.on_lines(buf, 0, vim.api.nvim_buf_line_count(buf))
  M.on_file(buf)
  M.update()
end

--- Triggered when lines are changed
---@param buf number
---@param first number
---@param last number
function M.on_lines(buf, first, last)
  local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
  for _, line in ipairs(lines) do
    M.on_line(buf, line)
  end
end

---@param buf number
---@param line string
function M.on_line(buf, line)
  -- Check for words
  for word, paths in pairs(Config.words) do
    if line:find(word) then
      Workspace.find({ buf = buf }):add(paths)
    end
  end
  -- Check for modules
  local module = Pkg.get_module(line)
  if module then
    M.on_mod(buf, module)
  end
end

--- Check if a module is available and add it to the library
---@param buf number
---@param modname string
function M.on_mod(buf, modname)
  local ws = Workspace.find({ buf = buf })

  -- Check for configured modules
  if Config.mods[modname] then
    return ws:add(Config.mods[modname])
  end

  -- Check for modules in Neovim plugins
  local mod = M.modules[modname]

  if mod == nil then
    -- resolve module in order:
    -- * workspace root
    -- * loaded plugins
    -- * unloaded plugins
    mod = vim.loader.find(modname, { rtp = false, paths = { ws.root } })[1]
      or vim.loader.find(modname)[1]
      or vim.loader.find(modname, { rtp = false, paths = Pkg.get_unloaded(modname) })[1]
      or false
    M.modules[modname] = mod
  end

  if mod then
    local lua = mod.modpath:find("/lua/", 1, true)
    local path = lua and mod.modpath:sub(1, lua - 1) or mod.modpath
    if path then
      ws:add(path)
    end
  else
    local modpath = Pkg.find_rock(modname)
    if modpath then
      ws:add(modpath)
    end
  end
end

---@param buf number
function M.on_file(buf)
  -- Check for words
  for file, paths in pairs(Config.files) do
    if file == vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p:t") then
      Workspace.find({ buf = buf }):add(paths)
    end
  end
end

--- Update LuaLS settings with the current library
function M.update()
  if package.loaded["neodev"] then
    vim.notify_once(
      "Please disable `neodev.nvim` in your config.\nThis is no longer needed when you use `lazydev.nvim`",
      vim.log.levels.WARN
    )
  end
  for _, client in ipairs(M.get_clients()) do
    local update = false

    ---@param ws lsp.WorkspaceFolder
    local folders = vim.tbl_map(function(ws)
      return Workspace.get(client.id, ws.name)
    end, client.workspace_folders or {})

    if #folders == 0 then
      folders = { Workspace.single(client) }
    end

    for _, w in ipairs(folders) do
      if w:update() then
        update = true
      end
    end

    if update then
      Lsp.attach(client)
      Lsp.update(client)
    end
  end
end

return M
