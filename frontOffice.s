NUM_PRG_ROM_IN_16KB = 2 ; Number of 16KB PRG sections
NUM_CHR_ROM_IN_8KB = 1 ; Number of 8KB CHR sections

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
APU_STATUS_ADDR = $4015
APU_FRAME_COUNTER_ADDR = $4017

COLOR_BLACK = $0F

.segment "HEADER"
.byte "NES", $1A ; iNES Header
.byte NUM_PRG_ROM_IN_16KB
.byte NUM_CHR_ROM_IN_8KB
.byte "00" ; Mapper information
.byte "00000000" ; iNES 2.0 information

.ZEROPAGE

.segment "OAM"
oam:
    .res 256 ; Dedicated space for sprites

.BSS

.CODE
reset:
    sei ; Disable interrupts
    cld ; Disable decimal mode

    ; Disable API IRQ
    ldx #%01000000
    stx APU_FRAME_COUNTER_ADDR

    ; Initialize stack
    ldx #$FF
    txs

    inx ; Sets X register to 0
    stx PPU_CONTROLLER_ADDR ; Disable NMI
    stx PPU_MASK_ADDR ; Disable rendering
    stx APU_STATUS_ADDR ; Disable APU sound
    stx APU_DMC_FLAGS_AND_RATE_ADDR ; Disable DMC IRQ

    ; Clear all RAM to 0
    txa
    : ; X=0, Loop until X overflows back to 0
        sta $0000, x
        sta $0100, x
        sta $0200, x
        sta $0300, x
        sta $0400, x
        sta $0500, x
        sta $0600, x
        sta $0700, x
        bne :- ; Branch while X!=0

    ; Place all sprites offscreen at Y=255
    lda #255
    ldx #0
    :
        sta oam, x ; Byte 0 (Y-coordinate)
        inx
        sta oam, x ; Byte 1 (tile number)
        inx ; Skip byte 2 (attributes)
        inx ; Skip byte 3 (X-coordinate)
        inx ; Align to Byte 0 of next sprite
        bne :- ; Branch while X!=0

    ; Wait for at least 2 VBlanks as PPU initializes
    bit PPU_STATUS_ADDR ; Handle VBlank flag not cleared on reset
    :
        bit PPU_STATUS_ADDR
        bpl :-
    :
        bit PPU_STATUS_ADDR
        bpl :-

    ; Clear background with empty tile FF
    lda #$20
    sta PPU_ADDR_ADDR
    lda #$00
    sta PPU_ADDR_ADDR

    lda #$FF
    ldy #4
    :
        ldx #0
        :
            sta PPU_DATA_ADDR
            inx
            bne :-
        dey
        bne :--

    ; Set universal background color
    lda #PPU_PALETTE_ADDR_HI
    sta PPU_ADDR_ADDR
    lda #$00
    sta PPU_ADDR_ADDR

    lda #COLOR_BLACK
    sta PPU_DATA_ADDR

    ; Turn on rendering
    lda #(PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR

    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

main:
    jmp main

nmi:
    ; Sprite DMA
    lda #0
    sta PPU_OAM_ADDR
    lda #>oam
    sta PPU_OAM_DMA

    ; Clean PPU write flag before setting scroll
    bit PPU_STATUS_ADDR
    lda #0
    sta PPU_SCROLL_ADDR ; Set X scroll
    sta PPU_SCROLL_ADDR ; Set Y scroll

    rti
irq:
    rti

.RODATA

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHR"
.incbin "frontOffice.chr"
