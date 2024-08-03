.macro assert expected, actual, error_code
    lda expected
    cmp actual
    beq :+
        lda error_code
        rts
    :
    lda #0
.endmacro
