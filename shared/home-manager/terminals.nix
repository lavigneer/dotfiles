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

      background = ${config.lib.stylix.colors.base00}
      foreground = ${config.lib.stylix.colors.base05}
      cursor-color = ${config.lib.stylix.colors.base05}
      selection-background = ${config.lib.stylix.colors.base02}
      selection-foreground = ${config.lib.stylix.colors.base05}

      palette =0=${config.lib.stylix.colors.base00}
      palette =1=${config.lib.stylix.colors.base08}
      palette =2=${config.lib.stylix.colors.base0B}
      palette =3=${config.lib.stylix.colors.base0A}
      palette =4=${config.lib.stylix.colors.base0D}
      palette =5=${config.lib.stylix.colors.base0E}
      palette =6=${config.lib.stylix.colors.base0C}
      palette =7=${config.lib.stylix.colors.base05}
      palette =8=${config.lib.stylix.colors.base03}
      palette =9=${config.lib.stylix.colors.base08}
      palette =10=${config.lib.stylix.colors.base0B}
      palette =11=${config.lib.stylix.colors.base0A}
      palette =12=${config.lib.stylix.colors.base0D}
      palette =13=${config.lib.stylix.colors.base0E}
      palette =14=${config.lib.stylix.colors.base0C}
      palette =15=${config.lib.stylix.colors.base07}
    '';
  };

  # Note: Homebrew cask installation is handled at the system level
  # See: darwin/modules/programs/terminals.nix for macOS Homebrew setup
}
