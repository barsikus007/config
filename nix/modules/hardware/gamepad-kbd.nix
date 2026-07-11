{
  lib,
  pkgs,
  username,
  ...
}:
#? View(⧉)+Menu(≡) to enable keyboard mode
#? D-pad -> arrows, A -> Enter, B -> Esc, LB -> Ctrl+Tab, RB -> Ctrl+Shift+Tab
#? (LT, abs:z) -> D-pad -> F15..F18 (= niri focus-column/workspace, same as on MX3)
let
  padDev = "/dev/input/xbox_gamepad";
  pyEnv = pkgs.python3.withPackages (ps: [ ps.evdev ]);
  rumblePy = pkgs.writeText "gamepad-rumble.py" /* python */ ''
    import sys, time
    from evdev import InputDevice, ff, ecodes

    dev = InputDevice(sys.argv[1])
    mode = sys.argv[2] if len(sys.argv) > 2 else "on"

    # on: single low-freq rumble; off: double short high-freq buzz
    if mode == "off":
        strong, weak, length, delay, count = 0x3000, 0xFFFF, 90, 80, 2
    else:
        strong, weak, length, delay, count = 0xC000, 0x6000, 250, 0, 1

    rumble = ff.Rumble(strong_magnitude=strong, weak_magnitude=weak)
    eff = ff.Effect(
        ecodes.FF_RUMBLE, -1, 0, ff.Trigger(0, 0), ff.Replay(length, delay),
        ff.EffectType(ff_rumble_effect=rumble),
    )
    eid = dev.upload_effect(eff)
    dev.write(ecodes.EV_FF, eid, count)
    time.sleep((length + delay) * count / 1000 + 0.05)
    dev.erase_effect(eid)
  '';
  gamepadRumble = pkgs.writeShellApplication {
    name = "gamepad-rumble";
    runtimeInputs = [ pyEnv ];
    text = /* shell */ ''
      [ -e "${padDev}" ] || exit 0
      exec python3 ${rumblePy} "${padDev}" "''${1:-on}"
    '';
  };

  gamepadKbdToggle = pkgs.writeShellApplication {
    name = "gamepad-kbd-toggle";
    runtimeInputs = with pkgs; [
      systemd
      coreutils
      libnotify
      gamepadRumble
    ];
    text = /* shell */ ''
      #? debounce
      stamp="$XDG_RUNTIME_DIR/gamepad-kbd.stamp"
      now="$(date +%s%3N)"
      last="$(cat "$stamp" 2>/dev/null || echo 0)"
      if [ "$((now - last))" -lt 600 ]; then exit 0; fi
      echo "$now" > "$stamp"

      if systemctl --user is-active --quiet gamepad-kbd.service; then
        systemctl --user stop gamepad-kbd.service
        gamepad-rumble off || true
        notify-send --app-name=Gamepad "Gamepad" "keyboard mode OFF"
      else
        gamepad-rumble on || true
        systemctl --user start gamepad-kbd.service
        notify-send --app-name=Gamepad "Gamepad" "keyboard mode ON"
      fi
    '';
  };

  #! `evsieve --input grab` to fix gamepad stealing
  gamepadKbd = pkgs.writeShellApplication {
    name = "gamepad-kbd";
    runtimeInputs = with pkgs; [
      systemd
      evsieve
    ];
    text = /* shell */ ''
      if [ ! -e "${padDev}" ]; then
        echo "no gamepad found (${padDev} missing)" >&2
        exit 1
      fi
      exec evsieve \
        --input "${padDev}" domain=ctl grab persist=reopen \
        --hook btn:start btn:select exec-shell="systemd-run --user --quiet --collect ${lib.getExe gamepadKbdToggle}" \
        --hook abs:z:512~ toggle=layer:2 \
        --hook abs:z:~511 toggle=layer:1 \
        --map abs:hat0x:-1 key:left:1 \
        --map abs:hat0x:1  key:right:1 \
        --map abs:hat0x:0  key:left:0 key:right:0 \
        --map abs:hat0y:-1 key:up:1 \
        --map abs:hat0y:1  key:down:1 \
        --map abs:hat0y:0  key:up:0 key:down:0 \
        --map btn:south key:enter \
        --map btn:east  key:esc \
        --map btn:tl key:leftctrl key:tab \
        --map btn:tr key:leftctrl key:leftshift key:tab \
        --toggle @ctl @base @hold id=layer mode=consistent \
        --map key:left@hold  key:f15 \
        --map key:down@hold  key:f16 \
        --map key:up@hold    key:f17 \
        --map key:right@hold key:f18 \
        --block abs btn \
        --output name="gamepad-kbd"
    '';
  };

  gamepadKbdWatch = pkgs.writeShellApplication {
    name = "gamepad-kbd-watch";
    runtimeInputs = with pkgs; [
      coreutils
      evsieve
    ];
    text = /* shell */ ''
      while [ ! -e "${padDev}" ]; do sleep 2; done
      exec evsieve \
        --input "${padDev}" persist=reopen \
        --hook btn:start btn:select exec-shell="${lib.getExe gamepadKbdToggle}"
    '';
  };
in
{
  hardware.uinput.enable = true;
  users.users.${username}.extraGroups = [
    "uinput"
    "input"
  ];

  environment.systemPackages = [
    gamepadKbdToggle
    gamepadRumble
  ];

  systemd.user.services.gamepad-kbd = {
    description = "Gamepad-as-keyboard remapper (evsieve)";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    startLimitIntervalSec = 30;
    startLimitBurst = 3;
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe gamepadKbd;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  systemd.user.services.gamepad-kbd-watch = {
    description = "Gamepad Menu+View chord watcher -> toggle keyboard mode";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = lib.getExe gamepadKbdWatch;
      Restart = "always";
      RestartSec = 3;
    };
  };
}
