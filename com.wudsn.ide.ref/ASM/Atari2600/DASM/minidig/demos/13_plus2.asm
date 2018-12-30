;---------------------------------------------------------------------------
;
; 13 char + 2 demo
;
; Paul Slocum
;
;---------------------------------------------------------------------------

        processor 6502
        include "vcs.h"


;---------------------------------------------------------------------------
; Constants
;---------------------------------------------------------------------------

chars equ $a7 ;2

;---------------------------------------------------------------------------
; RAM Variables
;---------------------------------------------------------------------------

charp equ $80 ;5
chara equ $85 ;5
charb equ $8a ;5
charc equ $8f ;5
chard equ $94 ;5
chare equ $99 ;5
charf equ $9e ;5
charg equ $a3 ;5

temp  equ $a9
line  equ $aa
count equ $ab
textptr equ $ac
savesp equ $ad



  MAC SLEEP
    IF {1} = 1
      ECHO "ERROR: SLEEP 1 not allowed !"
      END
    ENDIF
    IF {1} & 1
      nop $00
      REPEAT ({1}-3)/2
        nop
      REPEND
    ELSE
      REPEAT ({1})/2
        nop
      REPEND
    ENDIF
  ENDM



   MAC TEXTDISP
	lda #11
	sta NUSIZ1
	sta VDELP1
	lda charg+{1}	;3
	sta ENAM0		;3
	lsr				;2
	sta ENAM1		;3
	lsr				;2
	sta ENABL		;3
	lda charf+{1} 	;3
	sta GRP0			;3
	lda chare+{1}	;3
	sta GRP1			;3
	nop
	lda chard+{1}	;3
	sta GRP0			;3
	lda charc+{1}	;3
	ldy charb+{1}	;3
	ldx chara+{1}	;3
	sta GRP1			;3
	sty GRP0			;3
	stx GRP1			;3
	sta VDELP1		;3
	lda #4
	sta NUSIZ1
	lda charp+{1}	;3
	sta GRP1
   ENDM



;---------------------------------------------------------------------------
;---------------------------------------------------------------------------
        org $F000
;---------------------------------------------------------------------------
;---------------------------------------------------------------------------

;---------------------------------------------------------------------------
; Start of Program
;---------------------------------------------------------------------------
; Clear memory, locate character graphics positions and such,
; initialize key memory values, start GameLoop.
;-------------------------------------------------------------
Start
        sei
        cld
        ldx #$FF
        txs
        lda #0
clear
        sta 0,x
        dex
        bne clear

;---------------------------------------------------------------------------
; Initialize variables / registers
;---------------------------------------------------------------------------

        lda #$28
        sta COLUP0
        lda #$28
        sta COLUP1
        lda #255
        sta PF0
        lda #$f0
        sta PF1
        lda #0
        sta PF2

        lda #%00000101
        sta CTRLPF
        sta WSYNC
        sta GRP0
        sta GRP1
        lda #$03           ; set both players to 3 copies
        sta NUSIZ0
        sta NUSIZ1
        lda #$01           ; set vertical delay on for both players
        sta VDELP0
        sta RESM0
        sta RESM1
        sta VDELP1
        sta RESBL
        sta RESP0
        sta RESP1
        lda #%11110000
        sta HMP1
        lda #%11100000
        sta HMP0
        lda #%10000000
        sta HMBL
        lda #%10110000
        sta HMM0
        lda #%01010000
        sta HMM1
        sta WSYNC
        sta HMOVE


;--------------------------------------------------------------------------
; GameLoop
;--------------------------------------------------------------------------
GameLoop
        jsr VSync       ;start vertical retrace

        jsr VBlank      ; spare time during screen blank
        jsr Picture     ; draw one screen
        jsr overscan    ; do overscan

        jmp GameLoop    ;back to top

;--------------------------------------------------------------------------
; VSync
;--------------------------------------------------------------------------
VSync
        lda #2          ;bit 1 needs to be 1 to start retrace
        sta VSYNC       ;start retrace
        sta WSYNC       ;wait a few lines
        sta WSYNC
        lda #44         ;prepare timer to exit blank period (44)
        sta TIM64T      ;turn it on
        sta WSYNC       ;wait one more
        sta VSYNC       ;done with retrace, write 0 to bit 1

        rts ; VSync



;--------------------------------------------------------------------------
; VBlank
;--------------------------------------------------------------------------
; Game Logic
;--------------------------------------------------------------------------
VBlank

        rts ; VBlank



