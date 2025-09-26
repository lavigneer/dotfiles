{ config, pkgs, userFullName, userEmail, ... }:

{
  programs.git = {
    enable = true;
    userName = userFullName;
    # userEmail is set in platform-specific configurations
    
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
