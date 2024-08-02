.include "double_dabble.inc"

.export _main

.macro assert expected, actual, code
    lda expected
    cmp actual
    beq :+
        lda code
        rts
    :
.endmacro

.CODE
_main:
    lda #255
    sta dd_binary
    
    jsr double_dabble

    assert dd_decimal, #2, #1
    assert dd_decimal+1, #5, #2
    assert dd_decimal+2, #5, #3

    lda #0
    rts
