{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zsh = {
    enable = true;
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "tmux"
        "fzf"
        "z"
      ];
      theme = "";
    };
    
    sessionVariables = {
      ZSH_TMUX_CONFIG = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
    };
    
    shellAliases = {
      nix-shell = "nix-shell --run zsh";
      rebuild-nixos = "sudo nixos-rebuild switch --flake ~/workspace/dotfiles/nix-rework#nixos";
      rebuild-darwin = "darwin-rebuild switch --flake ~/workspace/dotfiles/nix-rework#mac";
      rebuild-home = "home-manager switch --flake ~/workspace/dotfiles/nix-rework";
    };
    
    # Additional shell initialization
    initContent = ''
      # Source manual zshrc if it exists
      if [[ -f ~/.zshrc.manual ]]; then
        source ~/.zshrc.manual
      fi
      
      # History settings
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      
      # Directory stack
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      
      # Correction
      setopt CORRECT
      setopt CORRECT_ALL
      
      # Key bindings
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      bindkey '^P' history-search-backward
      bindkey '^N' history-search-forward
      
      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # FZF key bindings and completion
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
    '';
    
    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
  };
  
  # Link to manual zshrc for additional customizations
  home.file.".zshrc.manual".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/zshrc/.zshrc";
}
