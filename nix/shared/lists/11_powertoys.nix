{ pkgs, ... }:
#? https://learn.microsoft.com/en-us/windows/powertoys/ analogs
with pkgs;
[
  caffeine-ng # ? Awake
  hyprpicker # --autocopy --notify # ? Color Picker
  # ? File Locksmith
  lsof
  psmisc # (fuser)
  xnconvert # ? Image Resizer
  krename # ? PowerRename
  # https://github.com/Genymobile/screen-ruler # ? Screen Ruler
  # ocr-screen-region # ? Text Extractor
]
