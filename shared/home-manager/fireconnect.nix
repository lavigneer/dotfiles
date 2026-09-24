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
        url = "https://raw.githubusercontent.com/mongodb/Afterburner/04ec398dbc6ed98223491eb25a6a9ca36e687f41/setup-fireconnect.sh";
        sha256 = "sha256:0spib4afdj9j0x7rmdz2z9vv2a214n4r6sv6m5hnn774p8pavdvd";
      }
    );
  };
in
{
  # The gist performs an interactive login, so expose it as an explicit command
  # instead of running it during every Home Manager activation.
  home.packages = [ fireconnectSetup ];
}
