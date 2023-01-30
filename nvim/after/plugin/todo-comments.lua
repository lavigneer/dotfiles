require("todo-comments").setup({
    highlight = {
        keyword = "",
    },
})

vim.keymap.set('n', '<leader>ft', '<CMD>TodoTelescope<CR>', { desc = "Todos" })
