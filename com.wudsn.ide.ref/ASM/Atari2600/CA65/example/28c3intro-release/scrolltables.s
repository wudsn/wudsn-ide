
.include "globals.inc"

.segment "RODATA"

colortab1: ; colors of scrollline
   .byte $60,$64,$68,$6c,$6e,$6a,$66,$62

colortab2: ; colors of scroller background
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $d0,$d2,$d4,$d6,$d8,$da,$dc,$de
   .byte $de,$dc,$da,$d8,$d6,$d4,$d2,$d0
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   .byte $00,$00,$00,$00,$00,$00,$00,$00
   
bgofftab: ; sinus tab for scroller background
   .byte $4f,$4f,$4f,$4f,$4f,$4f,$4f,$4e
   .byte $4e,$4e,$4d,$4d,$4c,$4b,$4b,$4a
   .byte $49,$49,$48,$47,$46,$45,$44,$43
   .byte $42,$41,$40,$3f,$3d,$3c,$3b,$39
   .byte $38,$37,$35,$34,$32,$31,$2f,$2e
   .byte $2c,$2a,$29,$27,$25,$23,$22,$20
   .byte $1e,$1c,$1a,$19,$17,$15,$13,$11
   .byte $0f,$0d,$0b,$09,$07,$05,$03,$01

powlist:
   .byte $80,$40,$20,$10,$08,$04,$02,$01

text:
   .byte "The Atari 2600 Video Computer System: The Ultimate Talk * "
   .byte "The History, the hardware and how to write programs * "
   .byte "by Sven Oliver ('SvOlli') Moll * 28c3 - Behind enemy lines - 2011-12-27 - 12:45 - Saal 3 * ", 0
