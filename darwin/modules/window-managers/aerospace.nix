{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.windowManagers.aerospace;
in
{
  options.windowManagers.aerospace = {
    enable = lib.mkEnableOption "Enable AeroSpace window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # AeroSpace tiling window manager for macOS with native configuration
    programs.aerospace = {
      enable = true;
      userSettings = {
        # Disable normalizations (i3-like behavior)
        enable-normalization-flatten-containers = false;
        enable-normalization-opposite-orientation-for-nested-containers = false;

        on-focused-monitor-changed = [ ];

        # macOS app behavior
        automatically-unhide-macos-hidden-apps = false;

        # Startup behavior
        start-at-login = true;

        mode.main.binding = {
          # Terminal launcher
          alt-enter = "exec-and-forget open -a \"Ghostty\" -n";

          # Window management
          alt-shift-q = "close --quit-if-last-window";

          # Focus navigation (i3-like with wrap-around)
          alt-j = "focus --boundaries-action wrap-around-the-workspace left";
          alt-k = "focus --boundaries-action wrap-around-the-workspace down";
          alt-l = "focus --boundaries-action wrap-around-the-workspace up";
          alt-semicolon = "focus --boundaries-action wrap-around-the-workspace right";

          # Window movement
          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          # Layout controls
          alt-b = "split horizontal";
          alt-v = "split vertical";
          alt-f = "fullscreen";
          alt-w = "layout h_accordion";
          alt-e = "layout tiles horizontal vertical";
          alt-shift-space = "layout floating tiling";

          # Workspace switching
          alt-1 = "workspace 1";
          alt-2 = "workspace 2";
          alt-3 = "workspace 3";
          alt-4 = "workspace 4";
          alt-5 = "workspace 5";
          alt-6 = "workspace 6";
          alt-7 = "workspace 7";
          alt-8 = "workspace 8";
          alt-9 = "workspace 9";
          alt-0 = "workspace 10";

          # Move window to workspace
          alt-shift-1 = "move-node-to-workspace 1";
          alt-shift-2 = "move-node-to-workspace 2";
          alt-shift-3 = "move-node-to-workspace 3";
          alt-shift-4 = "move-node-to-workspace 4";
          alt-shift-5 = "move-node-to-workspace 5";
          alt-shift-6 = "move-node-to-workspace 6";
          alt-shift-7 = "move-node-to-workspace 7";
          alt-shift-8 = "move-node-to-workspace 8";
          alt-shift-9 = "move-node-to-workspace 9";
          alt-shift-0 = "move-node-to-workspace 10";

          # Config management
          alt-shift-c = "reload-config";

          # Monitor workspace movement
          alt-shift-period = "move-workspace-to-monitor next";
          alt-shift-comma = "move-workspace-to-monitor prev";

          # Enter resize mode
          alt-r = "mode resize";
        };

        mode.resize.binding = {
          h = "resize width -50";
          j = "resize height +50";
          k = "resize height -50";
          l = "resize width +50";
          enter = "mode main";
          esc = "mode main";
        };

        workspace-to-monitor-force-assignment = {
          "1" = [
            "LS32R75"
            "SAMSUNG"
            "main"
          ];
          "2" = [
            "^BenQ"
            "SAMSUNG"
            "main"
          ];
          "3" = "built-in";
        };
      };
    };
  };
}
