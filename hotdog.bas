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

 rem --- enable the TIA music tracker (for the title-screen tune) ---
 set trackersupport basic

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

 rem --- 160A text-label graphics (match the digit style; stay crisp in 160A
 rem     screens where 320A plotchars text would render doubled/blurry) ---
 incgraphic gfx/score_label.png
 incgraphic gfx/gameover_label.png
 incgraphic gfx/pressfire_label.png

 rem --- cart attract-slide art (boot splash): striped umbrella, stainless cart,
 rem     and the chunky HOT DOG! title word (glow-cycled at runtime).
 rem     newblock: these are big and won't fit the remaining 4k gfx block ---
 newblock
 incgraphic gfx/cart_umbrella.png
 incgraphic gfx/cart_body.png
 incgraphic gfx/hotdog_title.png
 rem --- cart-slide intro credit (org name = 3 word-sprites on one row) ---
 incgraphic gfx/caa1_label.png
 incgraphic gfx/caa2_label.png
 incgraphic gfx/caa3_label.png
 incgraphic gfx/presents_label.png

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
 dim tuneon=x
 dim splitactive=y
 dim showitem=z
 dim musicdone=k

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

 rem --- palette 4: red (KETCHUP "ENEMY" warning text) ---
 P4C1=$44
 P4C2=$44
 P4C3=$44

 rem --- palette 3: cart umbrella (red & white stripes, white valance/finial) ---
 P3C1=$48
 P3C2=$0F
 P3C3=$0F

 rem --- palette 7: stainless cart (light silver, steel grey, black outline) ---
 P7C1=$0A
 P7C2=$06
 P7C3=$00

 rem --- palette 6: HOT DOG! splash word; C1 is glow-cycled on the cart slide ---
 P6C1=$1E
 P6C2=$1E
 P6C3=$1E

 state=0
 tuneon=0
 showitem=0
 splitactive=0
 musicdone=0

 rem ===================== CART SLIDE (boot splash, once) =====================
 rem  Full-screen 160A: the Sabrett umbrella cart with a bouncing, glowing
 rem  HOT DOG! word. Holds ~5s (5 x 60 frames) then falls into the marquee.
 rem  Fire skips straight to the game. Starts the marquee tune so music covers
 rem  the whole attract. Reuses spare title-time vars (reset by newgame).
cartslide
 splitactive=0
 adjustvisible 0 11
 displaymode 160A
 rem --- 'repeat' loops the tune; stopsong fires after the first full roll call ---
 if tuneon=0 then playsong hotdogmarch 100 repeat : tuneon=1
 frame=0
 catches=0
 inv=0
 kspeed=0
 kdirx=0
cartloop
 clearscreen
 BACKGRND=$00
 frame=frame+1
 inv=inv+1
 rem --- 5-second hold, then on to the marquee ---
 if frame>=60 then frame=0 : catches=catches+1
 if catches>=5 then goto titlescreen
 rem --- glow: cycle the HOT DOG! ink through yellow -> orange -> red ---
 kspeed=kspeed+1
 if kspeed>=14 then kspeed=0 : kdirx=kdirx+1
 if kdirx>2 then kdirx=0
 if kdirx=0 then P6C1=$1E
 if kdirx=1 then P6C1=$2E
 if kdirx=2 then P6C1=$48
 rem --- bounce: vertical bob for the title word from a small table ---
 ix=inv&15
 iy=bobtab[ix]
 iy=iy+30
 rem --- intro credit on one row (CHICAGOLAND ATARI ALLIANCE), PRESENTS below,
 rem     then umbrella + cart and the bobbing HOTDOG! word. No PRESS FIRE on this
 rem     screen (more room); fire still skips straight to the game. ---
 plotsprite caa1_label 5 2 4
 plotsprite caa2_label 5 74 4
 plotsprite caa3_label 5 110 4
 plotsprite presents_label 5 48 14
 plotsprite cart_umbrella 3 38 54
 plotsprite cart_body 7 48 72
 plotsprite hotdog_title 6 43 iy
 drawscreen
 if joy0fire then stopsong : playsfx sfx_powerup : gosub newgame : state=1 : goto playloop
 goto cartloop

 rem ===================== TITLE =====================
 rem  Split display: 320A crisp text in the header + footer, with a 160A band
 rem  carved out of the middle (via adjustvisible + top/bottomscreenroutine)
 rem  for the colorful 160A ingredient sprites. Set up once on entry.
