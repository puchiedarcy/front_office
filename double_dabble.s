.ZEROPAGE
decimal: .res 3
binary: .res 1

.macro double_dabble
    lda #0
    sta decimal+2
    sta decimal+1
    sta decimal

.repeat 8
    clc
    rol binary
    rol decimal+2
    rol decimal+1
    rol decimal

    lda decimal+2
    cmp #10
    bcc :+
        sbc #10
        sta decimal+2
        inc decimal+1
    :

    lda decimal+1
    cmp #10
    bcc :+
        sbc #10
        sta decimal+1
        inc decimal
    :
.endrepeat
.endmacro
