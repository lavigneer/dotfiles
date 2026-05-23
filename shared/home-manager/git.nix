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
    settings = {
      user = {
        name = userFullName;
        email = userEmail;
      };
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = true;
      push.autoSetupRemote = true;
      diff.tool = "difftastic";
      merge = {
        tool = "nvimdiff";
        conflictStyle = "diff3";
        mergiraf = {
          name = "mergiraf";
          driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
        };
      };
      difftool.difftastic.cmd = ''difft "$LOCAL" "$REMOTE"'';
      pager.difftool = true;
      mergetool.mergiraf = {
        cmd = ''mergiraf merge --git "$BASE" "$LOCAL" "$REMOTE" -p "$MERGED"'';
        trustExitCode = true;
      };
    };
  };

  programs.git.attributes = [
    "* merge=mergiraf"
  ];

  home.packages = with pkgs; [
    difftastic
    mergiraf
  ];

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
        overrideGpg = true;
        pagers = [
          {
            colorArg = "never";
            externalDiffCommand = "difft --color=always --display inline";
          }
        ];
      };
      gui = {
        mouseEvents = false;
        nerdFontsVersion = "3";
      };
    };
  };
}
