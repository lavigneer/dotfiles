-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.mouse = ""
vim.g.autoformat = false
vim.g.snacks_animate = false

vim.filetype.add({
  pattern = {
    [".*Tiltfile"] = "tiltfile",
  },
})

vim.treesitter.language.register("starlark", "tiltfile")
