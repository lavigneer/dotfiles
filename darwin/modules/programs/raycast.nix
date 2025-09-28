{ config, pkgs, lib, ... }:

{
  # Karabiner-Elements key remapping tool for macOS
  home.packages = with pkgs; [
    raycast
  ];
}
