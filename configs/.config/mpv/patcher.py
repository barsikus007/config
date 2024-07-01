input_bindings = """"""  # paste here from https://github.com/mpv-player/mpv/blob/master/etc/input.conf

eng = """~QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>?`qwertyuiop[]asdfghjkl;"zxcvbnm,./"""
rus = """ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ,ёйцукенгшщзхъфывапролджэячсмитьбю."""
for line in input_bindings.splitlines():
    if not line.startswith("#"):
        continue
    keybind, *rest = line.split(" ", 1)
    if keybind == "#":
        continue
    keybind = keybind[1:]
    keys = keybind.split("+")
    new_keys = [key.translate(key.maketrans(eng, rus)) if len(key) == 1 else key for key in keys]
    if new_keys == keys:
        continue
    print("+".join(new_keys), next(iter(rest), ""))
