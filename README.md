# 💻 `lazydev.nvim`

**lazydev.nvim** is a plugin that properly configures [LuaLS](https://luals.github.io/)
for editing your **Neovim** config by lazily updating your
workspace libraries.

## ✨ Features

- much faster auto-completion, since only the modules you `require`
  in open Neovim files will be loaded.
- no longer needed to configure what plugin sources you want
  to have enabled for a certain project
- load third-party addons from [LLS-Addons](https://github.com/LuaLS/LLS-Addons)
- will update your workspace libraries for:
  - **require** statements: `require("nvim-treesitter")`
  - **module annotations**: `---@module "nvim-treesitter"`
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) and [nvim_coq](https://github.com/ms-jpq/coq_nvim) completion source for the above

![2024-06-01_21-02-40](https://github.com/folke/lazydev.nvim/assets/292349/c5f23225-88eb-454d-9b4e-1bf9183f7ff8)

## ⚠️ Limitations

- If you have files that only use types from a plugin,
  then those types won't be available in your workspace.
- completion for module names when typing `require(...)`
  will only return loaded modules in your workspace.
- To get around the above, you can:
  - pre-load those plugins with the `library` option.
  - use the **nvim-cmp** or **coq_nvim** completion source to get all available modules.
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
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
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

Examples:

```lua

{
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- Library paths can be absolute
      "~/projects/my-awesome-lib",
      -- Or relative, which means they will be resolved from the plugin dir.
      "lazy.nvim",
      "luvit-meta/library",
      -- It can also be a table with trigger words / mods
      -- Only load luvit types when the `vim.uv` word is found
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      -- always load the LazyVim library
      "LazyVim",
      -- Only load the lazyvim library when the `LazyVim` global is found
      { path = "LazyVim", words = { "LazyVim" } },
      -- Load the wezterm types when the `wezterm` module is required
      -- Needs `justinsgithub/wezterm-types` to be installed
      { path = "wezterm-types", mods = { "wezterm" } },
      -- Load the xmake types when opening file named `xmake.lua`
      -- Needs `LelouchHe/xmake-luals-addon` to be installed
      { path = "xmake-luals-addon/library", files = { "xmake.lua" } },
    },
    -- always enable unless `vim.g.lazydev_enabled = false`
    -- This is the default
    enabled = function(root_dir)
      return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
    end,
    -- disable when a .luarc.json file is found
    enabled = function(root_dir)
      return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
    end,
  },
},
```

Default settings:

```lua
---@alias lazydev.Library {path:string, words:string[], mods:string[]}
---@alias lazydev.Library.spec string|{path:string, words?:string[], mods?:string[]}
---@class lazydev.Config
local defaults = {
  runtime = vim.env.VIMRUNTIME --[[@as string]],
  library = {}, ---@type lazydev.Library.spec[]
  integrations = {
    -- Fixes lspconfig's workspace management for LuaLS
    -- Only create a new workspace if the buffer is not part
    -- of an existing workspace or one of its libraries
    lspconfig = true,
    -- add the cmp source for completion of:
    -- `require "modname"`
    -- `---@module "modname"`
    cmp = true,
    -- same, but for Coq
    coq = false,
  },
  ---@type boolean|(fun(root:string):boolean?)
  enabled = function(root_dir)
      return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
  end,
}
```

## 🚀 Usage

Just install the plugin and start editing your Lua files.

If you don't use [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig),
then you can use `require('lazydev').find_workspace(buf?)` to check if the buffer
is part of an existing workspace or its libraries.

The `:LazyDev` command:

- `:LazyDev` or `:LazyDev debug` will show a notification with the **lazydev**
  settings for the current buffer.
- `:LazyDev lsp`: will show a notification with the settings for
  **any** attached LSP servers. Not limited to **LuaLS**.
