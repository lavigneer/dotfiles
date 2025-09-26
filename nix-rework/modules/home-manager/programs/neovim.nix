{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    
    # Extra packages available to Neovim
    extraPackages = with pkgs; [
      # Language servers
      nil # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.bash-language-server
      nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint
      lua-language-server
      gopls
      rust-analyzer
      pyright
      
      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier
      black
      rustfmt
      # gofmt is included with go package
      
      # DAP (Debug Adapter Protocol)
      delve # Go debugger
      
      # Tools
      tree-sitter
      ripgrep
      fd
      nodePackages.neovim
      
      # Clipboard support
      wl-clipboard # Wayland
      xclip # X11
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
}
