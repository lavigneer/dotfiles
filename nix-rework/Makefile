# Makefile for managing Nix configurations

# Variables
FLAKE_DIR := $(shell pwd)
USER := elavigne

# Default target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  update          - Update flake inputs"
	@echo "  nixos-build     - Build NixOS configuration (dry run)"
	@echo "  nixos-switch    - Switch to NixOS configuration"
	@echo "  darwin-build    - Build macOS configuration (dry run)"
	@echo "  darwin-switch   - Switch to macOS configuration"
	@echo "  home-switch     - Switch Home Manager configuration"
	@echo "  clean           - Clean old generations"
	@echo "  check           - Check flake syntax"
	@echo "  fmt             - Format nix files"

# Update flake inputs
.PHONY: update
update:
	nix flake update

# NixOS targets
.PHONY: nixos-build
nixos-build:
	sudo nixos-rebuild dry-build --flake .#nixos

.PHONY: nixos-switch
nixos-switch:
	sudo nixos-rebuild switch --flake .#nixos

# macOS targets  
.PHONY: darwin-build
darwin-build:
	darwin-rebuild check --flake .#mac

.PHONY: darwin-switch
darwin-switch:
	darwin-rebuild switch --flake .#mac

# Home Manager targets
.PHONY: home-switch
home-switch:
	home-manager switch --flake .

.PHONY: home-switch-nixos
home-switch-nixos:
	home-manager switch --flake .#$(USER)@nixos

.PHONY: home-switch-mac
home-switch-mac:
	home-manager switch --flake .#$(USER)@mac

# Maintenance
.PHONY: clean
clean:
	sudo nix-collect-garbage -d
	nix-collect-garbage -d

.PHONY: check
check:
	nix flake check

.PHONY: fmt
fmt:
	find . -name "*.nix" -exec nixpkgs-fmt {} \;

# Show system info
.PHONY: info
info:
	@echo "Flake directory: $(FLAKE_DIR)"
	@echo "User: $(USER)"
	@echo "System: $(shell uname -s)"
	@if command -v nixos-version >/dev/null 2>&1; then \
		echo "NixOS version: $$(nixos-version)"; \
	fi
	@if command -v sw_vers >/dev/null 2>&1; then \
		echo "macOS version: $$(sw_vers -productVersion)"; \
	fi

# Development
.PHONY: dev
dev:
	nix develop

# Show generations
.PHONY: generations
generations:
	@echo "=== System Generations ==="
	@if command -v nixos-version >/dev/null 2>&1; then \
		sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -10; \
	fi
	@if command -v darwin-rebuild >/dev/null 2>&1; then \
		sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | tail -10; \
	fi
	@echo ""
	@echo "=== Home Manager Generations ==="
	@home-manager generations | head -10

# Rollback (use with caution)
.PHONY: rollback-system
rollback-system:
	@if command -v nixos-version >/dev/null 2>&1; then \
		sudo nixos-rebuild switch --rollback; \
	elif command -v darwin-rebuild >/dev/null 2>&1; then \
		darwin-rebuild switch --rollback; \
	else \
		echo "No system configuration manager found"; \
	fi

.PHONY: rollback-home
rollback-home:
	home-manager switch --rollback
