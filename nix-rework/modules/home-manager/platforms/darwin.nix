{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # macOS-specific Home Manager configuration

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific packages
    mas # Mac App Store CLI
    
    # macOS development tools
    darwin.cctools
  ];

  # macOS-specific XDG config files
  xdg.configFile = {
    # macOS window management
    "aerospace".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aerospace/.config/aerospace";
    
    # macOS key remapping
    "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner/.config/karabiner";
  };

  # macOS-specific programs
  programs = {
    # Programs that work differently or are only available on macOS
  };

  # macOS-specific services
  services = {
    # macOS-specific services
    syncthing.enable = true;
  };

  # macOS-specific environment variables
  home.sessionVariables = {
    # macOS-specific environment variables
    BROWSER = "open";
  };

  # macOS/Work-specific git configuration
  programs.git = {
    userEmail = userEmail; # This will be eric.lavigne@mongodb.com for macOS
    extraConfig = {
      # Work-specific git settings can go here
    };
  };

  # Work-specific email accounts for macOS
  accounts.email.accounts = {
    "Work" = {
      primary = true;
      address = userEmail;
      userName = userEmail;
      realName = userFullName;
      # Add work email provider settings as needed
    };
  };
}
