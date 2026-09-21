{
  zramSwap = {
    enable = true;
    #? zeros eat swap slots 1:1 while costing no RAM (was 1GB of RAM usage per 20GB of swap)
    memoryPercent = 300;
  };
  #? aka mem_limit
  services.zram-generator.settings.zram0.zram-resident-limit = "ram / 2";

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
