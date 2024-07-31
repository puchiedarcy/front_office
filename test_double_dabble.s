.export _main
.include "double_dabble.s"

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
    sta binary
    
    double_dabble

    assert decimal, #2, #1
    assert decimal+1, #5, #2
    assert decimal+2, #5, #3

    lda #0
    rts
