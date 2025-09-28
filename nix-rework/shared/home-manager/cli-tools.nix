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
  ];
}
