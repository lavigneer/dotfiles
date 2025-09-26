{ config, pkgs, inputs, username, ... }:

{
  imports = [
    # Hardware-specific configuration for this machine
    ./hardware-configuration.nix
  ];

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