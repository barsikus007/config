{ pkgs, ... }:
with pkgs;
[
  #? build deps
  gcc
  libffi

  python-launcher
  # (python314FreeThreading.withPackages (
  (python3.withPackages (
    python-pkgs: with python-pkgs; [
      tkinter
      ptpython
      ipython
    ]
  ))
  uv
  hatch
  ruff
]
