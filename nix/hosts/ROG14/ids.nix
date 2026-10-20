let
  #? Asus GA401IV
  subsystemVendorId = "1043";
  subsystemDeviceId = "1F11";
in
{
  mic = {
    alsaCard = "Generic_1";
    pipewireNode = "alsa_input.pci-0000_04_00.6.analog-stereo";
    pipewireDevice = "alsa_card.pci-0000_04_00.6";
    deviceProfile = "Internal Microphone";
    deviceDescription = "Ryzen HD Audio Controller Analog Stereo";
  };
  gpu = {
    internal = {
      pci = "04:00";
    };
    discrete = rec {
      pci = "01:00";
      #? Nvidia TU106M
      vendorId = "10DE";
      deviceId = "1F12";
      lactId = "${vendorId}:${deviceId}-${subsystemVendorId}:${subsystemDeviceId}-0000:${pci}.0";
    };
  };
}
