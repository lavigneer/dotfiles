{ config, pkgs, inputs, username, ... }:

{
  # ===== HOME MANAGER MODULE IMPORTS =====
  # This system imports specific program and window manager modules
  home-manager.users.${username} = {
    imports = [
      # macOS programs this system wants
      ../../darwin/modules/programs/macos-tools.nix
      ../../darwin/modules/programs/git.nix
      ../../darwin/modules/programs/email.nix
      ../../darwin/modules/programs/karabiner.nix
      
      # macOS window managers this system wants
      ../../darwin/modules/window-managers/aerospace.nix
    ];

    # Enable specific window managers for this system
    windowManagers = {
      aerospace.enable = true;  # Enable AeroSpace tiling window manager
    };
  };

  # Machine-specific configuration for this particular macOS system
  
  # Machine-specific macOS system preferences
  system.defaults = {
    # Dock settings for this machine
    dock = {
      autohide = true;
      magnification = true;
      tilesize = 48;        # Larger tiles for this machine
      largesize = 64;
      orientation = "bottom";
    };
    
    # Finder settings
    finder = {
      _FXShowPosixPathInTitle = true;
      FXEnableExtensionChangeWarning = false;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      ShowStatusBar = true;
    };
    
    # Global UI settings for this machine
    NSGlobalDomain = {
      _HIHideMenuBar = false;  # Keep menu bar visible on this machine
      AppleKeyboardUIMode = 3;
      AppleShowAllExtensions = true;
      AppleInterfaceStyle = "Dark";
      "com.apple.sound.beep.feedback" = 0;
      
      # Machine-specific keyboard/mouse settings
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
    };
    
    # Trackpad settings for this machine
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };
    
    # Screenshot settings
    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
    };
  };

  # Machine-specific keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Machine-specific system packages (minimal - most via Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential system tools for this machine
    vim
  ];

  # Machine-specific garbage collection settings (can override platform defaults)
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Sunday 2 AM for this machine
    options = "--delete-older-than 30d";  # Less aggressive on work machine
  };

  # Machine-specific services
  services = {
    nix-daemon.enable = true;
  };

  # This value determines the nix-darwin release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial setup.
  system.stateVersion = 5;
}