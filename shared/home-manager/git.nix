{
  config,
  pkgs,
  lib,
  userFullName,
  userEmail,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.git = {
    enable = true;
    userName = userFullName;
    userEmail = userEmail;

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
    };
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
    settings = {
      git = {
        autoFetch = false;
      };
      gui = {
        mouseEvents = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
