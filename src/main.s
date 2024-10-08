.include "apu.inc"
.import play_beep

.include "money.inc"
.importzp money_total
.importzp money_size
.import add_money
.import print_money

.include "controller.inc"
.importzp controller1
.import read_controller1
.import on_press_goto

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
.import vram_lock

.ZEROPAGE
main_has_finished_this_frame:
    .res 1

.CODE
reset:
    ; Initialize stack
    ldx #$FF
    txs

    jsr disable_interrupt_requests
    jsr disable_decimal_mode
    jsr clear_ram
    sta vram_index
    sta vram_lock

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

    ; Turn on rendering
    lda #(PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR
    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

    inc money_size
    jsr print_money

    lda #1
    sta vram_lock

    ; Set universal background color
    ldx vram_index
    lda #4
    sta vram,x
    inx
    lda #PPU_ADDR_PALETTE_UNIVERSAL_BG
    sta vram,x
    inx
    lda #PPU_ADDR_PALETTE_HI
    sta vram,x
    inx
    lda #PPU_COLOR_BLACK
    sta vram,x
    inx
    lda #PPU_COLOR_PINK
    sta vram,x
    inx

    stx vram_index

    lda #0
    sta vram_lock

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
    pha
    txa
    pha
    tya
    pha

    jsr add_money

    lda vram_lock
    cmp #0
    bne :++

    ldx #0
    stx vram_index
    ; Get Length
    :
    lda vram,x
    clc
    adc vram_index
    sta p1
    cmp vram_index
    beq :+++
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
        inx
        stx vram_index
        jmp :---
    :

    ldx #0
    txa
    sta vram_index
    :
    cpx p1
    beq :+
        sta vram,x
        inx
        jmp :-
    :
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
    lda #(PPU_CONTROLLER_ENABLE_NMI) ; Bits 0 and 1 set nametable for scrolling
    sta PPU_CONTROLLER_ADDR

    ; APU

    lda main_has_finished_this_frame
    cmp #0
    beq :+
        jsr read_controller1
        dec main_has_finished_this_frame
    :

    pla
    tay
    pla
    tax
    pla

    rti

irq:
    rti

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHR"
.incbin "front_office.chr"
