{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    dunst
    picom
    feh
    xss-lock
    xclip
    xorg.xrandr
    xorg.xset
  ];

  # Picom X11 compositor configuration
  services.picom = {
    enable = true;
    package = pkgs.picom;
    
    # Shadows
    shadow = true;
    shadowExclude = [
      "name = 'Notification'"
      "class_g = 'Conky'"
      "class_g ?= 'Notify-osd'"
      "class_g = 'Cairo-clock'"
      "_GTK_FRAME_EXTENTS@:c"
    ];
    
    # Fading
    fade = false;
    
    # Transparency/Opacity
    activeOpacity = 1.0;
    inactiveOpacity = 0.95;
    opacityRules = [];
    
    # Background blurring
    settings = {
      # Shadow settings
      shadow-radius = 7;
      shadow-offset-x = -7;
      shadow-offset-y = -7;
      
      # Fade settings
      fade-in-step = 0.03;
      fade-out-step = 0.03;
      
      # Backend
      backend = "xrender";
      
      # VSync
      vsync = true;
      
      # Window detection
      mark-wmwin-focused = true;
      mark-ovredir-focused = true;
      detect-rounded-corners = true;
      detect-client-opacity = true;
      detect-transient = true;
      
      # Performance
      glx-no-stencil = true;
      use-damage = true;
      
      # Corners
      corner-radius = 0;
      rounded-corners-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
      ];
      
      # Blurring
      blur-kern = "3x3box";
      blur-background-exclude = [
        "window_type = 'dock'"
        "window_type = 'desktop'"
        "_GTK_FRAME_EXTENTS@:c"
      ];
      
      # Focus
      focus-exclude = [ "class_g = 'Cairo-clock'" ];
      
      # Logging
      log-level = "warn";
      
      # Window types
      wintypes = {
        tooltip = { fade = true; shadow = true; opacity = 1.0; focus = true; full-shadow = false; };
        dock = { shadow = false; clip-shadow-above = true; };
        dnd = { shadow = false; };
        popup_menu = { opacity = 1.0; };
        dropdown_menu = { opacity = 1.0; };
      };
    };
  };
  
  # Remove broken dunst symlink (directory doesn't exist)
  # TODO: Add dunst configuration if needed

  services = {
    dunst.enable = true;
    screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -c 000000";
    };
  };

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = lib.mkDefault "X11";
  };

  xsession = {
    enable = true;
    profileExtra = "export TERMINAL=ghostty";
  };
}
