{
    # Global settings
    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    # Options
    opts = {
      number = true;
      relativenumber = true;
      mouse = "";
      showmode = false;
      clipboard = "unnamedplus";
      breakindent = true;
      undofile = true;
      ignorecase = true;
      smartcase = true;
      signcolumn = "yes";
      updatetime = 250;
      timeoutlen = 300;
      splitright = true;
      splitbelow = true;
      list = true;
      listchars = {
        tab = "» ";
        trail = "·";
        nbsp = "␣";
      };
      conceallevel = 2;
      inccommand = "split";
      cursorline = true;
      scrolloff = 10;
      laststatus = 3;
      splitkeep = "screen";
      hlsearch = true;
    };

    # Colorschemes
    colorschemes = {
      kanagawa.enable = true;
      # nightfox.enable = true;
    };

    # Key mappings
    keymaps = [
      # Basic keymaps
      {
        mode = ["n" "v"];
        key = "<Space>";
        action = "<Nop>";
        options.silent = true;
      }
      {
        mode = "i";
        key = "<S-Up>";
        action = "<Nop>";
        options.silent = true;
      }
      {
        mode = "i";
        key = "<S-Down>";
        action = "<Nop>";
        options.silent = true;
      }

      # Completion keymaps
      {
        mode = "i";
        key = "<C-]>";
        action = "<C-X><C-]>";
      }
      {
        mode = "i";
        key = "<C-F>";
        action = "<C-X><C-F>";
      }
      {
        mode = "i";
        key = "<C-D>";
        action = "<C-X><C-D>";
      }
      {
        mode = "i";
        key = "<C-L>";
        action = "<C-X><C-L>";
      }

      # Word wrap navigation
      {
        mode = "n";
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = "n";
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }

      # Centering movements
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
      }

      # Paste without copying
      {
        mode = "x";
        key = "<leader>p";
        action = "\"_dP";
      }

      # Delete to void register
      {
        mode = "n";
        key = "<leader>d";
        action = "\"_d";
      }
      {
        mode = "v";
        key = "<leader>d";
        action = "\"_d";
      }

      # Better up/down
      {
        mode = ["n" "x"];
        key = "j";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = ["n" "x"];
        key = "<Down>";
        action = "v:count == 0 ? 'gj' : 'j'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = ["n" "x"];
        key = "k";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }
      {
        mode = ["n" "x"];
        key = "<Up>";
        action = "v:count == 0 ? 'gk' : 'k'";
        options = {
          expr = true;
          silent = true;
        };
      }

      # Clear search highlight
      {
        mode = "n";
        key = "<Esc>";
        action = "<cmd>nohlsearch<CR>";
      }

      # Diagnostic keymaps
      {
        mode = "n";
        key = "<leader>e";
        action.__raw = "vim.diagnostic.open_float";
        options.desc = "Show diagnostic [E]rror messages";
      }
      {
        mode = "n";
        key = "<leader>q";
        action.__raw = "vim.diagnostic.setloclist";
        options.desc = "Open diagnostic [Q]uickfix list";
      }

      # Terminal mode
      {
        mode = "t";
        key = "<Esc><Esc>";
        action = "<C-\\><C-n>";
        options.desc = "Exit terminal mode";
      }

      # Mini.files
      {
        mode = "n";
        key = "<leader>e";
        action.__raw = "function() require('mini.files').open(vim.api.nvim_buf_get_name(0), true) end";
        options.desc = "Open mini.files (directory of current file)";
      }

      # Mini.pick keymaps
      {
        mode = "n";
        key = "<leader>?";
        action = "<cmd>Pick oldfiles<CR>";
        options.desc = "[?] Find recently opened files";
      }
      {
        mode = "n";
        key = "<leader><space>";
        action = "<cmd>Pick buffers<CR>";
        options.desc = "[ ] Find existing buffers";
      }
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Pick buf_lines scope='current'<CR>";
        options.desc = "[/] Fuzzily search in current buffer";
      }
      {
        mode = "n";
        key = "<leader>gf";
        action = "<cmd>Pick git_files<CR>";
        options.desc = "Search [G]it [F]iles";
      }
      {
        mode = "n";
        key = "<leader>gc";
        action = "<cmd>Pick git_commits<CR>";
        options.desc = "Search [G]it [C]ommits";
      }
      {
        mode = "n";
        key = "<leader>gm";
        action = "<cmd>Pick git_files scope='modified'<CR>";
        options.desc = "Search [G]it [M]odified";
      }
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>Pick files<CR>";
        options.desc = "[S]earch [F]iles";
      }
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>Pick help<CR>";
        options.desc = "[S]earch [H]elp";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Pick grep pattern='<cword>'<CR>";
        options.desc = "[S]earch current [W]ord";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Pick grep_live<CR>";
        options.desc = "[S]earch by [G]rep";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Pick diagnostic scope='all'<CR>";
        options.desc = "[S]earch [D]iagnostics";
      }
      {
        mode = "n";
        key = "<leader>sq";
        action = "<cmd>Pick list scope='quickfix'<CR>";
        options.desc = "[S]earch [Q]uickfix";
      }
      {
        mode = "n";
        key = "<leader>sr";
        action = "<cmd>Pick resume<CR>";
        options.desc = "[S]earch [R]esume";
      }
      {
        mode = "n";
        key = "<leader>se";
        action = "<cmd>Pick explorer<CR>";
        options.desc = "[S]earch [E]xplorer";
      }
      {
        mode = "n";
        key = "<leader>sv";
        action = "<cmd>Pick visit_paths<CR>";
        options.desc = "[S]earch [V]isit Paths";
      }

      # Buffer management
      {
        mode = "n";
        key = "<leader>bd";
        action.__raw = "function() require('mini.bufremove').delete() end";
        options.desc = "[B]uffer [D]elete";
      }
      {
        mode = "n";
        key = "<leader>bD";
        action.__raw = "function() require('mini.bufremove').delete(0, true) end";
        options.desc = "Force [B]uffer [D]elete";
      }

      # Conform formatting
      {
        mode = "n";
        key = "<leader>cf";
        action.__raw = "function() require('conform').format({ async = true, lsp_fallback = true }) end";
        options.desc = "[C]ode [F]ormat";
      }

      # Spectre find/replace
      {
        mode = "n";
        key = "<leader>rs";
        action.__raw = "function() require('spectre').open() end";
        options.desc = "Find/Replace in Spectre";
      }
    ];

    # File type associations
    filetype = {
      extension = {
        mdx = "markdown.mdx";
        tf = "terraform";
      };
      pattern = {
        ".*Tiltfile" = "starlark";
      };
    };

    # Autocommands
    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
      qf = {
        clear = false;
      };
      nixvim-lsp-attach = {
        clear = true;
      };
      miniindentscope-disable = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = "TextYankPost";
        desc = "Highlight when yanking (copying) text";
        group = "kickstart-highlight-yank";
        callback.__raw = "function() vim.highlight.on_yank() end";
      }
      {
        event = "FileType";
        desc = "Hide quickfix buffers from buffer list";
        group = "qf";
        pattern = "qf";
        command = "set nobuflisted";
      }
      {
        event = "LspAttach";
        desc = "LSP on_attach customizations";
        group = "nixvim-lsp-attach";
        callback.__raw = ''
          function(event)
            local client = vim.lsp.get_client_by_id(event.data.client_id)
            
            -- Enable inlay hints if supported
            if client and client.supports_method("textDocument/inlayHint") then
              vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            end

            -- Custom keymaps
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            end

            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
            end, "[L]sp [H]int Toggle")

            -- Format command
            vim.api.nvim_buf_create_user_command(event.buf, "Format", function(_)
              vim.lsp.buf.format({})
            end, { desc = "Format current buffer" })

            -- Document highlighting
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
          end
        '';
      }
      {
        event = "FileType";
        desc = "Disable indentscope for certain filetypes";
        group = "miniindentscope-disable";
        pattern = [
          "Trouble" "alpha" "dashboard" "fzf" "help" "lazy" "mason"
          "neo-tree" "notify" "snacks_dashboard" "snacks_notif"
          "snacks_terminal" "snacks_win" "toggleterm" "trouble"
        ];
        callback.__raw = ''
          function()
            vim.b.miniindentscope_disable = true
          end
        '';
      }
    ];

    # Plugins
    plugins = {
      # LSP
      lsp = {
        enable = true;
        servers = {
          rust-analyzer = {
            enable = true;
            settings = {
              cargo.allFeatures = true;
              check.command = "clippy";
              checkOnSave = true;
            };
          };
          biome.enable = true;
          tsserver = {
            enable = true;
            settings = {
              preferences = {
                includeInlayVariableTypeHints = true;
                includeInlayPropertyDeclarationTypeHints = true;
                includeInlayFunctionLikeReturnTypeHints = true;
              };
            };
          };
          html = {
            enable = true;
            filetypes = ["html" "twig" "hbs" "htmldjango" "templ"];
          };
          gopls = {
            enable = true;
            settings = {
              gopls = {
                gofumpt = true;
                usePlaceholders = false;
                completeUnimported = true;
                staticcheck = true;
                semanticTokens = true;
                hints = {
                  assignVariableTypes = true;
                  compositeLiteralFields = true;
                  compositeLiteralTypes = true;
                  constantValues = true;
                  functionTypeParameters = true;
                  parameterNames = true;
                  rangeVariableTypes = true;
                };
                analyses = {
                  nilness = true;
                  unusedparams = true;
                  unusedwrite = true;
                  useany = true;
                };
              };
            };
          };
          basedpyright = {
            enable = true;
            settings = {
              basedpyright = {
                analysis = {
                  typeCheckingMode = "off";
                  autoSearchPaths = true;
                  diagnosticMode = "openFilesOnly";
                  useLibraryCodeForTypes = true;
                };
              };
            };
          };
          nil_ls.enable = true;
          tailwindcss = {
            enable = true;
            filetypes = [
              "astro" "html" "css" "scss" "javascript" "javascriptreact"
              "typescript" "typescriptreact" "vue" "svelte" "rust" "templ"
              "gohtml" "gohtmltmpl" "markdown" "mdx"
            ];
          };
          lua-ls = {
            enable = true;
            settings = {
              Lua = {
                runtime.version = "LuaJIT";
                workspace = {
                  checkThirdParty = false;
                  library = [
                    "\${3rd}/luv/library"
                  ];
                };
                completion.callSnippet = "Replace";
              };
            };
          };
        };
        keymaps = {
          lspBuf = {
            "gd" = "definition";
            "gD" = "declaration";
            "grt" = "type_definition";
            "K" = "hover";
            "<leader>ds" = "document_symbol";
          };
          diagnostic = {
            "<leader>e" = "open_float";
            "<leader>q" = "setloclist";
            "grX" = "setqflist";
            "grx" = "setloclist";
          };
        };
      };



      # Treesitter
      treesitter = {
        enable = true;
        settings = {
          ensure_installed = [
            "bash" "c" "html" "lua" "markdown" "markdown_inline" 
            "vim" "vimdoc" "go" "rust" "typescript" "javascript"
            "python" "nix" "json" "yaml" "toml"
          ];
          auto_install = true;
          highlight.enable = true;
          indent.enable = true;
        };
      };

      # Treesitter textobjects
      treesitter-textobjects = {
        enable = true;
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "aa" = "@parameter.outer";
            "ia" = "@parameter.inner";
            "af" = "@function.outer";
            "if" = "@function.inner";
            "ac" = "@class.outer";
            "ic" = "@class.inner";
          };
        };
        move = {
          enable = true;
          setJumps = true;
          gotoNextStart = {
            "]m" = "@function.outer";
            "]]" = "@class.outer";
          };
          gotoNextEnd = {
            "]M" = "@function.outer";
            "][" = "@class.outer";
          };
          gotoPreviousStart = {
            "[m" = "@function.outer";
            "[[" = "@class.outer";
          };
          gotoPreviousEnd = {
            "[M" = "@function.outer";
            "[]" = "@class.outer";
          };
        };
      };

      # Completion
      blink-cmp = {
        enable = true;
        settings = {
          keymap.preset = "enter";
          appearance.nerd_font_variant = "mono";
          completion = {
            documentation.auto_show = false;
            list.selection.auto_insert = false;
            accept.auto_brackets.enabled = false;
          };
          sources.default = ["lsp" "path" "snippets" "buffer"];
        };
      };

      # Conform for formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            javascript = ["prettier" "biome"];
            javascriptreact = ["prettier" "biome"];
            typescript = ["prettier" "biome"];
            typescriptreact = ["prettier" "biome"];
            astro = ["prettier"];
            vue = ["prettier"];
            css = ["prettier"];
            scss = ["prettier"];
            html = ["rustywind" "prettier"];
            json = ["prettier" "biome"];
            jsonc = ["biome"];
            yaml = ["prettier"];
            markdown = ["prettier"];
            lua = ["stylua"];
            go = ["gopls"];
            nix = ["nixfmt"];
            rust = ["rustfmt"];
            python = ["black"];
          };
        };
      };



      # Utility plugins
      sleuth.enable = true;
      dressing = {
        enable = true;
        settings = {
          select.enabled = false;
        };
      };

      # Mini plugins
      mini = {
        enable = true;
        modules = {
          basics = {
            options = {
              extra_ui = true;
            };
            mappings = {
              basic = false;
              windows = true;
            };
          };
          ai = {
            n_lines = 500;
          };
          surround = {};
          bracketed = {};
          comment = {};
          git = {};
          cursorword = {};
          diff = {
            view = {
              style = "sign";
            };
            mappings = {
              apply = "";
              reset = "";
              textobject = "";
            };
          };
          extra = {};
          move = {};
          tabline = {};
          notify = {};
          statusline = {};
          visits = {};
          icons = {};
          hipatterns = {
            highlighters = {
              fixme = {
                pattern = "%f[%w]()FIXME()%f[%W]";
                group = "MiniHipatternsFixme";
              };
              hack = {
                pattern = "%f[%w]()HACK()%f[%W]";
                group = "MiniHipatternsHack";
              };
              todo = {
                pattern = "%f[%w]()TODO()%f[%W]";
                group = "MiniHipatternsTodo";
              };
              note = {
                pattern = "%f[%w]()NOTE()%f[%W]";
                group = "MiniHipatternsNote";
              };
              hex_color = "hex_color";
            };
          };
          clue = {
            triggers = [
              { mode = "n"; keys = "<Leader>"; }
              { mode = "x"; keys = "<Leader>"; }
              { mode = "i"; keys = "<C-x>"; }
              { mode = "n"; keys = "g"; }
              { mode = "x"; keys = "g"; }
              { mode = "n"; keys = "'"; }
              { mode = "n"; keys = "`"; }
              { mode = "x"; keys = "'"; }
              { mode = "x"; keys = "`"; }
              { mode = "n"; keys = "\""; }
              { mode = "x"; keys = "\""; }
              { mode = "i"; keys = "<C-r>"; }
              { mode = "c"; keys = "<C-r>"; }
              { mode = "n"; keys = "<C-w>"; }
              { mode = "n"; keys = "z"; }
              { mode = "x"; keys = "z"; }
              { mode = "n"; keys = "["; }
              { mode = "x"; keys = "["; }
              { mode = "n"; keys = "]"; }
              { mode = "x"; keys = "]"; }
            ];
            window = {
              delay = 450;
              config = {
                anchor = "SW";
                row = "auto";
                col = "auto";
                width = "auto";
              };
            };
          };
          bufremove = {};
          files = {
            options = {
              use_as_default_explorer = true;
            };
            windows = {
              width_nofocus = 15;
              width_focus = 50;
              width_preview = 80;
              preview = true;
            };
          };
          pick = {
            mappings = {
              choose_marked = "<C-q>";
              choose_in_vsplit = "";
            };
          };
        };
      };

      # Testing
      neotest = {
        enable = true;
        adapters = {
          jest.enable = true;
          golang.enable = true;
        };
        settings = {
          status.virtual_text = true;
          output.open_on_run = false;
        };
      };

      # DAP (Debug Adapter Protocol)
      dap = {
        enable = true;
        extensions = {
          dap-ui.enable = true;
          dap-go.enable = true;
        };
      };

      # Find and replace
      spectre.enable = true;

      # Windsurf integration
      helm.enable = true;
    };

    # Extra Lua configuration for complex setups
    extraConfigLua = ''
      -- Custom filetype detection
      vim.filetype.add({
        extension = {
          mdx = "markdown.mdx",
          tf = "terraform",
        },
        pattern = {
          [".*Tiltfile"] = "starlark",
        },
      })
    '';
}