;--------------------------------------------------------------------------
; Overscan
;--------------------------------------------------------------------------
; More Game Logic
;--------------------------------------------------------------------------
overscan

        sta WSYNC

        lda #$00
        sta COLUBK

        lda #36         ; Use the timer to make sure overscan takes (34)
        sta TIM64T      ; 30 scan lines.  29 scan lines * 76 = 2204 / 64 = 34.4

endOS
        lda INTIM       ; We finished, but wait for timer
        bne endOS       ; by looping till zero

        sta WSYNC       ; End last scanline

        lda #$82
        sta VBLANK
        lda #$02
        sta VBLANK

        rts     ; overscan



;--------------------------------------------------------------------------
; Draw TV Pictures
;--------------------------------------------------------------------------
;
;--------------------------------------------------------------------------


Picture

pictureLoop
        lda INTIM       ;check timer for end of VBLANK period
        bne pictureLoop ;loop until it reaches 0

        sta WSYNC
        lda #$80
        sta VBLANK      ;end screen blank

        ; Set playfield color
        lda #$28
        sta COLUPF

        lda #15
        sta line

        lda #0
        sta textptr

        tsx
        stx savesp
        
        SLEEP 45

        jmp mainTextLoop        ;3

; put this here so we can jump out of the main text loop
; using a 2-cycle relative branch.

quitTextLoop

        lda #0
        sta GRP0
        sta GRP1
        sta GRP0
        sta GRP1
        sta ENAM0
        sta ENAM1
        sta ENABL

; restore stack pointer

        ldx savesp
        txs


        ldx #11

ScanLoop
        sta WSYNC
        dex
        bne ScanLoop

        sta COLUPF

        rts     ; Picture


        ;------------------------------------------------------------------

	align 256

mainTextLoop

; set up the stack for building screen data

        ldx #chars      ;2
        txs             ;2

; load the first text character
; note: x and y are reversed!
        ldy textptr      ;3
        ldx text,y       ;4
        beq quitTextLoop ;2 ->4   ; look for terminating character (0)
        iny              ;2

; build screen data for first character

        lda fontlo,x    ;4
        pha             ;3
        lda fontlo+1,x  ;4
        pha             ;3
        lda fontlo+2,x  ;4
        pha             ;3
        lda fontlo+3,x  ;4
        pha             ;3
        lda fontlo+4,x  ;4
        pha             ;3

; loop through the remaining 6 character pairs
textLineLoop

; load the next two text characters

        ldx text,y      ;4
        lda text1,y     ;4
        iny             ;2
        sty textptr     ;3
        tay             ;2

; build screen data for next two characters

        lda fonthi,x    ;4
        ora fontlo,y    ;4
        pha             ;3
        lda fonthi+1,x  ;4
        ora fontlo+1,y  ;4
        pha             ;3
        lda fonthi+2,x  ;4
        ora fontlo+2,y  ;4
        pha             ;3
        lda fonthi+3,x  ;4
        ora fontlo+3,y  ;4
        pha             ;3
        lda fonthi+4,x  ;4
        ora fontlo+4,y  ;4
        pha             ;3

; next character pair
        ldy textptr      ;3
        tsx              ;2
        bmi textLineLoop ;2

; now render it asap

        TEXTDISP 0,0
        TEXTDISP 1,2
        TEXTDISP 2,4
        TEXTDISP 3,6
        TEXTDISP 4,8

        lda #0          ;2
;        sta COLUP0      ;3
;        sta COLUP1      ;3
        sta GRP0
        sta GRP1
        sta GRP0
        sta ENAM0
        sta ENAM1
        sta ENABL


        SLEEP 66        ; 15+23+12

	jmp mainTextLoop  ;3

        ;------------------------------------------------------------------
        ;------------------------------------------------------------------




