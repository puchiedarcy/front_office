.include "init.inc"

.CODE
disable_interrupt_requests:
    sei
    rts

disable_decimal_mode:
    cld
    rts

clear_ram:
    lda #0
    txa
    :
        sta $0000, x
        ; Skip $0100s (stack)
        ; Skip $0200s (sim65 _main / nes oam)
        sta $0300, x
        sta $0400, x
        sta $0500, x
        sta $0600, x
        sta $0700, x
        inx
        bne :-
    rts
