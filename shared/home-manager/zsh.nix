{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Get editor completions based on the config schema
      "$schema" = "https://starship.rs/config-schema.json";

      # Inserts a blank line between shell prompts
      add_newline = false;

      # A minimal left prompt
      format = "$directory$git_branch$character";

      # move the rest of the prompt to the right
      right_format = "$all";

      line_break.disabled = true;

      aws.symbol = "  ";
      buf.symbol = " ";
      c.symbol = " ";
      conda.symbol = " ";
      crystal.symbol = " ";
      dart.symbol = " ";
      directory.read_only = " 󰌾";
      docker_context.symbol = " ";
      elixir.symbol = " ";
      elm.symbol = " ";
      fennel.symbol = " ";
      fossil_branch.symbol = " ";
      git_branch.symbol = " ";
      git_commit.tag_symbol = "  ";
      golang.symbol = " ";
      guix_shell.symbol = " ";
      haskell.symbol = " ";
      haxe.symbol = " ";
      hg_branch.symbol = " ";
      hostname.ssh_symbol = " ";
      java.symbol = " ";
      julia.symbol = " ";
      kotlin.symbol = " ";
      lua.symbol = " ";
      memory_usage.symbol = "󰍛 ";
      meson.symbol = "󰔷 ";
      nim.symbol = "󰆥 ";
      nix_shell = {
        symbol = " ";
        impure_msg = "";
      };
      nodejs.symbol = " ";
      ocaml.symbol = " ";
      os.symbols = {
        Alpaquita = " ";
        Alpine = " ";
        AlmaLinux = " ";
        Amazon = " ";
        Android = " ";
        Arch = " ";
        Artix = " ";
        CentOS = " ";
        Debian = " ";
        DragonFly = " ";
        Emscripten = " ";
        EndeavourOS = " ";
        Fedora = " ";
        FreeBSD = " ";
        Garuda = "󰛓 ";
        Gentoo = " ";
        HardenedBSD = "󰞌 ";
        Illumos = "󰈸 ";
        Kali = " ";
        Linux = " ";
        Mabox = " ";
        Macos = " ";
        Manjaro = " ";
        Mariner = " ";
        MidnightBSD = " ";
        Mint = " ";
        NetBSD = " ";
        NixOS = " ";
        OpenBSD = "󰈺 ";
        openSUSE = " ";
        OracleLinux = "󰌷 ";
        Pop = " ";
        Raspbian = " ";
        Redhat = " ";
        RedHatEnterprise = " ";
        RockyLinux = " ";
        Redox = "󰀘 ";
        Solus = "󰠳 ";
        SUSE = " ";
        Ubuntu = " ";
        Unknown = " ";
        Void = " ";
        Windows = "󰍲 ";
      };
      package.symbol = "󰏗 ";
      perl.symbol = " ";
      php.symbol = " ";
      pijul_channel.symbol = " ";
      python.symbol = " ";
      rlang.symbol = "󰟔 ";
      ruby.symbol = " ";
      rust.symbol = "󱘗 ";
      scala.symbol = " ";
      swift.symbol = " ";
      zig.symbol = " ";
      gradle.symbol = " ";
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "ssh-agent"
      ]
      ++ lib.optionals config.programs.tmux.enable [ "tmux" ]
      ++ lib.optionals config.programs.fzf.enable [ "fzf" ]
      ++ lib.optionals (lib.any (pkg: pkg.pname or pkg.name or "" == "asdf") config.home.packages) [
        "asdf"
      ]
      ++ lib.optionals (lib.any (pkg: pkg.pname or pkg.name or "" == "bazelisk") config.home.packages) [
        "bazel"
      ]
      ++ lib.optionals (lib.any (pkg: pkg.pname or pkg.name or "" == "lazydocker") config.home.packages) [
        "docker"
      ];
      theme = "";
    };

    sessionVariables = {
      ZSH_TMUX_CONFIG = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
      ZSH_TMUX_AUTOSTART = "true";
      ZSH_TMUX_AUTOCONNET = "false";
      ZSH_TMUX_AUTOQUIT = "false";
      ZSH_TMUX_AUTOSTART_ONCE = "false";
      ZSH_TMUX_DEFAULT_SESSION_NAME = "scratchpad";
      PROJECT_PATHS = "${config.home.homeDirectory}/workspace";
      RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.ripgreprc";
      XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
      PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
    };

    envExtra = ''
      export PATH=$HOME/.local/bin:$PATH:$HOME/.rd/bin

      # Ensure Nix per-user profile is in PATH early (only if not already present)
      if [ -d "/etc/profiles/per-user/$USER/bin" ] && [[ ":$PATH:" != *":/etc/profiles/per-user/$USER/bin:"* ]]; then
        export PATH="/etc/profiles/per-user/$USER/bin:$PATH"
      fi
    '';

    # Additional shell initialization
    initContent = ''
      # Source profile if it exists
      if test -f ~/.profile; then
        source ~/.profile
      fi

      # Completion configuration
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/.zcompcache"

      # Shell options from original .zshrc
      setopt NO_AUTOLIST BASH_AUTOLIST NO_MENUCOMPLETE

      # Custom functions
      # Conditional tmux autostart (disable in vscode)
      if [[ "$TERM_PROGRAM" != "vscode" ]]; then
        export ZSH_TMUX_AUTOSTART=true
      else
        export ZSH_TMUX_AUTOSTART=false
      fi

      # Additional plugins for tools not managed by nix
      if (( $+commands[brew] )); then
        plugins+=(brew)
      fi

      if (( $+commands[kubectl] )); then
        plugins+=(kubectl)
      fi

      # PATH additions
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

      # PNPM path setup
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac

      # Cargo environment
      [[ ! -r $HOME/.cargo/env ]] || source $HOME/.cargo/env > /dev/null 2> /dev/null

      # Go configuration (fallback if not set by nix)
      [[ ! -r /usr/local/go ]] || export GOROOT=/usr/local/go

      # OPAM configuration
      [[ ! -r $HOME/.opam/opam-init/init.zsh ]] || source $HOME/.opam/opam-init/init.zsh > /dev/null 2> /dev/null

      # FZF key bindings and completion
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi

      # FZF fallback paths (for non-nix systems)
      [[ ! -r /usr/share/doc/fzf/examples/key-bindings.zsh ]] || source /usr/share/doc/fzf/examples/key-bindings.zsh > /dev/null 2> /dev/null
      [[ ! -r /usr/share/doc/fzf/examples/completion.zsh ]] || source /usr/share/doc/fzf/examples/completion.zsh > /dev/null 2> /dev/null

      # Nix profile sourcing (for non-NixOS systems)
      if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then 
        . $HOME/.nix-profile/etc/profile.d/nix.sh
      fi

      # Ensure home-manager profile is in PATH (should be automatic but let's be explicit)
      if [ -d "/etc/profiles/per-user/$USER/bin" ] && [[ ":$PATH:" != *":/etc/profiles/per-user/$USER/bin:"* ]]; then
        export PATH="/etc/profiles/per-user/$USER/bin:$PATH"
      fi

      # Source home-manager session variables if available
      if [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
        . "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
      fi
    '';
  };

}
