.include "test.inc"
.include "money.inc"
.importzp money_total
.import add_money

.CODE
.export _main
_main:
    jsr test_add_money
    rts

test_add_money:
    lda #0
    sta money_total

    jsr add_money

    assert money_total, #1, #1
    rts
