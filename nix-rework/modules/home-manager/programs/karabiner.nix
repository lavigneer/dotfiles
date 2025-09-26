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
      # Note: karabiner-elements may not be available in nixpkgs
      # Typically installed via Homebrew: brew install --cask karabiner-elements
      # karabiner-elements
    ];

    # Karabiner-Elements configuration
    xdg.configFile = {
      "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner/.config/karabiner";
    };

    # Optional: Homebrew installation example
    # homebrew = {
    #   casks = [ "karabiner-elements" ];
    # };
  };
}
