.include "money.inc"
.include "double_dabble.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.CODE
.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_start_index
.importzp dd_decimal_size
.importzp dd_binary_size

.import dd_decimal_size_map

.import vram
.import vram_index
.import double_dabble

.export add_money
add_money:
    inc money_total
    jsr print_money
    rts

.export print_money
print_money:
    ldx #1
    stx dd_binary_size

    lda money_total
    dex
    sta dd_binary,x
    lda dd_decimal_size_map,x
    sta dd_decimal_size

    jsr double_dabble

    ldx vram_index
    lda #3
    clc
    adc dd_decimal_size
    sta vram,x
    inx
    lda #<MONEY_TOTAL_END_PPU_ADDR
    sec
    sbc dd_decimal_size
    sta vram,x
    inx
    lda #>MONEY_TOTAL_END_PPU_ADDR
    sta vram,x
    inx
    lda #$0A
    sta vram,x
    inx
 
    ldy dd_decimal_start_index
    :
        lda dd_decimal,y
        sta vram,x
        iny
        inx
        cpy #27
        bne :-
    stx vram_index

    rts
