{ config, pkgs, ... }:

{
  home = {
    stateVersion = "26.05";
    sessionPath = [ "$HOME/.local/bin" ];
    packages = with pkgs; [
      (iosevka-bin.override { variant = "SS15"; })
      ripgrep
    ];
  };

  fonts.fontconfig.enable = true;
  programs.home-manager.enable = true;

  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/dev/source";
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/home.yaml;
  };
}
