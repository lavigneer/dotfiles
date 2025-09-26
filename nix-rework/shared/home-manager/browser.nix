{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  home.packages = with pkgs; [
    google-chrome
  ];

  home.sessionVariables = {
    BROWSER = if isDarwin then "open" else "google-chrome";
  };
}
