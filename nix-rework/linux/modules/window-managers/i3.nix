{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  cfg = config.windowManagers.i3;
in
{
  imports = [
    ./x11.nix
    ../system/polybar.nix
    ../system/rofi.nix
  ];

  options.windowManagers.i3 = {
    enable = lib.mkEnableOption "Enable i3 window manager configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      i3status
      i3lock
      dmenu
    ];

    xsession.windowManager.i3 = {
      enable = true;
      config.bars = [];
      extraConfig = ''
        include ~/.config/i3/config
      '';
    };

    xdg.configFile = {
      "i3".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/i3/.config/i3";
    };

    services.redshift = {
      enable = true;
      latitude = 53.5461;
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
}
