.ZEROPAGE
decimal: .res 3
binary: .res 1

; Converts a binary number to its decimal form
.macro double_dabble
    ; Zero-out all decimal bytes
    lda #0
    .repeat 3, i
        sta decimal+i
    .endrepeat

    ; For each binary bit
    .repeat 8
        clc
        rol binary
        .repeat 3, i
            rol decimal+2-i
        .endrepeat

        ; Process any carry values
        .repeat 2, i
            lda decimal+2-i
            cmp #10
            bcc :+
                sbc #10
                sta decimal+2-i
                inc decimal+1-i
                :
        .endrepeat
    .endrepeat
.endmacro
