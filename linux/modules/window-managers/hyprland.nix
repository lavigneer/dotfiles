{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.windowManagers.hyprland;
in
{
  imports = [
    ./wayland.nix
    ../system/polybar.nix
    ../system/rofi.nix
  ];

  options.windowManagers.hyprland = {
    enable = lib.mkEnableOption "Enable Hyprland window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprland
      hyprpaper
      hypridle
      hyprlock
      wf-recorder
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings = {
        "$terminal" = "ghostty";
        "$menu" = "rofi -show drun";
      };
    };

    services = {

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
