{ config, pkgs, lib, username, userFullName, userEmail, ... }:

{
  # Linux platform system defaults (can be overridden by machine-specific configs)

  # Default user configuration for Linux systems
  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Default Linux services
  services = {
    # Audio
    pulseaudio.enable = false;
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };

    # Bluetooth support
    blueman.enable = lib.mkDefault true;

    # Printing support
    printing.enable = lib.mkDefault true;
  };

  # Security defaults
  security.rtkit.enable = lib.mkDefault true;

  # Default system state version for Linux (can be overridden per machine)
  system.stateVersion = lib.mkDefault "25.05";
}
