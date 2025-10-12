{ config, pkgs, lib, ... }:

{
  # System-level gaming configuration for Linux

  # Steam configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # Additional Steam configuration
    gamescopeSession.enable = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # Gaming-related system packages
  environment.systemPackages = with pkgs; [
    steam
    steam-run
    steam-unwrapped
  ];

  # Gaming-related hardware support
  hardware = {
    # Enable 32-bit support for games
    graphics.enable32Bit = true;

    # Pulseaudio 32-bit support (if using PulseAudio)
    # pulseaudio.support32Bit = true;
  };
}
