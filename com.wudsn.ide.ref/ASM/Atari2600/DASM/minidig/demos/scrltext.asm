; Eckhard Stolberg's Scrolling Text Demo

                processor       6502
                include         vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Zeropage variables declaration
;
                SEG.U   Variables
                ORG     $80
LoopCount       ds      1
Temp            ds      1
Sprite1         ds      7
Sprite2         ds      7
Sprite3         ds      7
Sprite4         ds      7
Sprite5         ds      7
Sprite6         ds      7
ShiftCount      ds      1
Sprite7         ds      7
TextPTR         ds      2
CharPTR         ds      2
ColourCycle     ds      1
TempColour      ds      1
SkipFrame       ds      1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
                SEG     Code
                ORG     $f000
                include scrlfont.h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Program initialization
;

Cart_Init:
                sei
                cld                     

                ldx     #$00
                txa
AllClear:
                sta     $00,x
                dex
                bne     AllClear
                txs

DemoInit:
                sta     WSYNC
                pha
                lda     #$f1
                sta     HMP1
                sta     CTRLPF
                lda     #$0a
                sta     COLUP0
                sta     COLUP1
                lda     #$e3
                sta     HMP0
                sta     NUSIZ0
                sta     NUSIZ1
                sta     VDELP0
                sta     VDELP1
                sta     RESP0
                sta     RESP1
                sta     WSYNC
                sta     HMOVE
                jsr     ResetTextPTR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Main program loop
;
NewFrame:
                ldx     #$02
                sta     WSYNC           
                stx     VSYNC           
                sta     WSYNC           
                sta     WSYNC
                sta     WSYNC
                sta     VSYNC           

                lda     #45
                sta     TIM64T          

                eor     SkipFrame
                sta     SkipFrame
                bne     VblankLoop

                dec     ColourCycle

                ldx     #6
ShiftDisp:
                asl     Sprite7,x
                rol     Sprite6,x
                rol     Sprite5,x
                rol     Sprite4,x
                rol     Sprite3,x
                rol     Sprite2,x
                rol     Sprite1,x
                dex
                bpl     ShiftDisp

                dec     ShiftCount
                bpl     VblankLoop

                ldy     #7
CopyChar:
                lda     (CharPTR),y
                sta     ShiftCount,y
                dey
                bpl     CopyChar

                inc     TextPTR
                bne     T1
                inc     TextPTR+1
T1:
                jsr     NewCharPTR
                lda     #<TextEnd
                cmp     TextPTR
                bne     NoWrap
                ldx     #>TextEnd
                cpx     TextPTR+1
                bne     NoWrap
                jsr     ResetTextPTR
NoWrap:
VblankLoop:
                lda     INTIM
                bne     VblankLoop      
                sta     WSYNC           
                sta     VBLANK          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayStart:
                ldy     ColourCycle
                jsr     ColourFX
                sty     COLUBK
                dey
                sty     TempColour
                lda     #%11111100
                sta     PF2

                lda     #6
                sta     LoopCount
DS1:   
                ldx     LoopCount
                lda     Sprite1,x
                sta     GRP0
                sta     WSYNC
                ldy     TempColour
                sty     COLUBK
                lda     Sprite2,x
                sta     GRP1
                lda     Sprite3,x
                sta     GRP0
                lda     Sprite4,x
                sta     Temp
                lda     Sprite5,x
                tay
                lda     Sprite6,x
                tax
                lda     Temp
                sta     GRP1
                sty     GRP0
                stx     GRP1
                stx     GRP0

                dec     TempColour
                ldy     TempColour
                nop

                ldx     LoopCount
                lda     Sprite1,x
                sta     GRP0
                lda     Sprite2,x
                sta     GRP1
                sty     COLUBK
                lda     Sprite3,x
                sta     GRP0
                pha
                pla
                lda     Sprite5,x
                tay
                lda     Sprite6,x
                tax
                lda     Temp
                dec     TempColour
                sta     GRP1
                sty     GRP0
                stx     GRP1
                stx     GRP0

                dec     LoopCount
                bpl     DS1   

                lda     #0
                sta     GRP0
                sta     GRP1
                sta     GRP0
                sta     GRP1
                sta     PF2
                ldy     TempColour
                jsr     ColourFX
                lda     #$22            ;dec 34 = hex 22
                sta     VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OverscanStart:
                sta     TIM64T

OverscanLoop:
                lda     INTIM
                bne     OverscanLoop    
                sta     WSYNC           

                jmp     NewFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
ResetTextPTR
                lda     #<TextStart
                sta     TextPTR
                lda     #>TextStart
                sta     TextPTR+1
NewCharPTR:
                ldy     #0
                lda     (TextPTR),y
                sec
                sbc     #32
                sta     CharPTR
                tya
                asl     CharPTR
                rol
                asl     CharPTR
                rol
                asl     CharPTR
                rol
                ora     #$f0            ; start of character data (highbyte)
                sta     CharPTR+1
                rts
ColourFX:
                ldx     #88
D1:
                sty     COLUBK
                sta     WSYNC
                dey
                dex
                bne     D1
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
TextStart:
                .byte   "This is just a test text.        "
                .byte   "This is a test text too.        "
                .byte   "text wrap:        3        2        1        "
TextEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Set up the 6502 interrupt vector table
;
                ORG     $fffc
