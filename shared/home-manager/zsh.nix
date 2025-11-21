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
      RIPGREP_CONFIG_PATH = "${config.home.homeDirectory}/.config/ripgrep/ripgreprc";
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
    '';
  };

}
