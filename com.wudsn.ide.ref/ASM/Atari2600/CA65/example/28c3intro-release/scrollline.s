
.include "globals.inc"
.include "vcs.inc"

.segment "ZEROPAGE"

.define SCROLLDELAY 1

VFBBASE: ; persistent: framebuffer
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00
   
DELAY  : .byte $00   ; persistent: delay for next call to move
TXTOFF : .byte $00   ; persistent: index for next char in text buffer
CURCHAR: .word $0000 ; 
CHARX  : .byte $00   ; persistant: charset: x position
CHARY  : .byte $00   ; persistant: charset: x position
BGIDX  : .byte $00   ; 
BORDER : .byte $00   ; persistant: gfxdata for "fade effect"

.macro noscrollline
.local @line
   ldy #$07
@line:
   sta WSYNC
   lda colortab2,x
   sta COLUBK
   lda #$00
   sta COLUPF
   sta PF0
   sta PF1
   sta PF2
   lda BORDER
   eor #$ff
   sta BORDER
   sta GRP0
   sta GRP1
   inx
   dey
   bpl @line
.endmacro

.macro scrollline vfbstart
.local @line
   ldy #$07
@line:
   sta WSYNC
   
   lda colortab1,y
   sta COLUPF
   lda colortab2,x
   sta COLUBK
   
   lda vfbstart+0
   sta PF0
   lda vfbstart+1
   sta PF1
   lda vfbstart+2
   sta PF2

   lda vfbstart+3
   sta PF0
   lda vfbstart+4
   sta PF1
   lda vfbstart+5
   sta PF2
   
   lda BORDER
   eor #$ff
   sta BORDER
   sta GRP0
   sta GRP1
   
   inx
   dey
   bpl @line
.endmacro


.segment "CODE"

   
scrollerstart:
   lda #$00
   sta COLUP0
   sta COLUP1
   sta CTRLPF
   sta WSYNC
   lda #$30
   sta HMP0
   lda #$10
   sta HMP1
   sta RESP0
   ldx #$0b
@loop:
   dex
   bne @loop
   sta RESP1
   sta WSYNC
   sta HMOVE
   
   lda #$00
   sta COLUBK

   inc BGIDX
   inc BGIDX
   
   lda BGIDX
   bpl @noreverse
   eor #$ff
@noreverse:
   lsr
   tax
   lda bgofftab,x
   tax
   
   lda #$55
   sta BORDER
   sta GRP0

   noscrollline
   noscrollline
   scrollline VFBBASE+ 0
   scrollline VFBBASE+ 6
   scrollline VFBBASE+12
   scrollline VFBBASE+18
   scrollline VFBBASE+24
   scrollline VFBBASE+30
   scrollline VFBBASE+36
   scrollline VFBBASE+42
   noscrollline
   noscrollline

   sta WSYNC
   lda #$00
   sta PF0
   sta PF1
   sta PF2
   sta GRP0
   sta GRP1
   
   rts

calcscrollwait:
.if SHOWTIMING
   lda #$c0
   sta COLUBK
.endif
   lda #$0f
   sta TIM64T
   jsr calcscroll
@wait:
   lda INTIM
   bne @wait
   rts

calcscroll:
   dec DELAY
   bpl noscroll
   lda #SCROLLDELAY
   sta DELAY
scroll:
   ldx #$00
   jsr getnextbit
   ; carry contains "new bit to draw"
   ror VFBBASE+5,x
   rol VFBBASE+4,x
   ror VFBBASE+3,x
   lda VFBBASE+3,x
   and #$08
   cmp #$08
   ror VFBBASE+2,x
   rol VFBBASE+1,x
   ror VFBBASE+0,x
   txa
   clc
   adc #$06
   tax
   cpx #$30
   bne scroll+2
noscroll:
   rts

getnextbit:
; set counters for next step
   dec CHARY
   bpl ok
   lda #$07
   sta CHARY
   dec CHARX
   bpl ok
   lda #$07
   sta CHARX
; TODO: set textpointer
   ldx TXTOFF
rereadtxt:
   lda text,x
   bne notextend
   ldx #$00
   beq rereadtxt
notextend:
   inx
   stx TXTOFF
   and #$7f ; unneccessary
   sec
   sbc #$20
   ldx #$00
   stx CURCHAR+1
   asl
   rol CURCHAR+1
   rol
   rol CURCHAR+1
   rol
   rol CURCHAR+1
   sta CURCHAR
   clc
   lda #<charset
   adc CURCHAR
   sta CURCHAR
   lda #>charset
   adc CURCHAR+1
   sta CURCHAR+1
ok:
   ldy CHARX
   lda (CURCHAR),y
   ldy CHARY
   and powlist,y
   cmp powlist,y
   rts
