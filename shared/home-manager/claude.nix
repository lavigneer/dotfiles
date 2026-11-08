{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Slash commands for the ticket workflow (/draft-pr, /address-comments,
  # /fix-ci), from github.com/lavigneer/herdr-ticket-flow. The herdr-desktop
  # Work sidebar sends them to a ticket's Claude session; they work the same
  # typed by hand.
  # From the repo's source (listing a built package's files would make Nix
  # build it while evaluating).
  commandsDir = inputs.herdr-ticket-flow + "/agents/claude";
  commands = lib.mapAttrs' (
    name: _:
    lib.nameValuePair ".claude/commands/${name}" {
      source = commandsDir + "/${name}";
    }
  ) (builtins.readDir commandsDir);
in
{
  home.packages = with pkgs; [
    claude-code
  ];

  home.file = commands;
}