;---------------------------------------------------------------------------
; note: dasm doesn't like using x or y as a label!

  MAC TEXTA
   byte {16},{3},{5},{7},{9},{11},{13},{15}
  ENDM
  MAC TEXTB
   byte {1},{2},{4},{6},{8},{10},{12},{14}
  ENDM

  MAC TEXT
	TEXT{1} t,h,i,r,t,e,e,n,c,h,a,r,s,plus,_2,0
	TEXT{1} _,_,ast,_,d,e,m,o,_,ast,_,_,_,_,_,0
	TEXT{1} eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,0
	TEXT{1} b,r,o,a,d,_,s,w,o,r,d,_,_,plus,_2,0
	TEXT{1} w,o,o,d,e,n,_,s,h,i,e,l,d,min,_1,0
	TEXT{1} m,e,t,a,l,_,h,e,l,m,e,t,_,min,_1,0
	TEXT{1} s,u,p,e,r,_,w,e,b,_,_,_,_,n,a,0
	TEXT{1} t,i,g,e,r,_,s,t,a,f,f,_,_,plus,_5,0
	TEXT{1} t,e,xx,t,_,r,o,u,t,i,n,e,_,plus,_9,0
	TEXT{1} eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,eq,0
	TEXT{1} g,o,l,d,_,n,u,g,g,e,t,s,_,_3,_5,0
	TEXT{1} l,i,g,h,t,_,a,r,r,o,w,s,_,_1,_5,0
	TEXT{1} w,h,i,t,e,_,m,a,j,i,c,k,s,_8,_3,0
  ENDM

        align 256
text
   TEXT B
text1
   TEXT A


;---------------------------------------------------------------------------

        align 256
fonthi

eof
	byte %00000000  ; value not used, address must be zero
_
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
a
        byte %10100000
        byte %10100000
        byte %11100000
        byte %10100000
        byte %01000000
b
        byte %11000000
        byte %10100000
        byte %11000000
        byte %10100000
        byte %11000000
c
        byte %01100000
        byte %10000000
        byte %10000000
        byte %10000000
        byte %01100000
d
        byte %11000000
        byte %10100000
        byte %10100000
        byte %10100000
        byte %11000000
e
        byte %11100000
        byte %10000000
        byte %11000000
        byte %10000000
        byte %11100000
f
        byte %10000000
        byte %10000000
        byte %11000000
        byte %10000000
        byte %11100000
g
        byte %01100000
        byte %10100000
        byte %10100000
        byte %10000000
        byte %01100000
h
        byte %10100000
        byte %10100000
        byte %11100000
        byte %10100000
        byte %10100000
i
_1
        byte %01000000
        byte %01000000
        byte %01000000
        byte %01000000
        byte %01000000
j
        byte %10000000
        byte %01000000
        byte %01000000
        byte %01000000
        byte %11100000
k
        byte %10100000
        byte %10100000
        byte %11000000
        byte %10100000
        byte %10000000
l
        byte %11100000
        byte %10000000
        byte %10000000
        byte %10000000
        byte %10000000
m
        byte %10100000
        byte %10100000
        byte %10100000
        byte %11100000
        byte %10100000
n
        byte %10100000
        byte %10100000
        byte %10100000
        byte %10100000
        byte %11000000
o
_0
        byte %01000000
        byte %10100000
        byte %10100000
        byte %10100000
        byte %01000000
p
        byte %10000000
        byte %10000000
        byte %11000000
        byte %10100000
        byte %11000000
q
        byte %01100000
        byte %11100000
        byte %10100000
        byte %10100000
        byte %01000000
r
        byte %10100000
        byte %10100000
        byte %11000000
        byte %10100000
        byte %11000000
s
        byte %11000000
        byte %00100000
        byte %01000000
        byte %10000000
        byte %01100000
t
        byte %01000000
        byte %01000000
        byte %01000000
        byte %01000000
        byte %11100000
u
        byte %01100000
        byte %10100000
        byte %10100000
        byte %10100000
        byte %10100000
v
        byte %01000000
        byte %01000000
        byte %10100000
        byte %10100000
        byte %10100000
w
        byte %10100000
        byte %11100000
        byte %10100000
        byte %10100000
        byte %10100000
xx
        byte %10100000
        byte %10100000
        byte %01000000
        byte %10100000
        byte %10100000
yy
        byte %01000000
        byte %01000000
        byte %01000000
        byte %10100000
        byte %10100000
z
        byte %11100000
        byte %10000000
        byte %01000000
        byte %00100000
        byte %11100000
ast
        byte %10100000
        byte %01000000
        byte %11100000
        byte %01000000
        byte %10100000
eq
        byte %00000000
        byte %11100000
        byte %00000000
        byte %11100000
        byte %00000000
plus
        byte %00000000
        byte %01000000
        byte %11100000
        byte %01000000
        byte %00000000
min
        byte %00000000
        byte %00000000
        byte %11100000
        byte %00000000
        byte %00000000
_2  
        byte %11100000
        byte %10000000
        byte %01000000
        byte %00100000
        byte %11000000
