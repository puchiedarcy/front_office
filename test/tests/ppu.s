.include "../test.inc"

.include "../../lib/ppu/ppu.inc"
.import oam
.import move_all_sprites_off_screen
.import wait_for_vblank
.import set_ppu_addr

.importzp a1

.CODE
.export _main
_main:
    jsr test_set_ppu_addr
    jsr test_wait_for_vblank
    jsr test_move_all_sprites_off_screen
    rts

test_set_ppu_addr:
    lda #$12
    sta a1+1
    lda #$34
    sta a1

    jsr set_ppu_addr

    assert PPU_ADDR_ADDR, #$34, #1
    rts

test_wait_for_vblank:
    lda #%10000000
    sta PPU_STATUS_ADDR

    jsr wait_for_vblank

    php
    pla
    and #%10000000

    assert , #%10000000, #2
    rts

test_move_all_sprites_off_screen:

    jsr move_all_sprites_off_screen

    assert oam, #255, #3
    assert oam+1, #255, #4
    rts
