{
  config,
  lib,
  hosts,
  thisHostName,
  ...
}:

let
  # orion is the wireguard mesh every host is on, so prefer it. public and
  # private are fallbacks for hosts not (yet) on the mesh.
  addressOf =
    host: host.ips.orion.address or host.ips.public or host.ips.private or null;

  reachable = lib.filterAttrs (
    name: host: name != thisHostName && (addressOf host) != null
  ) hosts;

  block = name: host: ''
    Host ${name}
      HostName ${addressOf host}
      ${lib.optionalString (host ? username) "User ${host.username}"}
  '';
in
{
  home.file.".ssh/config.d/hosts".text = lib.concatStringsSep "\n" (
    lib.mapAttrsToList block reachable
  );

  home.activation.sshConfigInclude = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cfg="$HOME/.ssh/config"
    line='Include ~/.ssh/config.d/*'
    mkdir -p "$HOME/.ssh" "$HOME/.ssh/config.d"
    touch "$cfg"
    chmod 600 "$cfg"
    if ! grep -Fxq "$line" "$cfg"; then
      printf '%s\n%s' "$line" "$(cat "$cfg")" > "$cfg"
    fi
  '';
}
