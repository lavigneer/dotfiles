{ pkgs, lib, ... }:
let
  # Slash commands for the ticket workflow (/draft-pr, /address-comments,
  # /fix-ci). The herdr-desktop Work sidebar sends them to a ticket's Claude
  # session; they work the same typed by hand.
  commands = lib.mapAttrs' (
    name: _:
    lib.nameValuePair ".claude/commands/${name}" {
      source = ./claude-commands + "/${name}";
    }
  ) (builtins.readDir ./claude-commands);
in
{
  home.packages = with pkgs; [
    claude-code
  ];

  home.file = commands;
}
