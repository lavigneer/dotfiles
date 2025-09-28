{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    mako
    grim
    slurp
    wl-clipboard
  ];

  services = {
    mako.enable = true;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
