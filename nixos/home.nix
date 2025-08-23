# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url =
      "https://github.com/nix-community/home-manager/archive/2a749f4790a14f7168be67cdf6e548ef1c944e10.tar.gz";
    sha256 = "0mddsj0497nz6cicbhmnlpx8bn3mscm5199c8q31d5r8sxngn1m5";
  };
  inherit (pkgs.lib) mkOrder;
in {
  imports = [ (import "${home-manager}/nixos") ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.elavigne = { pkgs, config, ... }: {
      home.packages = [ ];
      home.sessionVariables = { TERMINAL = "ghostty"; };
      dconf.settings = {
        "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
      };
      xsession = {
        enable = true;
        profileExtra = "export TERMINAL=ghostty";
      };

      accounts.email.accounts = {
        "Gmail" = {
          primary = true;
          address = "lavigneer@gmail.com";
          userName = "lavigneer@gmail.com";
          realName = "Eric Lavigne";
          thunderbird = { enable = true; };
          flavor = "gmail.com";
        };
        "Hotmail" = {
          address = "hi_eric@hotmail.com";
          userName = "hi_eric@hotmail.com";
          realName = "Eric Lavigne";
          thunderbird = {
            enable = true;
            settings = id: {
              "mail.server.server_${id}.authMethod" = 10;
              "mail.smtpserver.smtp_${id}.authMethod" = 10;
            };
          };
          imap = {
            authentication = "xoauth2";
            host = "outlook.office365.com";
            port = 993;
            tls.enable = true;
          };
        };
      };

      programs = {
        fzf = { enable = true; };
        thunderbird = {
          enable = true;
          profiles = {
            gmail.isDefault = true;
            hotmail.isDefault = false;
          };
        };

        lazygit = { enable = true; };

        opencode = {
          enable = true;
          settings = {
            provider = {
              ollama = {
                npm = "@ai-sdk/openai-compatible";
                name = "Ollama (local)";
                options = { baseURL = "http://localhost:11434/v1"; };
                models = { gpt-oss = { name = "Code Llama"; }; };
              };
            };
          };

        };

        neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          vimdiffAlias = true;
        };

        zsh = {
          enable = true;
          initContent = mkOrder 500 ''
            source ~/.zshrc.manual
            ZSH_TMUX_CONFIG="${config.home.homeDirectory}/.config/tmux/tmux.conf";
          '';
          oh-my-zsh = { enable = true; };
        };

        ghostty = {
          enable = true;
          enableZshIntegration = true;
        };

        tmux = {
          enable = true;
          plugins = [
            pkgs.tmuxPlugins.sensible
            pkgs.tmuxPlugins.pain-control
            pkgs.tmuxPlugins.kanagawa
          ];
          mouse = true;
          extraConfig = ''bind-key -r f display-popup -E "tmux-sessionizer"'';
        };

        ripgrep = { enable = true; };

        zed-editor = {
          enable = true;
          userSettings = {
            features = { edit_prediction_provider = "copilot"; };
            vim_mode = true;
            theme = {
              mode = "system";
              light = "One Light";
              dark = "One Dark";
            };
          };
          extensions = [
            "biome"
            "css"
            "dockerfile"
            "go"
            "golangci-lint"
            "html"
            "javascript"
            "json"
            "lua"
            "make"
            "nix"
            "ruff"
            "toml"
            "typescript"
            "yaml"
          ];
        };
      };

      services = {
        polybar = {
          enable = true;
          config = config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/workspace/dotfiles/polybar/.config/polybar/config.ini";
          script =
            "${config.home.homeDirectory}/workspace/dotfiles/polybar/.config/polybar/start.sh";
        };
      };

      home.stateVersion = "25.05";

      home.file = {
        ".ripgreprc".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/ripgrep/.ripgreprc";

        ".local/bin/tmux-sessionizer".source =
          config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/tmux/.local/bin/tmux-sessionizer";

        ".zshrc.manual".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/zshrc/.zshrc";
      };
      xdg.configFile = {
        "polybar/start.sh".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/polybar/.config/polybar/start.sh";

        "ghostty/config".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/ghostty/.config/ghostty/config";

        "nvim".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/nvim/.config/nvim";

        "rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/rofi/.config/rofi/config.rasi";
      };

    };
  };
}
