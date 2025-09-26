{ config, pkgs, lib, username, userFullName, userEmail, ... }:

{
  # Linux platform system defaults (can be overridden by machine-specific configs)
  
  # Default user configuration for Linux systems
  users.users.${username} = {
    isNormalUser = true;
    description = userFullName;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Default Linux system packages (minimal - most via Home Manager)
  environment.systemPackages = with pkgs; [
    # Essential Linux system tools
    wget
    unzip
    xss-lock
    gcc  # Common development dependency on Linux
  ];

  # Default Linux services
  services = {
    # Audio (PipeWire is the modern default for Linux)
    pulseaudio.enable = false;
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      alsa.support32Bit = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };
    
    # Bluetooth support (common on Linux desktops)
    blueman.enable = lib.mkDefault true;
    
    # Printing support (common need)
    printing.enable = lib.mkDefault true;
  };

  # Security defaults for Linux
  security.rtkit.enable = lib.mkDefault true;

  # Default Stylix theming for Linux
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/chalk.yaml";
  };

  # Default system state version for Linux (can be overridden per machine)
  system.stateVersion = lib.mkDefault "25.05";

  # ===== HOME MANAGER INTEGRATION =====
  # Basic Home Manager setup - specific module imports handled by systems
  
  home-manager.users.${username} = { config, pkgs, ... }: {
    imports = [
      # Always import shared Home Manager configurations
      ../shared/home-manager
      
      # Additional imports will be added by individual systems
    ];
  };
}