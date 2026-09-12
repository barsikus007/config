# ? flutter >=3.44 aborts in libc++ new.cpp when the executable (static mimalloc) interposes
# ? the engine's weak operator new: https://github.com/flutter/flutter/issues/188877
# set STV_PROTECTED on every dynsym symbol living in __lcxx_override, so the engine's own
# references bind locally and __is_function_overridden stays false
import struct
import sys

SHT_DYNSYM = 11
STV_PROTECTED = 3

path = sys.argv[1]
with open(path, "r+b") as f:
    data = bytearray(f.read())

    assert data[:6] == b"\x7fELF\x02\x01", "expected 64-bit little-endian ELF"
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from("<HHH", data, 0x3A)

    def section(i: int):
        return struct.unpack_from("<IIQQQQIIQQ", data, e_shoff + i * e_shentsize)

    def cstr(off: int):
        return data[off : data.index(b"\0", off)].decode()

    sections = [section(i) for i in range(e_shnum)]
    shstrtab = sections[e_shstrndx][4]

    override_idx = None
    dynsym = None
    for i, sh in enumerate(sections):
        if cstr(shstrtab + sh[0]) == "__lcxx_override":
            override_idx = i
        if sh[1] == SHT_DYNSYM:
            dynsym = sh
    assert override_idx is not None, "no __lcxx_override section, drop this patch"
    assert dynsym is not None, "no .dynsym section"
    dynstr = sections[dynsym[6]][4]

    patched = []
    for off in range(dynsym[4], dynsym[4] + dynsym[5], dynsym[9]):
        st_name, _, st_other, st_shndx = struct.unpack_from("<IBBH", data, off)
        if st_shndx != override_idx or st_other != 0:
            continue
        data[off + 5] = STV_PROTECTED
        patched.append(cstr(dynstr + st_name))

    assert "_Znwm" in patched, f"operator new not found in __lcxx_override: {patched}"
    f.seek(0)
    f.write(data)

print(f"lcxx-protected: {', '.join(patched)}")
