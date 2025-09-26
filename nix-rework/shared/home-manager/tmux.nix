{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
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
      # Set prefix to Ctrl-a
      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix
      
      # Reload config file
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
      
      # Quick pane cycling
      unbind ^A
      bind ^A select-pane -t :.+
      
      # Better window splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # Better window navigation
      bind -n M-H previous-window
      bind -n M-L next-window
      
      # Resize panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
      
      # Copy mode improvements
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection
      bind-key -T copy-mode-vi r send-keys -X rectangle-toggle
      
      # Session management
      bind-key -r f display-popup -E "tmux-sessionizer"
      
      # Enable focus events for vim
      set -g focus-events on
      
      # Don't rename windows automatically
      set-option -g allow-rename off
      
      # Renumber windows when one is closed
      set -g renumber-windows on
      
      # Start panes at 1, not 0
      set -g pane-base-index 1
      
      # Activity monitoring
      setw -g monitor-activity on
      set -g visual-activity on
      
      # Increase escape time for vim
      set -sg escape-time 0
      
      # Status bar configuration
      set -g status-position top
      set -g status-interval 5
      set -g status-left-length 30
      set -g status-right-length 150
      
      # Colors and styling will be handled by stylix
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      
      # Window status format
      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    '';
  };
  
  # Ensure tmux-sessionizer script is executable
  home.file.".local/bin/tmux-sessionizer" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/workspace/dotfiles/tmux/.local/bin/tmux-sessionizer";
    executable = true;
  };
}
