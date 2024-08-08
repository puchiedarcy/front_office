.include "lib/apu/apu.inc"
.import play_beep

.include "lib/bank/bank.inc"
.include "lib/controller/controller.inc"
.importzp controller1
.import read_controller1
.import on_press_goto

.include "lib/double_dabble/double_dabble.inc"

.include "lib/init/init.inc"
.import disable_interrupt_requests
.import disable_decimal_mode
.import clear_ram

.include "lib/parameters/parameters.inc"
.importzp p1
.importzp a1

.include "lib/ppu/ppu.inc"
.import oam
.import move_all_sprites_off_screen
.import wait_for_vblank
.import set_ppu_addr

.include "header.s"

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
    lda #1
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
            bne :-
        dey
        bne :--

    ; Set universal background color
    lda #PPU_ADDR_PALETTE_UNIVERSAL_BG
    sta a1
    lda #PPU_ADDR_PALETTE_HI
    sta a1+1
    jsr set_ppu_addr
    lda #PPU_COLOR_BLACK
    sta PPU_DATA_ADDR

    ; Turn on rendering
    lda #(PPU_MASK_RENDER_BACKGROUND)
    sta PPU_MASK_ADDR
    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

main:
    lda #0
    sta PPU_CONTROLLER_ADDR

    lda money
    sta dd_binary
    jsr double_dabble

    lda #(PPU_CONTROLLER_ENABLE_NMI)
    sta PPU_CONTROLLER_ADDR

    jmp main

nmi:
    jsr read_controller1

    lda #(BUTTON_A | BUTTON_B)
    sta p1
    lda #<play_beep
    sta a1
    lda #>play_beep
    sta a1+1
    jsr on_press_goto

    lda #BUTTON_A
    sta p1
    lda #<add_money
    sta a1
    lda #>add_money
    sta a1+1
    jsr on_press_goto

    MONEY = $235B
    lda #<MONEY
    sta a1
    lda #>MONEY
    sta a1+1
    jsr set_ppu_addr

    lda dd_decimal
    sta PPU_DATA_ADDR
    lda dd_decimal+1
    sta PPU_DATA_ADDR
    lda dd_decimal+2
    sta PPU_DATA_ADDR

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

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CHR"
.incbin "front_office.chr"