titlescreen
 splitactive=1
 adjustvisible 6 8
 if tuneon=0 then playsong hotdogmarch 100 repeat : tuneon=1
 frame=0
 gosub chaseinit
titleloop
 displaymode 320A
 clearscreen
 BACKGRND=$00
 frame=frame+1
 rem --- ketchup beat: gentle red flash behind the title ---
 if showitem=7 && frame&16 then BACKGRND=$42
 rem --- header (320A crisp), centered: x=(160-len*4)/2 ---
 plotchars 'HOTDOG!' 5 66 2
 plotchars 'CATCH THE FOOD' 5 52 4
 plotchars 'AVOID THE KETCHUP' 5 46 5
 rem --- attract: scenes 0-1 = the (slow) chase gag, shown FIRST; scenes 2-7 =
 rem     the food roll call. drawscene runs the active scene and its own
 rem     advance/wrap, so the title loop just dispatches. ---
 gosub drawscene
 rem --- footer (320A crisp), below the showcase name/role ---
 plotchars 'PRESS FIRE' 5 60 11
 drawscreen
 if joy0fire then stopsong : playsfx sfx_powerup : gosub newgame : state=1 : goto playloop
 goto titleloop

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
 if inv=0 && boxcollision(bunx,buny,14,12, kx,ky,14,20) then gosub gothit
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

 rem --- HUD: score in the top zone; lives moved to the BOTTOM zone so the busy
 rem     top area can't exceed Maria's per-scanline DMA budget when food/ketchup/
 rem     player cluster up there (was 8 sprites in the top zone -> garble/"hang") ---
 plotsprite score_label 5 8 2
 plotsprite dig0 5 56 3 thousands
 plotsprite dig0 5 64 3 hundreds
 plotsprite dig0 5 72 3 tens
 plotsprite dig0 5 80 3 ones
 if lives>=1 then plotsprite bun 0 8 184
 if lives>=2 then plotsprite bun 0 24 184
 if lives>=3 then plotsprite bun 0 40 184

 drawscreen
 if state=2 then playsfx sfx_downthepipe : goto gameoverscreen
 goto playloop

 rem ===================== GAME OVER =====================
gameoverscreen
 rem --- full-screen 160A (split disabled) so the digit sprites render
 rem     correctly; text uses the 160A label graphics ---
 splitactive=0
 adjustvisible 0 11
 displaymode 160A
 clearscreen
 BACKGRND=$44
 plotsprite gameover_label 5 44 50
 plotsprite score_label 5 36 100
 plotsprite dig0 5 88 100 thousands
 plotsprite dig0 5 96 100 hundreds
 plotsprite dig0 5 104 100 tens
 plotsprite dig0 5 112 100 ones
 plotsprite pressfire_label 5 40 150
 drawscreen
 if joy0fire then playsfx sfx_powerup : gosub newgame : state=1 : goto playloop
 goto gameoverscreen

 rem ===================== SUBROUTINES =====================
newgame
 rem --- gameplay: full-screen 160A; disable the title's split-mode band ---
 splitactive=0
 adjustvisible 0 11
 displaymode 160A
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
 rem --- catch blip; pitch rises with ingredient (frank->mustard->relish->onion) ---
 playsfx sfx_bling itype
 ones=ones+1
 if ones>9 then ones=0 : tens=tens+1
 if tens>9 then tens=0 : hundreds=hundreds+1
 if hundreds>9 then hundreds=0 : thousands=thousands+1
 catches=catches+1
 flash=8
 if catches=8 then kspeed=2 : playsfx sfx_uhoh
 gosub spawnfood
 return

gothit
 playsfx sfx_ouch
 lives=lives-1
 inv=60
 hitflash=12
 bunx=72
 buny=150
 return

 rem --- title ingredient showcase: ONLY the 160A sprite lives in the band (one
 rem     object per scanline = no flicker); the name + role are crisp 320A
 rem     plotchars in the footer below, same atascii font as the rest of the
 rem     title. Foods 0-3 set their P2 palette via setfoodpalette.
 rem     plotchars x centered = (160 - len*4)/2 = 80 - len*2. ---
