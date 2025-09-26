{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    ./git.nix
    ./zsh.nix
    ./neovim.nix
    ./tmux.nix
    ./terminals.nix
  ];

  programs = {
    # Core utilities
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ripgrep.enable = true;
    
    bat = {
      enable = true;
      config = {
        # Let stylix handle the theme, or use force if you want to override
        style = "numbers,changes,header";
      };
    };
    
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };
    
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Development tools
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # File managers
    yazi = {
      enable = true;
      enableZshIntegration = true;
    };

    # Starship prompt
    starship = {
      enable = true;
      enableZshIntegration = true;
      # You can add custom settings here or let it use defaults
      # settings = {
      #   # Custom starship configuration
      # };
    };

    # LazyGit
    lazygit.enable = true;

    # Zed editor (if available)
    zed-editor = pkgs.lib.mkIf (!isDarwin) {
      enable = true;
      userSettings = {
        features = { edit_prediction_provider = "copilot"; };
        vim_mode = true;
      };
      extensions = [
        "biome"
        "css"
        "dockerfile"
        "go"
        "golangci-lint"
        "html"
        "javascript"
        "json"
        "lua"
        "make"
        "nix"
        "ruff"
        "toml"
        "typescript"
        "yaml"
      ];
    };

    # Email (Thunderbird)
    thunderbird = pkgs.lib.mkIf (!isDarwin) {
      enable = true;
      profiles = {
        gmail.isDefault = true;
        hotmail.isDefault = false;
      };
    };

    # Rofi (Linux only)
    rofi = pkgs.lib.mkIf (!isDarwin) {
      enable = true;
    };
  };

  # Email accounts
  accounts.email.accounts = {
    "Gmail" = {
      primary = true;
      address = userEmail;
      userName = userEmail;
      realName = userFullName;
      thunderbird = pkgs.lib.mkIf (!isDarwin) { enable = true; };
      flavor = "gmail.com";
    };
  };
}
