{ config, pkgs, lib, userEmail, userFullName, ... }:

{
  # Work-specific email accounts for macOS
  accounts.email.accounts = {
    "Work" = {
      primary = true;
      address = userEmail;
      userName = userEmail;
      realName = userFullName;
      # Add work email provider settings as needed
    };
  };
}
