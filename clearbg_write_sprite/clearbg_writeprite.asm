INCLUDE "../gbhw.inc"

SECTION "start", ROM0[$0100]
    nop
    jp init

SECTION "romheader", ROM0[$0104]
    NINTENDO_LOGO
    ROM_HEADER "0123456789ABCDE"

init:
    nop
    di
    ld sp, $ffff
    
    ld a, %11100100
    ld [rBGP], a ; palette colors -- written to the palette register
    xor a
    ld [rSCX], a
    ld [rSCY], a

    call turnoff_lcd

    ld hl, tiledata  ; load tile data into hl
    ld de, _VRAM     ; address in the video memory
    ld b, 32; number of bytes to copy

; loop copies 32 bytes from de into hl
.load_loop:
    ld a, [hl]
    ld [de], a
    dec b
    jr z, .end_loop
    inc hl
    inc de
    jr .load_loop
.end_loop:

    ld hl, _SCRN0
    ld de, 32*32    ; no. of tiles in bg map

.clean_bg:
    ld a, 0        ; tile 
    ld [hl], a     ; 0 out the bg map
    dec de
    ld a, d
    or e
    jp z, .end_clean_bg
    inc hl
    jp .clean_bg
.end_clean_bg

; write our tiles on the map
    ld hl, _SCRN0
    ld [hl], $01

; configure and activate the display
    ld a, LCDCF_ON|LCDCF_BG8000|LCDCF_BG9800|LCDCF_BGON|LCDCF_OBJ8|LCDCF_OBJOFF
    ld [rLCDC], a

inf_loop:
    halt
    nop
    jr inf_loop

turnoff_lcd:
    ld  a, [rLCDC]
    rlca        ; sets the high bit of LCDC in the carry flag
    ret nc

.wait_vblank:
    ld a, [rLY]
    cp 145
    jr nz, .wait_vblank

    ; we're now in vblank, so turn off LCD
    ld a, [rLCDC]
    res 7, a     ; zero out bit 7, on the LCD
    ld [rLCDC], a ; write it back
    ret

; our tile data
tiledata:
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$00,$00,$00,$00,$00,$00,$00
    DB $00,$EE,$00,$E4,$04,$E0,$0E,$E0,$0E,$40,$1E,$41,$1E,$41,$1E,$41
    DB $1C,$43,$0C,$42,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
end_tiledata:

