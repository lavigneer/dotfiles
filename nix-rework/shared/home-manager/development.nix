{ config, pkgs, ... }:

{
  # Development tools and programming languages
  home.packages = with pkgs; [
    # C/C++ development
    gcc       # GNU Compiler Collection
    
    # Rust toolchain
    cargo
    rustup
    rustc
    
    # Go programming language
    go
    
    # Node.js and npm
    nodejs_24
    
    # Nix development
    nil # Nix LSP
  ];
}
