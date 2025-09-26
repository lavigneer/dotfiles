{ config, pkgs, lib, username, userFullName, userEmail, ... }:

{
  # Linux platform defaults (can be overridden by machine-specific configs)
  
  # Default user configuration for Linux systems
  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Default Linux system packages (minimal - most via Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential Linux system tools
    wget
    unzip
    xss-lock
    gcc  # Common development dependency on Linux
  ];

  # Default Linux services
  services = {
    # Audio (PipeWire is the modern default for Linux)
    pulseaudio.enable = false;
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };
    
    # Bluetooth support (common on Linux desktops)
    blueman.enable = lib.mkDefault true;
    
    # Printing support (common need)
    printing.enable = lib.mkDefault true;
  };

  # Security defaults for Linux
  security.rtkit.enable = lib.mkDefault true;

  # Default Stylix theming for Linux
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  # Default system state version for Linux (can be overridden per machine)
  system.stateVersion = lib.mkDefault "25.05";

  # ===== HOME MANAGER CONFIGURATION =====
  # Linux Home Manager defaults (integrated into platform config)
  
  home-manager.users.${username} = { config, pkgs, ... }: {
    imports = [
      # Shared Home Manager configurations
      ../shared/home-manager
      
      # Linux-specific window managers
      ./window-managers.nix
    ];

    # Linux-specific Home Manager configuration

    # Window manager configuration - enable the ones you want to use
    windowManagers = {
      i3.enable = lib.mkDefault true;           # Enable i3
      sway.enable = lib.mkDefault true;         # Enable Sway  
      hyprland.enable = lib.mkDefault true;    # Enable Hyprland
    };

    # Linux-specific packages (non-window manager specific)
    home.packages = with pkgs; [
      # Linux desktop applications
      discord
      google-chrome
      lutris
      pavucontrol
      solaar
      nil # Nix LSP
    ];

    # Linux-specific programs (non-window manager specific)
    programs = {
      # Email (Linux only for now)
      thunderbird = {
        enable = true;
        profiles = {
          gmail.isDefault = true;
          hotmail.isDefault = false;
        };
      };
    };

    # Linux-specific environment variables
    home.sessionVariables = {
      BROWSER = "google-chrome";
    };

    # Linux-specific git configuration
    programs.git = {
      userEmail = userEmail;
    };

    # Email accounts (Linux specific for thunderbird)
    accounts.email.accounts = {
      "Hotmail" = {
        primary = true;
        address = userEmail;
        userName = userEmail;
        realName = userFullName;
        thunderbird = {
          enable = true;
          settings = id: {
            "mail.server.server_${id}.authMethod" = 10;
            "mail.smtpserver.smtp_${id}.authMethod" = 10;
          };
        };
        imap = {
          authentication = "xoauth2";
          host = "outlook.office365.com";
          port = 993;
          tls.enable = true;
        };
      };
    };
  };
}