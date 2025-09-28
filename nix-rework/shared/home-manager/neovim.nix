{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    
    extraPackages = with pkgs; [
      nil
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted
      lua-language-server
      gopls
      rust-analyzer
      pyright
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black
      rustfmt
      delve
      tree-sitter
      ripgrep
      fd
      nodePackages.neovim
    ];
    
    # Neovim configuration
    extraLuaConfig = ''
      -- Bootstrap lazy.nvim if your config uses it
      require('config.lazy')
      
      -- Basic settings that work well with your existing config
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.cursorline = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.ignorecase = true
      vim.opt.smartcase = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 50
      vim.opt.colorcolumn = "80"
      
      -- Clipboard setup
      if vim.fn.has('wsl') == 1 then
        vim.g.clipboard = {
          name = 'WslClipboard',
          copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
          },
          paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
          },
          cache_enabled = 0,
        }
      elseif vim.fn.has('macunix') == 1 then
        vim.opt.clipboard = "unnamedplus"
      else
        vim.opt.clipboard = "unnamedplus"
      end
    '';
  };

  # Neovim configuration files - keeping symlinks for complex, frequently-changed configs
  xdg.configFile = {
    # LazyVim lock files and configs that change frequently
    "nvim/lazy-lock.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazy-lock.json";
    "nvim/lazyvim.json".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lazyvim.json";
    
    # Custom Lua configuration - symlinked because it's actively developed
    "nvim/lua".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nvim/.config/nvim/lua";
    
    # Stylua formatter config (converted from symlink)
    "nvim/stylua.toml".text = ''
      indent_type = "Spaces"
      indent_width = 2
      column_width = 120
    '';
  };
}
