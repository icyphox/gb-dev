include "gbhw.inc"

SECTION "vblank", ROM0[$0040]
    reti

SECTION "LCDC", ROM0[$0048]
    reti

SECTION "timer", ROM0[$0050]
    reti

SECTION "serial", ROM0[$0058]
    reti

SECTION "joypad", ROM0[$0060]
    reti

SECTION "entrypoint", ROM0[$0100]
    jp start

SECTION "romheader", ROM0[$0104]
    NINTENDO_LOGO
    ROM_HEADER "0123456789ABCDE"

start:
    di


.loop_until_line_144:
    ld a, [rLY]
    cp 144
    jp nz, .loop_until_line_144

.loop_until_line_145:
    ld a, [rLY]
    cp 145
    jp nz, .loop_until_line_145

    ; xor a
    ld a, [rSCY]
    inc a
    ld [rSCY], a

    jp .loop_until_line_145


