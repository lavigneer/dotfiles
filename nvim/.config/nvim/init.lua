---@diagnostic disable: missing-fields
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

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = "screen"

-- vim.opt.completeopt = "menu,noinsert,popup,fuzzy,menuone,noselect"

-- [[ Basic Keymaps ]]
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("i", "<S-Up>", "<Nop>", { silent = true })
vim.keymap.set("i", "<S-Down>", "<Nop>", { silent = true })

-- [[ Completion Keymaps ]]
-- vim.keymap.set("i", "<C-Space>", function()
--   vim.lsp.completion.get()
-- end)
vim.keymap.set("i", "<C-]>", "<")
vim.keymap.set("i", "<C-]>", "<C-X><C-]>")
vim.keymap.set("i", "<C-F>", "<C-X><C-F>")
vim.keymap.set("i", "<C-D>", "<C-X><C-D>")
vim.keymap.set("i", "<C-L>", "<C-X><C-L>")
-- vim.keymap.set("i", "<CR>", function()
--   -- autocomplete enter should do the full accept like CTRL-Y
--   return vim.fn.pumvisible() == 1 and "<C-y>" or "<CR>"
-- end, { expr = true })

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

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Add MDX as a filetype
vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
  },
})

vim.filetype.add({
  pattern = {
    [".*Tiltfile"] = "starlark",
  },
})

