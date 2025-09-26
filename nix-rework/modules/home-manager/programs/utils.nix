{ config, pkgs, ... }:

{
  # Core utilities and development tools
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
}
