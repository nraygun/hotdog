#!/usr/bin/env python3
"""Generate the cart attract-slide graphics for HOTDOG! (pure stdlib, no PIL).

Emits 4-color (2bpp) indexed 160A PNGs: index 0 = transparent, 1..3 = the
sprite's three 160A palette colors (actual on-screen colors come from the
P#C# regs set in hotdog.bas; the RGBs here are only for PNG preview).

  cart_umbrella.png  - Sabrett-style striped umbrella  (1=yellow 2=blue 3=white)
  cart_body.png      - stainless cart + sign + wheels   (1=silver 2=steel 3=black)
  hotdog_title.png   - chunky "HOT DOG!" splash word     (1=ink; glow-cycled at runtime)
"""
import zlib, struct, os

OUT = os.path.join(os.path.dirname(__file__), '..', 'gfx')

def write_png(path, rows, palette):
    h = len(rows); w = len(rows[0])
    raw = bytearray()
    for row in rows:
        raw.append(0)
        for ch in row:
            raw.append(int(ch))
    plte = bytes([0,0,0]) + b''.join(struct.pack('BBB', *c) for c in palette)
    trns = bytes([0])
    def chunk(t,d): return struct.pack('>I',len(d))+t+d+struct.pack('>I',zlib.crc32(t+d)&0xffffffff)
    sig = b'\x89PNG\r\n\x1a\n'
    ihdr = struct.pack('>IIBBBBB', w, h, 8, 3, 0, 0, 0)
    png = sig+chunk(b'IHDR',ihdr)+chunk(b'PLTE',plte)+chunk(b'tRNS',trns)+chunk(b'IDAT',zlib.compress(bytes(raw)))+chunk(b'IEND',b'')
    with open(path,'wb') as f: f.write(png)
    print('wrote', path, f'{w}x{h}')

def blank(w,h): return [[0]*w for _ in range(h)]
def to_rows(g): return [''.join(str(c) for c in row) for row in g]

# ---------------------------------------------------------------- umbrella
def umbrella():
    W,H = 84,30
    g = blank(W,H)
    cx = 42
    for x in range(W):
        dx = x-cx
        ytop = dx*dx//240                 # domed top: 0 at center, ~7 at edges
        seam = x % 14
        extra = 3 if seam in (6,7) else 0 # little scallop points at stripe seams
        ybot = 22 + extra
        col = 1 if (x//14) % 2 == 0 else 2  # alternating yellow / blue stripes
        for y in range(ytop, ybot):
            if 0 <= y < H: g[y][x] = col
        for y in range(18, 22):           # white valance band (the SABRETT strip)
            if 0 <= y < H and g[y][x] != 0: g[y][x] = 3
    for y in range(0,3):                   # finial knob on top
        for x in range(cx-1, cx+2): g[y][x] = 3
    return g

# ---------------------------------------------------------------- cart body
def disc(g, cx, cy, r, W, H):
    for y in range(cy-r, cy+r+1):
        for x in range(cx-r, cx+r+1):
            if 0<=x<W and 0<=y<H:
                d2 = (x-cx)**2 + (y-cy)**2
                if d2 <= r*r:
                    g[y][x] = 3 if d2 >= (r-3)**2 else 1   # black tire / silver hub
    for x in range(cx-(r-1), cx+r):        # silver spokes (cross)
        if 0<=x<W and (x-cx)**2 <= r*r: g[cy][x] = 1
    for y in range(cy-(r-1), cy+r):
        if 0<=y<H and (y-cy)**2 <= r*r: g[y][cx] = 1
    if 0<=cx<W and 0<=cy<H: g[cy][cx] = 2  # hub center

def cart():
    W,H = 64,88
    g = blank(W,H)
    for y in range(0,20): g[y][31]=2; g[y][32]=2      # umbrella pole
    for y in range(2,15):                              # menu sign (silver w/ black frame)
        for x in range(5,22): g[y][x]=1
        g[y][5]=3; g[y][21]=3
    for x in range(5,22): g[2][x]=3; g[14][x]=3
    for x in range(9,18): g[8][x]=2                    # squiggle on the sign
    for x in range(4,60): g[20][x]=2; g[21][x]=2       # stainless counter bar
    bx0,bx1,by0,by1 = 8,56,22,58
    for y in range(by0,by1):                           # body box (silver)
        for x in range(bx0,bx1): g[y][x]=1
    for y in range(by0+2,by1-2):                       # diamond quilting
        for x in range(bx0+2,bx1-2):
            if (x+y)%8==0 or (x-y)%8==0: g[y][x]=2
    for y in range(by0,by1): g[y][bx0]=3; g[y][bx1-1]=3   # black outline
    for x in range(bx0,bx1): g[by0][x]=3; g[by1-1][x]=3
    for x in range(12,52): g[58][x]=2                  # axle
    disc(g,40,72,13,W,H)                               # big front wheel
    disc(g,16,70,9,W,H)                                # small caster
    for x in range(8,56): g[86][x]=2                   # ground shadow
    return g

# ---------------------------------------------------------------- title word
FONT = {
 'H':['10001','10001','10001','11111','10001','10001','10001'],
 'O':['01110','10001','10001','10001','10001','10001','01110'],
 'T':['11111','00100','00100','00100','00100','00100','00100'],
 'D':['11110','10001','10001','10001','10001','10001','11110'],
 'G':['01110','10001','10000','10111','10001','10001','01111'],
 '!':['1','1','1','1','1','0','1'],
 ' ':['000','000','000','000','000','000','000'],
}

def title(text='HOT DOG!', scale=2):
    glyphs = [FONT[c] for c in text]
    base_w = sum(len(gl[0]) + 1 for gl in glyphs) - 1
    W, H = base_w*scale, 7*scale
    g = blank(W, H)
    ox = 0
    for gl in glyphs:
        gw = len(gl[0])
        for ry in range(7):
            for rx in range(gw):
                if gl[ry][rx] == '1':
                    for sy in range(scale):
                        for sx in range(scale):
                            g[ry*scale+sy][(ox+rx)*scale+sx] = 1
        ox += gw + 1
    return g

if __name__ == '__main__':
    RED=(210,40,40); WHITE=(240,240,240)
    SILVER=(200,200,205); STEEL=(110,110,120); BLACK=(20,20,20)
    INK=(240,200,40)
    # umbrella stripes alternate index1/index2 -> red/white (P3 set in hotdog.bas)
    write_png(os.path.join(OUT,'cart_umbrella.png'), to_rows(umbrella()), [RED,WHITE,WHITE])
    write_png(os.path.join(OUT,'cart_body.png'),     to_rows(cart()),     [SILVER,STEEL,BLACK])
    write_png(os.path.join(OUT,'hotdog_title.png'),  to_rows(title('HOTDOG!')), [INK,INK,INK])
