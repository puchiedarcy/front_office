.include "apu.inc"
.import play_beep

.include "money.inc"
.importzp money_total
.import add_money

.include "controller.inc"
.importzp controller1
.import read_controller1
.import on_press_goto

.include "double_dabble.inc"
.import double_dabble

.include "header.inc"

.include "init.inc"
.import disable_interrupt_requests
.import disable_decimal_mode
.import clear_ram

.include "parameters.inc"
.importzp p1
.importzp p2
.importzp p3
.importzp p4
.importzp a1

.include "ppu.inc"
.import oam
.import vram
.import vram_index
.import move_all_sprites_off_screen
.import wait_for_vblank
.import set_ppu_addr

.ZEROPAGE
main_has_finished_this_frame:
    .res 1, 0

.CODE
reset:
    ; Initialize stack
    ldx #$FF
    txs

    jsr disable_interrupt_requests
    jsr disable_decimal_mode
    jsr clear_ram

    ; Disable API IRQ
    ldx #%01000000
    stx APU_FRAME_COUNTER_ADDR

    inx ; Sets X register to 0
    stx PPU_CONTROLLER_ADDR ; Disable NMI
    stx PPU_MASK_ADDR ; Disable rendering
    stx APU_DMC_FLAGS_AND_RATE_ADDR ; Disable DMC IRQ

    jsr move_all_sprites_off_screen

    ; Wait for at least 2 VBlanks as PPU initializes
    bit PPU_STATUS_ADDR ; Handle VBlank flag not cleared on reset
    jsr wait_for_vblank
    jsr wait_for_vblank

    ; Clear background with empty tile FF
    lda #0
    sta a1
    lda #(PPU_ADDR_NAMETABLE_HI)
    sta a1+1
    jsr set_ppu_addr
    lda #$FF
    ldy #4
    :
        ldx #0
        :
            sta PPU_DATA_ADDR
            inx
            cpx #$F0
            bne :-
        dey
        bne :--

    ; Need to put into PPU buffer for NMI
    ; Set universal background color
    lda #PPU_ADDR_PALETTE_UNIVERSAL_BG
    sta a1
    lda #PPU_ADDR_PALETTE_HI
    sta a1+1
    jsr set_ppu_addr
    lda #PPU_COLOR_BLACK
    sta PPU_DATA_ADDR
    lda #PPU_COLOR_PINK
    sta PPU_DATA_ADDR

    ; Turn on rendering
    lda #(PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR
    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

main:
    lda main_has_finished_this_frame
    cmp #1
    beq main

    lda #BUTTON_A
    sta p1
    lda #<add_money
    sta a1
    lda #>add_money
    sta a1+1
    jsr on_press_goto

    lda #(BUTTON_A | BUTTON_B)
    sta p1
    lda #<play_beep
    sta a1
    lda #>play_beep
    sta a1+1
    jsr on_press_goto

    inc main_has_finished_this_frame
    jmp main

nmi:
    ldx #0
    ; Get Length
    lda vram,x
    sta p1
    cmp #0
    beq :++
        inx
        lda vram,x
        sta a1
        inx
        lda vram,x
        sta a1+1
        jsr set_ppu_addr

        :
        cpx p1
        beq :+
            inx
            lda vram,x
            sta PPU_DATA_ADDR
            jmp :-
:
    lda #0
    sta vram_index
    sta vram

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

    ; APU

    jsr read_controller1

    lda main_has_finished_this_frame
    cmp #0
    beq :+
        dec main_has_finished_this_frame
    :
    rti

irq:
    rti

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHR"
.incbin "front_office.chr"
