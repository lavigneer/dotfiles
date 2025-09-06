{
  inputs = {
    # This is pointing to an unstable release.
    # If you prefer a stable release instead, you can this to the latest number shown here: https://nixos.org/download
    # i.e. nixos-24.11
    # Use `nix flake update` to update the flake to the latest revision of the chosen release channel.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs@{ self, nixpkgs, stylix, home-manager, ... }: {
    # NOTE: 'nixos' is the default hostname
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      modules = [
        stylix.nixosModules.stylix
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager
        ./home.nix
      ];
    };
  };
}

