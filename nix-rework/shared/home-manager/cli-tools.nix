{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  
  # Universal rebuild script that auto-detects system type
  rebuild-nix = pkgs.writeShellScriptBin "rebuild-nix" ''
    set -e
    
    HOSTNAME=$(hostname)
    FLAKE_PATH="$HOME/workspace/dotfiles/nix-rework"
    
    echo "Rebuilding system: $HOSTNAME"
    
    if [[ "${toString isDarwin}" == "1" ]]; then
      echo "Detected Darwin system - running darwin-rebuild..."
      darwin-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
    else
      echo "Detected NixOS system - running nixos-rebuild..."
      sudo nixos-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
    fi
    
    echo "Rebuild completed successfully!"
  '';
in
{
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--max-columns-preview"
        "--colors=line:style:bold"
        "--smart-case"
      ];
    };
    
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
          mouse_events = [];
        };
      };
    };

    # JSON processor with native configuration
    jq = {
      enable = true;
    };
  };

  home.packages = with pkgs; [
    htop     
    curl     
    wget     
    unzip    
    gawk     
    gnugrep  
    gnused   
    less     
    tree     
    file     
    jq
    yq
    rebuild-nix  # Universal rebuild script
  ];
}
