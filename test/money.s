.include "test.inc"
.include "money.inc"
.importzp money_total
.importzp money_size
.import add_money

.CODE
.export _main
_main:
    jsr test_add_money
    rts

test_add_money:
    lda #0
    sta money_total
    inc money_size

    jsr add_money
    jsr add_money

    assert money_total+26, #1, #1
    rts
