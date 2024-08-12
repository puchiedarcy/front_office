.include "money.inc"

.ZEROPAGE
.exportzp money_total
money_total: .res 1

.CODE
.export add_money
add_money:
    inc money_total
    rts
