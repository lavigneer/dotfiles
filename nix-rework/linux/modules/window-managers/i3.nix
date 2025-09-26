{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.i3;
  isLinux = !pkgs.stdenv.hostPlatform.isDarwin;
in
{
  options.windowManagers.i3 = {
    enable = lib.mkEnableOption "Enable i3 window manager configuration";
  };

  config = lib.mkIf (isLinux && cfg.enable) {
    # i3-specific packages
    home.packages = with pkgs; [
      i3status
      i3lock
      dmenu
      rofi
      polybar
      picom
      dunst
      feh       # wallpaper setter
      xss-lock  # X11 screen locker utility
    ];

    # i3 configuration
    xsession = {
      enable = true;
      profileExtra = "export TERMINAL=ghostty";
      windowManager.i3 = { 
        enable = true;
        config.bars = []; # Disable default bar, use polybar instead
        extraConfig = ''
          include ~/.config/i3/config
        '';
      };
    };

    # i3-related XDG config files
    xdg.configFile = {
      "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
      "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
      "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
      "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
    };

    # i3-related programs
    programs = {
      rofi.enable = true;
    };

    # i3-related services
    services = {
      # Polybar for i3
      polybar = {
        enable = true;
        config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
        script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
      };
      
      # Dunst notification daemon
      dunst.enable = true;
      
      # Picom compositor
      picom.enable = true;
      
      # Redshift (blue light filter)
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
