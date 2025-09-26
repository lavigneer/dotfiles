{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Linux-specific Home Manager configuration

  # Linux-specific packages
  home.packages = with pkgs; [
    # Linux desktop applications
    discord
    google-chrome
    lutris
    pavucontrol
    solaar
    dunst
    xclip
    nil # Nix LSP
    
    # Linux system tools
    networkmanagerapplet
    blueman
  ];

  # Linux-specific XDG config files
  xdg.configFile = {
    # Window managers and desktop environment configs (i3 config handled by xsession.windowManager.i3)
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
    
    # Wayland configs
    "sway".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/sway/.config/sway";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar/.config/waybar";
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr/.config/hypr";
    "wofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wofi/.config/wofi";
    "foot".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
    
    # Display and monitor configs
    "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
  };

  # Linux-specific programs
  programs = {
    # Email (Linux only for now)
    thunderbird = {
      enable = true;
      profiles = {
        gmail.isDefault = true;
        hotmail.isDefault = false;
      };
    };

    # Linux window manager / desktop programs
    rofi.enable = true;
    
    # Zed editor (Linux)
    zed-editor = {
      enable = true;
      userSettings = {
        features = { edit_prediction_provider = "copilot"; };
        vim_mode = true;
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

  # Linux-specific services
  services = {
    # Polybar for i3
    polybar = {
      enable = true;
      config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
      script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
    };
    
    # Dunst notification daemon
    dunst.enable = true;
    
    # Picom compositor
    picom.enable = true;
    
    # GPG agent
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    # SSH agent
    ssh-agent.enable = true;
    
    # Syncthing (file synchronization)
    syncthing.enable = true;
    
    # Redshift (blue light filter)
    redshift = {
      enable = true;
      latitude = 53.5461;   # Edmonton coordinates
      longitude = -113.4938;
      settings = {
        redshift = {
          adjustment-method = "randr";
          gamma = 0.8;
        };
        randr = {
          screen = 0;
        };
      };
    };
  };

  # Linux-specific environment variables
  home.sessionVariables = {
    BROWSER = "google-chrome";
  };

  # Linux-specific X session configuration
  xsession = {
    enable = true;
    profileExtra = "export TERMINAL=ghostty";
    windowManager.i3 = { 
      enable = true;
      config.bars = [];
      extraConfig = ''
        include ~/.config/i3/config
      '';
    };
  };

  # Linux-specific git configuration
  programs.git = {
    userEmail = userEmail; # This will be hi_eric@hotmail.com for Linux
  };

  # Email accounts (Linux specific for thunderbird)
  accounts.email.accounts = {
    "Hotmail" = {
      primary = true;
      address = userEmail; # This will be hi_eric@hotmail.com for Linux
      userName = userEmail;
      realName = userFullName;
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
}