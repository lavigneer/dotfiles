# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let inherit (pkgs.lib) mkOrder;
in {

  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.elavigne = { pkgs, config, ... }: {
      home.packages = [ ];
      home.sessionVariables = { TERMINAL = "ghostty"; };
      # dconf.settings = {
      #   "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
      # };
      xsession = {
        enable = true;
        profileExtra = "export TERMINAL=ghostty";
        windowManager.i3 = { 
          enable = true;
          config.bars = [];
          extraConfig = ''
            include ~/.config/i3/config.user
          '';
        };
      };

      stylix = {
        autoEnable = true;
        # targets = {
        #   gnome.enable = true;
        #   tmux.enable = true;
        #   rofi.enable = true;
        # };
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

        rofi = { enable = true; };

        neovim = {
          enable = true;
          defaultEditor = true;
          vimAlias = true;
          vimdiffAlias = true;
          extraLuaConfig = ''
            require('config.lazy')
          '';
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
          settings = {
            config-file =
              "${config.home.homeDirectory}/.config/ghostty/config.user";
          };
        };

        tmux = {
          enable = true;
          plugins = [ pkgs.tmuxPlugins.sensible pkgs.tmuxPlugins.pain-control ];
          mouse = true;
          extraConfig = ''
            bind-key -r f display-popup -E "tmux-sessionizer"
            set -g renumber-windows on
          '';
        };

        ripgrep = { enable = true; };

        zed-editor = {
          enable = true;
          userSettings = {
            features = { edit_prediction_provider = "copilot"; };
            vim_mode = true;
            # theme = {
            #   mode = "system";
            #   light = "One Light";
            #   dark = "One Dark";
            # };
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

        "ghostty/config.user".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/ghostty/.config/ghostty/config";

        "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/nvim/.config/nvim/lazy-lock.json";

        "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/nvim/.config/nvim/lazyvim.json";

        "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/nvim/.config/nvim/lua";

        "nvim/stylua.toml".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/nvim/.config/nvim/stylua.toml";

        "i3/config.user".source = config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/workspace/dotfiles/i3/.config/i3/config";
        # "rofi/config.rasi".source = config.lib.file.mkOutOfStoreSymlink
        #   "${config.home.homeDirectory}/workspace/dotfiles/rofi/.config/rofi/config.rasi";
      };

    };
  };
}
