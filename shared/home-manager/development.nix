{ config, pkgs, lib, ... }:

{
  # Development languages and tools
  home.packages = with pkgs; [
    pre-commit
    devcontainer

    # System development
    gnumake
    bazelisk
    
    # Rust ecosystem
    cargo
    rustc
    rust-analyzer
    rustfmt
    clippy
    
    # Go ecosystem
    go
    gopls
    golangci-lint
    delve  # Go debugger
    
    # Node.js ecosystem
    nodejs_24
    yarn
    pnpm
    
    # Python ecosystem
    python312
    python312Packages.pip
    python312Packages.virtualenv
    pyright
    black
    ruff
    
    # Nix development
    nil
    nixpkgs-fmt
    nixd
  ];
  
  # Development environment variables
  home.sessionVariables = {
    # Go configuration
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
    GOROOT = "${pkgs.go}/share/go";
    
    # Rust configuration
    RUST_BACKTRACE = "1";
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    
    # Node.js configuration
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
    
    # Python configuration
    PYTHONPATH = "${config.home.homeDirectory}/.local/lib/python3.12/site-packages";
  };

  # tmux-sessionizer script
  home.file.".local/bin/bazel" = {
    source = config.lib.file.mkOutOfStoreSymlink "${pkgs.bazelisk}/bin/bazelisk";
    executable = true;
  };
}
