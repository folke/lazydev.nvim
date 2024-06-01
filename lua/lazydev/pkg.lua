---@class lazydev.Pkg
---@field get_unloaded fun(modname: string): string[]
---@field get_library fun(mod: vim.loader.ModuleInfo): string?
local M = {}

local is_lazy = type(package.loaded.lazy) == "table"

if is_lazy then
  ----------------------------------------
  --- Lazy
  ----------------------------------------
  ---@param modname string
  function M.get_unloaded(modname)
    local Util = require("lazy.core.util")
    return Util.get_unloaded_rtp(modname)
  end

  ---@param mod vim.loader.ModuleInfo
  function M.get_library(mod)
    local Plugin = require("lazy.core.plugin")
    local plugin = Plugin.find(mod.modpath)
    return plugin and (plugin.dir .. "/lua")
  end
else
  ----------------------------------------
  --- Neovim Packages
  ----------------------------------------
  ---@param modname string
  function M.get_unloaded(_)
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
        end
      end
    end
    return packs
  end

  ---@param mod vim.loader.ModuleInfo
  function M.get_library(mod)
    return mod.modpath:match(".*/lua") or mod.modpath
  end
end

return M
