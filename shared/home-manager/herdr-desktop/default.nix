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

  # The projects mod is linked file by file, so its folder stays a real,
  # writable directory: herdr-app writes jsconfig.json and typings into it.
  projectsMod = {
    "main.js" = ./projects/main.js;
    "mod.json" = ./projects/mod.json;
  };

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
  home.packages = [ pkgs.herdr-desktop ];

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

    # Sessionizer-style project picker (prefix+f)
    "herdr-app/mods/projects/config.js".text = ''
      // Written by Nix (shared/home-manager/herdr-desktop/default.nix).
      export const ROOTS = ${builtins.toJSON [ "${config.home.homeDirectory}/workspace" ]};
      export const DEPTH = 1;
    '';
  }
  // lib.mapAttrs' (
    name: source: lib.nameValuePair "herdr-app/mods/projects/${name}" { inherit source; }
  ) projectsMod;
}
