{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    dunst
    feh
    xss-lock
    xclip
    xorg.xrandr
    xorg.xset
  ];

  services = {
    dunst.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = lib.mkDefault "X11";
  };

  xsession = {
    enable = true;
    profileExtra = "export TERMINAL=ghostty";
  };
}
