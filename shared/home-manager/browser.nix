{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Additional browsers
  home.packages = with pkgs; [
    google-chrome
  ] ++ lib.optionals (!isDarwin) [
    chromium
  ];

  home.sessionVariables = {
    BROWSER = if isDarwin then "open" else "google-chrome";
  };
}
