{ config, pkgs, ... }:

{
  imports = [
    ../system/fonts.nix
    ../system/gaming.nix
    ../system/shell.nix
  ];

  # Common configurations that apply to both NixOS and nix-darwin
  
  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      
      # Trusted users for nix
      trusted-users = [ "root" "@admin" "@wheel" ];
      
      # Binary caches
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    
    # Garbage collection
    gc = {
      automatic = pkgs.lib.mkDefault true;
      options = pkgs.lib.mkDefault "--delete-older-than 30d";
    };
  };
  
  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    
    # Allow broken packages (use with caution)
    allowBroken = false;
    
    # Permit insecure packages (use sparingly)
    permittedInsecurePackages = [
      # Add specific packages here if needed
    ];
  };
}
