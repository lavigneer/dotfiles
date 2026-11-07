{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = with pkgs; [
    dunst
    feh
    xss-lock
    xclip
    xrandr
    xset
  ];

  services = {
    dunst.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
    };
  };

  # The X11 lockers only make sense in an X session. Bind them to the target
  # that ~/.hm-xsession starts, instead of graphical-session.target (which Sway
  # also starts), so they don't run under Wayland.
  systemd.user.services =
    let
      xOnly = {
        Unit = {
          After = lib.mkForce [ "hm-graphical-session.target" ];
          PartOf = lib.mkForce [ "hm-graphical-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hm-graphical-session.target" ];
      };
    in
    lib.mkMerge [
      { xss-lock = xOnly; }
      (lib.mkIf config.services.screen-locker.xautolock.enable { xautolock-session = xOnly; })
    ];

  xsession = {
    enable = true;
    # Launched by the display manager session defined in the NixOS host config
    scriptPath = ".hm-xsession";
  };
}
