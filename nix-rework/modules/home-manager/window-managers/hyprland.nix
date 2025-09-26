{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.hyprland;
in
{
  options.windowManagers.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # Hyprland-specific packages
    home.packages = with pkgs; [
      hyprland
      hyprpaper # wallpaper daemon
      hypridle # idle daemon
      hyprlock # screen locker
      # wl-clipboard managed by neovim module
      mako # notification daemon for wayland
      wofi # launcher
      waybar
      grim # screenshot utility
      slurp # select region for screenshot
      kanshi # display management
      foot # terminal (wayland native)
      wf-recorder # screen recording
    ];

    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Basic hyprland config - detailed config comes from external file
        "$terminal" = "ghostty";
        "$menu" = "wofi --show drun";
      };
      extraConfig = ''
        source = ~/.config/hypr/hyprland.conf
      '';
    };

    # Hyprland-related XDG config files
    xdg.configFile = {
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr/.config/hypr";
      "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar/.config/waybar";
      "wofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wofi/.config/wofi";
      "foot".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
      "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
    };

    # Hyprland-related programs
    programs = {
      waybar.enable = true;
      foot.enable = true;
    };

    # Hyprland-related services
    services = {
      # Mako notification daemon
      mako = {
        enable = true;
        # Configuration will come from dotfiles if needed
      };
      
      # Kanshi display management
      kanshi.enable = true;
      
      # Hypridle (replaces swayidle for hyprland)
      hypridle = {
        enable = true;
        settings = {
          general = {
            after_sleep_cmd = "hyprctl dispatch dpms on";
            before_sleep_cmd = "hyprlock";
            ignore_dbus_inhibit = false;
            lock_cmd = "hyprlock";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "hyprlock";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };
    };
  };
}
