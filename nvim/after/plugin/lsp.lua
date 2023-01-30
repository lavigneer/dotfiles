local lsp = require('lsp-zero')

lsp.preset('recommended')
lsp.ensure_installed({
    'tsserver',
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
    mapping = cmp_mappings,
    completion = {
        completeopt = 'menu,menuone,noinsert,noselect'
    },
    preselect = cmp.PreselectMode.None
})

lsp.set_preferences({
    sign_icons = {}
})

lsp.on_attach(function(client, bufnr)
    vim.keymap.set("n", "gR", vim.lsp.buf.workspace_symbol,
        { buffer = bufnr, remap = false, desc = "vim.lsp.buf.workspace_symbol()" })
    vim.keymap.set("n", "<leader>la", function() vim.lsp.buf.code_action() end,
        { buffer = bufnr, remap = false, desc = "LSP code action" })
    vim.keymap.set("n", "<leader>lr", function() vim.lsp.buf.rename() end,
        { buffer = bufnr, remap = false, desc = "LSP rename" })
end)


lsp.setup()


local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
    on_attach = function(client, bufnr)
        null_opts.on_attach(client, bufnr)
        if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
                desc = "Auto format before save",
                pattern = "<buffer>",
                callback = function() vim.lsp.buf.format({
                        filter = function(fclient) return fclient.name ~= "tsserver" end
                    })
                end,
            })
        end
        --- you can add other stuff here....
    end,
    sources = {
        null_ls.builtins.formatting.prettierd,
        null_ls.builtins.diagnostics.eslint_d,
        require("typescript.extensions.null-ls.code-actions"),
    }
})
