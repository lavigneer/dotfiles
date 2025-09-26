{ config, pkgs, lib, ... }:

{
  imports = [
    ./i3.nix
    ./sway.nix
    ./hyprland.nix
  ];

  # Common window manager packages that work across all WMs
  home.packages = with pkgs; [
    # Common utilities (clipboard tools moved to neovim module where they're actually needed)
    
    # Screen capture
    grim # Wayland screenshots
    slurp # Wayland region selection
    flameshot # X11 screenshots (works with XWayland)
    
    # File manager
    xfce.thunar # GUI file manager
    
    # Image viewers
    feh # X11 image viewer
    imv # Wayland image viewer
    
    # Terminal emulators (additional options)
    foot # Fast wayland terminal
    
    # Network management
    networkmanagerapplet
    
    # Bluetooth
    blueman
  ];

  # Common services that work across window managers
  services = {
    # GPG agent
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    # SSH agent
    ssh-agent.enable = true;
    
    # Syncthing (file synchronization)
    syncthing.enable = true;
  };

  # Common programs
  programs = {
    # Add any programs that work across all window managers
  };
}
