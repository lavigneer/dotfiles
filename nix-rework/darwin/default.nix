{ config, pkgs, lib, username, userFullName, userEmail, ... }:

{
  # macOS platform defaults (can be overridden by machine-specific configs)
  
  # Default user configuration for macOS systems
  users.users.${username} = {
    name = username;
    fullName = userFullName;
    home = "/Users/${username}";
  };

  # Default macOS system packages (minimal - most via Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential macOS system tools
    vim
  ];

  # Default macOS services
  services = {
    nix-daemon.enable = true;
  };

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
    };
    
    NSGlobalDomain = {
      AppleKeyboardUIMode = lib.mkDefault 3;
      AppleShowAllExtensions = lib.mkDefault true;
      AppleInterfaceStyle = lib.mkDefault "Dark";
      "com.apple.sound.beep.feedback" = lib.mkDefault 0;
    };
    
    trackpad = {
      Clicking = lib.mkDefault true;
      TrackpadRightClick = lib.mkDefault true;
    };
  };

  # Default keyboard settings
  system.keyboard = {
    enableKeyMapping = lib.mkDefault true;
    remapCapsLockToEscape = lib.mkDefault true;
  };

  # Default Stylix theming for macOS
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  # Default system state version for macOS (can be overridden per machine)
  system.stateVersion = lib.mkDefault 5;

  # ===== HOME MANAGER CONFIGURATION =====
  # macOS Home Manager defaults (integrated into platform config)
  
  home-manager.users.${username} = { config, pkgs, ... }: {
    imports = [
      # Shared Home Manager configurations
      ../shared/home-manager
      
      # macOS-specific window managers
      ./window-managers.nix
      
      # macOS-specific programs
      ./programs/karabiner.nix
      ./programs/darwin.nix
    ];

    # macOS-specific Home Manager configuration

    # Enable macOS window manager
    windowManagers = {
      aerospace.enable = lib.mkDefault true;  # Enable AeroSpace tiling window manager
    };

    # macOS-specific packages
    home.packages = with pkgs; [
      # macOS-specific packages
      mas # Mac App Store CLI
      
      # macOS development tools
      darwin.cctools
    ];

    # macOS-specific environment variables
    home.sessionVariables = {
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
  };
}