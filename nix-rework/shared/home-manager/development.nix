{ config, pkgs, ... }:

{
  # Development languages and tools
  home.packages = with pkgs; [
    # System development
    gcc
    clang
    llvm
    cmake
    gnumake
    
    # Rust ecosystem
    cargo
    rustup
    rustc
    rust-analyzer
    rustfmt
    clippy
    
    # Go ecosystem
    go
    gopls
    gofumpt
    golangci-lint
    delve  # Go debugger
    
    # Node.js ecosystem
    nodejs_24
    npm-check-updates
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
    
    # Database tools
    sqlite
    postgresql
    
    # Container tools
    docker-compose
    dive  # Docker image explorer
    
    # Version control
    git-lfs
    gitflow
    gh  # GitHub CLI
    
    # Performance and debugging
    htop
    btop
    perf-tools
    valgrind
    gdb
    
    # Network tools
    curl
    wget
    httpie
    netcat
    nmap
    wireshark
    
    # Text processing
    jq
    yq
    xmlstarlet
    
    # Build tools
    just  # Command runner like make
    earthly  # Build automation
    
    # Documentation
    pandoc
    mdbook
  ];
  
  # Development environment variables
  home.sessionVariables = {
    # Go configuration
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
    
    # Rust configuration
    RUST_BACKTRACE = "1";
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    
    # Node.js configuration
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
    
    # Python configuration
    PYTHONPATH = "${config.home.homeDirectory}/.local/lib/python3.12/site-packages";
  };
  
  # Development aliases
  home.shellAliases = {
    # Git shortcuts
    "g" = "git";
    "gs" = "git status";
    "ga" = "git add";
    "gc" = "git commit";
    "gp" = "git push";
    "gl" = "git log --oneline --graph --decorate";
    
    # Docker shortcuts
    "dk" = "docker";
    "dkc" = "docker-compose";
    "dki" = "docker images";
    "dkps" = "docker ps";
    
    # Development shortcuts
    "ll" = "ls -la";
    "la" = "ls -A";
    "l" = "ls -CF";
    "grep" = "grep --color=auto";
    "fgrep" = "fgrep --color=auto";
    "egrep" = "egrep --color=auto";
    
    # Quick navigation
    "..." = "cd ../..";
    "...." = "cd ../../..";
    "....." = "cd ../../../..";
  };
}
