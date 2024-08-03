.include "../test.inc"
.include "../../lib/apu/apu.inc"

.export _main
_main:
    jsr play_beep

    assert APU_STATUS_ADDR, #1, #1

    rts
