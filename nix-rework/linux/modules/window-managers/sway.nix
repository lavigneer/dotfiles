{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.sway;
in
{
  imports = [
    # Import shared Wayland components
    ./wayland.nix
  ];

  options.windowManagers.sway = {
    enable = lib.mkEnableOption "Enable Sway window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # Sway-specific packages (shared Wayland components imported above)
    home.packages = with pkgs; [
      sway
      swaylock
      swayidle
      # Common Wayland components (mako, rofi, polybar, grim, slurp, kanshi) 
      # are now provided by shared/wayland.nix
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

    # Sway-specific XDG config files (common Wayland configs in shared/wayland.nix)
    xdg.configFile = {
      "sway".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/sway/.config/sway";
      # Common configs (polybar, rofi, kanshi) are now in shared/wayland.nix
    };

    # Sway-specific programs (common Wayland programs in shared/wayland.nix)
    # Note: rofi, polybar services are handled by shared/wayland.nix

    # Sway-specific services (common Wayland services in linux/modules/wayland.nix)
    services = {
      # Common services (polybar, mako, kanshi) are now in wayland.nix
      
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
