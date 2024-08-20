.include "double_dabble.inc"

.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_size
.importzp dd_binary_size

.import dd_decimal_size_map

.import double_dabble

.export _main
_main:
    ldx #NUM_BINARY_BYTES
    stx dd_binary_size

    dex
    lda dd_decimal_size_map,x
    sta dd_decimal_size
 
    jsr double_dabble
    
    lda #0
    rts
