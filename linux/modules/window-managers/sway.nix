{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.windowManagers.sway;
  common = config.windowManagers.tiling;
in
{
  imports = [
    ./wayland.nix
    ./tiling-common.nix
  ];

  options.windowManagers.sway = {
    enable = lib.mkEnableOption "Enable Sway window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swaylock
      swayidle
    ];

    wayland.windowManager.sway = {
      enable = true;
      # Use the system sway from NixOS `programs.sway` (it carries host-specific
      # flags like --unsupported-gpu); Home Manager only manages the config.
      package = null;
      config = {
        # Modifier, terminal, menu, extra keys and focus are shared with i3
        inherit (common)
          modifier
          terminal
          menu
          focus
          ;
        keybindings = lib.mkOptionDefault common.keybindings;

        # Shared i3status-rust bar (see ../system/status-bar.nix), themed by Stylix
        bars = [ (config.windowManagers.statusBar // config.stylix.targets.sway.exportedBarConfig) ];

        # Same startup apps as i3. Locking is handled by swayidle below.
        startup = [
          { command = "dex --autostart --environment sway"; }
          # --indicator makes nm-applet use the StatusNotifier tray swaybar supports
          { command = "nm-applet --indicator"; }
        ];
      };
    };

    services.swayidle = {
      enable = true;
      # Only run in Sway, not in the i3 session (which also starts graphical-session.target)
      systemdTargets = [ "sway-session.target" ];
      # Lock before suspend, like xss-lock does under i3
      events.before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
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
