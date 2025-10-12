{ config, pkgs, lib, ... }:

let
  cfg = config.windowManagers.i3;
in
{
  imports = [
    ./x11.nix
    ../system/polybar.nix
    ../system/rofi.nix
  ];

  options.windowManagers.i3 = {
    enable = lib.mkEnableOption "Enable i3 window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      i3status
      i3lock
      dmenu
    ];

    xsession.windowManager.i3 = {
      enable = true;
      config = {
        # Use Super/Windows key instead of Alt
        modifier = "Mod4";

        # Disable bars since we use polybar
        bars = [ ];

        # Only override specific keybindings we want to customize
        keybindings = let modifier = "Mod4"; in {
          # Custom launcher (override default dmenu)
          "${modifier}+d" = "exec \"zsh -c 'rofi -show combi -modes combi'\"";
          # Custom terminal (override default)
          "${modifier}+Return" = "exec ghostty";

          # Volume keys (not in i3 defaults)
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };

        # Custom startup programs
        startup = [
          { command = "dex --autostart --environment i3"; notification = false; }
          { command = "xss-lock --transfer-sleep-lock -- i3lock --nofork"; notification = false; }
          { command = "nm-applet"; notification = false; }
          { command = "polybar main"; notification = false; }
        ];

        # Custom focus behavior (defaults are followMouse = true, mouseWarping = "output")
        focus = {
          followMouse = false;
          mouseWarping = false;
        };
      };
    };

    services.redshift = {
      enable = true;
      latitude = 53.5461;
      longitude = -113.4938;
      settings = {
        redshift = {
          adjustment-method = "randr";
          gamma = 0.8;
        };
        randr = {
          screen = 0;
        };
      };
    };
  };
}
