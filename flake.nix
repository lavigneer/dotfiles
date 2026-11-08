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

    # Nixvim for declarative Neovim configuration
    nixvim = {
      url = "github:nix-community/nixvim";
    };

    # Vim plugins (tracked as flake inputs)
    sidekick-nvim = {
      url = "github:folke/sidekick.nvim";
      flake = false;
    };
    nvim-lsp-endhints = {
      url = "github:chrisgrieser/nvim-lsp-endhints";
      flake = false;
    };

    # treefmt for formatting
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flox
    flox = {
      url = "github:flox/flox/latest";
    };

    # Herdr desktop mods: ticket -> worktree -> agent -> PR (private repo, so
    # over SSH; rebuild-nix fetches inputs as you before the sudo rebuild).
    sheltie = {
      url = "git+ssh://git@github.com/lavigneer/sheltie";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-darwin,
      home-manager,
      nix-darwin,
      stylix,
      nixvim,
      sidekick-nvim,
      nvim-lsp-endhints,
      treefmt-nix,
      flox,
      ...
    }@inputs:
    let
      # User configuration
      username = "elavigne";
      userFullName = "Eric Lavigne";

      # Platform-specific user info
      personalUserEmail = "hi_eric@hotmail.com";
      workUserEmail = "eric.lavigne@mongodb.com";

      # Systems used for per-system outputs (devShells, formatter)
      linuxSystems = [ "x86_64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems);

      # treefmt: nixfmt for Nix, prettier for Markdown/JSON
      treefmtEval = forAllSystems (
        system:
        treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} {
          projectRootFile = "flake.nix";
          programs = {
            nixfmt.enable = true;
            prettier.enable = true;
          };
          settings.formatter.prettier = {
            options = [
              "--prose-wrap"
              "always"
            ];
            includes = [
              "*.md"
              "*.json"
            ];
          };
        }
      );

      # Overlay to fix pre-commit build on darwin (dotnet-sdk tests require Swift which is broken)
      darwinOverlays = [
        (_final: prev: {
          pre-commit = prev.pre-commit.overridePythonAttrs (_oldAttrs: {
            doCheck = false;
            dontUsePytestCheck = true;
            nativeCheckInputs = [ ];
            preCheck = null;
            pytestCheckPhase = null;
          });
          direnv = prev.direnv.overrideAttrs (oldAttrs: {
            env = (oldAttrs.env or { }) // {
              CGO_ENABLED = "1";
            };
          });
          # Fix appstream-1.1.2 build on Darwin: meson incorrectly passes
          # 'none required' as linker flags for unfound optional dependencies.
          appstream = prev.appstream.overrideAttrs (oldAttrs: {
            postConfigure = (oldAttrs.postConfigure or "") + ''
              find . -name "*.ninja" -exec sed -i 's/ none required//g' {} +
            '';
          });
        })
      ];

      # Helper to create system configs
      mkSystem =
        {
          system,
          hostname,
          isDarwin ? false,
          userEmail,
        }:
        let
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
            inherit
              inputs
              username
              userFullName
              userEmail
              ;
          };
          modules =
            # Apply darwin overlays to fix broken packages (mkAfter ensures they're applied last)
            (if isDarwin then [ { nixpkgs.overlays = nixpkgs-darwin.lib.mkAfter darwinOverlays; } ] else [ ])
            ++ [
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
                    inherit
                      inputs
                      username
                      userFullName
                      userEmail
                      ;
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
          userEmail = personalUserEmail;
        };
      };

      # nix-darwin configurations
      darwinConfigurations = {
        # Your work Mac
        M-DX000XV19K = mkSystem {
          system = "aarch64-darwin";
          hostname = "M-DX000XV19K";
          isDarwin = true;
          userEmail = workUserEmail;
        };
        Erics-MacBook-Air.local = mkSystem {
          system = "aarch64-darwin";
          hostname = "Erics-MacBook-Air.local";
          isDarwin = true;
          userEmail = personalUserEmail;
        };
      };

      # Development shell with the tools used by the Makefile (fmt, lint)
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            nixfmt
            nil
            statix
            deadnix
          ];
        };
      });

      # Formatter (`nix fmt` / `make fmt`)
      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
    };
}
