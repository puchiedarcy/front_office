.include "../test.inc"

.include "../../lib/controller/controller.inc"
.importzp controller1
.import controller1_this_frame
.import controller1_last_frame
.import read_controller1
.import calculate_new_button_presses

.CODE
.export _main
_main:
    lda #%11110000
    sta controller1_last_frame
    lda #%00111100
    sta controller1_this_frame

    jsr calculate_new_button_presses

    assert controller1, #%00001100, #1

    rts
