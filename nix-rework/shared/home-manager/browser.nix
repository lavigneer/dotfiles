{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Web browser configuration
  home.packages = with pkgs; [
    google-chrome
  ];

  # Set browser environment variable (platform-specific)
  home.sessionVariables = {
    BROWSER = if isDarwin then "open" else "google-chrome";
  };
}
