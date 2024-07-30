.include "apu.s"
.include "controller.s"
.include "header.s"
.include "ppu.s"

.ZEROPAGE

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
    read_controller1

    on_press_goto BUTTON_A | BUTTON_B, play_beep

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
