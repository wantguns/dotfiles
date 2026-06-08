{ lib, inputs, ... }:

let
  utils = import ./utils.nix { inherit lib; };
  inherit (utils) isDarwin isLinux;
in {
  mkHost =
    hostConfig@{ hostname, platform, system, username ? "wantguns", ... }:
    let
      hostDarwin = isDarwin system;
      homeDirectory =
        if hostDarwin then "/Users/${username}" else "/home/${username}";

      hmModule = if hostDarwin then
        inputs.home-manager.darwinModules.home-manager
      else
        inputs.home-manager.nixosModules.home-manager;

      hostPath = ../hosts/${platform}/${hostname};
      commonPath = ../hosts/${platform}/common.nix;
      sharedPath = ../hosts/common/default.nix;

      diskoConfigPath = "${hostPath}/disk-config.nix";
      facterJsonPath = "${hostPath}/facter.json";
      hasDiskoConfig = !hostDarwin && builtins.pathExists diskoConfigPath;
      hasFacterJson = !hostDarwin && builtins.pathExists facterJsonPath;

      baseModules =
        [ sharedPath commonPath "${hostPath}/default.nix" hmModule ];

      linuxModules = if hostDarwin then
        [ ]
      else
        (lib.optional hasDiskoConfig inputs.disko.nixosModules.disko)
        ++ (lib.optional hasDiskoConfig diskoConfigPath)
        ++ (lib.optional hasFacterJson
          inputs.nixos-facter-modules.nixosModules.facter)
        ++ (lib.optional hasFacterJson { facter.reportPath = facterJsonPath; })
        ++ [ inputs.sops-nix.nixosModules.sops
            ../modules/network/wireguard-orion.nix
        ];

      systemBuilder = if hostDarwin then
        inputs.darwin.lib.darwinSystem
      else
        inputs.nixpkgs.lib.nixosSystem;
    in systemBuilder {
      inherit system;
      specialArgs = {
          inherit inputs;
          hosts = inputs.self.hosts;
          thisHostName = hostname;
      } // hostConfig.specialArgs or {};
      modules = baseModules ++ linuxModules ++ [{
        nixpkgs = {
          config.allowUnfree = true;
          hostPlatform = system;
        };

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs; };
          sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
          users.${username} = { ... }: {
            imports = [
              ../modules/home/default.nix
              "${hostPath}/home.nix"
            ];
          };
        };
      }];
    };
}
