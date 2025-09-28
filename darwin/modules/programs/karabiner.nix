{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Karabiner-Elements key remapping tool for macOS
  home.packages = with pkgs; [
    karabiner-elements
  ];

  # Karabiner-Elements configuration
  xdg.configFile = {
    "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/darwin/config/karabiner.json";
  };
}
