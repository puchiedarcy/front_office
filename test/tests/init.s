.include "../test.inc"
.include "../../lib/init/init.inc"

.CODE
.export _main
_main:
    jsr test_disable_interrupt_requests
    jsr test_disable_decimal_mode
    jsr test_initialize_stack
    rts

test_disable_interrupt_requests:
    lda #0
    pha
    plp

    disable_interrupt_requests

    php
    pla
    and #4

    assert , #4, #1
    rts

test_disable_decimal_mode:
    lda #8
    pha
    plp

    disable_decimal_mode

    php
    pla
    and #8

    assert , #0, #2
    rts

test_initialize_stack:
    tsx
    stx $00
    assert_not $00, #$FF, #3

    initialize_stack

    lda $00
    tsx
    stx $00
    tax
    txs

    assert $00, #$FF, #4
    rts
