{ config, pkgs, lib, inputs, username, userEmail, userFullName, ... }:

{
  imports = [
    # Shared system modules this system wants
    ../../shared/system/nix.nix
    ../../shared/system/fonts.nix
    ../../shared/system/shell.nix
    ../../shared/system/stylix.nix
    ../../darwin/modules/programs/terminals.nix
    ../../darwin/modules/programs/1password.nix
  ];

  home-manager.backupFileExtension = "bak";
  
  home-manager.users.${username} = {
    imports = [
      # Shared Home Manager modules this system wants
      ../../shared/home-manager/core.nix
      ../../shared/home-manager/cli-tools.nix
      ../../shared/home-manager/development.nix
      ../../shared/home-manager/git.nix
      ../../shared/home-manager/zsh.nix
      ../../shared/home-manager/nixvim
      ../../shared/home-manager/tmux.nix
      ../../shared/home-manager/terminals.nix
      ../../shared/home-manager/zed.nix
      ../../shared/home-manager/docker.nix
      ../../shared/home-manager/discord.nix
      ../../shared/home-manager/browser.nix
      ../../darwin/modules/programs/karabiner.nix
      ../../darwin/modules/programs/raycast.nix
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
  
  # Let Determinate Nix manage things
  nix = {
    enable = lib.mkForce false;
    optimise.automatic = lib.mkForce false;
    gc.automatic = lib.mkForce false;
  };
}