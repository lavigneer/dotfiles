{ pkgs
, ...
}:

{
  home.packages = with pkgs; [
    pinentry_mac
  ];
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
