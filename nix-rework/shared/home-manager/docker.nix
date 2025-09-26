{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  xdg.configFile = {
    "lazydocker".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazydocker/.config/lazydocker";
  };
}
