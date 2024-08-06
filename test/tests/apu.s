.include "../test.inc"

.include "../../lib/apu/apu.inc"
.import play_beep

.CODE
.export _main
_main:
    lda #0
    sta APU_STATUS_ADDR

    jsr play_beep

    assert APU_STATUS_ADDR, #1, #1

    rts
