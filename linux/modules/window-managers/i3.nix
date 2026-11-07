{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.windowManagers.i3;
  common = config.windowManagers.tiling;
in
{
  imports = [
    ./x11.nix
    ./tiling-common.nix
  ];

  options.windowManagers.i3 = {
    enable = lib.mkEnableOption "Enable i3 window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      i3lock
      dmenu
    ];

    xsession.windowManager.i3 = {
      enable = true;
      config = {
        # Modifier, terminal, menu, extra keys and focus are shared with Sway
        inherit (common)
          modifier
          terminal
          menu
          focus
          ;
        keybindings = lib.mkOptionDefault common.keybindings;

        # Shared i3status-rust bar (see ../system/status-bar.nix), themed by Stylix
        bars = [ (config.windowManagers.statusBar // config.stylix.targets.i3.exportedBarConfig) ];

        # Screen locking is handled by services.screen-locker (x11.nix)
        startup = [
          {
            command = "dex --autostart --environment i3";
            notification = false;
          }
          {
            command = "nm-applet";
            notification = false;
          }
        ];
      };
    };
  };
}
