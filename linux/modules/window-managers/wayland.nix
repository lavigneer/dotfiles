{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    grim
    slurp
    wl-clipboard
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
