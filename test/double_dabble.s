.include "test.inc"
.include "double_dabble.inc"
.import double_dabble

.importzp p1
.importzp p4

.export _main
_main:
    lda #255
    sta p4

    jsr double_dabble

    assert p1, #2, #1
    assert p1+1, #5, #2
    assert p1+2, #5, #3
    rts
