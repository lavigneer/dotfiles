{
  config,
  pkgs,
  lib,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs = {
    ghostty = {
      # Only enable native Ghostty on non-Darwin systems
      enable = true;
      enableZshIntegration = true;
      package = if isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = if isDarwin then 14 else 12;
        confirm-close-surface = false;
        window-decoration = false;
        gtk-single-instance = true;

        mouse-scroll-multiplier = 0.5;

        macos-secure-input-indication = true;
        macos-option-as-alt = true;
        macos-non-native-fullscreen = "visible-menu";

        adjust-cell-height = 4;

        cursor-style = "block";
        shell-integration-features = "no-cursor";
      };
    };
  };
}
