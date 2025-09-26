{ config, pkgs, lib, ... }:

let
  # Only apply this configuration on macOS
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  options.windowManagers.aerospace = {
    enable = lib.mkEnableOption "Enable AeroSpace window manager configuration";
  };

  config = lib.mkIf (isDarwin && config.windowManagers.aerospace.enable) {
    # AeroSpace tiling window manager for macOS
    home.packages = with pkgs; [
      # Note: aerospace may not be available in nixpkgs
      # Typically installed via Homebrew: brew install nikitabobko/tap/aerospace
      aerospace
    ];

    # AeroSpace configuration
    xdg.configFile = {
      "aerospace".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aerospace/.config/aerospace";
    };
  };
}
