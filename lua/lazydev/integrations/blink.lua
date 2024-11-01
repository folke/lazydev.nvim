---@module 'blink.cmp'

local Buf = require("lazydev.buf")
local Config = require("lazydev.config")
local Pkg = require("lazydev.pkg")

--- @type blink.cmp.Source
local M = {}

function M.new()
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
  return { '"', "'", ".", "/" }
end

function M:enabled()
  return Buf.attached[vim.api.nvim_get_current_buf()] and true or false
end

function M:get_completions(ctx, callback)
  local before = string.sub(ctx.line, 1, ctx.cursor[2])

  local transformed_callback = function(items)
    callback({
      context = ctx,
      is_incomplete_forward = false,
      is_incomplete_backward = false,
      items = items,
    })
  end

  ---@type string?
  local req, forward_slash = Pkg.get_module(before, { before = true })
  if not req then
    return transformed_callback({})
  end
  local items = {} ---@type table<string,lsp.CompletionItem>

  ---@param modname string
  ---@param modpath string
  local function add(modname, modpath)
    local word = forward_slash and modname:gsub("%.", "/") or modname
    local parts = vim.split(modname, ".", { plain = true })
    local last = parts[#parts] or modname
    items[modname] = items[modname]
      or {
        label = word,
        kind = vim.lsp.protocol.CompletionItemKind.Module,
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
        insertText = last,
      }
    local item = items[modname]
    -- item.label = "test + " .. item.label

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

  transformed_callback(vim.tbl_values(items))

  -- TODO: cancel run_async
  return function() end
end

return M
