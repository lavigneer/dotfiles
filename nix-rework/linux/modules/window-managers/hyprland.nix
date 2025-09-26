{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.hyprland;
in
{
  imports = [
    # Import shared Wayland components
    ./wayland.nix
  ];

  options.windowManagers.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # Hyprland-specific packages (shared Wayland components imported above)
    home.packages = with pkgs; [
      hyprland
      hyprpaper # wallpaper daemon
      hypridle # idle daemon
      hyprlock # screen locker
      # Common Wayland components (mako, rofi, polybar, grim, slurp, kanshi) 
      # are now provided by linux/modules/wayland.nix
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

    # Hyprland-specific XDG config files (common Wayland configs in linux/modules/wayland.nix)
    xdg.configFile = {
      "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr/.config/hypr";
      # Common configs (polybar, rofi, kanshi) are now in wayland.nix
    };

    # Hyprland-specific programs (common Wayland programs in linux/modules/wayland.nix)
    # Note: rofi, polybar services are handled by wayland.nix

    # Hyprland-specific services (common Wayland services in linux/modules/wayland.nix)
    services = {
      # Common services (polybar, mako, kanshi) are now in wayland.nix
      
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
