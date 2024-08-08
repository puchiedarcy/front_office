.include "../test.inc"

.include "../../lib/ppu/ppu.inc"
.import move_all_sprites_off_screen
.import wait_for_vblank
.import set_ppu_addr

.import a1

.CODE
.export _main
_main:
    lda #0
    rts

