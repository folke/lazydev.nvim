local Config = require("lazydev.config")
local Pkg = require("lazydev.pkg")

local M = {}

---@type table<number,number>
M.attached = {}

---@type table<string, vim.loader.ModuleInfo|false>
M.modules = {}

--- Mapping library name to path
---@type string[]
M.library = {}

function M.setup()
  M.add(Config.runtime)
  for _, lib in pairs(Config.library) do
    M.add(lib)
  end

  -- debounce updates
  local update = vim.schedule_wrap(M.update)
  local timer = assert(vim.uv.new_timer())
  M.update = function()
    timer:start(100, 0, update)
  end

  local group = vim.api.nvim_create_augroup("lazydev", { clear = true })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      local buffer = ev.buf ---@type number
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client and client.name == "lua_ls" and Config.is_enabled(client) then
        M.on_attach(buffer)
      end
    end,
  })

  -- Attach to all existing clients
  for _, client in ipairs(M.get_clients()) do
    for buf in pairs(client.attached_buffers) do
      M.on_attach(buf)
    end
  end

  -- Check for library changes
  M.update()
end

--- Will add the path to the library list
--- if it is not already included.
--- Automatically appends "/lua" if it exists.
---@param path string
function M.add(path)
  path = vim.fs.normalize(path)
  -- try to resolve to a plugin path
  if path:sub(1, 1) ~= "/" and not vim.uv.fs_stat(path) then
    local name, extra = path:match("([^/]+)(/?.*)")
    if name then
      local pp = Pkg.get_plugin_path(name)
      path = pp and (pp .. extra) or path
    end
  end
  -- append /lua if it exists
  if not path:find("/lua/?$") and vim.uv.fs_stat(path .. "/lua") then
    path = path .. "/lua"
  end
  if not vim.tbl_contains(M.library, path) then
    table.insert(M.library, path)
  end
end

--- Gets all LuaLS clients that are enabled
function M.get_clients()
  ---@param client vim.lsp.Client
  return vim.tbl_filter(function(client)
    return Config.is_enabled(client)
  end, vim.lsp.get_clients({ name = "lua_ls" }))
end

function M.on_attach(buf)
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
  M.update()
end

--- Triggered when lines are changed
---@param buf number
---@param first number
---@param last number
function M.on_lines(buf, first, last)
  local lines = vim.api.nvim_buf_get_lines(buf, first, last, false)
  for _, line in ipairs(lines) do
    local module = Pkg.get_module(line)
    if module then
      M.on_require(module)
    end
  end
end

--- Check if a module is available and add it to the library
---@param modname string
function M.on_require(modname)
  local mod = vim.loader.find(modname)[1]
  if not mod then
    local paths = Pkg.get_unloaded(modname)
    mod = vim.loader.find(modname, { rtp = false, paths = paths })[1]
  end

  M.modules[modname] = mod or false

  if mod then
    local lua = mod.modpath:find("/lua/", 1, true)
    local path = lua and mod.modpath:sub(1, lua + 3) or mod.modpath
    if path and not vim.tbl_contains(M.library, path) then
      table.insert(M.library, path)
      M.update()
    end
  end
end

---@param client vim.lsp.Client
function M.set_handlers(client)
  client.handlers["workspace/configuration"] = client.handlers["workspace/configuration"]
    ---@param params lsp.ConfigurationParams
    or function(err, params, ctx, cfg)
      ---@type any[]
      local ret = vim.deepcopy(vim.lsp.handlers["workspace/configuration"](err, params, ctx, cfg))
      -- Don't set workspace libraries for the fallback scope
      for i, item in ipairs(params.items) do
        if item.section == "Lua" and not item.scopeUri and type(ret[i]) == "table" and ret[i].workspace then
          ret[i].workspace.library = nil
        end
      end
      return ret
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
    M.set_handlers(client)
    local settings = vim.deepcopy(client.settings or {})

    ---@type string[]
    local library = vim.tbl_get(settings, "Lua", "workspace", "library") or {}
    for _, path in ipairs(M.library) do
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

    if not vim.deep_equal(settings, client.settings) then
      if Config.debug then
        M.debug()
      end
      client.settings = settings
      client.notify("workspace/didChangeConfiguration", {
        settings = settings,
      })
    end
  end
end

function M.debug()
  local Util = require("lazy.core.util")
  local Plugin = require("lazy.core.plugin")
  local lines = {}
  for _, lib in ipairs(M.library) do
    local plugin = Plugin.find(lib .. "/")
    table.insert(lines, "- " .. (plugin and "**" .. plugin.name .. "** " or "") .. ("`" .. lib .. "`"))
  end
  Util.info(lines, { title = "lazydev.nvim" })
end

return M
