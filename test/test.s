.export _main
.include "test.inc"

.ZEROPAGE
expected: .res 1
actual: .res 1
error_code: .res 1

.CODE
assert:
    lda expected
    cmp actual
    beq :+
        lda error_code
        rts
    :
    lda #0
    rts

_main:
    jmp test
    rts
