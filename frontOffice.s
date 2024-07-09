.segment "HEADER"
.byte "NES", $1A ; iNES Header
.byte 2 ; Number of 16KB PRG. Represents CPU spaces $8000-$BFFF and $C0000-$FFFF.
.byte 1 ; Number of 8KB CHR. Represents PPU space $0000-$1FFF.
.byte 0, 0 ; Mapper information.
.byte "PUCHIE_D" ; Unused.

.segment "STARTUP"
reset:
    sei ; Disable interrupts.
    cld ; Disable decimal mode.

    ldx #%01000000
    stx $4017 ; Disable API IRQ.

    ldx #$FF
    txs ; Initialize stack pointer to grow down from $01FF.

    inx ; Sets X register to 0.
    stx $2000 ; Disable NMI.
    stx $2001 ; Disable rendering.
    stx $4015 ; Disable APU sound.
    stx $4010 ; Disable DMC IRQ.

    bit $2002 ; Clear VBlank across reset.

    : ; Wait for VBLank 1 as PPU initializes.
        bit $2002 ; Bit 7 copied to N.
        bpl :- ; Branch on N=0. Thus, loop until N=1 meaning VBlank happened.

    ; In the meantime...
    ; Clear all RAM to 0.
    txa
    : ; X=0. Loop until X overflows back to 0.
        sta $0000, x
        sta $0100, x
        sta $0200, x
        sta $0300, x
        sta $0400, x
        sta $0500, x
        sta $0600, x
        sta $0700, x
        inx
    bne :- ; Branch while X!=0.

    ; Place all sprites offscreen at Y=255.
    lda #255
    ldx #0
    :
        sta oam, x ; Byte 0 of OAM is Y coordinate.
        inx ; Skip byte 1, tile number.
        inx ; Skip byte 2, attributes.
        inx ; Skip byte 3, X coordinate.
        inx ; Aligned to Byte 0 of next sprite.
    bne :- ; Branch while X!=0.

    : ; Wait for VBLank 2 as PPU initialization finalizes.
        bit $2002
        bpl :-

    lda #%10000000
    sta $2000 ; Enable NMIs.

    lda #%00001010
    sta $2001 ; Enable rendering.

    ; Set palette.
    lda #$3F
    sta $2006
    lda #$00
    sta $2006

    lda #$0F
    sta $2007
    lda #$25
    sta $2007

main:
    jmp main

nmi:
    inx
    stx $0000

    ; Set scroll.
    stx $2005 ; x-scroll
    stx $2005 ; y-scroll

    lda #%10000000
    sta $2000

    rti
irq:
    rti

oam:
    .res 256 ; Dedicated space for sprites.

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHARS"
.incbin "frontOffice.chr"
