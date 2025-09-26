{ config, pkgs, lib, userEmail, userFullName, ... }:

{
  # Thunderbird email client configuration
  programs.thunderbird = {
    enable = true;
    profiles = {
      gmail.isDefault = true;
      hotmail.isDefault = false;
    };
  };

  # Email accounts configuration
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
}
