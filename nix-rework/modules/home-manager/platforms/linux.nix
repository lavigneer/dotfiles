{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    ../window-managers
    
    # Core utilities and development tools
    ../programs/utils.nix
    
    # Linux-specific program modules
    ../programs/git.nix
    ../programs/zsh.nix
    ../programs/neovim.nix
    ../programs/tmux.nix
    ../programs/terminals.nix
    ../programs/zed.nix
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
    
    # Zed editor moved to shared programs/zed.nix module
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