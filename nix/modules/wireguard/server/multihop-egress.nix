args:
let
  outInterface = args.outInterface or "wg1";
  outInterfaceCfg = args.outInterfaceCfg or { configFile = "/etc/wireguard/${outInterface}.conf"; };
  outInterfaceTable = toString (args.outInterfaceTable or (120));
in
{
  networking.wg-quick.interfaces.${outInterface} = outInterfaceCfg // {
    table = "off";
    postUp = ''
      ip rule add fwmark ${outInterfaceTable} table ${outInterfaceTable}
      ip route add default dev ${outInterface} table ${outInterfaceTable}
    '';
    preDown = ''
      ip route del default dev ${outInterface} table ${outInterfaceTable}
      ip rule del fwmark ${outInterfaceTable} table ${outInterfaceTable}
    '';
  };
}
