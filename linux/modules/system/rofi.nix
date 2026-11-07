{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    settings = {
      modi = "drun,run,combi";
      combi-modi = "drun,run";
      timeout-action = "kb-cancel";
      timeout-delay = 0;
      filebrowser-directories-first = true;
      filebrowser-sorting-method = "name";
    };
  };
}
