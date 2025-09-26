{ config, pkgs, lib, ... }:

{
  # macOS-specific tools and utilities
  home.packages = with pkgs; [
    mas # Mac App Store CLI
    darwin.cctools # macOS development tools
  ];

  # macOS-specific environment variables
  home.sessionVariables = {
    BROWSER = "open";
  };
}
