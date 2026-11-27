{
  lib,
  hosts,
  orion,
  thisHostName,
  ...
}:

let
  block = name: peer: ''
    Host ${name}
      HostName ${peer.address}
      ${lib.optionalString (hosts ? ${name}) "User ${hosts.${name}.username}"}
  '';
in
{
  home.file.".ssh/config.d/hosts".text = lib.concatStringsSep "\n" (
    lib.mapAttrsToList block (removeAttrs orion [ thisHostName ])
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
