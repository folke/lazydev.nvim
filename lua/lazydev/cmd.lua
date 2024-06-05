local Util = require("lazydev.util")
local Workspace = require("lazydev.workspace")

local M = {}

---@type table<string, fun(args: string[])>
M.commands = {
  debug = function()
    local buf = vim.api.nvim_get_current_buf()
    local ws = Workspace.find({ buf = buf })
    if not ws then
      return Util.warn("No **LuaLS** workspace found.\nUse `:LazyDev lsp` to see settings of attached LSP clients.")
    end
    ws:debug({ details = true })
  end,
  lsp = function()
    local clients = Util.get_clients({ bufnr = 0 })
    local lines = {} ---@type string[]
    for _, client in ipairs(clients) do
      lines[#lines + 1] = "## " .. client.name
      lines[#lines + 1] = "```lua"
      lines[#lines + 1] = "settings = " .. vim.inspect(client.settings)
      lines[#lines + 1] = "```"
    end
    Util.info(lines)
  end,
}

function M.execute(input)
  local prefix, args = M.parse(input.args)
  prefix = prefix and prefix ~= "" and prefix or "debug"
  if not M.commands[prefix or ""] then
    return Util.error("Invalid command")
  end
  M.commands[prefix](args)
end

function M.complete(_, line)
  local prefix, args = M.parse(line)
  if #args > 0 then
    return {}
  end

  ---@param key string
  return vim.tbl_filter(function(key)
    return key:find(prefix, 1, true) == 1
  end, vim.tbl_keys(M.commands))
end

---@return string, string[]
function M.parse(args)
  local parts = vim.split(vim.trim(args), "%s+")
  if parts[1]:find("LazyDev") then
    table.remove(parts, 1)
  end
  if args:sub(-1) == " " then
    parts[#parts + 1] = ""
  end
  return table.remove(parts, 1) or "", parts
end

return M
