{ config, pkgs, ... }:
{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];
}
