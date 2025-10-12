{
  config,
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
    username = username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";

    # Essential environment variables
    sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "ghostty";
    };
  };

  # Enable XDG directories
  xdg.enable = true;
}
