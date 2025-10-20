{ config, pkgs, inputs, username, userEmail, userFullName, ... }:

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

  # Minimal stylix configuration for container
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/kanagawa.yaml";
  };

  # Container-specific home configuration
  home.stateVersion = "25.05";
}
