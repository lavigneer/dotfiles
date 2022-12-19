vim.keymap.set("n", "<leader>fb", vim.cmd.Ex, { desc = "File browser" })

-- Moving Lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("i", "<A-j>", "<Esc>:m .+1<CR>==gi")
vim.keymap.set("i", "<A-k>", "<Esc>:m .-2<CR>==gi")
vim.keymap.set("v", "<A-j>", ":move '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":move '<-2<CR>gv=gv")

-- Centering movements
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Do note copy replaced text on paste in highlight mode
vim.keymap.set("x", "<leader>p", "\"_dP")

-- Copy to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y")
vim.keymap.set("v", "<leader>y", "\"+y")
vim.keymap.set("n", "<leader>Y", "\"+Y")

-- Delete to void register to avoid copy
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("v", "<leader>d", "\"_d")

-- Force out of insert mode via ctrl+c
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Make accidental Q presses do nothing
vim.keymap.set("n", "Q", "<nop>")

-- LSP Formatting
vim.keymap.set("n", "<leader>lf", function()
    vim.lsp.buf.format({
        filter = function(client) return client.name ~= "tsserver" end
    })
end, {desc = "LSP format" })

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Quick replace word that you are on
vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")


-- Buffer
vim.keymap.set("n", "<leader>c", "<cmd>Bdelete<cr>", { desc = "Close buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>bnext<cr>", {desc = "Next buffer" })
vim.keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", {desc = "Previous buffer" })


-- Windows
vim.keymap.set("n", "<C-h>", "<C-w>h", {desc = "Move to left split" })
vim.keymap.set("n", "<C-j>", "<C-w>j", {desc = "Move to below split" })
vim.keymap.set("n", "<C-k>", "<C-w>k", {desc = "Move to above split" })
vim.keymap.set("n", "<C-l>", "<C-w>l", {desc = "Move to right split" })
vim.keymap.set("n", "<C-Up>", "<cmd>resize -2<CR>", {desc = "Resize split up" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize +2<CR>", {desc = "Resize split down" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<CR>", {desc = "Resize split left" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<CR>", {desc = "Resize split right" })

-- Stay in indent mode
vim.keymap.set("v", "<", "<gv", {desc = "unindent line" })
vim.keymap.set("v", ">", ">gv", {desc = "indent line" })
