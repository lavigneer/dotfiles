{ config
, pkgs
, lib
, username
, userFullName
, userEmail
, ...
}:

{
  # macOS platform system defaults (can be overridden by machine-specific configs)

  # Default user configuration for macOS systems
  users.users.${username} = {
    name = username;
    # fullName = userFullName;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  system.primaryUser = username;

  # Default macOS system preferences (conservative defaults)
  system.defaults = {
    dock = {
      autohide = lib.mkDefault true;
      magnification = lib.mkDefault true;
      tilesize = lib.mkDefault 36;
      largesize = lib.mkDefault 56;
    };

    finder = {
      _FXShowPosixPathInTitle = lib.mkDefault true;
      FXEnableExtensionChangeWarning = lib.mkDefault false;
      AppleShowAllExtensions = lib.mkDefault true;
      ShowPathbar = lib.mkDefault true;
      ShowStatusBar = lib.mkDefault true;
    };

    NSGlobalDomain = {
      AppleKeyboardUIMode = lib.mkDefault 3;
      AppleShowAllExtensions = lib.mkDefault true;
      AppleInterfaceStyle = lib.mkDefault "Dark";
      "com.apple.sound.beep.feedback" = lib.mkDefault 0;
      _HIHideMenuBar = lib.mkDefault false;

      # Keyboard and mouse defaults
      KeyRepeat = lib.mkDefault 2;
      InitialKeyRepeat = lib.mkDefault 15;
      ApplePressAndHoldEnabled = lib.mkDefault false;
    };

    trackpad = {
      Clicking = lib.mkDefault true;
      TrackpadRightClick = lib.mkDefault true;
      TrackpadThreeFingerDrag = lib.mkDefault true;
    };

    # Screenshot settings - sensible defaults for all Macs
    screencapture = {
      location = lib.mkDefault "~/Pictures/Screenshots";
      type = lib.mkDefault "png";
    };
  };

  # Default keyboard settings
  system.keyboard = {
    enableKeyMapping = lib.mkDefault true;
    remapCapsLockToEscape = lib.mkDefault true;
  };

  # Homebrew configuration (base setup)
  homebrew = {
    enable = lib.mkDefault true;

    # Cleanup settings
    onActivation = {
      autoUpdate = lib.mkDefault true;
      upgrade = lib.mkDefault true;
    };
  };

  # Default system state version for macOS (can be overridden per machine)
  system.stateVersion = lib.mkDefault 5;
}
