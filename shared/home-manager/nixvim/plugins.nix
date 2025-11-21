# Plugins configuration for nixvim
{ pkgs, ... }:
{
  # LSP
  lsp = {
    enable = true;
    servers = {
      rust_analyzer = {
        enable = true;
        installCargo = false;
        installRustc = false;
        settings = {
          cargo.allFeatures = true;
          check.command = "clippy";
          checkOnSave = true;
        };
      };
      biome.enable = true;
      ts_ls = {
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
        filetypes = [
          "html"
          "twig"
          "hbs"
          "htmldjango"
          "templ"
        ];
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
          "astro"
          "html"
          "css"
          "scss"
          "javascript"
          "javascriptreact"
          "typescript"
          "typescriptreact"
          "vue"
          "svelte"
          "rust"
          "templ"
          "gohtml"
          "gohtmltmpl"
          "markdown"
          "mdx"
        ];
      };
      lua_ls = {
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
        "bash"
        "c"
        "html"
        "lua"
        "markdown"
        "markdown_inline"
        "vim"
        "vimdoc"
        "go"
        "rust"
        "typescript"
        "javascript"
        "python"
        "nix"
        "json"
        "yaml"
        "toml"
        "starlark"
      ];
      auto_install = true;
      highlight.enable = true;
      indent.enable = true;
    };
  };

  # Treesitter textobjects
  treesitter-textobjects = {
    enable = true;
    settings = {
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
        set_jumps = true;
        goto_next_start = {
          "]m" = "@function.outer";
          "]]" = "@class.outer";
        };
        goto_next_end = {
          "]M" = "@function.outer";
          "][" = "@class.outer";
        };
        goto_previous_start = {
          "[m" = "@function.outer";
          "[[" = "@class.outer";
        };
        goto_previous_end = {
          "[M" = "@function.outer";
          "[]" = "@class.outer";
        };
      };
    };
  };

  # Treesitter context (sticky scroll)
  treesitter-context = {
    enable = true;
    settings = {
      max_lines = 3;
      min_window_height = 0;
      multiline_threshold = 1;
      trim_scope = "outer";
      mode = "cursor";
    };
  };

  # Completion
  blink-cmp = {
    enable = true;
    settings = {
      keymap.preset = "enter";
      appearance.nerd_font_variant = "mono";
      completion = {
        documentation.auto_show = true;
        list.selection.auto_insert = false;
        accept.auto_brackets.enabled = false;
      };
      sources.default = [
        "lsp"
        "path"
        "snippets"
        "buffer"
      ];
    };
  };

  # Conform for formatting
  conform-nvim = {
    enable = true;
    settings = {
      formatters_by_ft = {
        javascript = [
          "prettier"
          "biome"
        ];
        javascriptreact = [
          "prettier"
          "biome"
        ];
        typescript = [
          "prettier"
          "biome"
        ];
        typescriptreact = [
          "prettier"
          "biome"
        ];
        astro = [ "prettier" ];
        vue = [ "prettier" ];
        css = [ "prettier" ];
        scss = [ "prettier" ];
        html = [
          "rustywind"
          "prettier"
        ];
        json = [
          "prettier"
          "biome"
        ];
        jsonc = [ "biome" ];
        yaml = [ "prettier" ];
        markdown = [ "prettier" ];
        lua = [ "stylua" ];
        go = [ "gopls" ];
        nix = [ "nixfmt" ];
        rust = [ "rustfmt" ];
        python = [ "black" ];
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
      # Base16 colorscheme support for stylix
      base16 = { };
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
      surround = { };
      bracketed = { };
      comment = { };
      git = { };
      cursorword = { };
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
      extra = { };
      move = { };
      tabline = { };
      notify = { };
      statusline = { };
      visits = { };
      icons = { };
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
          {
            mode = "n";
            keys = "<Leader>";
          }
          {
            mode = "x";
            keys = "<Leader>";
          }
          {
            mode = "i";
            keys = "<C-x>";
          }
          {
            mode = "n";
            keys = "g";
          }
          {
            mode = "x";
            keys = "g";
          }
          {
            mode = "n";
            keys = "'";
          }
          {
            mode = "n";
            keys = "`";
          }
          {
            mode = "x";
            keys = "'";
          }
          {
            mode = "x";
            keys = "`";
          }
          {
            mode = "n";
            keys = "\"";
          }
          {
            mode = "x";
            keys = "\"";
          }
          {
            mode = "i";
            keys = "<C-r>";
          }
          {
            mode = "c";
            keys = "<C-r>";
          }
          {
            mode = "n";
            keys = "<C-w>";
          }
          {
            mode = "n";
            keys = "z";
          }
          {
            mode = "x";
            keys = "z";
          }
          {
            mode = "n";
            keys = "[";
          }
          {
            mode = "x";
            keys = "[";
          }
          {
            mode = "n";
            keys = "]";
          }
          {
            mode = "x";
            keys = "]";
          }
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
      bufremove = { };
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
        source = {
          files = {
            tool = "rg";
          };
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
  };

  # DAP UI and extensions
  dap-ui.enable = true;
  dap-go.enable = true;

  # Find and replace
  spectre.enable = true;

  # Helm integration
  helm.enable = true;
}
