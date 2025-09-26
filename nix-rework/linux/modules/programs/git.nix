{ config, pkgs, lib, userEmail, ... }:

{
  # Linux-specific git configuration
  programs.git = {
    userEmail = userEmail;
  };
}
