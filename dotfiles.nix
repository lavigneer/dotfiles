{
  config,
  pkgs,
  ...
}: let
  configSymlinksLib = import ./lib/configSymlinks.nix {inherit pkgs;};
  sources = import ./lib/sources {inherit pkgs;};

  # List of dotfiles where the path to link under
  # ~/.config/ matches the path in the dotfiles repo.
  # e.g. ~/.config/alacritty/alacritty.yml matches ./alacritty/alacritty.yml.
  simpleConfigFilesToLinkList = [
    "alacritty/alacritty.yml"
    "chemacs/profile"
    "chemacs/profiles.el"
    "direnv/direnvrc"
    "direnv/direnv.toml"
    "doom/config.el"
    "doom/init.el"
    "doom/packages.el"
    "emacs-rgoulter/init.el"
    "emacs-rgoulter/straight/versions/default.el"
    "fish/coloured-manpages.fish"
    "fish/config.fish"
    "fish/fishfile"
    "fish/functions/fisher.fish"
    "fish/keybindings.txt"
    "git/common.inc"
    "git/gpg.inc"
    "kitty/kitty.conf"
    "powerline/themes/tmux/default.json"
    "starship.toml"
    "tmux/tmux.conf"
  ];

  # Files where the symlinks aren't following a nice convention.
  unconventionalConfigFilesToLink = {
    "emacs" = sources.chemacs2;
    "nvim/init.vim" = ./vimrc;
    "tmux/plugins/tpm" = sources.tpm;
  };

  # e.g. "gvimrc" to link "~/.gvimrc" to ./gvimrc
  simpleHomeFilesToLinkList = [
    "gvimrc"
    "hgrc"
    "hgrc.d/fancy.style"

    "vimrc"
    "vim/after/ftplugin/org.vim"
  ];

  unconventionalHomeFilesToLink = {
    ".nvim/after/ftplugin/org.vim" = ./vim/after/ftplugin/org.vim;
    ".nvim/bundle/Vundle.vim" = sources.vundle;
    ".vim/bundle/Vundle.vim" = sources.vundle;
  };
in
  configSymlinksLib.mkSymlinkedDotfilesConfig {
    inherit
      simpleConfigFilesToLinkList
      unconventionalConfigFilesToLink
      simpleHomeFilesToLinkList
      unconventionalHomeFilesToLink
      ;
    symlinkFromDir = ./.;
  }
