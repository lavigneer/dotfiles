{ config, pkgs, lib, ... }:

let
  cfg = config.windowManagers.sway;
in
{
  imports = [
    ./wayland.nix
    ../system/polybar.nix
    ../system/rofi.nix
  ];

  options.windowManagers.sway = {
    enable = lib.mkEnableOption "Enable Sway window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      sway
      swaylock
      swayidle
    ];

    wayland.windowManager.sway = {
      enable = true;
      config = {
        terminal = "ghostty";
        menu = "rofi -show drun";
      };
    };

    services.swayidle = {
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
}
