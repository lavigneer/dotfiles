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
      rofi # launcher with Wayland support (v2.0.0+)
      polybar # status bar (works on Wayland via XWayland)
      grim # screenshot utility
      slurp # select region for screenshot
      kanshi # display management
      # Using Ghostty as terminal (configured in shared terminals.nix)
      wf-recorder # screen recording
    ];

    # Hyprland configuration
    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        # Basic hyprland config - detailed config comes from external file
        "$terminal" = "ghostty";
        "$menu" = "rofi -show drun";
      };
      extraConfig = ''
        source = ~/.config/hypr/hyprland.conf
      '';
    };

    # Hyprland-related XDG config files
    xdg.configFile = {
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr/.config/hypr";
      "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
      "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
      "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
      # foot config removed - using Ghostty as terminal
    };

    # Hyprland-related programs
    programs = {
      rofi.enable = true;
      # foot.enable removed - using Ghostty as terminal
    };

    # Hyprland-related services
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
