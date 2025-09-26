{
  description = "Eric's unified NixOS and nix-darwin configuration with Home Manager";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin for macOS
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    # Stylix for theming
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake utils for easier multi-system support
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, home-manager, nix-darwin, stylix, flake-utils, ... }@inputs:
    let
      # Helper functions
      shared = import ./modules/shared;
      
      # User configuration
      username = "elavigne";
      userFullName = "Eric Lavigne";
      
      # Platform-specific user info
      linuxUserEmail = "hi_eric@hotmail.com";
      darwinUserEmail = "eric.lavigne@mongodb.com";
      
      # System configurations
      linuxSystems = [ "x86_64-linux" ];
      darwinSystems = [ "x86_64-darwin" "aarch64-darwin" ];
      
      # Helper to create system configs
      mkSystem = { system, hostname, isDarwin ? false }:
        let
          pkgs = if isDarwin then nixpkgs-darwin.legacyPackages.${system} else nixpkgs.legacyPackages.${system};
          systemFunc = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          homeManagerModule = if isDarwin then home-manager.darwinModules.home-manager else home-manager.nixosModules.home-manager;
        in
        systemFunc {
          inherit system;
          specialArgs = { 
            inherit inputs username userFullName; 
            userEmail = if isDarwin then darwinUserEmail else linuxUserEmail;
          };
          modules = [
            # Shared configuration
            ./modules/shared
            
            # System configuration
            (./systems + "/${hostname}")
            
            # Home Manager integration
            homeManagerModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import (./modules/home-manager + (if isDarwin then "/darwin.nix" else "/linux.nix"));
                extraSpecialArgs = { 
                  inherit inputs username userFullName; 
                  userEmail = if isDarwin then darwinUserEmail else linuxUserEmail;
                };
              };
            }
            
            # Stylix for both platforms
          ] ++ (if isDarwin then [
            stylix.darwinModules.stylix
          ] else [
            stylix.nixosModules.stylix
          ]);
        };
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        # Your Linux PC
        nixos = mkSystem {
          system = "x86_64-linux";
          hostname = "nixos";
          isDarwin = false;
        };
      };

      # nix-darwin configurations  
      darwinConfigurations = {
        # Your work Mac
        mac = mkSystem {
          system = "x86_64-darwin";  # Change to "aarch64-darwin" if you have Apple Silicon
          hostname = "mac";
          isDarwin = true;
        };
      };

      # Standalone Home Manager configurations (optional)
      homeConfigurations = {
        "${username}@nixos" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [ ./modules/home-manager/linux.nix ];
          extraSpecialArgs = { 
            inherit inputs username userFullName; 
            userEmail = linuxUserEmail;
          };
        };
        
        "${username}@mac" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs-darwin.legacyPackages.x86_64-darwin;
          modules = [ ./modules/home-manager/darwin.nix ];
          extraSpecialArgs = { 
            inherit inputs username userFullName; 
            userEmail = darwinUserEmail;
          };
        };
      };

      # Development shell
      devShells = flake-utils.lib.eachDefaultSystemMap (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          buildInputs = with nixpkgs.legacyPackages.${system}; [
            nixpkgs-fmt
            nil
            git
          ];
        };
      });
    };
}
