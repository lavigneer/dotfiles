{ config, pkgs, ... }:

{
  # Discord - Communication platform
  home.packages = with pkgs; [
    claude-code
  ];
      # Universal rebuild script that auto-detects system type
  # claude = pkgs.writeShellScriptBin "claude" ''
  #   set -e
  #
  #   HOSTNAME=$(hostname)
  #   FLAKE_PATH="$HOME/workspace/dotfiles"
  #
  #   echo "Rebuilding system: $HOSTNAME"
  #
  #   if [[ "${toString isDarwin}" == "1" ]]; then
  #     echo "Detected Darwin system - running darwin-rebuild..."
  #     sudo darwin-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
  #   else
  #     echo "Detected NixOS system - running nixos-rebuild..."
  #     sudo nixos-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
  #   fi
  #
  #   echo "Rebuild completed successfully!"
  # '';

}
