{ config, pkgs, ... }:
{
  # Discord - Communication platform
  home.packages = with pkgs; [
    claude-code
  ];

}
