# Shared Home Manager configurations across all platforms
{ config, pkgs, lib, ... }:

{
  imports = [
    # Core Home Manager setup
    ./core.nix
    
    # Cross-platform programs
    ./cli-tools.nix
    ./development.nix
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./tmux.nix
    ./terminals.nix
    ./zed.nix
    ./docker.nix
  ];
}
