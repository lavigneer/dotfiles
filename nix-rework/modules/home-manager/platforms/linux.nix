{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    ../window-managers
  ];

  # Linux-specific Home Manager configuration

  # Window manager configuration - enable the ones you want to use
  windowManagers = {
    i3.enable = true;           # Enable i3
    sway.enable = true;         # Enable Sway  
    hyprland.enable = true;     # Enable Hyprland
  };

  # Linux-specific packages (non-window manager specific)
  home.packages = with pkgs; [
    # Linux desktop applications
    discord
    google-chrome
    lutris
    pavucontrol
    solaar
    nil # Nix LSP
  ];

  # Linux-specific programs (non-window manager specific)
  programs = {
    # Email (Linux only for now)
    thunderbird = {
      enable = true;
      profiles = {
        gmail.isDefault = true;
        hotmail.isDefault = false;
      };
    };
    
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

  # Linux-specific environment variables
  home.sessionVariables = {
    BROWSER = "google-chrome";
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