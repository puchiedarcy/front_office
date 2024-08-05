.macro assert actual, expected, error_code
    .ifnblank actual
        lda actual
    .endif
    cmp expected
    beq :+
        lda error_code
        rts
    :
    lda #0
.endmacro

.macro assert_not actual, expected, error_code
    .ifnblank actual
        lda actual
    .endif
    cmp expected
    bne :+
        lda error_code
        rts
    :
    lda #0
.endmacro
