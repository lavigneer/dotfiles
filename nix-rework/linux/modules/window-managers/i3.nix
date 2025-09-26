{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.i3;
in
{
  imports = [
    # Import shared X11 components
    ./x11.nix
  ];

  options.windowManagers.i3 = {
    enable = lib.mkEnableOption "Enable i3 window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    # i3-specific packages (shared X11 components imported above)
    home.packages = with pkgs; [
      i3status
      i3lock
      dmenu
      # Common X11 components (rofi, polybar, picom, dunst, feh, xss-lock) 
      # are now provided by linux/modules/x11.nix
    ];

    # i3 configuration (xsession.enable handled by x11.nix)
    xsession.windowManager.i3 = { 
      enable = true;
      config.bars = []; # Disable default bar, use polybar instead
      extraConfig = ''
        include ~/.config/i3/config
      '';
    };

    # i3-specific XDG config files (common X11 configs in linux/modules/x11.nix)
    xdg.configFile = {
      "i3".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/i3/.config/i3";
      # Common configs (polybar, rofi, picom, dunst) are now in x11.nix
    };

    # i3-specific programs and services (common X11 ones in ./x11.nix)
    # Note: rofi, polybar, dunst, picom services are handled by x11.nix
    
    # Additional i3-specific services can go here if needed
    services = {
      # Redshift (blue light filter) - i3-specific
      redshift = {
        enable = true;
        latitude = 53.5461;   # Edmonton coordinates
        longitude = -113.4938;
        settings = {
          redshift = {
            adjustment-method = "randr";
            gamma = 0.8;
          };
          randr = {
            screen = 0;
          };
        };
      };
    };
  };
}
