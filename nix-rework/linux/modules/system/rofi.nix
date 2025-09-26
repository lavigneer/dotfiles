{ config, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,run,combi";
      combi-modi = "drun,run";
      timeout = {
        action = "kb-cancel";
        delay = 0;
      };
      filebrowser = {
        directories-first = true;
        sorting-method = "name";
      };
    };
  };
}
