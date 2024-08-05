.macro disable_interrupt_requests
    sei
.endmacro

.macro disable_decimal_mode
    cld
.endmacro

.macro initialize_stack
    ldx #$FF
    txs
.endmacro
