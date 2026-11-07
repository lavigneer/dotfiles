{
  config,
  pkgs,
  lib,
  ...
}:

# Settings shared by i3 (X11) and Sway (Wayland) so both sessions behave the same.
#
# `windowManagers.tiling` holds config values that i3.nix and sway.nix plug into
# their `config` blocks. Keybindings are merged on top of Home Manager's
# defaults (workspaces, focus/move, layouts, resize mode, ...) via
# lib.mkOptionDefault, so only additions live here. Mod+Return and Mod+d use
# `terminal` and `menu`.

let
  anyEnabled =
    (config.windowManagers.i3.enable or false) || (config.windowManagers.sway.enable or false);
in
{
  imports = [
    ../system/status-bar.nix
    ../system/rofi.nix
  ];

  options.windowManagers.tiling = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = "Config shared by the i3 and Sway modules.";
  };

  config = lib.mkMerge [
    {
      windowManagers.tiling = {
        # Super/Windows key
        modifier = "Mod4";

        # Follows $TERMINAL (ghostty by default, herdr-app where herdr-desktop.nix is imported)
        terminal = config.home.sessionVariables.TERMINAL;
        menu = "\"zsh -c 'rofi -show combi -modes combi'\"";

        # Added to the Home Manager default keybindings
        keybindings = {
          "XF86AudioRaiseVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10%";
          "XF86AudioLowerVolume" = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10%";
          "XF86AudioMute" = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle";
        };

        # Defaults are followMouse = true, mouseWarping = "output"
        focus = {
          followMouse = false;
          mouseWarping = false;
        };
      };
    }

    (lib.mkIf anyEnabled {
      home.packages = with pkgs; [
        dex # XDG autostart
        networkmanagerapplet # nm-applet
        pulseaudio # pactl, for the volume keys (talks to PipeWire)
      ];

      # Night light. Unlike redshift (X11 only) gammastep auto-detects the
      # backend: randr under i3, wlr-gamma-control under Sway.
      services.gammastep = {
        enable = true;
        latitude = 53.5461;
        longitude = -113.4938;
        settings.general.gamma = 0.8;
      };
    })
  ];
}
