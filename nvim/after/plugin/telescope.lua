local builtin = require('telescope.builtin')
--vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
--vim.keymap.set('n', '<leader>ff', builtin.git_files, {})
--vim.keymap.set('n', '<leader>fw', function()
--	builtin.grep_string({ search = vim.fn.input("Grep > " )});
--end)

vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
-- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, { desc = "Old files" })
