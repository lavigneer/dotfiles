{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    
    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
    ];
    
    extraConfig = ''
      # Session management
      bind-key -r f display-popup -E -E "tmux-sessionizer"

      # Enable focus events for vim
      set -g focus-events on

      # Renumber windows when one is closed
      set -g renumber-windows on

      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity on

      # Increase escape time for vim
      set -sg escape-time 0

      # Colors and styling will be handled by stylix
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
    '';
  };
  
  # tmux-sessionizer script
  home.file.".local/bin/tmux-sessionizer" = {
    text = ''
      #!/usr/bin/env bash

      if [[ $# -eq 1 ]]; then
          selected=$1
      else
          selected=$(find ~/workspace -mindepth 1 -maxdepth 1 -type d | fzf)
      fi

      if [[ -z $selected ]]; then
          exit 0
      fi

      selected_name=$(basename "$selected" | tr . _)
      tmux_running=$(pgrep tmux)

      if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
          tmux new-session -s $selected_name -c $selected
          exit 0
      fi

      if ! tmux has-session -t=$selected_name 2> /dev/null; then
          tmux new-session -ds $selected_name -c $selected
      fi

      tmux switch-client -t $selected_name
    '';
    executable = true;
  };
}
