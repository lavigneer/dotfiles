{ config, pkgs, lib, ... }:

{
  # Linux desktop applications
  home.packages = with pkgs; [
    discord
    google-chrome
    lutris
    pavucontrol
    solaar
  ];

  # Browser configuration
  home.sessionVariables = {
    BROWSER = "google-chrome";
  };
}
