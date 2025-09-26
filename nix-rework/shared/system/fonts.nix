{ config, pkgs, ... }:

{
  # Shared font configuration across all systems
  fonts.packages = with pkgs; [
    # Basic fonts
    noto-fonts
    noto-fonts-emoji
    noto-fonts-cjk-sans
    noto-fonts-extra
    
    # Nerd Fonts for terminal and development
    nerd-fonts.go-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.heavy-data
    
    # Additional fonts can be added here
    # nerd-fonts.fira-code
    # nerd-fonts.source-code-pro
  ];
}
