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
.global controller1

.CODE
.global read_controller1

.macro on_press_goto buttons, label
    lda controller1
    and #buttons
    beq :+
        jsr label
    :    
.endmacro