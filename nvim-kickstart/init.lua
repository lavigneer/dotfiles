--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]
-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require("lazy").setup({
  -- NOTE: First, some plugins that don't require any configuration

  -- Detect tabstop and shiftwidth automatically
  "tpope/vim-sleuth",

  -- Expose an undo tree
  "mbbill/undotree",

  -- NOTE: This is where your plugins related to LSP can be installed.
  --  The configuration is done below. Search for lspconfig to find it below.
  {
    -- LSP Configuration & Plugins
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",

      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { "j-hui/fidget.nvim", opts = {} },

      -- Additional lua configuration, makes nvim stuff amazing!
      "folke/neodev.nvim",
    },
  },

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
        harpoon:list():append()
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

  {
    "echasnovski/mini.files",
    lazy = false,
    opts = {
      options = {
        use_as_default_explorer = true,
      },
      windows = {
        width_nofocus = 15,
        width_focus = 50,
        width_preview = 80,
        preview = true,
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (directory of current file)",
      },
    },
  },

  {
    "echasnovski/mini.bracketed",
    opts = {},
  },
  {
    "echasnovski/mini.comment",
    opts = {},
  },
  {
    "echasnovski/mini.bufremove",
    opts = {},
    keys = {
      { "<leader>bd", "<cmd>lua MiniBufremove.delete()<CR>", { desc = "[B]uffer [D]elete" } },
      { "<leader>bD", "<cmd>lua MiniBufremove.delete()<CR>", { desc = "Force [B]uffer [D]elete" } },
    },
  },
  {
    "echasnovski/mini.extra",
    opts = {},
  },
  {
    "echasnovski/mini.pick",
    opts = {
      mappings = {
        choose_marked = "<C-q>",
      },
      options = {
        content_from_bottom = true,
      },
    },
    keys = {
      { "<leader>?", "<cmd>Pick oldfiles<CR>", { desc = "[?] Find recently opened files" } },
      { "<leader><space>", "<cmd>Pick buffers<CR>", { desc = "[ ] Find existing buffers" } },
      { "<leader>/", "<cmd>Pick buf_lines scope='current'<CR>", { desc = "[/] Fuzzily search in current buffer" } },
      { "<leader>gf", "<cmd>Pick git_files<CR>", { desc = "Search [G]it [F]iles" } },
      { "<leader>gm", "<cmd>Pick git_files scope='modified'<CR>", { desc = "Search [G]it [M]odified" } },
      { "<leader>sf", "<cmd>Pick files<CR>", { desc = "[S]earch [F]iles" } },
      { "<leader>sh", "<cmd>Pick help<CR>", { desc = "[S]earch [H]elp" } },
      { "<leader>sw", "<cmd>grep pattern='<cword><CR>", { desc = "[S]earch current [W]ord" } },
      { "<leader>sg", "<cmd>Pick grep_live<CR>", { desc = "[S]earch by [G]rep" } },
      { "<leader>sd", "<cmd>Pick diagnostic scope='all'<CR>", { desc = "[S]earch [D]iagnostics" } },
      { "<leader>sq", "<cmd>Pick list scope='quickfix'<CR>", { desc = "[S]earch [Q]uickfix" } },
      { "<leader>sr", "<cmd>Pick resume<CR>", { desc = "[S]earch [R]esume" } },
    },
  },
  {
    "echasnovski/mini.statusline",
    opts = {},
  },
  {
    "echasnovski/mini.tabline",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      show_icons = true,
    },
  },
  {
    "echasnovski/mini.basics",
    lazy = false,
    opts = {
      options = {
        extra_ui = true,
      },
      mappings = {
        basic = false,
        windows = true,
      },
    },
    config = function(_, opts)
      require("mini.basics").setup(opts)
    end,
  },
  {
    -- Autocompletion
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",

      -- Adds LSP completion capabilities
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",

      -- Adds a number of user-friendly snippets
      "rafamadriz/friendly-snippets",
    },
  },

  -- Gen
  {
    "David-Kunz/gen.nvim",
    opts = {
      display_mode = "split",
      -- model = "codellama",
      show_model = true,
      no_auto_close = true,
    },
    keys = {
      { "<leader>lg", "<cmd>Gen<CR>", { desc = "[L]lm [G]en" } },
      { "<leader>lr", "ggVG:Gen Review_Code<CR>", { desc = "[L]lm [R]eview Code" } },
      { "<leader>le", "<cmd>Gen Enhance_Code<CR>", mode = "v", { desc = "[L]lm [E]nhance Code" } },
      { "<leader>lc", "<cmd>Gen Change_Code<CR>", mode = "v", { desc = "[L]lm [C]hange Code" } },
    },
  },

  -- Useful plugin to show you pending keybinds.
  { "folke/which-key.nvim", opts = {} },

  {
    "EdenEast/nightfox.nvim",
    priority = 1000,
    opts = {
      options = {
        -- transparent = true,
        colorblind = {
          enable = true,
          severity = {
            protan = 1.0,
          },
        },
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd.colorscheme("nightfox")
    end,
  },

  -- formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["javascript"] = { "prettier" },
        ["javascriptreact"] = { "prettier" },
        ["typescript"] = { "prettier" },
        ["typescriptreact"] = { "prettier" },
        ["vue"] = { "prettier" },
        ["css"] = { "prettier" },
        ["scss"] = { "prettier" },
        ["less"] = { "prettier" },
        ["html"] = { "prettier" },
        ["htmldjango"] = { "prettier" },
        ["json"] = { "prettier" },
        ["jsonc"] = { "prettier" },
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

  -- Find and Replace
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

  -- Testing
  { "nvim-neotest/neotest-jest" },
  {
    "nvim-neotest/neotest",
    opts = {
      -- Can be a list of adapters like what neotest expects,
      -- or a list of adapter names,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = { "neotest-jest" },
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
    -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    build = ":TSUpdate",
  },

  -- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
  --       These are some example plugins that I've included in the kickstart repository.
  --       Uncomment any of the lines below to enable them.
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
  --    up-to-date with whatever is in the kickstart repo.
  --    Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --
  --    For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
  -- { import = 'custom.plugins' },
}, {})

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Set highlight on search
vim.o.hlsearch = true

-- Make line numbers default
vim.wo.number = true

-- Disable mouse mode
vim.o.mouse = ""

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = "unnamedplus"

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

-- Highlight cursor line
vim.o.cursorline = true

-- Relative line numbers
vim.o.relativenumber = true

-- Expand tabs to spaces
vim.o.expandtab = true

-- Set completeopt to have a better completion experience
vim.o.completeopt = "menuone,noselect"

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

-- Set folding behavior
vim.o.foldmethod = "expr"
vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
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

-- Force out of insert mode via ctrl+c
vim.keymap.set("i", "<C-c>", "<Esc>")

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

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Undotree bindings
vim.keymap.set("n", "<leader>du", "<cmd>UndotreeToggle<cr>", { desc = "[D]ocument [U]ndotree" })

-- [[ Lsp Inlay Hints ]]
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.server_capabilities.inlayHintProvider then
      vim.lsp.inlay_hint.enable(args.buf, true)
    end
  end,
})

