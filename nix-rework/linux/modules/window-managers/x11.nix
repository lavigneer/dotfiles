{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared X11 components for i3 and other X11 window managers
  # This module provides common packages, services, and configurations
  
  # X11-specific packages (rofi and polybar now in dedicated system modules)
  home.packages = with pkgs; [
    # X11-specific components
    dunst # notification daemon for X11
    picom # compositor for X11
    feh # wallpaper setter
    xss-lock # X11 screen locker utility
    
    # X11 utilities
    xclip # clipboard utilities for X11
    xorg.xrandr # display management
    xorg.xset # X11 settings
  ];

  # X11-specific config files (rofi and polybar now in dedicated system modules)
  xdg.configFile = {
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
  };

  # X11-specific services (rofi and polybar now in dedicated system modules)
  services = {
    # Dunst notification daemon
    dunst = {
      enable = true;
      # Configuration will come from dotfiles if needed
    };
    
    # Picom compositor
    picom = {
      enable = true;
      # Configuration comes from dotfiles symlink above
      # You can add specific settings here or manage via dotfiles
    };

    # Screen locker
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
      xautolock = {
        enable = true;
        time = 10; # minutes
      };
    };
  };

  # Common X11 environment variables
  home.sessionVariables = {
    # X11-specific variables
    XDG_CURRENT_DESKTOP = "X11";
  };

  # X11 session configuration
  xsession = {
    enable = true;
    profileExtra = "export TERMINAL=ghostty";
  };
}
