{ config, pkgs, lib, ... }:

{
  # Linux development tools
  home.packages = with pkgs; [
    nil # Nix LSP
  ];
}
