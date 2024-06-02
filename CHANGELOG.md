# Changelog

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
