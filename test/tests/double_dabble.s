.include "../test.inc"
.include "../../lib/double_dabble/double_dabble.inc"

.export _main
_main:
    lda #255
    sta dd_binary

    jsr double_dabble

    assert dd_decimal, #2, #1
    assert dd_decimal+1, #5, #2
    assert dd_decimal+2, #5, #3

    rts
