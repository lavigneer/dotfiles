{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Stylix theming configuration shared across all platforms
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";

    # Ensure Home Manager integration is enabled
    homeManagerIntegration = {
      autoImport = true;
      followSystem = true;
    };
  };
}
