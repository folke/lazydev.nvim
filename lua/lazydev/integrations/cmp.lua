local Buf = require("lazydev.buf")
local Config = require("lazydev.config")
local Pkg = require("lazydev.pkg")

local Source = {}

function Source:get_trigger_characters()
  return { '"', "'", ".", "/" }
end

---@param params cmp.SourceCompletionApiParams
---@param callback fun(items: lsp.CompletionItem[])
function Source:complete(params, callback)
  local cmp = require("cmp")
  local before = params.context.cursor_before_line
  ---@type string?
  local req, forward_slash = Pkg.get_module(before, { before = true })
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
        kind = cmp.lsp.CompletionItemKind.Module,
      }
    local item = items[modname]

    local plugin = Pkg.get_plugin_name(modpath)
    if plugin then
      if item.documentation then
        item.documentation.value = item.documentation.value .. "\n- `" .. plugin .. "`"
      else
        item.documentation = {
          kind = cmp.lsp.MarkupKind.Markdown,
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

function Source:is_available()
  return Buf.attached[vim.api.nvim_get_current_buf()]
end

local M = {}

function M.setup()
  local ok, cmp = pcall(require, "cmp")
  if ok then
    cmp.register_source("lazydev", Source)
  end
end

return M
