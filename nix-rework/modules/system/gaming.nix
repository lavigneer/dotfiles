{ config, pkgs, lib, ... }:

let
  # Check if we're on a system that supports gaming (primarily Linux)
  isLinux = !pkgs.stdenv.hostPlatform.isDarwin;
in
{
  config = lib.mkIf isLinux {
    # Steam configuration
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      
      # Additional Steam configuration
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    # Gaming-related packages (system-level required)
    environment.systemPackages = with pkgs; [
      steam
      steam-run
      steam-unwrapped
      
      # Additional gaming tools can be added here
      # gamemode
      # mangohud
    ];

    # Gaming-related hardware support
    hardware = {
      # Enable 32-bit support for games
      graphics.enable32Bit = true;
      
      # Pulseaudio 32-bit support (if using PulseAudio)
      # pulseaudio.support32Bit = true;
    };
  };
}
