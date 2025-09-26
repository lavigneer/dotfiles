{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    gcc
    cargo
    rustup
    rustc
    go
    nodejs_24
    nil
  ];
}
