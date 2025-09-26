{ config, pkgs, inputs, username, userFullName, userEmail, ... }:

let
  # Check if we're running on macOS
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  
  # Dotfiles path - adjust this to your actual dotfiles location
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  imports = [
    ./programs
    ./services
  ];

  # Basic user info
  home = {
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
    };

    # User packages that should be available on both systems
    packages = with pkgs; [
      # Development tools
      cargo
      rustup
      rustc
      go
      nodejs_24
      zig
      
      # CLI utilities
      btop
      fzf
      ripgrep
      fd
      bat
      eza
      zoxide
      jq
      curl
      wget
      unzip
      tree
      
      # Git and version control
      git
      lazygit
      gh
      
      # Text processing (sed, awk, grep are in coreutils/gawk/gnugrep)
      gawk
      gnugrep
      gnused
      
      # Network tools
      dig
      
      # System monitoring
      htop
      
      # File management
      yazi
    ];
  };

  # File configurations using symlinks to your dotfiles
  home.file = {
    # Keep manual configs for things not managed by Nix programs
    ".local/bin/tmux-sessionizer".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.local/bin/tmux-sessionizer";
    
    # Manual zshrc for additional customizations
    ".zshrc.manual".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/zshrc/.zshrc";
  };

  # XDG config files (shared across platforms)
  xdg.configFile = {
    # Neovim configuration
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazyvim.json";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lua";
    "nvim/stylua.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/stylua.toml";
    
    # File manager
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi/.config/yazi";
    
    # LazyDocker
    "lazydocker".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazydocker/.config/lazydocker";
    
    # Lazy git config moved to git.nix module
  };

  # Enable XDG directories
  xdg.enable = true;
}
