.include "header.s"
.include "ppu.s"

JOY1_ADDR = $4016

APU_PULSE1_TONE = $4000
APU_PULSE1_SWEEP = $4001
APU_PULSE1_FREQUENCY_LO = $4002
APU_PULSE1_FREQUENCY_HI = $4003

APU_A440_LO = 253

APU_DMC_FLAGS_AND_RATE_ADDR = $4010
APU_STATUS_ADDR = $4015
APU_FRAME_COUNTER_ADDR = $4017

.ZEROPAGE
joy1: .res 1
joy1_this_frame: .res 1
joy1_last_frame: .res 1

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
        inx
        bne :- ; Branch while X!=0

    move_all_sprites_off_screen

    ; Wait for at least 2 VBlanks as PPU initializes
    bit PPU_STATUS_ADDR ; Handle VBlank flag not cleared on reset
    wait_for_vblank
    wait_for_vblank

    ; Clear background with empty tile FF
    set_ppu_addr #(PPU_ADDR_NAMETABLE_HI), #0
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
    set_ppu_addr #PPU_ADDR_PALETTE_HI, #PPU_ADDR_PALETTE_UNIVERSAL_BG
    lda #PPU_COLOR_BLACK
    sta PPU_DATA_ADDR

    ; Turn on rendering
    lda #(PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR
    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

main:
    jmp main

nmi:
read_joy1:
    lda joy1_this_frame
    sta joy1_last_frame
    
    ; Strobe JOY1_ADDR to latch buttons pressed
    lda #1
    sta JOY1_ADDR
    sta joy1_this_frame
    lsr a
    sta JOY1_ADDR
    :
        lda JOY1_ADDR
        lsr a
        rol joy1_this_frame
        bcc :-
    lda joy1_last_frame
    eor #%11111111
    and joy1_this_frame
    sta joy1 ; Only new button presses this frame

    and #%10000000
    beq skipAudio

    lda #0
    sta APU_PULSE1_TONE
    lda #0
    sta APU_PULSE1_SWEEP
    lda #APU_A440_LO
    sta APU_PULSE1_FREQUENCY_LO
    lda #0
    sta APU_PULSE1_FREQUENCY_HI
    lda #1
    sta APU_STATUS_ADDR

skipAudio:
    ; Sprite DMA
    lda #0
    sta PPU_OAM_ADDR
    lda #>oam
    sta PPU_OAM_DMA

    ; Clear PPU write flag before setting scroll
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
