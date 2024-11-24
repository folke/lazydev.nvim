# Changelog

## [1.9.0](https://github.com/folke/lazydev.nvim/compare/v1.8.0...v1.9.0) (2024-11-24)


### Features

* **integrations:** added blink integration. Closes [#71](https://github.com/folke/lazydev.nvim/issues/71) ([c4cd076](https://github.com/folke/lazydev.nvim/commit/c4cd076ad8f04bbe9749f136848cb9a2c16270b8))


### Bug Fixes

* **blink:** complete the extra mod names only ([d580089](https://github.com/folke/lazydev.nvim/commit/d5800897d9180cea800023f2429bce0a94ed6064))
* **completion:** show top mods when no module typed yet ([7008928](https://github.com/folke/lazydev.nvim/commit/7008928168c63bc3ddc1e1aa2ec27b3591670ae8))
* **integrations:** correct mapping for loaded plugins ([2c09c87](https://github.com/folke/lazydev.nvim/commit/2c09c8782f4bd83cfc98b272eb9ab687c3e746f8))
* **pkg:** lsmod should not return the module itself ([74443e2](https://github.com/folke/lazydev.nvim/commit/74443e2f0c40f77ec3ffb5ea7cd7b613c05da755))

## [1.8.0](https://github.com/folke/lazydev.nvim/compare/v1.7.1...v1.8.0) (2024-07-25)


### Features

* make lazydev partially work on Neovim &lt; 0.10 ([6c24937](https://github.com/folke/lazydev.nvim/commit/6c249371681a3a9f50b6953ca2116e4ec771b809))

## [1.7.1](https://github.com/folke/lazydev.nvim/compare/v1.7.0...v1.7.1) (2024-07-22)


### Performance Improvements

* lazy-load integrations ([f5d344d](https://github.com/folke/lazydev.nvim/commit/f5d344dcc9121991238b8acff7e77531b5f7fa06))

## [1.7.0](https://github.com/folke/lazydev.nvim/compare/v1.6.0...v1.7.0) (2024-07-14)


### Features

* added `files` option [#39](https://github.com/folke/lazydev.nvim/issues/39) ([#41](https://github.com/folke/lazydev.nvim/issues/41)) ([380e80d](https://github.com/folke/lazydev.nvim/commit/380e80d1491e3195f25e3d180170d8dd438db25a))
* added support for luarocks installed with lazy ([e3d0d55](https://github.com/folke/lazydev.nvim/commit/e3d0d55b4bff301be97f6a9820b21c59381440c1))


### Bug Fixes

* **util:** notify ([a74b397](https://github.com/folke/lazydev.nvim/commit/a74b397e8d6d291313d4f4f969edb6e57ddf7ab7))

## [1.7.0](https://github.com/folke/lazydev.nvim/compare/v1.6.0...v1.7.0) (2024-07-04)


### Features

* added `files` option [#39](https://github.com/folke/lazydev.nvim/issues/39) ([#41](https://github.com/folke/lazydev.nvim/issues/41)) ([380e80d](https://github.com/folke/lazydev.nvim/commit/380e80d1491e3195f25e3d180170d8dd438db25a))
* added support for luarocks installed with lazy ([e3d0d55](https://github.com/folke/lazydev.nvim/commit/e3d0d55b4bff301be97f6a9820b21c59381440c1))

## [1.6.0](https://github.com/folke/lazydev.nvim/compare/v1.5.1...v1.6.0) (2024-06-15)


### Features

* **debug:** add warning when a .luarc.json was found ([309d05d](https://github.com/folke/lazydev.nvim/commit/309d05d2734a77361dde6ad7d348812a2fc2fa95))

## [1.5.1](https://github.com/folke/lazydev.nvim/compare/v1.5.0...v1.5.1) (2024-06-09)


### Bug Fixes

* **lsp:** make sure `client.handlers` is unique for each client. Fixes [#29](https://github.com/folke/lazydev.nvim/issues/29) ([2f239a5](https://github.com/folke/lazydev.nvim/commit/2f239a5216b184ce9a9fb6c73cae18bbf3c578ef))

## [1.5.0](https://github.com/folke/lazydev.nvim/compare/v1.4.0...v1.5.0) (2024-06-05)


### Features

* added lspconfig integration to fix its workspace management ([3e301ee](https://github.com/folke/lazydev.nvim/commit/3e301ee157c79d1378980b5e7e4eebd3474229a4))
* **buf:** resolve modules in order: workspace root, loaded plugins, unloaded plugins. See [#13](https://github.com/folke/lazydev.nvim/issues/13) ([47777cb](https://github.com/folke/lazydev.nvim/commit/47777cbaa4d19348c76b0d8bd750ae769de6c892))
* optionally add a completion source for coq_nvim ([#20](https://github.com/folke/lazydev.nvim/issues/20)) ([3af5a7d](https://github.com/folke/lazydev.nvim/commit/3af5a7d749687952793cc9df93aec31547146f0c))
* **workspace:** find a workspace for a buffer / path ([4c29893](https://github.com/folke/lazydev.nvim/commit/4c29893cf2faec7caa276d7ba510e02bc8f0dd82))


### Bug Fixes

* **pkg:** added support for detecting modules with `pcall(require, "...")` ([be8332e](https://github.com/folke/lazydev.nvim/commit/be8332eb2a40b2e450d185a4844603029ca229fb))


### Performance Improvements

* ignore `/lua` dirs since they will be in the library instead ([1f54b6e](https://github.com/folke/lazydev.nvim/commit/1f54b6ead06bd04b32ad8885ad40a7aca47461c8))

## [1.4.0](https://github.com/folke/lazydev.nvim/compare/v1.3.0...v1.4.0) (2024-06-04)


### Features

* added a `LazyDev` debugging command that shows libraries and settings for the current buffer ([3f6320d](https://github.com/folke/lazydev.nvim/commit/3f6320d43198bb847cbad6fd2a577dda18554f29))
* added support for loading libraries based on words/mods ([7fabc0d](https://github.com/folke/lazydev.nvim/commit/7fabc0d5a44b3002b88c7c32b2b67bd3742c23ae))


### Bug Fixes

* **pkg:** luvit-meta/library not found using native package system ([#19](https://github.com/folke/lazydev.nvim/issues/19)) ([96062a7](https://github.com/folke/lazydev.nvim/commit/96062a7b94d5e6c3b4ec746b5d8d2a69e6389761))
* **workspace:** make sure we always add the /lua root of the current project ([50927b4](https://github.com/folke/lazydev.nvim/commit/50927b4e70dce1ff68103ef1f2c197f1b75f4ac4))


### Performance Improvements

* only update single when needed ([fe37da2](https://github.com/folke/lazydev.nvim/commit/fe37da2cc14d4faffbe96be09b3fd08aa58ae972))

## [1.3.0](https://github.com/folke/lazydev.nvim/compare/v1.2.1...v1.3.0) (2024-06-03)


### Features

* **config:** make it easier to specify plugin paths in library ([890c7d5](https://github.com/folke/lazydev.nvim/commit/890c7d5b982b829e2881f21d739e689772c7971e))
* prettier debug ([fe68a25](https://github.com/folke/lazydev.nvim/commit/fe68a25bb37c8e683e233f09a5dd6c80c3ea9c64))
* prettier debug ([766931a](https://github.com/folke/lazydev.nvim/commit/766931a928787e12dd42efef605b4aecdccffc11))


### Bug Fixes

* added single file support. Fixes [#10](https://github.com/folke/lazydev.nvim/issues/10) ([0592c8f](https://github.com/folke/lazydev.nvim/commit/0592c8f80a7c9bb99b7ea4d8a047d2d3bddeebd1))
* fixup for debug. See [#10](https://github.com/folke/lazydev.nvim/issues/10) ([f3b3795](https://github.com/folke/lazydev.nvim/commit/f3b3795c6daf11da989220d859c0468b82d766ae))
* **lsp:** dont error when workspace not loaded yet. Fixes [#10](https://github.com/folke/lazydev.nvim/issues/10) ([41e5bb1](https://github.com/folke/lazydev.nvim/commit/41e5bb150020d0841fffdd52e6a4942f51004986))
* **lsp:** try to avoid incorrect temporary diagnostics ([22473af](https://github.com/folke/lazydev.nvim/commit/22473afec50117716db4a25e0b064437b8c6a1bd))
* pass root_dir to enabled instead of lsp client ([37ba8ac](https://github.com/folke/lazydev.nvim/commit/37ba8ac79ab48762486deb9891547fde88a86763))
* remove lazy.nvim dep ([4bd9af4](https://github.com/folke/lazydev.nvim/commit/4bd9af4b388c5f937c3f2308a1ead2ea2f68b09d))
* revert set_handlers for now ([f2fe955](https://github.com/folke/lazydev.nvim/commit/f2fe95553b21fb7596c7cb060063886f17eb38c8))
* windows fixes [#12](https://github.com/folke/lazydev.nvim/issues/12) ([f98d85a](https://github.com/folke/lazydev.nvim/commit/f98d85a16771282caceeefa0d9a65336f8b44437))
* **workspace:** don't add workspace folder as library. See [#13](https://github.com/folke/lazydev.nvim/issues/13) ([ae12a62](https://github.com/folke/lazydev.nvim/commit/ae12a6224c466315f6ecbe6ed1ee7c5641f21d40))
* **workspace:** resolve real paths. Fixes [#13](https://github.com/folke/lazydev.nvim/issues/13) ([b32bc5a](https://github.com/folke/lazydev.nvim/commit/b32bc5a0c6d50d0c2c3f5101a3f967d2222a539e))


### Performance Improvements

* debounce LuaLS updates ([7d843b9](https://github.com/folke/lazydev.nvim/commit/7d843b9f3aa9240e38854e7bc4df389929dbe44a))
* dont return workspace library for the fallback scope ([2e715cd](https://github.com/folke/lazydev.nvim/commit/2e715cd4629df2b47d92468935226655cb7e88ed))
* **lsp:** explicitely disable the fallback scope when no scopeUri and in a workspace ([b9ecd40](https://github.com/folke/lazydev.nvim/commit/b9ecd4034358a39859216d64b8548fa2b577af95))
* properly track library usage per workspace folder ([48267c8](https://github.com/folke/lazydev.nvim/commit/48267c807750610f3f8f7cb1469308f68243f081))

## [1.2.1](https://github.com/folke/lazydev.nvim/compare/v1.2.0...v1.2.1) (2024-06-02)


### Bug Fixes

* added support for module names with forward slashes instead of dots ([3c9423a](https://github.com/folke/lazydev.nvim/commit/3c9423a021a8e2890b2029ad20d830c713720afc))

## [1.2.0](https://github.com/folke/lazydev.nvim/compare/v1.1.0...v1.2.0) (2024-06-02)


### Features

* added fast cmp completion source for require statements and module annotations ([a5c908d](https://github.com/folke/lazydev.nvim/commit/a5c908dc8eec1823c5a6dfbb07fbe8c74fce3a14))
* **buf:** added support for `---[@module](https://github.com/module) "foobar"`. Fixes [#4](https://github.com/folke/lazydev.nvim/issues/4) ([6d0aaae](https://github.com/folke/lazydev.nvim/commit/6d0aaaea20d270c2c49fb0ff8b2835717e635f0d))
* **config:** allow library to be a list of strings, or a table for easier merging ([6227a55](https://github.com/folke/lazydev.nvim/commit/6227a55bd1a4b7dcdc911377032ec5bb4eedba6b))


### Bug Fixes

* **buf:** implement on_reload ([1af5a6e](https://github.com/folke/lazydev.nvim/commit/1af5a6e801e16cf02a1ba0dc4808e522f2d06ae2))


### Performance Improvements

* **buf:** not needed to use treesitter to parse requires ([62c8bbf](https://github.com/folke/lazydev.nvim/commit/62c8bbff840432eb9e7fd3d994751cbb95c89e25))

## [1.1.0](https://github.com/folke/lazydev.nvim/compare/v1.0.0...v1.1.0) (2024-06-01)


### Features

* added support for Neovim's package system ([37a48c0](https://github.com/folke/lazydev.nvim/commit/37a48c05311269d5cb08f0f2131e1ad583c6a485))


### Bug Fixes

* always call on_change when ataching new buffer ([f0de1e7](https://github.com/folke/lazydev.nvim/commit/f0de1e75f8e3a98e37ddf8d9b923ded039ff504e))
* **pkg:** normalize paths for packpaths ([ee3d47f](https://github.com/folke/lazydev.nvim/commit/ee3d47f3a53891483c8a3e02f8c3e49a12064434))


### Performance Improvements

* batch require changes from file in one go ([45ef0d0](https://github.com/folke/lazydev.nvim/commit/45ef0d06cabac70c8615ae679d9efc72305f2142))
* **pkg:** cache unloaded packs for packpath impl ([95aabb2](https://github.com/folke/lazydev.nvim/commit/95aabb27a0a8fec9826c6ca45ff8ba3d886a8888))

## 1.0.0 (2024-06-01)


### Features

* Config.enabled ([b2da629](https://github.com/folke/lazydev.nvim/commit/b2da6296892323254b5841d45e643dcdaa6fbeb3))
* config.enabled can be a function/boolean ([8434266](https://github.com/folke/lazydev.nvim/commit/8434266c8dd5c690134f5e66d340633e9f63e7bf))
* initial commit ([77c5029](https://github.com/folke/lazydev.nvim/commit/77c5029d68941dfdbb3eaee4910bdc97d5c9a93b))


### Bug Fixes

* automatically add `/lua` when needed ([feef58f](https://github.com/folke/lazydev.nvim/commit/feef58f427d54ffebeec8f09b4d8c31dbea9b1c3))


### Performance Improvements

* update LSP with vim.schedule ([c211df9](https://github.com/folke/lazydev.nvim/commit/c211df939c5af6d8c0de0d6abfff300805fe66a7))
