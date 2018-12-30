
.include "globals.inc"
.include "vcs.inc"

.define TABLESIZE $30

.segment "ZEROPAGE"

LINEIDX: .byte 0
LINE1:   .byte 0
LINE2:   .byte 0

.segment "CODE"

p0data:
   .byte $80,$40
p1data:
   .byte $08,$10

calcbeamrider:
   ldx LINEIDX
   inx
   cpx #TABLESIZE
   bne noreset
   ldx #$00
noreset:
   stx LINEIDX
   lda bgofftab+4,x
   sec 
   sbc #$1d
   sta LINE1

   lda LINEIDX
   clc
   adc #(TABLESIZE/2)
   cmp #TABLESIZE
   bcc nooverflow
   sbc #TABLESIZE
nooverflow:
   tax
   lda bgofftab+4,x
   sec 
   sbc #$1d
   sta LINE2
   rts

beamrider:
   lda #$00
   sta COLUBK
   lda #$50
   sta COLUP0
   sta COLUP1
   sta COLUPF
   lda #$01
   sta CTRLPF
   lda #$00
   sta VDELP0
   sta VDELP1
   sta VDELBL 
   lda #$00
   sta GRP0
   lda #$00
   sta GRP1
   lda #$00
   sta PF0
   sta PF1
   sta PF2
   sta WSYNC
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   nop
   sta RESP0
   nop
   sta RESM0
   sta RESBL
   sta RESM1
   sta RESP1
   lda #$00
   sta HMP0
   lda #$00
   sta HMP1
   sta HMOVE
   lda #$20
   sta HMP0
   lda #$10
   sta HMM0
   lda #$f0
   sta HMM1
   lda #$e0
   sta HMP1

   sta WSYNC
   lda #$02
   sta ENAM0
   sta ENAM1
   sta ENABL
.if 0
   lda #$c0
   sta PF0
   lda #$ff
   sta PF1
   sta PF2
.endif
   lda #$50
   sta COLUBK
   lda p0data+1
   sta GRP0
   lda p1data+1
   sta GRP1
   
   ldx #$32
mainloop:
   ldy #$00
   cpx LINE1
   bne l1
   ldy #$50
l1:
   cpx LINE2
   bne l2
   ldy #$50
l2:
   txa
   sta WSYNC
   and #$01
   beq nomove
   sta HMOVE
nomove:
   sty COLUBK
   tay
   lda p0data,y
   sta GRP0
   lda p1data,y
   sta GRP1
   dex
   bne mainloop
   
   sta WSYNC
   lda #$00
   sta COLUPF
   sta ENAM0
   sta ENAM1
   sta ENABL
   sta GRP0
   sta GRP1
   lda #$00
   sta COLUBK
   sta PF0
   sta PF1
   sta PF2
   
   rts
