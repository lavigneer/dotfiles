{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    # Core utilities and development tools
    ../programs/utils.nix
    
    # macOS-specific program modules
    ../programs/git.nix
    ../programs/zsh.nix
    ../programs/neovim.nix
    ../programs/tmux.nix
    ../programs/terminals.nix
    ../programs/zed.nix
    
    # Note: No window managers imported for macOS
    # Add other macOS-specific programs here as needed
  ];

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
    # Work-specific Zed editor customizations
    zed-editor = {
      # Zed is enabled by default via shared module
      # Add any work-specific overrides here
      userSettings = {
        # Work-specific settings can override shared ones
        # collaboration = {
        #   channel_default_public = false;
        # };
      };
    };
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
