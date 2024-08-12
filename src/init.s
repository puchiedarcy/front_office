.include "init.inc"

.CODE
.export disable_interrupt_requests
disable_interrupt_requests:
    sei
    rts

.export disable_decimal_mode
disable_decimal_mode:
    cld
    rts

.export clear_ram
clear_ram:
    lda #0
    tax
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
