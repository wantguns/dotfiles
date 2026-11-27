{ lib, inputs }:

{
  mkHost = (import ./mkHost.nix { inherit lib inputs; }).mkHost;
  mkHostConfig = (import ./mkHostConfig.nix { inherit lib; }).mkHostConfig;
  isPlatform = (import ./utils.nix { inherit lib; }).isPlatform;
  isDarwin = (import ./utils.nix { inherit lib; }).isDarwin;
  isLinux = (import ./utils.nix { inherit lib; }).isLinux;
  wg = import ./wg.nix { inherit lib; };
}
