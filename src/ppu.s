.include "ppu.inc"

.importzp a1

.segment "VRAM"
.export vram
vram:
    .res 127

.export vram_index
vram_index:
    .res 1, 0

.segment "OAM"
.export oam
oam:
    .res 256 ; Dedicated space for sprites

.CODE
.export move_all_sprites_off_screen
move_all_sprites_off_screen:
    lda #255 ; Off-screen and empty tile value.
    ldx #0
    :
        sta oam, x ; Byte 0 (Y-coordinate)
        inx
        sta oam, x ; Byte 1 (tile number)
        inx ; Skip byte 2 (attributes)
        inx ; Skip byte 3 (X-coordinate)
        inx ; Align to Byte 0 of next sprite
        bne :- ; Branch while X!=0
    rts

.export wait_for_vblank
wait_for_vblank:
    :
        bit PPU_STATUS_ADDR
        bpl :-
    rts

.export set_ppu_addr
set_ppu_addr:
    bit PPU_STATUS_ADDR

    lda a1+1
    sta PPU_ADDR_ADDR
    lda a1
    sta PPU_ADDR_ADDR
    rts
