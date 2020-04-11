INCLUDE "hardware.inc"


SECTION "Header", ROM0[$100]

EntryPoint:
    di 
    jp Start

REPT $150 - $104
    db 0
ENDR

SECTION "Game", ROM0

Start:
.waitVBlank
    ld a, [rLY]
    cp 144
    jr c, .waitVBlank

    xor a ; a is zero'd
    ld [rLCDC], a

    ld hl, $9000
    ld de, FontTiles
    ld bc, FontTilesEnd - FontTiles
.copyfont
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyfont

    ld hl, $9800
    ld de, HelloWorldStr
.copystring
    ld a, [de]
    ld [hli], a
    inc de
    and a
    jr nz, .copystring

; Init display registers
    ld a, %11100100
    ld [rBGP], a
    
    xor a
    ld [rSCY], a; no y scroll
    ld [rSCX], a ; no x scroll
    
    ld [rNR52], a ; turn off sound

    ; turn screen on, display bg
    ld a, %10000001
    ld [rLCDC], a

.lockup
    jr .lockup

SECTION "Font", ROM0

FontTiles:
INCBIN "font.chr"
FontTilesEnd:

SECTION "Hello World", ROM0

HelloWorldStr:
    db "Hi icyphox!", 0
