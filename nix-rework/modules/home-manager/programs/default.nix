{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./tmux.nix
    ./terminals.nix
    ./zed.nix
  ];

  programs = {
    # Core utilities
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ripgrep.enable = true;
    
    bat = {
      enable = true;
      config = {
        # Let stylix handle the theme, or use force if you want to override
        style = "numbers,changes,header";
      };
    };
    
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
    
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Development tools
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # File managers
    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    # Starship prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      # You can add custom settings here or let it use defaults
      # settings = {
      #   # Custom starship configuration
      # };
    };

    # LazyGit moved to git.nix module

    # Platform-specific programs are now in platform files
  };

  # Email accounts are now configured in platform-specific files
}
