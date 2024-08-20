.include "test.inc"
.include "double_dabble.inc"

.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_size
.importzp dd_binary_size
.import dd_decimal_size_map

.import double_dabble

.export _main
_main:
    jsr one_binary_byte
    jsr eleven_binary_bytes
    rts

one_binary_byte:
    lda #255
    sta dd_binary

    ldx #1
    stx dd_binary_size

    dex
    lda dd_decimal_size_map,x
    sta dd_decimal_size

    jsr double_dabble

    assert dd_decimal+24, #2, #1
    assert dd_decimal+25, #5, #2
    assert dd_decimal+26, #5, #3
    rts

eleven_binary_bytes:
    lda #255
    sta dd_binary
    sta dd_binary+1
    sta dd_binary+2
    sta dd_binary+3
    sta dd_binary+4
    sta dd_binary+5
    sta dd_binary+6
    sta dd_binary+7
    sta dd_binary+8
    sta dd_binary+9
    sta dd_binary+10

    ldx #11
    stx dd_binary_size

    dex
    lda dd_decimal_size_map,x
    sta dd_decimal_size

    jsr double_dabble

    assert dd_decimal, #3, #4
    assert dd_decimal+1, #0, #5
    assert dd_decimal+2, #9, #6
    assert dd_decimal+3, #4, #7
    assert dd_decimal+4, #8, #8
    assert dd_decimal+5, #5, #9
    assert dd_decimal+6, #0, #10
    assert dd_decimal+7, #0, #11
    assert dd_decimal+8, #9, #12
    assert dd_decimal+9, #8, #13
    assert dd_decimal+10, #2, #14
    assert dd_decimal+11, #1, #15
    assert dd_decimal+12, #3, #16
    assert dd_decimal+13, #4, #17
    assert dd_decimal+14, #5, #18
    assert dd_decimal+15, #0, #19
    assert dd_decimal+16, #6, #20
    assert dd_decimal+17, #8, #21
    assert dd_decimal+18, #7, #22
    assert dd_decimal+19, #2, #23
    assert dd_decimal+20, #4, #24
    assert dd_decimal+21, #7, #25
    assert dd_decimal+22, #8, #26
    assert dd_decimal+23, #1, #27
    assert dd_decimal+24, #0, #28
    assert dd_decimal+25, #5, #29
    assert dd_decimal+26, #5, #30
    rts
