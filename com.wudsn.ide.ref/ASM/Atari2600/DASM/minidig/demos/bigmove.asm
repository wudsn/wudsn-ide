	processor 6502

	include vcs.h

; TIA (Stella) write-only registers
;
Vsync		equ	$00
Vblank		equ	$01
Wsync		equ	$02
Rsync		equ	$03
Nusiz0		equ	$04
Nusiz1		equ	$05
Colup0		equ	$06
Colup1		equ	$07
Colupf		equ	$08
Colubk		equ	$09
Ctrlpf		equ	$0A
Refp0		equ	$0B
Refp1		equ	$0C
Pf0             equ     $0D
Pf1             equ     $0E
Pf2             equ     $0F
Resp0		equ	$10
Resp1		equ	$11
Resm0		equ	$12
Resm1		equ	$13
Resbl		equ	$14
Audc0		equ	$15
Audc1		equ	$16
Audf0		equ	$17
Audf1		equ	$18
Audv0		equ	$19
Audv1		equ	$1A
Grp0		equ	$1B
Grp1		equ	$1C
Enam0		equ	$1D
Enam1		equ	$1E
Enabl		equ	$1F
Hmp0		equ	$20
Hmp1		equ	$21
Hmm0		equ	$22
Hmm1		equ	$23
Hmbl		equ	$24
Vdelp0		equ	$25
Vdelp1		equ	$26
Vdelbl		equ	$27
Resmp0		equ	$28
Resmp1		equ	$29
Hmove		equ	$2A
Hmclr		equ	$2B
Cxclr		equ	$2C
;
; TIA (Stella) read-only registers
;
Cxm0p		equ	$00
Cxm1p		equ	$01
Cxp0fb		equ	$02
Cxp1fb		equ	$03
Cxm0fb		equ	$04
Cxm1fb		equ	$05
Cxblpf		equ	$06
Cxppmm		equ	$07
Inpt0		equ	$08
Inpt1		equ	$09
Inpt2		equ	$0A
Inpt3		equ	$0B
Inpt4		equ	$0C
Inpt5		equ	$0D
;
; RAM definitions
; Note: The system RAM maps in at 0080-00FF and also at 0180-01FF. It is
; used for variables and the system stack. The programmer must make sure
; the stack never grows so deep as to overwrite the variables.
;
RamStart	equ	$0080
RamEnd		equ	$00FF
StackBottom	equ	$00FF
StackTop	equ	$0080
;
; 6532 (RIOT) registers
;
Swcha		equ	$0280
Swacnt		equ	$0281
Swchb		equ	$0282
Swbcnt		equ	$0283
Intim		equ	$0284
Tim1t		equ	$0294
Tim8t		equ	$0295
Tim64t		equ	$0296
T1024t		equ	$0297
;
; ROM definitions
;
RomStart        equ     $F000
RomEnd          equ     $FFFF
IntVectors      equ     $FFFA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
s1              EQU     $80
s2              EQU     $82
s3              EQU     $84
s4              EQU     $86
s5              EQU     $88
s6              EQU     $8A
DelayPTR        EQU     $8C
LoopCount       EQU     $8E
TopDelay        EQU     $8F
BottomDelay     EQU     $90
MoveCount       EQU     $91
Temp            EQU     $92
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Program initialization
;
		ORG	RomStart

Cart_Init:
		SEI				; Disable interrupts.:
		CLD				; Clear "decimal" mode.

		LDX	#$FF
		TXS				; Clear the stack

Common_Init:
		LDX	#$28		; Clear the TIA registers ($04-$2C)
		LDA	#$00
TIAClear:
		STA	$04,X
		DEX
                BPL     TIAClear        ; loop exits with X=$FF
	
		LDX	#$FF
RAMClear:
		STA	$00,X		; Clear the RAM ($FF-$80)
		DEX
                BMI     RAMClear        ; loop exits with X=$7F
	
		LDX	#$FF
		TXS				; Reset the stack
 
IOClear:
		STA	Swbcnt		; console I/O always set to INPUT
		STA	Swacnt		; set controller I/O to INPUT

DemoInit:       LDA     #$01
                STA     VDELP0
                STA     VDELP1
                LDA     #$03
                STA     Nusiz0
                STA     Nusiz1
                LDA     #$36
                STA     COLUP0
                STA     COLUP1
                LDA     #$ff
                STA     s1+1
                STA     s2+1
                STA     s3+1
                STA     s4+1
                STA     s5+1
                STA     s6+1
                LDA     #0
                STA     s1
                LDA     #10
                STA     s2
                LDA     #20
                STA     s3
                LDA     #30
                STA     s4
                LDA     #40
                STA     s5
                LDA     #50
                STA     s6
                LDA     #0
                STA     TopDelay
                STA     MoveCount
                LDA     #179
                STA     BottomDelay
                LDA     #$f2
                STA     DelayPTR+1
                LDA     #$1d+36 ;?????
                STA     DelayPTR
                STA     Wsync
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                STA     RESP0
                STA     RESP1
                LDA     #$50    ;?????
                STA     HMP1
                LDA     #$40    ;?????
                STA     HMP0
                STA     Wsync
                STA     HMOVE
                STA     Wsync
                LDA     #$04
                STA     COLUBK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Main program loop
