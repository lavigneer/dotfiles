return {
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "mason.nvim",
            "williamboman/mason-lspconfig.nvim",
        },
        opts = {
            inlay_hints = {
                enabled = false,
            },
            capabilities = {},
            autoformat = true,
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            servers = {
                jsonls = {},
                tsserver = {},
                eslint = {
                    settings = {
                        workingDirectory = { mode = "auto" },
                    },
                },
                rust_analyzer = {
                    keys = {
                        { "K",          "<cmd>RustHoverActions<cr>", desc = "Hover Actions (Rust)" },
                        { "<leader>cR", "<cmd>RustCodeAction<cr>",   desc = "Code Action (Rust)" },
                        { "<leader>dr", "<cmd>RustDebuggables<cr>",  desc = "Run Debuggables (Rust)" },
                    },
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                                runBuildScripts = true,
                            },
                            -- Add clippy lints for Rust.
                            checkOnSave = {
                                allFeatures = true,
                                command = "clippy",
                                extraArgs = { "--no-deps" },
                            },
                            procMacro = {
                                enable = true,
                                ignored = {
                                    ["async-trait"] = { "async_trait" },
                                    ["napi-derive"] = { "napi" },
                                    ["async-recursion"] = { "async_recursion" },
                                },
                            },
                        },
                    },
                },
            },
            setup = {
                rust_analyzer = function(_, opts)
                    local ok, mason_registry = pcall(require, "mason-registry")
                    local adapter ---@type any
                    if ok then
                        -- rust tools configuration for debugging support
                        local codelldb = mason_registry.get_package("codelldb")
                        local extension_path = codelldb:get_install_path() .. "/extension/"
                        local codelldb_path = extension_path .. "adapter/codelldb"
                        local liblldb_path = vim.fn.has("mac") == 1 and extension_path .. "lldb/lib/liblldb.dylib"
                            or extension_path .. "lldb/lib/liblldb.so"
                        adapter = require("rust-tools.dap").get_codelldb_adapter(codelldb_path, liblldb_path)
                    end
                    local rust_tools_opts = {
                        dap = {
                            adapter = adapter,
                        },
                        tools = {
                            on_initialized = function()
                                vim.cmd([[
                                    augroup RustLSP
                                    autocmd CursorHold                      *.rs silent! lua vim.lsp.buf.document_highlight()
                                    autocmd CursorMoved,InsertEnter         *.rs silent! lua vim.lsp.buf.clear_references()
                                    autocmd BufEnter,CursorHold,InsertLeave *.rs silent! lua vim.lsp.codelens.refresh()
                                    augroup END
                                ]])
                            end,
                        },
                    }
                    require("rust-tools").setup(vim.tbl_deep_extend("force", rust_tools_opts or {}, { server = opts }))
                    return true
                end,
            },
        },
        keys = {},
        ---@param opts PluginLspOpts
        config = function(_, opts)
            local lspconfig = require("lspconfig")

            -- Preconfiguration ===========================================================
            local on_attach_custom = function(client, bufnr)
                local function buf_set_option(name, value)
                    vim.api.nvim_buf_set_option(bufnr, name, value)
                end

                buf_set_option("omnifunc", "v:lua.MiniCompletion.completefunc_lsp")

                -- Currently all formatting is handled with 'null-ls' plugin
                if vim.fn.has("nvim-0.8") == 1 then
                    client.server_capabilities.documentFormattingProvider = false
                    client.server_capabilities.documentRangeFormattingProvider = false
                else
                    client.resolved_capabilities.document_formatting = false
                    client.resolved_capabilities.document_range_formatting = false
                end
            end

            local diagnostic_opts = {
                signs = {
                    priority = 9999,
                    severity = { min = "WARN", max = "ERROR" },
                },
                underline = true,
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                    prefix = "●",
                    severity = { min = "ERROR", max = "ERROR" },
                },
                severity_sort = true,
                update_in_insert = false,
            }

            vim.diagnostic.config(diagnostic_opts)

            local servers = opts.servers
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                {},
                opts.capabilities or {}
            )

            local function setup(server)
                local server_opts = vim.tbl_deep_extend("force", {
                    capabilities = vim.deepcopy(capabilities),
                    on_attach = on_attach_custom,
                }, servers[server] or {})

                if opts.setup[server] then
                    if opts.setup[server](server, server_opts) then
                        return
                    end
                elseif opts.setup["*"] then
                    if opts.setup["*"](server, server_opts) then
                        return
                    end
                end
                require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available thourgh mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
                all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
                if server_opts then
                    server_opts = server_opts == true and {} or server_opts
                    -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                    if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                        setup(server)
                    else
                        ensure_installed[#ensure_installed + 1] = server
                    end
                end
            end

            if have_mason then
                mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
            end
        end,
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = { "mason.nvim" },
        opts = function()
            local nls = require("null-ls")
            local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
            return {
                root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
                sources = {
                    nls.builtins.formatting.stylua,
                    nls.builtins.formatting.shfmt,
                    nls.builtins.formatting.prettierd,
                },
                on_attach = function(client, bufnr)
                    if client.supports_method("textDocument/formatting") then
                        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            group = augroup,
                            buffer = bufnr,
                            callback = function()
                                vim.lsp.buf.format({
                                    async = false,
                                    filter = function(fclient)
                                        return fclient.name ~= "tsserver"
                                    end,
                                })
                            end,
                        })
                    end
                end,
            }
        end,
    },
    {

        "williamboman/mason.nvim",
        cmd = "Mason",
        keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
        build = ":MasonUpdate",
        config = true,
    },

    {
        "simrat39/rust-tools.nvim",
        lazy = true,
        config = function() end,
    },
}
