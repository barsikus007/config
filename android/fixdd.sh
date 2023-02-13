#!/bin/sh

# run while loop for boot_completed status & sleep 10 needed for magisk service.d
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done
sleep 10

get_chkfn() {
  # get currently active function name
  ls -al /config/usb_gadget/g1/configs/b.1/ | grep -Eo "function0.*" | awk '{print $3}' | cut -d/ -f8
}

# save currently active function name
get_chkfn > /data/adb/.fixdd

# path to link to the function for pixel 7 pro
path_to_func="/config/usb_gadget/g1/configs/b.1/function0"

# loop
# run every 0.5 seconds
while true
do
  # check the app is active
  chkapp="$(pgrep -f drivedroid | wc -l)"
  # check currently active function
  chkfn=$(get_chkfn)
  # load previous active function
  chkfrstfn="$(cat /data/adb/.fixdd)"
  if [ "$chkapp" -eq "1" ] && [ "$chkfn" != "mass_storage.0" ]; then
    # add mass_storage.0 config & function and remove currently active function
    rm $path_to_func
    mkdir -p /config/usb_gadget/g1/functions/mass_storage.0/lun.0/
    ln -s /config/usb_gadget/g1/functions/mass_storage.0 $path_to_func
  elif [ "$chkapp" -eq "0" ] && [ "$chkfn" = "mass_storage.0" ]; then
    # remove mass_storage.0 function & restore previous function
    rm $path_to_func
    ln -s /config/usb_gadget/g1/functions/"$chkfrstfn" $path_to_func
    if [ "$chkfrstfn" = "ffs.adb" ]; then
      setprop sys.usb.config adb
    elif [ "$chkfrstfn" = "ffs.mtp" ]; then
      setprop sys.usb.config mtp
    fi
  fi
  sleep 0.5
done