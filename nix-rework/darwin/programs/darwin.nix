{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  imports = [
    # macOS-compatible window managers only
    ./aerospace.nix
  ];

  config = lib.mkIf isDarwin {
    # macOS window manager packages
    home.packages = with pkgs; [
      # PDF viewers (work on macOS too)
      zathura
      
      # macOS-specific utilities that might be useful for window management
      # Most macOS window management tools are installed via Homebrew
    ];

    # macOS-specific window manager services
    services = {
      # Services specific to macOS window management
      # Most window manager services on macOS are handled by the tools themselves
    };
  };
}
