{ config, pkgs, lib, ... }:

{
  # Stylix theming configuration shared across all platforms
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };
}
