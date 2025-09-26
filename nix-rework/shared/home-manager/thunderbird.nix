{ config, pkgs, lib, ... }:

{
  # Thunderbird email client - enabled by importing this module
  programs.thunderbird = {
    enable = true;
    profiles = {
      default = {
        isDefault = true;
        # name is automatically set by Home Manager and is read-only
      };
    };
  };

  # Note: Email accounts are system-specific and should be configured
  # in individual system files (systems/*/default.nix) since they vary
  # significantly between personal and work setups.
}
