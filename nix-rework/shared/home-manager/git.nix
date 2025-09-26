{ config, pkgs, lib, userFullName, userEmail, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.git = {
    enable = true;
    userName = userFullName;
    userEmail = userEmail;
    
    extraConfig = lib.mkMerge [
      {
        init.defaultBranch = "main";
        core.editor = "nvim";
        pull.rebase = true;
        push.autoSetupRemote = true;
        diff.tool = "nvimdiff";
        merge.tool = "nvimdiff";
      }
      (lib.mkIf isDarwin {
        # Work-specific git settings for macOS
      })
    ];
  };
  
  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      editor = "nvim";
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # LazyGit - TUI for git
  programs.lazygit = {
    enable = true;
    # Additional lazygit configuration can go here
    # settings = {
    #   # Custom lazygit settings
    # };
  };

  # LazyGit config file symlink
  xdg.configFile."lazygit".source = config.lib.file.mkOutOfStoreSymlink 
    "${config.home.homeDirectory}/workspace/dotfiles/lazygit/.config/lazygit";
}
