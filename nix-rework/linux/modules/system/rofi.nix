{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  home.packages = with pkgs; [
    rofi
  ];

  xdg.configFile = {
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
  };

  programs.rofi.enable = true;
}
