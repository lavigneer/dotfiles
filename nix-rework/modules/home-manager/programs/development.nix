{ config, pkgs, ... }:

{
  # Development tools and programming languages
  home.packages = with pkgs; [
    # Rust toolchain
    cargo
    rustup
    rustc
    
    # Go programming language
    go
    
    # Node.js and npm
    nodejs_24
    
    # Zig programming language
    zig
  ];
}
