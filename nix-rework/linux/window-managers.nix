{ config, pkgs, lib, ... }:

let
  isLinux = !pkgs.stdenv.hostPlatform.isDarwin;
in
{
  imports = [
    # Linux-compatible window managers only
    ./i3.nix
    ./sway.nix
    ./hyprland.nix
  ];

  config = lib.mkIf isLinux {
    # Linux window manager packages
    home.packages = with pkgs; [
      # Screen capture (Linux/X11/Wayland specific)
      grim # Wayland screenshots
      slurp # Wayland region selection
      flameshot # X11 screenshots (works with XWayland)
      
      # File manager
      xfce.thunar # GUI file manager
      
      # Image viewers
      feh # X11 image viewer
      imv # Wayland image viewer
      
      # PDF viewers
      zathura
      
      # Terminal emulators (Linux-specific)
      foot # Fast wayland terminal
      
      # Network management (Linux desktop specific)
      networkmanagerapplet
      
      # Bluetooth (Linux desktop specific)
      blueman
    ];

    # Linux-specific window manager services
    services = {
      # GPG agent
      gpg-agent = {
        enable = true;
        defaultCacheTtl = 1800;
        enableSshSupport = true;
      };
      
      # SSH agent
      ssh-agent.enable = true;
    };
  };
}
