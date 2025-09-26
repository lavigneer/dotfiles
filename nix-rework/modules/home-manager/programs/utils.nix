{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
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

    # Better cat replacement
    bat = {
      enable = true;
      config = {
        # Let stylix handle the theme
        style = "numbers,changes,header";
      };
    };
    
    # Better ls replacement
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
    
    # Smart cd replacement
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # Configuration files for utilities
  xdg.configFile = {
    # Yazi file manager
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi/.config/yazi";
  };
}
