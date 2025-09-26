{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  home.packages = with pkgs; [
    dunst
    picom
    feh
    xss-lock
    xclip
    xorg.xrandr
    xorg.xset
  ];

  xdg.configFile = {
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
  };

  services = {
    dunst.enable = true;
    picom.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
      xautolock = {
        enable = true;
        time = 10;
      };
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "X11";
  };

  xsession = {
    enable = true;
    profileExtra = "export TERMINAL=ghostty";
  };

  # X11 server configuration
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    
    xkb = {
      layout = "us";
      variant = "";
    };
  };
}
