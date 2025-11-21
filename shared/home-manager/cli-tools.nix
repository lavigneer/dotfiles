{ config, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Universal rebuild script that auto-detects system type
  rebuild-nix = pkgs.writeShellScriptBin "rebuild-nix" ''
    set -e

    HOSTNAME=$(hostname)
    FLAKE_PATH="$HOME/workspace/dotfiles"

    echo "Rebuilding system: $HOSTNAME"

    if [[ "${toString isDarwin}" == "1" ]]; then
      echo "Detected Darwin system - running darwin-rebuild..."
      sudo darwin-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
    else
      echo "Detected NixOS system - running nixos-rebuild..."
      sudo nixos-rebuild switch --flake "$FLAKE_PATH#$HOSTNAME"
    fi

    echo "Rebuild completed successfully!"
  '';
in
{
  programs = {
    awscli = {
      enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };

    ripgrep = {
      enable = true;
      arguments = [
        "--hidden"
        "--glob=!.git/*"
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
          mouse_events = [ ];
        };
      };
    };
  };

  home.packages = with pkgs; [
    asdf
    htop
    curl
    devbox
    kubectl
    tilt
    wget
    unzip
    gawk
    gnugrep
    gnused
    less
    tree
    terraform
    file
    jq
    yq
    xz
    rebuild-nix
  ];

  home.file.".local/bin/tldr-fuzzy" = {
    text = ''
      #!/usr/bin/env bash
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title tldr
      # @raycast.mode fullOutput

      # Optional parameters:
      # @raycast.icon 🤖
      "${pkgs.tealdeer}/bin/tldr" --list | "${pkgs.fzf}/bin/fzf" | xargs "${pkgs.tealdeer}/bin/tldr"
    '';
    executable = true;
  };
}
