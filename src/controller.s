.include "controller.inc"

.importzp p1
.importzp a1

.ZEROPAGE
.exportzp controller1
controller1: .res 1

.BSS
.export controller1_this_frame
controller1_this_frame: .res 1
.export controller1_last_frame
controller1_last_frame: .res 1

.CODE
.export read_controller1
read_controller1:
    ; Move last frame's inputs
    lda controller1_this_frame
    sta controller1_last_frame

    ; Strobe CONTROLLER1_ADDR to latch buttons held
    lda #1
    sta CONTROLLER1_ADDR

    ; Sets up ring counter for counting 8 bits of input
    sta controller1_this_frame
    lsr a

    ; Poll 0 to CONTROLLER1_ADDR to finish latching
    sta CONTROLLER1_ADDR
    :
        lda CONTROLLER1_ADDR

        ; Bit 0 has button press status
        ; Shift that status into Carry flag
        lsr a

        ; Roll the Carry flag into this frame's held buttons
        rol controller1_this_frame
        bcc :-

.export calculate_new_button_presses
calculate_new_button_presses:
    lda controller1_last_frame
    eor #%11111111
    and controller1_this_frame
    sta controller1
    rts

.export on_press_goto
on_press_goto:
    lda p1
    and controller1
    beq :+
        jmp (a1)
    :
    rts
