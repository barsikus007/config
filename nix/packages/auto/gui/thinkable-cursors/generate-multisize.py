#!/usr/bin/env python3
import os
import struct
import subprocess
import sys
import tempfile


def make_multisize(xcursor_path, mode, output_path, sizes=(32, 48, 64, 96, 128)):
    with tempfile.TemporaryDirectory() as tmpdir:
        with open(xcursor_path, "rb") as f:
            magic, _hsize, _ver, ntoc = struct.unpack("<4sIII", f.read(16))
            if magic != b"Xcur":
                raise ValueError(f"{xcursor_path} is not an Xcursor file")
            frames = []
            for _ in range(ntoc):
                _ctype, _subtype, pos = struct.unpack("<III", f.read(12))
                cur = f.tell()
                f.seek(pos)
                _hsize, _itype, _isubtype, _version, w, h, xhot, yhot, delay = struct.unpack("<IIIIIIIII", f.read(36))
                pix = f.read(w * h * 4)
                frames.append(
                    {
                        "w": w,
                        "h": h,
                        "xhot": xhot,
                        "yhot": yhot,
                        "delay": delay,
                        "pix": pix,
                    }
                )
                f.seek(cur)

        if not frames:
            raise ValueError(f"No frames in {xcursor_path}")

        orig_w = frames[0]["w"]
        orig_h = frames[0]["h"]

        for i, frame in enumerate(frames):
            pix = frame["pix"]
            rgba = bytearray(len(pix))
            for p in range(0, len(pix), 4):
                rgba[p] = pix[p + 2]
                rgba[p + 1] = pix[p + 1]
                rgba[p + 2] = pix[p]
                rgba[p + 3] = pix[p + 3]

            raw_path = os.path.join(tmpdir, f"frame_{i}.raw")
            with open(raw_path, "wb") as rf:
                rf.write(rgba)

            png_path = os.path.join(tmpdir, f"frame_{i}_{orig_w}.png")
            subprocess.run(
                [
                    "magick",
                    "-size",
                    f"{orig_w}x{orig_h}",
                    "-depth",
                    "8",
                    f"rgba:{raw_path}",
                    png_path,
                ],
                check=True,
            )

        config_lines = []
        for s in sizes:
            for i, frame in enumerate(frames):
                png_path = os.path.join(tmpdir, f"frame_{i}_{s}.png")
                if s != orig_w:
                    subprocess.run(
                        [
                            "magick",
                            os.path.join(tmpdir, f"frame_{i}_{orig_w}.png"),
                            "-filter",
                            "Lanczos",
                            "-resize",
                            f"{s}x{s}",
                            png_path,
                        ],
                        check=True,
                    )

                if mode == "busy":
                    xhot = s // 2
                    yhot = s // 2
                elif mode == "working":
                    xhot = 0
                    yhot = round(16 * s / 64)
                else:
                    xhot = round(frame["xhot"] * s / orig_w)
                    yhot = round(frame["yhot"] * s / orig_h)

                delay = frame["delay"] or 50
                config_lines.append(f"{s} {xhot} {yhot} {png_path} {delay}")
                if s == 32:
                    # Map nominal size 24 to the 32x32 frame so standard Linux size 24 gets normal 100% DPI scale
                    config_lines.append(f"24 {xhot} {yhot} {png_path} {delay}")

        cfg_path = os.path.join(tmpdir, "cursor.cfg")
        with open(cfg_path, "w", encoding="utf-8") as f:
            f.write("\n".join(config_lines) + "\n")

        subprocess.run(["xcursorgen", cfg_path, output_path], check=True)


def alias_32_to_24(xcursor_path):
    with tempfile.TemporaryDirectory() as tmpdir:
        with open(xcursor_path, "rb") as f:
            magic, _hsize, _ver, ntoc = struct.unpack("<4sIII", f.read(16))
            if magic != b"Xcur":
                return
            images = []
            for _ in range(ntoc):
                _ctype, _subtype, pos = struct.unpack("<III", f.read(12))
                cur = f.tell()
                f.seek(pos)
                _hsize, _itype, _isubtype, _version, w, h, xhot, yhot, delay = struct.unpack("<IIIIIIIII", f.read(36))
                pix = f.read(w * h * 4)
                images.append(
                    {
                        "w": w,
                        "h": h,
                        "xhot": xhot,
                        "yhot": yhot,
                        "delay": delay,
                        "pix": pix,
                    }
                )
                f.seek(cur)

        if not images:
            return

        cfg_lines = []
        for img in images:
            w, h = img["w"], img["h"]
            pix = img["pix"]
            rgba = bytearray(len(pix))
            for p in range(0, len(pix), 4):
                rgba[p] = pix[p + 2]
                rgba[p + 1] = pix[p + 1]
                rgba[p + 2] = pix[p]
                rgba[p + 3] = pix[p + 3]

            raw_path = os.path.join(tmpdir, f"frame_{w}.raw")
            with open(raw_path, "wb") as rf:
                rf.write(rgba)

            png_path = os.path.join(tmpdir, f"frame_{w}.png")
            subprocess.run(
                [
                    "magick",
                    "-size",
                    f"{w}x{h}",
                    "-depth",
                    "8",
                    f"rgba:{raw_path}",
                    png_path,
                ],
                check=True,
            )
            xh = img["xhot"]
            yh = img["yhot"]
            dl = img["delay"]
            cfg_lines.append(f"{w} {xh} {yh} {png_path} {dl}")
            if w == 32:
                # Map nominal size 24 to the 32x32 original crisp layer
                cfg_lines.append(f"24 {xh} {yh} {png_path} {dl}")

        cfg_path = os.path.join(tmpdir, "cursor.cfg")
        with open(cfg_path, "w", encoding="utf-8") as f:
            f.write("\n".join(cfg_lines) + "\n")

        subprocess.run(["xcursorgen", cfg_path, xcursor_path], check=True)


def process_cursor_dir(cursor_dir):
    busy_path = os.path.join(cursor_dir, "aero_busy")
    if os.path.exists(busy_path):
        make_multisize(busy_path, "busy", busy_path)

    working_path = os.path.join(cursor_dir, "aero_working")
    if os.path.exists(working_path):
        make_multisize(working_path, "working", working_path)

    for fname in os.listdir(cursor_dir):
        if fname in ("aero_busy", "aero_working"):
            continue
        p = os.path.join(cursor_dir, fname)
        if os.path.isfile(p) and not os.path.islink(p):
            alias_32_to_24(p)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate-multisize.py <cursor_dir>")
        sys.exit(1)
    process_cursor_dir(sys.argv[1])
