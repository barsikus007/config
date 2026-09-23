{
  lib,
  pkgs,
  username,
  ...
}:
#? record and replay dynamic keystroke macros via evdev without grabbing devices
#? passive read on by-id keyboards preserves logiops and capslock layout led
let
  keyMacro =
    pkgs.writers.writePython3Bin "key-macro"
      {
        libraries = [ pkgs.python3Packages.evdev ];
        flakeIgnore = [
          "E501"
          "W503"
        ];
        makeWrapperArgs = [
          "--prefix"
          "PATH"
          ":"
          (lib.makeBinPath [ pkgs.libnotify ])
        ];
      }
      /* python */ ''
        import glob
        import json
        import os
        import select
        import signal
        import subprocess
        import sys
        import time

        import evdev

        RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
        REC_PID_FILE = os.path.join(RUNTIME_DIR, "key-macro-rec.pid")
        PLAY_PID_FILE = os.path.join(RUNTIME_DIR, "key-macro-play.pid")
        DATA_FILE = os.path.join(RUNTIME_DIR, "key-macro.json")
        IGNORE_KEYS = {
            evdev.ecodes.KEY_F9,
            evdev.ecodes.KEY_F10,
        }


        def notify(msg):
            subprocess.run(
                ["notify-send", "--app-name=Macro", "--urgency=low", "Macro", msg],
                check=False,
            )


        def get_keyboards():
            devs = []
            for p in glob.glob("/dev/input/by-id/*-event-kbd"):
                try:
                    devs.append(evdev.InputDevice(p))
                except Exception:
                    pass
            if not devs:
                for p in glob.glob("/dev/input/event*"):
                    try:
                        dev = evdev.InputDevice(p)
                        name = dev.name.lower()
                        if any(x in name for x in ("mouse", "touchpad", "ydotool", "macro", "video")):
                            continue
                        caps = dev.capabilities()
                        if evdev.ecodes.EV_KEY in caps:
                            keys = caps[evdev.ecodes.EV_KEY]
                            if evdev.ecodes.KEY_A in keys and evdev.ecodes.KEY_SPACE in keys:
                                devs.append(dev)
                    except Exception:
                        pass
            return devs


        def record_daemon():
            keyboards = get_keyboards()
            if not keyboards:
                notify("no keyboards found to record")
                sys.exit(1)

            events = []
            running = True

            def sig_handler(signum, frame):
                nonlocal running
                running = False

            signal.signal(signal.SIGTERM, sig_handler)
            signal.signal(signal.SIGINT, sig_handler)

            last_time = time.monotonic()
            first_event = True

            while running:
                r, _, _ = select.select(keyboards, [], [], 0.2)
                now = time.monotonic()
                for dev in r:
                    try:
                        for ev in dev.read():
                            if ev.type == evdev.ecodes.EV_KEY:
                                if ev.code in IGNORE_KEYS:
                                    continue
                                if first_event:
                                    delta = 0.0
                                    first_event = False
                                else:
                                    delta = min(now - last_time, 5.0)
                                last_time = now
                                events.append((ev.code, ev.value, delta))
                    except Exception:
                        pass

            with open(DATA_FILE, "w") as f:
                json.dump(events, f)

            presses = sum(1 for _, val, _ in events if val == 1)
            notify(f"⏹ recording stopped ({presses} keys)")


        def is_pid_running(pid_file):
            if os.path.exists(pid_file):
                try:
                    with open(pid_file) as f:
                        pid = int(f.read().strip())
                    os.kill(pid, 0)
                    return pid
                except (ProcessLookupError, ValueError):
                    try:
                        os.remove(pid_file)
                    except OSError:
                        pass
            return None


        def stop_daemon(pid_file):
            pid = is_pid_running(pid_file)
            if pid is not None:
                try:
                    os.kill(pid, signal.SIGTERM)
                    for _ in range(50):
                        time.sleep(0.02)
                        try:
                            os.kill(pid, 0)
                        except ProcessLookupError:
                            break
                except ProcessLookupError:
                    pass
                if os.path.exists(pid_file):
                    try:
                        os.remove(pid_file)
                    except OSError:
                        pass
                return True
            return False


        def is_recording():
            return is_pid_running(REC_PID_FILE)


        def is_playing():
            return is_pid_running(PLAY_PID_FILE)


        def stop_recording():
            return stop_daemon(REC_PID_FILE)


        def stop_playing():
            if stop_daemon(PLAY_PID_FILE):
                notify("⏹ playback stopped")
                return True
            return False


        def toggle():
            if stop_playing():
                time.sleep(0.05)
            if stop_recording():
                return

            notify("⏺ recording started...")
            proc = subprocess.Popen(
                [sys.executable, __file__, "_rec_daemon"],
                start_new_session=True,
            )
            with open(REC_PID_FILE, "w") as f:
                f.write(str(proc.pid))


        def play_daemon():
            with open(PLAY_PID_FILE, "w") as f:
                f.write(str(os.getpid()))

            try:
                with open(DATA_FILE) as f:
                    events = json.load(f)
            except Exception:
                events = []

            if not events:
                if os.path.exists(PLAY_PID_FILE):
                    try:
                        os.remove(PLAY_PID_FILE)
                    except OSError:
                        pass
                return

            ui = evdev.UInput(name="key-macro-player")
            time.sleep(0.12)

            held_keys = set()
            running = True

            def sig_handler(signum, frame):
                nonlocal running
                running = False

            signal.signal(signal.SIGTERM, sig_handler)
            signal.signal(signal.SIGINT, sig_handler)

            try:
                for code, val, delta in events:
                    if not running:
                        break
                    if delta > 0:
                        end_sleep = time.monotonic() + delta
                        while running and time.monotonic() < end_sleep:
                            time.sleep(min(0.02, max(0.0, end_sleep - time.monotonic())))
                    if not running:
                        break
                    ui.write(evdev.ecodes.EV_KEY, code, val)
                    ui.syn()
                    if val == 1:
                        held_keys.add(code)
                    elif val == 0:
                        held_keys.discard(code)
            finally:
                for code in held_keys:
                    try:
                        ui.write(evdev.ecodes.EV_KEY, code, 0)
                    except Exception:
                        pass
                try:
                    ui.syn()
                except Exception:
                    pass
                time.sleep(0.05)
                try:
                    ui.close()
                except Exception:
                    pass
                if os.path.exists(PLAY_PID_FILE):
                    try:
                        os.remove(PLAY_PID_FILE)
                    except OSError:
                        pass


        def play():
            if stop_playing():
                return

            if is_recording():
                stop_recording()
                time.sleep(0.1)

            if not os.path.exists(DATA_FILE):
                notify("macro is empty")
                return

            try:
                with open(DATA_FILE) as f:
                    events = json.load(f)
            except Exception:
                events = []

            if not events:
                notify("macro is empty")
                return

            notify("▶ playing macro...")
            proc = subprocess.Popen(
                [sys.executable, __file__, "_play_daemon"],
                start_new_session=True,
            )
            with open(PLAY_PID_FILE, "w") as f:
                f.write(str(proc.pid))


        def main():
            cmd = sys.argv[1] if len(sys.argv) > 1 else "toggle"
            if cmd == "toggle":
                toggle()
            elif cmd == "play":
                play()
            elif cmd == "_rec_daemon":
                record_daemon()
            elif cmd == "_play_daemon":
                play_daemon()
            else:
                print(f"Usage: {sys.argv[0]} [toggle|play]")
                sys.exit(1)


        if __name__ == "__main__":
            main()
      '';
in
{
  hardware.uinput.enable = true;
  users.users.${username}.extraGroups = [
    "uinput"
    "input"
  ];

  environment.systemPackages = [ keyMacro ];
}
