{ lib, inputs, ... }:

let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) isDarwin isLinux;
in
{
  mkHomeConfig =
    hostname: hostConfig:
    let
      system = hostConfig.system;
      username = hostConfig.username;
      platform = if isDarwin system then "darwin" else "linux";
      hostPath = ../hosts/${platform}/${hostname};
      homeDirectory = if isDarwin system then "/Users/${username}" else "/home/${username}";
    in
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ../modules/home/default.nix
        "${hostPath}/home.nix"
        { home = { inherit username homeDirectory; }; }
      ];
    };
}
