{ config, pkgs, lib, ... }:

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
        # Only override non-default settings
        
        # Disable normalizations (these are false by default, but kept for clarity)
        enable-normalization-flatten-containers = false;
        enable-normalization-opposite-orientation-for-nested-containers = false;

        # Custom startup behavior (default is false)
        start-at-login = true;

        mode.main.binding = {
          # Custom terminal launcher (override default)
          alt-enter = "exec-and-forget open -a \"Ghostty\" -n";

          # Custom monitor workspace movement (non-default keybindings)
          alt-shift-period = "move-workspace-to-monitor next";
          alt-shift-comma = "move-workspace-to-monitor prev";
        };

        # Note: resize mode bindings are likely defaults in AeroSpace
        # Keeping only if they differ from standard hjkl+enter/esc defaults

        workspace-to-monitor-force-assignment = {
          "1" = ["LS32R75" "SAMSUNG" "main"];
          "2" = ["^BenQ" "SAMSUNG" "main"];
          "3" = "built-in";
        };
      };
    };
  };
}
