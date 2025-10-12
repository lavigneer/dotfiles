{ config, pkgs, ... }:

{
  services.polybar = {
    enable = true;
    package = pkgs.polybar;

    config = {
      # Font configuration
      "fonts" = {
        opensansreg = "JetBrainsMono Nerd Font:Regular:size=11";
        opensanssemibold = "JetBrainsMono Nerd Font:SemiBold:size=11";
        opensansbold = "JetBrainsMono Nerd Font:Bold:size=11";
        opensansboldhigh = "JetBrainsMono Nerd Font:Bold:size=12";
        opensansital = "JetBrainsMono Nerd Font:Italic:size=11";
        xos = "Nimbus Sans:size=14;0";
        nerd = "JetBrainsMono Nerd Font:size=12;0";
      };

      # Color scheme
      "colors" = {
        light-red = "#D95B5B";
        light-green = "#249824";
        light-purple = "#A44BA0";

        menucol-yellow = "#F7F272";
        menucol-blue = "#1771F1";
        menucol-orange = "#FFAF60";
        menucol-red = "#F85C50";
        menucol-green = "#77BD8B";
        menucol-sealine = "#00CF91";
        menucol-purple = "#9A76B3";
        menucol-pink = "#FF77BF";
        menucol-deepblue = "#6560FF";
        menucol-lightblue = "#60FFF7";

        fav-purple = "#6633FF";
        dark = "#111";
        dark-red = "#311";
        dark-green = "#131";
        dark-purple = "#201134";
      };
    };

    script = ''
      # Polybar startup script
      pkill polybar
      sleep 1
      polybar main &
    '';
  };
}
