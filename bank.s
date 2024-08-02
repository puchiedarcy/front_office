MONEY = $235B

.ZEROPAGE
money: .res 1

.macro print_money
    set_ppu_addr #>MONEY, #<MONEY
    lda dd_decimal
    sta PPU_DATA_ADDR
    lda dd_decimal+1
    sta PPU_DATA_ADDR
    lda dd_decimal+2
    sta PPU_DATA_ADDR
.endmacro

.macro add_money
    inc money
.endmacro
