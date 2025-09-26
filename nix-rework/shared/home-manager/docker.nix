{ config, pkgs, ... }:

{
  # LazyDocker configuration
  xdg.configFile."lazydocker/config.yml".text = ''
    gui:
      # Confusing, but this disables mouse events
      mouseEvents: true
  '';
  
  # Install lazydocker package
  home.packages = with pkgs; [
    lazydocker
  ];
}
