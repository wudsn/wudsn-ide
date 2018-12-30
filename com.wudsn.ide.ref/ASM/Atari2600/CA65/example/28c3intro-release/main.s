
.include "vcs.inc"
.include "globals.inc"

.segment "ZEROPAGE"
POS    : .byte $00   ; 
ASAVE  : .byte $00   ; 
XSAVE  : .byte $00   ; 
YSAVE  : .byte $00   ; 

.segment "CODE"

reset:
   sei
   cld
   ldx #$ff
   txs
   inx
   txa
@loop:
   sta $00,x
   inx
   bne @loop

vblankstart:
   lda #$02
   sta WSYNC
   sta VBLANK
   sta WSYNC
   sta WSYNC
   sta WSYNC
   sta VSYNC
   sta WSYNC
   sta WSYNC
   lda #$29
   sta TIM64T
   lda #$00
   sta WSYNC
   sta COLUBK
   sta VSYNC
   
waitforpicturestart:
   lda #$2f
   sta TIM64T
   jsr calcscroll
   jsr calcbeamrider
@wait:
   lda INTIM
   bne @wait
   sta VBLANK
   
   ldx #$03
@loop3:
   sta WSYNC
   dex
   bne @loop3
   
   jsr logodraw
   jsr scrollerstart
   jsr beamrider
   
   ldx #$0c
@loop4:
   sta WSYNC
   dex
   bne @loop4
   
   jmp vblankstart
