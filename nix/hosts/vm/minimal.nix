{
  virtualisation.vmVariant = {
    virtualisation = {
      diskImage = null;
      memorySize = 8 * 1024;
      cores = 8;
      forwardPorts = [
        #? ssh ogurez@localhost -p 22222 -o StrictHostKeychecking=no
        {
          from = "host";
          host.port = 22222;
          guest.port = 2222;
        }
      ];
    };
  };
}
