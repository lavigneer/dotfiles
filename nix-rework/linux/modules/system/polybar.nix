{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared Polybar configuration for all window managers
  # Works on both X11 and Wayland (via XWayland)
  
  # Polybar package
  home.packages = with pkgs; [
    polybar # status bar (works on X11 and Wayland via XWayland)
  ];

  # Polybar config files
  xdg.configFile = {
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
  };

  # Polybar service
  services = {
    polybar = {
      enable = true;
      config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
      script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
    };
  };
}
