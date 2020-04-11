INCLUDE "../gbhw.inc"

; our constants to work with our sprite
; sprite 0Y is at the beginning of our OAM (sprite mem)
; 'EQU' -- equals
_SPR0_Y     EQU     _OAMRAM     
_SPR0_X     EQU     _OAMRAM+1
_SPR0_NUM   EQU     _OAMRAM+2
_SPR0_ATT   EQU     _OAMRAM+3


; vars to move our sprite around
_MOVX       EQU     _RAM
_MOVY       EQU     _RAM+1


; begin
SECTION "start", ROM0[$0100]
    nop
    jp      setup


; ROM header
SECTION "romheader", ROM0[$0104]
    NINTENDO_LOGO
    ROM_HEADER "0123456789ABCDE"


setup:
    nop
    di
    ld      sp, $ffff

; set our background and sprite palette colors   
init:
    ld      a, %11100100
    ld      [rBGP], a
    ld      [rOBP0], a

; zero out scroll X and scroll Y
    ld      a, 0
    ld      [rSCX], a
    ld      [rSCY], a

    call    turnoff_lcd

; load tiles
; 32 bytes (2 tiles)
    ld      hl, tiles
    ld      de, _VRAM
    ld      b, 32


; loop and load tile data, pointed to by HL
.load_loop
    ld      a, [hl]
    ld      [de], a
    dec     b
    jr      z, .end_load_loop
    inc     hl
    inc     de
    jr      .load_loop
.end_load_loop


; clear out bg by filling it with tile 0s 
; 32x32 tiles 
    ld      hl, _SCRN0
    ld      de, 32*32

; loop to clear out bg (32x32)
.clearbg_loop
    ld      a, 0
    ld      [hl], a
    dec     de
    ld      a, d
    or      e
    jp      z, .end_clearbg_loop
    inc     hl
    jp      .clearbg_loop
.end_clearbg_loop


; all map tiles are 0'd, we can create the sprite
    ; Y position
    ld      a, 30
    ld      [_SPR0_Y], a

    ; X position
    ld      a, 30
    ld      [_SPR0_X], a
    
    ; tile number
    ld      a, 1
    ld      [_SPR0_NUM], a

    ; special attributes
    ld      a, 0
    ld      [_SPR0_ATT], a

; configure and activate the display
    ld      a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJON
    ld      [rLCDC], a

; prepare animation vars
    ld      a, 1
    ld      [_MOVY], a
    ld      [_MOVX], a

animation:
; we first wait for VBlank
.wait:
    ld      a, [rLY]
    cp      145
    jr      nz, .wait

; increment Y
    ld      a, [_SPR0_Y]
    ld      hl, _MOVY
    add     a, [hl]
    ld      hl, _SPR0_Y
    ld      [hl], a

; so we don't exit the screen   
    cp      152
    jr      z, .dec_y
    cp      16
    jr      z, .inc_y
    jr      .end_y

.dec_y:
    ld      a, -1
    ld      [_MOVY], a
    jr      .end_y

.inc_y:
    ld      a, 1
    ld      [_MOVY], a

.end_y:
; start with X
    ld      a, [_SPR0_X]
    ld      hl, _MOVX
    add     a, [hl]

    ld      hl, _SPR0_X
    ld      [hl], a

; max X
    cp      160
    jr      z, .dec_x
    cp      8
    jr      z, .inc_x
    jr      .end_x

.dec_x:
    ld      a, -1
    ld      [_MOVX], a
    jr      .end_x

.inc_x:
    ld      a, 1
    ld      [_MOVX], a

.end_x:
    call    delay
    jr      animation

turnoff_lcd:
    ld      a, [rLCDC]
    rlca
    ret     nc


; wait for VBlank again
.wait_vblank:
    ld      a, [rLY]
    cp      145
    jr      nz, .wait_vblank
; we're in VBlank, turn off LCD
    ld      a, [rLCDC]
    res     7, a
    ld      [rLCDC], a
    ret


delay:
    ld      de, 2000

.exec_delay:
    dec     de
    ld      a, d
    or      e
    jr      z, .end_delay
    nop
    jr      .exec_delay
.end_delay:
    ret

tiles::
    DB  $00, $00, $00, $00, $00, $00, $00, $00
    DB  $00, $00, $00, $00, $00, $00, $00, $00
    DB $02,$02,$07,$07,$07,$07,$0F,$0F
    DB $1F,$1F,$0F,$00,$0C,$03,$8F,$00
    DB $4F,$60,$6D,$6F,$AD,$8F,$0D,$0F
    DB $0F,$0F,$0F,$0F,$0F,$0F,$00,$00
    DB $00,$00,$0A,$04,$0A,$0E,$8E,$8E
    DB $C4,$C4,$84,$04,$84,$04,$C4,$04
    DB $C4,$04,$FC,$FC,$F4,$F4,$84,$84
    DB $8E,$8E,$EA,$EA,$E0,$8E,$00,$00


    
