.include "money.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.importzp p1
.importzp p2
.importzp p3
.importzp p4

.CODE
.import vram
.import vram_index
.import double_dabble

.export add_money
add_money:
    inc money_total

    lda money_total
    sta p4
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
    lda p1
    sta vram,x
    inx
    lda p2
    sta vram,x
    inx
    lda p3
    sta vram,x
    inx
    stx vram_index

    rts
