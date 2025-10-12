{ config
, pkgs
, lib
, inputs
, ...
}:

{
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  stylix.targets.nixvim = {
    enable = true;
  };

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;

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
      expandtab = true;
      shiftwidth = 4;
      tabstop = 4;
      smartindent = true;
      wrap = false;
      termguicolors = true;
      colorcolumn = "100";
    };

    # Key mappings
    keymaps = import ./keymaps.nix;

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

            -- Enable endhints if supported (lsp-endhints handles this automatically)
            -- Disable built-in inline inlay hints
            if client and client.supports_method("textDocument/inlayHint") then
              vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
            end

            -- Custom keymaps
            local map = function(keys, func, desc)
              vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
            end

            map("<leader>lh", function()
              require('lsp-endhints').toggle()
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
          "Trouble"
          "alpha"
          "dashboard"
          "fzf"
          "help"
          "lazy"
          "mason"
          "neo-tree"
          "notify"
          "snacks_dashboard"
          "snacks_notif"
          "snacks_terminal"
          "snacks_win"
          "toggleterm"
          "trouble"
        ];
        callback.__raw = ''
          function()
            vim.b.miniindentscope_disable = true
          end
        '';
      }
    ];

    # Plugins
    plugins = import ./plugins.nix { inherit pkgs; };

    # Extra plugins not in nixvim
    extraPlugins = with pkgs.vimPlugins; [
      neotest-golang
      pkgs.vimPlugins.nvim-treesitter
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins: [ plugins.go ]))
      (pkgs.vimUtils.buildVimPlugin {
        name = "sidekick.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "folke";
          repo = "sidekick.nvim";
          rev = "main";
          sha256 = "sha256-yhKnsUCZWJnPQ+/EuSqhb2fj6KGxuGWpkPsxCiwcO2o=";
        };
        doCheck = false;
      })
      (pkgs.vimUtils.buildVimPlugin {
        name = "nvim-lsp-endhints";
        src = pkgs.fetchFromGitHub {
          owner = "chrisgrieser";
          repo = "nvim-lsp-endhints";
          rev = "main";
          sha256 = "sha256-gfVE5XSGuf+aC/Pi+sGWsfgmWpQ6RvC9x+SMTRagdSM=";
        };
        doCheck = false;
      })
    ];

    # Extra Lua configuration for complex setups
    extraConfigLua = ''
      -- Neotest golang adapter configuration
      require('neotest').setup({
        adapters = {
          require('neotest-golang'),
        },
      })

      -- Sidekick configuration
      require('sidekick').setup({
        cli = {
          mux = {
            backend = "tmux",
            enabled = true,
          },
        },
      })

      -- LSP Endhints configuration
      require('lsp-endhints').setup({
        icons = {
          type = "=> ",
          parameter = "=> ",
        },
        label = {
          padding = 1,
        },
      })

      -- Tilt LSP configuration
      local lspconfig = require('lspconfig')
      local configs = require('lspconfig.configs')

      if not configs.tilt_lsp then
        configs.tilt_lsp = {
          default_config = {
            cmd = { 'tilt', 'lsp', 'start' },
            filetypes = { 'starlark', 'tiltfile' },
            root_dir = lspconfig.util.root_pattern('Tiltfile'),
            settings = {},
          },
        }
      end

      lspconfig.tilt_lsp.setup({})

      -- Custom filetype detection
      vim.filetype.add({
        extension = {
          mdx = "markdown.mdx",
          tf = "terraform",
        },
        filename = {
          ["Tiltfile"] = "starlark",
        },
        pattern = {
          [".*Tiltfile"] = "starlark",
        },
      })

      -- Platform-specific clipboard setup
      if vim.fn.has('wsl') == 1 then
        vim.g.clipboard = {
          name = 'WslClipboard',
          copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
          },
          paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          },
          cache_enabled = 0,
        }
      end
    '';

    # Extra packages that nixvim needs
    extraPackages = with pkgs; [
      # Language servers
      nil
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      lua-language-server
      gopls
      rust-analyzer
      pyright
      tilt

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black
      rustfmt

      # Tools
      delve
      tree-sitter
      ripgrep
      fd
      nodePackages.neovim

      # Additional formatters for conform
      biome
      rustywind
    ];
  };
}
