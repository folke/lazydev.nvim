local Buf = require("lazydev.buf")
local Config = require("lazydev.config")
local Pkg = require("lazydev.pkg")

---@param map table<integer, table>
local function new_uid(map)
  local key ---@type integer|nil
  while true do
    if not key or map[key] then
      key = math.floor(math.random() * 10000)
    else
      return key
    end
  end
end

---@param args {pos: {[1]: integer, [2]: integer}, line: string} (row, col)
---@param callback fun(items: lsp.CompletionItem[])
local function complete(args, callback)
  if not Buf.attached[vim.api.nvim_get_current_buf()] then
    return callback({})
  end

  local req, forward_slash = Pkg.get_module(args.line)
  if not req then
    return callback({})
  end

  local items = {} ---@type table<string,lsp.CompletionItem>

  ---@param modname string
  ---@param modpath string
  local function add(modname, modpath)
    items[modname] = items[modname]
      or {
        label = forward_slash and modname:gsub("%.", "/") or modname,
        kind = vim.lsp.protocol.CompletionItemKind.Module,
      }
    local item = items[modname]

    local plugin = Pkg.get_plugin_name(modpath)
    if plugin then
      if item.documentation then
        item.documentation.value = item.documentation.value .. "\n- `" .. plugin .. "`"
      else
        item.documentation = {
          kind = vim.lsp.protocol.MarkupKind.Markdown,
          value = "# Plugins:\n" .. "- `" .. plugin .. "`",
        }
      end
    end
  end

  if not req:find(".", 1, true) then
    Pkg.topmods(add)
    for _, lib in ipairs(Config.libs) do
      for _, mod in ipairs(lib.mods) do
        add(mod, lib.path)
      end
    end
  else
    Pkg.lsmod(req:gsub("%.[^%.]*$", ""), add)
  end

  callback(vim.tbl_values(items))
end

local M = {}

function M.setup()
  local ok = pcall(require, "coq")
  if ok then
    COQsources = COQsources or {} ---@type table<integer, table>
    COQsources[new_uid(COQsources)] = {
      name = "lazy",
      fn = complete,
    }
  end
end

return M
