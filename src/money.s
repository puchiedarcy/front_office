.include "money.inc"
.include "double_dabble.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_start_index
.importzp dd_decimal_size
.importzp dd_binary_size

.CODE
.import vram
.import vram_index
.import double_dabble

.export add_money
add_money:
    inc money_total
    rts

.export print_money
print_money:
    lda money_total
    sta dd_binary

    lda #1
    sta dd_binary_size
    lda #DD_DECIMAL_NUMBER_SIZE_1
    sta dd_decimal_size

    jsr double_dabble

    ldx vram_index
    lda #2
    clc
    adc #DD_DECIMAL_NUMBER_SIZE_2
    sta vram,x
    inx
    lda #<MONEY_TOTAL_END_PPU_ADDR
    sec
    sbc #DD_DECIMAL_NUMBER_SIZE_2
    clc
    adc #1
    sta vram,x
    inx
    lda #>MONEY_TOTAL_END_PPU_ADDR
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