;
NewScreen:
                LDA     #$02
		STA	Wsync		; Wait for horizontal sync
		STA	Vblank		; Turn on Vblank
                STA	Vsync		; Turn on Vsync
		STA	Wsync		; Leave Vsync on for 3 lines
		STA	Wsync
		STA	Wsync
                LDA     #$00
		STA	Vsync		; Turn Vsync off

                LDA     #43             ; Vblank for 37 lines
                                        ; changed from 43 to 53 for 45 lines PAL
		STA	Tim64t		; 43*64intvls=2752=8256colclks=36.2lines

Joystick:       LDA     #$80
                BIT     SWCHA
                BEQ     Right
                LSR
                BIT     SWCHA
                BEQ     Left
                LSR
                BIT     SWCHA
                BEQ     Down
                LSR
                BIT     SWCHA
                BEQ     UP
                JMP     VblankLoop

UP:             LDA     TopDelay
                BEQ     U1
                DEC     TopDelay
                INC     BottomDelay
U1:             JMP     VblankLoop

Down:           LDA     BottomDelay
                BEQ     D1
                INC     TopDelay
                DEC     BottomDelay
D1:             JMP     VblankLoop

Right:          LDX     MoveCount
                INX
                STX     MoveCount
                CPX     #3
                BNE     R2
                LDX     DelayPTR
                DEX
                STX     DelayPTR
                CPX     #$1c ;?????
                BNE     R1
                LDA     #$1d ;?????
                STA     DelayPTR
                LDA     #2
                STA     MoveCount
                JMP     VblankLoop
R1:             LDA     #0
                STA     MoveCount
R2:             LDA     #$f0
                STA     HMP0
                STA     HMP1
                STA     Wsync
                STA     HMOVE
                JMP     VblankLoop

Left:           LDX     MoveCount
                DEX
                STX     MoveCount
                CPX     #$ff
                BNE     L2
                LDX     DelayPTR
                INX
                STX     DelayPTR
                CPX     #$1d+37 ;?????
                BNE     L1
                LDA     #$1d+36 ;#?????
                STA     DelayPTR
                LDA     #0
                STA     MoveCount
                JMP     VblankLoop
L1:             LDA     #2
                STA     MoveCount
L2:             LDA     #$10
                STA     HMP0
                STA     HMP1
                STA     Wsync
                STA     HMOVE
                JMP     VblankLoop

                ORG     $F200
VblankLoop:
		LDA	Intim
		BNE	VblankLoop	; wait for vblank timer
		STA	Wsync		; finish waiting for the current line
		STA	Vblank		; Turn off Vblank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScreenStart:
                LDY     TopDelay
                INY     ;?????
X1:             STA     Wsync
                DEY
                BNE     X1
                LDY     #4 ;?????
X2:             DEY
                BPL     X2
                LDA     #9
                STA     LoopCount
                JMP     (DelayPTR)
JNDelay:        byte      $c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9
                byte      $c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9
                byte      $c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9
                byte      $c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c9,$c5
                NOP
X3:             NOP
                NOP
                NOP
                LDY     LoopCount
                LDA     (s1),Y
                STA     GRP0
                LDA     (s2),Y
                STA     GRP1
                LDA     (s3),Y
                STA     GRP0
                LDA     (s6),Y
                STA     Temp
                LDA     (s5),Y
                TAX
                LDA     (s4),Y
                LDY     Temp
                STA     GRP1
                STX     GRP0
                STY     GRP1
                STA     GRP0
                DEC     LoopCount
                BPL     X3
                LDA     #0
                STA     GRP0
                STA     GRP1
                STA     GRP0
                STA     GRP1
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                NOP
                LDY     BottomDelay
                INY     ;?????
X4:             STA     Wsync
                DEY
                BNE     X4
                LDA     #$02
                STA     Vblank
                STA     Wsync
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
OverscanStart:  LDA     #35             ;skip 30 lines (overscan)
		STA	Tim64t

OverscanLoop:
		LDA	Intim
		BNE	OverscanLoop	; wait for Overscan timer
		STA	Wsync		; finish waiting for the current line


                JMP     NewScreen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ORG     $FF00
Data:           byte      $00,$88,$89,$8a,$8a,$8a,$aa,$fa,$d9,$88
                byte      $00,$82,$45,$28,$28,$28,$28,$28,$48,$88
                byte      $00,$3e,$20,$a0,$a0,$b8,$a0,$a0,$a0,$be
                byte      $00,$11,$11,$11,$11,$11,$11,$11,$11,$7d
                byte      $00,$17,$11,$11,$11,$f1,$11,$11,$11,$17
                byte      $00,$cc,$12,$01,$01,$0e,$10,$10,$09,$c6
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Set up the 6502 interrupt vector table
;
		ORG	IntVectors
NMI             word      Cart_Init
Reset           word      Cart_Init
IRQ             word      Cart_Init
        
		END
