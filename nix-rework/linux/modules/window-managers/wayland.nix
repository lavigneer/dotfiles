{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  home.packages = with pkgs; [
    mako
    grim
    slurp
    kanshi
    wl-clipboard
  ];

  xdg.configFile = {
    "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
  };

  services = {
    mako.enable = true;
    kanshi.enable = true;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
