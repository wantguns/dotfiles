{ lib, ... }:

let
  isPlatform = system: platform: builtins.match ".*-${platform}" system != null;
  isDarwin = system: isPlatform system "darwin";
  isLinux = system: isPlatform system "linux";
in { inherit isPlatform isDarwin isLinux; }
