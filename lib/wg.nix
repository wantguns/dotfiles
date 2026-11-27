{ lib }:

{
  mkOrion =
    table:
    lib.mapAttrs (
      name: peer:
      assert lib.assertMsg (
        (peer ? endpoint) != (peer ? hub)
      ) "orion.${name}: set exactly one of endpoint (a hub) or hub (a spoke)";
      assert lib.assertMsg (
        !(peer ? hub) || (table.${peer.hub} or { }) ? endpoint
      ) "orion.${name}: ${peer.hub or ""} is not a hub";
      peer
    ) table;
}
