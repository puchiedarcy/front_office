.include "apu.inc"
play_beep:
    lda #0
    sta APU_PULSE1_TONE
    lda #0
    sta APU_PULSE1_SWEEP
    lda #APU_A440_LO
    sta APU_PULSE1_FREQUENCY_LO
    lda #0
    sta APU_PULSE1_FREQUENCY_HI
    lda #1
    sta APU_STATUS_ADDR
    rts
