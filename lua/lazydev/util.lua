local M = {}

---@alias NotifyOpts {level?: number, title?: string, once?: boolean}

---@param msg string|string[]
---@param opts? NotifyOpts
function M.notify(msg, opts)
  opts = opts or {}
  msg = type(msg) == "table" and table.concat(msg, "\n") or msg
  ---@cast msg string
  msg = vim.trim(msg)
  return vim[opts.once and "notify_once" or "notify"](msg, opts.level, {
    title = opts.title or "lazydev.nvim",
    on_open = function(win)
      vim.wo[win].conceallevel = 3
      vim.wo[win].concealcursor = "n"
      vim.wo[win].spell = false
      vim.treesitter.start(vim.api.nvim_win_get_buf(win), "markdown")
    end,
  })
end

M.get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients

---@param path string
function M.is_absolute(path)
  return path:sub(1, 1) == "/" or path:sub(2, 2) == ":"
end

---@param path string
function M.norm(path)
  path = vim.fs.normalize(path)
  -- Special case for Windows drive letters
  -- vim.fs.normalize doesn't handle them correctly
  if path:sub(2, 2) == ":" then
    path = path:sub(1, 1):lower() .. path:sub(2)
  end
  return path
end

---@param msg string|string[]
---@param opts? NotifyOpts
function M.warn(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.WARN }, opts or {}))
end

---@param msg string|string[]
---@param opts? NotifyOpts
function M.error(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.ERROR }, opts or {}))
end

---@param msg string|string[]
---@param opts? NotifyOpts
function M.info(msg, opts)
  M.notify(msg, vim.tbl_extend("keep", { level = vim.log.levels.INFO }, opts or {}))
end

return M
