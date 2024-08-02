.include "../../../test/test.s"
.include "../apu.inc"

.global test
test:
    lda #1
    sta expected

    jsr play_beep
    lda APU_STATUS_ADDR
    sta actual

    lda #1
    sta error_code

    jsr assert
    rts
