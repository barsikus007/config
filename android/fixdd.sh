#!/bin/sh

# run while loop for boot_completed status & sleep 10 needed for magisk service.d
while [ "$(getprop sys.boot_completed | tr -d '\r')" != "1" ]; do sleep 1; done
sleep 10

get_fn_type() {
  # get currently active function name
  if ls /config/usb_gadget/g1/configs/b.1/function* > /dev/null 2>&1
  then
    echo "function"
  else
    echo "f"
  fi
}

fn_type=$(get_fn_type)

get_last_fn() {
  # get currently free function number
  num=$(ls -al /config/usb_gadget/g1/configs/b.1/ | grep -Eo "$fn_type[0-9]+[[:space:]]" | tail -1 | cut -dn -f 3)
  echo "$fn_type"$((num+1))
}

is_mass_storage_present() {
  # returns 1 if mass_storage.0 is present
  ls -al /config/usb_gadget/g1/configs/b.1/ | grep -Eo "mass_storage.0" | wc -l
}

# save currently active function name
if [ "$fn_type" = "f" ]; then
  get_chkfn > /data/adb/.fixdd
fi

# loop
# run every 0.5 seconds
while true
do
  # path to link to the function
  path_to_func="/config/usb_gadget/g1/configs/b.1/$(get_last_fn)"
  # check the app is active
  chkapp="$(pgrep -f drivedroid | wc -l)"
  # check if mass storage is active function
  mass_storage_active=$(is_mass_storage_present)
  if [ "$chkapp" -eq "1" ] && [ "$mass_storage_active" -eq "0" ]; then
  
    # add mass_storage.0 to currently active functions
    if [ "$fn_type" = "f" ]; then
      # TODO why do i need this?
      setprop sys.usb.config cdrom
      setprop sys.usb.configfs 1
      # TODO /
      rm "$path_to_func"
    fi
    mkdir -p /config/usb_gadget/g1/functions/mass_storage.0/lun.0/
    ln -s /config/usb_gadget/g1/functions/mass_storage.0 "$path_to_func"

    if [ "$fn_type" = "f" ]; then
      # TODO why do i need this?
      getprop sys.usb.controller >/config/usb_gadget/g1/UDC
      setprop sys.usb.state cdrom
      # TODO /
    fi

  elif [ "$chkapp" -eq "0" ] && [ "$mass_storage_active" -eq "1" ]; then
    # remove mass_storage.0 function
    # TODO check if position changed (this is instant, so it should be fine)
    rm "$path_to_func"
    # it seems, than pixel 7 doesn't use sys.usb.config at all
    if [ "$fn_type" = "f" ]; then
      # TODO why do i need this?
      setprop sys.usb.configfs 0
      setprop sys.usb.configfs 1
      # TODO /
      # load previous active function
      chkfrstfn="$(cat /data/adb/.fixdd)"
      ln -s /config/usb_gadget/g1/functions/"$chkfrstfn" "$path_to_func"
      # TODO why do i need this?
      echo a600000.dwc3 > /config/usb_gadget/g1/UDC
      # TODO /
      # pixel 7 have persist.sys.usb.config instead?
      if [ "$chkfrstfn" = "ffs.adb" ]; then
        setprop sys.usb.config adb
      elif [ "$chkfrstfn" = "ffs.mtp" ]; then
        setprop sys.usb.config mtp
      elif [ "$chkfrstfn" = "mtp.gs0" ]; then
        setprop sys.usb.config mtp
      fi
    fi
  fi
  sleep 0.5
done
