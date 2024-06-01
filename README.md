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

![2024-06-01_21-02-40](https://github.com/folke/lazydev.nvim/assets/292349/c5f23225-88eb-454d-9b4e-1bf9183f7ff8)

## ⚠️ Limitations

- If you have files that only use types from a plugin,
  then those types won't be available in your workspace.
- completion for module names when typing `require(...)`
  will only return loaded modules in your workspace.
- To get around the above, you can pre-load those plugins with the `library` option.
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
        vim.env.LAZY .. "/luvit-meta/library", -- see below
        -- You can also add plugins you always want to have loaded.
        -- Useful if the plugin has globals or types you want to use
        -- vim.env.LAZY .. "/LazyVim", -- see below
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  -- { "folke/neodev.nvim", enabled = false }, -- make sure to uninstall or disable neodev.nvim
}
```

## ⚙️ Configuration

Default settings:

```lua
{
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type string[]
  ---@param client vim.lsp.Client
  enabled = function(client)
    if vim.g.lazydev_enabled ~= nil then
      return vim.g.lazydev_enabled
    end
    return client.root_dir and vim.uv.fs_stat(client.root_dir .. "/lua") and true or false
  end,
}
```
