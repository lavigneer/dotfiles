{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

# Herdr desktop app (herdr-app): a GUI for persistent terminals and coding
# agents, backed by its own herdr-core server. Separate from the `herdr` TUI
# configured in ../herdr.nix. Imported per machine; becomes the default terminal.
#
# Docs for everything under ~/.config/herdr-app:
# https://github.com/herdrdev/herdr-app/blob/main/defaults/AGENTS.md

let
  cfg = config.herdrDesktop;

  # Bindings resembling the herdr TUI (../herdr.nix plus the TUI's defaults),
  # added on top of herdr-app's own default keys. Prefix keys are GPUI key
  # sequences ("ctrl-b h": Ctrl+B, then H). Shifted punctuation is bound under
  # both spellings ("ctrl-b %" and "ctrl-b shift-%"), as herdr-app's own
  # defaults do. Not available in herdr-app, so not bound: pane resize
  # (prefix+shift+hjkl), copy mode (prefix+[), moving tabs (prefix+< / >),
  # scrollback in $EDITOR (prefix+e) and pane cycling (prefix+tab).
  prefix = "ctrl-b";
  p = key: "${prefix} ${key}";
  # Nix strings have no \u escapes; get the real control character from JSON.
  ctrlB = builtins.fromJSON ''"\u0002"'';
  both = keys: action: lib.genAttrs (map p keys) (_: action);

  tuiKeys = lib.mergeAttrsList [
    {
      # Ctrl+B is the prefix now; press it twice to send it to the program.
      "${p "ctrl-b"}" = "send:${ctrlB}";

      # Panes
      "${p "h"}" = "pane.go:left";
      "${p "j"}" = "pane.go:down";
      "${p "k"}" = "pane.go:up";
      "${p "l"}" = "pane.go:right";
      "${p "ctrl-h"}" = "pane.go:left";
      "${p "ctrl-j"}" = "pane.go:down";
      "${p "ctrl-k"}" = "pane.go:up";
      "${p "ctrl-l"}" = "pane.go:right";
      "${p "v"}" = "pane.split:right";
      "${p "-"}" = "pane.split:down";
      "${p "x"}" = "pane.close";
      "${p "z"}" = "pane.zoom";
      "ctrl-space" = "pane.zoom";

      # Tabs
      "${p "c"}" = "tab.new";
      "${p "n"}" = "tab.next";
      "${p "p"}" = "tab.prev";
      "${p "shift-x"}" = "tab.close";
      "${p "shift-t"}" = "tab.rename";

      # Spaces (the TUI's workspaces)
      "${p "f"}" = "mod.open:projects";
      "${p "t"}" = "mod.open:tickets";
      "${p "w"}" = "mod.open:picker";
      "${p "shift-n"}" = "space.new";
      "${p "shift-w"}" = "space.rename";
      "${p "shift-d"}" = "space.close";

      # App. Closing the window keeps terminals running, like detaching.
      "${p "q"}" = "window.close";
      "${p "s"}" = "app.settings";
      "${p "b"}" = "layout.toggle:sidebar";
    }
    (both [ "_" "shift-_" ] "pane.split:down")
    (both [ "%" "shift-%" "|" "shift-|" "\\" ] "pane.split:right")
    (both [ "?" "shift-?" "shift-/" ] "app.help")
    (lib.listToAttrs (
      map (n: lib.nameValuePair (p (toString n)) "tab.select:${toString n}") (lib.range 1 9)
    ))
  ];

  # The projects, tickets and work mods (and the Claude commands and demo) come
  # from github.com/lavigneer/herdr-ticket-flow; this module only configures them.
  ticketFlow = inputs.herdr-ticket-flow.packages.${pkgs.stdenv.hostPlatform.system}.default;
  ticketFlowShare = "${ticketFlow}/share/herdr-ticket-flow";

  # herdr-ticket-flow's Work sidebar keys (Alt+Shift+arrows/Enter/O/P/T), as
  # its keys.json ships them. Its popup keys (Ctrl+Shift+J/F) are left out:
  # those open under the Ctrl+B prefix above.
  workKeys = lib.filterAttrs (
    _: action: lib.hasPrefix "work." action
  ) (lib.importJSON "${inputs.herdr-ticket-flow}/keys.json").global;

  defaultKeys = lib.importJSON "${pkgs.herdr-desktop.src}/defaults/keys.json";
  keys = lib.recursiveUpdate defaultKeys { global = workKeys // tuiKeys; };

  # The mods' settings (ticket-flow.json in the app home), from the options below.
  ticketFlowSettings = {
    roots = [ "${config.home.homeDirectory}/workspace" ];
    depth = 1;
    programs = {
      git = lib.getExe config.programs.git.package;
      gh = lib.getExe config.programs.gh.package;
      jira = lib.getExe pkgs.jira-cli-go;
      hc = lib.getExe' pkgs.herdr-core "hc";
    };
    inherit (cfg.tickets) tracker github;
    jira = {
      inherit (cfg.tickets) jql transitions resolution;
    };
    inherit (cfg.tickets) githubOwners worktreeDir;
    repoRules =
      lib.mapAttrsToList (component: repo: { inherit component repo; }) cfg.tickets.components
      ++ lib.mapAttrsToList (project: repo: { inherit project repo; }) cfg.tickets.projects;
    branch = "${cfg.tickets.branchPrefix}{ref}";
    agent.argv = cfg.tickets.agent;
  };

  # The shipped main layout with the work outline between Spaces and Agents.
  # A copy, so it won't pick up changes to Herdr's main layout; regenerated
  # from the installed version on every rebuild.
  mainLayout = lib.importJSON "${pkgs.herdr-desktop.src}/defaults/layouts/main.json";
  addWork =
    node:
    if node.id or null == "sidebar-lists" then
      node
      // {
        children = lib.concatMap (
          child:
          [ child ]
          ++ lib.optional (child.id or null == "spaces") {
            id = "work-outline";
            type = "block";
            content.mod = "work";
            size.weight = 1;
            min = 90;
          }
        ) node.children;
      }
    else if node ? children then
      node // { children = map addWork node.children; }
    else
      node;
  workLayout = pkgs.writeText "herdr-app-work-layout.json" (builtins.toJSON (addWork mainLayout));

  # Settings Nix owns; merged into settings.json on every activation (below).
  managedSettings = pkgs.writeText "herdr-app-settings.json" (
    builtins.toJSON {
      font = "JetBrainsMono Nerd Font";
      font_size = 12;
      # Dark half of the layout's theme; pick Kanagawa once with the theme
      # picker (or `herdr-app do app.theme --name kanagawa`).
      appearance = "dark";
      # The Nix build never sends telemetry (only release builds do); this
      # keeps it off if the binary ever changes.
      telemetry = false;
    }
  );

  # Herdr theme from the Stylix scheme (Kanagawa), with the usual base16 ANSI mapping.
  kanagawa =
    let
      c = config.lib.stylix.colors.withHashtag;
    in
    {
      background = c.base00;
      foreground = c.base05;
      selection = c.base02;
      cursor = c.base05;
      ansi = [
        c.base00
        c.base08
        c.base0B
        c.base0A
        c.base0D
        c.base0E
        c.base0C
        c.base05
        c.base03
        c.base08
        c.base0B
        c.base0A
        c.base0D
        c.base0E
        c.base0C
        c.base07
      ];
    };

in
{
  options.herdrDesktop.tickets = {
    tracker = lib.mkOption {
      type = lib.types.enum [
        "jira"
        "github"
      ];
      default = "jira";
      description = "Where tickets come from: Jira (jira-cli) or GitHub issues (gh).";
    };
    github = {
      repos = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "lavigneer/herdr-ticket-flow" ];
        description = "With the GitHub tracker: only issues in these repos (owner/repo); empty: anywhere.";
      };
      assignee = lib.mkOption {
        type = lib.types.str;
        default = "@me";
        description = "With the GitHub tracker: list open issues assigned to this user.";
      };
      search = lib.mkOption {
        type = lib.types.str;
        default = "";
        example = "label:bug";
        description = "With the GitHub tracker: extra GitHub search terms.";
      };
      ref = lib.mkOption {
        type = lib.types.str;
        default = "issue-{number}";
        description = "With the GitHub tracker: an issue's part of a branch name.";
      };
      closeOnFinish = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "With the GitHub tracker: close the issue at Finish if merging didn't.";
      };
    };
    components = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        Fern = "10gen/fern";
      };
      description = ''
        Jira component -> repo ("owner/repo" on GitHub, or a local path) for new
        work on a ticket. Checked before `projects`; a repo that isn't cloned yet
        is cloned into the workspace with gh.
      '';
    };
    projects = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        WEB = "10gen/web-app";
      };
      description = ''
        Jira project key -> repo ("owner/repo" or a local path), when no
        component says otherwise. Without either, existing work, the last repo
        used for the ticket and the focused repo are suggested, and any local
        repo can be picked.
      '';
    };
    githubOwners = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "10gen" ];
      description = ''
        GitHub orgs/users searched for pull requests that mention a ticket, in
        addition to the owners of your local repos and of the repos above.
      '';
    };
    jql = lib.mkOption {
      type = lib.types.str;
      # Naming `project` makes jira-cli search every project, not just its default one.
      default = "project IS NOT EMPTY AND assignee = currentUser() AND resolution = Unresolved";
      description = "Which tickets to list (jira-cli adds the ORDER BY).";
    };
    branchPrefix = lib.mkOption {
      type = lib.types.str;
      default = "lavigneer/";
      description = "Branch for a ticket: this prefix plus its key.";
    };
    worktreeDir = lib.mkOption {
      type = lib.types.str;
      default = ".claude/worktrees";
      description = "Where ticket worktrees go, relative to the repo's main checkout.";
    };
    agent = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "claude" ];
      description = "Agent started in a ticket's space.";
    };
    transitions = {
      start = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "In Progress";
        description = "Jira transition when work on a ticket starts (tickets popup), or null for none.";
      };
      review = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "In Review";
        description = "Jira transition when its PR is marked ready for review (Work sidebar), or null.";
      };
      done = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "Resolved";
        description = ''
          Jira transition after the PR merged and Finish cleaned up its worktree,
          or null. Skipped while other work on the ticket is still open.
        '';
      };
    };
    resolution = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "Fixed";
      description = "Resolution set with the `done` transition, if its screen asks for one.";
    };
  };

  config = {
    home.packages = [
      pkgs.herdr-desktop
      # Jira Server/Data Center access for the tickets mod. Log in once with
      # `jira init --installation local --auth-type bearer` and a personal access
      # token (kept in JIRA_API_TOKEN, ~/.netrc or the OS keychain).
      pkgs.jira-cli-go
      # herdr-demo (the mods against fake tickets/PRs/repos in a separate Herdr
      # app) and herdr-ticket-flow-install.
      ticketFlow
    ];

    # Default terminal for the window managers (Super+Return) and $TERMINAL.
    # Overrides the ghostty default in core.nix; ghostty stays installed.
    home.sessionVariables.TERMINAL = "herdr-app";

    # settings.json must stay a real file: the app saves through symlinks, so a
    # Nix store link makes every in-app change (theme, zoom, sounds) fail. Merge
    # the Nix-owned keys in on each activation and keep whatever else the app saved.
    home.activation.herdrAppSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      settings="${config.xdg.configHome}/herdr-app/settings.json"
      run mkdir -p "$(dirname "$settings")"
      if [[ -L "$settings" ]]; then
        run rm "$settings"
      fi
      if [[ -s "$settings" ]] && ${lib.getExe pkgs.jq} -e 'type == "object"' "$settings" >/dev/null 2>&1; then
        tmp="$(mktemp "$settings.XXXXXX")"
        ${lib.getExe pkgs.jq} -s '.[0] * .[1]' "$settings" ${managedSettings} > "$tmp"
        chmod 644 "$tmp"
        run mv "$tmp" "$settings"
      else
        run install -m 644 ${managedSettings} "$settings"
      fi
    '';

    # Read-only links are fine for these: the app only reads them (keys.json is
    # rewritten only by app.reset, which then fails harmlessly).
    xdg.configFile = {
      "herdr-app/keys.json" = {
        force = true;
        text = builtins.toJSON keys;
      };

      "herdr-app/themes/kanagawa.json".text = builtins.toJSON kanagawa;

      # The mods only read their settings.
      "herdr-app/ticket-flow.json".text = builtins.toJSON ticketFlowSettings;
    };

    home.activation.herdrAppMods = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      # The "work" layout: switch to it once with `herdr-app do layout.switch --name work`.
      layouts="${config.xdg.configHome}/herdr-app/layouts"
      run mkdir -p "$layouts"
      run install -m 644 ${workLayout} "$layouts/work.json"

      # Real copies, not links: herdr-app resolves module imports to their real
      # path and refuses ones outside the mod folder (a /nix/store link is), and
      # writes jsconfig.json and typings into it.
      mods="${config.xdg.configHome}/herdr-app/mods"
      run mkdir -p "$mods"
      for mod in ${ticketFlowShare}/mods/*; do
        name="$(basename "$mod")"
        run rm -rf "$mods/$name"
        run cp -R "$mod" "$mods/$name"
        run chmod -R u+w "$mods/$name"
      done
    '';
  };
}
