{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Shared Wayland components for Sway, Hyprland, and other Wayland compositors
  # This module provides common packages, services, and configurations
  
  # Common Wayland packages
  home.packages = with pkgs; [
    # Core shared components (also used on X11)
    rofi # launcher with Wayland support (v2.0.0+)
    polybar # status bar (works on Wayland via XWayland)
    
    # Wayland-specific components
    mako # notification daemon for wayland
    grim # screenshot utility
    slurp # select region for screenshot
    kanshi # display management
    
    # Optional but commonly useful on Wayland
    wl-clipboard # clipboard utilities (also in neovim.nix but useful here)
  ];

  # Common Wayland config files
  xdg.configFile = {
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
    "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
    # Note: mako config can be added here if you want to manage it via dotfiles
  };

  # Common Wayland programs
  programs = {
    rofi.enable = true;
    # Note: polybar is managed via services, not programs
  };

  # Common Wayland services
  services = {
    # Polybar status bar (works on Wayland via XWayland)
    polybar = {
      enable = true;
      config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
      script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
    };

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
