
.include "globals.inc"
.include "vcs.inc"

.segment "ZEROPAGE"

SCRSAVE: .byte $00   ;

.macro _bytes_space_8
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_T
.byte %11111111
.byte %11111111
.byte %10011001
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_H
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11111111
.byte %11111111
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_E
.byte %11111111
.byte %11111111
.byte %11000001
.byte %11000000
.byte %11111100
.byte %11111100
.byte %11000000
.byte %11000001
.byte %11111111
.byte %11111111
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_U
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11100111
.byte %11111111
.byte %01111110
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_L
.byte %11000000
.byte %11000000
.byte %11000000
.byte %11000000
.byte %11000000
.byte %11000000
.byte %11000000
.byte %11000001
.byte %11111111
.byte %11111111
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_I
.byte %00111100
.byte %00111100
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00011000
.byte %00111100
.byte %00111100
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_M
.byte %11000011
.byte %11100111
.byte %11111111
.byte %11111111
.byte %11011011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_A
.byte %00111100
.byte %01111110
.byte %11100111
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11111111
.byte %11111111
.byte %11000011
.byte %11000011
.byte %11000011
.byte %11000011
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.macro _bytes_K
.byte %11000011
.byte %11000111
.byte %11001110
.byte %11011100
.byte %11111000
.byte %11111000
.byte %11011100
.byte %11001110
.byte %11000111
.byte %11000011
.byte %00000000
.byte %00000000
.byte %00000000
.endmacro

.segment "RODATA"

logoscrolldata:
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
.byte %00000000
_bytes_T
_bytes_H
_bytes_E
_bytes_space_8
_bytes_U
_bytes_L
_bytes_T
_bytes_I
_bytes_M
_bytes_A
_bytes_T
_bytes_E
_bytes_space_8
_bytes_T
_bytes_A
_bytes_L
_bytes_K
scrolldataend:

.segment "CODE"

logodraw:
   lda #$02
   sta CTRLPF
   lda #$00
   sta COLUBK
   lda #$20
   sta COLUP1
   inc SCRSAVE
   ldy SCRSAVE
   lda #$f0
   sta HMP0
   ldx #$5f
   sta RESP0
   
logoloop:
   lda logoscrolldata,y
   sta GRP0
   txa
;   cmp #$07
   and #$07
   sta WSYNC
   bne @skip1
   sta HMOVE
@skip1:
   adc #$21
   sta COLUP0
   lda Logo_PF0,x
   sta PF0
   lda Logo_PF1,x
   sta PF1
   lda Logo_PF2,x
   sta PF2
   lda Logo_PF3,x
   sta PF0
   lda Logo_PF4,x
   sta PF1
   lda Logo_PF5,x
   sta PF2
   iny
   dex
   bpl logoloop

   lda #$00
   sta COLUPF
   sta COLUBK
   rts
   