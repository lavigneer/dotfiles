{ config, pkgs, lib, ... }:

{
  # Linux-specific desktop applications
  home.packages = with pkgs; [
    pavucontrol   # PulseAudio volume control (Linux audio)
    solaar        # Logitech device manager (more useful on Linux desktops)
  ];
}
