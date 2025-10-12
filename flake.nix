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

    # Nixvim for declarative Neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-darwin
    , home-manager
    , nix-darwin
    , stylix
    , flake-utils
    , nixvim
    , ...
    }@inputs:
    let
      # Helper functions
      shared = import ./modules/shared;

      # User configuration
      username = "elavigne";
      userFullName = "Eric Lavigne";

      # Platform-specific user info
      personalUserEmail = "hi_eric@hotmail.com";
      workUserEmail = "eric.lavigne@mongodb.com";

      # System configurations
      linuxSystems = [ "x86_64-linux" ];
      darwinSystems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      # Helper to create system configs
      mkSystem =
        { system
        , hostname
        , isDarwin ? false
        ,
        }:
        let
          pkgs =
            if isDarwin then nixpkgs-darwin.legacyPackages.${system} else nixpkgs.legacyPackages.${system};
          systemFunc = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
          homeManagerModule =
            if isDarwin then
              home-manager.darwinModules.home-manager
            else
              home-manager.nixosModules.home-manager;
        in
        systemFunc {
          inherit system;
          specialArgs = {
            inherit inputs username userFullName;
            userEmail = if isDarwin then workUserEmail else personalUserEmail;
          };
          modules = [
            (if isDarwin then stylix.darwinModules.stylix else stylix.nixosModules.stylix)
            # Platform-specific configuration (provides defaults for the platform)
            (if isDarwin then ./darwin else ./linux)

            # Machine-specific configuration (can override platform defaults)
            (./systems + "/${hostname}")

            # Home Manager integration (configuration now in platform defaults)
            homeManagerModule
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit inputs username userFullName;
                  userEmail = if isDarwin then workUserEmail else personalUserEmail;
                };
              };
            }
          ];
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
        M-DX000XV19K = mkSystem {
          system = "aarch64-darwin"; # Change to "aarch64-darwin" if you have Apple Silicon
          hostname = "M-DX000XV19K";
          isDarwin = true;
        };
        Erics-MacBook-Air.local = mkSystem {
          system = "aarch64-darwin"; # Change to "aarch64-darwin" if you have Apple Silicon
          hostname = "Erics-MacBook-Air.local";
          isDarwin = true;
        };
      };

      # Standalone Home Manager configurations removed
      # Home Manager configuration is now integrated into platform defaults
      # Use system configurations (nixosConfigurations/darwinConfigurations) instead
      homeConfigurations = { };

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
