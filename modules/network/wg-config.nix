{
  lib,
  pkgs,
  orion,
}:

let
  spokes = lib.filterAttrs (_: peer: peer ? hub) orion;
  case =
    name: peer:
    let
      hub = orion.${peer.hub};
    in
    ''
      ${name})
        address='${peer.address}'
        hubKey='${hub.publicKey}'
        endpoint='${hub.endpoint}:51820'
        ;;
    '';
in
pkgs.writeShellApplication {
  name = "wg-config";
  runtimeInputs = [
    pkgs.sops
    pkgs.qrencode
  ];
  text = ''
    name=''${1:?usage: wg-config <peer> [--qr]}
    case "$name" in
    ${lib.concatStrings (lib.mapAttrsToList case spokes)}
    *)
      echo "unknown peer: $name (known: ${lib.concatStringsSep " " (lib.attrNames spokes)})" >&2
      exit 1
      ;;
    esac

    key=$(sops decrypt --extract "[\"wg\"][\"$name\"][\"private\"]" ${../../secrets/hosts.yaml})
    conf=$(printf '[Interface]\nPrivateKey = %s\nAddress = %s/16\n\n[Peer]\nPublicKey = %s\nAllowedIPs = 10.69.0.0/16\nEndpoint = %s\nPersistentKeepalive = 25' \
      "$key" "$address" "$hubKey" "$endpoint")

    if [ "''${2-}" = --qr ]; then
      qrencode -t ansiutf8 <<<"$conf"
    else
      printf '%s\n' "$conf"
    fi
  '';
}
