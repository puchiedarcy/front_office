.include "test.inc"
.include "double_dabble.inc"

.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_size
.importzp dd_binary_size

.import double_dabble

.export _main
_main:
    lda #255
    sta dd_binary
    lda #1
    sta dd_binary_size
    lda #DD_DECIMAL_NUMBER_SIZE_1
    sta dd_decimal_size

    jsr double_dabble

    assert dd_decimal+24, #2, #1
    assert dd_decimal+25, #5, #2
    assert dd_decimal+26, #5, #3
    rts