-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
-- Defer Treesitter setup after first render to improve startup time of 'nvim {filename}'
vim.defer_fn(function()
  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup({
    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      "c",
      "cpp",
      "go",
      "lua",
      "python",
      "rust",
      "tsx",
      "javascript",
      "typescript",
      "vimdoc",
      "vim",
      "bash",
    },

    -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself!)
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<c-space>",
        node_incremental = "<c-space>",
        scope_incremental = "<c-s>",
        node_decremental = "<M-space>",
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
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
        set_jumps = true, -- whether to set jumps in the jumplist
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
end, 0)

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>f", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gd", "<cmd>Pick lsp scope='definition'<CR>", "[G]oto [D]efinition")
  nmap("gr", "<cmd>Pick lsp scope='references'<CR>", "[G]oto [R]eferences")
  nmap("gI", "<cmd>Pick lsp scope='implementation'<CR>", "[G]oto [I]mplementation")
  nmap("<leader>D", "<cmd>Pick lsp scope='definition'<CR>", "Type [D]efinition")
  nmap("<leader>ds", "<cmd>Pick lsp scope='document_symbol'<CR>", "[D]ocument [S]ymbols")
  nmap("<leader>ws", "<cmd>Pick lsp scope='workspace_symbol'<CR>", "[W]orkspace [S]ymbols")

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
  nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
    vim.lsp.buf.format()
  end, { desc = "Format current buffer with LSP" })
end

-- document existing key chains
require("which-key").register({
  ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
  ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
  ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
  ["<leader>h"] = { name = "More git", _ = "which_key_ignore" },
  ["<leader>l"] = { name = "[L]lm", _ = "which_key_ignore" },
  ["<leader>r"] = { name = "[R]ename", _ = "which_key_ignore" },
  ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
  ["<leader>t"] = { name = "[T]est", _ = "which_key_ignore" },
  ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
})

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("mason-lspconfig").setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  rust_analyzer = {},
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
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require("neodev").setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require("mason-lspconfig")

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
})

mason_lspconfig.setup_handlers({
  function(server_name)
    require("lspconfig")[server_name].setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
      init_options = (servers[server_name] or {}).init_options,
    })
  end,
})

local lspconfig = require("lspconfig")
lspconfig.htmx.setup({ filetypes = { "html", "twig", "hbs", "htmldjango" } })

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

---@diagnostic disable-next-line: missing-fields
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
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

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
