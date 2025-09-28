{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs = {
    ghostty = {
      # Only enable native Ghostty on non-Darwin systems
      enable = !isDarwin;
      enableZshIntegration = !isDarwin;
      settings = lib.mkIf (!isDarwin) {
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
        window-opacity = 0.95;
        confirm-close-surface = false;
      };
    };
  };

  # On macOS, install Ghostty via Homebrew and configure manually
  home = lib.mkIf isDarwin {
    # Create Ghostty config file manually on macOS
    file.".config/ghostty/config".text = ''
      font-family = JetBrainsMono Nerd Font
      font-size = 14
      confirm-close-surface = false
    '';
  };

  # Note: Homebrew cask installation is handled at the system level
  # See: darwin/modules/programs/terminals.nix for macOS Homebrew setup
}
