{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Terminal applications that need to be installed via Homebrew on macOS
  homebrew.casks = [
    "ghostty" # Terminal emulator not available in nixpkgs for darwin
  ];
}
