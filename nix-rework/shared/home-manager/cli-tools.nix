{ config, pkgs, ... }:

{
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f --hidden --follow --exclude .git";
      defaultOptions = [
        "--height 40%"
        "--border"
        "--reverse"
        "--inline-info"
      ];
      fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
      fileWidgetOptions = [
        "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
      ];
      changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];
      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];
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

    bat = {
      enable = true;
      config = {
        theme = "base16";
        style = "numbers,changes,header";
        pager = "less -FR";
      };
    };
  };

  home.packages = with pkgs; [
    htop
    fd
    curl
    wget
    unzip
    jq
    gawk
    gnugrep
    gnused
    tree  # for fzf directory preview
    file  # for file type detection
    less  # for bat pager
  ];

}
