{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Docker-related tools and configurations
  
  # LazyDocker configuration
  xdg.configFile = {
    "lazydocker".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazydocker/.config/lazydocker";
  };
}