_3  
        byte %11100000
        byte %00100000
        byte %01100000
        byte %00100000
        byte %11100000
_4  
        byte %00100000
        byte %00100000
        byte %11100000
        byte %10100000
        byte %10100000
_5  
        byte %11100000
        byte %00100000
        byte %11100000
        byte %10000000
        byte %11100000
_6  
        byte %01000000
        byte %10100000
        byte %11000000
        byte %10000000
        byte %01100000
_7  
        byte %10000000
        byte %10000000
        byte %10000000
        byte %10000000
        byte %11100000
_8  
        byte %11100000
        byte %10100000
        byte %11100000
        byte %10100000
        byte %11100000
_9  
        byte %01000000
        byte %00100000
        byte %11100000
        byte %10100000
        byte %11100000



        align 256
fontlo
;eof
	byte %00000000
;_
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
        byte %00000000
;a
        byte %00001010
        byte %00001010
        byte %00001110
        byte %00001010
        byte %00000100
;b
        byte %00001100
        byte %00001010
        byte %00001100
        byte %00001010
        byte %00001100
;c
        byte %00000110
        byte %00001000
        byte %00001000
        byte %00001000
        byte %00000110
;d
        byte %00001100
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00001100
;e
        byte %00001110
        byte %00001000
        byte %00001100
        byte %00001000
        byte %00001110
;f
        byte %00001000
        byte %00001000
        byte %00001100
        byte %00001000
        byte %00001110
;g
        byte %00000110
        byte %00001010
        byte %00001010
        byte %00001000
        byte %00000110
;h
        byte %00001010
        byte %00001010
        byte %00001110
        byte %00001010
        byte %00001010
;i
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00000100
;j
        byte %00001000
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00001110
;k
        byte %00001010
        byte %00001010
        byte %00001100
        byte %00001010
        byte %00001000
;l
        byte %00001110
        byte %00001000
        byte %00001000
        byte %00001000
        byte %00001000
;m
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00001110
        byte %00001010
;n
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00001100
;o
        byte %00000100
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00000100
;p
        byte %00001000
        byte %00001000
        byte %00001100
        byte %00001010
        byte %00001100
;q
        byte %00000110
        byte %00001110
        byte %00001010
        byte %00001010
        byte %00000100
;r
        byte %00001010
        byte %00001010
        byte %00001100
        byte %00001010
        byte %00001100
;s
        byte %00001100
        byte %00000010
        byte %00000100
        byte %00001000
        byte %00000110
;t
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00001110
;u
        byte %00000110
        byte %00001010
        byte %00001010
        byte %00001010
        byte %00001010
;v
        byte %00000100
        byte %00000100
        byte %00001010
        byte %00001010
        byte %00001010
;w
        byte %00001010
        byte %00001110
        byte %00001010
        byte %00001010
        byte %00001010
;xx
        byte %00001010
        byte %00001010
        byte %00000100
        byte %00001010
        byte %00001010
;yy
        byte %00000100
        byte %00000100
        byte %00000100
        byte %00001010
        byte %00001010
;z
        byte %00001110
        byte %00001000
        byte %00000100
        byte %00000010
        byte %00001110
;ast
        byte %00001010
        byte %00000100
        byte %00001110
        byte %00000100
        byte %00001010
;eq
        byte %00000000
        byte %00001110
        byte %00000000
        byte %00001110
        byte %00000000
;plus
        byte %0000
        byte %0100
        byte %1110
        byte %0100
        byte %0000
;min
        byte %0000
        byte %0000
        byte %1110
        byte %0000
        byte %0000
;_2  
        byte %1110
        byte %1000
        byte %0100
        byte %0010
        byte %1100
;_3  
        byte %1110
        byte %0010
        byte %0110
        byte %0010
        byte %1110
;_4  
        byte %0010
        byte %0010
        byte %1110
        byte %1010
        byte %1010
;_5  
        byte %1110
        byte %0010
        byte %1110
        byte %1000
        byte %1110
;_6  
        byte %0100
        byte %1010
        byte %1100
        byte %1000
        byte %0110
;_7  
        byte %1000
        byte %1000
        byte %1000
        byte %1000
        byte %1110
;_8  
        byte %1110
        byte %1010
        byte %1110
        byte %1010
        byte %1110
;_9  
        byte %1100
        byte %0010
        byte %1110
        byte %1010
        byte %1110



;---------------------------------------------------------------------------
; Program Startup
;---------------------------------------------------------------------------
        org $FFFC
        word Start
        word Start
