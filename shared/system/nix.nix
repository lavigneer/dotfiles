{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Core Nix configuration that applies to both NixOS and nix-darwin

  # Nix settings
  nix = {
    # Ensure Nix uses maximum parallelism for builds
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      # Trusted users for nix
      trusted-users = [
        "root"
        "@admin"
        "@wheel"
      ];

      # Binary caches
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://cache.flox.dev"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="
      ];

      # Automatic optimization of nix store
      auto-optimise-store = true;

      # Maximum number of parallel build jobs
      max-jobs = "auto";
    };

    # Automatic store optimization
    optimise = {
      automatic = true;
      interval = [ "daily" ];
    };

    # Garbage collection settings
    gc = {
      automatic = lib.mkDefault true;
      # Run garbage collection daily
      interval = lib.mkDefault "daily";
      # Keep generations from the last 30 days
      options = lib.mkDefault "--delete-older-than 30d";
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
