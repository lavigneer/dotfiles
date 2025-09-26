{ config, pkgs, inputs, username, userEmail, userFullName, ... }:

{
  imports = [
    # Shared system modules this system wants
    ../../shared/system/nix.nix
    ../../shared/system/fonts.nix
    ../../shared/system/shell.nix
    ../../shared/system/stylix.nix
    # Note: Not importing gaming.nix since this is macOS
  ];
  
  # ===== HOME MANAGER MODULE IMPORTS =====
  # This system imports specific program and window manager modules
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
      
      # macOS programs this system wants
      ../../darwin/modules/programs/karabiner.nix
      
      # macOS window managers this system wants
      ../../darwin/modules/window-managers/aerospace.nix
    ];

    # Enable specific window managers for this system
    windowManagers = {
      aerospace.enable = true;  # Enable AeroSpace tiling window manager
    };

    # Note: Thunderbird module is available but not imported (using native macOS mail apps)

    # macOS-specific tools and utilities
    home.packages = with pkgs; [
      mas             # Mac App Store CLI
      darwin.cctools  # macOS development tools
    ];

    # Email configuration for this system (work email)
    accounts.email.accounts = {
      "Work" = {
        primary = true;
        address = userEmail;
        userName = userEmail;
        realName = userFullName;
        # Add work email provider settings as needed
      };
    };
  };

  # Machine-specific configuration for this particular macOS system
  
  # Machine-specific macOS system preferences (only overrides of platform defaults)
  system.defaults = {
    # Dock settings - overrides for this specific machine
    dock = {
      tilesize = 48;        # Larger tiles than default (36)
      largesize = 64;       # Larger magnified size than default (56)
      orientation = "bottom";
    };
    
    # Finder settings - additional settings for this machine
    finder = {
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    
    # Global UI settings - machine-specific overrides
    NSGlobalDomain = {
      _HIHideMenuBar = false;  # Keep menu bar visible (override auto-hide)
      
      # Machine-specific keyboard/mouse settings
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
    };
    
    # Trackpad settings - additional features for this machine
    trackpad = {
      TrackpadThreeFingerDrag = true;  # Not in platform defaults
    };
    
    # Screenshot settings - machine-specific
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
  };

  # Machine-specific garbage collection settings (override platform defaults)
  nix.gc = {
    interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Sunday 2 AM for this machine
    options = "--delete-older-than 30d";  # Less aggressive than default for work machine
  };
}