.include "double_dabble.inc"

.ZEROPAGE
dd_decimal: .res 3
dd_binary: .res 1

.CODE
; Converts a binary number to its decimal form
double_dabble:
    ; Zero-out all decimal bytes
    lda #0
    .repeat 3, i
        sta dd_decimal+i
    .endrepeat

    ; For each binary bit
    .repeat 8
        clc
        rol dd_binary
        .repeat 3, i
            rol dd_decimal+2-i
        .endrepeat

        ; Process any carry values
        .repeat 2, i
            lda dd_decimal+2-i
            cmp #10
            bcc :+
                sbc #10
                sta dd_decimal+2-i
                inc dd_decimal+1-i
                :
        .endrepeat
    .endrepeat
    rts
