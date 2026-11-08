{
  config,
  pkgs,
  inputs,
  username,
  userEmail,
  userFullName,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware.nix

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
      ../../shared/home-manager/herdr-desktop
      ../../shared/home-manager/zed.nix
      ../../shared/home-manager/docker.nix
      ../../shared/home-manager/thunderbird.nix
      ../../shared/home-manager/discord.nix
      ../../shared/home-manager/browser.nix
      ../../shared/home-manager/claude.nix
      ../../linux/modules/programs/desktop-apps.nix
      ../../linux/modules/programs/gaming.nix
      ../../linux/modules/window-managers/i3.nix
      ../../linux/modules/window-managers/sway.nix
    ];

    windowManagers = {
      i3.enable = true;
      sway.enable = true;
    };

    # Personal projects track their work in GitHub issues (open ones assigned
    # to me, in any repo); branches are lavigneer/issue-<number>.
    herdrDesktop.tickets.tracker = "github";

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

    # Graphical login screen (LightDM) that launches the Home Manager-managed
    # X session. i3 itself (config, startup apps, bar, dunst, etc.) is
    # configured in ../../linux/modules/window-managers/i3.nix via Home Manager.
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.session = [
        {
          name = "i3";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };
    displayManager.defaultSession = "i3";
  };

  # i3lock (run by xss-lock from home-manager's screen-locker) authenticates
  # via the "i3lock" PAM service. The custom i3 session above doesn't enable
  # NixOS's i3 module, so nothing creates it and PAM falls back to "other",
  # which denies every password. (Sway's programs.sway adds swaylock's.)
  security.pam.services.i3lock = { };

  # Sway (Wayland). Registers a "Sway" session in the login screen; the sway
  # config itself comes from ../../linux/modules/window-managers/sway.nix.
  programs.sway = {
    enable = true;
    # Sway refuses to start on the proprietary NVIDIA driver without this flag
    extraOptions = [ "--unsupported-gpu" ];
  };

  # Machine-specific garbage collection settings (override platform defaults)
  nix.gc = {
    dates = "weekly";
    options = "--delete-older-than 60d"; # Keep history longer than the 30d platform default
  };
}