drawshowcase
 rem --- foods are scenes 2-5 (itype 0-3); bun=6, ketchup=7 use global palettes ---
 if showitem<6 then itype=showitem-2 : gosub setfoodpalette
 rem --- sprite low in the 160A band, just above the name (band is ~y96-127) ---
 if showitem=2 then plotsprite frank 2 72 110
 if showitem=3 then plotsprite mustard 2 72 110
 if showitem=4 then plotsprite relish 2 70 110
 if showitem=5 then plotsprite onion 2 72 110
 if showitem=6 then plotsprite bun 0 72 110
 rem --- ketchup is taller (22px); raise it so it bottom-aligns inside the band ---
 if showitem=7 then plotsprite ketchup 1 72 104
 rem --- name (320A footer, same font), centered ---
 if showitem=2 then plotchars 'FRANKS' 5 68 9
 if showitem=3 then plotchars 'MUSTARD' 5 66 9
 if showitem=4 then plotchars 'RELISH' 5 68 9
 if showitem=5 then plotchars 'ONIONS' 5 68 9
 if showitem=6 then plotchars 'BUN' 5 74 9 : plotchars 'PLAYER' 5 68 10
 if showitem=7 then plotchars 'KETCHUP' 5 66 9 : plotchars 'ENEMY' 5 70 10
 return

 rem --- attract scene dispatch: 0-1 = chase gag (shown FIRST), 2-7 = roll call.
 rem     Chase scenes advance themselves on sprite position; roll-call scenes
 rem     advance on a frame timer and wrap 7 -> 0 back into the chase. ---
drawscene
 if showitem<=1 then gosub drawchase : return
 gosub drawshowcase
 if frame<70 then return
 frame=0
 showitem=showitem+1
 if showitem>7 then showitem=0
 rem --- first time the roll call wraps (all food shown once): stop the tune ---
 if showitem=0 && musicdone=0 then stopsong : musicdone=1
 gosub chaseinit
 return

 rem --- (re)position the chase as scene 0 begins: dog (frank, ix) ahead at x40,
 rem     bun (bunx) a gap (kx) behind, gain counter (ky) cleared, frank palette.
 rem     No-op for any other scene, so it's safe to call on boot and every wrap.
 rem     kx/ky are the gameplay ketchup coords -- reused here, reset by newgame. ---
chaseinit
 if showitem=0 then ix=40 : kx=32 : ky=0 : bunx=8 : itype=0 : gosub setfoodpalette
 return

 rem --- "BUN CHASES DOG / KETCHUP CHASES BUN" attract gag (SLOW, with tension) -
 rem  Scene 0: the frank strolls in from the left; the bun chases a touch faster
 rem  so the gap (kx) keeps closing and it ALMOST grabs the dog right as the dog
 rem  slips off the right edge.
 rem  Scene 1: the bun turns and flees left; a ketchup bottle gives chase from
 rem  the right, SPEEDING UP as the bun nears the edge for a near-miss, then the
 rem  attract rolls on into the food roll call (scene 2).
 rem  Motion is gated to every other frame (frame&1) so the gag plays slowly; the
 rem  per-scene step is in stepA/stepB. The gap (kx) is floored so the chaser
 rem  never actually overtakes. Sprites stay horizontally separated (one object
 rem  per scanline -> no flicker); the scene-0/1 branch keeps both halves off the
 rem  transition frame. ---
drawchase
 if showitem=1 then goto chaseB
 rem -- scene 0: draw dog + bun, then close the gap on alternate frames --
 plotchars 'GET THE DOG!' 5 56 9
 plotsprite frank 2 ix 110 : plotsprite bun 0 bunx 110
 if frame&1 then gosub stepA
 return
stepA
 ix=ix+1
 ky=ky+1
 if ky>=4 then ky=0 : kx=kx-1
 if kx<3 then kx=3
 bunx=ix-kx
 if ix>=158 then showitem=1 : bunx=150 : kx=20 : ky=0 : ix=170
 return
chaseB
 rem -- scene 1: draw bun + ketchup, then close the gap on alternate frames --
 plotchars 'NO KETCHUP!' 5 58 9
 plotsprite bun 0 bunx 110 : plotsprite ketchup 1 ix 104
 if frame&1 then gosub stepB
 return
stepB
 bunx=bunx-1
 ky=ky+1
 if ky>=10 then ky=0 : kx=kx-1
 if bunx<35 then kx=kx-1
 if kx<4 then kx=4
 ix=bunx+kx
 if bunx<=6 then showitem=2 : frame=0
 return

 rem ===================== DISPLAY-SPLIT INTERRUPTS =====================
 rem  These fire every frame at the top/bottom of the "visible" region set by
 rem  adjustvisible. On the title (splitactive=1) they carve a 160A band out
 rem  of the 320A screen; elsewhere (splitactive=0) everything stays 160A so
 rem  gameplay/game-over sprites never see a stray 320A zone.
