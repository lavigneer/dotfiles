{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    historyLimit = 10000;
    mouse = true;
    keyMode = "vi";
    shell = "${pkgs.zsh}/bin/zsh";

    # Plugins
    plugins = with pkgs.tmuxPlugins; [
      sensible
      pain-control
    ];

    extraConfig = ''
      # Session management
      bind-key -r f display-popup -E -E "tmux-sessionizer"
      bind-key -r t display-popup -E -E "tmux-sessionizer-worktree"

      # Enable focus events for vim
      set -g focus-events on

      # Renumber windows when one is closed
      set -g renumber-windows on

      set -gu default-command

      # Increase escape time for vim
      set -sg escape-time 0

      # Toggle collapse/expand for right pane
      bind-key C-Space if-shell "[[ $(tmux display -p '#{pane_width}') -le 5 ]]" \
        "resize-pane -L 999; resize-pane -R 80" \
        "resize-pane -R 999"
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

  home.file.".local/bin/tmux-sessionizer-worktree" = {
    text = ''
      #!/usr/bin/env bash

      if [[ $# -eq 1 ]]; then
          selected=$1
      else
          selected=$(git worktree list | fzf)
      fi

      if [[ -z $selected ]]; then
          exit 0
      fi

      selected=$(echo "$selected" | cut -f 1 -d " " -)
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
  };
}
