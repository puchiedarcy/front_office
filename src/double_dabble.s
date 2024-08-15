.include "double_dabble.inc"

.importzp p1
.importzp p4

.CODE
; Converts a binary number to its decimal form
.export double_dabble
double_dabble:
    ; Zero-out all decimal bytes
    lda #0
    .repeat 3, i
        sta p1+i
    .endrepeat

    ; For each binary bit
    .repeat 8
        clc
        rol p4
        .repeat 3, i
            rol p1+2-i
        .endrepeat

        ; Process any carry values
        .repeat 2, i
            lda p1+2-i
            cmp #10
            bcc :+
                sbc #10
                sta p1+2-i
                inc p1+1-i
                :
        .endrepeat
    .endrepeat
    rts
