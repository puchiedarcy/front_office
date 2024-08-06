.include "../test.inc"
.import disable_interrupt_requests
.import disable_decimal_mode
.import clear_ram


.CODE
.export _main
_main:
    jsr test_disable_interrupt_requests
    jsr test_disable_decimal_mode
    jsr clear_ram
    rts

test_disable_interrupt_requests:
    lda #0
    pha
    plp

    jsr disable_interrupt_requests

    php
    pla
    and #4

    assert , #4, #1
    rts

test_disable_decimal_mode:
    lda #8
    pha
    plp

    jsr disable_decimal_mode

    php
    pla
    and #8

    assert , #0, #2
    rts

test_clear_ram:
    lda #45
    sta $0444

    jsr clear_ram

    assert $0444, #0, #5
    rts
