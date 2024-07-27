PPU_CONTROLLER_ADDR = $2000
PPU_CONTROLLER_ENABLE_NMI = %10000000

PPU_MASK_ADDR = $2001
PPU_MASK_RENDER_SPRITES = %00010000
PPU_MASK_RENDER_BACKGROUND = %00001000

PPU_STATUS_ADDR = $2002
PPU_OAM_ADDR = $2003
PPU_SCROLL_ADDR = $2005

PPU_ADDR_ADDR = $2006
PPU_ADDR_NAMETABLE_HI = $20
PPU_ADDR_PALETTE_HI = $3F
PPU_ADDR_PALETTE_UNIVERSAL_BG = $00

PPU_DATA_ADDR = $2007
PPU_OAM_DMA = $4014

PPU_COLOR_BLACK = $0F

.segment "OAM"
oam:
    .res 256 ; Dedicated space for sprites

.macro move_all_sprites_off_screen
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
.endmacro

.macro wait_for_vblank
    :
        bit PPU_STATUS_ADDR
        bpl :-
.endmacro

.macro set_ppu_addr hi, lo
    lda PPU_STATUS_ADDR

    lda hi
    sta PPU_ADDR_ADDR
    lda lo
    sta PPU_ADDR_ADDR
.endmacro
