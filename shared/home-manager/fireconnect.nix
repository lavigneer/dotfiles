{ pkgs, ... }:

let
  fireconnectSetup = pkgs.writeShellApplication {
    name = "setup-fireconnect";
    runtimeInputs = with pkgs; [
      curl
      nodejs_24
    ];
    text = builtins.readFile (
      builtins.fetchurl {
        url = "https://gist.githubusercontent.com/RedBeard0531/87f63f7e5b073dd26a20ef24ef648248/raw";
        sha256 = "sha256-7qQ3434trCaN31z0Fyl40fPDQ/NMogyvOZrDGLNoPXU=";
      }
    );
  };
in
{
  # The gist performs an interactive login, so expose it as an explicit command
  # instead of running it during every Home Manager activation.
  home.packages = [ fireconnectSetup ];
}
