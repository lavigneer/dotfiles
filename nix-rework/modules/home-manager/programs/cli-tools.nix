{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  # Modern CLI tools and utilities
  programs = {
    # Fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Modern grep replacement
    ripgrep.enable = true;
    
    # Development environment management
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # File manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Additional CLI utilities as packages
  home.packages = with pkgs; [
    # System monitoring
    btop
    htop
    
    # File operations
    fd        # Modern find replacement
    tree      # Directory tree viewer
    
    # Network utilities
    dig       # DNS lookup
    curl      # HTTP client
    wget      # Download utility
    
    # Archive utilities
    unzip
    
    # JSON processing
    jq
    
    # Text processing utilities (POSIX compliant versions)
    gawk      # GNU awk
    gnugrep   # GNU grep
    gnused    # GNU sed
  ];

  # Configuration files for utilities
  xdg.configFile = {
    # Yazi file manager
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi/.config/yazi";
  };
}
