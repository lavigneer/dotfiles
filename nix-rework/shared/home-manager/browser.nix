{ config, pkgs, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Firefox configuration
  programs.firefox = {
    enable = true;
    
    profiles = {
      default = {
        id = 0;
        isDefault = true;
        
        settings = {
          # Privacy and security
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.donottrackheader.enabled" = true;
          
          # Performance
          "browser.sessionstore.resume_from_crash" = false;
          "browser.sessionstore.restore_on_demand" = true;
          "browser.sessionstore.restore_tabs_lazily" = true;
          
          # Interface preferences
          "browser.tabs.firefox-view" = false;
          "browser.toolbars.bookmarks.visibility" = "always";
          "browser.uidensity" = 1; # Compact mode
          
          # Developer tools
          "devtools.theme" = "dark";
          "devtools.toolbox.host" = "right";
          
          # Downloads
          "browser.download.useDownloadDir" = false; # Always ask where to save
          
          # Search
          "browser.search.suggest.enabled" = false;
          "browser.urlbar.suggest.searches" = false;
          
          # Disable telemetry
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
        };
        
        # Extensions (requires manual installation or additional configuration)
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          # Common useful extensions
          # ublock-origin
          # bitwarden
          # privacy-badger
          # decentraleyes
        ];
        
        # Bookmarks toolbar
        bookmarks = [
          {
            name = "Development";
            toolbar = true;
            bookmarks = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
              {
                name = "NixOS Manual";
                url = "https://nixos.org/manual/nixos/stable/";
              }
              {
                name = "Home Manager Manual";
                url = "https://nix-community.github.io/home-manager/";
              }
            ];
          }
        ];
      };
    };
  };
  
  # Additional browsers
  home.packages = with pkgs; [
    google-chrome
  ] ++ lib.optionals (!isDarwin) [
    chromium
  ];

  home.sessionVariables = {
    BROWSER = if isDarwin then "open" else "firefox";
  };
}