-- Set tf files as terraform
vim.filetype.add({
  extension = {
    tf = "terraform",
  },
})

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  desc = "Hide quickfix buffers from buffer list",
  group = vim.api.nvim_create_augroup("qf", { clear = false }),
  pattern = "qf",
  command = "set nobuflisted",
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

  -- Helm support
  { "towolf/vim-helm", ft = "helm" },

  -- Nicer input ui
  {
    "stevearc/dressing.nvim",
    opts = {
      select = { enabled = false },
    },
  },

  -- Move inlay hints to end of line
  {
    "chrisgrieser/nvim-lsp-endhints",
    event = "LspAttach",
    opts = {},
  },

  { "williamboman/mason.nvim", branch = "v1.x" },
  { "williamboman/mason-lspconfig.nvim", branch = "v1.x" },

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

          map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("grt", vim.lsp.buf.type_definition, "Type [D]efinition")
          map("grX", vim.diagnostic.setqflist, "Workspace Diagnostics")
          map("grx", vim.diagnostic.setloclist, "Buffer Diagnostics")
          map("<leader>ds", vim.lsp.buf.document_symbol, "[D]ocument [S]ymbols")
          map("<leader>ws", "<cmd>Pick lsp scope='workspace_symbol'<CR>", "[W]orkspace [S]ymbols")
          map("<leader>lh", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
          end, "[L]sp [H]int Toggle")
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
      -- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      local servers = {
        rust_analyzer = {
          init_options = {
            cargo = {
              allFeatures = true,
            },
            check = {
              command = "clippy",
            },
            checkOnSave = true,
          },
        },
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
        html = { filetypes = { "html", "twig", "hbs", "htmldjango", "templ" } },
        htmx = { filetypes = { "html", "twig", "hbs", "htmldjango", "templ" } },
        gopls = {
          filetypes = { "go", "gomod", "gowork", "gotmpl", "html" },
          init_options = {
            templateExtensions = { "html" },
            codelenses = {
              gc_details = false,
              generate = true,
              regenerate_cgo = true,
              vulncheck = true,
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
              nilness = true,
              unusedparams = true,
              unusedwrite = true,
              useany = true,
            },
            -- annotations = { bounds = false, escape = false, inline = false },
            gofumpt = true,
            usePlaceholders = false,
            completeUnimported = true,
            staticcheck = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
            semanticTokens = true,
          },
        },
        gdscript = {},
        golangci_lint_ls = {},
        basedpyright = {
          settings = {
            basedpyright = {
              analysis = {
                typeCheckingMode = "off",
                autoSearchPaths = true,
                diagnosticMode = "openFilesOnly",
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        nil_ls = {},
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
            "templ",
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

        ocamllsp = {
          filetypes = {
            "ocaml",
            "ocaml.menhir",
            "ocaml.interface",
            "ocaml.ocamllex",
            "reason",
            "dune",
          },
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "*.opam",
              "esy.json",
              "package.json",
              ".git",
              "dune-project",
              "dune-workspace",
              "*.ml"
            )(fname)
          end,
        },

        helm_ls = {
          init_options = {
            valuesFiles = {
              additionalValuesFilesGlobPattern = "*.values.yaml",
            },
            yamlls = {
              path = "yaml-language-server",
            },
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
            server.on_attach = function(client, buffer)
              -- Disable yamlls for helm
              if server_name == "yamlls" then
                if vim.bo[buffer].filetype == "helm" then
                  vim.schedule(function()
                    vim.cmd("LspStop ++force yamlls")
                  end)
                end
              end

              if client.server_capabilities.completionProvider ~= nil then
                client.server_capabilities.completionProvider.triggerCharacters =
                  vim.split("qwertyuiopasdfghjklzxcvbnm. ", "")
              end
              -- if client:supports_method("textDocumentation/completion") then
              --   vim.lsp.completion.enable(true, client.id, buffer, {
              --     autotrigger = true,
              --   })
              -- end
              if client.supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
              end
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
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })

      vim.lsp.enable("evergreenlsp")
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
        ["astro"] = { "prettier" },
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
        ["cucumber"] = { "prettier" },
        ["graphql"] = { "prettier" },
        ["handlebars"] = { "prettier" },
        ["lua"] = { "stylua" },
        ["gdscript"] = { "gdformat" },
        ["groovy"] = { "npm-groovy-lint" },
        ["templ"] = { "templ" },
        ["go"] = { "gopls" },
        ["nix"] = { "nixfmt" },
        ["ocaml"] = { "ocamlformat" },
        ["starlark"] = { "buildifier" },
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
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("kanagawa")
    end,
  },
  {
    "dgox16/oldworld.nvim",
    lazy = false,
    priority = 1000,
    config = function() end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.hi("Comment gui=none")
    end,
  },

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
      require("mini.git").setup()
      require("mini.cursorword").setup()
      require("mini.diff").setup({ view = { style = "sign" }, mappings = { apply = "", reset = "", textobject = "" } })
      require("mini.extra").setup()
      require("mini.move").setup()
      require("mini.tabline").setup()
      require("mini.notify").setup()
      require("mini.statusline").setup()
      require("mini.visits").setup()

      local icons = require("mini.icons")
      icons.setup()
      icons.tweak_lsp_kind()

      local indentscope = require("mini.indentscope")
      indentscope.setup({
        draw = {
          animation = indentscope.gen_animation.none(),
        },
        options = {
          indent_at_cursor = false,
        },
      })

      -- Turn off indentscope for special file types
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "Trouble",
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      local hipatterns = require("mini.hipatterns")
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
          hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
          todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
          note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

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

          -- `[]` keys
          { mode = "n", keys = "[" },
          { mode = "x", keys = "[" },
          { mode = "n", keys = "]" },
          { mode = "x", keys = "]" },
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
      local codeaction_format_item = function(item)
        local client_id, title
        if vim.version and vim.version.cmp(vim.version(), vim.version.parse("0.10-dev")) >= 0 then
          client_id = item.ctx.client_id
          title = item.action.title
        else
          client_id = item[1]
          title = item[2].title
        end

        local client = vim.lsp.get_client_by_id(client_id)
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
      vim.keymap.set("n", "<leader>gc", "<cmd>Pick git_hunks<CR>", { desc = "Search [G]it [H]unks" })
      vim.keymap.set("n", "<leader>gc", "<cmd>Pick git_commits<CR>", { desc = "Search [G]it [C]ommits" })
      vim.keymap.set(
        "n",
        "<leader>gm",
        "<cmd>Pick git_files scope='modified'<CR>",
        { desc = "Search [G]it [M]odified" }
      )
      vim.keymap.set("n", "<leader>sf", "<cmd>Pick files<CR>", { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>sh", "<cmd>Pick help<CR>", { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sw", "<cmd>Pick grep pattern='<cword>'<CR>", { desc = "[S]earch current [W]ord" })
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
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
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
  { "nvim-treesitter/nvim-treesitter-context", opts = { separator = "-" } },

  -- Testing
  {
    "nvim-neotest/neotest",
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "nvim-neotest/neotest-jest" },
      { "fredrikaverpil/neotest-golang" },
    },
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = { "neotest-jest", "neotest-golang" },
      status = { virtual_text = true },
      output = { open_on_run = false },
      quickfix = {
        open = function()
          vim.cmd("copen")
        end,
      },
    },
    config = function(_, opts)
      local neotest_ns = vim.api.nvim_create_namespace("neotest")
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            -- Replace newline and tab characters with space for more compact diagnostics
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)

      if opts.adapters then
        local adapters = {}
        for name, config in pairs(opts.adapters or {}) do
          if type(name) == "number" then
            if type(config) == "string" then
              config = require(config)
            end
            adapters[#adapters + 1] = config
          elseif config ~= false then
            local adapter = require(name)
            if type(config) == "table" and not vim.tbl_isempty(config) then
              local meta = getmetatable(adapter)
              if adapter.setup then
                adapter.setup(config)
              elseif meta and meta.__call then
                adapter(config)
              else
                error("Adapter " .. name .. " does not support setup")
              end
            end
            adapters[#adapters + 1] = adapter
          end
        end
        opts.adapters = adapters
      end

      require("neotest").setup(opts)
    end,
    -- stylua: ignore
    keys = {
      {
        "<leader>tt",
        function() require("neotest").run.run(vim.fn.expand("%")) end,
        desc =
        "Run File"
      },
      {
        "<leader>tT",
        function() require("neotest").run.run(vim.loop.cwd()) end,
        desc =
        "Run All Test Files"
      },
      {
        "<leader>tr",
        function() require("neotest").run.run() end,
        desc =
        "Run Nearest"
      },
      {
        "<leader>ts",
        function() require("neotest").summary.toggle() end,
        desc =
        "Toggle Summary"
      },
      {
        "<leader>to",
        ---@diagnostic disable-next-line: missing-fields
        function() require("neotest").output.open({ enter = true, auto_close = true }) end,
        desc =
        "Show Output"
      },
      {
        "<leader>tO",
        function() require("neotest").output_panel.toggle() end,
        desc =
        "Toggle Output Panel"
      },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
    },
  },

  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    version = "1.*",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = "enter" },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        -- keyword = { range = "full" },
        documentation = { auto_show = false },
        list = {
          selection = {
            -- preselect = false,
            auto_insert = false,
          },
        },
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
      },
      cmdline = {
        enabled = false,
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },

  {
    "Exafunction/windsurf.vim",
    event = "BufEnter",
  },
  -- { "github/copilot.vim" },
  -- {
  --   "ravitemer/mcphub.nvim",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --   },
  --   build = "npm install -g mcp-hub@latest",
  --   config = function()
  --     require("mcphub").setup()
  --   end,
  -- },
  -- {
  --   "olimorris/codecompanion.nvim",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-treesitter/nvim-treesitter",
  --     "ravitemer/mcphub.nvim",
  --   },
  --   config = function()
  --     require("codecompanion").setup({
  --       extensions = {
  --         mcphub = {
  --           callback = "mcphub.extensions.codecompanion",
  --           opts = {
  --             show_result_in_chat = true, -- Show mcp tool results in chat
  --             make_vars = true, -- Convert resources to #variables
  --             make_slash_commands = true, -- Add prompts as /slash commands
  --           },
  --         },
  --       },
  --     })
  --   end,
  --   keys = {
  --     {
  --       "<C-a>",
  --       "<cmd>CodeCompanionActions<CR>",
  --       mode = { "n", "v" },
  --       desc = "Open Code Companion Actions",
  --     },
  --     {
  --       "<LocalLeader>a",
  --       "<cmd>CodeCompanionChat Toggle<CR>",
  --       mode = { "n", "v" },
  --       desc = "Toggle Code Companion Chat",
  --     },
  --     {
  --       "ga",
  --       "<cmd>CodeCompanionChat Add<CR>",
  --       mode = { "v" },
  --       desc = "Add to Code Companion Chat",
  --     },
  --   },
  -- },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
    },
    keys = {
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Breakpoint Condition",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Run/Continue",
      },
      {
        "<leader>da",
        function()
          require("dap").continue({ before = get_args })
        end,
        desc = "Run with Args",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Go to Line (No Execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Down",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Up",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Step Over",
      },
      {
        "<leader>dP",
        function()
          require("dap").pause()
        end,
        desc = "Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Widgets",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("mason-nvim-dap").setup({
        automatic_installation = true,
        handlers = {},
        ensure_installed = {
          "delve",
        },
      })

      dapui.setup({
        icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
        controls = {
          icons = {
            pause = "⏸",
            play = "▶",
            step_into = "⏎",
            step_over = "⏭",
            step_out = "⏮",
            step_back = "b",
            run_last = "▶▶",
            terminate = "⏹",
            disconnect = "⏏",
          },
        },
      })

      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

      dap.listeners.after.event_initialized["dapui_config"] = dapui.open
      dap.listeners.before.event_terminated["dapui_config"] = dapui.close
      dap.listeners.before.event_exited["dapui_config"] = dapui.close

      require("dap-go").setup({
        delve = {
          detached = vim.fn.has("win32") == 0,
        },
      })
    end,
  },
})

-- vim: ts=2 sts=2 sw=2 et
