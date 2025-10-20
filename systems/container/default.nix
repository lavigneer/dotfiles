{ config, pkgs, inputs, username, userEmail, userFullName, lib, ... }:

{
  # Minimal container configuration - only CLI tools and development essentials

  imports = [
    ../../shared/home-manager/core.nix
    ../../shared/home-manager/cli-tools.nix
    ../../shared/home-manager/development.nix
    ../../shared/home-manager/git.nix
    ../../shared/home-manager/zsh.nix
    ../../shared/home-manager/nixvim
    ../../shared/home-manager/tmux.nix
    ../../shared/home-manager/docker.nix
  ];

  # Disable stylix for container (not available in standalone home-manager)
  stylix.targets.nixvim.enable = lib.mkForce false;

  # Container-specific home configuration
  home.stateVersion = "25.05";
}
