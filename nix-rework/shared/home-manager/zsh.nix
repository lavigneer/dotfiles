{ config, pkgs, ... }:

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
      "os.symbols" = {
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
    
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "sudo"
        "docker"
        "kubectl"
        "tmux"
        "fzf"
      ];
      theme = "";
    };
    
    sessionVariables = {
      ZSH_TMUX_CONFIG = "${config.home.homeDirectory}/.config/tmux/tmux.conf";
    };
    
    shellAliases = {
      nix-shell = "nix-shell --run zsh";
      rebuild-nixos = "sudo nixos-rebuild switch --flake ~/workspace/dotfiles/nix-rework#nixos";
      rebuild-darwin = "darwin-rebuild switch --flake ~/workspace/dotfiles/nix-rework#mac";
      rebuild-home = "home-manager switch --flake ~/workspace/dotfiles/nix-rework";
    };
    
    # Additional shell initialization
    initExtra = ''
      # History settings
      setopt HIST_VERIFY
      setopt SHARE_HISTORY
      setopt EXTENDED_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_IGNORE_SPACE
      
      # Directory stack
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      
      # Correction
      setopt CORRECT
      setopt CORRECT_ALL
      
      # Key bindings
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      bindkey '^P' history-search-backward
      bindkey '^N' history-search-forward
      
      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # FZF key bindings and completion
      if command -v fzf-share >/dev/null; then
        source "$(fzf-share)/key-bindings.zsh"
        source "$(fzf-share)/completion.zsh"
      fi
    '';
    
    # History configuration
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };
  };
  
}
