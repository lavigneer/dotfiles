{
  config,
  pkgs,
  ...
}:

{
  config = {
    homebrew.casks = [
      "claude"
    ];

    home-manager.users.${config.system.primaryUser} = {
      home.packages = with pkgs; [
        claude-code
      ];
    };
  };
}
