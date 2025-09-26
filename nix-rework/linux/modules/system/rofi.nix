{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared Rofi configuration for all window managers
  # Works on both X11 and Wayland (v2.0.0+ has native Wayland support)
  
  # Rofi package
  home.packages = with pkgs; [
    rofi # launcher with X11 and Wayland support (v2.0.0+)
  ];

  # Rofi config files
  xdg.configFile = {
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
  };

  # Rofi program configuration
  programs = {
    rofi.enable = true;
  };
}
