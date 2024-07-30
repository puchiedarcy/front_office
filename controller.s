CONTROLLER1_ADDR= $4016

BUTTON_A = %10000000
BUTTON_B = %01000000
BUTTON_SELECT = %00100000
BUTTON_START = %00010000
BUTTON_UP = %00001000
BUTTON_DOWN = %00000100
BUTTON_LEFT = %00000010
BUTTON_RIGHT = %00000001

.ZEROPAGE
controller1: .res 1
controller1_this_frame: .res 1
controller1_last_frame: .res 1

.macro read_controller1
    lda controller1_this_frame
    sta controller1_last_frame
    
    ; Strobe CONTROLLER1_ADDR to latch buttons pressed
    lda #1
    sta CONTROLLER1_ADDR
    sta controller1_this_frame
    lsr a
    sta CONTROLLER1_ADDR
    :
        lda CONTROLLER1_ADDR
        lsr a
        rol controller1_this_frame
        bcc :-
    lda controller1_last_frame
    eor #%11111111
    and controller1_this_frame
    sta controller1 ; Only new button presses this frame
.endmacro

.macro on_press_goto btn, label
    lda controller1
    and #btn
    beq :+

    label
:    
.endmacro
