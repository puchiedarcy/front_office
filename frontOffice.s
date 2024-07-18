SIZE_PRG_ROM_IN_16KB = 2 ; Number of 16KB PRG sections.
SIZE_CHR_ROM_IN_8KB = 1 ; Number of 8KB CHR sections.
MAPPER_LO = 0 ; Mapper id, mirroring, and battery.
MAPPER_HI = 0 ; Mapper id, indicate alternate platforms.

PPU_CONTROLLER_ADDR = $2000
PPU_MASK_ADDR = $2001
PPU_STATUS_ADDR = $2002
PPU_OAM_ADDR = $2003
PPU_SCROLL_ADDR = $2005
PPU_ADDR_ADDR = $2006
PPU_DATA_ADDR = $2007
PPU_OAM_DMA = $4014

PPU_CONTROLLER_ENABLE_NMI = %10000000

PPU_MASK_RENDER_SPRITES = %00010000
PPU_MASK_RENDER_BACKGROUND = %00001000

PPU_PALETTE_ADDR_HI = $3F

APU_DMC_FLAGS_AND_RATE_ADDR = $4010
API_STATUS_ADDR = $4015
APU_FRAME_COUNTER_ADDR = $4017

COLOR_BLACK = $0F
COLOR_BLUE = $22
COLOR_PINK = $25

.segment "INESHDR"
.byte "NES", $1A ; iNES Header
.byte SIZE_PRG_ROM_IN_16KB
.byte SIZE_CHR_ROM_IN_8KB
.byte MAPPER_LO
.byte MAPPER_HI
.byte "PUCHIE_D"

.ZEROPAGE
tick: .res 1

.segment "OAM"
oam:
    .res 256 ; Dedicated space for sprites.

.BSS
sprite1XPos: .res 1

.CODE
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

    lda #PPU_CONTROLLER_ENABLE_NMI 
    sta PPU_CONTROLLER_ADDR ; Enable NMIs.

    lda #(PPU_MASK_RENDER_SPRITES | PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR ; Enable rendering.

    ; Set palette.
    lda #PPU_PALETTE_ADDR_HI 
    sta PPU_ADDR_ADDR
    lda #$00 ; Background palette 0.
    sta PPU_ADDR_ADDR

    lda #COLOR_BLACK
    sta PPU_DATA_ADDR

    lda #COLOR_PINK
    sta PPU_DATA_ADDR

    lda #PPU_PALETTE_ADDR_HI
    sta PPU_ADDR_ADDR
    lda #$15 ; Sprite palette 1.
    sta PPU_ADDR_ADDR

    lda sprite1Color
    STA PPU_DATA_ADDR

    ; Draw sprite 0.
    lda #$45
    sta oam ; Sprite 0 y-position.
    sta oam + 3 ; Sprite 0 x-position.
    lda #$01
    sta oam + 1 ; Sprite tile.
    sta oam + 2 ; Sprte palette. 
main:
    inc tick
    jmp main

nmi:
    ldx sprite1XPos
    stx oam + 3
    inx
    stx sprite1XPos

    ; Sprite OAM DMA.
    lda #0
    sta PPU_OAM_ADDR
    lda #>oam
    sta PPU_OAM_DMA

    ; Set scroll.
    stx PPU_SCROLL_ADDR ; x-scroll
    stx PPU_SCROLL_ADDR ; y-scroll

    rti
irq:
    rti

.RODATA
sprite1Color:
.byte COLOR_BLUE

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHR"
.incbin "frontOffice.chr"
