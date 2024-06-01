---@class lazydev.Pkg
local M = {}

local is_lazy = type(package.loaded.lazy) == "table"

---@param modname string
---@return string[]
function M.lazy_unloaded(modname)
  local Util = require("lazy.core.util")
  return Util.get_unloaded_rtp(modname)
end

---@param modname string
function M.pack_unloaded(modname)
  local sites = vim.opt.packpath:get() ---@type string[]
  local default_site = vim.fn.stdpath("data") .. "/site"
  if not vim.tbl_contains(sites, default_site) then
    sites[#sites + 1] = default_site
  end

  local packs = {} ---@type string[]
  for _, site in pairs(sites) do
    for _, pack in ipairs(vim.fn.expand(site .. "/pack/*/opt/*/lua", false, true)) do
      if not pack:find("*", 1, true) then
        packs[#packs + 1] = pack:sub(1, -5)
        packs[#packs + 1] = vim.fs.normalize(pack:sub(1, -5))
      end
    end
  end
  return packs
end

M.get_unloaded = is_lazy and M.lazy_unloaded or M.pack_unloaded

return M