topscreenroutine
 WSYNC=1
 displaymode 160A
 WSYNC=1
 return

bottomscreenroutine
 WSYNC=1
 if splitactive then displaymode 320A else displaymode 160A
 WSYNC=1
 return

 rem --- cart-slide title bob: gentle 0..6..0 vertical offset (16-frame loop) ---
 data bobtab
 0,0,1,2,3,4,5,5,6,6,5,4,3,2,1,0
end

 rem ===================== SOUND DATA =====================
 rem  Title-screen tune (TIA tracker) + event sound effects.
 rem  Instruments + song authored for HOTDOG!; sfx blocks are
 rem  from the 7800basic soundtest library.

 data tiaplain
  $10,$00,$00 ; version, priority, frames per chunk
  $00,$08 ; note offset, volume
  $00,$08
  $00,$06
  $00,$04
  $00,$00
end

 data tiabass
  $10,$00,$02 ; version, priority, frames per chunk
  $00,$06
  $00,$04
  $00,$04
  $00,$00
end

 rem =================== THE SONG ===================
 songdata hotdogmarch

 ;---- voice 1: melody ----
main1
 k=a3
 i=tiaplain
 ; bar1 C            bar2 C
 g8 e8 g8 a8   g8 e8 c8 r8     g8 e8 g8 > c8   < a8 g8 e8 r8
 ; bar3 F            bar4 G
 a8 f8 a8 > c8   < a8 f8 a8 r8   b8 g8 b8 > d8   < g4 r4
 ; bar5 C            bar6 C
 > c8 < g8 e8 g8   > c8 < g8 e8 r8   a8 g8 e8 c8   g8 e8 c8 r8
 ; bar7 G            bar8 C
 d8 g8 b8 > d8   < g8 b8 > d8 r8 <   > c4 < g8 e8   c2

 ;---- voice 2: oom-pah bass ----
main2
 k=a2
 i=tiabass
 ; C                C
 c8 r8 g8 r8 c8 r8 g8 r8     c8 r8 g8 r8 c8 r8 g8 r8
 ; F                G
 f8 r8 > c8 < r8 f8 r8 > c8 < r8     g8 r8 > d8 < r8 g8 r8 > d8 < r8
 ; C                C
 c8 r8 g8 r8 c8 r8 g8 r8     c8 r8 g8 r8 c8 r8 g8 r8
 ; G                C
 g8 r8 > d8 < r8 g8 r8 > d8 < r8     c8 r8 g8 r8 c2
end

 rem ---- event sound effects ----
 data sfx_bling
 $10,$10,$00 ; version, priority, frames per chunk
 $1c,$04,$07
 $1b,$04,$07
 $04,$0f,$05
 $15,$04,$09
 $16,$04,$07
 $03,$0f,$04
 $11,$04,$08
 $11,$04,$08
 $11,$04,$04
 $0e,$04,$09
 $0e,$04,$07
 $0e,$04,$04
 $1c,$04,$07
 $1b,$04,$05
 $1c,$04,$04
 $1b,$04,$02
 $00,$00,$00
end

 data sfx_ouch
 $10,$10,$00 ; version, priority, frames per chunk
 $07,$0c,$0f ; first chunk of freq,channel,volume
 $07,$0c,$0f
 $07,$0c,$0f
 $18,$04,$07
 $19,$04,$04
 $07,$0c,$09
 $19,$04,$0f
 $19,$04,$0d
 $19,$04,$0f
 $19,$04,$0f
 $1b,$04,$0f
 $1b,$04,$0f
 $1b,$04,$0f
 $1b,$04,$0f
 $1b,$04,$09
 $1b,$04,$05
 $1b,$04,$03
 $1b,$04,$02
 $1c,$04,$01
 $1c,$04,$01
 $1c,$04,$01
 $1b,$04,$02
 $19,$04,$00
 $1b,$04,$00
 $19,$04,$01
 $00,$00,$00
