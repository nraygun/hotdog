#!/usr/bin/env python3
"""Generate 160A text-label PNGs for Hotdog! (pure stdlib, no PIL).

Why these exist: the atascii font is a 320A characterset. In the 160A gameplay
and game-over screens, 320A plotchars text renders doubled/overlapping. These
labels are authored at native 160A resolution (a 5x7 pixel font, 8-px cells) so
they stay crisp and match the 160A digit sprites. Plot them with plotsprite.

Run from anywhere:  python3 tools/makelabels.py
"""
import os, zlib, struct

OUT = os.path.join(os.path.dirname(__file__), "..", "gfx")

# 5x7 pixel font, '1' = lit pixel, '.' = transparent. Uniform 5-wide cells.
FONT = {
    'A': ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    'B': ["11110", "10001", "10001", "11110", "10001", "10001", "11110"],
    'C': ["01111", "10000", "10000", "10000", "10000", "10000", "01111"],
    'D': ["11110", "10001", "10001", "10001", "10001", "10001", "11110"],
    'E': ["11111", "10000", "10000", "11110", "10000", "10000", "11111"],
    'F': ["11111", "10000", "10000", "11110", "10000", "10000", "10000"],
    'G': ["01111", "10000", "10000", "10111", "10001", "10001", "01111"],
    'H': ["10001", "10001", "10001", "11111", "10001", "10001", "10001"],
    'I': ["01110", "00100", "00100", "00100", "00100", "00100", "01110"],
    'K': ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
    'L': ["10000", "10000", "10000", "10000", "10000", "10000", "11111"],
    'M': ["10001", "11011", "10101", "10001", "10001", "10001", "10001"],
    'N': ["10001", "11001", "10101", "10101", "10101", "10011", "10001"],
    'O': ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
    'P': ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    'R': ["11110", "10001", "10001", "11110", "10100", "10010", "10001"],
    'S': ["01111", "10000", "10000", "01110", "00001", "00001", "11110"],
    'T': ["11111", "00100", "00100", "00100", "00100", "00100", "00100"],
    'U': ["10001", "10001", "10001", "10001", "10001", "10001", "01110"],
    'V': ["10001", "10001", "10001", "10001", "10001", "01010", "00100"],
    'Y': ["10001", "10001", "01010", "00100", "00100", "00100", "00100"],
    ' ': ["00000", "00000", "00000", "00000", "00000", "00000", "00000"],
}
PALETTE = [(0, 0, 0), (216, 168, 96), (160, 96, 48), (250, 250, 250)]


def chunk(tag, data):
    c = tag + data
    return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xffffffff)


def render(word, gapn=3):
    gap = "0" * gapn                   # inter-glyph gap; 3 -> 8-px cells, smaller packs tighter
    rows = []
    for r in range(7):
        rows.append("".join(FONT[c][r].replace("1", "1") + gap for c in word))
    rows.append("0" * len(rows[0]))   # blank 8th row
    w = len(rows[0])
    while w % 4:                       # 160A width must be a multiple of 4
        rows = [r + "0" for r in rows]
        w += 1
    return rows, w, len(rows)


def write_label(name, word, gapn=3):
    rows, w, h = render(word, gapn)
    m = {"0": 0, "1": 1}
    raw = bytearray()
    for line in rows:
        raw.append(0)
        raw.extend(m[ch] for ch in line)
    plte = b"".join(struct.pack("BBB", *c) for c in PALETTE)
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 3, 0, 0, 0))
    png += chunk(b"PLTE", plte) + chunk(b"tRNS", b"\x00")
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9)) + chunk(b"IEND", b"")
    path = os.path.join(OUT, name)
    with open(path, "wb") as f:
        f.write(png)
    print("wrote", os.path.relpath(path), f"{w}x{h}")


if __name__ == "__main__":
    write_label("score_label.png", "SCORE")
    write_label("gameover_label.png", "GAME OVER")
    write_label("pressfire_label.png", "PRESS FIRE")
    # cart-slide intro credit. A single 156-px sprite is too wide for Maria to
    # draw on one line (it clipped to garbage), so the org name is three tight
    # word-sprites laid out on one row; PRESENTS sits centered below.
    write_label("caa1_label.png", "CHICAGOLAND", 1)
    write_label("caa2_label.png", "ATARI", 1)
    write_label("caa3_label.png", "ALLIANCE", 1)
    write_label("presents_label.png", "PRESENTS")
    # NOTE: the title attract-mode showcase draws ingredient NAMES as 320A
    # plotchars text (same atascii font), not 160A label graphics, so no
    # name_*/role_* labels are generated here.
