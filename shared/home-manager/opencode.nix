{ config, pkgs, ... }:

let
  home = config.home.homeDirectory;
in
{
  home.packages = with pkgs; [
    opencode
  ];

  xdg.configFile = {
    # Global instructions, applied to every session (opencode reads this
    # automatically, the same way Claude Code reads ~/.claude/CLAUDE.md).
    "opencode/AGENTS.md".source = ./opencode/AGENTS.md;

    # "opencode/tui.json".text = builtins.toJSON {
    #   "$schema" = "https://opencode.ai/tui.json";
    #   mouse = false;
    # };

    "opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";

      # opencode is installed by nix, so it must not update itself in place.
      autoupdate = false;
      share = "disabled";

      # Built-in LSP and formatter integrations replace the gopls-lsp and
      # rust-analyzer-lsp Claude Code plugins.
      lsp = true;
      formatter = true;

      # Reuse the skills already installed under ~/.claude/skills rather than
      # keeping a second copy in this repo.
      skills.paths = [ "${home}/.claude/skills" ];

      mcp = {
        mongo-glean = {
          type = "remote";
          url = "https://mongodb-be.glean.com/mcp/default";
          enabled = true;
        };

        devprod-mcp = {
          type = "remote";
          url = "https://devprod-mcp-gateway.corp.mongodb.com/mcp";
          enabled = true;
        };

        honeycomb = {
          type = "remote";
          url = "https://mcp.honeycomb.io/mcp";
          enabled = true;
        };

        backstage = {
          type = "local";
          command = [ "${home}/workspace/devprod-infra-agent-config/backstage/backstage-mcp" ];
          enabled = true;
        };

        engflow = {
          type = "local";
          command = [ "${home}/workspace/devprod-infra-agent-config/engflow/engflow-mcp" ];
          environment = {
            ENGFLOW_CLUSTER = "sodalite.cluster.engflow.com";
          };
          enabled = true;
        };

        evergreen = {
          type = "local";
          command = [
            "uvx"
            "--from=git+https://github.com/evergreen-ci/evergreen-mcp-server"
            "evergreen-mcp-server"
          ];
          enabled = true;
        };
      };

      # Mirrors the Claude Code "auto" permission mode: edits and reads go
      # through without prompting, bash is allow-listed for read-only commands
      # and anything that leaves the machine still asks.
      permission = {
        edit = "allow";
        webfetch = "allow";

        bash = {
          "*" = "ask";

          # Explicitly allow-listed in Claude Code
          "make lint" = "allow";
          "make verify-commit" = "allow";
          "kubectl get *" = "allow";
          "kubectl * get *" = "allow";
          "kubectl logs *" = "allow";
          "kubectl * logs *" = "allow";
          "kubectl describe *" = "allow";
          "kubectl * describe *" = "allow";
          "kubectl config view*" = "allow";
          "kubectl config current-context*" = "allow";
          "kubectl config get-*" = "allow";
          "helm show *" = "allow";
          "helm list *" = "allow";
          "helm * get *" = "allow";
          "go doc *" = "allow";
          "bazel query *" = "allow";

          # Read-only commands that Claude Code's auto mode approved implicitly
          "cat *" = "allow";
          "head *" = "allow";
          "tail *" = "allow";
          "ls *" = "allow";
          "find *" = "allow";
          "grep *" = "allow";
          "rg *" = "allow";
          "wc *" = "allow";
          "which *" = "allow";
          "jq *" = "allow";
          "git status*" = "allow";
          "git diff*" = "allow";
          "git log*" = "allow";
          "git show*" = "allow";
          "git branch" = "allow";
          "git blame *" = "allow";
          "gh pr view*" = "allow";
          "gh pr list*" = "allow";
          "gh pr diff*" = "allow";
          "gh run view*" = "allow";
          "gh run list*" = "allow";

          # Confirmed before running, as in Claude Code's "ask" list
          "git push*" = "ask";
          "gh pr create*" = "ask";
          "gh pr edit*" = "ask";
          "git commit*" = "ask";
        };
      };
    };
  };
}
