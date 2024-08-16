.include "double_dabble.inc"

.ZEROPAGE
.importzp p1
.importzp p4

.exportzp dd_decimal
dd_decimal: .res 27
.exportzp dd_binary
dd_binary: .res 11
.exportzp dd_decimal_size
dd_decimal_size: .res 1
.exportzp dd_binary_size
dd_binary_size: .res 1
.exportzp dd_decimal_start_index
dd_decimal_start_index: .res 1

.CODE
; Converts a binary number to its decimal form
.export double_dabble
double_dabble:
    lda #27
    sec
    sbc dd_decimal_size
    sta dd_decimal_start_index

    ; Zero-out all decimal bytes
    lda #0
    ldx dd_decimal_start_index
    :
        sta dd_decimal,x
        inx
        cpx #27
    bne :-

    ; For each binary bit
    lda dd_binary_size
    clc
    adc dd_binary_size
    adc dd_binary_size
    adc dd_binary_size
    adc dd_binary_size
    adc dd_binary_size
    adc dd_binary_size
    adc dd_binary_size
    tay

    :
    clc
    ldx dd_binary_size
    dex
    :
        rol dd_binary,x
        php
        dex
        cpx #$FF
        bne :-
    ldx #26
    :
        plp
        rol dd_decimal,x
        php
        dex
        cpx dd_decimal_start_index
    bne :-
    plp
    rol dd_decimal,x

    ;Process carry values
    ldx #26
    :
        lda dd_decimal,x
        cmp #10
        bcc :+
            sbc #10
            sta dd_decimal,x
            dex
            inc dd_decimal,x
            inx
        :
        dex
        cpx dd_decimal_start_index
    bne :--

    dey
    cpy #0
    bne :-----
    rts
