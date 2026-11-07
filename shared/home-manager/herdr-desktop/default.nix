{
  config,
  lib,
  pkgs,
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

  defaultKeys = lib.importJSON "${pkgs.herdr-desktop.src}/defaults/keys.json";
  keys = lib.recursiveUpdate defaultKeys { global = tuiKeys; };

  # Our mods. Installed as real files, not links: herdr-app resolves module
  # imports to their real path and refuses ones outside the mod folder (a
  # /nix/store link is), and it writes jsconfig.json and typings into the
  # folder. So the shared modules (lib.js, data.js, config.js) are copied into
  # each mod.
  configValues = {
    ROOTS = [ "${config.home.homeDirectory}/workspace" ];
    DEPTH = 1;
    JIRA = lib.getExe pkgs.jira-cli-go;
    GH = lib.getExe config.programs.gh.package;
    GIT = lib.getExe config.programs.git.package;
    JQL = cfg.tickets.jql;
    BRANCH_PREFIX = cfg.tickets.branchPrefix;
    WORKTREE_DIR = cfg.tickets.worktreeDir;
    GITHUB_OWNERS = cfg.tickets.githubOwners;
    PROJECTS = cfg.tickets.projects;
    COMPONENTS = cfg.tickets.components;
    AGENT = cfg.tickets.agent;
    TASK = cfg.tickets.task;
    EXTRA_BRANCH_TASK = cfg.tickets.extraBranchTask;
  };
  configJs =
    name: values:
    pkgs.writeText name (
      "// Written by Nix (shared/home-manager/herdr-desktop/default.nix).\n"
      + lib.concatStrings (
        lib.mapAttrsToList (k: v: "export const ${k} = ${builtins.toJSON v};\n") values
      )
    );
  mods = {
    # Sessionizer-style project picker (prefix+f)
    projects = ./projects;
    # Jira ticket -> worktree -> agent popup (prefix+t)
    tickets = ./tickets;
    # Repo -> worktree outline for the sidebar (in the "work" layout)
    work = ./work;
  };
  modFilesWith =
    configFile:
    lib.mapAttrs (_: dir: {
      "config.js" = configFile;
      "lib.js" = ./lib.js;
      "data.js" = ./data.js;
      "main.js" = dir + "/main.js";
      "mod.json" = dir + "/mod.json";
    }) mods;

  # Shell lines copying the mods into "$1"/<mod>/ as real files; `run` is
  # Home Manager's dry-run-aware wrapper, or nothing for the demo.
  installModsLines =
    run: modFiles:
    lib.concatStrings (
      lib.mapAttrsToList (mod: files: ''
        ${run} mkdir -p "$1/${mod}"
        ${lib.concatStrings (
          lib.mapAttrsToList (name: source: ''
            if [[ -L "$1/${mod}/${name}" ]]; then ${run} rm "$1/${mod}/${name}"; fi
            ${run} install -m 644 ${source} "$1/${mod}/${name}"
          '') files
        )}
      '') modFiles
    );

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

  # herdr-demo: a separate Herdr app over fake tickets, PRs and repos (see demo/).
  demoVars = ''
    : "''${HERDR_DEMO:=''${XDG_STATE_HOME:-$HOME/.local/state}/herdr-demo}"
    : "''${HERDR_DEMO_DATA:=${./demo/data.json}}"
    export HERDR_DEMO HERDR_DEMO_DATA
  '';
  demoTool =
    name: inputs:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = inputs;
      text = demoVars + builtins.readFile (./demo + "/${name}.sh");
    };
  demoJira = demoTool "jira" [ pkgs.jq ];
  demoGh = demoTool "gh" [
    pkgs.jq
    config.programs.git.package
  ];
  demoAgent = demoTool "agent" [ config.programs.git.package ];
  demoConfig = configJs "herdr-demo-config.js" (
    configValues
    // {
      ROOTS = [ "@HERDR_DEMO@/ws" ];
      JIRA = lib.getExe demoJira;
      GH = lib.getExe demoGh;
      AGENT = [ (lib.getExe demoAgent) ];
      GITHUB_OWNERS = [ "10gen" ];
      COMPONENTS = {
        Fern = "10gen/fern";
        Docs = "10gen/docs";
      };
      PROJECTS = {
        WEB = "10gen/web-app";
        API = "otherorg/api";
      };
    }
  );
  herdrDemo = pkgs.writeShellApplication {
    name = "herdr-demo";
    runtimeInputs = with pkgs; [
      herdr-desktop
      jq
      config.programs.git.package
      coreutils
      gnused
      procps
      util-linux # setsid
    ];
    text =
      demoVars
      + ''
        install_mods() {
          ${installModsLines "" (modFilesWith demoConfig)}
        }
        install_app_files() {
          mkdir -p "$1/layouts" "$1/themes"
          install -m 644 ${pkgs.writeText "keys.json" (builtins.toJSON keys)} "$1/keys.json"
          install -m 644 ${managedSettings} "$1/settings.json"
          install -m 644 ${pkgs.writeText "kanagawa.json" (builtins.toJSON kanagawa)} "$1/themes/kanagawa.json"
          install -m 644 ${workLayout} "$1/layouts/work.json"
        }
      ''
      + builtins.readFile ./demo/herdr-demo.sh;
  };
in
{
  options.herdrDesktop.tickets = {
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
    task = lib.mkOption {
      type = lib.types.str;
      default = "Work on Jira ticket {key}: {summary}\n\nRun `jira issue view {key} --plain --comments 20` for the description and comments.";
      description = "First message to the agent for a new worktree; {key} and {summary} are filled in.";
    };
    extraBranchTask = lib.mkOption {
      type = lib.types.str;
      default = "Start another piece of work for Jira ticket {key}: {summary}\n\nCreate a git worktree under {worktreeDir}/ in this repo on a new branch named {prefix}{key}-<short-description> (pick a short kebab-case description of the change), then work in it. Run `jira issue view {key} --plain --comments 20` for the description and comments.";
      description = ''
        First message to the agent asked for another branch of a ticket in a repo
        that already has one; it names and creates the branch itself. {key},
        {summary}, {prefix} and {worktreeDir} are filled in.
      '';
    };
  };

  config = {
    home.packages = [
      pkgs.herdr-desktop
      # Jira Server/Data Center access for the tickets mod. Log in once with
      # `jira init --installation local --auth-type bearer` and a personal access
      # token (kept in JIRA_API_TOKEN, ~/.netrc or the OS keychain).
      pkgs.jira-cli-go
      # Try the mods against fake tickets/PRs/repos in a separate Herdr app.
      herdrDemo
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
    };

    home.activation.herdrAppMods = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      # The "work" layout: switch to it once with `herdr-app do layout.switch --name work`.
      layouts="${config.xdg.configHome}/herdr-app/layouts"
      run mkdir -p "$layouts"
      run install -m 644 ${workLayout} "$layouts/work.json"

      install_mods() {
        ${installModsLines "run" (modFilesWith (configJs "herdr-app-mods-config.js" configValues))}
      }
      install_mods "${config.xdg.configHome}/herdr-app/mods"
    '';
  };
}
