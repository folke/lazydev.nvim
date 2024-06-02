# 💻 `lazydev.nvim`

**lazydev.nvim** is a plugin that properly configures [LuaLS](https://luals.github.io/)
for editing your **Neovim** config by lazily updating your
workspace libraries.

## 🚀 Features

- much faster auto-completion, since only the modules you `require`
  in open Neovim files will be loaded.
- no longer needed to configure what plugin sources you want
  to have enabled for a certain project
- load third-party addons from [LLS-Addons](https://github.com/LuaLS/LLS-Addons)
- will update your workspace libraries for:
  - **require** statements: `require("nvim-treesitter")`
  - **module annotations**: `---@module "nvim-treesitter"`
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) completion source for the above

![2024-06-01_21-02-40](https://github.com/folke/lazydev.nvim/assets/292349/c5f23225-88eb-454d-9b4e-1bf9183f7ff8)

## ⚠️ Limitations

- If you have files that only use types from a plugin,
  then those types won't be available in your workspace.
- completion for module names when typing `require(...)`
  will only return loaded modules in your workspace.
- To get around the above, you can:
  - pre-load those plugins with the `library` option.
  - use the **nvim-cmp** completion source to get all available modules.
- Neovim types are **NOT** included and also no longer needed
  on **Neovim >= 0.10**

## ⚡️ Requirements

- Neovim >= 0.10.0
- [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager
  - **OR** a plugin manager that uses **Neovim**'s native package system

## 📦 Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- Library items can be absolute paths
        -- "~/projects/my-awesome-lib",
        -- Or relative, which means they will be resolved as a plugin
        -- "LazyVim",
        -- When relative, you can also provide a path to the library in the plugin dir
        "luvit-meta/library", -- see below
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  { -- optional completion source for require statements and module annotations
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
    end,
  },
  -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}
```

## ⚙️ Configuration

> [!TIP]
> You can force enable/disable **lazydev** in certain project folders using [:h 'exrc'](https://neovim.io/doc/user/options.html#'exrc')
> with `vim.g.lazydev_enabled = true` or `vim.g.lazydev_enabled = false`

Default settings:

```lua
{
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type string[]|table<string,string>
  ---@type boolean|(fun(root:string):boolean?)
  enabled = function(root_dir)
    if vim.g.lazydev_enabled ~= nil then
      return vim.g.lazydev_enabled
    end
    return true
  end,
  -- add the cmp source for completion of:
  -- `require "modname"`
  -- `---@module "modname"`
  cmp = true,
}
```
