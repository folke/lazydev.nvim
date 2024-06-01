# 💻 `lazydev.nvim`

**lazydev.nvim** is a plugin that properly configures [lua_ls](https://luals.github.io/)
for editing your **Neovim** config by lazily updating your
workspace libraries.

## 🚀 Features

- much faster auto-completion, since only the modules you `require`
  in open Neovim files will be loaded.
- no longer needed to configure what plugin sources you want
  to have enabled for a certain project
- load third-party addons from [LLS-Addons](https://github.com/LuaLS/LLS-Addons)

## ⚡️ Requirements

- Neovim >= 0.10.0
- [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager

## 📦 Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        vim.env.LAZY .. "/luvit-meta/library", -- see below
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}
```
