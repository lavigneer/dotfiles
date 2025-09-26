{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  services = pkgs.lib.optionalAttrs (!isDarwin) {
    # Linux-specific services
    
    # Polybar for i3
    polybar = {
      enable = true;
      config = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar/config.ini";
      script = "${dotfilesPath}/polybar/.config/polybar/start.sh";
    };
    
    # Dunst notification daemon
    dunst = {
      enable = true;
      # Configuration will be loaded from external file
    };
    
    # Picom compositor
    picom = {
      enable = true;
      # Configuration will be loaded from external file
    };
    
    # GPG agent
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
    
    # SSH agent
    ssh-agent.enable = true;
    
    # Syncthing (file synchronization)
    syncthing.enable = true;
    
    # Redshift (blue light filter)
    redshift = {
      enable = true;
      latitude = 53.5461;   # Edmonton coordinates
      longitude = -113.4938;
      settings = {
        redshift = {
          adjustment-method = "randr";
          gamma = 0.8;
        };
        randr = {
          screen = 0;
        };
      };
    };
  } // pkgs.lib.optionalAttrs isDarwin {
    # macOS-specific services
    
    # Syncthing also works on macOS
    syncthing.enable = true;
  };
}
