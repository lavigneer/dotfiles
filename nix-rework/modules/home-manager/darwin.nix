{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    # Core Home Manager setup
    ./core.nix
    
    # Program modules
    ./programs/cli-tools.nix
    ./programs/development.nix
    ./programs/git.nix
    ./programs/zsh.nix
    ./programs/neovim.nix
    ./programs/tmux.nix
    ./programs/terminals.nix
    ./programs/zed.nix
    ./programs/docker.nix
    ./programs/karabiner.nix
    
    # Window managers (macOS-specific)
    ./window-managers/darwin.nix
  ];

  # macOS-specific Home Manager configuration

  # Enable macOS window manager
  windowManagers = {
    aerospace.enable = true;  # Enable AeroSpace tiling window manager
  };

  # macOS-specific packages
  home.packages = with pkgs; [
    # macOS-specific packages
    mas # Mac App Store CLI
    
    # macOS development tools
    darwin.cctools
    
    # macOS window management and utilities moved to programs/macos-window-management.nix
  ];

  # macOS-specific XDG config files
  xdg.configFile = {
    # macOS window management configs moved to programs/macos-window-management.nix
  };

  # macOS-specific services
  services = {
  };

  # macOS-specific environment variables
  home.sessionVariables = {
    # macOS-specific environment variables
    BROWSER = "open";
  };

  # macOS/Work-specific git configuration
  programs.git = {
    userEmail = userEmail;
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
