{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  # Agent skills for the ticket workflow (/draft-pr, /address-comments,
  # /fix-ci, /resolve-conflicts), from github.com/lavigneer/sheltie. The
  # herdr-desktop Work sidebar sends them to a ticket's Claude session; they
  # work the same typed by hand.
  # From the repo's source (listing a built package's files would make Nix
  # build it while evaluating).
  skillsDir = inputs.sheltie + "/skills";
  skills = lib.mapAttrs' (
    name: _:
    lib.nameValuePair ".claude/skills/${name}" {
      source = skillsDir + "/${name}";
    }
  ) (builtins.readDir skillsDir);
in
{
  home.packages = with pkgs; [
    claude-code
  ];

  home.file = skills;
}
