-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

-- Centering movements
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Do note copy replaced text on paste in highlight mode
vim.keymap.set("x", "<leader>p", '"_dP')

-- Delete to void register to avoid copy
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- Force out of insert mode via ctrl+c
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "<leader>fT", function()
  Util.terminal.open(nil, { cwd = Util.root.get() })
end, { desc = "Terminal (root dir)" })
vim.keymap.set("n", "<leader>ft", function()
  Util.terminal.open()
end, { desc = "Terminal (cwd)" })
