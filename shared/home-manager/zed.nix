{ config, pkgs, lib, ... }:

let
  cfg = config.programs.zed-editor;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Zed Editor configuration
  programs.zed-editor = {
    enable = lib.mkDefault true;
    
    userSettings = {
      # Core editor settings
      features = { 
        edit_prediction_provider = "copilot"; 
      };
      vim_mode = lib.mkDefault true;
      
      # Editor behavior
      soft_wrap = lib.mkDefault "editor_width";
      tab_size = lib.mkDefault 2;
      indent_guides = {
        enabled = lib.mkDefault true;
      };
      
      # Terminal integration
      terminal = {
        shell = {
          program = lib.mkDefault "zsh";
        };
        font_size = lib.mkDefault (if isDarwin then 13 else 11);
      };
      
      # File management
      auto_save = lib.mkDefault "on_focus_change";
      format_on_save = lib.mkDefault "on";
      
      # Git integration
      git = {
        git_gutter = "tracked_files";
        inline_blame = {
          enabled = true;
        };
      };
      
      # Language servers and formatting
      lsp = {
        rust-analyzer = {
          binary = {
            path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
          };
        };
        nil = {
          binary = {
            path = "${pkgs.nil}/bin/nil";
          };
        };
      };
      
      # Collaboration
      calls = {
        mute_on_join = true;
        share_on_join = false;
      };
    };
    
    # Extensions to install
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
      # Platform-specific extensions
    ] ++ lib.optionals (!isDarwin) [
      # Linux-specific extensions if any
    ] ++ lib.optionals isDarwin [
      # macOS-specific extensions if any
    ];
  };
  
  # Additional packages that Zed might need
  home.packages = with pkgs; [
    # Language servers (if not already included elsewhere)
    nil
    rust-analyzer
    
    # Formatters that Zed extensions might use
    nixpkgs-fmt
    rustfmt
  ];
}
