{ config, pkgs, lib, ... }:

{
  # Stylix theming configuration shared across all platforms
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
    
    # Additional Stylix configuration can be added here
    # fonts = {
    #   monospace = {
    #     package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
    #     name = "JetBrainsMono Nerd Font";
    #   };
    # };
  };
}
