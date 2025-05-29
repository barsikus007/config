{
  zramSwap.enable = true;

  # swapDevices = [
  #   {
  #     # device = "/zxc/hibernation";
  #     #? free | awk '/Mem/ {x=$2/1024; printf "%.0fM", (x<2 ? 2*x : x<8 ? 1.5*x : x) }
  #     # TODO this is device specific value
  #     size = 38 * 1024; # in megabytes
  #     priority = 0;
  #   }
  # ];
}
