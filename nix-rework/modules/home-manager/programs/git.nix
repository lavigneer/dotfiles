{ config, pkgs, userFullName, userEmail, ... }:

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
      
      # Better diff and merge tools
      diff.tool = "nvimdiff";
      merge.tool = "nvimdiff";
      
      # Signing commits (optional)
      # commit.gpgsign = true;
      # user.signingkey = "YOUR_GPG_KEY_ID";
    };
    
    # Git aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      ca = "commit -a";
      cam = "commit -am";
      cp = "cherry-pick";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
      
      # Pretty logs
      lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      ll = "log --oneline";
      
      # Useful shortcuts
      pushf = "push --force-with-lease";
      amend = "commit --amend --no-edit";
      fixup = "commit --fixup";
      squash = "commit --squash";
    };
    
    # Delta for better diffs (if you want to try it)
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        line-numbers = true;
        syntax-theme = "base16";
      };
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
}
