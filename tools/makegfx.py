#!/usr/bin/env python3
"""Generate indexed-palette PNG sprites for Hotdog! (pure stdlib, no PIL).

7800basic's incgraphic uses each pixel's *palette index*; the displayed color
comes from the PxCy registers set in hotdog.bas. So these PNGs only need 4
distinguishable palette entries (index 0 = transparent/background).

Sprites are 16x16, defined as ASCII art:
  '.' -> 0 (transparent)   '1' -> 1   '2' -> 2   '3' -> 3
"""
import os, zlib, struct

OUT = os.path.join(os.path.dirname(__file__), "..", "gfx")

# A 4-entry RGB palette just so the PNGs look sane in an editor. The real
# on-console colors are chosen by PxCy registers in hotdog.bas.
PALETTE = [
    (0, 0, 0),        # 0 transparent/background
    (216, 168, 96),   # 1
    (160, 96, 48),    # 2
    (250, 250, 250),  # 3
]


def chunk(tag, data):
    c = tag + data
    return struct.pack(">I", len(data)) + c + struct.pack(">I", zlib.crc32(c) & 0xffffffff)


def write_png(path, rows):
    h = len(rows)
    w = len(rows[0])
    assert all(len(r) == w for r in rows), f"ragged art in {path}"
    raw = bytearray()
    for r in rows:
        raw.append(0)  # filter type 0 (none)
        raw.extend(r)
    plte = b"".join(struct.pack("BBB", *c) for c in PALETTE)
    trns = b"\x00"  # palette index 0 fully transparent
    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 3, 0, 0, 0))
    png += chunk(b"PLTE", plte)
    png += chunk(b"tRNS", trns)
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(png)
    print("wrote", os.path.relpath(path), f"{w}x{h}")


def art(s):
    rows = s.strip("\n").splitlines()
    w = max(len(r) for r in rows)
    w = (w + 3) & ~3  # 160A needs width a multiple of 4
    m = {".": 0, "1": 1, "2": 2, "3": 3}
    out = []
    for line in rows:
        line = line.ljust(w, ".")
        out.append(bytes(m[ch] for ch in line))
    return out


# --- Player: an open hot dog bun (poppy-seed). idx1=bun, idx2=shadow, idx3=seed
BUN = art("""
................
................
.2221111111222..
.2113333333112..
.1133131313311..
.1111111111111..
.1131311313131..
.1111111111111..
.1113131311311..
.1111111111111..
.2113131313112..
.2211111111122..
..2221111122 ..
""".replace(" ", "."))

# --- Ketchup bottle (the enemy). idx1=red body, idx2=dark, idx3=white cap/label
KETCHUP = art("""
......2222......
......2332......
......2332......
......2332......
......2332......
.....233332.....
.....211112.....
....21111112....
....21111112....
....21133112....
....21133112....
....21133112....
....21111112....
....21111112....
....21111112....
....21111112....
....21111112....
....21111112....
....21111112....
....21111112....
....21111112....
.....222222.....
""")

# --- Frankfurter (an ingredient). idx1=meat, idx2=dark, idx3=sheen
FRANK = art("""
................
................
...2222222222...
..211111111112..
.21133111133112.
.21111111111112.
.21111111111112.
..211111111112..
...2222222222...
................
""")

# --- Mustard squiggle. idx1=yellow, idx2=dark edge, idx3=highlight
MUSTARD = art("""
................
..21........12..
..2112....2112..
...211222112....
....2113311 ....
.....21111......
......2112......
.....211112.....
....21133112....
...2112..2112...
..212......212..
..2..........2..
""".replace(" ", "."))

# --- Relish heap. idx1=green, idx2=dark, idx3=light fleck
RELISH = art("""
................
................
.....2122212.....
...2113133112...
..211313131312..
.21131313131312.
.21313131313112.
.21131313131312.
..211313131312..
...2113133112...
.....222222.....
""".replace(" ", "."))

# --- Onion bits. idx1=white, idx2=edge, idx3=center
ONION = art("""
................
...212....212...
..21312..21312..
..21312..21312..
...212....212...
......212.......
....21312.......
....21312..212..
.....212..21312.
..........21312.
...........212..
""".replace(" ", "."))

# --- Digit strip for plotvalue: glyph index 0='0' .. 9='9', 8x8 cells, ink=1.
# plotvalue maps each BCD nibble to the cell at that index, so order matters.
_DIGITS = [
"""
..1111..
.1....1.
.1...11.
.1..1.1.
.1.1..1.
.11...1.
.1....1.
..1111..
""",
"""
...11...
..111...
...11...
...11...
...11...
...11...
...11...
..1111..
""",
"""
..1111..
.1....1.
......1.
.....1..
...11...
..1.....
.1......
.111111.
""",
"""
.111111.
......1.
.....1..
...111..
.....1..
......1.
.1....1.
..1111..
""",
"""
....11..
...1.1..
..1..1..
.1...1..
.111111.
.....1..
.....1..
.....1..
""",
"""
.111111.
.1......
.1......
.11111..
......1.
......1.
.1....1.
..1111..
""",
"""
..1111..
.1......
.1......
.11111..
.1....1.
.1....1.
.1....1.
..1111..
""",
"""
.111111.
......1.
.....1..
....1...
...1....
..1.....
..1.....
..1.....
""",
"""
..1111..
.1....1.
.1....1.
..1111..
.1....1.
.1....1.
.1....1.
..1111..
""",
"""
..1111..
.1....1.
.1....1.
.1....1.
..11111.
......1.
......1.
..1111..
""",
]


def digit_strip():
    glyphs = [art(d) for d in _DIGITS]  # each is list of 8 byte-rows, 8 wide
    h = len(glyphs[0])
    rows = []
    for r in range(h):
        rows.append(b"".join(g[r] for g in glyphs))  # concat the 10 glyphs side by side
    return rows


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    # individual digit sprites dig0..dig9 (loaded consecutively in the .bas so
    # plotsprite dig0 ... <value> selects the glyph via the frame parameter)
    for d, artstr in enumerate(_DIGITS):
        write_png(os.path.join(OUT, "dig%d.png" % d), art(artstr))
    write_png(os.path.join(OUT, "bun.png"), BUN)
    write_png(os.path.join(OUT, "ketchup.png"), KETCHUP)
    write_png(os.path.join(OUT, "frank.png"), FRANK)
    write_png(os.path.join(OUT, "mustard.png"), MUSTARD)
    write_png(os.path.join(OUT, "relish.png"), RELISH)
    write_png(os.path.join(OUT, "onion.png"), ONION)
