{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared X11 components for i3 and other X11 window managers
  # This module provides common packages, services, and configurations
  
  # Common X11 packages
  home.packages = with pkgs; [
    # Core shared components (also used on Wayland)
    rofi # launcher
    polybar # status bar
    
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

  # Common X11 config files
  xdg.configFile = {
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
  };

  # Common X11 programs
  programs = {
    rofi.enable = true;
    # Note: polybar is managed via services, not programs
  };

  # Common X11 services
  services = {
    # Polybar status bar
    polybar = {
      enable = true;
      config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
      script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
    };

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
