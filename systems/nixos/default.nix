{ config, pkgs, inputs, username, userEmail, userFullName, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../shared/system/nix.nix
    ../../shared/system/fonts.nix
    ../../shared/system/shell.nix
    ../../shared/system/stylix.nix
    ../../linux/modules/system/gaming.nix
  ];

  home-manager.users.${username} = {
    imports = [
      ../../shared/home-manager/core.nix
      ../../shared/home-manager/cli-tools.nix
      ../../shared/home-manager/development.nix
      ../../shared/home-manager/git.nix
      ../../shared/home-manager/zsh.nix
      ../../shared/home-manager/nixvim
      ../../shared/home-manager/tmux.nix
      ../../shared/home-manager/terminals.nix
      ../../shared/home-manager/zed.nix
      ../../shared/home-manager/docker.nix
      ../../shared/home-manager/thunderbird.nix
      ../../shared/home-manager/discord.nix
      ../../shared/home-manager/browser.nix
      ../../linux/modules/programs/desktop-apps.nix
      ../../linux/modules/programs/gaming.nix
      ../../linux/modules/window-managers/i3.nix
      ../../linux/modules/window-managers/sway.nix
      ../../linux/modules/window-managers/hyprland.nix
    ];

    windowManagers = {
      i3.enable = true;
      sway.enable = true;
      hyprland.enable = true;
    };

    accounts.email.accounts = {
      "Hotmail" = {
        primary = true;
        address = userEmail;
        userName = userEmail;
        realName = userFullName;
        thunderbird = {
          enable = true;
          settings = id: {
            "mail.server.server_${id}.authMethod" = 10;
            "mail.smtpserver.smtp_${id}.authMethod" = 10;
          };
        };
        imap = {
          authentication = "xoauth2";
          host = "outlook.office365.com";
          port = 993;
          tls.enable = true;
        };
      };
    };
  };

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking configuration
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time zone and locale (machine-specific)
  time.timeZone = "America/Edmonton";
  i18n.defaultLocale = "en_CA.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_CA.UTF-8";
    LC_IDENTIFICATION = "en_CA.UTF-8";
    LC_MEASUREMENT = "en_CA.UTF-8";
    LC_MONETARY = "en_CA.UTF-8";
    LC_NAME = "en_CA.UTF-8";
    LC_NUMERIC = "en_CA.UTF-8";
    LC_PAPER = "en_CA.UTF-8";
    LC_TELEPHONE = "en_CA.UTF-8";
    LC_TIME = "en_CA.UTF-8";
  };

  # Machine-specific services
  services = {
    # Enable OpenSSH daemon for this machine
    openssh.enable = true;
  };

  # Machine-specific garbage collection settings (override platform defaults)
  nix.gc = {
    dates = "weekly";
    options = "--delete-older-than 60d"; # More aggressive than default for personal machine
  };
}
