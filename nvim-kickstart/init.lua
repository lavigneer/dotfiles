--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = ""

vim.opt.showmode = false

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.conceallevel = 2

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("i", "<S-Up>", "<Nop>", { silent = true })
vim.keymap.set("i", "<S-Down>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Centering movements
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Do not copy replaced text on paste in highlight mode
vim.keymap.set("x", "<leader>p", '"_dP')

-- Delete to void register to avoid copy
vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
require("lazy").setup({
  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- Nicer input ui
  {
    "stevearc/dressing.nvim",
    opts = {
      select = { enabled = false },
    },
  },

  -- LSP Configuration & Plugins
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", "<cmd>Pick lsp scope='definition'<CR>", "[G]oto [D]efinition")
          map("gr", "<cmd>Pick lsp scope='references'<CR>", "[G]oto [R]eferences")
          map("gI", "<cmd>Pick lsp scope='implementation'<CR>", "[G]oto [I]mplementation")
          map("<leader>D", "<cmd>Pick lsp scope='definition'<CR>", "Type [D]efinition")
          map("<leader>ds", "<cmd>Pick lsp scope='document_symbol'<CR>", "[D]ocument [S]ymbols")
          map("<leader>ws", "<cmd>Pick lsp scope='workspace_symbol'<CR>", "[W]orkspace [S]ymbols")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          vim.api.nvim_buf_create_user_command(0, "Format", function(_)
            vim.lsp.buf.format({})
          end, { desc = "Format current buffer" })

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {
        rust_analyzer = {},
        biome = {},
        tsserver = {
          init_options = {
            preferences = {
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
            },
          },
        },
        html = { filetypes = { "html", "twig", "hbs", "htmldjango" } },
        htmx = { filetypes = { "html", "twig", "hbs", "htmldjango" } },
        gopls = {
          filetypes = { "go", "gomod", "gowork", "gotmpl", "html" },
          init_options = {
            templateExtensions = { "html" },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              run_govulncheck = true,
              test = true,
              tidy = true,
              upgrade_dependency = true,
              vendor = true,
            },
            hints = {
              assignVariableTypes = true,
              compositeLiteralFields = true,
              compositeLiteralTypes = true,
              constantValues = true,
              functionTypeParameters = true,
              parameterNames = true,
              rangeVariableTypes = true,
            },
            analyses = {
              fieldalignment = true,
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            usePlaceholders = true,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
        golangci_lint_ls = {},
        tailwindcss = {
          filetypes = {
            "aspnetcorerazor",
            "astro",
            "astro-markdown",
            "blade",
            "clojure",
            "django-html",
            "htmldjango",
            "edge",
            "eelixir",
            "elixir",
            "ejs",
            "erb",
            "eruby",
            "gohtml",
            "gohtmltmpl",
            "haml",
            "handlebars",
            "hbs",
            "html",
            "html-eex",
            "heex",
            "jade",
            "leaf",
            "liquid",
            "markdown",
            "mdx",
            "mustache",
            "njk",
            "nunjucks",
            "php",
            "razor",
            "slim",
            "twig",
            "css",
            "less",
            "postcss",
            "sass",
            "scss",
            "stylus",
            "sugarss",
            "javascript",
            "javascriptreact",
            "reason",
            "rescript",
            "typescript",
            "typescriptreact",
            "vue",
            "svelte",
            "rust",
          },
        },

        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = "LuaJIT" },
              workspace = {
                checkThirdParty = false,
                library = {
                  "${3rd}/luv/library",
                  unpack(vim.api.nvim_get_runtime_file("", true)),
                },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      require("mason").setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua",
      })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            if server_name == "gopls" then
              server.on_attach = function(client, _)
                if client.name == "gopls" then
                  if not client.server_capabilities.semanticTokensProvider then
                    local semantic = client.config.capabilities.textDocument.semanticTokens
                    client.server_capabilities.semanticTokensProvider = {
                      full = true,
                      legend = {
                        tokenTypes = semantic.tokenTypes,
                        tokenModifiers = semantic.tokenModifiers,
                      },
                      range = true,
                    }
                  end
                end
              end
            end
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },

  -- Autoformat
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["javascript"] = { "prettier", "biome" },
        ["javascriptreact"] = { "prettier", "biome" },
        ["typescript"] = { "prettier", "biome" },
        ["typescriptreact"] = { "prettier", "biome" },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "rustywind", "prettier" },
        ["htmldjango"] = { "rustywind", "prettier" },
        ["json"] = { "prettier", "biome" },
        ["jsonc"] = { "biome" },
        ["yaml"] = { "prettier" },
        ["markdown"] = { "prettier" },
        ["markdown.mdx"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
        ["lua"] = { "stylua" },
      },
    },
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        desc = "[C]ode [F]ormat",
      },
    },
    config = function(_, opts)
      require("conform").setup(opts)
    end,
  },

  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("carbonfox")
      vim.cmd.hi("Comment gui=none")
    end,
  },

  -- Highlight todo, notes, etc in comments
  { "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = { signs = false } },

  -- Find and replace
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>rs",
        function()
          require("spectre").open()
        end,
        desc = "Find/Replace in Spectre",
      },
    },
  },

  -- Trouble
  {
    "folke/trouble.nvim",
    branch = "main", -- IMPORTANT!
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
    },
    opts = {}, -- for default options, refer to the configuration section for custom setup.
  },

  -- Faster file navigation
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      lazy = false,
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      ---@diagnostic disable-next-line: missing-parameter
      harpoon:setup()
      vim.keymap.set("n", "<leader>a", function()
        harpoon:list():add()
      end)
      vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set("n", "<A-1>", function()
        harpoon:list():select(1)
      end)
      vim.keymap.set("n", "<A-2>", function()
        harpoon:list():select(2)
      end)
      vim.keymap.set("n", "<A-3>", function()
        harpoon:list():select(3)
      end)
      vim.keymap.set("n", "<A-4>", function()
        harpoon:list():select(4)
      end)
      vim.keymap.set("n", "<A-5>", function()
        harpoon:list():select(5)
      end)
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets
          -- This step is not supported in many windows environments
          -- Remove the below condition to re-enable on windows
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        completion = { completeopt = "menu,menuone,noinsert" },

        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete({}),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- Mini ftw
  {
    "echasnovski/mini.nvim",
    lazy = false,
    dependencies = {},
    config = function()
      require("mini.basics").setup({
        options = {
          extra_ui = true,
        },
        mappings = {
          basic = false,
          windows = true,
        },
      })
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.surround").setup()
      require("mini.bracketed").setup()
      require("mini.comment").setup()
      require("mini.cursorword").setup()
      require("mini.diff").setup({ view = { style = "sign" }, mappings = { apply = "", reset = "", textobject = "" } })
      require("mini.extra").setup()
      require("mini.tabline").setup()
      require("mini.notify").setup()
      require("mini.visits").setup()
      require("mini.icons").setup()

      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
        },
        window = {
          delay = 450,
          config = { anchor = "SW", row = "auto", col = "auto", width = "auto" },
        },
      })

      local bufremove = require("mini.bufremove")
      bufremove.setup()
      vim.keymap.set("n", "<leader>bd", function()
        bufremove.delete()
      end, { desc = "[B]uffer [D]elete" })
      vim.keymap.set("n", "<leader>bD", function()
        bufremove.delete(0, true)
      end, { desc = "Force [B]uffer [D]elete" })

      local statusline = require("mini.statusline")
      statusline.setup()

      local files = require("mini.files")
      files.setup({
        options = {
          use_as_default_explorer = true,
        },
        windows = {
          width_nofocus = 15,
          width_focus = 50,
          width_preview = 80,
          preview = true,
        },
      })
      vim.keymap.set("n", "<leader>e", function()
        files.open(vim.api.nvim_buf_get_name(0), true)
      end, { desc = "Open mini.files (directory of current file)" })

      local pick = require("mini.pick")
      pick.setup({
        mappings = {
          choose_marked = "<C-q>",
          choose_in_vsplit = "",
        },
      })
      local codeaction_format_item = function(action_tuple)
        local title = action_tuple[2].title:gsub("\r\n", "\\r\\n")
        local client = vim.lsp.get_client_by_id(action_tuple[1])
        return string.format("%s\t[%s]", title:gsub("\n", "\\n"), client.name)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(items, opts, on_choice)
        if opts.kind == "codeaction" then
          opts.format_item = codeaction_format_item
        end
        return pick.ui_select(items, opts, on_choice)
      end
      vim.keymap.set("n", "<leader>?", "<cmd>Pick oldfiles<CR>", { desc = "[?] Find recently opened files" })
      vim.keymap.set("n", "<leader><space>", "<cmd>Pick buffers<CR>", { desc = "[ ] Find existing buffers" })
      vim.keymap.set(
        "n",
        "<leader>/",
        "<cmd>Pick buf_lines scope='current'<CR>",
        { desc = "[/] Fuzzily search in current buffer" }
      )
      vim.keymap.set("n", "<leader>gf", "<cmd>Pick git_files<CR>", { desc = "Search [G]it [F]iles" })
      vim.keymap.set(
        "n",
        "<leader>gm",
        "<cmd>Pick git_files scope='modified'<CR>",
        { desc = "Search [G]it [M]odified" }
      )
      vim.keymap.set("n", "<leader>sf", "<cmd>Pick files<CR>", { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>sh", "<cmd>Pick help<CR>", { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sw", "<cmd>grep pattern='<cword><CR>", { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", "<cmd>Pick grep_live<CR>", { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", "<cmd>Pick diagnostic scope='all'<CR>", { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sq", "<cmd>Pick list scope='quickfix'<CR>", { desc = "[S]earch [Q]uickfix" })
      vim.keymap.set("n", "<leader>sr", "<cmd>Pick resume<CR>", { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>se", "<cmd>Pick explorer<CR>", { desc = "[S]earch [E]xplorer" })
      vim.keymap.set("n", "<leader>sv", "<cmd>Pick visit_paths<CR>", { desc = "[S]earch [V]isit Paths" })
    end,
  },

  -- Highlight, edit, and navigate code
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "bash", "c", "html", "lua", "markdown", "markdown_inline", "vim", "vimdoc" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]m"] = "@function.outer",
              ["]]"] = "@class.outer",
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@class.outer",
            },
            goto_previous_start = {
              ["[m"] = "@function.outer",
              ["[["] = "@class.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
})

-- vim: ts=2 sts=2 sw=2 et
