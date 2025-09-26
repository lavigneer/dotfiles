{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  home.packages = with pkgs; [
    polybar
  ];

  xdg.configFile = {
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
  };

  services.polybar = {
    enable = true;
    config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
    script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
  };
}
