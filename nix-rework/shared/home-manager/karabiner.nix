{ config, pkgs, lib, ... }:

let
  # Only apply this configuration on macOS
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  config = lib.mkIf isDarwin {
    # Karabiner-Elements key remapping tool for macOS
    home.packages = with pkgs; [
     karabiner-elements
    ];

    # Karabiner-Elements configuration
    xdg.configFile = {
      "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner/.config/karabiner";
    };
  };
}
