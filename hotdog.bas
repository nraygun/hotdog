 rem ===========================================================
 rem  HOTDOG!  - Atari 7800 (7800basic)
 rem  Chicagoland Atari Alliance / nraygun/hotdog
 rem
 rem  Prototype, Manny-style design:
 rem  Roam the stand catching ingredients while a ketchup
 rem  bottle ricochets around the screen. Touch ketchup =
 rem  lose a life. 3 lives. Absolutely no ketchup!
 rem ===========================================================

 set tv ntsc
 set romsize 48k
 set zoneheight 16
 set screenheight 192
 displaymode 160A

 rem --- ingredient + character sprites ---
 incgraphic gfx/bun.png
 incgraphic gfx/ketchup.png
 incgraphic gfx/frank.png
 incgraphic gfx/mustard.png
 incgraphic gfx/relish.png
 incgraphic gfx/onion.png

 rem --- HUD font: atascii (320A 1bpp) for text labels; mixes fine with 160A sprites ---
 incgraphic gfx/atascii.png 320A
 characterset atascii
 alphachars ASCII

 rem --- digit sprites: loaded consecutively so plotsprite dig0 .. <value>
 rem     selects the right glyph via the frame parameter (avoids plotvalue,
 rem     which needs doublewide in 160A and would stretch the game sprites) ---
 incgraphic gfx/dig0.png
 incgraphic gfx/dig1.png
 incgraphic gfx/dig2.png
 incgraphic gfx/dig3.png
 incgraphic gfx/dig4.png
 incgraphic gfx/dig5.png
 incgraphic gfx/dig6.png
 incgraphic gfx/dig7.png
 incgraphic gfx/dig8.png
 incgraphic gfx/dig9.png

 rem --- variables ---
 dim bunx=a
 dim buny=b
 dim kx=c
 dim ky=d
 dim kdirx=e
 dim kdiry=f
 dim kspeed=g
 dim ix=h
 dim iy=i
 dim itype=j
 dim lives=l
 dim inv=m
 dim frame=n
 dim state=o
 dim catches=p
 dim bvis=q
 dim flash=r
 dim hitflash=s
 dim ones=t
 dim tens=u
 dim hundreds=v
 dim thousands=w

 rem --- palette 0: bun (tan body, brown shade, dark poppy seeds) ---
 P0C1=$1C
 P0C2=$16
 P0C3=$00

 rem --- palette 1: ketchup (red body, dark red, white cap) ---
 P1C1=$44
 P1C2=$40
 P1C3=$0F

 rem --- palette 5: white HUD text ---
 P5C1=$0F
 P5C2=$0F
 P5C3=$0F

 state=0

 rem ===================== TITLE =====================
titlescreen
 clearscreen
 BACKGRND=$00
 plotchars 'HOTDOG!' 5 60 3
 plotchars 'CATCH THE FOOD' 5 28 6
 plotchars 'AVOID THE KETCHUP' 5 22 7
 plotchars 'PRESS FIRE' 5 44 10
 drawscreen
 if joy0fire then gosub newgame : state=1 : goto playloop
 goto titlescreen

 rem ===================== GAMEPLAY =====================
playloop
 clearscreen
 frame=frame+1

 rem --- player movement (guarded so bytes never under/overflow) ---
 if joy0left && bunx>5 then bunx=bunx-2
 if joy0right && bunx<140 then bunx=bunx+2
 if joy0up && buny>24 then buny=buny-2
 if joy0down && buny<168 then buny=buny+2

 rem --- ketchup ricochet (one move per frame, bounce at walls) ---
 if kdirx=0 then kx=kx+kspeed else kx=kx-kspeed
 if kx>=140 then kdirx=1
 if kx<=8 then kdirx=0
 if kdiry=0 then ky=ky+kspeed else ky=ky-kspeed
 if ky>=168 then kdiry=1
 if ky<=24 then kdiry=0

 rem --- collisions ---
 if boxcollision(bunx,buny,14,12, ix,iy,14,12) then gosub gotfood
 if inv=0 && boxcollision(bunx,buny,14,12, kx,ky,14,14) then gosub gothit
 if inv>0 then inv=inv-1
 if lives=0 then state=2

 rem --- background: dark counter, flash green on catch / red on hit ---
 BACKGRND=$00
 if flash>0 then flash=flash-1 : BACKGRND=$C8
 if hitflash>0 then hitflash=hitflash-1 : BACKGRND=$44

 rem --- draw current ingredient ---
 if itype=0 then plotsprite frank 2 ix iy
 if itype=1 then plotsprite mustard 2 ix iy
 if itype=2 then plotsprite relish 2 ix iy
 if itype=3 then plotsprite onion 2 ix iy

 rem --- draw ketchup ---
 plotsprite ketchup 1 kx ky

 rem --- draw player (blink while invulnerable) ---
 if inv=0 then bvis=1
 if inv>0 then bvis=frame&4
 if bvis then plotsprite bun 0 bunx buny

 rem --- HUD: score digits + remaining lives as bun icons ---
 plotchars 'SCORE' 5 8 0
 plotsprite dig0 5 56 3 thousands
 plotsprite dig0 5 64 3 hundreds
 plotsprite dig0 5 72 3 tens
 plotsprite dig0 5 80 3 ones
 if lives>=1 then plotsprite bun 0 110 4
 if lives>=2 then plotsprite bun 0 126 4
 if lives>=3 then plotsprite bun 0 142 4

 drawscreen
 if state=2 then goto gameoverscreen
 goto playloop

 rem ===================== GAME OVER =====================
gameoverscreen
 clearscreen
 BACKGRND=$44
 plotchars 'GAME OVER' 5 44 4
 plotchars 'SCORE' 5 40 7
 plotsprite dig0 5 84 106 thousands
 plotsprite dig0 5 92 106 hundreds
 plotsprite dig0 5 100 106 tens
 plotsprite dig0 5 108 106 ones
 plotchars 'PRESS FIRE' 5 44 10
 drawscreen
 if joy0fire then gosub newgame : state=1 : goto playloop
 goto gameoverscreen

 rem ===================== SUBROUTINES =====================
newgame
 lives=3
 ones=0
 tens=0
 hundreds=0
 thousands=0
 catches=0
 kspeed=1
 bunx=72
 buny=150
 kx=20
 ky=30
 kdirx=0
 kdiry=0
 inv=0
 flash=0
 hitflash=0
 frame=0
 gosub spawnfood
 return

spawnfood
 ix=rand
 ix=ix&127
 ix=ix+8
 iy=rand
 iy=iy&63
 iy=iy+28
 itype=catches&3
 gosub setfoodpalette
 return

setfoodpalette
 rem frank
 if itype=0 then P2C1=$34 : P2C2=$22 : P2C3=$3A
 rem mustard
 if itype=1 then P2C1=$1C : P2C2=$16 : P2C3=$1E
 rem relish
 if itype=2 then P2C1=$C8 : P2C2=$C2 : P2C3=$CC
 rem onion
 if itype=3 then P2C1=$0E : P2C2=$08 : P2C3=$0C
 return

gotfood
 ones=ones+1
 if ones>9 then ones=0 : tens=tens+1
 if tens>9 then tens=0 : hundreds=hundreds+1
 if hundreds>9 then hundreds=0 : thousands=thousands+1
 catches=catches+1
 flash=8
 if catches=8 then kspeed=2
 gosub spawnfood
 return

gothit
 lives=lives-1
 inv=60
 hitflash=12
 bunx=72
 buny=150
 return
