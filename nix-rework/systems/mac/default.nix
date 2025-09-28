{ config, pkgs, inputs, username, userEmail, userFullName, ... }:

{
  imports = [
    # Shared system modules this system wants
    ../../shared/system/nix.nix
    ../../shared/system/fonts.nix
    ../../shared/system/shell.nix
    ../../shared/system/stylix.nix
    ../../darwin/modules/programs/terminals.nix
    # Note: Not importing gaming.nix since this is macOS
  ];
  
  home-manager.users.${username} = {
    imports = [
      # Shared Home Manager modules this system wants
      ../../shared/home-manager/core.nix
      ../../shared/home-manager/cli-tools.nix
      ../../shared/home-manager/development.nix
      ../../shared/home-manager/git.nix
      ../../shared/home-manager/zsh.nix
      ../../shared/home-manager/neovim.nix
      ../../shared/home-manager/tmux.nix
      ../../shared/home-manager/terminals.nix
      ../../shared/home-manager/zed.nix
      ../../shared/home-manager/docker.nix
      ../../shared/home-manager/discord.nix
      ../../shared/home-manager/browser.nix
      ../../darwin/modules/programs/karabiner.nix
      ../../darwin/modules/window-managers/aerospace.nix
    ];

    # Enable specific window managers for this system
    windowManagers = {
      aerospace.enable = true;
    };

    # macOS-specific tools and utilities
    home.packages = with pkgs; [];

    # Email configuration for this system
    accounts.email.accounts = {
      "Work" = {
        primary = true;
        address = userEmail;
        userName = userEmail;
        realName = userFullName;
      };
    };
  };

  system.defaults = {
    dock = {
      tilesize = 48;
      largesize = 64;
      orientation = "bottom";
    };
  };

  # Machine-specific garbage collection settings (override platform defaults)
  nix.gc = {
    interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Sunday 2 AM for this machine
    options = "--delete-older-than 30d";  # Less aggressive than default for work machine
  };
}