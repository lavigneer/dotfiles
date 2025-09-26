{ config, pkgs, inputs, username, ... }:

{
  # nix-darwin configuration for macOS

  # Enable flakes and other experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    interval = { Weekday = 0; Hour = 2; Minute = 0; }; # Weekly on Sunday at 2 AM
    options = "--delete-older-than 60d";
  };

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # System packages (keep minimal, most packages should be in Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential tools
    git
    vim
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    noto-fonts-extra
    nerd-fonts.go-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.heavy-data
  ];

  # Shell configuration
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  # macOS system preferences
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.2;
      minimize-to-application = true;
      show-recents = false;
      static-only = true;
      tilesize = 48;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      QuitMenuItem = true;
      _FXShowPosixPathInTitle = true;
    };

    # Login window settings
    loginwindow = {
      GuestEnabled = false;
      DisableConsoleAccess = true;
    };

    # Screenshots
    screencapture.location = "~/Pictures/Screenshots";

    # Trackpad and mouse
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # Keyboard
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3; # Full keyboard access for all controls
      ApplePressAndHoldEnabled = false; # Disable press-and-hold for keys in favor of key repeat
      KeyRepeat = 2; # Fast key repeat
      InitialKeyRepeat = 15; # Faster initial key repeat
      "com.apple.mouse.tapBehavior" = 1; # Tap to click
      "com.apple.sound.beep.volume" = 0.0; # Disable system beep
    };
  };

  # Keyboard shortcuts and key remapping
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # This value determines the nix-darwin release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = 5;
}
