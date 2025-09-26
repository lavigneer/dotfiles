{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.aerospace;
in
{
  options.windowManagers.aerospace = {
    enable = lib.mkEnableOption "Enable AeroSpace window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # AeroSpace tiling window manager for macOS
    home.packages = with pkgs; [
      aerospace
    ];

    # AeroSpace configuration
    xdg.configFile = {
      "aerospace".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aerospace/.config/aerospace";
    };
  };
}
