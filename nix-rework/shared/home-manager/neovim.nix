{ config, pkgs, lib, inputs, ... }:

{
  # Import the complete nixvim configuration
  imports = [
    ./nixvim
  ];
}