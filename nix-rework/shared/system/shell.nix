{ config, pkgs, ... }:

{
  # Shared shell configuration
  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];
  
  # Set default shell
  users.defaultUserShell = pkgs.zsh;
}
