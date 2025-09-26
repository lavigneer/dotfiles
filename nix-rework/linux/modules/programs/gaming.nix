{ config, pkgs, lib, ... }:

{
  # User-level gaming applications for Linux
  home.packages = with pkgs; [
    lutris        # Gaming launcher for Linux
    # Additional gaming tools for users
    # heroic       # Epic Games launcher
    # bottles      # Windows app compatibility
  ];
}
