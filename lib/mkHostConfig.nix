{ lib, ... }:

let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) isDarwin isLinux;
in {
  mkHostConfig = config:
    let
      platform = if isDarwin config.system then
        "darwin"
      else if isLinux config.system then
        "linux"
      else
        throw "Unsupported system: ${config.system}";

      defaults = {
        remoteBuild = false;
        justHome = false;
        platform = platform;
      };
    in lib.recursiveUpdate defaults config;
}
