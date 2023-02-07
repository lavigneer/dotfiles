local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
vim.keymap.set('n', '<leader>fG', builtin.grep_string, { desc = "Grep string under cursor" })
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Old files" })
vim.keymap.set('n', '<leader>ld', builtin.diagnostics, { desc = "Diagnostics" })
vim.keymap.set('n', '<leader>fs', builtin.git_status, { desc = "Git Status" })

require('telescope').setup({
    defaults = {
        sorting_strategy = "ascending",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                results_width = 0.8,
            },
            vertical = {
                mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
        }
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_cursor {}
        }
    }
})

require("telescope").load_extension("ui-select")
