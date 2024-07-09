SIZE_PRG_ROM_IN_16KB = 2 ; Number of 16KB PRG sections.
SIZE_CHR_ROM_IN_8KB = 1 ; Number of 8KB CHR sections.
MAPPER_LO = 0 ; Mapper id, mirroring, and battery.
MAPPER_HI = 0 ; Mapper id, indicate alternate platforms.

PPU_CONTROLLER_ADDR = $2000
PPU_MASK_ADDR = $2001
PPU_STATUS_ADDR = $2002
PPU_SCROLL_ADDR = $2005
PPU_ADDR_ADDR = $2006
PPU_DATA_ADDR = $2007

PPU_PALETTE_ADDR_HI = $3F

APU_DMC_FLAGS_AND_RATE_ADDR = $4010
API_STATUS_ADDR = $4015
APU_FRAME_COUNTER_ADDR = $4017

COLOR_BLACK = $0F
COLOR_PINK = $25

.segment "HEADER"
.byte "NES", $1A ; iNES Header
.byte SIZE_PRG_ROM_IN_16KB
.byte SIZE_CHR_ROM_IN_8KB
.byte MAPPER_LO
.byte MAPPER_HI
.byte "PUCHIE_D"

.segment "STARTUP"
reset:
    sei ; Disable interrupts.
    cld ; Disable decimal mode.

    ldx #%01000000
    stx APU_FRAME_COUNTER_ADDR ; Disable API IRQ.

    ldx #$FF
    txs ; Initialize stack pointer to grow down from $01FF.

    inx ; Sets X register to 0.
    stx PPU_CONTROLLER_ADDR ; Disable NMI
    stx PPU_MASK_ADDR ; Disable rendering.
    stx API_STATUS_ADDR ; Disable APU sound.
    stx APU_DMC_FLAGS_AND_RATE_ADDR ; Disable DMC IRQ.

    bit PPU_STATUS_ADDR ; Clear VBlank across reset.

    : ; Wait for VBLank 1 as PPU initializes.
        bit PPU_STATUS_ADDR ; Bit 7 copied to N.
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
        bit PPU_STATUS_ADDR
        bpl :-

    lda #%10000000
    sta PPU_CONTROLLER_ADDR ; Enable NMIs.

    lda #%00001010
    sta PPU_MASK_ADDR ; Enable rendering.

    ; Set palette.
    lda #PPU_PALETTE_ADDR_HI 
    sta PPU_ADDR_ADDR
    lda #$00
    sta PPU_ADDR_ADDR

    lda #COLOR_BLACK
    sta PPU_DATA_ADDR

    lda #COLOR_PINK
    sta PPU_DATA_ADDR

main:
    jmp main

nmi:
    inx
    stx $00

    ; Set scroll.
    stx PPU_SCROLL_ADDR ; x-scroll
    stx PPU_SCROLL_ADDR ; y-scroll

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
