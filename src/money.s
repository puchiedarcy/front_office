.include "money.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.importzp dd_binary
.importzp dd_decimal

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
    lda dd_decimal+24
    sta vram,x
    inx
    lda dd_decimal+25
    sta vram,x
    inx
    lda dd_decimal+26
    sta vram,x
    inx
    stx vram_index

    rts
