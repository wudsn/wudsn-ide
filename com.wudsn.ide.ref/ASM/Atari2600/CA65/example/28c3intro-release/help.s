
.include "vcs.inc"
.segment "CODE"

cleartia:
   lda #$00
   sta NUSIZ0
   sta NUSIZ1
   sta COLUBK
   sta REFP0
   sta REFP1
   sta PF0
   sta PF1
   sta PF2
   sta GRP0
   sta GRP1
   sta ENAM0
   sta ENAM1
   sta ENABL
   sta CXCLR
   rts
