{
  config,
  pkgs,
  lib,
  ...
}:

# Shared status bar for i3 (i3bar) and Sway (swaybar).
#
# Both bars speak the same i3bar protocol, so a single i3status-rust config
# drives the status line in either session. Workspaces, binding mode and the
# system tray are handled natively by i3bar/swaybar. Colors and fonts come from
# Stylix (see stylix.targets.{i3,sway}.exportedBarConfig and
# config.lib.stylix.i3status-rust.bar).

{
  options.windowManagers.statusBar = lib.mkOption {
    type = lib.types.attrs;
    readOnly = true;
    description = ''
      Bar settings shared by i3 and Sway. Use as an entry in
      `xsession.windowManager.i3.config.bars` or
      `wayland.windowManager.sway.config.bars`, merged with the matching
      `stylix.targets.<wm>.exportedBarConfig`.
    '';
  };

  config = {
    windowManagers.statusBar = {
      position = "top";
      statusCommand = "${config.programs.i3status-rust.package}/bin/i3status-rs ${config.xdg.configHome}/i3status-rust/config-default.toml";
    };

    programs.i3status-rust = {
      enable = true;
      bars.default = {
        icons = "material-nf"; # Nerd Font glyphs (JetBrains Mono Nerd Font is installed)

        settings.theme = {
          theme = "plain";
          overrides = config.lib.stylix.i3status-rust.bar;
        };

        blocks = [
          {
            block = "cpu";
            interval = 2;
          }
          {
            block = "memory";
            format = " $icon $mem_used_percents ";
          }
          {
            block = "disk_space";
            path = "/";
            info_type = "available";
            format = " $icon $available ";
          }
          {
            block = "net";
            format = " $icon {$ssid|$device} ";
          }
          {
            block = "sound";
          }
          {
            block = "time";
            interval = 5;
            format = " $icon $timestamp.datetime(f:'%a %d %b %H:%M') ";
          }
        ];
      };
    };
  };
}
