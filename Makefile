# Repo maintenance helpers.
# To apply the config use `rebuild-nix`; to update inputs use `nix flake update`.

DEV := nix develop --command

.PHONY: help
help:
	@echo "Available targets:"
	@echo "  fmt        - Format the repo (nixfmt + prettier via treefmt)"
	@echo "  lint       - Lint Nix files (statix + deadnix)"
	@echo "  check      - Evaluate all flake outputs (nix flake check)"
	@echo "  all        - fmt, lint and check"

.PHONY: fmt
fmt:
	nix fmt

.PHONY: lint
lint:
	$(DEV) statix check .
	$(DEV) deadnix --fail --no-lambda-pattern-names .

.PHONY: check
check:
	nix flake check --all-systems --no-build

.PHONY: all
all: fmt lint check
