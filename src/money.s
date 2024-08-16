.include "money.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_start_index

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
    jsr double_dabble

    ldx vram_index
    lda #5
    sta vram,x
    inx
    lda #<MONEY_TOTAL_END_PPU_ADDR-2
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
