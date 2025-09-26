# Shared configurations across all platforms
{ config, pkgs, lib, ... }:

{
  imports = [
    # System-level shared configurations
    ./system/default.nix
  ];
}
