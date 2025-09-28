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
      window-decoration=false
      confirm-close-surface=false
      gtk-single-instance=true

      mouse-scroll-multiplier=0.5

      macos-secure-input-indication=true
      macos-option-as-alt=true
      macos-non-native-fullscreen=true

      font-size=14
      adjust-cell-height=4

      cursor-style=block
      shell-integration-features=no-cursor
    '';
  };

  # Note: Homebrew cask installation is handled at the system level
  # See: darwin/modules/programs/terminals.nix for macOS Homebrew setup
}