Reset           .word   Cart_Init
IRQ             .word   Cart_Init
        
		END

===Start of SCRLBAR7.DAS===================================================
                processor       6502
                include         vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Zeropage variables declaration
;
                SEG.U   Variables
                ORG     $80
LoopCount       ds      1
Temp            ds      1
Sprite1         ds      7
Sprite2         ds      7
Sprite3         ds      7
Sprite4         ds      7
Sprite5         ds      7
Sprite6         ds      7
ShiftCount      ds      1
Sprite7         ds      7
TextPTR         ds      2
CharPTR         ds      2
ColourCycle     ds      1
TempColour      ds      1
SkipFrame       ds      1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
                SEG     Code
                ORG     $f000
                include scrlfont.grp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Program initialization
;

Cart_Init:
                sei
                cld                     

                ldx     #$00
                txa
AllClear:
                sta     $00,x
                dex
                bne     AllClear
                txs

DemoInit:
                sta     WSYNC
                pha
                lda     #$f1
                sta     HMP1
                sta     CTRLPF
                lda     #$0a
                sta     COLUP0
                sta     COLUP1
                lda     #$e3
                sta     HMP0
                sta     NUSIZ0
                sta     NUSIZ1
                sta     VDELP0
                sta     VDELP1
                sta     RESP0
                sta     RESP1
                sta     WSYNC
                sta     HMOVE
                jsr     ResetTextPTR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Main program loop
;
NewFrame:
                ldx     #$02
                sta     WSYNC           
                stx     VSYNC           
                sta     WSYNC           
                sta     WSYNC
                sta     WSYNC
                sta     VSYNC           

                lda     #45
                sta     TIM64T          

                eor     SkipFrame
                sta     SkipFrame
                bne     VblankLoop

                dec     ColourCycle

                ldx     #6
ShiftDisp:
                asl     Sprite7,x
                rol     Sprite6,x
                rol     Sprite5,x
                rol     Sprite4,x
                rol     Sprite3,x
                rol     Sprite2,x
                rol     Sprite1,x
                dex
                bpl     ShiftDisp

                dec     ShiftCount
                bpl     VblankLoop

                ldy     #7
CopyChar:
                lda     (CharPTR),y
                sta     ShiftCount,y
                dey
                bpl     CopyChar

                inc     TextPTR
                bne     T1
                inc     TextPTR+1
T1:
                jsr     NewCharPTR
                lda     #<TextEnd
                cmp     TextPTR
                bne     NoWrap
                ldx     #>TextEnd
                cpx     TextPTR+1
                bne     NoWrap
                jsr     ResetTextPTR
NoWrap:
VblankLoop:
                lda     INTIM
                bne     VblankLoop      
                sta     WSYNC           
                sta     VBLANK          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayStart:
                ldy     ColourCycle
                jsr     ColourFX
                sty     COLUBK
                dey
                sty     TempColour
                lda     #%11111100
                sta     PF2

                lda     #6
                sta     LoopCount
DS1:   
                ldx     LoopCount
                lda     Sprite1,x
                sta     GRP0
                sta     WSYNC
                ldy     TempColour
                sty     COLUBK
                lda     Sprite2,x
                sta     GRP1
                lda     Sprite3,x
                sta     GRP0
                lda     Sprite4,x
                sta     Temp
                lda     Sprite5,x
                tay
                lda     Sprite6,x
                tax
                lda     Temp
                sta     GRP1
                sty     GRP0
                stx     GRP1
                stx     GRP0

                dec     TempColour
                ldy     TempColour
                nop

                ldx     LoopCount
                lda     Sprite1,x
                sta     GRP0
                lda     Sprite2,x
                sta     GRP1
                sty     COLUBK
                lda     Sprite3,x
                sta     GRP0
                pha
                pla
                lda     Sprite5,x
                tay
                lda     Sprite6,x
                tax
                lda     Temp
                dec     TempColour
                sta     GRP1
                sty     GRP0
                stx     GRP1
                stx     GRP0

                dec     LoopCount
                bpl     DS1   

                lda     #0
                sta     GRP0
                sta     GRP1
                sta     GRP0
                sta     GRP1
                sta     PF2
                ldy     TempColour
                jsr     ColourFX
                lda     #$22            ;dec 34 = hex 22
                sta     VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OverscanStart:
                sta     TIM64T

OverscanLoop:
                lda     INTIM
                bne     OverscanLoop    
                sta     WSYNC           

                jmp     NewFrame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
ResetTextPTR
                lda     #<TextStart
                sta     TextPTR
                lda     #>TextStart
                sta     TextPTR+1
NewCharPTR:
                ldy     #0
                lda     (TextPTR),y
                sec
                sbc     #32
                sta     CharPTR
                tya
                asl     CharPTR
                rol
                asl     CharPTR
                rol
                asl     CharPTR
                rol
                ora     #$f0            ; start of character data (highbyte)
                sta     CharPTR+1
                rts
ColourFX:
                ldx     #88
D1:
                sty     COLUBK
                sta     WSYNC
                dey
                dex
                bne     D1
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
TextStart:
                .byte   "This is just a test text.        "
                .byte   "This is a test text too.        "
                .byte   "text wrap:        3        2        1        "
TextEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;
; Set up the 6502 interrupt vector table
;
                ORG     $fffc
Reset           .word   Cart_Init
IRQ             .word   Cart_Init
        
		END


