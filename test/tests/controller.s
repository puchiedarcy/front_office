.include "../test.inc"

.include "../../lib/controller/controller.inc"
.importzp controller1
.import controller1_this_frame
.import controller1_last_frame

.import calculate_new_button_presses
.import on_press_goto

.importzp p1
.importzp a1

.CODE
.export _main
_main:
    jsr test_calculate_new_button_presses
    jsr test_on_press_goto
    rts

test_calculate_new_button_presses:
    lda #%11110000
    sta controller1_last_frame
    lda #%00111100
    sta controller1_this_frame

    jsr calculate_new_button_presses

    assert controller1, #%00001100, #1
    rts

test_on_press_goto:
    lda #BUTTON_UP
    sta p1
    lda #<goto_label
    sta a1
    lda #>goto_label
    sta a1+1

    jsr on_press_goto

    assert , #45, #2
    rts

goto_label:
    lda #45
    rts
