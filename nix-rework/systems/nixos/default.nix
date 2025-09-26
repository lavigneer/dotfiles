{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 60d";
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Locale and timezone
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";

  # Display and desktop
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.gnome.gnome-keyring.enable = true;
  
  # i3 window manager
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [ dmenu i3status i3lock ];
  };
  services.displayManager.defaultSession = "none+i3";
  security.pam.services.i3lock.enable = true;

  # Bluetooth
  services.blueman.enable = true;

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    description = "Eric Lavigne";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Gaming configuration moved to modules/system/gaming.nix

  # System packages (keep minimal, move user packages to Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential system tools (minimal - most packages in Home Manager)
    wget
    unzip
    xss-lock
    
    # Development essentials
    gcc
    
    # Gaming packages moved to modules/system/gaming.nix
  ];

  # Stylix theming
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  # Shell configuration moved to modules/system/shell.nix

  # Fonts configuration moved to modules/system/fonts.nix

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken.
  system.stateVersion = "25.05";
}
