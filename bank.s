MONEY = $235D

.ZEROPAGE
money: .res 1

.macro print_money
    set_ppu_addr #>MONEY, #<MONEY
    lda money
    sta PPU_DATA_ADDR
.endmacro

.macro add_money
    inc money
.endmacro
