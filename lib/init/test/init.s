.include "../../../test/test.inc"
.include "../init.inc"

.export test
test:
    lda #4
    sta expected

    disable_interrupt_requests

    php
    pla
    sta actual

    lda #1
    sta error_code

    jsr assert

