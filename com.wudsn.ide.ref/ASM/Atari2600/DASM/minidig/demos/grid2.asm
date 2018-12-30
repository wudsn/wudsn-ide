                processor       6502
                include         vcs.h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Zeropage variables declaration
;
                SEG.U   Variables
                ORG     $80
GPTR            ds      2       ; Pointer to graphics data
LCPTR           ds      2       ; Pointer to line background colour data
GridCount       ds      1       ; Counter for shift phase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Program initialization
;
                SEG     Code
                ORG     $f000

Cart_Init:
                sei
                cld                     

Common_Init:
                ldx     #$28            ; Clear the TIA registers ($04-$2C)
                lda     #$00
TIAClear:
                sta     $04,X
                dex
                bpl     TIAClear

RAMClear:
                sta     $00,X           
                dex
                bmi     RAMClear        
	
                ldx     #$ff
                txs                     
 
IOClear:
                sta     SWBCNT          
                sta     SWACNT          


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Main program loop
;
NewFrame:
                lda     #$02
                sta     WSYNC           
;                sta     VBLANK          
                sta     VSYNC           
                sta     WSYNC           
                sta     WSYNC
                sta     WSYNC
                lda     #$00
                sta     VSYNC           

                lda     #43             ; Vblank for 37 lines
                sta     TIM64T          

                ldx     GridCount
Joystick:       lda     SWCHA
                bpl     Right
                asl
                bpl     Left
                jmp     NoStick

Right:          dex
                bpl     REnd
                ldx     #2
REnd:           stx     GridCount
                jmp     NoStick

Left:           inx
                cpx     #$03
                bne     LEnd
                ldx     #0
LEnd:           stx     GridCount

NoStick:        lda     GLow,x
                sta     GPTR
                lda     GHigh,x
                sta     GPTR+1
                lda     LCLow,x
                sta     LCPTR
                lda     LCHigh,x
                sta     LCPTR+1

                lda     #$0e
                sta     COLUBK
                cpx     #2
                bne     White
                lda     #$00
White:          sta     COLUP0
                sta     COLUP1
                lda     #%00000011
                sta     NUSIZ0
                sta     NUSIZ1


VblankLoop:
                lda     INTIM
                bne     VblankLoop      
                sta     WSYNC           
                sta     VBLANK          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayStart:
                ldx     #30
                ldy     #5
                jsr     DisplayLine
DS1:            ldy     #4
                jsr     DisplayLine
                dex
                bpl     DS1

                sta     WSYNC
                lda     #2
                sta     VBLANK
                sta     WSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OverscanStart:  lda     #35             ;skip 30 lines (overscan)
                sta     TIM64T

OverscanLoop:
                lda     INTIM
                bne     OverscanLoop    
                sta     WSYNC           

                jmp     NewFrame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ALIGN   256
Graphics:
G1:             .byte   %00000000
                .byte   %10010010
                .byte   %10010010
                .byte   %10010010
                .byte   %10010010
                .byte   %00000000
G2:             .byte   %00000000
                .byte   %01001001
                .byte   %01001001
                .byte   %01001001
                .byte   %01001001
                .byte   %00000000
G3:             .byte   %00000000
                .byte   %11011011
                .byte   %11011011
                .byte   %11011011
                .byte   %11011011
                .byte   %00000000
LineColours:
LC1:            .byte   $0e,0,0,0,0,$0e
LC2:            .byte   $0e,$0e,$0e,$0e,$0e,$0e


GLow:           .byte   <G1,<G2,<G3
GHigh:          .byte   >G1,>G2,>G3
LCLow:          .byte   <LC1,<LC1,<LC2
LCHigh:         .byte   >LC1,>LC1,>LC2

DisplayLine:
                sta     WSYNC
                .byte   $c5             ; cmp $ea   - 3 cycles
DL1:            .byte   $ea             ; nop       - 2 cycles
                lda     (GPTR),y
                sta     GRP0    
                sta     GRP1    
                lda     (LCPTR),y
                sta     COLUBK
                nop
                sta     RESP0   
                sta     RESP1      
                sta     RESP0   
                sta     RESP1   
                sta     RESP0   
                sta     RESP1     
                sta     RESP0   
                sta     RESP1   
                sta     RESP0   
                sta     RESP1   
                sta     RESP0   
                sta     RESP1   
                sta     RESP0   
                sta     RESP1   
                sta     RESP0   
                sta     RESP1   
                dey              
                bpl     DL1
                rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Set up the 6502 interrupt vector table
;
                ORG     $fffc
Reset           .word   Cart_Init
IRQ             .word   Cart_Init
        
		END

