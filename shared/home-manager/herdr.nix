{ lib, pkgs, ... }:

{
  home.packages = [ pkgs.herdr pkgs.bun pkgs.go ];

  home.sessionVariables.HERDR_AUTOSTART = "true";

  # Keep the plugin installation reproducible even though Herdr manages plugins
  # outside the Nix store. Update this ref when upgrading Sessionizer.
  home.activation.herdrSessionizer = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    export PATH="${pkgs.herdr}/bin:${pkgs.bun}/bin:${pkgs.go}/bin:${pkgs.git}/bin:${pkgs.jq}/bin:$PATH"
    sessionizer_ref="df519d50379cdc0def9db134d215aa607923e98f"
    sessionizer_marker="$HOME/.config/herdr/sessionizer.ref"
    auto_title_ref="743bb2f9c8b7e70cdeb0cbb998ed343acb77690a"
    auto_title_marker="$HOME/.config/herdr/auto-title.ref"

    if [[ -f "$sessionizer_marker" ]] \
      && [[ "$(<"$sessionizer_marker")" == "$sessionizer_ref" ]] \
      && ${pkgs.herdr}/bin/herdr plugin list --json \
        | ${pkgs.jq}/bin/jq -e '.result.plugins[]? | select(.plugin_id == "sessionizer")' >/dev/null; then
      :
    else
      ${pkgs.herdr}/bin/herdr plugin install andrewchng/herdr-sessionizer \
        --ref "$sessionizer_ref" --yes
      printf '%s\n' "$sessionizer_ref" > "$sessionizer_marker"
    fi

    if [[ ! -e "$HOME/.config/opencode/plugins/herdr-agent-state.js" ]]; then
      ${pkgs.herdr}/bin/herdr integration install opencode
    fi

    if [[ -f "$auto_title_marker" ]] \
      && [[ "$(<"$auto_title_marker")" == "$auto_title_ref" ]] \
      && ${pkgs.herdr}/bin/herdr plugin list --json \
        | ${pkgs.jq}/bin/jq -e '.result.plugins[]? | select(.plugin_id == "herdr.auto-title")' >/dev/null; then
      :
    else
      ${pkgs.herdr}/bin/herdr plugin install kryptamine/herdr-auto-title \
        --ref "$auto_title_ref" --yes
      printf '%s\n' "$auto_title_ref" > "$auto_title_marker"
    fi
  '';

  home.file.".config/herdr/config.toml".text = ''
    onboarding = false

    [theme]
    name = "terminal"

    [terminal]
    default_shell = "${pkgs.zsh}/bin/zsh"
    shell_mode = "auto"
    new_cwd = "follow"

    [keys]
    # Keep the tmux prefix and familiar movement keys.
    prefix = "ctrl+b"
    focus_pane_left = [ "prefix+h", "prefix+ctrl+h" ]
    focus_pane_down = [ "prefix+j", "prefix+ctrl+j" ]
    focus_pane_up = [ "prefix+k", "prefix+ctrl+k" ]
    focus_pane_right = [ "prefix+l", "prefix+ctrl+l" ]
    resize_pane_left = "prefix+shift+h"
    resize_pane_down = "prefix+shift+j"
    resize_pane_up = "prefix+shift+k"
    resize_pane_right = "prefix+shift+l"
    split_horizontal = [ "prefix+minus", "prefix+shift+minus" ]
    split_vertical = [ "prefix+v", "prefix+shift+5", "prefix+shift+backslash" ]
    move_tab_previous = "prefix+shift+comma"
    move_tab_next = "prefix+shift+period"
    copy_mode = "prefix+["
    # Herdr's zoom is the closest equivalent to the old narrow right-pane toggle.
    zoom = "ctrl+space"

    [[keys.command]]
    key = "prefix+f"
    type = "plugin_action"
    command = "sessionizer.open"
    description = "open a project workspace"

    [[keys.command]]
    key = "prefix+t"
    type = "plugin_action"
    command = "sessionizer.worktree-open"
    description = "open a worktree workspace"

    [ui]
    mouse_capture = true
    copy_on_select = true
    pane_borders = true
    pane_outer_borders = true
    window_title = "{workspace}: {terminal_title}"
    prompt_new_tab_name = false
    confirm_close = false
    tab_bar_position = "bottom"
    tab_bar_right_separator = " | "

    [advanced]
    scrollback_limit_bytes = 10000000

    [session]
    resume_agents_on_restore = true

    [worktrees]
    directory = "~/.herdr/worktrees"

    [ui.toast]
    delivery = "herdr"
    delay_seconds = 1
  '';

  # Install with: herdr plugin install andrewchng/herdr-sessionizer --yes
  home.file.".config/herdr/plugins/config/sessionizer/config.toml".text = ''
    [projects]
    roots = [ "~/workspace" ]
    git_only = true
    depth = 1

    [ui]
    placement = "popup"
    width = "80%"
    height = "80%"
  '';
}
