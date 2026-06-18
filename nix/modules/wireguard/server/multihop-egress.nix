args:
let
  outInterface = if args ? outInterface then args.outInterface else "wg1";
  outInterfaceCfg =
    if args ? outInterfaceCfg then
      args.outInterfaceCfg
    else
      { configFile = "/etc/wireguard/${outInterface}.conf"; };
  outInterfaceTable = if args ? outInterfaceTable then args.outInterfaceTable else 120;
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