end

 data sfx_downthepipe
 $10,$10,$00 ; version, priority, frames per chunk
 $1e,$06,$0f ; first chunk of freq,channel,volume
 $1e,$06,$0f
 $18,$04,$08
 $0c,$0c,$0d
 $12,$0c,$0b
 $0a,$06,$06
 $18,$04,$0a
 $0c,$0c,$0b
 $03,$06,$0f
 $1e,$0c,$0e
 $1e,$06,$0f
 $0f,$06,$0f
 $1e,$06,$02
 $1e,$06,$00
 $1e,$06,$00
 $07,$06,$00
 $1e,$06,$0f
 $1e,$06,$0f
 $18,$04,$08
 $0c,$0c,$0d
 $12,$0c,$0b
 $0a,$06,$06
 $18,$04,$0a
 $0c,$0c,$0b
 $03,$06,$0f
 $1e,$0c,$0e
 $1e,$06,$0f
 $0f,$06,$0f
 $1e,$06,$02
 $1e,$06,$00
 $1e,$06,$00
 $07,$06,$00
 $1e,$06,$0f
 $1e,$06,$0f
 $18,$04,$08
 $0c,$0c,$0d
 $12,$0c,$0b
 $0a,$06,$06
 $18,$04,$0a
 $0c,$0c,$0b
 $03,$06,$0f
 $1e,$0c,$0e
 $1e,$06,$0f
 $0f,$06,$0f
 $1e,$06,$02
 $1e,$06,$00
 $1e,$06,$00
 $07,$06,$00
 $00,$00,$00
end

 data sfx_powerup
 $10,$10,$00 ; version, priority, frames per chunk
 $1e,$06,$0f ; first chunk of freq,channel,volume
 $1c,$04,$0f
 $0c,$0c,$0f
 $0c,$0c,$0f
 $0c,$0c,$0f
 $1c,$04,$0f
 $1b,$04,$0a
 $16,$04,$09
 $12,$04,$07
 $12,$04,$0e
 $12,$04,$08
 $0d,$04,$03
 $12,$04,$08
 $12,$04,$0f
 $0b,$0c,$0f
 $0b,$0c,$0f
 $0b,$0c,$0c
 $1c,$04,$06
 $1c,$04,$0c
 $07,$0c,$0f
 $07,$0c,$09
 $05,$0c,$0a
 $18,$04,$07
 $07,$0c,$0f
 $07,$0c,$0a
 $05,$0c,$0c
 $05,$0c,$05
 $1e,$06,$03
 $03,$0c,$04
 $03,$0c,$04
 $03,$0c,$04
 $02,$0c,$08
 $03,$0c,$04
 $1e,$06,$02
 $0a,$0c,$0e
 $0a,$0c,$0f
 $1e,$04,$0d
 $19,$04,$08
 $15,$04,$0b
 $15,$04,$0f
 $15,$04,$08
 $0f,$04,$07
 $15,$04,$07
 $15,$04,$0c
 $06,$0c,$07
 $0f,$04,$02
 $00,$06,$04
 $01,$0c,$00
 $0a,$04,$04
 $0a,$04,$08
 $0a,$04,$03
 $07,$04,$03
 $0a,$04,$03
 $00,$00,$00
end

 data sfx_uhoh
 $10,$10,$00 ; version, priority, frames per chunk
 $07,$06,$01 ; first chunk of freq,channel,volume
 $1e,$0c,$03
 $1e,$0c,$04
 $17,$0c,$04
 $0a,$06,$06
 $0a,$0c,$0a
 $07,$06,$0f
 $1e,$04,$0f
 $19,$04,$0f
 $19,$04,$0f
 $1b,$04,$07
 $18,$04,$07
 $18,$04,$04
 $07,$0c,$02
 $16,$04,$00
 $16,$04,$00
 $16,$04,$00
 $0f,$06,$00
 $1e,$06,$00
 $1e,$06,$00
 $1e,$06,$00
 $19,$04,$00
 $1e,$04,$01
 $1e,$04,$0a
 $1c,$04,$0f
 $1c,$04,$0f
 $1e,$04,$0f
 $1b,$0c,$0f
 $0d,$0c,$0f
 $0d,$0c,$0e
 $0e,$0c,$0f
 $0e,$0c,$0f
 $0e,$0c,$0f
 $0e,$0c,$0f
 $0e,$0c,$0f
 $0e,$0c,$0d
 $1b,$0c,$0a
 $04,$0c,$0a
 $1b,$0c,$0b
 $0e,$0c,$0a
 $0e,$0c,$0a
 $1b,$0c,$0a
 $0d,$0c,$0a
 $0d,$0c,$06
 $0e,$0c,$04
 $0e,$0c,$04
 $0e,$0c,$02
 $00,$00,$00
end

