{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    mako
    grim
    slurp
    kanshi
    wl-clipboard
  ];

  # Kanshi display configuration for Wayland
  services.kanshi = {
    enable = true;
    profiles = {
      # External monitor only (laptop closed)
      external = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "DP-3";
            status = "enable";
          }
        ];
      };
      
      # Laptop only
      laptop = {
        outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      };
      
      # Triple monitor setup
      triple = {
        outputs = [
          {
            criteria = "BenQ Corporation BenQ GL2460 F9F04858SL0";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "Samsung Electric Company LS32R75 H4ZN400165";
            status = "enable";
            position = "1920,0";
          }
          {
            criteria = "Chimei Innolux Corporation 0x143C 0x00000000";
            status = "enable";
            position = "5760,0";
          }
        ];
      };
      
      # Dual monitor setup
      dual = {
        outputs = [
          {
            criteria = "HDMI-A-1";
            status = "enable";
            position = "0,0";
          }
          {
            criteria = "eDP-1";
            status = "enable";
            position = "1920,0";
          }
        ];
      };
    };
  };

  services = {
    mako.enable = true;
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "sway";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
