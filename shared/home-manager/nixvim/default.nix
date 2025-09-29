{
  config,
  pkgs,
  lib,
  inputs,
  ...
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
      shiftwidth = 2;
      tabstop = 2;
      smartindent = true;
      wrap = false;
      termguicolors = true;
      colorcolumn = "80";
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
    plugins = import ./plugins.nix;

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
