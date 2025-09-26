{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/workspace/dotfiles";
in
{
  programs = {
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ripgrep.enable = true;
    
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    yazi = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  home.packages = with pkgs; [
    btop
    htop
    fd
    tree
    dig
    curl
    wget
    unzip
    jq
    gawk
    gnugrep
    gnused
  ];

  xdg.configFile = {
    "yazi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/yazi/.config/yazi";
  };
}
