{ lib }:

let mkInfo = { hosts, extraWgHosts }:
  let
    generateWgConfig = allWgHosts: host:
      let
        privateKey = builtins.readFile host.ips.orion.privateKeyFile;
        listenPort = 51820;
        publicPeers = lib.filterAttrs (_: v: v ? ips && v.ips ? public) allWgHosts;

        gatewayHostname =
          if host.ips.orion ? gateway
          then host.ips.orion.gateway
          else (lib.head (lib.attrNames publicPeers));
      in ''
        [Interface]
        PrivateKey = ${privateKey}
        Address = ${host.ips.orion.address}/16
        DNS = 10.69.0.1

        # Create a [Peer] block for every public host
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: peer: ''
          [Peer]
          PublicKey = ${peer.ips.orion.publicKey}
          # If this peer is the gateway, it handles all traffic.
          # Otherwise, we only allow traffic for its own IP.
          AllowedIPs = ${if name == gatewayHostname then "10.69.0.0/16" else "${peer.ips.orion.address}/32"}
          Endpoint = ${peer.ips.public}:${toString listenPort}
          PersistentKeepalive = 25
        '') publicPeers)}
      '';

    allWgHosts = hosts // extraWgHosts;

  in {
    wgHosts = allWgHosts;

    buildPackages = { pkgs }: lib.mapAttrs' (name: host: lib.nameValuePair name (
      let
        configFile = pkgs.writeText "wg0.conf" (generateWgConfig allWgHosts host);
      in pkgs.stdenv.mkDerivation {
        name = "${host.hostname}-wg-config";
        src = configFile;
        buildInputs = [ pkgs.qrencode ];
        buildCommand = ''
          mkdir -p $out
          cp ${configFile} $out/wg0.conf
          cat ${configFile} | qrencode -t png -o $out/wg0.png
          cat ${configFile} | qrencode -t ansiutf8 > $out/wg0.ansiutf8
          echo "Built config for ${host.hostname}"
        '';
      }
    )) extraWgHosts;
  };
in
{
  inherit mkInfo;
}
