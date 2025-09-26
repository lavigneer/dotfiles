{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.sway;
in
{
  options.windowManagers.sway = {
    enable = lib.mkEnableOption "Enable Sway window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # Sway-specific packages
    home.packages = with pkgs; [
      sway
      swaylock
      swayidle
      wl-clipboard
      mako # notification daemon for wayland
      wofi # rofi alternative for wayland
      waybar
      grim # screenshot utility
      slurp # select region for screenshot
      kanshi # display management
      foot # terminal (wayland native)
    ];

    # Sway configuration
    wayland.windowManager.sway = {
      enable = true;
      config = {
        # Basic sway config - detailed config comes from external file
        terminal = "ghostty";
        menu = "wofi --show drun";
      };
      extraConfig = ''
        include ~/.config/sway/config
      '';
    };

    # Sway-related XDG config files
    xdg.configFile = {
      "sway".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/sway/.config/sway";
      "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar/.config/waybar";
      "wofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wofi/.config/wofi";
      "foot".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
      "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
    };

    # Sway-related programs
    programs = {
      waybar.enable = true;
      foot.enable = true;
    };

    # Sway-related services
    services = {
      # Mako notification daemon
      mako = {
        enable = true;
        # Configuration will come from dotfiles if needed
      };
      
      # Kanshi display management
      kanshi.enable = true;
      
      # Swayidle
      swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 600;
            command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
            resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
          }
        ];
      };
    };
  };
}
