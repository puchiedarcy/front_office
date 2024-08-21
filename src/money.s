.include "money.inc"
.include "double_dabble.inc"

.ZEROPAGE
.exportzp money_total
money_total:
    .res 27
.exportzp money_size
money_size: .res 1

.CODE
.importzp dd_binary
.importzp dd_decimal
.importzp dd_decimal_start_index
.importzp dd_decimal_size
.importzp dd_binary_size

.import dd_decimal_size_map

.import vram
.import vram_index
.import vram_lock
.import double_dabble

.export add_money
add_money:
    ldy #1
    ldx #26
    sec
    :
    lda money_total,x
    adc #0
    sta money_total,x
    cmp #10
    bne :++
        lda #0
        sta money_total,x
        iny
        dex
        bpl :+
            ldx #1
            stx money_size
            ldy money_size
            jmp :+++
        :
        sec
        jmp :--
    :
    cpy money_size
    bmi :+
        sty money_size
    :

    jsr print_money
    rts

.export print_money
print_money:
    lda #1
    sta vram_lock

    ldx vram_index
    lda #3
    clc
    adc money_size
    sta vram,x
    inx
    lda #<MONEY_TOTAL_END_PPU_ADDR
    sec
    sbc money_size
    sta vram,x
    inx
    lda #>MONEY_TOTAL_END_PPU_ADDR
    sta vram,x
    inx
    lda #$0A
    sta vram,x
    inx

    lda #27
    sec
    sbc money_size
    tay
    :
        lda money_total,y
        sta vram,x
        iny
        inx
        cpy #27
        bne :-
    stx vram_index

    lda #0
    sta vram_lock

    rts
