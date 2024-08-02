.include "bank.inc"
.ZEROPAGE
money: .res 1

.CODE
add_money:
    inc money
    rts
