{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared Wayland components for Sway, Hyprland, and other Wayland compositors
  # This module provides common packages, services, and configurations
  
  # Wayland-specific packages (rofi and polybar now in dedicated modules)
  home.packages = with pkgs; [
    # Wayland-specific components
    mako # notification daemon for wayland
    grim # screenshot utility
    slurp # select region for screenshot
    kanshi # display management
    
    # Optional but commonly useful on Wayland
    wl-clipboard # clipboard utilities (also in neovim.nix but useful here)
  ];

  # Wayland-specific config files (rofi and polybar now in dedicated modules)
  xdg.configFile = {
    "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
    # Note: mako config can be added here if you want to manage it via dotfiles
  };

  # Wayland-specific services (rofi and polybar now in dedicated system modules)
  services = {
    # Mako notification daemon
    mako = {
      enable = true;
      # Configuration will come from dotfiles if needed
      # You can add specific settings here or manage via dotfiles
    };
    
    # Kanshi display management
    kanshi = {
      enable = true;
      # Configuration comes from dotfiles symlink above
    };
  };

  # Common Wayland environment variables
  home.sessionVariables = {
    # Ensure XDG portal uses the correct backend
    XDG_CURRENT_DESKTOP = "sway"; # or set this per WM if needed
    
    # Wayland-specific variables
    MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland support
    NIXOS_OZONE_WL = "1"; # Electron apps Wayland support
  };
}
