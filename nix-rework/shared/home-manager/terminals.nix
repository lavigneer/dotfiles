{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs = {
    ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        font-family = "JetBrainsMono Nerd Font";
        font-size = if isDarwin then 14 else 12;
        theme = "base16";
        window-opacity = 0.95;
        confirm-close-surface = false;
      };
    };
  };
}
