{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.sway;
in
{
  options.windowManagers.sway = {
    enable = lib.mkEnableOption "Enable Sway window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # Sway-specific packages
    home.packages = with pkgs; [
      sway
      swaylock
      swayidle
      # wl-clipboard managed by neovim module
      mako # notification daemon for wayland
      rofi # launcher with Wayland support (v2.0.0+)
      polybar # status bar (works on Wayland via XWayland)
      grim # screenshot utility
      slurp # select region for screenshot
      kanshi # display management
      # Using Ghostty as terminal (configured in shared terminals.nix)
    ];

    # Sway configuration
    wayland.windowManager.sway = {
      enable = true;
      config = {
        # Basic sway config - detailed config comes from external file
        terminal = "ghostty";
        menu = "rofi -show drun";
      };
      extraConfig = ''
        include ~/.config/sway/config
      '';
    };

    # Sway-related XDG config files
    xdg.configFile = {
      "sway".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/sway/.config/sway";
      "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
      "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
      "kanshi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/kanshi/.config/kanshi";
      # foot config removed - using Ghostty as terminal
    };

    # Sway-related programs
    programs = {
      rofi.enable = true;
      # foot.enable removed - using Ghostty as terminal
    };

    # Sway-related services
    services = {
      # Polybar status bar (works on Wayland via XWayland)
      polybar = {
        enable = true;
        config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
        script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
      };

      # Mako notification daemon
      mako = {
        enable = true;
        # Configuration will come from dotfiles if needed
      };
      
      # Kanshi display management
      kanshi.enable = true;
      
      # Swayidle
      swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = "${pkgs.swaylock}/bin/swaylock -f";
          }
          {
            timeout = 600;
            command = "${pkgs.sway}/bin/swaymsg 'output * dpms off'";
            resumeCommand = "${pkgs.sway}/bin/swaymsg 'output * dpms on'";
          }
        ];
      };
    };
  };
}
