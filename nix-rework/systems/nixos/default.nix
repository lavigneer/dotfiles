{ config, pkgs, inputs, username, ... }:

{
  imports = [
    # Hardware-specific configuration for this machine
    ./hardware-configuration.nix
  ];

  # ===== HOME MANAGER MODULE IMPORTS =====
  # This system imports specific program and window manager modules
  home-manager.users.${username} = {
    imports = [
      # Linux programs this system wants
      ../../linux/modules/programs/desktop-apps.nix
      ../../linux/modules/programs/email.nix
      ../../linux/modules/programs/development.nix
      ../../linux/modules/programs/git.nix
      
      # Linux window managers this system wants  
      ../../linux/modules/window-managers/i3.nix
      ../../linux/modules/window-managers/sway.nix
      ../../linux/modules/window-managers/hyprland.nix
    ];

    # Enable specific window managers for this system
    windowManagers = {
      i3.enable = true;           # Enable i3
      sway.enable = true;         # Enable Sway  
      hyprland.enable = true;     # Enable Hyprland
    };
  };

  # Machine-specific configuration for this particular NixOS system

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking configuration
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time zone and locale (machine-specific)
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_CA.UTF-8";
    LC_IDENTIFICATION = "en_CA.UTF-8";
    LC_MEASUREMENT = "en_CA.UTF-8";
    LC_MONETARY = "en_CA.UTF-8";
    LC_NAME = "en_CA.UTF-8";
    LC_NUMERIC = "en_CA.UTF-8";
    LC_PAPER = "en_CA.UTF-8";
    LC_TELEPHONE = "en_CA.UTF-8";
    LC_TIME = "en_CA.UTF-8";
  };

  # X11 and desktop environment (machine-specific choice)
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    # Window managers are configured via Home Manager
    windowManager.i3.enable = true;
    
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Audio configuration
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Machine-specific services
  services = {
    # Enable OpenSSH daemon for this machine
    openssh.enable = true;
    
    # Enable CUPS to print documents on this machine
    printing.enable = true;
  };

  # Machine-specific system packages (minimal - most packages via Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential system tools for this machine
    wget
    curl
  ];

  # Machine-specific garbage collection settings (can override platform defaults)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";  # More aggressive on this machine
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. Don't change this after initial setup.
  system.stateVersion = "25.05";
}