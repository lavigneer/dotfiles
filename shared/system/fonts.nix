{ config, pkgs, ... }:

{
  # Shared font configuration across all systems
  fonts.packages = with pkgs; [
    # Basic fonts
    noto-fonts
    noto-fonts-color-emoji
    noto-fonts-cjk-sans

    # Nerd Fonts for terminal and development
    nerd-fonts.go-mono
    nerd-fonts.jetbrains-mono
    nerd-fonts.heavy-data
  ];
}
