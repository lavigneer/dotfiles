{
  config,
  lib,
  pkgs,
  inputs,
  username,
  userFullName,
  userEmail,
  ...
}:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  # Basic Home Manager configuration
  home = {
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";

    # Essential environment variables
    sessionVariables = {
      EDITOR = "nvim";
      # Machines can pick another default terminal (see herdr-desktop.nix)
      TERMINAL = lib.mkDefault "ghostty";
    };
  };

  # Enable XDG directories
  xdg.enable = true;
}
