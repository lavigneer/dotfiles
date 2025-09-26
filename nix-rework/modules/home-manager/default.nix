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
      TERMINAL = if isDarwin then "ghostty" else "ghostty";
      BROWSER = if isDarwin then "open" else "google-chrome";
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
      
      # Terminal emulators (removed - using manual installation)
      
    ] ++ pkgs.lib.optionals (!isDarwin) [
      # Linux-specific packages
      discord
      google-chrome
      lutris
      pavucontrol
      solaar
      dunst
      xclip
      nil # Nix LSP
    ] ++ pkgs.lib.optionals isDarwin [
      # macOS-specific packages
      mas # Mac App Store CLI
    ];
  };

  # File configurations using symlinks to your dotfiles
  home.file = {
    # Keep manual configs for things not managed by Nix programs
    ".local/bin/tmux-sessionizer".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.local/bin/tmux-sessionizer";
    
    # Manual zshrc for additional customizations
    ".zshrc.manual".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/zshrc/.zshrc";
  };

  # XDG config files
  xdg.configFile = {
    # Neovim configuration
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazyvim.json";
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lua";
    "nvim/stylua.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/stylua.toml";
    
    # Terminal configurations will be managed by Nix programs, not manual files
    
    # Shell configurations - starship managed by Nix programs
    
    # File manager
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi/.config/yazi";
    
    # Lazy git
    "lazygit".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazygit/.config/lazygit";
    
    # LazyDocker
    "lazydocker".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazydocker/.config/lazydocker";
    
  } // pkgs.lib.optionalAttrs (!isDarwin) {
    # Linux-specific configs
    "i3/config".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/i3/.config/i3/config";
    "polybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/polybar/.config/polybar";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "picom".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/picom/.config/picom";
    "dunst".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/dunst/.config/dunst";
    "sway".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/sway/.config/sway";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar/.config/waybar";
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hypr/.config/hypr";
    "wofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wofi/.config/wofi";
    "foot".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/foot/.config/foot";
  } // pkgs.lib.optionalAttrs isDarwin {
    # macOS-specific configs
    "aerospace".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/aerospace/.config/aerospace";
    "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/karabiner/.config/karabiner";
  };

  # Enable XDG directories
  xdg.enable = true;
}
