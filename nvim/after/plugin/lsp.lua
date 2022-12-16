local lsp = require('lsp-zero')
local null_ls = require('null-ls')

local null_opts = lsp.build_options('null-ls', {
    on_attach = function(client)
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                desc = "Auto format before save",
                pattern = "<buffer>",
                callback = vim.lsp.buf.formatting_sync,
            })
        end
    end
})

lsp.preset('recommended')
lsp.ensure_installed({
    'tsserver',
    'eslint',
    'sumneko_lua',
    'rust_analyzer'
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
    ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-y>'] = cmp.mapping.confirm({ select = true }),
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.setup_nvim_cmp({
    mapping = cmp_mappings
})

lsp.set_preferences({
    sign_icons = {}
})

lsp.on_attach(function(client, bufnr)
    -- vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, {buffer = bufnr, remap = false, desc = "Go to definition" })
    -- vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, {buffer = bufnr, remap = false, desc = "Trigger LSP Hover" })
    vim.keymap.set("n", "gR", vim.lsp.buf.workspace_symbol,
        { buffer = bufnr, remap = false, desc = "vim.lsp.buf.workspace_symbol()" })
    -- vim.keymap.set("n", "<leader>ld", function() vim.diagnostic.open_float() end, {buffer = bufnr, remap = false, desc = "LSP diagnostic float open" })
    -- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, {buffer = bufnr, remap = false, desc = "Diagnostic next" })
    -- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, {buffer = bufnr, remap = false, desc = "Diagnostic previous" })
    vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end,
        { buffer = bufnr, remap = false, desc = "LSP code action" })
    vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end,
        { buffer = bufnr, remap = false, desc = "LSP rename" })
    -- vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, {buffer = bufnr, remap = false, desc = "LSP signature help" })
end)



null_ls.setup({
    on_attach = null_opts.on_attach,
    sources = {
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.diagnostics.eslint,
    }
})



lsp.setup()
