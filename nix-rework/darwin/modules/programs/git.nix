{ config, pkgs, lib, userEmail, ... }:

{
  # macOS-specific git configuration
  programs.git = {
    userEmail = userEmail;
    extraConfig = {
      # Work-specific git settings can go here
    };
  };
}
