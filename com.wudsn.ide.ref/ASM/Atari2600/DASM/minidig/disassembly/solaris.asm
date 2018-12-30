      processor 6502
      seg.u stella

;LIST ON
;PW 80
;PL 253
;SYNTAX 6502
;CODE
;RADIX 10
;ABSOLUTE
;  VERSION 19.4 DATE 22-FEB-86
;
;TITLE   UNIVERSE   COPYRIGHT 1986, DOUGLAS NEUBAUER
;
;
;  ********************************
; COPYRIGHT (C) 1986, DOUGLAS NEUBAUER
; THIS SOURCE LISTING IS COPYRIGHTED.
; NO RIGHT TO REPRODUCE THIS LISTING
; IS GRANTED UNLESS BY WRITTEN AGREEMENT
; OR WRITTEN PERMISSION BY DOUGLAS NEUBAUER
;  ********************************
;
; FILE NAME UNIV.ASM,UNIV.OBJ
;
; BEGINS 07-JAN-83
; SCREEN 11-MAR-83
; ENDS ????????
;
;  ********************************
;    BURN = 1 THEN BURN PROMS, BURN = 0 THEN ASSEMBLE FOR DEVELOPMENT SYSTEM
BURN EQU 1
;  ********************************
;
;      BANK2         BANK4
; 0   FIGHTER       PLN FIG
; 8   PIRATE        PLN PIR
; 10  WARP GRA.     MISC GRAPH
; 14  DARTER        ----
; 18  HYPERJUMPER   MAN + KEY
; 20  P KILLER      LANDING ZONE
; 28  BLOCKADER     TRN TOWER
; 30  ENEMY PHOTON  ENE PHOTON
; 38  EXPLOSIONS    EXPLOS
; 40  SATURN RINGS  CRATER
; 48-53  MOON1
; 54-5F  MOON2
; E0  PBLK   (60+80)
;
;
;  *** ZERO PAGE RAM ***
;
;   BEGIN DATA SECTION
;DATA
;
      ORG $80
MAZRAM DS 8
CURSOR DS 1
JMPCNT DS 1
MAZSTA DS 1 ;MUST BE RIGHT AFTER JMPCNT (FOR FINDV)
RANDOM DS 2
PROGST DS 1
HCOLP1 DS 2
JMPTIM DS 1
NOCLER
             ; DONT CLEAR PREVIOUS RAM ON WARM START
NEWLEV DS 1  ;NO CLEAR ON GAME SEL.
PNTR1  DS 2
PNTR2  DS 2
PNTR3  DS 2
PNTR4  DS 2
PNTR5  DS 2
PNTR6  DS 2
ATRACT DS 2  ;2 BYTE FRAME TIMER
ONESHT DS 1
;
HGRAP1 DS 3  ; PLAYER TYPE
       DS 1
HGRAP0 DS 4
IQREAP DS 1  ;ALSO HWARF TARGET NUM.
;
HHORP1 DS 3  ; PLAYER X
       DS 1
HHORP0 DS 4
PLINES DS 1
;
HVERP1 DS 3  ; PLAYER Y
       DS 1
HVERP0 DS 4
VWALL  DS 1
;
ZPOSP1 DS 2  ; PHOTON Z
       DS 1
ZPOSP0 DS 4
       DS 1  ;IQPATH-1
IQPATH DS 4
;
;  TEMPORARY STUFF  *********
STARS  DS 2  ;STAR PNTR
REQUST DS 1
BOTSCN DS 1
HHORM2 DS 1  ; STAR HPOS
NEWATT DS 1
PAUTIM DS 1
CENTER DS 1  ; HORIZ ZOOM BYTE
IQPNTR DS 1  ;IQ RAM
IQSTAK DS 1
IQWARP DS 1
SHIPST DS 1
HOLDM2 DS 1
HOLDM0 DS 1
;  END TEMP ******************
;
GAMTIM DS 1
LSTCUR DS 1
GAMEST DS 1
LIVES  DS 1
TARNUM DS 1
FUEL   DS 1
SCORE  DS 3
CH0PTR DS 1
CH1PTR DS 1
CH0SHD DS 1
CH1SHD DS 1
 ORG $E3
; BEGIN CHART BLOCK
EXPNTR DS 1  ; ALSO USED AS CHART TIMER
CHTBLK
VECTP1 DS 2
PNTRP1 DS 1
       DS 1
XDELP0 DS 4
       DS 1
YDELP0 DS 4
       DS 1
ZDELP0 DS 4  ; SPEED OF OBJS.
VELOC  DS 1  ; FOR HORIZ SHIP
HPOSL  DS 1  ; FOR HORIZ SHIP
HHITP0 DS 4  ; USES STAK1 TOO ,ALSO USED FOR STACK IN BRAIN, 4LEV DEEP
; END CHART BLOCK
; FOLLOWING VARIABLES RESIDE IN STACK
STAK1  DS 1
STAK2  DS 1
STAK3  DS 1
STAK4  DS 1
;
;
;  END DATA SECTION
;; CODE
;
;
;  VCS EQUATES
VSYNC  EQU 0
VBLANK EQU 1
WSYNC  EQU 2
SIZPM0 EQU 4
SIZPM1 EQU 5
COLPM0 EQU 6
COLPM1 EQU 7
COLPF  EQU 8
COLBK  EQU 9
PRIOR  EQU $A
REFP0  EQU $B
REFP1  EQU $C
GRFPF0 EQU $D
GRFPF1 EQU $E
GRFPF2 EQU $F
HPOSP0 EQU $10
HPOSP1 EQU $11
HPOSM0 EQU $12
HPOSM1 EQU $13
HPOSM2 EQU $14
AUDC0  EQU $15
AUDC1  EQU $16
AUDF0  EQU $17
AUDF1  EQU $18
AUDV0  EQU $19
AUDV1  EQU $1A
GRAFP0 EQU $1B
GRAFP1 EQU $1C
GRAFM0 EQU $1D
GRAFM1 EQU $1E
GRAFM2 EQU $1F
HDELP0 EQU $20
HDELP1 EQU $21
HDELM0 EQU $22
HDELM1 EQU $23
HDELM2 EQU $24
VDELP0 EQU $25
VDELP1 EQU $26
VDELM2 EQU $27
GCTLM0 EQU $28
GCTLM1 EQU $29
ADDEL  EQU $2A
CLRDEL EQU $2B
HITCLR EQU $2C
M0PL   EQU $30
M1PL   EQU $31
P0PF   EQU $32
P1PF   EQU $33
M0PF   EQU $34
M1PF   EQU $35
M2PF   EQU $36
MIPL   EQU $37
POT0   EQU $38
POT1   EQU $39
POT2   EQU $3A
POT3   EQU $3B
TRIG0  EQU $3C
TRIG1  EQU $3D
PORTA  EQU $280
RACTL  EQU $281
PORTB  EQU $282
PBCTL  EQU $283
RTIMER EQU $284
RFLAG  EQU $285
STIME1 EQU $294
STIME8 EQU $295
STIM64 EQU $296
ST1024 EQU $297
FTIME1 EQU $29C
FTIME8 EQU $29D
FTIM64 EQU $29E
FT1024 EQU $29F
;
;
;  BANK SELECT EQUATES

 IFCONST BURN
BANK1 EQU $F000
BANK2 EQU $F000
BANK3 EQU $F000
BANK4 EQU $F000
 ELSE
BANK1 EQU $C000
BANK2 EQU $D000
BANK3 EQU $E000
BANK4 EQU $F000
 ENDIF
STROB1 EQU $FFF6
STROB2 EQU $FFF8
STROB3 EQU $FFF7
STROB4 EQU $FFF9
;
;
;  GAME EQUATES
NUMCOL EQU 3+4
K      EQU 8   ; CHTRAM POS. OF HOME PLANET
U      EQU 1
TOPSCN EQU $99
SCNSIZ EQU TOPSCN+39
MTNTOP EQU $62
TRNTOP EQU $62
VSHIP  EQU $1D
ZVIS   EQU $78
PBLK   EQU $60+$80  ; BLANK P0
POFF   EQU $A8   ;NEW P0
SCLR   EQU $F2  ;STAR COLOR
VCENT  EQU $53 ;VERT ZOOM CENTR OF SCRN
SKYCOL EQU $70
SURCOL EQU $62
TRNCOL EQU $84
; Z= USED IN BANK2
; EQUATE Q= BRNTB1
; EQUATE W= TYPTAB
; EQUATE J= AUDTAB
; BOTTOM OF SCREEN = 0
;
; VBLANK EQUATES
;
TEMP4    EQU PNTR5+0
TEMP5    EQU PNTR2+1
TEMP6    EQU PNTR1+0
TEMP7    EQU PNTR1+1
TEMP9    EQU PNTR4+0
TEMP10   EQU PNTR4+1
JOYRMH   EQU PNTR6+0
JOYRMV   EQU PNTR6+1
TEMP11   EQU PNTR2+0
TEMP12   EQU PNTR3+0
TEMP13   EQU PNTR3+1
THGRP1   EQU PNTR5+1  ;SHIP GRAPHIC 0,1,2
NEWAVE   EQU STARS+1
;
;
;  SCREEN EQUATES
VECTP0 EQU PNTR1
HOLDP1 EQU PNTR2+0
CROSP1 EQU PNTR2+1
VERTP0 EQU PNTR3+0
VERTP1 EQU PNTR3+1
MISC1  EQU PNTR4
MOON2  EQU PNTR5
MOON1  EQU PNTR6
MOON3  EQU STAK1  ;AND STAK2
MISC2  EQU STAK3  ;AND STAK4
;
;
;
; .BEGIN PROGRAM
;
; LIST OFF
; INCLUDE B:BANK2.ASM
;
;
; LIST OFF
; INCLUDE B:BANK3.ASM
;
;
; LIST OFF
; INCLUDE B:BANK4.ASM
;
;
; LIST OFF
; INCLUDE B:BANK1.ASM
;
;
; LIST OFF
 IFNCONST BURN
;  JUMP VECTORS FOR UNIV.ASM DURNING DEVELOPMENT
; BK3
 ORG BANK3+$FCC
 JMP BANK2+$FCF
 JMP BANK1+$FD2
 JMP BANK4+$FD5
 ORG BANK3+$FEA
 JMP BANK2+$FED
 JMP BANK4+$FF0
; BK1
 ORG BANK1+$FCF
 JMP BANK4+$FD2
 ORG BANK1+$FD5
 JMP BANK3+$FD8
 ORG BANK1+$FDE
 JMP BANK2+$FE1
 ORG BANK1+$FF0
 JMP BANK3+$FF3
; BK4
 ORG BANK4+$FD2
 JMP BANK3+$FD5
 ORG BANK4+$FD8
 JMP BANK1+$FDB
 ORG BANK4+$FE4
 JMP BANK3+$FE7
 ORG BANK4+$FEA
 JMP BANK1+$FED
 JMP BANK3+$FF0
; BK2
 ORG BANK2+$FCC
 JMP BANK1+$FCF
 ORG BANK2+$FD5
 JMP BANK3+$FD8
 ORG BANK2+$FDE
 JMP BANK4+$FE1
 ORG BANK2+$FE4
 JMP BANK4+$FE7
;   DEFINE PC (FOR DEVELOPMENT SYSTEM)
 ORG $9C04
 DW INIT
;   FOR HALT DURING VBLANK
 ORG HACKCLI
 CLI
 ORG HACKSEI
 SEI
 ENDIF

;.END

; bank 1
       seg bank1
       ORG $0000
       rorg $f000
DIVTB1 
       .byte $08,$03,$02,$01,$01,$01,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $0C,$08,$05,$13,$13,$12,$12,$22
       .byte $22,$31,$41,$51,$61,$71,$80,$F0
       .byte $0E,$09,$18,$16,$14,$24,$23,$33
       .byte $32,$42,$62,$72,$82,$91,$91,$F1
       .byte $0F,$0B,$19,$18,$26,$25,$34,$34
       .byte $43,$63,$73,$82,$92,$92,$A2,$F2
       .byte $0F,$1C,$19,$28,$38,$37,$46,$45
       .byte $54,$74,$83,$93,$A3,$A3,$B2,$F2
       .byte $0F,$1D,$1B,$29,$38,$48,$47,$56
       .byte $65,$85,$94,$A4,$B4,$B3,$C3,$F3
       .byte $0F,$1E,$2B,$3A,$39,$48,$58,$67
       .byte $76,$95,$95,$A4,$B4,$C4,$D3,$F3
       .byte $0F,$1F,$2C,$3A,$49,$59,$68,$78
       .byte $87,$96,$A6,$B5,$C5,$D4,$E4,$F4
ZOOMTB 
       .byte $0F,$7F,$5D,$4B,$3A,$29,$29,$28
       .byte $28,$17,$17,$16,$15,$15,$15,$04
       .byte $1F,$0F,$1E,$0B,$9A,$89,$99,$89
       .byte $08,$18,$07,$07,$06,$16,$05,$05
       .byte $8F,$8F,$9C,$8C,$0B,$0A,$09,$09
       .byte $08,$18,$08,$07,$07,$06,$06,$05
       .byte $0F,$0F,$1F,$0C,$0B,$0A,$0A,$09
       .byte $89,$88,$88,$88,$07,$07,$06,$06
       .byte $9F,$8F,$8F,$8D,$0C,$0B,$0A,$09
       .byte $89,$89,$88,$88,$08,$07,$07,$06
       .byte $0F,$0F,$0F,$0E,$8C,$8B,$8A,$9A
       .byte $09,$09,$09,$08,$08,$08,$07,$07
       .byte $0F,$0F,$0F,$0E,$0C,$0B,$0A,$0A
GRATB7 
       .byte $09,$09,$89,$08,$88,$08,$08,$07
       .byte $8F,$8F,$0F,$0F,$8D,$0C,$8B,$8A
       .byte $0A,$89,$89,$89,$88,$88,$88,$88
;
;
;
;   SUBROUTINES FOR BANK 1
NEWOB1
;  SUB.
       STY    IQSTAK
NEWOB2
; GTO
       STA    IQPNTR 
;
NEWOBJ
       LDY    IQPNTR 
       LDA    TYPTAB,Y
       BMI    NEWOB3
       STA    PNTR3 
       LDA    #>NEWOB1
       STA    PNTR3+1 
       CLC
       LDA    TYPTAB+1,Y
       JMP.ind (PNTR3)
NEWB55
;  EMP
       CMP    HGRAP0+3
       JMP    NEWB62
NEWB78
;  RNW
       CMP    RANDOM 
NEWB62
       LDA    TYPTAB+2,Y
       BCC    NEWB61
       BCS    NEWOB2  ;JMP
NEWB50
;  LVS
       ADC    NEWAVE 
       TAX
       LDA    NEWT11,X
       STA    IQREAP 
       JMP    NEWOB7
NEWB51
;  BRN
       DEC    IQREAP 
       BPL    NEWOB2
       BMI    NEWOB7  ;JMP
NEWOB5
;  RET
       LDY    IQSTAK 
       LDA    #$00 
       STA    IQSTAK 
       BEQ    NEWOB7  ;JMP
NEWB81
;  INL
       LDA    LIVES 
       CMP    #$05 
       BCS    NEWOB8
       INC    LIVES 
       BCC    NEWOB8  ;JMP
NEWB41
;  STO
       TAX
       LDA    #$00 
       BEQ    NEWB60  ;JMP
NEWOB4
;  ENB
       TAX
       LDA    0,X
NEWB60
       ORA    TYPTAB+2,Y
NEWB54
       STA    0,X
NEWB61
       INY
NEWOB7
       INY
NEWOB8
       INY
       STY    IQPNTR 
NEWB58
       RTS
NEWB40
;  RND
       LDA    RANDOM 
       AND    #$03 
       ADC    TYPTAB+1,Y
       TAY
       LDA    NEWTB7-$E0,Y
;  FALL THRU TO NEWOB3
;    EQUATES ****
SUB EQU <NEWOB1
GTO EQU <NEWOB2
ENB EQU <NEWOB4
STO EQU <NEWB41
RET EQU <NEWOB5
RNW EQU <NEWB78
LVS EQU <NEWB50
RND EQU <NEWB40
BRN EQU <NEWB51
EMP EQU <NEWB55
INL EQU <NEWB81
;
;
NEWOB3
;  BEGIN LOAD
       CMP    #$E0
       BCS    NEWOB8  ;2ND BYTE OF RND
       CMP    #$A8    ;?
       BCS    NEWB94
       LDY    IQWARP 
       CPY    #$F1 
       BCS    NEWB94
       LDA    #$CB    ;TOO FAST
NEWB94
       STA    TEMP10 
       LDY    #$05 
       STY    TEMP4 
NEWB18
       LDA.wy HGRAP0-2,Y
       ASL
       BPL    NEWB19
       DEC    TEMP4 
NEWB19
       DEY
       BNE    NEWB18
       BIT    PROGST 
       BVC    NEWB13
;  PLANET/TRENCH
       LDX    #$03 
       LDA    TEMP10 
       AND    #$04 
       BEQ    NEWB52
       INX    ;LZ OR MAN
NEWB52
       LDA    TEMP10 
       AND    #$03 
       CMP    TEMP4 
       BCS    NEWB48
       LDA    #$CB 
       STA    TEMP10    ;CRATER DEFAULT
NEWB48
       LDA    HGRAP0-1,X
       CMP    #PBLK
       BNE    NEWB58 ;ABORT
       LDA    HVERP0-2,X
       CMP    #$4E 
       BCS    NEWB58 ;ABORT
       LDA    TEMP10 
       AND    #$7C 
       CMP    #$40 
       BCC    NEWB93
       LDA    PROGST 
       SBC    #$08   ;C=1
       AND    #$68   ;40=PLN, 28=TRN
NEWB93 
       STA    HGRAP0-1,X
       LDA    #$56 
       STA    HVERP0-1,X
       CPX    #$04 
       BEQ    NEWB53 ;LZ OR MAN
       LDY    #$04 
NEWB11
       JMP    NEWB10
NEWB53
       LDA    #AUDMAN-J
       STA    CH1SHD 
       LDY    NEWAVE 
       BEQ    NEWB11  ; EASY JUMP
       JMP    NEWB29
;
NEWB13
       LDA    HGRAP0-2,X
       SBC    #$21 
       CMP    #$07 
       BCS    NEWB74
;  DARTER
       TXA
       TAY
       DEX
       JSR    BRAN22
       SBC    #$03 
       STA    HVERP0-1,X
       BCC    NEWB16    ;ABORT
       LDA    #AUDLNH-J
       STA    CH1SHD 
       LDA    #$14 
       STA    HGRAP0-1,X
       JMP    NEWB92
NEWB74
       LDA    TEMP10 
       AND    #$03 
       CMP    TEMP4 
       BCS    NEWB20
;  MOON FORCE STUFF
       LDY    SWAPT1-1,X
       BEQ    NEWB21
       LDA.wy HGRAP0-1,Y
       AND    #$7F 
       CMP    #$28 
       BCS    NEWB21
NEWB16
;  ABORT
       LDA    #PBLK
       STA    HGRAP0-1,X
       RTS
NEWB21
       LDA    #$02 
       CMP    TEMP4 
       BCC    NEWB16  ;ABORT
       LDA    #$CB   ; MOON1 NOINC IQPNTR
       STA    TEMP10 
NEWB20
; DEFINE GRAPHIC
       LDA    TEMP10 
       AND    #$7C 
       CMP    #$40 
       BNE    NEWB71
       EOR    NEWTB8-1,X  ;RINGS
NEWB71
       STA    HGRAP0-1,X
;  VERTICAL
       LDA    #TOPSCN
       CPX    #$04 
       BCS    NEWB24
       LDA    HGRAP0,X
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       AND    #$3F 
       EOR    #$FF 
       ADC    HVERP0+0,X   ;C=0
NEWB24
       STA    TEMP4  ;MAX
       LDA    #$00 
       CPX    #$02 
       BCC    NEWB25
       LDA    HVERP0-2,X
       ADC    #$07   ;C=1
NEWB25
       STA    TEMP5  ;MIN
       CMP    TEMP4 
       BCS    NEWB16  ;ABORT
       ADC    TEMP4 
       ROR
       STA    HVERP0-1,X   ;DEFAULT
       LDY    RANDOM 
       LDA    NEWOB3,Y  ;RANDOM CODE
       AND    #$0F 
       ADC    NEWTB1,X
       CMP    TEMP5 
       BCS    NEWB26
       CMP    TEMP4 
       BCC    NEWB26
       STA    HVERP0-1,X
NEWB26
       LDA    TEMP10 
       CMP    #$92 
       BNE    NEWB27
; WARPERS
       LDA    HVERP0-1,X
       CMP    HVERP0-2 
       BCC    NEWB16  ;ABORT
       CMP    #TOPSCN-$10
       BCS    NEWB16
       STA    HVERP1+3
       LDA    #$08 
       STA    HHORP1+3 
       STA    ZPOSP0-1,X
       STA    ZPOSP0-1 
       LDA    #AUDJMP-J
       STA    CH1PTR 
       LDA    #$98 
       STA    HHORP0-1,X
       LDA    #$00 
       STA    ZDELP0-1,X
       STA    ZDELP0-1 
       LDA    #$05 
       STA    YDELP0-1,X
       STA    YDELP0-1 
       LDA    #$10 
       STA    HGRAP1+3 
       LDA    #$0D 
       STA    XDELP0-1 
       LDA    RANDOM 
       AND    #$03 
       ORA    #$10 
       BNE    NEWB28  ;JMP
NEWB27
       CMP    #$A8 
       BCC    NEWB76
;   MOONS
;  MOON ZPOS
       LDY    #$28 
       LDA    IQWARP 
       ADC    #$1F    ;C=1
       BPL    NEWB69
       LDY    #$18 
NEWB69
       STY    ZPOSP0-1,X
;  MOON HPOS
       LDA    RANDOM 
       LSR
       ADC    #$10 
       ADC    CENTER 
       ROR
       JMP    NEWB31
NEWB76
;  SPACE GUYS ONLY
;  WANDER STUFF
       LSR
       LSR
       LSR
       AND    #$07 
       TAY
       LDA    NEWAVE 
       BEQ    NEWB29  ;NO WANDER
       ASL    GAMEST 
       BCS    NEWB91
       LDA    RANDOM 
       CMP    NEWTB5,Y
NEWB91
       ROR    GAMEST 
NEWB29
;   ENTRY FROM LZ
; SHIP ZPOS
       LDA    GAMEST 
       AND    #$03 
       TAY         ;JMP QUALITY
NEWB10
;  ENTRY FROM PLANET GUYS
       LDA    NEWTB3,Y
       STA    ZPOSP0-1,X
; SHIP HPOS
       LDA    RANDOM 
       AND    NEWTB4,Y
       ADC    NEWT10,Y
       LSR
       BCC    NEWB32
       EOR    #$FF 
NEWB32
       ADC    CENTER 
NEWB31
       STA    HHORP0-1,X
       LDA    RANDOM 
       AND    #$0F 
       ADC    ZPOSP0-1,X
       STA    ZPOSP0-1,X
       LDA    IQWARP 
       BPL    NEWB70
       CMP    #$F0 
       BCS    NEWB70
       LDA    #$10 
NEWB70
       AND    #$1F 
       STA    ZDELP0-1,X
       LDA    #$00 
       STA    YDELP0-1,X
NEWB28
       STA    XDELP0-1,X
       LDA    TEMP10 
       CMP    #$CB 
       BEQ    NEWB92   ;NO INC IQPNTR
       INC    IQPNTR 
NEWB92
       LDA    RANDOM 
       LDY    PROGST 
       CPY    #$40 
       BNE    NEWB44
       LDY    #$4C 
       STY    HHORP0-1,X
       BNE    NEWB43   ;JMP
NEWB44
       AND    #$09 
       ORA    #$C0 
NEWB43
       STA    IQPATH-1,X
NEWB75
       RTS
;
;
;
GRATB3
       .byte $00,$02,$02,$FA,$FB,$FA,$FB,$FF
;
;
BRAIN
;  EVERY FRAME
       LDA    PROGST 
       AND    #$30  ;CHART,HYPER
       BNE    BRAN99
;    EXCHANGE REQUEST
       BIT    PROGST 
       BVS    BRAN20  ;PLANET/TRN
       LDA    REQUST 
       BEQ    BRAN20
       AND    #$07 
       TAX
       BIT    REQUST 
       BMI    BRAN17
       BVS    BRAN19
;  SIMPLE EXCHANGE
       LDA    HVERP0-1,X
       SEC
       SBC    #$02 
       STA    HVERP0-1,X
       INX
       JSR    EXCHN1
BRAN99
       RTS
BRAN19
       LDA    HGRAP0-1,X
       BPL    BRAN18
       LDA    HVERP0+0,X
       CLC
       ADC    #$03 
       STA    HVERP0-1,X
       INX
       JMP    EXCHNG
BRAN18
       AND    #$7F 
       TAY
       AND    #$78 
       CMP    #$38 
       BEQ    BRAN20   ;EXPLOSION
       LDA    ZOOMTB,Y
       BMI    BRAN20  ;SIZE=X2
       LDA    BRNTB6,Y
       AND    #$3F 
       CLC
       ADC    HVERP1+2
       CMP    HVERP0-1,X
       BCS    BRAN10  ;TOO LOW
       LDA    HGRAP1+3 
       CMP    #PBLK
       BNE    BRAN20
       LDA    YDELP0+1,X
       CMP    #$10 
       BCC    BRAN14
       LDA    #$1A  ;DOWN
       STA    YDELP0+1,X  ;ALSO WRITES IN ZDEL P1+3
BRAN14
       LDY    #$00 
       LDA    #$01 
       STA    ZDELP0-1,X
       LDA    #$08    ;UP
       STA    YDELP0-1,X
       JSR    BRAN22      ;SWAP
BRAN17
       TXA
       TAY
       INX
       LDA    #$18  ;DOWN
       STA    YDELP0-1,X
       JMP    BRAN29   ;SWAP
BRAN10
       LDA    ZPOSP1+1 
       CMP    #$20 
       BCC    BRAN20
       LDA    #$80 
       STA    ZPOSP1+1   ;COSMETIC?
BRAN20
;
;
       LDA    PROGST 
       AND    #$83 
       BNE    BRAN99
;  ONE GUY PER FRAME SECTION
;
       LDA    ATRACT 
       AND    #$0F 
       BNE    BRAN52
       BIT    PROGST 
       BVS    BRAN54  ;TRN/PLN
       LDY    HVERP0+0 
       BNE    BRAN54
; ROTATE DOWN
       LDX    #$02 
       JSR    EXCHNG
       INX
       JSR    EXCHNG
       INX
       JSR    EXCHNG
       LDA    #$EF 
       STA    HVERP0+3 
       RTS
BRAN54
       JMP    BRAN70
BRAN52
       CMP    #$03 
       BNE    BRAN54
;  PHOTON FIRE LOGIC
       LDA    HVERP1  ;MAN DIEING
       BEQ    BRAN63
       LDA    ZPOSP0 
       CMP    #$50 
       BCS    BRAN63
       LDY    NEWAVE 
       CMP    BRNT15,Y
       BCC    BRAN63
       LDY    HGRAP0 
       BMI    BRAN63
       STA    TEMP13
       BIT    PROGST 
       BVC    BRAN49
       LSR    TEMP13
       LDA    BRNTB9,Y  ;TRN/PLAN
       TAY
       AND    #$1F 
       ADC    #$03    ;C=1 JUMP UP FIX
       STA    TEMP4 
       TYA
       LDY    #$15 
       AND    #$40 
       BNE    BRAN51
BRAN63
       JMP    BRAN64
BRAN49
       LDA    BRNTB6,Y
       CMP    #$C0 
       AND    #$3F 
       STA    TEMP4 
       BCC    BRAN63
       LDA    HVERP0+0 
       SBC    #$30 
       CMP    #$28 
       BCS    BRAN63
       LDY    #$18 
BRAN51
       STY    TEMP12
       LDX    #$03 
       LDY    #$04 
       BIT    HGRAP0+3 
       BVS    BRAN81
       BIT    HGRAP0+2
       BVC    BRAN64
       DEX
       DEY
; FIRE
BRAN81
       JSR    BRAN22   ;SWAP
       DEY
       DEX
       BNE    BRAN81
       LDA    #$37 
       STA    HGRAP0 
       LDA    TEMP12
       STA    ZDELP0 
       LDX    #$00 
       STX    YDELP0 
       LDA    CENTER 
       SBC    HHORP0 
       BCS    BRAN83
       EOR    #$FF 
       INX
BRAN83
       LSR
       LSR
       LSR
       LDY    #$0F 
BRAN65
       ADC    #$02 
       CMP    TEMP13  ;ZPOSP0+0 
       BCS    BRAN66
       DEY
       BNE    BRAN65
BRAN66
       INY
       TYA
       LDY    NEWAVE 
       CMP    BRNT10,Y
       BCC    BRAN82
       LDA    BRNT10,Y
BRAN82
       EOR    BRNT14,X
       STA    XDELP0 
       LDA    HVERP0+1
       SEC
       SBC    TEMP4 
       ADC    #$03    ;C=1 ,ADD 4
       STA    HVERP0+0 
LSOUN2
;  ENTRY
       LDY    #AUDSHT-J
LSOUND
       LDA    CH1PTR 
       LSR
       BNE    LSOUN1
       STY    CH1PTR 
LSOUN1
       RTS
BRAN64
       LDA    #$03 
;  ROTATE STUFF
       LDY    HVERP0+3
       CPY    #$F0 
       BCC    BRAN70
       LDA    PAUTIM 
       BNE    BRAN70   ;FIX EXPLOS JMP UP BUG?
; ROTATE UP
       LDX    #$04 
       JSR    EXCHNG
       DEX
       JSR    EXCHNG
       DEX
       JSR    EXCHNG
       LDA    #$01 
       STA    HVERP0+0 
       RTS
BRAN70
       AND    #$03 
       TAX
       INX
;
;  IQ STUFF
;    SETUP FOR ZOOM
       LDY    #$FF 
       LDA    ZPOSP0-1,X
       LSR
       LSR
       STA    TEMP4  ;ZOOM Z VAL 
       CMP    #$10 
       LDA    #$00  ;NO ZOOM
       BCS    BRAN40
       LDA    ZDELP0-1,X
       ASL
       ASL
       ASL
       ASL
       BCC    BRAN41
       LDY    #$00 
       EOR    #$F0 
BRAN41
       BPL    BRAN40
       LDA    #$70 
BRAN40
       STA    TEMP5  ; ABS. ZDEL, ZOOM
       STY    PNTR1  ; ZDEL SIGN, ZOOM
;
       LDA    HGRAP0-1,X
       AND    #$78 
       LSR
       LSR
       TAY
       BIT    PROGST 
       BVC    BRAN43
       INY   ;PLANET/TRN
BRAN43
       LDA    BRNTB4,Y
       STA    PNTR4 
       LDA    #>BRAN32
       STA    PNTR4+1
       LDA    SHIPST 
       AND    #$30 
       BEQ    BRAN58
       LDA    HGRAP0-1,X  ;DOING TAKEOFF
       BPL    BRAN47
       LDA    #PBLK
       STA    HGRAP0-1,X
BRAN58
       LDA    #$27 
       CMP    HGRAP0-1,X
       LDA    GAMEST 
       BPL    BRAN56
;   WANDER
       BCC    BRAN47   ;NOT VISIBLE
       AND    #$7F 
       STA    GAMEST 
BRAN47
       TYA
       EOR    GAMTIM
       AND    #$03  ;RANDOM PATH
       BPL    BRAN55   ;JMP
BRAN56
       LDA    IQPATH-1,X
       AND    #$07 
       CLC
       ADC    BRNT11,Y
BRAN55 
       STA    TEMP13   ;PATH PNTR
       LDA    #$00 
       JMP.ind (PNTR4)
;
;
BRAN36
;  PHOTON TYPE
       STA    JOYRMV
       JMP    BRAN38
;
BRAN31
;  BLOCK TYPE
       LDA    ZPOSP0-1,X
       BNE    BRAIN7
       JSR    LSOUN2
BRAIN7
       LDA    NEWAVE 
       ADC    #$03    ;C=0
       LDY    HHORP0-1,X
       CPY    CENTER 
       BCC    BRAN15
       EOR    #$FF 
;
BRAN15
;  MOON TYPE
       STA    JOYRMH
       LDA    IQWARP 
       CMP    #$80 
       ROR
       SEC
       SBC    #$02 
       TAY
       CPY    #$F7 
       BCC    BRAN48
;  SPECIAL MOON ZDEL FIX
       LDA    BRNTB8-$F7,Y
       STA    TEMP5 
       TYA
BRAN48
       JSR    ZHELP2
       LDA    ZDELP0-1,X
       JSR    POSTH1
       STA    ZDELP0-1,X
;
; XDEL MOON
       SEC
       LDA    HHORP0-1,X
       SBC    CENTER 
       JSR    DIVIDE
BRAN35
       CLC
       ADC    JOYRMH
       JSR    PREHL5   ;PACK
       LDA    XDELP0-1,X
       JSR    POSTH1
       STA    XDELP0-1,X
;
; YDEL MOON
BRAN38
       SEC
       LDA    HVERP0-1,X
       SBC    #VCENT
       JSR    DIVIDE
       CLC
       ADC    JOYRMV
       JSR    PREHL5  ;PACK
       LDA    YDELP0-1,X
       JSR    POSTH1
       BCC    BRAIN2  ;JMP
;
BRAN30
; PBLK TYPE
       STA    ZDELP0-1,X
       STA    XDELP0-1,X
BRAIN2
       STA    YDELP0-1,X
BRAN42
; WARP GRA TYPE
       JMP    BRAN46
;
BRN100
;  TRN TOWER
       LDA    IQPATH-1,X
       AND    #$E0 
       STA    IQPATH-1,X
BRAN32
; PLANET TYPE
       LDA    IQWARP 
       JSR    ZHELP1  ;SLOW AND PACK
       LDA    ZDELP0-1,X
       JSR    POSTH1
       STA    ZDELP0-1,X
       LDA    #$00 
       LDY    PROGST 
       CPY    #$40 
       BNE    BRAN35
;  TRENCH
       STA    TEMP10   ;A=0
       LDA    #$F9 
       SBC    IQWARP   ;C=1
       STA    TEMP7   ;MAX SPEED
       LDA    #$4C 
       BCC    BRAN89
       LDY    ZPOSP0-1,X
       CPY    #$54 
       BCS    BRAN89
       LDA    IQPATH-1,X
       LSR
       LSR
       ADC    #$2B 
BRAN89
;  A=DEST
       JMP    BRAN21
;
BRAIN9
;  DARTER
       LDA    HGRAP0-1,X
       CMP    #$14 
       BCC    BRAN42   ;WARP IN
;
BRAN11
;  SHIP TYPE
       LDA    PROGST 
       CMP    #$40 
       BEQ    BRN100  ;TRENCH
;    PATH LOGIC
       STY    TEMP11
       LDY    TEMP13 
       LDA    ATRACT 
       AND    #$FC 
       CMP    #$F0 
       BEQ    BRAN73  ;RE-SYNC
       AND    #$04 
       BNE    BRAN72
BRAN73
       ORA    IQPATH-1,X
       CLC
       ADC    #$10 
       STA    IQPATH-1,X
       BCC    BRAN72
       LDA    BRNTB1,Y
       LSR
       LDY    TEMP11
       BCS    BRAN74
;  INC PATH
       SEC
       LDA    BRNT12,Y
       AND    #$F0 
       ADC    IQPATH-1,X
       JMP    BRAN75
BRAN74
;  NEW PATH
       LDA    BRNT13,Y   ;MASK
       BPL    BRAN78
       STA    HGRAP0-1,X   ;DARTER OFF
       JMP    BRN105   ; NEWOBJ?
BRAN78
       AND    RANDOM 
       ORA    BRNT12,Y
       CPY    #$06    ;WARPER
       BNE    BRAN75
       LDY    NEWAVE 
       SBC    BRNT16,Y   ;C=1
BRAN75
       STA    IQPATH-1,X
BRAN72
; ZDEL STUFF
       LDA    IQWARP 
       CLC
       ADC    #$07 
       STA    TEMP10 
       LDY    TEMP13
       LDA    BRNTB1,Y
       TAY
       AND    #$0F 
       STA    TEMP7 
       TYA
       BMI    BRAN87
       LDY    NEWAVE 
       CMP    BRNT17,Y
       BCC    BRAN87
       LDA    BRNT17,Y
BRAN87
       SEC
       SBC    ZPOSP0-1,X
       JSR    ZHELP
       SEC         ;DEFINE C=TYPE 2
       LDA    ZDELP0-1,X
       JSR    POSTHP
       JSR    POSTHP   ;TWICE FOR TYPE 2 MOTION
       STA    ZDELP0-1,X
;
; FROM BEHIND KLUDGE FIX
       AND    #$1F 
       CMP    #$10 
       BCS    BRAN12
       LDA    ZPOSP0-1,X
       CMP    #$F8 
       BCC    BRAN12
       LDA    HHORP0-1,X
       CMP    #$50 
       LDA    #$A0 
       BCS    BRAN13
       LDA    #$00 
BRAN13
       STA    HHORP0-1,X
BRAN12
;
;  XDEL STUFF
       SEC
       LDA    HHORP0-1,X
       SBC    CENTER 
       JSR    DIVIDE   ;ZOOM
       CLC
       ADC    JOYRMH   ;JOYSTK
       ADC    JOYRMH   ;ADD TWICE
       STA    TEMP10 
       LDY    TEMP13
       LDA    BRNTB2,Y
       STA    TEMP12
       LDA    BRNTB3,Y
       AND    #$0F 
       STA    TEMP7 
       CPY    #PH6-Q
       BCC    BRAIN1
       LDA    RANDOM   ;HWARPER 
       AND    #$20 
       BCS    BRAN69   ;JMP
BRAIN1
       LSR
       LDA    IQPATH-1,X
       AND    #$08 
       BEQ    BRAN69
       LDA    #$FF     ;REFLECT
BRAN69
       EOR    BRNTB3,Y
       BCS    BRAN62
       ADC    #$50 
       JMP    BRAN21
BRAN62
       ADC    CENTER 
BRAN21
       LDY    RTIMER
       CPY    #$0A 
       BCS    BRN101
       RTS       ;ABORT
BRN101
       SEC
       SBC    HHORP0-1,X
       JSR    PREHLP
       LSR    TEMP12  ;DEFINE C
       LDA    XDELP0-1,X
       JSR    POSTHP
       STA    XDELP0-1,X
;
;  YDEL STUFF
       SEC
       LDA    HVERP0-1,X
       SBC    #VCENT
       JSR    DIVIDE   ;ZOOM
       CLC
       ADC    JOYRMV
       ADC    JOYRMV  ;TWICE WHY?
       STA    TEMP10 
       LDA    TEMP12
       ASL
       TAY
       AND    #$0F 
       STA    TEMP7 
       TYA
       SEC
       SBC    HVERP0-1,X
       JSR    PREHLP
       LDA    YDELP0-1,X
       LDY    PAUTIM 
       CPY    #$01   ;C=0=TYPE 1
       JSR    POSTHP
       STA    YDELP0-1,X
;
BRAN46
;
;  SWAP LOGIC
       LDA    HGRAP0-1,X
       CMP    #PBLK
       BNE    BRAN23
BRN105
; EMPTY
       LDY    HGRAP1+3
       BPL    BRAN24
       CPY    #PBLK
       BNE    BRAN26
BRAN50
       JMP    NEWOBJ
BRAN26
;  OFF SCREEN
       LDA    HVERP1+3
       CMP    #TOPSCN
       BCC    BRAN98
BRAN16
       CPX    #$04 
       BEQ    BRAN85
       TXA
       TAY
       INX
       JSR    BRAN29
       JMP    BRAN16
BRAN24
; ONSCREEN
       CPY    #$48   ;SATURN STUFF
       BCS    BRAN50
       LDA    BRNTB6,Y
       AND    #$3F 
       CLC
       ADC    HVERP0-2,X  ;NO LOAD P0+0 BUG
       BCS    BRAN98  ;OOPS LOOK OUT!
       CMP    HVERP1+3
       BCS    BRAN98
       CPX    #$04 
       BCS    BRAN85
       LDA    HGRAP0,X
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       AND    #$3F 
       ADC    HVERP1+3    ;C=0 
       CMP    HVERP0,X ;2PBLKS IN A ROW
       BCC    BRAN85
       LDA    HGRAP0-2,X
       CMP    #PBLK
       BNE    BRAN98
       TXA
       TAY
       INX
       BCS    BRAN22  ;C=1,JMP SWAP
BRAN85
       LDA    #$80 
       STA    YDELP0-1 
       TXA
       TAY
       LDX    #$00 
       BEQ    BRAN22  ;JMP SWAP
;
BRAN23
; FULL OBJ
;  VISUAL SWAP STUFF ??
       LDY    SWAPT5-1,X
       BIT    PROGST 
       BVC    BRAN59
;  PLANET/TRN
       LDA    ZPOSP0-1,X
       CMP    #$77 
       BCS    BRAN25
       LDA.wy HGRAP0-1,Y
       CMP    #PBLK
       BEQ    BRAN29
BRAN98
       RTS

BRAN59
       LDA    HVERP0-1,X
       CMP    SWAPT2-1,X
       BCC    BRAN28
       CMP    SWAPT3-1,X
       BCC    BRAN25
       CPX    #$01 
       BEQ    BRAN61
       LDA    HGRAP0-1,X    ;1LINE JITTER FIX
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       BPL    BRAN61
       AND    #$3F 
       ADC    #$01     ;C=1
       ADC    HVERP0-2,X
       CMP    HVERP0-1,X
       BCS    BRAN25   ;  END FIX
BRAN61
       LDY    SWAPT4-1,X
BRAN28
       LDA.wy HGRAP0-1,Y
       CMP    #PBLK
       BEQ    BRAN29
       AND    #$7F 
       STX    TEMP4 
       TAX
       LDA    SWAPT1-1,Y
       BNE    BRAN25  ;Y NOT 1,4
       LDA    BRNTB6,X
       CMP    #$40    ;FIXES PHOTON OFF,ALSO
       BCS    BRAN25
       LDX    TEMP4 
BRAN29
;
BRAN22
;  DO SWAP
       LDA    HGRAP0-1,X
       STA.wy HGRAP0-1,Y
       LDA    #PBLK
       STA    HGRAP0-1,X
       LDA    ZDELP0-1,X
       STA.wy ZDELP0-1,Y
       LDA    XDELP0-1,X
       STA.wy XDELP0-1,Y
       LDA    YDELP0-1,X
       STA.wy YDELP0-1,Y
       LDA    IQPATH-1,X
       STA.wy IQPATH-1,Y
       LDA    HHORP0-1,X
       STA.wy HHORP0-1,Y
       LDA    ZPOSP0-1,X
       STA.wy ZPOSP0-1,Y
       LDA    HVERP0-1,X
       STA.wy HVERP0-1,Y
BRAN25
       RTS
;
;
;
HYPSRV
       LDX    HCOLP1+1 
       LDA    ZOOMTB,X
       STA    HOLDM0   ;FOR SHPSRV
       LDX    ZPOSP1 
       LDA    ZOOMTB,X
       STA    VECTP1
       LDX    ZPOSP1+1 
       LDA    ZOOMTB,X
       STA    VECTP1+1  ;PHOTONS
;
       LDX    #$01 
       LDA    PROGST 
       AND    #$10 
       BEQ    HYPSR1
HYPSR2
       LDY    ZDELP0,X
       LDA    ZOOMTB,Y
       LSR
       LSR
       LSR
       LSR
       AND    #$07 
       EOR    #$FF 
       SEC
       ADC    YDELP0,X
       BPL    HYPSR4
       LDA    #$00 
HYPSR4
       STA    YDELP0,X
       DEY
       BEQ    HYPSR3
       STY    ZDELP0,X
HYPSR3
       DEX
       BPL    HYPSR2
       RTS
HYPSR1
;  FALL THRU
;
;
GRAPH
;  ANIMATION HANDLER
;  X=1
       STX    TARNUM   ;DEFAULT
       LDX    #$04 
GRAPH1
       BIT    PROGST  ;DEFINE V FOR PLN/TRN
;   WARNING DONT REDEFINE V FLAG
       CPX    TEMP5 
       BCS    GRAPH2
       TXA
       BEQ    GRAPH2
       BVS    GRAPH3
;  VECTOR DOWN STUFF
       LDA    YDELP0-1,X
       EOR    #$1F 
       CMP    YDELP0-1,X
       BCC    GRAPH2  ;JMP GRAPH2
       STA    YDELP0-1,X
       BCS    GRAPH2   ;JMP GRAPH2
GRAPH3
;  PLN/TRN
       LDA    IQPATH-1,X
       ORA    #$03 
       STA    IQPATH-1,X
GRAPH2
       LDA    HGRAP0-1,X
       CMP    #PBLK
       BEQ    GRAPH4
       AND    #$7F 
       LDY    ZPOSP0-1,X
       CMP    #$40 
       BCS    GRAPH5
       CPY    TEMP6 
       BCC    GRAPH5
       STY    TEMP6 
       STX    TARNUM  ;NEW TARNUM
GRAPH5
;  OFFSCN CHECK
       CPY    #ZVIS
       BCS    GRAPH6
       LDY    HVERP0-1,X
       CPY    #TOPSCN
       BCS    GRAPH6
       LDY    HHORP0-1,X
       CPY    #$04    ;BIG MOONS FIX
       BCC    GRAPH6
       CPY    #$9C 
       BCS    GRAPH6
;  ONSCREEN
       STA    HGRAP0-1,X
       AND    #$78 
       STA    TEMP7 
       LSR
       LSR
       TAY
       BVC    GRAPH7
       INY   ;PLN/TRN
GRAPH7
       LDA    GRATB6,Y
       STA    PNTR4 
       LDA    GRATB7,Y
       ASL
       LDA    #[>GRAP23]/2
       ROL
       STA    PNTR4+1
       LDA    ZPOSP0-1,X
       BVC    GRAPH8
       TAY  ;PLN/TRN
       LDA    SURTB2,Y
       STA    TEMP12
       TYA
       LSR
GRAPH8
       LSR
       CMP    #$13 
       BCC    GRAPH9
       LDA    #$13 
GRAPH9
       TAY
       JMP.ind (PNTR4)
;
GRAPH6
;  OFFSCREEN
       ORA    #$87  ;DEFAULT SMALL SIZE
       CMP    #POFF
       BCC    GRAPH4
       BVS    GRAPH4
GRAP10
       LDA    #PBLK
GRAPH4
       STA    HGRAP0-1,X
       BVC    GRAP11
       LDY    ZPOSP0-1,X
       CPY    #ZVIS
       BCC    GRAP69
       LDY    #ZVIS-1
GRAP69
       LDA    SURTB2,Y
       STA    HVERP0-1,X
GRAP11
       JMP    GRAP12
;
GRAP20
;  RINGS
       LDA    HGRAP1+3 
       AND    #$7F 
       CMP    #$48 
       BCC    GRAP40
       LDA    #$48 
       STA    HGRAP1+3 
       LDA    HHORP0-1,X
       STA    HHORP1+3 
       LDA    ZPOSP0-1,X
       STA    ZPOSP0-1 
       LDA    HVERP0-1,X
       SBC    #$01    ;C=1
       STA    HVERP1+3
       CMP    #TOPSCN-3
       BCS    GRAP10   ;TURN OFF
GRAP40
       JMP    GRAP36
;
GRAP24
; PLNPIR
       LDA    TEMP4 
       JMP    GRAP70
GRAP26
;  BLOCK
       LDA    TEMP11
       JMP    GRAP65
GRAP23
;  SPACE FIGHT, ETC
       LDA    TEMP4 
GRAP65
       CPY    #$09  ;ZOOM ADJ
       BCC    GRAP61
       AND    #$01 
       CPY    #$0E  ;ZOOM ADJ
       JMP    GRAP60
GRAP21
;  MAN
       LDA    PROGST 
       AND    #$FD 
       CMP    #$40 
       BNE    GRAP22
;  IN TRENCH
       LDA    ATRACT 
       LSR
       BCC    GRAP22
       LDA    PNTR3  ;VERT
       ADC    #$04  ;C=1
       AND    #$FE 
       CMP    #$56 
       BCS    GRAP22
       CMP    #$0C 
       BCC    GRAP22
       STA    VWALL 
       LDA    GAMEST 
       LSR
       LDA    VWALL 
       BCS    GRAP54
       ADC    #$56 
       LSR
GRAP54
       STA    YDELP0-1 
       DEC    YDELP0-1  ;VWIND
;
GRAP22
;  TRN TOWER
       STX    TEMP5 
GRAP71
;  PLN FIGHT
       LDA    TEMP13
GRAP70
       CPY    #$11 
GRAP60
       BCC    GRAP61
       LDA    #$00 
GRAP61
       CLC
       ADC    GRATB4,Y
       BIT    PROGST 
       BVC    GRAP44  ;SPACE GUYS
       LSR
       LSR
       LSR
       LSR
GRAP44
       JMP    GRAP42
;
GRAP29
; WARNING: IN PAGE 8!
;  PLN PHOT
       LDA    HVERP0-1,X
       CMP    TEMP12
       BCS    GRAP41
       STA    TEMP12
GRAP41
       LDA    ATRACT 
       LSR
       AND    #$01 
       ORA    GRATB2,Y
       JMP    GRAP42
;
GRAP28
; WARINING: IN PAGE 9!
;  SPA PHOT
       TYA
       ORA    PAUTIM 
       BNE    GRAP41
       LDY    #EXPREG-EXPTAB
       STY    EXPNTR 
       LDA    #$20 
       STA    PAUTIM 
       LDA    #$3F 
       BNE    GRAP96   ;JMP
;
GRAP27
; DAR/WRPGRA
       LDA    HGRAP0-1,X
       CMP    #$14 
       BCC    GRAP46
;  DARTER
       LDA    #AUDVAR-J
       STA    CH0SHD 
       LDA    ATRACT 
       LSR
       LSR
       AND    #$01 
       ORA    #$04 
       CPY    #$10 
       BCC    GRAP42
       ORA    #$02 
       BCS    GRAP42  ;JMP
;
GRAP46
;  WARP GRA
       STX    TEMP5 
       LDY    HVERP1+3
       STY    HVERP0-1,X
       LDY    HHORP0-1,X
       CPY    HHORP1+3 
       BCS    GRAP43
       LDA    #PBLK
       STA    HGRAP1+3 
       LDA    #$00 
       STA    XDELP0-1,X
       LDA    #$18 
GRAP96
       BNE    GRAP43    ;JMP
;
GRAP30
;  MOONS
       LDA    GRATB1,Y
       CPX    #$01 
       BCS    GRAP47
       ADC    #$04    ;C=0
       LDY    #$A0 
       STY    ZPOSP0-1 
       BNE    GRAP66   ;JMP
GRAP47
       LSR
       LSR
       LSR
       LSR
GRAP66
       AND    #$0F 
       LDY    HGRAP0-1,X
       CPY    #$54 
       BCC    GRAP67
       ADC    #$0B    ;C=1
GRAP67
       ADC    #$48   ;C=0
       BNE    GRAP43  ;JMP
;
GRAP32
;  SPA EXPLOS
       STX    TEMP5 
GRAP33
;  PLN EXPLOS
       LDY    EXPNTR 
       LDA    EXPTAB,Y
       BMI    GRAP48
       DEY
       CMP    PAUTIM 
       BEQ    GRAP49
       BNE    GRAP50  ;JMP
GRAP48
       CMP    #PBLK
       BEQ    GRAP51
       LSR
       LSR
       LSR
       SEC
       SBC    #$18 
       CLC
       ADC    HVERP0-1,X
       STA    HVERP0-1,X
GRAP49
       INC    EXPNTR 
GRAP50
       LDA    EXPTAB,Y
       AND    #$07 
       TAY
       ORA    #$38 
GRAP51
       STA    HGRAP0-1,X
       BIT    PROGST 
       BVS    GRAP52
       LDA    EXPOFF,Y
       BVC    GRAP53  ;JMP
;
GRAP34
;  LZ
GRAP35
;  CRATER
       STX    TEMP5 
GRAP36
;  PKILLER,ETC.
       LDA    GRATB1,Y
GRAP42
       AND    #$07 
       ORA    TEMP7 
GRAP43
       STA    HGRAP0-1,X
       BIT    PROGST 
       BVC    GRAP97
;  PLN/TRN
       LDA    TEMP12
       STA    HVERP0-1,X
GRAP52
       LDY    HGRAP0-1,X
       CPY    #$40 
       LDA    GRATB3-$40,Y
       BCS    GRAP53
       LDA    BRNTB9,Y
GRAP55
       AND    #$80 
       BEQ    GRAP53
       LDA    #$FC 
GRAP53
       CLC
       ADC    HHORP0-1,X
       CMP    #$A0 
       BCC    GRAP56
       LDA    #$00 
GRAP56
       STA    HHITP0-1,X
GRAP12
       DEX
       BMI    GRAP68
       JMP    GRAPH1
GRAP68
       RTS

GRAP97
       TAY
       TXA
       BEQ    GRAP68
       LDA    ZOOMTB,Y
       BVC    GRAP55    ;JMP
;
;
;
;
;
;
;
CLOS35
;  PBLK
       LDA    HVERP0-1,X
       ADC    #$01    ;C=1
       JMP    CLOS36
CLOS33
       LDA    ZPOSP0-1,X
       ADC    #$10   ;C=0
       CMP    #$12 
       BCS    CLOS44
       LDA    HGRAP0-1,X
       AND    #$78 
       LDY    #ATTSB1-W   ;5 IN A ROW?
       CMP    #$18 
       BCC    CLOS42
       BNE    CLOS43    ;NOT MAN
       BIT    GAMEST 
       BVS    CLOS43    ; NOT ENEMY
       LDY    #$5F        ;ABORT ENEMY PLANET
CLOS42
       CPY    IQPNTR 
       BCS    CLOS43
       STY    IQPNTR 
CLOS43
       LDA    #PBLK
       STA    HGRAP0-1,X
CLOS44
       LDA    HGRAP0,X
       CMP    #PBLK
       BEQ    CLOS35
       AND    #$7F 
       TAY
       LDA    BRNTB9,Y
       AND    #$1F 
       ADC    HVERP0-1,X    ;C=0
       CMP    HVERP0+0,X
       BCC    CLOS31  ;NO ERROR
CLOS36
       STA    HVERP0,X
       CPX    #$03 
       BNE    CLOS51
       LDA    ZPOSP0+3
       CMP    #ZVIS-1
       BCS    CLOS31
CLOS51
       LDA    #$FF 
       STA    ZDELP0,X  ;NO MOVE DOWN
CLOS31
       LDA    HVERP0+0,X ;RESTORE
       CMP    PNTR3+1    ;FROM PLNSRV
       BCS    CLOS39
       STX    PNTRP1 
CLOS39
       INX
CLOS30
;  BEGIN PLANET/TRENCH
       LDA    BRNTB9,Y
       AND    #$20 
       BEQ    CLOS32
       LSR    HVERP0-1,X
       SEC
       ROL    HVERP0-1,X
CLOS32 CPX    #$4
       BNE    CLOS33
CLOS40
       RTS
;
CLOSE
       LDX    #$00    ;OLD TAX
       LDA    HVERP0+0 
       CMP    #$F3 
       BCC    CLOS77
       STX    HVERP0+0   ;FIX JUMP UP BUG
CLOS77
       STX    REQUST 
       STX    PNTRP1 
       INX
       LDA    HGRAP0 
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       STA    TEMP4 
       BNE    CLOS34
       STA    HVERP0+0 
CLOS34
       BIT    PROGST 
       BVS    CLOS30  ;PLN/TRENCH
;
;  P1+3 CHECK
       LDA    HGRAP1+3
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       AND    #$3F 
       STA    HOLDM0  ;FOR HITS
       CLC
       ADC    HVERP1+2
       CMP    HVERP1+3 
       BCC    CLOSE1
       STA    HVERP1+3 
       CPY    #$40 
       BCC    CLOSE1
       LDA    #PBLK  ;MOON OFF
       STA    HGRAP1+3
CLOSE21
;  P0 CHECK STUFF
;
CLOSE1
       LDA    HVERP0+0,X
       CMP    #TOPSCN
       BCS    CLOSE2  ;OFFSCRN
;  ON SCREEN
       LDA    HGRAP0,X
       AND    #$7F 
       TAY
       LDA    BRNTB6,Y
       TAY
       BEQ    CLOSE3  ;PBLK
       AND    #$3F 
       ADC    HVERP0-1,X   ;C=0
       CMP    HVERP0,X
       BCC    CLOSE4   ;NO ERROR
       STA    HVERP0+0,X
       CMP    #TOPSCN
       BCS    CLOSE5   ;WENT OFFSCRN
;  REQUEST LOGIC
       TYA
       BMI    CLOSE6
       BIT    TEMP4 
       BMI    CLOS11
       AND    #$40 
       BNE    CLOSE7
       BEQ    CLOSE4    ;JMP
CLOSE6
; TOP =NORMAL
       LDA    HGRAP0,X   ;NO SWAP IF OFFSCRN
       BMI    CLOSE4
       LDA    #$40 
       BIT    TEMP4 
       BMI    CLOSE8
       BVS    CLOSE4
CLOSE7
       LDA    #PBLK
       STA    HGRAP0-1,X
       LDA    #$80 
CLOSE8
       ORA    CLSTB1-1,X
       CMP    REQUST 
       BCC    CLOSE4
       STA    REQUST 
CLOSE4       
       STX    PNTRP1 
CLOSE9
       STY    TEMP4 
       INX
       CPX    #$04 
       BCC    CLOSE1
       RTS
CLOS10
       LDA    HVERP0+0,X
CLOSE2
       CMP    HVERP0-1,X
       BCS    CLOSE5
       LDA    HVERP0-1,X
       STA    HVERP0,X
       LDA    REQUST 
       BNE    CLOSE5
       LDA    CLSTB1-1,X
       STA    REQUST 
CLOSE5
       INX
       CPX    #$04 
       BCC    CLOS10
       RTS
CLOS11
       LDA    YDELP0,X
       AND    #$10 
       BEQ    CLOSE4
       LDA    #PBLK
       STA    HGRAP0,X
CLOSE3
       LDA    #$02 
       CLC
       ADC    HVERP0-1,X
       STA    HVERP0,X
       JMP    CLOSE9
;
;
;
;
;
;  TABLES
;
;
;
TYPTAB
W EQU TYPTAB  ;EQUATE
       .byte $00
;   SPACE TYPE GUYS
BLKTYP 
       .byte $CA,$CA,$D6,$D6
       .byte LVS,$00,$AB,$AB,BRN,BLKTYP+6-W
DONTYP
       .byte $A1
       .byte $C8,ENB,SHIPST,$01
MONTYP
       .byte STO,IQREAP,$04
       .byte $CA,$D6,$CA,$D6,$C2,BRN,MONTYP+3-W
       .byte $C8,ENB,GAMEST,$20,GTO,MONTYP-W
COBTYP
       .byte LVS,$0A,$92,BRN,COBTYP+2-W,GTO,DONTYP-W
PIRTYP
       .byte $89,LVS,$05,RNW,$C0,PIRTY1-W,$89,BRN,PIRTYP+6-W
       .byte GTO,DONTYP-W
PIRTY1
       .byte STO,GAMEST,$00,$8B,$8B,$8B,GTO,DONTYP-W
PLNTYP
       .byte $A1,LVS,$0A
PLNTY1
       .byte RNW,$20,PIRTY1-W,RND,$E0,BRN,PLNTY1+3-W,GTO,DONTYP-W
FIGTYP
       .byte $81,LVS,$05
FIGTY1
       .byte RNW,$20,PIRTY1-W,RND,$F0,BRN,FIGTY1+3-W,GTO,DONTYP-W
;   PLANET TYPES

FRNTYP
       .byte $A7,$9B,$C3,$C3,EMP,PBLK-1,FRNTYP+1-W,$C0,$C3
FRNTY1
       .byte $C3,ENB,GAMEST,$20
CRATYP
       .byte ENB,SHIPST,$10,$C3,GTO,CRATYP-W
TRNTYP
       .byte ENB,GAMEST,$02,$A7,$AB,EMP,PBLK-1,TRNTYP+4-W
       .byte $A8,GTO,FRNTY1-W
TRNTY1
       .byte STO,PROGST,$40,STO,GAMEST,$15
       .byte LVS,$0F,$9F,$AB,EMP,PBLK-1,TRNTY1+9-W
       .byte BRN,TRNTY1+8-W,$AB,$AB,$AB,$AB,$AB
       .byte ENB,PROGST,$08,$C0
BLOWT2
       .byte ENB,SHIPST,$41
BLOWIT
       .byte ENB,SHIPST,$50,GTO,CRATYP+3-W
;
HYPSUB
       .byte $92,$92,$92,RET
;
;  ENETYP 2ND LAST IN TYPTAB
ENETYP
       .byte LVS,$0F,$9F,RND,$E8,EMP,PBLK-1,ENETYP+3-W
       .byte BRN,ENETYP+2-W,$C0,INL,GTO,BLOWT2-W
;
;  ATTSUB IS LAST IN TYPTAB
ATTSUB
       .byte STO,HGRAP0+3,PBLK
ATTSB1
       .byte $C3,LVS,$14,RND,$EC,BRN,ATTSB1+3-W
       .byte $C0,ENB,SHIPST,$01,RET
;
;
CLSTB1 .byte $01,$02,$03
;  SHARE 1
SWAPT1 .byte $00,$01,$04
;  SHARE 1
SWAPT2 .byte $00,$32,$53,$72
SWAPT3 .byte $50,$53,$72,$FF
SWAPT4 .byte $02,$03,$04,$04
;
NEWTB1 .byte $78,$18,$38,$59,$76
NEWTB5 .byte $E0,$D0,$00,$00,$B0
NEWTB7
       .byte $A1,$81,$89,$CB,$A3,$8B,$83,$83
       .byte $8B,$83,$83,$C3,$8B,$83,$93,$93
       .byte $81,$81,$83,$8B
NEWT11 
       .byte $1E,$28,$37,$4B,$64
       .byte $00,$00,$01,$01,$02
       .byte $01,$02,$02,$03,$04
       .byte $00,$01,$01,$02,$04
       .byte $02,$04,$05,$05,$06
NEWTB3 .byte $84,$9E,$AE,$BE,$67
NEWTB4 .byte $3F,$3F,$1F,$1F,$7F
;
;
EXPTAB
EXPPLN .byte $C5,$1C,$C4,$19,$C3,$16,$C2,$13
       .byte $C1,$10,$C0,$0D,PBLK
EXPTRN
       .byte $C3,$1E,$C5,$C5,PBLK
EXPREG
       .byte $C7,$CE,$CD,$C4,$1A,$CB,$16,$CA
       .byte $11,$D1,$0C,$D0,$07,PBLK
EXPFAR
       .byte $C7,$1E,$CE,$C6,$CD,$C5,$C4,$15
       .byte $CB,$12,PBLK
;
;
;
BRNTB9
; BRNTB6 FOR PLANET
       .byte $52,$52,$52,$4F,$4F,$0F,$0C,$0A
       .byte $53,$13,$53,$51,$11,$51,$4E,$4B
       .byte $53,$53,$53,$51,$51,$51,$0E,$0B
       .byte $14,$14,$14,$11,$11,$11,$0E,$0B
       .byte $93,$91,$90,$8F,$0E,$0D,$0C,$0B
       .byte $13,$53,$13,$11,$51,$11,$4E,$0A
       .byte $10,$0F,$10,$0F,$0E,$0D,$0C,$0B
       .byte $B9,$B7,$B5,$B3,$11,$0F,$0F,$0F
       .byte $32,$30,$2E,$8D,$8C,$8B,$8B,$0A
;
BRNT15 
       .byte $1C,$14,$0C,$08,$04
BRNT16 
       .byte $60,$40,$30,$20
;  SHARE 1
BRNT10
; PHOT VECTORS
       .byte $00,$03,$06,$08,$0C
BRNT17
;  MAX Z GUYS
       .byte $18,$20,$28,$30,$38
;
BRNTB1
;  ZDELST
Q EQU BRNTB1  ;EQUATE
       .byte $01,$01,$01,$01
PH1    .byte $2E,$1A,$08,$13
PH2    .byte $F4,$F4,$F3,$F7
PH3    .byte $17,$26,$36,$FC,$3D
PH4    .byte $F2,$F2,$F3,$F7
PH5    .byte $20,$06,$06,$06,$07
PH7    .byte $24,$08,$18,$05
;  LAST IN TABLE
PH6    .byte $19,$0F,$09,$1A,$FF
;
BRNTB2 
; YDEST
       .byte $C4,$C4,$E4,$E4
       .byte $46,$3E,$3C,$38
       .byte $02,$02,$02,$02
       .byte $29,$39,$3B,$37,$3B
       .byte $01,$01,$01,$01
       .byte $0E,$2E,$1E,$0E,$0E
       .byte $2B,$55,$45,$55
       .byte $28,$38,$0A,$58,$48
;
BRNTB3
; XDEST
       .byte $74,$B4,$74,$B4
       .byte $DB,$1B,$18,$FC
       .byte $1D,$F9,$E4,$24
       .byte $1D,$FD,$FD,$28,$E8
       .byte $2E,$DE,$FF,$24
       .byte $C0,$2F,$CF,$FF,$0A
       .byte $DE,$19,$25,$ED
       .byte $1D,$ED,$FD,$0D,$FD
;
BRNT11 
       .byte PH1-Q,PH2-Q,PH3-Q,PH4-Q
       .byte PH5-Q,PH2-Q,PH6-Q,$00,PH7-Q
BRNT12
       .byte $80,$C0,$80,$40,$C0,$A0,$E0,$00,$70
BRNT13 
       .byte $08,$08,$09,$08,$E0,$0B,$0B,$00,$0B
;
;
;
SURTB2 
       .byte $02,$05,$08,$0B,$0E,$10,$13,$15,$17,$19,$1B,$1D,$1F,$20,$22,$24
       .byte $25,$27,$28,$29,$2B,$2C,$2D,$2E,$2F,$30,$31,$32,$33,$34,$35,$36
       .byte $37,$38,$39,$39,$3A,$3B,$3C,$3C,$3D,$3E,$3E,$3F,$40,$40,$41,$41
       .byte $42,$42,$43,$43,$44,$44,$45,$45,$46,$46,$47,$47,$47,$48,$48,$49
       .byte $49,$49,$4A,$4A,$4B,$4B,$4B,$4C,$4C,$4C,$4D,$4D,$4D,$4D,$4E,$4E
       .byte $4E,$4F,$4F,$4F,$4F,$50,$50,$50,$50,$51,$51,$51,$51,$52,$52,$52
       .byte $52,$52,$53,$53,$53,$53,$53,$54,$54,$54,$54,$54,$55,$55,$55,$55
       .byte $55,$55,$56,$56,$56,$56,$56,$56
;
;
GRATB6
       .byte <GRAP23,<GRAP71,<GRAP36,<GRAP24
       .byte <GRAP27,<GRAP71,<GRAP23,<GRAP21
       .byte <GRAP36,<GRAP34,<GRAP26,<GRAP22
       .byte <GRAP28,<GRAP29,<GRAP32,<GRAP33
       .byte <GRAP20,<GRAP35,<GRAP30,<GRAP35
       .byte <GRAP30,<GRAP35,<GRAP30,<GRAP35
;
;
NEWT10 .byte $00,$60,$C0,$DF
;  SHARE 2
GRATB1 
       .byte $00,$00,$00,$00,$11,$11,$11,$22
       .byte $22,$32,$33,$43,$43,$54,$64,$75
       .byte $85,$96,$A6,$B7
GRATB2 
       .byte $02,$02,$02,$02,$02,$02,$02,$04
       .byte $04,$04,$04,$06,$06,$06,$06,$06
       .byte $06,$06,$06,$06
;
NEWTB8 
       .byte $14,$08
;  SHARE 2
GRATB4 .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$03,$33,$33,$33,$33,$35,$35
       .byte $35,$66,$66,$77
;
;
;
BRNTB4 
       .byte <BRAN11,<BRAN11,<BRAN11,<BRAN11
       .byte <BRAIN9,<BRAN11,<BRAN11,<BRAN32
       .byte <BRAN11,<BRAN32,<BRAN31,<BRN100
       .byte <BRAN36,<BRAN36,<BRAN30,<BRAN30
       .byte <BRAN15,<BRAN32,<BRAN15,<BRAN42
       .byte <BRAN15,<BRAN42,<BRAN15,<BRAN42
       .byte <BRAN30,<BRAN30
;
BRNTB7 
       .byte $00,$01,$02,$03,$04,$05,$06,$07
       .byte $08,$08,$08,$08,$09,$09,$09,$09
       .byte $0A,$0A,$0A,$0A,$0B,$0B,$0B,$0B
       .byte $0C,$0C,$0C,$0C,$0D,$0D,$0D,$0D
       .byte $0E,$0E,$0E,$0E,$0F,$0F,$0F,$0F
BRNTB8
       .byte $70,$70,$70,$60,$50,$50,$50
;
BRNT20 
       .byte $01,$02,$02,$04,$05,$06,$06,$08
       .byte $08,$0A,$0A,$0C,$0C,$12,$12,$12
;
;
BRNTB6
;  OBJ SIZE AND MISC TABLE
       .byte $D5,$D4,$D3,$D2,$D0,$90,$8D,$8B
       .byte $92,$90,$90,$CE,$CD,$CC,$CB,$CA
       .byte $91,$91,$91,$91,$90,$90,$90,$90
       .byte $D3,$D3,$D3,$D1,$D1,$CF,$8C,$8A
       .byte $D5,$D5,$D3,$D3,$D0,$CE,$CC,$8A
       .byte $12,$12,$12,$10,$10,$0E,$0C,$0A
       .byte $50,$4F,$50,$4F,$4E,$4D,$4C,$4B
       .byte $A5,$A1,$9D,$99,$95,$93,$92,$91
       .byte $17,$15,$13,$11,$10,$0F,$0D,$0C
       .byte $21,$1F,$1B,$17,$14,$13,$10,$0F
       .byte $0E,$0D,$0B,$0A
       .byte $21,$1F,$1B,$17,$14,$13,$10,$0F
       .byte $0E,$0D,$0B,$0A
;  SHARE 1    NULL FOR PBLK
;
BRNTB5 .byte $00,$01,$02,$03,$04,$05,$06,$07
       .byte $08,$0C,$10,$14,$18,$1C,$20,$24
;
;
;
DIVIDE
       BPL    DIVID1  ;??? OR BCS MAYBE ???
' -VALUE
       EOR    #$FF 
       JSR    DIVID1
       EOR    #$FF 
       RTS
DIVID1
;  + VALUE
       ASL
       BCC    DIVID3
       LDA    #$F0   ;FOR A>127
DIVID3 
       AND    #$F0 
       ORA    TEMP4  ;Z VAL
       TAY
       LDA    DIVTB1,Y
       AND    #$0F 
       ORA    TEMP5  ;Z DEL
       TAY
       LDA    DIVTB1,Y
       LSR
       LSR
       LSR
       LSR
       TAY
       LDA    BRNTB5,Y  ;UNPACK VALUE
       EOR    PNTR1   ; -ZOOM
       RTS
;
;
;
ZHELP  
;  FOR Z ONLY
       LDY    #$00 
       STY    TEMP11
       CMP    #$70 
       BCC    ZHELP3
       DEC    TEMP11
ZHELP3 
       EOR    TEMP11
       CMP    TEMP7 
       BCC    ZHELP4
       LDA    TEMP7 
ZHELP4 
       EOR    TEMP11
       ROL    TEMP11
       ADC    TEMP10
; 
ZHELP1 
; SLOW DOWN
       LDY    ZPOSP0-1,X
       CPY    #ZVIS
       BCC    ZHELP2
       BIT    PROGST 
       BVS    ZHELP7   ;PLANET/TRENCH
       BIT    GAMEST 
       BMI    ZHELP7   ;WANDERING
       CPY    #$D0 
       BCS    ZHELP2
       LDA    #$FE 
       BNE    ZHELP8  ;JMP
ZHELP7 
       LDA    ATRACT 
       LSR
       LSR
       AND    #$01 
       ORA    #$FE   ;SLOW DOWN
ZHELP8 
       LDY    IQWARP 
       CPY    #$F6 
       BCS    ZHELP2
       SBC    #$01    ;GO A LITTLE FASTER  ,C=0
;
ZHELP2 
;  PACK Z
       TAY
       BMI    ZHELP5
       CMP    #$10 
       BCC    ZHELP6
       LDA    #$0F 
       BCS    ZHELP6  ;JMP
ZHELP5 
       CMP    #$F0 
       BCS    ZHELP6
       LDA    #$F0 
ZHELP6 
       AND    #$1F 
       STA    TEMP10 
ZHEL99
       RTS
;
;
;
PREHLP 
; FOR X AND Y ONLY
       LDY    #$00 
       STY    TEMP11
       CMP    #$80 
       BCC    PREHL1
       DEC    TEMP11
PREHL1 
       EOR    TEMP11
       LSR
       LSR
       CMP    TEMP7 
       BCC    PREHL2
       LDA    TEMP7 
PREHL2 
       TAY
       LDA    BRNT20,Y
       EOR    TEMP11
       ROL    TEMP11 
       ADC    TEMP10 
PREHL5 
; PACK
       BPL    PREHL3
       EOR    #$FF 
       JSR    PREHL3
       EOR    #$1F 
       STA    TEMP10 
       RTS
PREHL3 
       TAY
       CPY    #$28 
       BCC    PREHL4
       LDY    #$27 
PREHL4 
       LDA    BRNTB7,Y
       STA    TEMP10 
       RTS
;
;
POSTH1 
       CLC  ;TYPE 1
POSTHP 
       STA    TEMP11
       AND    #$E0 
       ORA    TEMP10 
       BCC    POSTH2
       CMP    TEMP11
       BEQ    POSTH2
       EOR    TEMP11
       AND    #$10 
       BEQ    POSTH4
       LDA    #$FE 
POSTH4 
       BCS    POSTH3
       EOR    #$FF 
POSTH3 
       ADC    TEMP11
       SEC
       RTS
POSTH2 
       CLC
       RTS
;
;
EXCHNG 
; EXCJAMGE PBK X-1 WITH X-2
       LDA    HVERP0-1,X
       LDY    HVERP0-2,X
       STA    HVERP0-2,X
       STY    HVERP0-1,X
EXCHN1
; NO VERT EXCHANGE
       LDA    ZDELP0-1,X
       LDY    ZDELP0-2,X
       STA    ZDELP0-2,X
       STY    ZDELP0-1,X
       LDA    HHORP0-1,X
       LDY    HHORP0-2,X
       STA    HHORP0-2,X
       STY    HHORP0-1,X
       LDA    ZPOSP0-1,X
       LDY    ZPOSP0-2,X
       STA    ZPOSP0-2,X
       STY    ZPOSP0-1,X
       LDA    YDELP0-1,X
       LDY    YDELP0-2,X
       STA    YDELP0-2,X
       STY    YDELP0-1,X
       LDA    XDELP0-1,X
       LDY    XDELP0-2,X
       STA    XDELP0-2,X
       STY    XDELP0-1,X
       LDA    HGRAP0-1,X
       LDY    HGRAP0-2,X
       STA    HGRAP0-2,X
       STY    HGRAP0-1,X
       LDA    IQPATH-1,X
       LDY    IQPATH-2,X
       STA    IQPATH-2,X
       STY    IQPATH-1,X
       RTS
;
;
;
;     BANK SELECT CODE
      ORG  $0FCF
      RORG BANK1+$0FCF
PON1
       STA    STROB4 ;JMP FFD2
       JSR    BRAIN
       STA    STROB3 ;JMP DFD8
      .byte $00,$00,$00
       JSR    HYPSRV
       STA    STROB2 ;JMP EFE1
EXPOFF 
       .byte $FF,$FC,$FD,$FA,$FA,$00,$00,$00
SWAPT5 .byte $01,$01,$02,$03
       JSR    CLOSE
       STA    STROB3 ;JMP DFF3
BRNT14 .byte $00,$1F
       .byte $00
       .byte "DOUG N"
       .word PON1
       .word PON1
;
;
; **********************
;  END INCLUDE BANK1.SRC
; **********************
;
;END

;
; **********************************
;   VERSION 17.6  08-MAR-86
;COPYRIGHT (C) 1986, DOUGLAS NEUBAUER
; INCLUDE BANK3.SRC FOR UNIV.SRC
; **********************************
;
;
;*********
 seg bank3
 ORG $1000
 RORG BANK3    ; BEGIN BANK3
;*********
;
;
SCRTAB
       .byte $00,$1E,$33,$33,$33,$33,$33,$1E
       .byte $00,$3F,$0C,$0C,$0C,$0C,$3C,$1C
       .byte $00,$3F,$30,$30,$1E,$03,$23,$3E
       .byte $00,$1E,$23,$03,$06,$03,$23,$1E
       .byte $00,$06,$06,$3F,$26,$16,$0E,$06
       .byte $00,$3E,$23,$03,$3E,$30,$30,$3F
       .byte $00,$1E,$33,$33,$3E,$30,$31,$1E
       .byte $00,$0C,$0C,$0C,$06,$03,$21,$3F
       .byte $00,$1E,$33,$33,$1E,$33,$33,$1E
       .byte $00,$1E,$23,$03,$1F,$33,$33,$1E
       .byte $00,$00,$00,$08,$1C,$3E,$00,$00 ;DOWN
       .byte $00,$00,$08,$18,$38,$18,$08,$00 ;LEFT
       .byte $00,$00,$00,$3E,$1C,$08,$00,$00 ;UP
       .byte $00,$00,$08,$0C,$0E,$0C,$08,$00 ;RIGHT
       .byte $00,$00,$66,$3C,$18,$3C,$66,$00 ;X
       .byte $00,$00,$00,$00,$00,$00,$00,$00 ;BLANK
;  SCANNER
       .byte $00,$FB,$0B,$0B,$FB,$C3,$C3,$FB
       .byte $00,$D9,$19,$19,$1F,$19,$19,$DF
       .byte $00,$65,$6D,$6D,$7D,$75,$75,$65
       .byte $00,$97,$B6,$B6,$F7,$D6,$D6,$97
       .byte $00,$B6,$36,$34,$BE,$32,$32,$BE
;  JUMP
       .byte $00,$78,$CC,$0C,$0C,$0C,$0C,$3E
       .byte $00,$79,$CD,$CD,$CD,$CD,$CD,$CD
       .byte $00,$8D,$8D,$AD,$AD,$FD,$DD,$8D
       .byte $00,$80,$83,$83,$F0,$9B,$9B,$F0
;  COPYRIGHT
       .byte $00,$00,$F7,$95,$87,$80,$90,$F0
       .byte $47,$41,$77,$55,$75,$00,$00,$00
       .byte $03,$00,$4B,$4A,$6B,$00,$08,$00
       .byte $80,$80,$AA,$AA,$BA,$22,$27,$02
       .byte $00,$00,$11,$11,$17,$15,$17,$00
       .byte $00,$00,$77,$55,$77,$54,$77,$00
;
FUELT1
       .byte $7F,$7E,$7C,$78,$70,$60,$40,$00
;
CHTAB8
; CHART GRAPHICS
       .byte $00,$00,$00,$00,$00,$00,$00 ;BLANK
; SHARE 1
LD107  .byte $00

SMSKTB
       .byte $01,$02,$04,$08,$10,$20,$40,$80
       .byte $00,$00,$66,$3C,$18,$3C,$66,$00 ;X
       .byte $00,$08,$2A,$1C,$7F,$1C,$2A,$08 ;GOOD
       .byte $00,$FF,$80,$BA,$AA,$BB,$80,$E0 ;TRN
       .byte $00,$18,$99,$C3,$E7,$C3,$99,$18 ;BLK
       .byte $00,$80,$40,$60,$72,$FF,$00,$80 ;FIGH
       .byte $00,$00,$E8,$98,$5A,$39,$1F,$00 ;BAD
       .byte $00,$00,$C3,$99,$FF,$99,$C3,$00 ;PIRATE
       .byte $00,$18,$3C,$FF,$18,$FF,$3C,$18 ;PLN
       .byte $00,$08,$1C,$08,$03,$E7,$B6,$9C ;HOL
       .byte $00,$1C,$26,$4E,$1C,$18,$18,$0E ;COBRA
       .byte $00,$08,$81,$00,$10,$00,$81,$10 ;WALL
; COMPANY NAME
       .byte $00,$F2,$D8,$D8,$D8,$D8,$D8,$F0
       .byte $00,$CD,$DD,$DD,$FD,$ED,$EC,$CC
       .byte $00,$EF,$8D,$CD,$8D,$ED,$00,$00
       .byte $00,$7A,$6A,$7B,$6A,$7B,$00,$00
       .byte $00,$BD,$B5,$B5,$B5,$B5,$00,$00
       .byte $00,$ED,$8F,$EF,$8D,$EF,$00,$00
; SOME TARG GRA
       .byte $18,$3C,$3C,$3C,$18 ;MOON/CRA
       .byte $24,$3C,$18,$7E,$18  ;MAN
       .byte $FF,$81,$81,$FF,$FF   ;LZ
;
;
;
       .byte $A0,$90
XTABLE
       .byte $71,$61,$51,$41,$31,$21,$11,$01
       .byte $F1,$E1,$D1,$C1,$B1,$A1,$91,$72
       .byte $62,$52,$42,$32,$22,$12,$02,$F2
       .byte $E2,$D2,$C2,$B2,$A2,$92,$73,$63
       .byte $53,$43,$33,$23,$13,$03,$F3,$E3
       .byte $D3,$C3
;
;
;
SCRKER
; SETUP SCORE
;  DISPLAY PNTR 654321
       LDY    #$07 
SCRKR4
       LDX    #$F0 
SKRKR3
;  ENTRY
       STA    WSYNC
       STA    ADDEL
       STX    TEMP7 
       STX    TEMP5 
       LDA    #$10 
       STA    VBLANK   ;TURN OFF
       STX    PNTR3+1 
       STX    PNTR4+1
       STX    PNTR5+1
       STX    PNTR6+1
       STA    HDELP1
       STA    REFP0
       STA    REFP1
       LDA    #$00 
       STA    HPOSP0
       STA    HPOSP1
       STA    WSYNC
       STA    ADDEL
; NEXT LINE SETUP
       STA    GRAFP0
       STY    STAK1 
       LDA    #$03 
       STA    SIZPM0
       STA    SIZPM1
       STA    VDELP0
       STA    VDELP1
       STA    CLRDEL
;
SCRKR1
;  DISPLAY SCORE
       LDY    STAK1 
       LDA    (PNTR1),Y
       STA    STAK2 
       STA    WSYNC
       STA    ADDEL
       LDA    (PNTR2),Y
       TAX
       LDA    (PNTR6),Y
       STA    GRAFP0
       LDA    (PNTR5),Y
       STA    GRAFP1
       LDA    (PNTR4),Y
       STA    GRAFP0
       LDA    (PNTR3),Y
       LDY    STAK2 
       STA    GRAFP1
       STX    GRAFP0
       STY    GRAFP1
       STA    GRAFP0
       DEC    STAK1 
       BNE    SCRKR1
       LDA    #$00 
       STA    VDELP1
       STA    GRAFP0
       STA    GRAFP1
WAIT1L
; ENTRY
       STA    WSYNC
       STA    ADDEL
       RTS
;
;
CHART
       LDY    #$08 
       JSR    LDSCR4
       JSR    SCRKER
;  SETUP CHART
       STA    VDELP0
       LDA    #$17 
       STA    STAK1 
       LDA    HCOLP1 ;CHART COLOR
       ORA    #$0E 
       STA    COLPM0
       STA    COLPM1
       LDX    #$A0 
       STA    HPOSP0
       STA    HPOSM0
       STX    HDELM1
       LDY    #$C0 
       LDX    #$0A 
       STA    HPOSM1
       STA    HPOSP1
       STY    HDELM0
       EOR    #$22 
       STA    COLPF
CHAR98
       STA    WSYNC
       STA    ADDEL
       LDA    #$F1 
       STA    TEMP7,X
       LDY    #$9F 
       NOP
       NOP
       NOP
       NOP
       NOP
       DEX
       STA    CLRDEL
       BPL    CHAR98
;
CHART2
; DISPLAY CHART
; LINE 1 SETUP
       LDA    #$1F 
       STA    WSYNC
       STA    ADDEL
; LIN 2
       STA    GRFPF1
       STY    GRFPF2
       STA    GRAFM0
       STA    GRAFM1
       LDX    #$05 
CHAR82
       DEX
       BPL    CHAR82
       STX    GRFPF2
       LDY    STAK1 
       BMI    CHAR86
       LDX    #$0C 
       LDA    #$00 
       STA    GRFPF2
CHART5
       STA    WSYNC
       STA    ADDEL
;  LINES 3,4,5
       TYA
       AND    #$FE 
       EOR    #$0C 
       BEQ    CHAR85
       LDA    #$10 
CHAR85
       STA    GRFPF1
       LDA.wy CHTBLK,Y
       AND    #$F0 
       LSR
       STA    PNTR1-2,X
       DEX
       DEX
       LDA.wy CHTBLK,Y
       AND    #$0F 
       ASL
       ASL
       ASL
       STA    PNTR1-2,X
       DEY
       DEX
       DEX
       BNE    CHART5
;
       STY    STAK1 
       LDY    #$07 
CHART1
       LDA    (PNTR1),Y
       STA    WSYNC
       STA    ADDEL
       STA    STAK2 
       LDA    (PNTR6),Y
       STA    GRAFP0
       LDA    (PNTR3),Y
       STA    GRAFP1
       LDA    (PNTR4),Y
       TAX
       LDA    (PNTR5),Y
       NOP
       STA    GRAFP0
       NOP
       STX    GRAFP0
       LDX    STAK2 
       LDA    (PNTR2),Y
       STA    GRAFP1
       DEY
       STX    GRAFP1
       BPL    CHART1
       STA    WSYNC
       STA    ADDEL
; LINE 1
       LDA    #$10 
       STA    GRFPF1
; Y = FF
       BIT    STAK1 
       BPL    CHAR87
       LDY    #$9F 
CHAR87
       JMP    CHART2
CHAR86
; FINISH LINE 2
       LDA    HCOLP1 
       ADC    #$C8 
       TAX
       STA    WSYNC
       STA    ADDEL
; LINE 3, ALL DONE CHART
       LDA    #$00 
       STA    GRFPF1
       STA    GRFPF2
       STA    GRAFM0
       STA    GRAFM1
       LDY    #$02 
       LDA    #$A8  ;JUMP
       JSR    LDSCOR
       LDA    JMPTIM 
       AND    #$0F 
       ASL
       ASL
       ASL
       STA    PNTR1 
       LDA    JMPTIM 
       AND    #$F0 
       LSR
       STA    PNTR2 
       JSR    SCRKER
       LDY    #$08 
       JSR    LDSCR1  ; WAIT
;  FALL THRU TO SCANDS
;
;
SCANDS
       STA    WSYNC
       STA    ADDEL
; LINE 1
       LDA    #$00 
       STA    VDELP0
       STA    VDELM2
       STA    GRAFP0
       STA    GRAFP1
       STA    GRAFM2
       STA    SIZPM0
       STA    COLPF
; RANGE
       LDX    TARNUM 
       LDA    ZPOSP0-1,X
       CMP    #$40 
       BCC    SCAND8
       ADC    #$3F 
       ROR
SCAND8
       TAY
       LSR
       AND    #$78 
       STA    PNTR5+0
       TYA
       AND    #$0F 
       TAY
       LDA    SCNTB1,Y
       STA    PNTR5+1
       LDA    FUEL 
       LSR
       LSR
       LSR
       STA    WSYNC
       STA    ADDEL
; LINE 2
       LDY    #$01 
       STY    PRIOR
       BIT    PROGST 
       BPL    SCAN10
;  COPYRIGHT
       STY    COLBK
       LDA    #$C7 
       LDX    #$FF 
       TXS
       LDX    #$2C 
       JSR    LDSCOR
       LDY    #$08 
       JSR    SCRKR4
       LDA    #$68   ;TITLE
       LDX    #$2A 
       LDY    #$01 
       JSR    LDSCOR
       LDX    #>CHTAB8
       LDY    #$07 
       JSR    SKRKR3
       LDY    #$04  ;WAIT
       JMP    HORZ11
SCAN10
; HORIZ
       STA    STAK1    ;TEMPORARY REG
       SEC
       LDA    HHORP0-1,X
       SBC    CENTER 
       CLC
       ADC    #$28 
       CMP    #$50 
       BCC    SCAND1
       CMP    #$A8 
       LDA    #$50 
       BCC    SCAND1
       LDA    #$00 
SCAND1
       LSR
       TAY
       LDA    #$70-9 ;X
       CPY    #$13 
       BEQ    SCAND5
       LDA    #$68-9 ;RT
       BCS    SCAND5
       LDA    #$58-9 ;LT
SCAND5
       STA    PNTR2 
       LDA    XTABLE,Y
       STA    HDELP0
       STA    WSYNC
       STA    ADDEL
;  LINE 3
;  HPOSP0
       AND    #$0F 
       TAY
       LDA    #>MASKTB
       STA    PNTR6+1
       LDA    #$B8 
       STA    COLPM1
       LDA    #$F2 
       STA    COLBK
       LDA    #$00 
       STA    GRAFM0
       LDA    #>SCRTAB
       STA    PNTR2+1
       STA    PNTR3+1 
SCAND6
       DEY
       BNE    SCAND6
       STA    HPOSP0
       LDA    HGRAP0-1,X
       AND    #$78 
       LSR
       LSR
       LSR
       TAY
       STA    WSYNC
       STA    ADDEL
;   LINE 4
       LDA    #$04 
       STA    SIZPM1
;  VERTICAL
       LDA    HVERP0-1,X
       CLC
       ADC    #$48 
       LSR
       LSR
       LSR
       LSR
       STA    PNTR1   ;HOLD REG
       LDX    #$0E 
       STA    CLRDEL
       STA    HPOSP1  ; NUMBERS POSITION
       LDA    #$10 
       STA    HDELM2
       LDA    #$F0 
       STA    HDELP1
       STA    HPOSM2  ;CROSSHAIRS POSITION
       LDA    SCNTB4,Y
       BIT    ONESHT
       BVC    SCAN11
       LDA    RANDOM 
       TAX
SCAN11
       STA    PNTR4 
       STX    COLPM0
       LDX    #$03 
       STA    WSYNC
       STA    ADDEL
       STX    GRAFM2
       STX    GRFPF1  ;DISP 1ST LINE SCANNER
       LDX    #$FF 
       STX    GRFPF2
       LDX    #$70-9  ;X
       LDA    PNTR1 
       CMP    #$08 
       BEQ    SCAND7
       LDX    #$60-9  ;UP
       BCS    SCAND7
       LDX    #$50-9  ;DWN
SCAND7
       STX    PNTR3 
       LDA    #<MASKTB+2
       SEC
       SBC    PNTR1 
       STA    PNTR6 
       LDA    SCNTB2,Y
       SEC
       SBC    PNTR1 
       STA    PNTR1 
       LDA    #>CHTAB8
       STA    PNTR1+1
       STA    CLRDEL
       LDY    #$0F 
       LDA    #$01    ;C=1
;
SCAND2
; DISPLAY SCANNER
       AND    (PNTR6),Y
       SBC    #$01 
       STA    WSYNC
       STA    ADDEL
       AND    (PNTR1),Y
       STA    GRAFP0
       LDA    TACTB1,Y
       STA    GRFPF2
       LDA    (PNTR2),Y  ; LEFT NO.
       LDX    TACTB2,Y
       BMI    SCAND3
       STA    GRAFP1
       LDA    PNTR4      ; SCANNER COLOR
       STA    COLBK
       STX    PRIOR
       LDA    (PNTR3),Y  ; RIGHT #
       STA    GRAFP1
SCAND4
       SEC
       LDX    #$F2   ;BAK COLOR
       LDA    #$01 
       STA    PRIOR
       STX    COLBK
       DEY
       BPL    SCAND2
       BMI    SCAN33 ;JMP
SCAND3
       STX    PRIOR
       LDA    PNTR5
       STA    PNTR2 
       LDA    PNTR5+1
       STA    PNTR3 
       JMP    SCAND4
SCAN33
;
;
       STA    WSYNC
       STA    ADDEL
; SETUP FUEL
       LDA    #$00 
       STA    GRAFP0
       NOP
       STX    COLPF   ;BAKCOL
       LDX    LIVES 
       LDA    LIVTAB,X
       STA    GRFPF0
       LDA    LIVTAB+1,X
       STA    GRFPF1
       LDA    #$34 
       STA    PRIOR
       LDA    STAK1   ;HOLDS FUEL
       LSR
       LSR
       TAY
       LDA    FUELT1,Y
       STA    GRFPF2
       LDY    STAK1 
       STA    HPOSP0
       STA    HPOSP1
       LDA    XTABLE-2,Y
       STA    HDELM2
       STA    WSYNC
       STA    ADDEL
       AND    #$0F 
       CLC
       ADC    #$07 
       TAX
DISP70
       DEX
       BPL    DISP70
       LDA    #$10 
       STA    HDELP1
       LDA    ATRACT 
       STA    HPOSM2
       STA    WSYNC
       STA    ADDEL
       LDX    #$F2   ;BAKCOL
       LDY    FUEL 
       CPY    #$01 
       BCC    DISP72
       CPY    #$20 
       BCS    DISP71
       LDY    #$52 ;#AUDLOW-J
       STY    CH0SHD    ;LOW FUEL
       AND    #$10 
       BNE    DISP72
DISP71
       LDX    #$1A 
DISP72
       LDY    #$04 
       NOP
       NOP
       NOP
       NOP
       STA    CLRDEL
;
DISP73
; DISPLAY FUEL
       LDA    #$8E 
       STA    WSYNC
       STA    ADDEL
       STA    COLPM0
       STA    COLPM1
       LDA    #$04 
       STA    SIZPM0
       STA    SIZPM1
       LDA    FUELT3,Y
       STA    GRAFP0
       STA    GRAFP1
       LDA    FUELT4,Y
       STA    GRAFP0
       LDA    FUELT2,Y
       STA    GRAFP1
       LDA    #$03 
       STA    SIZPM0
       STA    SIZPM1
       STX    COLPM0
       STX    COLPM1
       LDA    FUELT5,Y
       STA    GRAFP0
       STA    GRAFP1
       DEY
       BPL    DISP73
       JMP    MAIN2   ; SCREEN ALL DONE
;
;
;
FUELT2 .byte $EE,$88,$E8,$88,$E8
FUELT5 .byte $FF,$00,$EE,$CC
FUELT3 .byte $88,$88,$CC,$EE,$CC
FUELT4 .byte $8E,$8A,$EA,$8A,$EA
;
;
;  MASKTB BLOCK
TACTB1 .byte $FF,$23,$03,$03,$03,$03,$03,$07
       .byte $FF,$07,$03,$03,$03,$03,$03,$23
MASKTB
SCNTB4 .byte $44,$44,$44,$B4,$B4,$55,$55,$87
       .byte $85,$85,$87,$87,$15
TACTB2 .byte $05,$05,$25,$05,$25,$05,$25,$05
       .byte $85,$05,$25,$05,$25,$05,$25,$05
;  END MASKTB BLOCK
;
;
SCNTB1 .byte $00,$08,$10,$18,$20,$20,$28,$28
       .byte $30,$30,$38,$38,$40,$40,$48,$48
;
SCNTB2 .byte $14,$44,$4C,$9F,$A4,$2C,$1C,$5B
       .byte $9A,$9A,$3C,$9A,$14
;
;
;
;
LDSCR3 
; ENTRY FROM MESSRV
       LDY    #$01 
LDSCR4
; ENTRY FROM CHART
       LDX    #$48 
       LDA    #$78   ;SCANNER 
LDSCOR
; WORD TO SCORE KERNAL
; A=PNTR,X=COLOR,Y=WAIT
       STX    COLPM0
       STX    COLPM1
       CLC
       STA    PNTR6 
       ADC    #$08 
       STA    TEMP4 
       ADC    #$08 
       STA    PNTR4 
       ADC    #$08 
       STA    PNTR3 
       ADC    #$08 
       STA    PNTR2 
       ADC    #$08 
       STA    PNTR1 
LDSCR1
       STA    WSYNC
       STA    ADDEL
       DEY
       BNE    LDSCR1
       RTS
;
;
;
;
;
MESSRV
       LDA    NEWATT 
       CMP    #$40 
       BCC    MESSR1
       BIT    ATRACT 
       BPL    LDSCR3
MESSR1
       LDA    #$1E 
       STA    COLPM0
       STA    COLPM1 ;SCORE COLOR
       LSR           ;A = 0F
       AND    SCORE 
       ASL
       ASL
       ASL
       STA    PNTR2 
       LDA    #$F0 
       AND    SCORE 
       LSR
       STA    PNTR3 
       LDA    SCORE+1
       AND    #$0F 
       ASL
       ASL
       ASL
       STA    PNTR4 
       LDA    SCORE+1 
       AND    #$F0 
       LSR
       STA    PNTR5
       LDA    SCORE+2 
       AND    #$0F 
       ASL
       ASL
       ASL
       STA    PNTR6 
       LDY    #$78    ;BLANK
       TYA
       LDX    PROGST 
       CPX    #$CE    ;PWR UP
       BEQ    MESSR6
       LDA    #$00 
MESSR6
       STA    PNTR1 
;
       LDX    #$0A 
MESSR2
       LDA    PNTR1,X
       BNE    MESSR3
       STY    PNTR1,X
       DEX
       DEX
       BNE    MESSR2
MESSR3
       RTS
;
;
;
CRAZY
;  CANT CROSS PAGE BOUNDARY
       .byte $60,$71,$50,$61,$40,$51,$30,$41
       .byte $20,$31,$10,$21,$00,$11,$F0,$01
       .byte $E0,$F1,$D0,$E1,$C0,$D1,$B0,$C1
       .byte $A0,$B1,$90,$62,$73,$52,$63,$42
       .byte $53,$32,$43,$22,$33,$12,$23,$02
       .byte $13,$F2,$03,$E2,$F3,$D2,$E3,$C2
       .byte $D3,$B2,$C3,$A2,$B3,$92,$64,$75
       .byte $54,$65,$44,$55,$34,$45,$24,$35
       .byte $14,$25,$04,$15,$F4,$05,$E4,$F5
       .byte $D4,$E5,$C4,$D5,$B4,$C5,$A4,$B5
       .byte $94,$66,$77,$56,$67,$46,$57,$36
       .byte $47,$26,$37,$16,$27,$06,$17,$F6
       .byte $07,$E6,$F7,$D6,$E7,$C6,$D7,$B6
       .byte $C7,$A6,$B7,$96,$68,$79,$58,$69
       .byte $48,$59,$38,$49,$28,$39,$18,$29
       .byte $08,$19,$F8,$09,$E8,$F9,$D8,$E9
       .byte $C8,$D9,$B8,$C9,$A8,$B9,$98,$6A
       .byte $7B,$5A,$6B,$4A,$5B,$3A,$4B,$2A
       .byte $3B,$1A,$2B,$0A,$1B,$FA,$0B,$EA
       .byte $FB,$DA,$EB,$CA,$DB,$BA,$CB,$AA
;
;
;
;
; *** END KERNALS FOR BANK 3 *****
;
;
;
;
;  INIT SECTION
INIT
       SEI
       CLD
       LDX    #$00   ;COLD START
       LDY    #$CE   ; GAME OVER
INIT2
;  WARM START: GAME RESET/SELECT
       LDA    #$00 
INIT1
       STA    VSYNC,X
       INX
       BNE    INIT1
       STY    PROGST 
       DEX    ;X=FF
       TXS
;
       LDA    #$60 
       STA    JMPTIM 
       LDA    #$15 
       STA    CURSOR 
       LDA    #$04 
       STA    LIVES 
       LDY    #$07 
       JSR    DOOR24  ;SETUP CHART
;
INIT3
;  ENTRY FROM MAN DIED
       LDY    #$FF 
       STY    FUEL 
       INY
       STY    ONESHT  ;Y=0 ,CLEAR DAMAGE
       LDA    #$50 
       STA    CENTER 
       LDY    #$40    ;CRATERS
       LDX    #VSHIP
       DEC    LIVES 
       BNE    INIT6
       LDX    #$00 
INIT8
;  ENTRY FROM END GAME (DOOR)
       LDA    #$CA 
       STA    PROGST 
INIT6
       STX    HVERP1    ;REDUNDANT
       LDA    PROGST 
       AND    #$84 
       BEQ    INIT7   ;MAN DIED,GAME NOT OVER
;  RESET TO PLANET
       LDA    #CRATYP-W
       STA    IQPNTR 
       LDA    #$40 
       STA    GAMEST   ;YOUR PLANET
INIT4
; ENTRY FROM SHIP TAKEOFF
       STX    HVERP1  ;SHIP VERT
       LDA    #PBLK 
       STA    HGRAP1+3 
       LDX    #$03 
INIT10
       LDA    #$00 
       STA    XDELP0,X
       STA    ZDELP0,X
       LDA    INTAB1,X
       STA    ZPOSP0,X
       LDA    INTAB2,X
       STA    HHORP0,X
       STY    HGRAP0,X
       DEX
       BPL    INIT10
;
INIT7
;  MAN DIED GAME NOT OVER
       LDA    #$58 
       STA    PLINES 
       LDA    #$80 
       STA    ZPOSP1 
       STA    ZPOSP1+1 
INIT5
;  ENTRY FROM SECTOR IS EMPTY
       LDX    #$FF 
       TXS              ;DEFINE STACK
       LDA    SHIPST 
       AND    #$10 
       ASL
       AND    SHIPST 
       STA    SHIPST    ;IF SHIPST=30 THEN =20
       INX       ;X=0
       STX    VELOC 
       STX    CH0SHD 
       STX    CH1SHD 
;
;
;  END INIT SECTION
;
MAIN
;
;  VBLANK SERVICE
;
       LDY    HHORM2 
       BIT    PROGST 
       BVC    MAIN11
       LDY    #$88     ;PLN/TRN  FIXED
MAIN11
       LDA    CRAZY,Y
       LDY    RTIMER   ;FOR RANDOM
MAIN70
       LDX    RTIMER   ;TEMP  ***
       BPL    MAIN70
       STA    WSYNC
       LDX    #$FF 
       STX    VSYNC
       STA    HDELM2
       AND    #$0F 
       LSR
       BCS    HORIZ1    ;DELAY
HORIZ1
       SEC
       NOP
       SBC    #$01 
       BPL    HORIZ1
       STA    HPOSM2
       STA    WSYNC
       STA    ADDEL
       JMP    EXIT3   ;TO MOVER
;
MAIN9
       LDX    #$03 
HORIZ17
       LDY    HHITP0,X
       LDA    CRAZY,Y
       STA    HHITP0,X
       DEX
       BPL    HORIZ17
;
MAIN8
       JSR    MESSRV
;
HACKSEI
       NOP   ; TEMPORARY $78 *********
;
;
;  END VBLANK SERVICE
;
;
       BIT    SHIPST 
       BMI    HORZ15
       LDY    HHORP1 
       LDA    CRAZY-$2D,Y
       STA    HHORP1 
HORZ15
       LDX    HOLDM2 
       BEQ    HORZ14
       LDA    CRAZY-$2D,X
       STA    HHORP1+1 
HORZ14
       BIT    PROGST 
       BVC    HORZ16
       SEC     ;PLN/TRN
       LDA    #$A0 
       SBC    VWALL 
       TAX
       LDA    CRAZY+8,X
       STA    HOLDM0 
       LDY    VWALL 
       LDA    CRAZY-$0B,Y
       STA    HOLDM2 
HORZ16
       LDY    THGRP1
HORIZ
       LDX    $0285     ;TEMP ***
       BPL    HORIZ
       STA    WSYNC
       CLC
       LDA    HORTB1,Y
       ADC    RANDOM+1  ;HOLD CENTER
       TAX
       LDA    CRAZY,X
       STA    HDELM1
       AND    #$0F 
       LSR
       BCS    HORIZ4   ;DELAY
HORIZ4
       SEC
       NOP
       SBC    #$01 
       BPL    HORIZ4
       STA    HPOSM1
       STA    WSYNC     ;?? NEEDED ??
;
;  SETUP FOR SCREEN
       LDX    #$00 
       LDA    PROGST 
       LSR
       BCS    HORIZ5  ;SCREEN PROTECT
       AND    #$18 
       BNE    HORIZ8
;  NORMAL
       LDA    LJOYT10,Y
       STA    RANDOM+1   ;HDELM1
       LDY    #<SATKRN
       BIT    PROGST 
       BVS    HORIZ6   ;PLAN, DISP SATURN
       LDY    #<DIS170
       BIT    HGRAP1+3
       BMI    HORIZ7  ;NO P1+3
       LDY    #<DIS150
HORIZ6
       LDX    HHORP1+3 
HORIZ7
       STY    VECTP1
       LDA    CRAZY,X
       STA    STARS+1  ;TEMP HOLD HORIZ
       JSR    SCRKER
       JMP    EXIT2    ;DISPLY
HORIZ8
       AND    #$08 
       BEQ    HORIZ9
       JSR    SCRKER
       STA    HPOSM0
       STA    HPOSM2
       JMP    EXIT1  ;HWARP
HORIZ9
       JSR    SCRKER
       JMP    CHART
HORIZ5
       LDA    ATRACT   ;SCRN PROT.
       AND    #$C0 
       EOR    ATRACT+1 
       AND    #$C7 
       STA    COLBK
       LDY    #SCNSIZ+1
       JSR    WAIT1L
       STX    VBLANK
HORZ11
       JSR    LDSCR1
;  FALL THRU MAIN2
;
;
MAIN2
;
;  OVERSCAN SERVICE
;
;
       STA    WSYNC
       LDA    #$20  ;FOR NOW***  ;28 (30 =#$24) LINES OVERSCAN
       STA    STIM64
       LDX    #$FF 
       STX    VBLANK
       TXS
       INX  ; X=0
       STX    THGRP1   ;FOR JOYSTK
       STX    HOLDM2   ;FOR PHOTON
       STX    COLBK
       LDA    ATRACT 
       AND    #$03 
       BEQ    MAIN88
       LDA    #$12 
MAIN88
       STA    HCOLP1     ;FLAME COLOR
       LDX    NEWLEV 
       LDA    DORT11,X
       AND    #$07 
       STA    NEWAVE 
;
;
;
HACKCLI
       NOP      ; TEMPOARY $58 *********** (sic)
;
;
;
; TIMSRV
       LDA    ONESHT 
       LSR
       EOR    PORTB    ;GAME RESET
       LSR
       LDX    #NOCLER
       BCS    TIMSR1
       LDY    #$4E 
       JMP    INIT2
TIMSR1
;
       LDA    PAUTIM 
       BEQ    TIMSR4
       DEC    PAUTIM 
       BNE    TIMSR4
       LDA    HVERP1 
       BNE    TIMSR4
       LDA    PROGST 
       ORA    #$02 
       CMP    PROGST 
       STA    PROGST 
       BNE    TIMS16
;  YOU DIED
       JMP    INIT3
TIMS16
       LDA    #$30 
       STA    PAUTIM  ;PAUSE A BIT LONGER
TIMSR4
       LDA    SHIPST 
       BPL    TIMSR6
;  SHIP TAKEOFF
       LDY    HCOLP1+1 
       CPY    #$70 
       BNE    TIMSR9   ;NOT DONE
;  SHIP TAKEOFF DONE
       LDA    #$00 
       STA    IQSTAK 
       STA    PROGST   ;DEFAULT 
       STA    GAMEST   ;DEFAULT
       LDA    #MONTYP-W 
       STA    IQPNTR   ;DEFAULT
       LDA    NEWATT 
       AND    #$F8 
       STA    NEWATT 
       LDA    SHIPST 
       LDX    #$F2 
       CMP    #$B0 
       BEQ    TIMS18
       AND    #$10 
       BNE    TIMSR7  ;PLANET
       LDA    IQPATH-1
       AND    #$03    ;JMP QUAL I HOPE
       STA    GAMEST 
       EOR    #$FF 
       JSR    ADDFUL
       JSR    DOOR
TIMSR7
;  ENTRY FROM HITSRV
       LDX    #$E1 
TIMS18
       STX    IQWARP 
       LDX    #VSHIP
       LDY    #PBLK
       JMP    INIT4
TIMSR6
       LSR
       BCC    TIMSR9
;  SECTOR IS EMPTY
       AND    #$20 
       BEQ    TIMS14
       LDY    #$01 
       LDA    #$08 
       JSR    ADDSC3 ;DESCTROY PLANET/TRN
TIMS14
       LDA    NEWATT 
       AND    #$07 
       TAX
       LDA    LD107,X
       EOR    MAZRAM 
       STA    MAZRAM 
       LDA    NEWATT 
       ASL
       ROL
       ROL
       EOR    NEWATT 
       AND    #$07 
       BEQ    TIMSR8
       LDA    NEWATT 
       AND    #$C0 
TIMSR8
       STA    NEWATT 
       JSR    DOOR2
       JMP    INIT5
TIMSR9
;
       LDA    PROGST 
       INC    ATRACT 
       BNE    TIMSR2
       INC    ATRACT+1 
       BNE    TIMSR2
       ORA    #$01 
       STA    PROGST 
TIMSR2
       AND    #$93 
       BEQ    TIMS17
;  IQWARP=0
       LDA    #$00 
       STA    IQWARP 
TIMS17
       JSR    HITSRV
       JSR    EXIT5   ;JOY/AUDIO
       JSR    SMARTS
       JMP    MAIN
;
;
;
;
;    BANK3 SUBROUTINES
;
;
INTAB1 .byte $05,$14,$27,$48
INTAB2 .byte $78,$28,$68,$3B
;
HITAB2
       .byte $1C,$2F,$2F,$38,$7F,$7F,$7F,$7F
;
LIVTAB .byte $80,$E0,$E0,$C0,$80
;  SHARE 2
SJOYT2
       .byte $00,$00,$80,$40
DORTB1
       .byte $48,$48,$00,$00,$48
;  SHARE 4
CHTAB1 .byte $00,$00,$00,$00,$00,$03,$00,$00
       .byte $00,$00,$03,$1A,$1A,$1A,$1A
; SHARE 2
DORT12
       .byte $00,$00,$09,$12,$1B
;
;
SMARTS
;  CHART BRAINS, ETC.
       LDY    PROGST 
       LDA    SHIPST 
       ORA    PAUTIM 
       BEQ    SMART5
       TYA
       AND    #$DF 
       STA    PROGST 
SMART20
       JMP    EXIT4   ;DO BRAIN
SMART5
       TYA
       BNE    SMAR50
       BIT    MAZSTA 
       BPL    SMAR50
; NEGATIVE UNIVERSE
       LDX    #$42 
       LDA    RANDOM 
       CMP    #$0C            ;OR 08
       BCS    SMAR69
       LDA    #AUDEX6-J      ;NOISY
       STA    CH1PTR 
       LDX    #$8E 
SMAR69
       STX    COLBK
SMAR50
       TYA
       AND    #$83 
       BNE    SMART1
       LDA    ATRACT 
       AND    #$1F 
       BNE    SMAR11
       LDA    JMPTIM 
       SED
       SEC
       SBC    #$01 
       CLD
       BNE    SMART3
       INC    GAMTIM
       LDA    NEWATT 
       BNE    SMAR55
       INC    GAMTIM
SMAR55
       CMP    #$40 
       BCC    SMART4
;  FALL THROUGH TO BLOWLZ ( NO BRAIN)
;
BLOWZ
       LDA    NEWATT 
       AND    #$3F   ;DEST PLN
       STA    NEWATT 
       LDA    #AUDHLP-J
       STA    CH1PTR 
       BIT    GAMEST 
       BVC    BLOWL1
       LDA    #BLOWIT-W
       STA    IQPNTR   ;DEST PLAN
BLOWL1
; ENTRY FROM DOOR
       LDA    MAZRAM 
       AND    #$7F 
       STA    MAZRAM 
       LDA    #$80   ;NEGATIVE UNIV.
BLOWL3
; ENTRY FROM SMARTS
       ORA    MAZSTA 
       STA    MAZSTA 
       RTS
;
;
SMART4
       JSR    ADDFL2 ;-15
       LDA    #$50  ;25 SEC  (WAS #$60)
SMART3
       STA    JMPTIM 
SMAR21
       RTS

SMAR11
       CMP    JMPTIM 
       BNE    SMART1
       CMP    #$05 
       BCS    SMART1
       JMP    SMRHLP
SMART1
       LDA    HGRAP1+3
       CMP    #$10         ;COBRA
SMAR30
       BEQ    SMART20
       LDA    GAMEST 
       AND    #$DF 
       CMP    GAMEST 
       STA    GAMEST ;ONESHOT GAMEST
       ROR
       LSR    ONESHT 
       AND    TRIG1
       BMI    SMART9
       BCC    SMART9
       ASL    ONESHT 
SMAR22
;  ENTRY FROM SMRJOY
       LDA    PROGST 
       EOR    #$20 
       STA    PROGST 
       AND    #$20 
       BEQ    SMAR24      ;EXIT CHART
; SETUP CHART
       ASL               ;A = 40
       STA    ATRACT     ;HACK
       BCC    BLOWL3     ;JMP
SMAR24
       LDX    #$10 
SMAR23
       LDA    CHTAB1,X
       STA    XDELP0-1,X
       DEX
       BPL    SMAR23
       RTS

SMART9
       ASL
       ROL    ONESHT 
       LDA    #$20 
       TAY               ;SAVE
       BIT    PROGST     ;DEFINE V,Z
       BEQ    SMAR30     ;DO BRAIN
; FALL THRU TO SMRJOY
;
SMRJOY
; IN CHART
       LDA    ATRACT 
       BPL    SMRJ43
       AND    #$BF 
       STA    ATRACT ;BIG HACK
       LDX    TRIG0
       BMI    SMRJ44
; JUMP
       LDX    #MONTYP-W       ;ABORT SPACE
       BVC    SMRJ40        ; V DEFINED ABOVE
       LDX    #CRATYP-W       ;ABORT PLANET/TRENCH
SMRJ40
       STX    IQPNTR 
       STY    SHIPST        ;Y=$20
       ASL    ONESHT        ;NO SHOOT PHOTON
       LSR    ONESHT 
       LDA    #$50 
       STA    CENTER 
       BNE    SMAR22        ;JMP
SMRJ43
       LDY    #$01 
       STY    EXPNTR        ;JOYSTK WAIT
SMRJ44
       AND    #$07 
       TAX
       LDA    MAZRAM 
       AND    SMSKTB,X
       BEQ    SMRJ22
       JSR    FINDV
       LDY    TEMP6
       JSR    CHTERS
       BNE    SMRJ60
       LDX    CURSOR 
       CPX    #$06 
       BEQ    SMRJ60
       BIT    RANDOM 
       BVS    SMRJ22
SMRJ60
       JSR    CHTDRW
SMRJ22
       DEC    EXPNTR 
       BPL    SMRJ99
       INC    EXPNTR ; EXPNTR = 0 ALWAYS?
       LDA    PORTA
       LDX    #$03 
SMRJY1
       ASL
       BCC    SMRJY2
       DEX
       BPL    SMRJY1
SMRJ30
       LDA    ATRACT 
       AND    #$3F 
       LDY    #$00 
       CMP    #$21 
       BEQ    SMRJ31
       BCS    CHTRD2
SMRJ99
       LDY    #$02 
SMRJ31
       LDA    CURSOR 
       JSR    CHTERS      ;ERASE GUY, IF ANY (Y REG IS SAVED)
; FALL THRU TO CHTDRW
;
;
CHTDRW
; PUT OBJ ON CHART, A=POSIT, Y=GRAPHIC
       LSR
       TAX
       TYA
       BCC    CHTDR1
       ASL
       ASL
       ASL
       ASL
CHTDR1
       ORA    CHTBLK,X
       STA    CHTBLK,X
CHTRD2
       RTS
;
SMRJY2
       LDA    CURSOR 
       CLC
       ADC    SJOYT1,X
       CMP    #$30 
       BCS    SMRJ99 ;VERT
       TAY
       LDA    NCHTB1,Y
       AND    SJOYT2,X
       BNE    SMRJ99 ;HORIZ
       TYA
       LSR
       TAX
       LDA    CHTBLK,X
       BCC    SMRJY4
       LSR
       LSR
       LSR
       LSR
SMRJY4
       AND    #$0F 
       TAX
       CMP    #$0C 
       BCS    SMRJ99 ;HIT WALL
       TYA
       EOR    LSTCUR 
       BPL    SMRJY7
       ASL
       BNE    SMRJ30
SMRJY7
       LDA    CURSOR 
       STA    LSTCUR 
       ASL    LSTCUR 
       CPX    #$01 
       ROR    LSTCUR  ;SET BI
       STY    CURSOR 
       LDY    #$0F 
       STY    EXPNTR 
; FALL THRU TO CHTERS
;
CHTERS
; ERASE OBJ ON CHART, A=POSIT
       LSR
       TAX
       LDA    #$F0 
       BCC    CHTES1
       LDA    #$0F 
CHTES1
       AND    CHTBLK,X
       STA    CHTBLK,X
       TXA
       ROL            ;C STILL DEFINED ! (RESTORE A)
       RTS
;
;
;
FINDV1
       CLC
       LDX    #$00 
       BCC    FINDV2 ;JMP
FINDV
; X=INDEX (X NOT SAVED)
       TXA
       ASL
       ASL
       ASL
       ASL
       ORA    NEWLEV 
       TAY
       CPX    #$04 
       BCS    FINDV1
       CPX    #$02 
       LDA    FINTB2,X
       TAX
       LDA    JMPCNT,X
       BCC    FINDV8
       LSR
       LSR
       LSR
FINDV8
       AND    #$07 
       STA    TEMP9         ;FOR SMRHLP ONLY
       TAX
       LDA    NCHTB1,Y
       STA    TEMP7  ;SIGN
       LDA    NCHTB2,Y
       STA    TEMP4  ;DIR
       SEC
FINDV2
       LDA    NCHTB5,Y
       TAY
       AND    #$07 
       ADC    #$03 
       STA    TEMP6  ;GRAPHIC
       TYA
       LSR
       LSR
       BPL    FINDV5  ;JMP
FINDV6
       LSR    TEMP7
       BCS    FINDV7
       ADC    #$08 
FINDV7
       ADC    #$F9 
       LSR    TEMP4 
       BCS    FINDV5
       ADC    #$05 
FINDV5
       DEX
       BPL    FINDV6
LDAF5  RTS
;
;
;
FINTB2
       .byte $00,$01,$00
; SHARE 1
SMHTB2
       .byte $01,$01,$08,$08
;
;
NCHTB5
; INITIAL POSITIONS
       .byte $25,$64,$92,$00,$54,$54,$5D,$54,$8D,$B5,$5A,$0D,$34,$54,$3F,$9F
       .byte $22,$44,$6C,$54,$22,$0D,$35,$82,$1F,$85,$84,$00,$42,$82,$37,$6F
       .byte $00,$00,$27,$77,$61,$7D,$00,$2F,$31,$55,$00,$B5,$1A,$A5,$0C,$37
       .byte $00,$1A,$75,$7E,$82,$5F,$06,$1E,$AC,$17,$AF,$7A,$06,$37,$7F,$BE
       .byte $75,$9A,$37,$7A,$B5,$00,$3E,$3B,$0A,$62,$61,$6F,$00,$62,$8A,$5D
       .byte $9A,$09,$7C,$99,$29,$8A,$61,$62,$6A,$47,$07,$59,$B4,$B9,$53,$29
       .byte $62,$A4,$04,$04,$74,$04,$14,$5C,$BC,$25,$0C,$4C,$84,$09,$AD,$94
       .byte $50,$50,$98,$28,$A7,$38,$67,$A8,$40,$68,$38,$80,$50,$47,$00
;
; SHARE 1
DORTB3
; WORMHOLE DESTINATION
       .byte $00,$2A,$2F,$05
;
SJOYT3
; SHARE 2 BITS OF 1ST 48 BYTES OF NCHTB1
NCHTB1
; SIGNS
       .byte $B4,$26,$30,$00,$0F,$43,$95,$07,$1F,$0F,$07,$6A,$9C,$3C,$2A,$26
       .byte $11,$47,$B4,$3B,$38,$32,$2A,$53,$AA,$13,$0F,$00,$15,$5E,$A6,$33
       .byte $00,$00,$2A,$55,$AA,$0E,$00,$2A,$2A,$4D,$80,$27,$30,$2A,$33,$4E
       .byte $00,$38,$47,$2A,$1C,$0B,$2A,$55,$0F,$2A,$47,$71,$2A,$2A,$63,$55
;
NCHTB2
; DIRS
       .byte $38,$5F,$37,$00,$0E,$35,$2A,$55,$67,$17,$19,$2A,$65,$30,$2A,$26
       .byte $08,$40,$38,$57,$34,$38,$55,$50,$55,$52,$0E,$00,$78,$2F,$55,$2A
       .byte $00,$00,$2A,$55,$2A,$0F,$00,$2A,$55,$5C,$00,$2B,$2A,$2A,$4C,$55
       .byte $00,$0B,$4B,$55,$65,$20,$55,$2A,$0E,$2A,$26,$17,$55,$2A,$2A,$55
;
;
SJOYT1
       .byte $06,$FA,$01,$FF
;
;
;
DOOR21
; NEW LEVEL
       LDA    NEWATT 
       CMP    #$40 
       BCC    DOO438
       JSR    BLOWL1
DOO438
       JSR    SWAP   ;RESTORE
       LDA    DORTB8,Y
       STA    CURSOR 
       TYA
       ASL
       ASL
       ASL
       ASL
       ORA    NEWLEV
       LSR
       TAX
       LDA    DORTB4,X           ;THE BIG TABLE
       BCC    DOOR37
       LSR
       LSR
       LSR
       LSR
DOOR37
       AND    #$0F 
       CMP    #$08 
       EOR    NEWLEV
       STA    NEWLEV 
       BCC    DOOR23
       LDY    #$0F 
DOOR24
;   ENTRY, LOAD MAZRAM (FROM INIT ONLY)
       LDX    #$07 
DOOR25
       LDA    DORTB6,Y
       STA    MAZRAM,X
       DEY
       DEX
       BPL    DOOR25
DOOR23
       JSR    SWAP
       LDX    #$00 
       STX    NEWATT 
       LDY    NEWLEV
       LDA    GAMTIM
       SBC    DORT11,Y
       BCC    DOOR34
DOOR39
       SBC    #$04 
       BCC    DOOR35
       INX
       CPX    #$04 
       BCC    DOOR39
       LDA    MAZRAM 
       AND    #$03 
       BEQ    DOOR35
       JSR    BLOWL1
DOOR35
       LDA    #$05 
       STA    JMPTIM 
DOOR34
       LDA    DORT12,X
       STA    JMPCNT 
       BIT    MAZRAM 
       BMI    DOOR36
       ORA    #$80 
DOOR36
       STA    MAZSTA 
       RTS

DOOR2
;  ENTRY FOR SECTOR IS EMPTY
       LDA    CURSOR 
       LDY    #$03 
DOOR20
       CMP    DORTB9,Y
       BEQ    DOOR21
       DEY
       BPL    DOOR20
       BMI    SWAP1      ;JMP
;
;
SWAP
       LDA    NEWLEV
       AND    #$07 
       TAX
       LDA    MAZRAM,X
       STA    TEMP4 
       LDA    MAZRAM 
       STA    MAZRAM,X
       LDA    TEMP4 
       STA    MAZRAM 
SWAP1
       LDX    CURSOR 
       STX    LSTCUR 
       RTS
;
DOOR
; JUST HYPERWARPED  (FROM TIMSRV)
       BIT    LSTCUR 
       BPL    DOOR2          ;SECTOR EMPTY?!
       LDX    #$07 
DOOR3
       LDA    MAZRAM 
       AND    SMSKTB,X
       BEQ    DOOR10
       STX    TEMP5 
       JSR    FINDV       ;BIG TIMING LOOP!!! WATCH OUT!!
       LDX    TEMP5 
       CMP    CURSOR 
       BEQ    DOOR4
DOOR10
       DEX
       BPL    DOOR3
       BMI    SWAP1      ;SHOULDNT BE ABLE TO GET HERE, BAIL OUT!!!
DOOR4
; FOUND SOMETHING
       LDY    PNTR1  ;GRAPHIC
       CPY    #$0A 
       BNE    DOOR8
; WORMHOLE
       AND    #$03 
       TAY
       LDA    DORTB3,Y
       STA    CURSOR 
       LDA    #$30 
       STA    SHIPST       ;JMP AGAIN
       RTS

DOOR8
       LDA    DORTB1-3,Y
       STA    PROGST 
       LDA    DORTB2-3,Y
       STA    IQPNTR 
       CPY    #$03 
       BEQ    DOOR50      ;FRIENDLY
       INX               ;FIX FOR INDEX-1
       TXA
DOOR60
; ENTRY FROM SMRHLP (SAVES A BYTE)
       ORA    NEWATT 
       STA    NEWATT 
DOOR5
       RTS

DOOR50
       LDA    CURSOR  ;STARS END?
       BNE    SMRHL4
; GAME OVER
       LDY    #$18    ;MAN
       STY    ONESHT  ;SET STARS END BIT
       LDX    #VSHIP
       JMP    INIT8
;
;
;
SMRHLP
; CHART THINK
       TAX
       EOR    NEWATT 
       CMP    #$40 
       BCS    DOOR5       ;FRIENDLY ATTACK
       AND    #$07 
       BEQ    DOOR5
       LDA    MAZRAM 
       AND    LD107,X
       BEQ    IRQRQ1
       DEX                ;FIX INDEX
       JSR    FINDV
       TAY                ;SAVE
       JSR    FINDV6      ;NEXT MOVE
       LDX    TEMP9
       CPX    #$07 
       BEQ    IRQRQ1       ;STOP
       STA    TEMP4 
       CMP    CURSOR 
       BEQ    SMRHL1
       EOR    LSTCUR 
       ASL
       BNE    SMRHL3
SMRHL1
; CROSS FIRE
       LDA    #HYPSUB-W
       BNE    IRQREQ      ;JMP
SMRHL3
       LDA    PROGST 
       AND    #$20 
       BEQ    SMRHL6      ;NOT IN THE CHART!!
       TYA
       JSR    CHTERS
SMRHL6
       LDY    JMPTIM 
       LDX    LDAF5,Y
       LDA    JMPCNT,X   ;JMPCNT OR MAZSTA
       CLC
       ADC    SMHTB2-1,Y   ;INC
       STA    JMPCNT,X
       BIT    MAZRAM 
       BPL    IRQRQ1 ;NO FRIENDLY
       LDX    NEWLEV
       LDA    NCHTB5+$70,X
       LSR
       LSR
       CMP    TEMP4 
       BNE    IRQRQ1
; HIT FRIENDLY
       TYA
       LSR
       ROR
       ROR
       JSR    DOOR60
       LDA    #AUDHLP-J
       STA    CH1PTR 
       LDA    #$85           ;(WAS 99)
       STA    JMPTIM 
       BIT    GAMEST 
       BVC    IRQRQ1
SMRHL4
; ENTRY FROM DOOR
       LDA    GAMEST 
       ORA    #$40 
       STA    GAMEST 
       LDA    NEWATT 
       BEQ    IRQRQ1
       ROL
       ROL
       ROL
       AND    #$03 
       JSR    DOOR60
       LDA    #ATTSUB-W
; FALL THRU TO IRQREQ
;
IRQREQ
; DEFINE A = IRQ ADDR
       LDY    IQSTAK 
       BNE    IRQRQ1
       LDY    IQPNTR 
       DEY
       DEY
       STY    IQSTAK 
       STA    IQPNTR 
IRQRQ1
       RTS
;
DORT11
       .byte $00,$00,$0B,$11,$F2,$09,$F4,$0A
       .byte $53,$5B,$2C,$F2,$41
LDD7E  .byte $F4,$F4,$F4
;
DORTB2
       .byte FRNTYP-W,TRNTYP-W,BLKTYP-W,FIGTYP-W
       .byte ENETYP-W,PIRTYP-W,PLNTYP-W,MONTYP-W,COBTYP-W
;
DORTB9
       .byte $18,$2D,$1D,$03
DORTB8
       .byte $23,$04,$12,$2C
;
DORTB6
; INITIAL MAZRAM VALUES
       .byte $F3,$FB,$FF,$FE,$FF,$EF,$FB,$FF
       .byte $FF,$FF,$FB,$FD,$EF,$FF,$7F,$FF
;
;

DORTB4
       .byte $11,$16,$3E,$21,$24,$43,$31,$71
       .byte $37,$73,$52,$43,$21,$75,$71,$16
       .byte $11,$31,$26,$13,$37,$20,$14,$43
       .byte $35,$43,$37,$72,$16,$27,$17,$51
;
HITAB1
       .byte $60,$66,$07,$12,$A0,$4F,$03,$00
       .byte $00,$00,$02,$02,$64,$62,$83,$00
       .byte $01,$0C,$03
HITAB4
       .byte $02,$98,$9F,$AF
HITAB5
       .byte $14,$14,$14,$1A,$1E
;
;
ADDSCR
; A=VALUE
       LDY    #$00 
ADDSC3
; ENTRY FOR OTHER DIGITS
       SED
       CLC
ADDSC1
       ADC.wy SCORE,Y
       STA.wy SCORE,Y
       BCC    ADDSC2
       LDA    #$01 
       INY
       CPY    #$03 
       BCC    ADDSC1
ADDSC2
       CLD
       RTS
;
;
;
;
HITSRV
       LDA    HVERP1 
       BEQ    HITS20
       LDA    SHIPST 
       BNE    HITS20
       LDX    FUEL 
       BEQ    HITS52   ;NO FUEL BLOWUP
       LDA    PROGST 
       AND    #$B1 
       BNE    HITS20
       LDY    #$7F 
       BIT    PROGST 
       BVC    HITS14    ;A=0
;  PLAN/TRENCH
       LDY    VWALL 
       CPY    #$13 
       BCC    HITS43
       DEY
       DEY
       LDA    #$60 
HITS14
       STA    TEMP5 
       TYA
       LDY    HGRAP1+3
       BMI    HITSR3
       EOR    HOLDM0      ;FROM CLOSE!, NOT DEFINED FOR PLN/TRN
       ORA    #$C0 
       SEC
       ADC    HVERP1+3
HITSR3
       STA    TEMP4 
       LDA    MIPL
       STA    HHITP0 
       LDX    #$03 
HITSR1
       LDA    HHITP0,X
       BPL    HITSR2
       LDA    HGRAP0,X
       BMI    HITSR2
       AND    #$78 
       CMP    #$38   ;EXPLOS
       BEQ    HITSR2
       CLC
       ADC    TEMP5 
       STA    TEMP6
       CMP    #$A0 
       BEQ    HITSR2  ;CRATER
       LDA    HVERP0+0,X
       CMP    TEMP4 
       BCC    HITSR4  ;A HIT
HITSR2
       DEX
       BPL    HITSR1
HITS20
       RTS

HITS43
       TAX   ;A=0
       LDA    GAMEST 
       EOR    #$01 
       STA    GAMEST 
       LSR
       LDY    #$E8 
       STY    IQWARP 
       BCS    HITS42   ;MADE IT THRU
HITS52
       JMP    HITS25
HITSR4
       ADC    #$06     ;C=0
       STA    TEMP7 
       LDY    #$02 
HITSR5
       LDA.wy HVERP1,Y
       CMP    TEMP7 
       BCS    HITSR6
       CPY    #$00 
       BEQ    HITSR7
       LDA.wy ZPOSP1-1,Y
       BMI    HITSR6
       JMP    HITSR8
HITSR6
       DEY
       BPL    HITSR5
;  OOPS!
       RTS

HITSR7
;  HIT SHIP
       LDY    TEMP6
       CPY    #$10 
       BEQ    HITS45  ;DARTER
       LDA    ZPOSP0,X
       CMP    #$0C 
       BCS    HITSR9
       CPY    #$78 
       BNE    HITS10
; HITMAN
       LDA    #AUDCTH-J
       STA    CH1SHD 
       LDA    PROGST 
       AND    #$08 
       BNE    HITS42
       LDY    NEWAVE  ;TRENCH
       LDA    HITAB5,Y
       STA    GAMEST    ;SPEED+OPEN DOOR
       LDY    #$FC 
       BNE    HITS77   ;JMP
HITS42
       LDA    #PBLK
       STA    HGRAP0,X
       RTS

HITS10
       CPY    #$80 
       BNE    HITS13
; LZ
       CMP    #$0D 
       BCS    HITSR9
       LDA    CENTER 
       SBC    HHORP0,X
       CMP    #$04 
       BCS    HITS16
       BIT    GAMEST 
       BVS    HITS41  ;YOUR PLANET
;  TRN ENTRANCE
       LDA    #TRNTY1-W
       STA    IQPNTR 
       JMP    TIMSR7
HITS41
       INC    FUEL 
       BNE    HITS12
       DEC    FUEL 
       LDA    ONESHT 
       AND    #$8F 
       STA    ONESHT   ;FIX DAMAGE
       RTS

HITS12
       LDA    PROGST 
       ORA    #$02 
       STA    PROGST 
       LDA    #AUDFUL-J
       STA    CH1SHD 
       RTS

HITS16
       LDA    #AUDBMP-J
       LDY    #$04 
       STA    CH1PTR 
HITS77
       STY    IQWARP 
HITSR9
       RTS

HITS13
       LDA    IQWARP 
       CMP    #$F0 
       BCC    HITSR9     ;NO HITS AT HIGH SPEED
       LDA    HGRAP0,X
       CMP    #$40 
HITS45
;  FROM DARTER BRANCH
       LDY    #AUDEX4-J 
       BCS    HITS26   ;HIT MOON
       LDA    RANDOM 
       AND    #$3F 
       CMP    ZPOSP0+1
       BCS    HITS25   ;DIE
       LDA    NEWAVE 
       BEQ    HITS26 ;DAMAGE ONLY
       LDA    ONESHT 
       LSR
       AND    #$70 
       ORA    #$40 
       ORA    ONESHT 
       STA    ONESHT 
       AND    #$10 
       BEQ    HITS26 ;DAMAGE ONLY
HITS25
; ENTRY
       LDA    CENTER 
       STA    HHORP0,X
       LDA    #$0C 
       STA    ZPOSP0,X
       LDA    #VSHIP+1
       STA    HVERP0+0,X
       LDY    #AUDEXP-J
       STY    CH1PTR 
       LDA    #$00 
       STA    HVERP1 
HITS26
       STY    CH0PTR 
       JSR    ADDFL2 ;-15
       LDA    #$0E 
       STA    COLBK
       BNE    HITS15  ;JMP
HITSR8
;  HIT PHOTON
       STY    TEMP9
       LDY    TEMP6 
       CPY    #$10 
       BEQ    HITS51  ;DARTER
       LSR
       LSR
       CMP    #$08 
       BCC    HITS19
       LDA    #$07 
HITS19
       CPY    #$60 
       TAY
       LDA    ZPOSP0,X
       BCC    HITS21
       LSR   ;PLANET/TRENCH
HITS21
       CMP    HITAB2,Y
       BCS    HITSR9
       CMP    HITAB3,Y
       BCC    HITSR9
HITS51
       LDA    TEMP6
       LSR
       LSR
       LSR
       TAY
       CMP    #$0F 
       BEQ    HITSR9   ;MAN
       CMP    #$10 
       BNE    HITS18
       BIT    GAMEST 
       BVC    HITSR9   ;TRN ENTRANCE
;   LZ
       JSR    BLOWZ
HITS18
       LDA    HITAB1,Y
       PHA          ;   LOOK OUT !!
       AND    #$03 
       TAY
       LDA    HITAB4,Y
       STA    CH1PTR    ;SOUND
       PLA          ; LOOK OUT
       LSR
       AND    #$7E 
       JSR    ADDSCR
       LDY    TEMP9
       LDA.wy ZPOSP1-1,Y
       CMP    #$18 
       LDA    #$80 
       STA.wy ZPOSP1-1,Y
       LDY    #EXPTRN-EXPTAB
       LDA    PROGST 
       EOR    #$40 
       BEQ    HITS23    ;TRNCH
       LDY    #EXPFAR-EXPTAB
       BCS    HITS22
HITS15
       LDY    #EXPREG-EXPTAB
HITS22
       BIT    PROGST 
       BVC    HITS23
;  PLANET/TRENCH
       LDY    #EXPPLN-EXPTAB
       LDA    IQPATH,X
       AND    #$03 
       EOR    #$03 
       BNE    HITS23
       STA    IQWARP    ;=0 VISUAL COSMETIC?
HITS23
       STY    EXPNTR 
       LDY    #$04 
HITS62
       LDA.wy HGRAP0-1,Y
       AND    #$78 
       CMP    #$38 
       BNE    HITS63
       LDA    #$E0 
       STA.wy HGRAP0-1,Y   ;TURN OFF EXPLOS
HITS63
       DEY
       BNE    HITS62
       LDA    #$20 
       STA    PAUTIM 
       LDA    #$3F 
       STA    HGRAP0,X
       STY    XDELP0,X     ;Y=0
       STY    YDELP0,X
       STY    ZDELP0,X
       RTS
;
;
ADDFL2
; ENTRY -15
       LDA    #$F0 
ADDFUL
       SEC
       ADC    FUEL 
       BCS    ADDFL1
       LDA    #$00 
ADDFL1
       STA    FUEL 
       RTS
;
;
;
;
;
;     BANK SELECT CODE
; ORG BANK3+$0FCC
EXIT5
       STA    STROB2   ;JMP EFCF
EXIT4
       STA    STROB1   ;JMP CFD2
EXIT3
       STA    STROB4   ;JMP FFD5
       JMP    INIT
       RTS

LJOYT10
       .byte $F0,$00,$00
HORTB1
       .byte $FD,$E1,$E6
HITAB3
       .byte $00,$00,$00,$08,$10,$1C,$1E,$20
       JMP    SCANDS
EXIT2
       STA    STROB2 ;JMP EFED
EXIT1
       STA    STROB4 ;JMP FFF0
       JMP    MAIN8
       JMP    MAIN9
       .byte "DOUG N"
       .word INIT
       .word INIT
;
;
;
; ************************
;  END INCLUDE BANK3.SRC
; ************************

;
;  ******************************
;  VERSION 10.7  28-JUL-84
;COPYRIGHT (C) 1986, DOUGLAS NEUBAUER
;  BANK2.SRC FILE
;INCLUDE FOR UNIV.SRC, $E000 BANK
;  ******************************
;
;
;**********
; ORG BANK2   ; BEGIN BANK2
;**********
;
;
;
; WARNING: MUST BE ON PAGE BOUNDARY

       seg bank2
       ORG $2000
       RORG $F000
DIS500
; DISPLAY SHIP
       LDA    (MISC1),Y
       STA    GRAFP1
       BEQ    DIS501
       LDA    (MISC2),Y
       STA    COLPM1
DIS502
; ENTRY FROM WAIT SHIP, 28 CY
       STX    HDELP0
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
;
       LDA    (MISC1),Y
       TAX
       LDA    (MISC2),Y
       STA    COLPM1
       ASL
       STA    GRAFM1
       JMP.ind (VECTP0)
DIS501
       STA    GRAFM1
       DEY
       LDA    (MISC1),Y
       STA    GRAFP1
       STX    HDELP0
       LDA    #<DIS130
       STA    VECTP1
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
       LDX    #$00 
       NOP
       LDA    HCOLP1 
       STA    COLPM1
       JMP.ind (VECTP0)
DIS780
; WAIT SHIP
       LDA    #<DIS500  ;=0
       STA    VECTP1
       STA    GRAFP1
       CPY    HVERP1 
       STA    HDELP1
       BCC    DIS502
       LDA    #<DIS780
       JMP    DIS910
;
;
DIS580
; WAIT END OF SCREEN
       LDA    #$00 
       STA    GRAFP1
       DEY
       JMP    DIS912
;
;
DIS330
; HPOS PHOTON
       LDA    #<DIS370
       JMP    DIS740
;
;
DIS730
; HPOS SHIP
       LDA    #<DIS780
       JMP    DIS740
;
;
DIS130
; DISPLAY P1 PHOTON
       LDA    (MISC1),Y
       AND    (RANDOM),Y
       STA    GRAFP1
;
       DEY
DIS132
; ENTRY FROM WAIT PHOTON, 28 CY
       STX    HDELP0
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
;
       LDA    (MISC1),Y
       BNE    DIS131
       LDX    PNTRP1 
       STX    VECTP1 
       LDA    DIS500-1,X
       STA    PNTRP1 
       LDX    #$00 
       JMP.ind (VECTP0)
DIS131
       AND    (RANDOM),Y
       TAX
       LDA    #<DIS130
       STA    VECTP1
       JMP.ind (VECTP0)
;
;
DIS370
; WAIT PHOTON
       LDA    #$00 
       STA    GRAFP1
       CPY    VERTP1
       DEY
       STA.w  $0021   ; original code used .byte to get this instr
       BCC    DIS132
       CPY    VERTP1
       BCS    DIS371
       LDA    #<DIS130
       STA    VECTP1
DIS371
       JMP    DIS912
;
;
       .byte <DIS700
DIS350
; SETUP P1+1
       LDA    #$00
       STA    GRAFP1
       LDA    HVERP1+1
       STA    VERTP1
       LDA    HGRAP1+1
       STA    MISC1
       LDA    HHORP1+1 
       JMP    DIS902
;
;
DIS300
; SETUP P1+2
       LDA    #$00 
       STA    GRAFP1
       LDA    HVERP1+2 
       STA    VERTP1
       LDA    HGRAP1+2 
       STA    MISC1
       LDA    HHORP1+2
       JMP    DIS902
;
;
       .byte <DIS580
DIS700
; SETUP SHIP
       LDA    #$00 
       STA    GRAFP1
       LDA    HGRAP1 
       STA    MISC1
       STA    MISC2
; 
       LDA    HHORP1 
       STA    HDELP1
       AND    #$0F 
       STA    HOLDP1
       LDA    #<DIS730
       JMP    DIS900
;
;
JOYTB6 .byte $9F
;  SHARE 1
JOYTB1 .byte $00,$08,$F8
;  SHARE 1
JOYTB2 .byte $00,$A0,$60
;  SHARE 1
JOYTB3
;  SHARE 4
JOYTB4 .byte $00
;  SHARE 1
JOYTB5 .byte $FF,$01
;  SHARE 1
;
SATAB1
;  GRAPHIC
       .byte $00,$E0,$FC,$FF,$FF,$EF,$C7,$C7
       .byte $98,$07,$07,$01,$00,$00,$00
       .byte $00,$E0,$E0,$C0,$E0,$E0,$C0,$E0,$C0
       .byte $E6,$FE,$FC,$F8,$F0,$C0,$00,$00
;
;
;ORG BANK2+$10D  ;TEMPORARY? *********
DIS250
; WAITP0
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
;
       LDA    #<DIS200
       STA    VECTP0
       CPY    VERTP0
       BCC    DIS203
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
       LDX    #$00 
       CPY    VERTP0
       BCC    DIS206
       LDA    #<DIS250
       JMP    DIS403
;
;
DIS200
; DISPLAY P0
       STA    WSYNC
       STA    ADDEL
       LDA    (MOON1),Y
       STA    GRAFP0
       STX    GRAFP1
       LDA    (MOON3),Y
       STA    COLPM0
;
       LDA    (MOON2),Y
       STA    HDELP0
DIS203
; ENTRY FROM DIS250  ,32
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
;
       LDA    (MOON1),Y
       STA    GRAFP0
       BEQ    DIS201
       LDA    (MOON2),Y
       TAX   ;HDELP0
       LDA    (MOON3),Y
DIS206
       STA    WSYNC
       STA    ADDEL
       STA    COLPM0
       JMP.ind (VECTP1)
DIS201
; ENTRY FROM DIS400, 56 CY WORST
       TSX   ;PNTRP0
       BEQ    DIS202  ;ALL DONE P0
       DEX
       TXS
DIS205
;  ENTRY FROM TOP O SCREEN
       LDA    HVERP0,X
       STA    VERTP0
       LDA    #<DIS400
DIS204
       STA    WSYNC
       STA    ADDEL
       STA    VECTP0
       JMP.ind (VECTP1)
DIS202
       STX    VERTP0  ;VPOS=0
       LDA    #<DIS250
       JMP    DIS204
;
;
DIS400
;  SETUP P0, 1ST LINE
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
       ASL
       STA    MOON2+1  ;HOLD REG STAR GRAF.
;
       TSX
       LDA    MIPL
       STA    HHITP0+1,X  ;USES MOON2+0
       STA    HITCLR
       LDA    HHITP0,X
       STA    MOON2  ;HOLD
       LDA    HGRAP0,X
       BMI    DIS201  ;NO DISPLAY
       STA    MOON1   ;HOLD REG
       TAX
       SEC
       LDA    MTABL2,X
       SBC    VERTP0
       STA    MOON3
;
       LDX    #$00 
       LDA    #<DIS430
DIS403
       STA    WSYNC
       STA    ADDEL
       STA    VECTP0
       JMP.ind (VECTP1)
;
;
DIS430
; HPOSP0
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       LDA    MOON2  ;HOLD REG
       LDX    #<DIS460
       LSR
       BCS    DIS432  ;DELAY
DIS432
       SEC
       AND    #$07 
       BEQ    DIS433
       STX    VECTP0
       SBC    #$01 
       BEQ    DIS435
       LDX.w  MOON2+1 ;LDX ABS, STAR GRA - original code used DB $AE,MOON2+1,0
DIS431
       STX.w  GRAFM2 ;STX ABS -  original code used DB $8E,GRAFM2,0
       SBC    #$01 
       BNE    DIS431
       STA    HPOSP0
DIS434
       DEY
       STA    WSYNC
       STA    ADDEL
       LDX    MOON2
       JMP.ind (VECTP1)
DIS435
       NOP
DIS433
       STA    HPOSP0
       STX    VECTP0
       LDX    MOON2+1 
       STX    GRAFM2
       JMP    DIS434
;
;
DIS460
; SETUP P0, 2ND LINE
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
;
       LDX    MOON1  ;HOLD REG
       SEC
       LDA    MTABL1,X
       SBC    VERTP0
       STA    MOON1
       LDA    MTABL3,X
       STA    MOON3+1 
       SBC    #$00 
       STA    MOON1+1
       LDA    MTABL4,X
       LDX    #<DIS250   ;X=$0D ,IHOPE !!
       STX    VECTP0
       CMP    #<KDL8-1
       BCS    DIS461
       LDX    #$00 
DIS461
       STX    SIZPM0
       SBC    VERTP0
       STA    MOON2
       LDA    #>NULL
       SBC    #$00 
       STA    WSYNC
       STA    ADDEL
       STA    MOON2+1 
       JMP.ind (VECTP1)
;
;
DIS100
;  DISPLAY P1+3
       LDA    (MISC1),Y
       STA    GRAFP1
       LDA    (MISC2),Y
       STA    COLPM1
DIS102
; ENTRY FROM WAIT P1+3, 27CY
       STX    HDELP0
       DEY
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
;
       LDA    (MISC1),Y
       TAX
       BEQ    DIS101  ;ALL DONE
       LDA    (MISC2),Y
       STA    COLPM1
       JMP.ind (VECTP0)
DIS101
       LDA    #<DIS170
       STA    VECTP1
       JMP.ind (VECTP0)
;
;
DIS150
;  WAIT P1+3
       LDA    #<DIS100
       STA    VECTP1
       LDA    #$00 
       STA    GRAFP1
       CPY    HVERP1+3 
       STA    HDELP1
       BCC    DIS102
       BEQ    DIS901
       LDA    #<DIS150
       JMP    DIS910
;
;
DIS170
; PRESETUP P1+2
       LDA    #$00 
       STA    GRAFP1
;
       LDA    HCOLP1+1 
       STA    COLPM1  ;PHOTON COLOR
       LDA    #>PHOGR1
       STA    MISC1+1
       LDA    #>DIS300
       STA    VECTP1+1   ;PAGE CROSS !!!!!
       LDA    #>YCL1  ;SHIP COLOR
       STA    MISC2+1
       LDA    #<DIS300
       JMP    DIS900
;
;
DIS902
; ENTRY FROM PHOTON SETUP
       STA    HDELP1
       AND    #$0F 
       STA    HOLDP1
       LDA    #<DIS330
DIS900
;  MISC ENTRY
       DEY
       STX    HDELP0
       STA    VECTP1
DIS903
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
       LDX    #$00 
       JMP.ind (VECTP0)
;
DIS910
; WAIT ENTRY
       STA    CHTBLK 
DIS901
       DEY
DIS912
       CPY    BOTSCN 
       STX    HDELP0
       BNE    DIS903
; SCREEN DONE
       JMP    EXIT9   ;TO BANK 4
;
;
SATKRN
; SATURN KERNAL
       LDX    #$00 
       STX    GRAFP1
       DEY
       CPY    #$8D   ;HVERP1+3
       BCC    SATK20
       STX    HDELP1
       JMP    DIS912
SATK20
; SETUP
       LDA    #<DIS170
       STA    VECTP1
       LDA    #$25 
       STA    SIZPM1
       STA    HPOSM0
       STA    HPOSP0
       STX    HDELP0
       LDA    #$F0 
       STA    HDELM0
       LDX    #$96 
       LDA    #$82 
       BIT    GAMEST 
       BVS    SATKR9
       LDX    #$26 
       LDA    #$22 
SATKR9
       STX    COLPM0
       STA    COLPM1
       LDX    #$20 
       JMP    SATKR1
;
;
;   GRAPHICS TABLES
;
;
;  STAR TABLE AND DELTAS
 ORG $22CF
 RORG BANK2+$2CF   ;TEMPORARY *********
SHPTB4 .byte $70,$00,$50
; SHARE 1
JOYTB7 .byte $00,<(STARTB+1)
SATAB2 
; HDEL,SIZE,ETC
       .byte $00,$00,$E0,$E0,$F0,$02,$F2,$F2
       .byte $D7,$22,$F2,$F2,$92,$F2,$02,$02
       .byte $00,$F0,$00,$F0,$F0,$00,$F0,$00
       .byte $F0,$00,$00,$F0
;
; ORG BANK2+$2F0   ;TEMPOARY ********** (sic)
; NO DELTA
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
NULL
;
;   RINGS DELTA
       .byte $08,$09,$04,$06,$F4,$F9,$F8,$B8,$00,$02,$00,$09,$0C,$0E,$0C,$09
RDL1
; PLANET KILLER DELTA
       .byte $08,$18,$08,$08,$00,$F2,$00,$1D,$0E,$0C,$09,$FC
KDL8   .byte $0E,$1C,$F9,$08,$08,$08,$08,$0C,$0E,$0C,$15,$F6
KDL7   .byte $04,$11,$02,$00,$FD,$0E,$1C,$09,$08,$F8
KDL6   .byte $08,$18,$F8,$0E,$0C,$09,$08,$08,$18,$F8
KDL5
; EXPLOSION DELTA
       .byte $18,$D8,$48,$F8,$B8,$58,$98,$38
       .byte $68,$98,$C8,$58,$78,$98,$A8,$7A
       .byte $78,$A9,$98,$48,$18,$44,$A6,$34
       .byte $09,$08,$48
XDL8
       .byte $08,$0A,$08,$F1,$12,$D0,$29,$30
       .byte $A2,$30,$49,$CC,$CE,$7C,$E9,$CA
       .byte $18,$39,$18,$D8,$38,$08,$F8
XDL7
       .byte $0A,$18,$09,$F8,$E8,$28,$08,$F8
       .byte $08,$28,$B0,$42,$E0,$29,$1A,$F8
       .byte $09,$08,$10
XDL6
       .byte $02,$00,$19,$F8,$04,$16,$04,$09
       .byte $F4,$16,$04,$FD,$0E,$1C,$F9
XDL5
       .byte $08,$F8,$18,$F8,$18,$FA,$08,$19
;
STARTB
;
       .byte $F8,$0A,$08
XDL4
; CIRCLE DELTAS

       .byte $09,$04,$F6,$14,$09,$18,$08,$00
       .byte $F2,$00,$09,$0C,$0E,$0C,$09,$08
       .byte $18,$08,$08,$F0,$02,$F0,$1D,$0E
CDLF
       .byte $0C,$09,$1C,$FE,$0C,$19,$08,$08
       .byte $F8,$08,$0C,$0E,$0C,$05,$16,$04
       .byte $01,$F2,$00,$1D,$FE,$0C
CDLE
       .byte $09,$18,$F8,$18,$08,$0C,$FE,$0C
       .byte $09,$08,$08,$08,$18,$08,$08,$F8
       .byte $18,$F8
CDLC
       .byte $08,$18,$F8,$08,$18,$08,$08,$08
       .byte $08,$08,$FA,$08,$19,$F8
CDLA
;
SPDVOL
       .byte $D8,$D8,$D4,$D6,$D4,$C9,$B8
       .byte $A8,$98,$8A,$78,$61,$52,$40,$49
       .byte $30,$72,$60,$59,$4C,$3E,$3C,$29
       .byte $1A,$18,$19,$18,$18,$18,$18,$08
       .byte $0A,$08,$09,$08,$08,$08,$08,$08
       .byte $08
SPDVL1
       .byte $F8,$F0,$F2,$F0,$F9,$FA,$F8
       .byte $F9,$F8,$D0,$B2,$90,$79,$58,$34
       .byte $36,$34,$39,$34,$26,$24,$2D,$2E
       .byte $2C,$29,$28,$18,$18,$18,$18,$1A
       .byte $18,$19
;
;  END STAR TABLE
;
;  SHARE 7
PHOTB3 .byte $07,$07,$07,$07,$0B,$0A,$09,$08,$07
;
PHOTB1 
       .byte <PHOGR1+U,<PHOGR2+U,<PHOGR3+U,<PHOGR4+U
       .byte <PHOGR5+U,<PHOGR6+U,<PHOGR7+U,<PHOGR8+U
       .byte <BLANK+U
;
;
;
; PLANET KILLER
       .byte $00,$00,$08,$18,$3C,$7E,$FF,$08,$08,$FF,$7E,$3C,$18,$08
KGR8   .byte $00,$00,$08,$18,$1C,$3E,$7F,$08,$08,$7F,$3E,$1C,$18,$08
KGR7   .byte $00,$00,$08,$18,$3C,$7E,$08,$08,$7E,$3C,$18,$08
KGR6   .byte $00,$00,$08,$18,$1C,$3E,$08,$08,$3E,$1C,$18,$08
KGR5   .byte $00,$00,$18,$3C,$FF,$18,$FF,$3C,$18
KGR4   .byte $00,$00,$18,$7E,$18,$7E,$18
KGR3
       .byte $00,$00,$18
KGR1
       .byte $3C,$18
KGR2
;  RINGS
       .byte $00,$00,$0F,$3F,$FE,$F3,$E3,$C1
       .byte $0C,$18,$30,$30,$60,$7C,$F8,$E0
RGR8   .byte $00,$00,$0F,$3F,$7F,$73,$71,$06,$06,$0C,$18,$18,$3C,$38
RGR7   .byte $00,$00,$7C,$FE,$E6,$C2,$0C,$18,$18,$3C,$38
RGR6   .byte $00,$00,$3C,$7E,$76,$62,$06,$04,$0F,$0C
RGR5   .byte $00,$00,$0F,$1F,$12,$60,$40,$E0,$C0
RGR4   .byte $00,$00,$0E,$1E,$30,$20,$60,$60
RGR3   .byte $00,$00,$0C,$18,$38,$20
RGR2   .byte $00,$00,$08,$10,$20
RGR1
;
;  RING COL
CR
       .byte $68,$68,$68,$66,$66,$66,$66,$66
       .byte $66,$68,$68,$68,$68,$68
;
;  PLANET KILLER COL
CK
       .byte $00,$A4,$A6,$A8,$AA,$AC,$AE,$AE,$AC,$AA,$A8,$A6,$A4
;
;
LINTB3
       .byte <SHP4+1,<SHP3+1,<SHP3+1,<SHP2+1
       .byte <SHP2+1,<SHP1+1,<SHP1+1,<SHP1+1
;
;
 ORG $2500
 RORG BANK2+$500    ;TEMPOARY ********** (sic)
;
; FIGHTER
       .byte $00,$00,$24,$66,$C3,$99,$99,$FF,$7E,$3C,$7E,$CF,$7E,$48
FGR8
       .byte $00,$00,$3C,$7E,$DB,$99,$FF,$7E,$3C,$7E,$C3,$7E,$24
FGR7
       .byte $00,$00,$18,$3C,$7E,$FF,$7E,$3C,$7E,$F3,$7E,$12
FGR6
       .byte $00,$00,$24,$66,$42,$42,$7E,$3C,$6E,$3C,$28
FGR5   .byte $00,$00,$18,$3C,$7E,$3C,$76,$3C,$14
FGR4   .byte $00,$00,$28,$6C,$44,$7C,$38,$7C,$28
FGR3   .byte $00,$00,$10,$38,$38,$28
FGR2   .byte $00,$00,$10,$10
FGR1
; PIRATES
       .byte $00,$00,$C3,$81,$81,$A5,$FF,$BD,$99,$81,$C3
PGR8   .byte $00,$00,$63,$41,$55,$7F,$5D,$49,$63
PGR7   .byte $00,$00,$66,$42,$5A,$7E,$5A,$42,$66
PGR6   .byte $00,$00,$36,$22,$3E,$22,$36
PGR5   .byte $00,$00,$24,$3C,$3C,$24
PGR4   .byte $00,$00,$14,$14,$14
PGR3   .byte $00,$00,$18,$18
PGR2
       .byte $00,$00,$08
PGR1
;
;ORG BANK2+$584     ;TEMPOARY ********** (sic)
;  P1 PHOTONS
       .byte $00,$00,$10,$38,$7C,$7C,$7C,$38,$10
PHOGR1
       .byte $00,$00,$10,$38,$7C,$7C,$38,$10
PHOGR2
       .byte $00,$00,$18
PHOGR7
       .byte $3C,$3C,$3C,$18
PHOGR3
PHOGR4
       .byte $00,$00,$10,$38,$38,$10
PHOGR5
       .byte $00,$00
BLANK
       .byte $10
PHOGR8
       .byte $38,$10
PHOGR6
;
; FIGHTER COL
CF
       .byte $54,$56,$58,$5A,$5C,$58,$58,$5E,$5C,$5A,$58,$5E,$5E
;  PIRATE COL
CP
       .byte $1E,$1E,$18,$16,$14,$16,$18,$1E,$1E
       .byte $1A,$12,$12,$1A
;
;
;ORG BANK2+$5C1  ;TEMPOARY ********** (sic)
;  YOUR SHIP GRAPHIC
; NORMAL
       .byte $00,$00,$08,$0C,$0E,$1E,$0C,$04
       .byte $00,$04,$00,$F1,$7F,$3F,$1F,$1F
       .byte $0E,$0E,$04,$04
YGR1
; BANK RIGHT
       .byte $00,$00,$20,$30,$38,$78,$30,$10
       .byte $00,$1B,$00,$6F,$FE,$FC,$FC,$78
       .byte $38,$30,$10,$10
YGR2
; BANK LEFT
       .byte $00,$00,$10,$18,$1C,$3C,$18,$08
       .byte $00,$D8,$00,$E4,$7F,$3F,$3F,$1E
       .byte $1C,$0C,$08,$08
YGR3
;
;
 ORG $2600
 RORG BANK2+$600   
;
; BLOCKADER
       .byte $00,$00,$18,$3C,$81,$CB,$FF,$CB,$81,$3C,$18
BGR8
       .byte $00,$00,$18,$18,$20,$30,$38,$30,$20,$18,$18
BGR7
       .byte $00,$00,$18,$18,$04,$0C,$1C,$0C,$04,$18,$18
BGR6
       .byte $00,$00,$18,$40,$60,$70,$60,$40,$18
BGR5
       .byte $00,$00,$18,$02,$0E,$0E,$0E,$02,$18
BGR4
       .byte $00,$00,$10,$44,$7C,$44,$10
BGR3
       .byte $00,$00,$10
BGR1
       .byte $28,$10
BGR2
;
; JUMP GRAPHIC
       .byte $00,$00,$0C,$60,$06,$18,$C3,$0C,$60,$18
DGR8
; DARTER
       .byte $00,$00,$08,$1C,$3E,$1C,$08
DGR3   .byte $00,$00,$08,$1C,$08,$04
DGR2   .byte $00,$00,$0C,$08,$04
DGR1
; ENEMY BULLETS
       .byte $00,$00,$08,$08,$1C,$3E,$1C,$08,$08
EGR6    byte $00,$00,$36,$1C,$08,$1C,$36,$04
EGR5   .byte $00,$00,$08,$08,$1C,$08,$08
EGR4   .byte $00,$00,$14,$08,$14,$04
EGR3   .byte $00,$00,$08,$1C,$08
EGR2   .byte $00,$00,$08,$04
EGR1
;
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00
;
;  ENEMY PHODON COLOR
CE
       .byte $9E,$8E,$7E,$6E,$7E,$8E,$9E,$00
;  DARTER COL
CD
       .byte $44,$48,$48,$00,$00,$42,$44,$48,$48,$46
       .byte $46,$48,$8A,$8C,$8C,$8E,$8E,$8A
; BLOCKADER COL
CB
       .byte $88,$CA,$C6,$CA,$88,$86,$CE,$CC
       .byte $CA,$CC,$CE,$86,$88
;
;
;
;       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
 ORG $26C6
 RORG BANK2+$6C6   ;TEMPOARY ********** (sic)
; YOUR SHIP COLORS
       .byte $00,$00,$00
       .byte $00,$00,$00,$6D,$6B,$79,$76,$84
       .byte $84,$92,$A2,$A0
YCL1
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$6C,$6A,$79,$76,$84
       .byte $84,$92,$A2,$A0
;
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$6C,$6A,$79,$76,$84
       .byte $84,$92,$A2,$A0
;
;
 ORG $2700
 RORG BANK2+$700  ; TEMPOARY ********** (sic)
;
; HYPERJUMPER
       .byte $00,$00,$5A,$7E,$3C,$FF,$99,$99,$BD,$FF,$7E,$3C
HGR8
HGR7
HGR6
       .byte $00,$00,$24,$3C,$7E,$5A,$5A,$7E,$3C,$18
HGR5
HGR4
       .byte $00,$00,$28,$3C,$6C,$54,$7C,$38
HGR3
       .byte $00,$00,$10,$38,$38
HGR2
       .byte $00,$00,$10
HGR1
; EXPLOSION
       .byte $00,$00,$20,$08,$80,$20,$02,$20,$08,$84
       .byte $40,$01,$81,$81,$20,$04,$11,$40
       .byte $84,$02,$01,$02,$20,$04,$01,$80
       .byte $02,$40,$04,$40
XGR8
       .byte $00,$00,$08,$20,$82,$08,$20,$04,$08,$80
       .byte $15,$89,$80,$24,$50,$A0,$45,$40
       .byte $02,$48,$02,$49,$80,$A0,$02,$28
XGR7
       .byte $00,$00,$28,$10,$80,$04,$40,$84,$10,$05
       .byte $40,$84,$22,$80,$41,$84,$A0,$04
       .byte $08,$A0,$02,$50
XGR6
       .byte $00,$00,$14,$08,$20,$12,$44,$20,$12,$89
       .byte $04,$20,$08,$90,$02,$21,$08,$14
XGR5
       .byte $00,$00,$14,$28,$02,$44,$08,$2A,$54,$02
       .byte $48,$10,$24,$08
XGR4
       .byte $00,$00,$22,$7F,$7F,$7F,$FE,$FF,$FF,$7F,$3E,$38
XGR3
       .byte $00,$00,$30,$7C,$7C,$7C,$3C,$38
XGR2
       .byte $00,$00,$10,$38,$38,$10
XGR1
;
; HYPERJUMPER COL
CHCOL
       .byte $84,$84,$84,$88,$8A,$8E,$8C,$8A,$88,$86
       .byte $48,$4C,$48,$46,$42,$42,$42,$C4,$C6,$CA
       .byte $C8,$C6,$C6,$C4,$84,$84,$84,$44,$44,$48
       .byte $46,$44,$44,$42
;
;  EXPLOS COLOR
CX
       .byte $8E,$8E,$8E,$AA,$8E,$AA,$AA,$8E
       .byte $8E,$8E,$AA,$AA,$8E,$8E,$AA,$8E
       .byte $8E,$AA,$AA,$8E,$AA,$8E,$8E,$AA
       .byte $AA,$8E,$8E,$8E
       .byte $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
       .byte $1E,$1E
;
;
SHPTB5
       .byte $08,$14,$1C,$0E,$2C
;
LINTB5 .byte $F5,$F5,$F5,$F4
       .byte $F4,$F2,$F2,$F2
;
;
;  APPROX. E800  ******
;
;   CIRCLES
       .byte $00,$00,$3C,$7E,$7E,$FF,$FF,$FF,$FF,$FF,$7E,$7E,$3C
CGR8   .byte $00,$00,$1C,$3E,$3E,$7F,$7F,$7F,$7F,$3E,$3E,$1C
CGR7   .byte $00,$00,$3C,$7E,$7E,$7E,$7E,$7E,$3C
CGR6   .byte $00,$00,$1C,$3E,$3E,$3E,$3E,$1C
CGR5   .byte $00,$00,$18,$3C,$3C,$3C,$18
CGR4   .byte $00,$00,$08,$1C,$1C,$08
CGR3   .byte $00,$00,$18,$18
CGR2   .byte $00,$00,$08
CGR1
       .byte $00
       .byte $00,$00,$18,$3C,$3E,$7E,$7E,$FE,$FE,$FE
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
       .byte $FE,$FE,$FE,$7E,$7E,$3E,$3C,$18
CGRF
       .byte $00,$00,$00
;
       .byte $00,$00,$08,$1C,$3C,$3E,$3E,$7E,$7E,$7E
       .byte $7F,$7F,$7F,$7F,$7F,$7F,$7E,$7E
       .byte $7E,$3E,$3E,$3C,$1C,$08
CGRE
       .byte $00,$00,$18,$38,$3C,$7C,$7C,$7C,$7E,$7E
       .byte $7E,$7E,$7E,$7E,$7C,$7C,$7C,$3C
       .byte $38,$18
CGRC
       .byte $00,$00,$18,$38,$3C,$3C,$7C,$7C,$7C,$7C
       .byte $7C,$7C,$3C,$3C,$38,$18
CGRA
;
; CIRCLE COLOR
CC2
       .byte $42,$44,$46,$48,$46,$44,$44,$46
       .byte $48,$46,$48,$48,$46,$46,$46,$48
       .byte $48,$46,$44,$42,$40,$42,$44,$44
CC1
       .byte $82,$82,$82,$82,$84,$84,$86,$86
       .byte $88,$88,$8A,$8A,$8C,$8C,$8E,$8E
       .byte $8E,$8C,$8A,$88,$86,$84,$82,$80
CC4
       .byte $A2,$A2,$A2,$A2,$A2,$A2,$A2,$A2
       .byte $A2,$A2,$A2,$A2
;
;
;
;
SATKR2
       LDA    (STARS),Y
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
       LDA    XDL4-3,X  ;MOON
       STA    HDELP1
SATKR1
       STA    WSYNC
       STA    ADDEL
       LDA    SATAB1-1,X 
       STA    GRAFP0
       LDA    CGR1-1,X   ;MOON
       STA    GRAFP1
       LDA    SATAB2-1,X
       STA    GRAFM0
       STA    HDELP0
       AND    #$05 
       ORA    #$10 
       STA    SIZPM0
       DEY
       DEX
       BNE    SATKR2
       BIT    SHIPST 
       BPL    SATKR3
       STY    COLPM1    ;SHIP COLOUR
       LDA    #>DIS700    ;SHIP GO!
       STA    VECTP1+1 
       LDA    #<DIS700
       STA    VECTP1
SATKR3
       LDA    #$20 
       STA    SIZPM1
       JMP.ind (VECTP0)
;
;
;
MTABL1

       .byte <FGR8+U,<FGR7+U,<FGR6+U,<FGR5+U,<FGR4+U,<FGR3+U,<FGR2+U,<FGR1+U
       .byte <PGR8+U,<PGR7+U,<PGR6+U,<PGR5+U,<PGR4+U,<PGR3+U,<PGR2+U,<PGR1+U
       .byte <DGR8+U,0,0,0,<DGR3+U,<DGR2+U,<DGR2+U,<DGR1+U
       .byte <HGR8+U,<HGR7+U,<HGR6+U,<HGR5+U,<HGR4+U,<HGR3+U,<HGR2+U,<HGR1+U
       .byte <KGR8+U,<KGR7+U,<KGR6+U,<KGR5+U,<KGR4+U,<KGR3+U,<KGR2+U,<KGR1+U
       .byte <BGR8+U,<BGR7+U,<BGR6+U,<BGR5+U,<BGR4+U,<BGR3+U,<BGR2+U,<BGR1+U
       .byte <EGR6+U,<EGR5+U,<EGR6+U,<EGR5+U,<EGR4+U,<EGR3+U,<EGR2+U,<EGR1+U
       .byte <XGR8+U,<XGR7+U,<XGR6+U,<XGR5+U,<XGR4+U,<XGR3+U,<XGR2+U,<XGR1+U
       .byte <RGR8+U,<RGR7+U,<RGR6+U,<RGR5+U,<RGR4+U,<RGR3+U,<RGR2+U,<RGR1+U
       .byte <CGRF+U,<CGRE+U,<CGRC+U,<CGRA+U,<CGR8+U,<CGR7+U,<CGR6+U,<CGR5+U
       .byte <CGR4+U,<CGR3+U,<CGR2+U,<CGR1+U
       .byte <CGRF+U,<CGRE+U,<CGRC+U,<CGRA+U,<CGR8+U,<CGR7+U,<CGR6+U,<CGR5+U
       .byte <CGR4+U,<CGR3+U,<CGR2+U,<CGR1+U
;
MTABL2
;  COLORS
; FIGHTER
Z EQM <CF
       .byte Z+$D,Z+$D,Z+$D,Z+$E,Z+$E,Z+$D,Z+$8,Z+$E
; PIRATE
Z EQM <CP
       .byte Z+$A,Z+$9,Z+$9,Z+$8,Z+$E,Z+$7,Z+$7,Z+$A
; DARTER
Z EQM <CD
       .byte Z+$13,0,0,0,Z+$B,Z+$5,Z+$5,Z+$6
; HJUMPER
Z EQM <CHCOL
       .byte Z+$B,Z+$19,Z+$23,Z+$A,Z+$18,Z+$F,Z+$C,Z+$7
; PKILLER
Z EQM <CK
       .byte Z+$E,Z+$E,Z+$D,Z+$D,Z+$C,Z+$B,Z+$A,Z+$9
; BLOCKADER
Z EQM <CB
       .byte Z+$E,Z+$E,Z+$E,Z+$D,Z+$D,Z+$6,Z+$5,Z+$E
; ENEMY PHOTON
Z EQM <CE
       .byte 0,0,Z+$8,Z+$9,Z+$8,Z+$9,Z+$8,Z+$9
; EXPLOSION
Z EQM <CX
       .byte Z+$1D,Z+$1B,Z+$19,Z+$17,Z+$1D,Z+$27,Z+$27,Z+$27
; RINGS
Z EQM <CR
       .byte Z+$0F,Z+$0F,Z+$0F,Z+$0F,Z+$0F,Z+$0F,Z+$0F,Z+$0F
;  MOON1 COLOR
Z EQM <CC1
       .byte Z+$19,Z+$18,Z+$16,Z+$14,Z+$14,Z+$11,Z+$10,Z+$0F
       .byte Z+$0D,Z+$0D,Z+$0D,Z+$0D
;  MOON2 COLOR
Z EQM <CC2
       .byte Z+$19,Z+$18,Z+$16,Z+$14,Z+$14,Z+$11,Z+$10,Z+$0F
       .byte Z+$0D,Z+$0D,Z+$0D,Z+$0D
;
;
;
DISPLY
;  ENTRY FROM VBLANK
       CLC
       SBC    STARS   ;A=0
       STA    CROSP1
       LDA    #$20   ;M=X4
       STA    SIZPM1
       LDA    #$80 
       STA    HDELM2
       LDA    RANDOM+1 
       STA    HDELM1
       LDA    #>DIS205
       STA    VECTP0+1
       STA    RANDOM+1 
       LDA    STARS+1
       STA    HDELP1
       STA    WSYNC
       STA    ADDEL
       AND    #$0F 
       LDX    #>STARTB
       STX    STARS+1
       LDX    #>DIS150
       STX    VECTP1+1 
       LSR
       BCS    DISPL2  ;DELAY
DISPL2
       BEQ    DISPL9
DISPL1
       SEC
       NOP
       SBC    #$01 
       BNE    DISPL1
       NOP
DISPL9
       STA    HPOSP1
;  2 SPARE CY
       STA    WSYNC
       STA    ADDEL
       LDX    HGRAP1+3
       LDA    MTABL2,X
       CPX    #$48 
       BCC    DISPL7
       LDA    #<CC4+$0D  ;MOON COLOR
DISPL7
       SEC
       SBC    HVERP1+3 
       STA    MISC2
; C=1  I HOPE
       LDA    MTABL1,X
       SBC    HVERP1+3
       STA    MISC1
       LDA    MTABL3,X
       STA    MISC2+1 
       SBC    #$00 
       STA    MISC1+1
       LDX    PNTRP1 
       TXS   ;PNTRP0
       LDA    #<DIS350
       STA    PNTRP1 
       LDY    #TOPSCN
       JMP    DIS205
;
;
;
MTABL3
;  MOON1+1
Z EQM >FGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >PGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >DGR8
       .byte Z,0,0,0,Z,Z,Z,Z
Z EQM >HGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >KGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >BGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >EGR6
       .byte 0,0,Z,Z,Z,Z,Z,Z
Z EQM >XGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >RGR8
       .byte Z,Z,Z,Z,Z,Z,Z,Z
Z EQM >CGRF
       .byte Z,Z,Z,Z,Z,Z,Z,Z
       .byte Z,Z,Z,Z
       .byte Z,Z,Z,Z,Z,Z,Z,Z
       .byte Z,Z,Z,Z
;
;
;
;
MTABL4
; MOON2+0, HDEL
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte <KDL8+U,<KDL7+U,<KDL6+U,<KDL5+U,0,0,0,0
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte <XDL8+U,<XDL7+U,<XDL6+U,<XDL5+U,XDL4+U,0,0,0
       .byte <RDL1+U,<RDL1-1+U,<RDL1-3+U,<RDL1-4+U,0,0,0,0
       .byte <CDLF+U,<CDLE+U,<CDLC+U,<CDLA+U,0,0,0,0
       .byte $00,$00,$00,$00
       .byte <CDLF+U,<CDLE+U,<CDLC+U,<CDLA+U,0,0,0,0
       .byte $00,$00,$00,$00
;
;
;
;
;
;    END KERNALS BANK 2
;
;
;   SUBROUTINES
;
;
;
JOYSTK
       LDX    #$00 
       STX    JOYRMH
       STX    JOYRMV
       LDA    PORTA
       CMP    #$FF 
       BEQ    JOYS68
       STX    ATRACT+1 
       LSR    PROGST 
       ASL    PROGST 
JOYS68
       BIT    MAZSTA 
       BMI    JOYS35   ;NEGATIVE UNIVERSE
       EOR    #$FF 
JOYS35
       STA    TEMP12
       LSR
       LSR
       LSR
       LSR
       AND    #$03 
       TAY
       LDA    PROGST 
       AND    #$B3 
       BNE    JOYS49
       LDA    ATRACT 
       AND    #$07 
       BNE    JOYS77
;  SPEED STUFF
       LDX    IQWARP 
       BPL    JOYS31
       LDA    SHIPST 
       AND    #$30 
       BEQ    JOYS40
       CPX    #$E0 
       BCS    JOYS31
       AND    #$10 
       BNE    JOYS41
       CPX    #$D9 
       BCS    JOYS31
       LDA    #$10  ;HWARP
       STA    PROGST 
       LDA    #$28 
       STA    ZDELP0+1
       LDA    #$30 
       STA    ZDELP0 
       LDA    #$4B 
       STA    YDELP0 
       LDA    #$49 
       STA    YDELP0+1
       LDA    #AUDTAK-J
       STA    CH0PTR 
JOYS41
       LDA    #AUDTAK-J
       STA    CH1PTR 
       LDA    #$05 
       STA    IQWARP   ;??
       LDA    #$00 
       STA    HCOLP1+1  ;SHIP TAKEOFF Z
       LDA    #$80 
       ORA    SHIPST   ;SAVE TYPE OF TAKEOFF
       STA    SHIPST   ;SHIP TAKEOFF
JOYS49
       RTS

JOYS40
       CPX    #$F1 
       BCC    JOYS32
       LDA    GAMEST   ;JOYSTK SPEED DELTA
       AND    #$1C 
       LSR
       LSR
       ADC    IQWARP   ;C=0
       BCS    JOYS31
       TAX
       CPX    #$F4 
       BCC    JOYS32
       CPX    #$FC 
       BCS    JOYS32
       BIT    PROGST 
       BVC    JOYS34
;  PLANET/TRENCH
       LDA    JOYT13,Y
       ASL
       BNE    JOYS32
JOYS34
       CPX    #$F9 
       BEQ    JOYS30
JOYS32
       INC    IQWARP 
       BCC    JOYS30
       DEC    IQWARP 
JOYS31
       DEC    IQWARP 
JOYS30
       JMP    JOYS24
JOYS77
;
;  VERTICAL
;   Y=VERT
       LSR
       BCC    JOYS24
       LDA    HHORM2 
       CLC
       ADC    JOYTB1,Y
       CMP    #$A0 
       BCC    JOYS20
;  C=1
       SBC    JOYTB2,Y
JOYS20
       STA    HHORM2 
;
;  STAR VERTICAL STUFF
       LDA    STARS 
       CLC
       ADC    JOYTB3,Y
       CMP    #<[STARTB+2]
       BCC    JOYS21
       LDA    JOYTB7,Y
JOYS21
       STA    STARS 
JOYS24
       LDA    JOYT11,Y
       STA    JOYRMV
;
; HORIZONTAL
       LDX    #$01 
       STX    THGRP1
       LDY    VELOC 
       BIT    TEMP12
       BPL    JOYST2
       BVS    JOYST4
; RIGHT
;  X=1
       CPY    #$1F 
       BEQ    JOYS11
JOYST3
       INY
       JMP    JOYS12
JOYST2
       BVC    JOYST4
; LEFT
       INX  ; X=2
       CPY    #$E0 
       BEQ    JOYST7
JOYST5
       DEY
JOYS12
       LDA    #$4E 
       STA    HCOLP1 
       BNE    JOYST7  ;jmp
JOYST4
;  NULL
       DEX   ;X=0
       TYA
       BMI    JOYST3
       BNE    JOYST5
JOYST7
       STX    THGRP1
       STY    VELOC 
;
       LDX    #$01 
       TYA
       BPL    JOYST6
       INX
JOYST6
       ASL
       ASL
       ASL
       CLC
       ADC    HPOSL 
       STA    HPOSL 
JOYS11
       LDA    JOYTB4-1,X
       ADC    CENTER 
       CMP    #$74 
       BCS    JOYST9
       CMP    #$2D 
       BCC    JOYST9
       STA    CENTER 
JOYST8
       RTS

JOYST9
       CLC
       LDA    HHORM2 
       ADC    JOYTB5-1,X
       CMP    #$A0 
       BCC    JOYS10
       LDA    JOYTB6-1,X
JOYS10
       STA    HHORM2 
       LDA    THGRP1
       BEQ    JOYST8
       LDA    #$00 
       CPX    THGRP1
       BNE    JOYS79
       LDA    JOYT14-1,X
JOYS79
       STA    VELOC 
       LDA    PROGST 
       CMP    #$40 
       BEQ    JOYST8    ;TRENCH
       LDA    JOYT12-1,X
       STA    JOYRMH
       RTS
;
;
;
AUDTAB
J EQU AUDTAB    ;EQUATE
       .byte $10,$00
AUDEXP
       .byte $0F,$88,$C6,$E9,$E7
AUDRMP
       .byte $08,$E4,$E5,$C6,$A7,$A8,$C9,$EA
       .byte $EB,$CC,$CC,$ED,$EE,$EE,$EF,$F0
       .byte $F0,$F1,$D1,$D2,$B2,$B3,$93,$94
       .byte $94,$75,$75,$56,$56,$57,$37,$38
       .byte $38,$39,$39,$39,$1A,$1A,$1A,$1B
       .byte $1B,$10,$00
AUDPHN
       .byte $08,$A2,$0F,$E6,$83,$C8,$84,$CA
       .byte $85,$89,$88,$89,$68,$6B,$6A,$6B
       .byte $4B,$4C,$4D,$4E,$4F,$31,$31,$32
       .byte $32,$2E,$2F,$11,$12,$13,$10,$00
AUDLOW
       .byte $04,$12,$12,$12,$12,$12,$12,$12
       .byte $38,$38,$38,$38,$38,$38,$38,$00
AUDFUL
       .byte $0F,$65,$42,$00
AUDMAN
       .byte $04,$27,$46,$68,$8A,$00
AUDTAK
       .byte $08,$20,$42,$64,$86,$C4,$E5,$E7
       .byte $C9,$CB,$AD,$E9,$EB,$ED,$CF,$D1
       .byte $D3,$F5,$F5,$F6,$F6,$F6,$D6,$D6
       .byte $D6,$B6,$B5,$94,$94,$73,$73,$73
       .byte $72,$52,$52,$52,$31,$31,$31,$11
       .byte $11,$11,$10,$00
AUDEX2
       .byte $03,$EE,$85,$66,$08,$05,AUDTAK-J+$12
AUDEX3
       .byte $10,$10,$08,$F0,$E1,$E4,$E3
       .byte $05,AUDRMP-J+6
AUDEX4
       .byte $0F,$E4,$C8,$AC,$08,$05,AUDRMP+$11-J
AUDEX5
       .byte $08,$E5,$E2,$E7,$E4,$FF,$05,AUDRMP-J+$21
AUDEX6
       .byte $08,$05,AUDTAK+5-J
AUDSHT
       .byte $08,$28,$66,$82,$05,AUDPHN-J+$A
AUDLNH .byte $08,$41,$8E,$A1,$8B,$00
AUDVAR .byte $04,$14,$13,$12,$11,$00
AUDCTH
       .byte $04,$2C,$2B,$2E,$69,$48,$27,$00
AUDBMP
       .byte $0F,$E8,$84,$CF,$8E,$6F,$6E,$4D
       .byte $4C,$4B,$2A,$29,$28,$27,$26,$10,$00
AUDJMP
       .byte $08,$21,$22,$43,$6C,$6A,$68,$87
       .byte $86,$85,$A3,$C1,$E4,$FF,$10,$00
AUDHLP
       .byte $04,$10,$51,$4F,$53,$00
;
;
;
SHPTB1
       .byte $8E,$8C,$8E,$8C,$8A,$88,$86,$84
       .byte $82,$80,$82,$80,$82,$80,$82,$80
;
SHPTB2
       .byte $8F,$8D,$8F,$8C,$8F,$8C,$8B,$8C
       .byte $8A,$8D,$8A,$8C,$89,$8A,$88,$8A
       .byte $88,$8D,$88,$86,$84,$86,$84,$83
       .byte $84,$80,$82,$80,$82,$80,$83,$80
;
;
;
SHPSRV
;  SHIP GRAPHICS, ETC
       LDA    SHIPST 
       BMI    SHPSR1  ;SHIP TAKEOFF
       CMP    #$20 
       BNE    SHPSR4
;  HWARP SPEEDUP
       LDA    #$05 
       STA    TARNUM   ;HYP CURSOR
       LDY    #PBLK
       STY    IQREAP ;GRAPH
       LDX    #$FF 
       LDA    #$50 
       STA    PLINES 
       SBC    CENTER 
       BCS    SHPS55
       LDX    #$01 
       EOR    #$FF 
SHPS55
       LSR
       CMP    #$04 
       BCC    SHPS56
       LDX    #$00 
       LDA    #$03 
SHPS56
       STA    IQPATH-1      ;DISPLAY JMP QUAL.
;
       LDA    ATRACT 
       LSR
       LSR
       LSR
       LDA    IQWARP 
       ROL
       SBC    #$AE 
       CMP    #$31 
       BCS    SHPS21
       CMP    #$10 
       BCC    SHPSR6
       LDA    #$0F 
SHPSR6
       TAY
       LDA    SHPTB1,Y
       STA    COLBK
       LDY    NEWAVE 
       LDA    RANDOM 
       CMP    SHPTB5,Y
       BCS    SHPS21
       TXA
       ADC    CENTER   ;C=0
       STA    CENTER 
SHPS21
       LDA    ATRACT 
       LSR
       LDA    #$50 
       BCC    SHPS20
SHPSR4
;  NORMAL SHIP
       LDA    CENTER 
SHPS20 LDX    THGRP1
       STA    RANDOM+1 
       CLC
       ADC    JOYTB8,X  ;HOFFSET
       STA    HHORP1 
       LDA    JOYTB9,X
       JMP    SHPSR5
SHPSR1
       LDY    HCOLP1+1 
       BIT    PROGST 
       BVC    SHPSR3
;  PLANET/TRENCH
       LDA    #$02 
       STA    GCTLM1  ;FIX M1 GLITCHES
       CPY    #$13    ;$13 FOR TRENCH
       BCS    SHPSR3
       INC    HVERP1  ;PLANET TAKEOFF FIX
SHPSR3
       LDA    RANDOM 
       AND    #$03 
       TAX
       LDA    SHPTB4,X
       CPY    #$20 
       BCS    SHPSR7
       LDA    SHPTB2,Y
SHPSR7
       STA    COLBK
       STA    ZDELP0-1  ;HOLD BAK COLOR
       LDA    #$4A 
       STA    HCOLP1 
       LDA    HOLDM0    ;FROM HYPSRV
       LSR
       LSR
       LSR
       LSR
       AND    #$07 
       CLC
       ADC    HVERP1 
       STA    HVERP1 
       TYA
       LSR
       LSR
       TAX
       CMP    #$08 
       BCC    SHPSR2
       LDX    #$07 
SHPSR2
       INC    HCOLP1+1 
       LDA    LINTB5,X
       SEC
       SBC    HVERP1 
       STA    ATRACT+1    ;SHIP COLOR PNTR
       LDA    LINTB3,X
SHPSR5
       SEC
       SBC    HVERP1 
       STA    HGRAP1 
;   FALL THRU
;
PHOTON
; FIRE PHOTON TORPEDO
       BIT    SHIPST 
       BPL    PHOT97
       RTS   ;USING SHIP RAM DURING TAKEOFF
PHOT55
       LDA    PAUTIM 
       BNE    PHOTN5 ;WAIT
       LDA    ONESHT 
       ORA    #$02 
       STA    ONESHT 
       BNE    PHOTN5 ;JMP
PHOT97
       LDX    TRIG0
       BMI    PHOTN5
       LDY    #$00 
       STY    ATRACT+1 
       BIT    ONESHT 
       BPL    PHOTN5
       LDA    PROGST 
       BMI    PHOT55   ;GAME OVER
       CPY    HVERP1         ;Y=0
       BEQ    PHOTN5
       AND    #$F8 
       CMP    PROGST 
       STA    PROGST 
       BNE    PHOTN5
       LDA    ZPOSP1 
       BMI    PHOT44
       LDA    ZPOSP1+1 
       CMP    #$31 
       BCS    PHOT56
       BCC    PHOTN8   ;JMP
PHOT44
;  LOAD PHOTON
       LDA    #AUDPHN-J
       STA    CH0PTR 
       STY    ZPOSP1    ;Y=0
       LDA    ONESHT 
       AND    #$7F      ;ONESHT
       EOR    #$04 
       STA    ONESHT 
       AND    #$04 
       BEQ    PHOT11
       LDY    FUEL 
       BEQ    PHOT11
       DEC    FUEL 
PHOT11
       SEC
       ADC    CENTER 
       STA    HOLDM2 
       LDA    #VSHIP+$09
       STA    HVERP1+1
       BNE    PHOTN8     ;JMP
PHOTN5
       ASL    ONESHT 
       TXA
       ASL
       ROR    ONESHT 
       LDA    ZPOSP1 
       BMI    PHOTN8
       CMP    #$09 
       BCC    PHOTN8
       LDA    ZPOSP1+1 
       BPL    PHOTN8
PHOT56
;  TRANSFER
       LDA    ZPOSP1 
       STA    ZPOSP1+1 
       LDA    HVERP1+1 
       STA    HVERP1+2 
       LDA    HHORP1+1 
       STA    HHORP1+2
       LDA    #$80  ;TURN OFF
       STA    ZPOSP1 
PHOTN8
;
       LDA    #$08 
       STA    HCOLP1+1 
       LDX    #$01 
PHOTN1
       LDY    ZPOSP1-1,X
       BPL    PHOTN3
       LDA    HVERP1-1,X
       BNE    PHOT29
       LDA    #VSHIP  ;EXPLODED SHIP
PHOT29
       CLC
       ADC    #$06 
       STA    HVERP1,X
       LDY    #$08 
       BNE    PHOT27   ;JMP
PHOTN3
;  PHOTON ON
       LDA    VECTP1-1,X   ;HOLD ZOOMTB FROM HYPRSRV
       AND    #$70 
       LSR
       LSR
       LSR
       LSR
       ADC    HVERP1,X     ;C=0
       STA    HVERP1,X
       INC    ZPOSP1-1,X
       TYA
       LSR
       LSR
       LDY    #$07 
       CMP    #$08 
       BCS    PHOT27
       LDY    #$0E 
       STY    HCOLP1+1  ;PHOTON COLOR 
       TAY
PHOT27
       LDA    PHOTB1,Y
       SEC
       SBC    HVERP1,X
       STA    HGRAP1,X
       INX
       CPX    #$03 
       BCC    PHOTN1
; VERT SPACING
       LDA    HVERP1+2  ;SIMPLIFY?
       SBC    PHOTB3,Y   ;C=1
       CMP    HVERP1+1
       BCS    PHOT28
       INC    HVERP1+2 
       DEC    HGRAP1+2   ;ADJ 
       LDA    HVERP1+1
       CMP    #$4D 
       BIT    PROGST 
       BVC    PHOT83
;  PLN/TRN
       CMP    #$4B 
PHOT83
       BCC    PHOT28
       LDA    ZPOSP1 
       BMI    PHOT28
       LDA    #$80 
       STA    ZPOSP1+1 
PHOT28
       RTS
;
;
;
;
AUDIO
       LDA    ATRACT 
       AND    #$01 
       TAX
       LDY    CH0PTR,X
       LDA    AUDTAB,Y
       BNE    AUDIO2
       LDA    PROGST 
       AND    #$81 
       BNE    AUDIO1
       LDY    CH0SHD,X
       STY    CH0PTR,X
       STA    CH0SHD,X
       RTS

AUDIO5
       CMP    #$05 
       BNE    AUDIO4
;  JUMP
       LDA    AUDTAB+1,Y
       STA    CH0PTR,X
       RTS

AUDIO4
       STA    AUDC0,X
       RTS

AUDIO2
       INC    CH0PTR,X
       CMP    #$10 
       BCC    AUDIO5
       BEQ    AUDIO3
       STA    AUDF0,X
       LSR
       LSR
AUDIO1
       LSR
       LSR
AUDIO3
       STA    AUDV0,X
       CPY    #AUDHLP-J
       BCC    AUDIO9
       LDA    ATRACT 
       AND    #$1E 
       BEQ    AUDIO9
       DEC    CH0PTR,X         ;REPEAT NOTE
AUDIO9
;    ENGINE AUDIO
       LDA    CH1PTR 
       CMP    #$02 
       BCS    AUDIO6  ;CHANEL IN USE
       LDY    IQWARP 
       BPL    AUDIO6
       TYA
       CMP    #$F2 
       BCS    AUDIO7
       ADC    #$3A   ;3A=1D*2  C=0
       ROR
AUDIO7
       TAX
       STA    AUDF1
       LDA    SHIPST 
       CMP    #$20 
       BNE    AUDIO8
       LDA    CH0PTR 
       CMP    #$02 
       BCS    AUDIO8
       DEX
       STX    AUDF0  ;HWARP
       LDA    #$08 
       STA    AUDC0
       LDA    SPDVL1-$D8,Y
       LSR
       LSR
       LSR
       LSR
       STA    AUDV0
AUDIO8
       LDA    #$08 
       STA    AUDC1
       LDA    SPDVOL-$D8,Y
       LSR
       LSR
       LSR
       LSR
       LDY    #$F0 
       CPY    PORTA
       ADC    #$01   ;C=1=MOVE JOYSTK
       STA    AUDV1
AUDIO6
       RTS
;
;
DIS740
;  HPOSP1
       STA    VECTP1
       LDA    #$00 
       STA    GRAFP1
       DEY
       LDA    HOLDP1
       LSR
       BCS    DIS742  ;DELAY
DIS742
       BEQ    DIS741   ;CY 39-40
       STX    HDELP0
       CMP    #$02 
       BCS    DIS743  ;CY 57-58
;  CY 48-49
       LDA    RANDOM  ;DUMMY
       STA    HPOSP1
       LDA    (STARS),Y
       JMP    DIS744
DIS743
       CPY    CROSP1 ;FIX STAR BUG
       BCC    DIS745
DIS745
       LDA    (STARS),Y
       STA    HPOSP1
DIS744
       STA    GRAFM2
       ORA    #SCLR
       STA    COLPF
       LDX    #$00 
       JMP.ind (VECTP0)
DIS741
       STA    HPOSP1
       STX    HDELP0
       LDA    (STARS),Y
       JMP    DIS744
;
;
;  BANK SELECT CODE
 ORG $2FCC
 RORG BANK2+$FCC

PON2
       STA    STROB1      ;JMP CFCF
       JSR    JOYSTK
       JSR    AUDIO
       STA    STROB3      ;JMP DFD8
JOYTB8 .byte $00,$02,$01
JOYTB9
       .byte <YGR1+2,<YGR2+2,<YGR3+2
;       .byte $D7,$EB,$FF
EXIT9
       STA    STROB4      ;JMP FFE1
       JSR    SHPSRV
       STA    STROB4      ;JMP FFE7
JOYT11 .byte $00,$06,$FA,$00
JOYT12 .byte $F9,$07
       JMP    DISPLY
JOYT13 .byte $00,$FF,$01,$00
JOYT14 .byte $1F,$E0
       .byte "DOUG N"
       .word PON2
       .word PON2

;
; ********************************
;   VERSION 11.2   31-JUL-84
;COPYRIGHT (C) 1986, DOUGLAS NEUBAUER
; INCLUDE BANK4.SRC FOR UNIV.SRC
; ********************************
;
;
;*********
       seg bank4
       ORG $3000
       RORG BANK4   ;BEGIN BANK4
;  ALWAYS F000
;*********
;
;
; WARNING: MUST BE ON PAGE BOUNDARY
PLN500
; DISPLAY SHIP
       STA    COLBK
       LDA    (MISC1),Y
       STA    GRAFP1
       BEQ    PLN501
       LDA    (MISC2),Y
       STA    COLPM1
PLN502
       DEY
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN503
       LDA    (MISC1),Y
       TAX
       LDA    (MISC2),Y
       STA    COLPM1
       ASL
       STA    GRAFM1
       LDA    #SURCOL 
       JMP.ind (VECTP0)
PLN503
       LDA    (MISC1),Y
       TAX
       LDA    (MISC2),Y
       STA    COLPM1
       ASL
       STA    GRAFM1
       LDA    #$00 
       JMP.ind (VECTP0)
PLN501
       DEY
       LDA    (MISC1),Y
       STA    GRAFP1
       STY    GRAFM1
       LDA    #<PLN130  ;WARNING BIT 1 MUST =0
       STA    GRAFM1   ;KLUDGE HWARP STARS FIX !!!!!
       STA    VECTP1
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN504
       LDA    #SURCOL
PLN504
       LDX    HCOLP1 
       STX    COLPM1
       LDX    #$00 
       JMP.ind (VECTP0)
;
PLN780
; WAIT SHIP
       STA    COLBK
       LDA    #<PLN500  ;=0
       STA    VECTP1
       STA    GRAFP1
       CPY    HVERP1 
       STA    HDELP1
       BCC    PLN502
       LDX    #<PLN780
       JMP    PLN910
;
;
HYP780
;  WAIT HYPERSHIP
       STA    COLBK
       LDA    #<PLN500  ;=0
       STA    VECTP1
       CPY    HVERP1 
       STA    HDELP1
       BCC    PLN502
       BEQ    PLN581
       LDX    #<HYP780
       JMP    PLN910
;
;
PLN580
; WAIT END OF SCREEN
       STA    COLBK
       LDA    #$00 
       STA    GRAFP1
PLN581
       DEY
       JMP    PLN911
;
;
PLN330
; HPOS PHOTON
       LDX    #<PLN370
       JMP    PLN740
;
;
PLN730
; HPOS SHIP
       LDX    #<PLN780
       JMP    PLN740
;
;
HYP730
;  HPOS HYPERSHIP
       LDX    #<HYP780
       JMP    PLN740
;
;
       .byte $00,$00
;  WARNING BIT 1 OF PLN130 MUST=0 FOR HWARP STARS FIX!!!
PLN130
; DISPLAY P1 PHOTON
       STA    COLBK
       LDA    (MISC1),Y
       AND    (RANDOM),Y
       STA    GRAFP1
;
       DEY
PLN132
; ENTRY FROM WAIT PHOTON, 27 CY
;
       LDA    (MISC1),Y
       BNE    PLN131
       LDX    PNTRP1 
       STX    VECTP1 
       LDA    PLN500-1,X
       STA    PNTRP1 
       LDX    #$00 
PLN134
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN133
       LDA    #SURCOL
PLN133
       JMP.ind (PNTR1)
PLN131
       AND    (RANDOM),Y
       TAX
       LDA    #<PLN130
       STA    VECTP1
       BNE    PLN134   ;JMP
;
;
PLN370
; WAIT PHOTON
       STA    COLBK
       LDA    #$00 
       STA    GRAFP1
       CPY    VERTP1
       DEY
       STA    HDELP1
       BCC    PLN132
       CPY    VERTP1 
       BCS    PLN371
       LDA    #<PLN130
       STA    VECTP1
PLN371
       JMP    PLN912
;
;
       .byte <PLN700
PLN350
;SETUP P1+1
       STA    COLBK
       LDA    #$0
       STA    GRAFP1
       LDA    HVERP1+1 
       STA    VERTP1
       LDA    HGRAP1+1
       STA    MISC1
       LDA    HHORP1+1 
       JMP    PLN902
;
;
       .byte <PLN580
PLN700
; SETUP SHIP
       STA    COLBK
       LDA    #$0
       STA    GRAFP1
       LDA    HGRAP1 
       STA    MISC1
       STA    MISC2
; 
       LDA    HHORP1 
       STA    HDELP1
       AND    #$0F 
       STA    HOLDP1
       LDA    #<PLN730
       JMP    PLN900
;
;
;
;   P0 KERNALS
;
PLN207
       STX    HDELP0
       STA    WSYNC
       STA    ADDEL
       STX    SIZPM0
       JMP.ind (VECTP1)
PLN250
;  WARNING: LOW PLN250 MUST BE <$10
; WAIT P0
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
;
       LDA    #$00 
       STA    COLPM0
       LDA    #<PLN200
       STA    VECTP0
       CPY    VERTP0 
       BCC    PLN203
       DEY
       CPY    VERTP0
       BCC    PLN206  ;MUST HAVE C=0
       BCS    PLN259  ;JMP
;
;
PLN200
; DISP P0
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       LDA    (MOON1),Y
       STA    GRAFP0
       STX    GRAFP1
       LDA    (MOON3),Y
       STA    COLPM0
PLN203
;  27 CY
       DEY
       LDA    (MOON1),Y
       STA    GRAFP0
       BEQ    PLN201
;
       LDA    (MOON3),Y
       TAX
       LSR
;
PLN206
;  ENTRY C=0!!
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN204
       LDA    #SURCOL
PLN204
       BCS    PLN207
PLN209
;  ENTRY
       STA    WSYNC
       STA    ADDEL
       STX    COLPM0
       JMP.ind (VECTP1)
PLN201
;  41 CY
       TSX
       BEQ    PLN202
       DEX
       TXS
       LDA    HVERP0,X
       STA    VERTP0
;
       LDX    #<PLN400
       JMP    PLN402
PLN202
       STX    PNTR3 
PLN259
       JMP    PLN462
;
;
PLN400
; SETUP P0, 1ST LINE
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
       TSX
       LDA    MIPL
       STA    HHITP0+1,X
       STA    HITCLR
       DEY
       LDA    HGRAP0,X
       BMI    PLN201
       STA    MOON1  ;HOLD
       LDA    HHITP0,X
       STA    HDELP0
       AND    #$0F 
       STA    MOON3  ;HOLD
       LDA    (MOON2),Y
       AND    CROSP1
       BEQ    PLN403
       LDA    #SURCOL
PLN403
       STA    MOON3+1
;
       LDX    #<PLN430
PLN402
;  ENTRY
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN401
       LDA    #SURCOL
PLN401
       STA    WSYNC
       STA    ADDEL
       STX    VECTP0
       JMP.ind (VECTP1)
;
;
PLN430
; HPOSP0
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
       LDX    #<PLN460
       LDA    MOON3
       LSR
       BCS    PLN431   ;DELAY
PLN431
       BEQ    PLN432
       STX    VECTP0
PLN433
       SEC
       NOP
       SBC    #$01 
       BNE    PLN433
       STA    HPOSP0
PLN434
       DEY
       STA    WSYNC
       STA    ADDEL
       LDA    MOON3+1   ;LINE LOOK AHEAD
       JMP.ind (VECTP1)
PLN432
       STA.w  HPOSP0     ;STA ABS HPOSP0 (ORIG = DB $8D,HPOS0,0)
       STX    VECTP0
       BEQ    PLN434   ;JMP
;
;
PLN800
; PLOW UP PLANET
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       CPY    #$50 
       BCS    PLN804
       LDA    (RANDOM),Y
       CMP    YDELP0-1   ;PROB.
       ROL
       ROL
       STA    GRAFM0
PLN804
       DEY
       LDA    #$0E 
       STA    COLPM0
       LDA    HCOLP1 
       LDX    #$00 
       STX    SIZPM0
       STA    WSYNC
       STA    ADDEL
       STX    GRAFM0
       JMP.ind (VECTP1)
;
;
;
PLN460
; SETUP P0, 2ND LINE
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
       LDX    MOON1  ;HOLD
       LDA    PTABL4,X
       STA    SIZPM0
       SEC
       LDA    PTABL2,X
       SBC    VERTP0
       STA    MOON3
       LDA    PTABL1,X
       SBC    VERTP0 
       STA    MOON1
       LDA    PTABL3,X
       STA    MOON3+1 
       SBC    #$00 
       STA    MOON1+1
       DEY
PLN462
;  ENTRY
       LDX    #<PLN250
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN461
       LDA    #SURCOL
PLN461
       STX    HDELP0  ; X<$10
       STA    WSYNC
       STA    ADDEL
       STX    VECTP0
       JMP.ind (VECTP1)
;
;
;
PLN902
; ENTRY FROM PHOTON SETUP
       STA    HDELP1
       AND    #$0F 
       STA    HOLDP1
       LDA    #<PLN330
PLN900
;  MISC ENTRY
       DEY
       STA    VECTP1
PLN903
       LDA    (STARS),Y
       AND    CROSP1
       BEQ    PLN905
       LDA    #SURCOL
PLN905
       LDX    #$00 
       JMP.ind (VECTP0)
;
PLN910
; WAIT ENTRY
       DEY
       STX    VECTP1
PLN911
;  END SCREEN ENTRY
       CPY    #$06    ;BUG, WANT 4 FOR HYPER
       BNE    PLN912
       STA    GRAFM2  ;A=0 FOR TRENCH
PLN912
       CPY    #$00 
       BNE    PLN903
       JMP    EXIT8   ;TO SCANDS
;
;
HYP250
; TOP HALF
       STX    YDELP0+3  ;TEMP
       LDX    WALLTB+1+8,Y   ;TRENCH FIX
       LDA    WALLTB+0+8,Y
       STA    GRFPF0,X
       DEY
       DEY
       LDX    YDELP0+3
HYP256
;  ENTRY FROM TOP O SCREEN
       LDA    LINTB4,X
       ASL
       STA    WSYNC
       STA    ADDEL
       STA    GRAFM1
       ROR
       CPX    YDELP0  ;VPOS2
       BCS    HYP251
       CPX    YDELP0+1 ;VPOS1
       BCS    HYP252
HYP251
       LDA    ZDELP0-1  ;DEFAULT
HYP252
       STA    COLBK
       INX
       TXA
       AND    #$03 
       BEQ    HYP250
       CPX    #$4D 
       BNE    HYP256
;  MIDDLE O SCREEN
       LDA    #$10 
       STA    HDELM2
       LDA    #$F0 
       STA    HDELM0
       LDX    #$00
;  Y=$4C    ,I HOPE.
;  FALL THRU TO HYP200
;
;
HYP200
; BOT HALF 
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       STA    GRAFM1
       LDA    ZDELP0-1  ;DEFAULT
       CPY    YDELP0    ;VPOS2
       BCS    HYP201
       CPY    YDELP0+1  ;VPOS1
       BCC    HYP201
       LDA    LINTB4,Y
HYP201
       STA    COLBK
       DEY
       LDX    WALLTB,Y
       LDA    WALLTB-1,Y
       STA    GRFPF0,X
       LDA    ZDELP0-1
       CPY    YDELP0    ;VPOS2
       BCS    HYP203
       CPY    YDELP0+1  ;VPOS1
       BCC    HYP203
       LDA    LINTB4,Y
HYP203
       LDX    #$00 
       STA    WSYNC
       STA    ADDEL
       STX    GRAFM1
       JMP.ind (VECTP1)
;
;
TRN251
       LDA    #TRNCOL
       STA    COLPF
       LDA    #$8A 
       STA    GRAFM2
       STA    GRAFM0
       CPY    VWALL 
       DEY
       BCS    TRN254
       LDX    #$10 
       STX    HDELM2
       LDX    #$F0 
       STX    HDELM0
       LDX    #<TRN250
       BNE    TRN259   ;JMP
TRN254
       CPY    YDELP0-1  ;VWIND
       BCS    TRN252
       LDA    #SURCOL
TRN252
; ENTRY
       LDX    #<TRN255
       BNE    TRN259     ;JMP
;
;
TRN207
       STX    HDELP0
       STA    WSYNC
       STA    ADDEL
       LDX    SIZPM0     ;DUMMY, NO CRATERS
       JMP.ind (VECTP1)
;
TRN256
;  SETUP PF
       LDA    #$00 
       STA    COLBK
       STA    GRFPF2
       LDY    VWALL 
       LDX    WALLTB-7,Y
       BNE    TRN257
       STA    GRFPF1
TRN257
       LDA    WALLTB-8,Y
       STA    GRFPF0,X
       LDY    #$55   ;RESTORE
       LDA    #$00 
       BEQ    TRN252     ;JMP
;
;
TRN255
;  DOING WALL
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       JMP    TRN251
;
;
TRN200
; DISPL P0
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       LDA    (MOON1),Y
       STA    GRAFP0
       STX    GRAFP1
       LDA    (MOON3),Y
       STA    COLPM0
TRN203
;  27 CY
       DEY
       LDX    WALLTB-6,Y
       LDA    WALLTB-7,Y
       STA    GRFPF0,X
       LDA    (MOON1),Y
       STA    GRAFP0
       BEQ    TRN201
;
       LDA    (MOON3),Y
       TAX
       LSR
;
TRN206
;  ENTRY C=0!!
       LDA    #SURCOL
       BCS    TRN207
       STA    WSYNC
       STA    ADDEL
       STX    COLPM0
       JMP.ind (VECTP1)
TRN201
;  53 CY
       TSX
       BEQ    TRN202
       DEX
       TXS
       LDA    HVERP0,X
       STA    VERTP0
;
       LDX    #<TRN400
TRN402
; ENTRY
       LDA    #SURCOL
TRN259
;  ENTRY FROM WALL
       STA    WSYNC
       STA    ADDEL
       STX    PNTR1 
       JMP.ind (VECTP1)
TRN202
       STX    PNTR3 
TRN403
;  ENTRY
       LDX    #<TRN250
       BNE    TRN402  ;JMP
;
;
TRN250
;    WAIT P0
       STA    WSYNC
       STA    ADDEL
       STX    GRAFP1
       CPY    #$56       ;TOP OF TRENCH
       BEQ    TRN256
       STA    COLBK
       LDA    #<TRN200
       STA    VECTP0
       CPY    VERTP0
       BCC    TRN203
       DEY
       LDX    WALLTB-6,Y
       LDA    WALLTB-7,Y
       STA    GRFPF0,X
       LDX    #TRNCOL     ;M0 COLOR
       STX    COLPM0
       CPY    VERTP0
       BCC    TRN206  ;MUST HAVE C=0
       BCS    TRN403  ;JMP
;
;
TRN400
; SETUP P0, 1ST LINE
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
       LDA    #TRNCOL
       STA    COLPM0
       DEY
       LDX    WALLTB-6,Y
       LDA    WALLTB-7,Y
       BEQ    TRN401
       LDA    WALLTB-9,Y
TRN401
       STA    GRFPF0,X
       TSX
       LDA    MIPL
       STA    HHITP0+1,X
       STA    HITCLR
       LDA    HGRAP0,X
       BMI    TRN201
       STA    MOON1   ;HOLD
       LDA    HHITP0,X
       STA    HDELP0
       AND    #$0F 
       STA    MOON3  ;HOLD
       LDX    #<TRN430
       LDA    #SURCOL
       STA    WSYNC
       STA    ADDEL
       STX    VECTP0
       JMP.ind (VECTP1)
;
;
TRN430
; HPOSP0
       STA    WSYNC
       STA    ADDEL
       STA.w  COLBK    ;STA ABS COLBK (ORIG=DB $8D,COLBK,0)
       STX    GRAFP1
       LDX    #<TRN460
       LDA    MOON3
       LSR
       BCS    TRN431  ;DELAY
TRN431
       BEQ    TRN432
       DEY
TRN433
       SEC
       NOP
       SBC    #$01 
       BNE    TRN433
       STA    HPOSP0
TRN434
       LDA    #SURCOL
       STA    WSYNC
       STA    ADDEL
       STX    VECTP0
       JMP.ind (VECTP1)
TRN432
       STA    HPOSP0
       DEY
       JMP    TRN434
;
;
;
TRN460
; SETUP P0, 2ND LINE
       STA    WSYNC
       STA    ADDEL
       STA    COLBK
       STX    GRAFP1
       LDX    MOON1  ;HOLD
       LDA    PTABL4,X
       SEC
       BMI    TRN462   ;KEY
       STA    SIZPM0
       LDA    PTABL2,X
       SBC    VERTP0
       STA    MOON3
       LDA    PTABL1,X
       SBC    VERTP0 
       STA    MOON1
       LDA    PTABL3,X
       STA    MOON3+1
       SBC    #$00 
TRN463
;  52CY
       STA    MOON1+1
       DEY
       LDX    WALLTB-6,Y
       LDA    WALLTB-7,Y
       STA    GRFPF0,X
       STX    HDELP0  ;X=0,1,2
       LDA    #SURCOL
       LDX    #<TRN250  ;WARNING: NO WSYNC!!!!!
       STA    ADDEL
       STX    VECTP0
       JMP.ind (VECTP1)
;
TRN462
;  KEY
       LDA    #$20 
       STA    SIZPM0
       LDA    #<YPC1+7
       SBC    VERTP0
       STA    MOON3
       LDA    KEYTB1-$18,X
       SBC    VERTP0
       STA    MOON1
       LDA    #>YPL4
       STA    MOON3+1
       BNE    TRN463  ;JMP
;
;
PLN740
; HPOSP1
       STA    COLBK
       LDA    #$00 
       STA    GRAFP1
       STX    VECTP1
       LDA    HOLDP1
       LSR
       BCS    PLN742   ;DELAY
PLN742
       BNE    PLN741
       STA    HPOSP1   ;CY 39-40
       DEY
       JMP    PLN746
PLN741
       DEY
       CMP    #$02 
       BCC    PLN743
       LDA    (STARS),Y
       NOP
       NOP
       NOP
       STA    HPOSP1  ;CY-57-58
PLN744
       AND    CROSP1
       BEQ    PLN745
       LDA    #SURCOL
PLN745
       LDX    #$00 
       JMP.ind (VECTP0)
PLN743
; CY 48-49
       STA.w  HPOSP1 ;STA ABS HPOSP1 (ORIG=DB $8D,HPOSP1,0)
PLN746
       LDA    (STARS),Y
       JMP    PLN744
;
;
;
HYPER
; SETUP HYPERSPACE
       LDA    ATRACT+1   ;SHIP COLOR
       STA    MISC2
       LDA    #>HYP730
       STA    VECTP1+1 
       LDA    #<HYP730
       STA    VECTP1
       LDA    #$70 
       STA    HDELM2
       LDA    #$50 
       STA    HDELM0
       STA    WSYNC
       STA    ADDEL
       LDA    #$00 
       STA    VDELM2
       STA    SIZPM1
       LDA    HCOLP1 
       STA    COLPM1
       LDA    #$30 
       STA    SIZPM0
       LDA    #$31 
       STA    PRIOR
       LDA    #<PLN580
       STA    PNTRP1 
       LDA    HHORP1 
       STA    HDELP1
       AND    #$0F 
       STA    HOLDP1
       LDA    #>SHP4
       STA    MISC1+1 
       STA    MISC2+1
       LDA    HGRAP1 
       STA    MISC1
       LDA    #>LINTB4
       STA    STARS+1
       LDA    #$10 
       STA    CROSP1
       STA    WSYNC
       STA    ADDEL
       LDA    #$02 
       STA    GRAFM2
       STA    GRAFM0
       LDA    #>HYP200
       STA    VECTP0+1
       LDA    #<HYP200
       STA    VECTP0
       LDA    #$10 
       STA    HDELM0
       LDA    #$F0 
       STA    HDELM2
       LDA    #<LINTB4  ;STAR PATTERN
       STA    STARS    ;DISP M1 STARS
       STA    HPOSM1
       LDA    #$80 
       STA    HDELM1
       LDA    ZDELP0-1
       STA    COLPF
       STA    COLPM0   ;A=COLOR
       LDX    #$00 
       LDY    #TOPSCN-$27  ;HOPEFULLY
       JMP    HYP256
;
;
PLNTB4 .byte $F0,$F0,$B0,$90,$00,$00
;
; PAGE 5 (MORE OR LESS)
;
; TRENCH TOWER
       .byte $00,$00,$24,$66,$FF,$18,$3C,$5E,$0F,$5E,$3C,$18
RPL8   .byte $00,$00,$24,$66,$FF,$18,$3C,$66,$DB,$66,$3C,$18
RPL7   .byte $00,$00,$24,$66,$FF,$18,$3C,$7A,$F8,$7A,$3C,$18
RPL6   .byte $00,$00,$24,$7E,$18,$3C,$0E,$0E,$3C,$18
RPL5   .byte $00,$00,$24,$7E,$18,$3C,$66,$66,$3C,$18
RPL4   .byte $00,$00,$24,$7E,$18,$3C,$70,$70,$3C,$18
RPL3   .byte $00,$00,$24,$3C,$18,$3C,$18
RPL2   .byte $00,$00,$18
RPL1
;  MISC GRAPHIC
       .byte $00,$00,$24,$66,$E7,$FF,$7E,$3C,$66,$42,$5A,$42
NPL8
NPL7
NPL6
       .byte $00,$00,$28,$6C,$FE,$7C,$38,$6C,$44,$54
NPL5
NPL4
NPL3
       .byte $00,$00,$10,$38,$38,$38,$28
NPL2
       .byte $00,$00,$10,$10
NPL1
;
;  MISC GRA COLORS
NCL1
       .byte $1A,$6A,$68,$66,$64,$8C,$8C,$8C,$8C,$1E
       .byte $1E,$4C,$4A,$48,$46,$8C,$8C,$1E,$1E,$8C
;
;
;ORG BANK4+$584   ;TEMPOARY *****
;
PLN198
;  P1 PHOTONS
       .byte $00,$00,$10,$38,$7C,$7C,$7C,$38,$10
       .byte $00,$00,$10,$38,$7C,$7C,$38,$10
       .byte $00,$00,$18
       .byte $3C,$3C,$3C,$18
       .byte $00,$00,$10,$38,$38,$10
       .byte $00,$00
       .byte $10
       .byte $38,$10
;
;  MISC GRA COLORS CONT.
NCL2
       .byte $1A,$8A,$88,$86,$84,$1E,$1E,$8C,$8C,$8C
;  TRN TWR COLOR
RCL1
       .byte $56,$58,$5A,$58,$5A,$5C,$5E,$5C,$5A,$58
;
PLNTB2 .byte $FF,$FF,$D7,$C3,$83,$81
;
;ORG BANK4+$5C1  ;TEMPOARY ********
;  YOUR SHIP GRAPHIC
; NORMAL
       .byte $00,$00,$08,$0C,$0E,$1E,$0C,$04
       .byte $00,$04,$00,$F1,$7F,$3F,$1F,$1F
       .byte $0E,$0E,$04,$04
; BANK RIGHT
       .byte $00,$00,$20,$30,$38,$78,$30,$10
       .byte $00,$1B,$00,$6F,$FE,$FC,$FC,$78
       .byte $38,$30,$10,$10
; BANK LEFT
       .byte $00,$00,$10,$18,$1C,$3C,$18,$08
       .byte $00,$D8,$00,$E4,$7F,$3F,$3F,$1E
       .byte $1C,$0C,$08,$08
 ORG $3600
 RORG BANK4+$600   ;TEMPOARY **********
;
;
;   MAN
       .byte $00,$00,$04,$04,$04,$2C,$38,$38,$08,$3C,$7E,$42,$5A
WPL8
       .byte $00,$00,$24,$24,$3C,$18,$08,$7E,$DB,$81,$18
WPL7
       .byte $00,$00,$20,$20,$20,$34,$1C,$5A,$42,$7E,$3C,$08,$18
WPL6
       .byte $00,$00,$08,$08,$28,$38,$10,$38,$7C,$54
WPL5
       .byte $00,$00,$28,$38,$10,$7C,$FE,$10
WPL4
       .byte $00,$00,$20,$20,$28,$38,$54,$7C,$38,$10
WPL3
       .byte $00,$00,$10,$10
WPL1
       .byte $10,$38,$10
WPL2
;
;  PLN PIRATE
       .byte $00,$00,$81,$C3,$66,$7E,$3C,$18,$18,$90,$F0,$60
PPL8
       .byte $00,$00,$81,$C3,$66,$7E,$3C,$18,$18,$3C,$3C,$18
PPL7
       .byte $00,$00,$81,$C3,$66,$7E,$3C,$18,$18,$09,$0F,$06
PPL6
       .byte $00,$00,$42,$66,$3C,$3C,$18,$50,$70,$20
PPL5
       .byte $00,$00,$42,$66,$3C,$3C,$18,$18,$3C,$18
PPL4
       .byte $00,$00,$42,$66,$3C,$3C,$18,$0A,$0E,$04
PPL3
       .byte $00,$00,$24,$3C,$18,$08,$04
PPL2
       .byte $00,$00,$18,$08
PPL1
;
;
;  PLN PIR COLORS
PCL1
       .byte $6A,$5A,$48,$46,$46,$46,$48,$4A,$4A,$4C
;  MAN COLORS
WCL1
       .byte $8A,$8A,$8A,$8A,$8A,$8A,$62,$18,$18,$18,$1C
       .byte $8A,$8A,$8A,$8A,$8A,$8A,$18,$18,$18,$62,$1C
       .byte $8A,$8A,$8A,$8A,$8A,$48,$18,$1C
       .byte $88,$88,$88,$46,$48
;
PLANT1 .byte $80,$8E,$80,$81
;
 ORG $36C6     
 RORG BANK4+$6C6    ;TEMPOARY  *******
; YOUR SHIP COLORS
       .byte $00,$00,$00
       .byte $00,$00,$00,$1D,$1B,$29,$26,$34
       .byte $34,$42,$42,$40
;
KEYTB1
       .byte <YPL4+U,<YPL4+U,<YPL4+U,<YPL3+U,<YPL3+U,<YPL3+U,<YPL2+U,<YPL1+U
;       .byte $DE,$DE,$DE,$E4,$E4,$E4,$E8,$EB
;
       .byte $00,$00,$00,$1C,$1A,$29,$26,$34
       .byte $34,$42,$42,$40
;
SURTB1
       .byte $01,$02,$04,$08,$10,$20,$40
       .byte $80,$00,$00,$00,$1C,$1A,$29,$26,$34
       .byte $34,$42,$42,$40
;
;
 ORG $3700
 RORG BANK4+$700     ;TEMPOARY ********
;
; CRATER
       .byte $00,$00,$40,$88,$84,$82,$C6,$FE,$FC,$F8,$E0
CPL8   .byte $00,$00,$40,$90,$88,$CC,$F8,$F0,$C0
CPL7   .byte $00,$00,$30,$48,$F8,$F0,$C0
CPL6   .byte $00,$00,$3C,$42,$FF,$7E
CPL5   .byte $00,$00,$44,$FE,$7C
CPL4   .byte $00,$00,$6C,$3E
CPL3   .byte $00,$00,$68,$3C
CPL2   .byte $00,$00,$EF
CPL1
;
; EXPLOS GRAPHIC
       .byte $00,$00,$08,$04,$40,$02,$04,$10,$81,$02
       .byte $20,$04,$10,$40,$01,$04,$20,$08
XPL8
       .byte $00,$00,$10,$04,$20,$08,$02,$10,$04,$41
       .byte $04,$10,$04,$20,$04,$10
XPL7
       .byte $00,$00,$08,$04,$20,$0A,$18,$14,$4A,$10
       .byte $04,$24,$14,$28
XPL6
       .byte $00,$00,$08,$14,$08,$20,$14,$2A,$04,$10
       .byte $04,$10
XPL5
       .byte $00,$00,$08,$20,$42,$34,$98,$22,$44,$28
XPL4
       .byte $00,$00,$10,$44,$18,$28,$24,$10
XPL3
;
;
;  PLN FIGHTER
       .byte $00,$00,$81,$C3,$E7,$18,$3C,$18,$E7,$C3,$81
FPL8
FPL7
FPL6
       .byte $00,$00,$42,$66,$18,$18,$66,$42
FPL5
FPL4
FPL3
       .byte $00,$00,$24,$18,$24
FPL2
       .byte $00,$00,$18
FPL1
;
;
; EXPLOS COLOR
XCL1
       .byte $BC,$15,$1E,$F5,$BC,$15,$1E,$F5
       .byte $BC,$15,$1E,$F5,$BC,$15,$1E,$BC
;
       .byte $1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
;
; CRATER COLORS
CCL1
       .byte $C7,$60,$E7,$60,$07,$60,$27,$00,$47
       .byte $60,$60,$E7,$60,$27,$00,$47
       .byte $60,$60,$00,$00
;
;  FIGHTER COLOR
FCL1
       .byte $1A,$1A,$1A,$4E,$4E,$4E,$AC,$AC
       .byte $AC,$1A,$1A,$1A,$4E,$4E,$4E
;
;  KEY GRAPHIC
       .byte $00,$00,$05,$42,$A5,$BF,$A0,$40
YPL4
       .byte $00,$00,$0A,$24,$5E,$20
YPL3
       .byte $00,$00,$0C,$3C
YPL2
       .byte $00,$00,$18
YPL1
;  KEY COLOR
YPC1
       .byte $1C,$1C,$1C,$1C,$1C,$1C
;
;
;
CHTAB7
;  CHART COLORS
       .byte $80,$30,$D6,$F0,$62,$B0,$06,$42
       .byte $50,$86,$70,$D0,$A0,$10,$A6,$00
;
PTABL1
;   CANT CROSS PAGE
; MOON1+0 GRAPHICS PNTR.
       .byte <FPL8+U,<FPL7+U,<FPL6+U,<FPL5+U,<FPL4+U,<FPL3+U,<FPL2+U,<FPL1+U
       .byte <PPL8+U,<PPL7+U,<PPL6+U,<PPL5+U,<PPL4+U,<PPL3+U,<PPL2+U,<PPL1+U
       .byte <NPL8+U,<NPL7+U,<NPL6+U,<NPL5+U,<NPL4+U,<NPL3+U,<NPL2+U,<NPL1+U
       .byte <WPL8+U,<WPL7+U,<WPL6+U,<WPL5+U,<WPL4+U,<WPL3+U,<WPL2+U,<WPL1+U
       .byte <LPL8+U,<LPL7+U,<LPL6+U,<LPL5+U,<LPL4+U,<LPL3+U,<LPL2+U,<LPL1+U
       .byte <RPL8+U,<RPL7+U,<RPL6+U,<RPL5+U,<RPL4+U,<RPL3+U,<RPL2+U,<RPL1+U
       .byte <EPL6+U,<EPL5+U,<EPL6+U,<EPL5+U,<EPL4+U,<EPL3+U,<EPL2+U,<EPL1+U
       .byte <XPL8+U,<XPL7+U,<XPL6+U,<XPL5+U,<XPL4+U,<XPL3+U,<XPL3+U,<XPL3+U
       .byte <CPL8+U,<CPL7+U,<CPL6+U,<CPL5+U,<CPL4+U,<CPL3+U,<CPL2+U,<CPL1+U
;
;
;
PTABL3 
       .byte $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
       .byte $F6,$F6,$F6,$F6,$F6,$F6,$F6,$F6
       .byte $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5
       .byte $F6,$F6,$F6,$F6,$F6,$F6,$F6,$F6
       .byte $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8
       .byte $F5,$F5,$F5,$F5,$F5,$F5,$F5,$F5
       .byte $FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC
       .byte $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
       .byte $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
;
;
;  LANDING ZONE
       .byte $00,$00,$FF,$81,$81,$81,$FF,$FF,$FF,$DB,$C3,$FF
LPL8   .byte $00,$00,$FE,$82,$82,$FE,$FE,$D6,$C6,$FE
LPL7   .byte $00,$00,$7E,$42,$42,$7E,$7E,$66,$7E
LPL6   .byte $00,$00,$7C,$44,$44,$7C,$6C,$7C
LPL5   .byte $00,$00,$FF,$81,$FF,$E7,$FF
LPL4   .byte $00,$00,$7E,$42,$7E,$7E
LPL3   .byte $00,$00,$3C,$24,$3C
LPL2   .byte $00,$00,$38,$38
LPL1
;
;
;
; LANDING COLORS
LCL1
       .byte $4C,$4A,$4A,$4A,$4E,$46,$48,$46,$46,$46
;
;
;
PTABL2
;  COLORS
; FIGHTER
;       .byte $D0,$D3,$D6,$CD,$D0,$D3,$CD,$D0
;       .byte $A0,$A0,$A0,$9F,$9F,$9F,$9E,$9C
;       .byte $7B,$85,$B2,$7A,$84,$B1,$82,$82
;       .byte $AB,$AB,$B6,$BE,$BE,$BE,$C3,$C3
;       .byte $D8,$D7,$D6,$D5,$D5,$D7,$D7,$D7
;       .byte $BC,$BC,$BC,$BC,$BC,$BC,$B7,$B6
;       .byte $00,$00,$ED,$EE,$ED,$EE,$ED,$EE
;       .byte $AB,$AB,$AB,$AB,$B3,$B3,$B3,$B3
;       .byte $BC,$C3,$BC,$C7,$C6,$C6,$C6,$C6
Z EQM <FCL1
       .byte Z+$A,Z+$D,Z+$10,Z+$7,Z+$A,Z+$D,Z+$7,Z+$A
; PLN PIR
Z EQM <PCL1
       .byte Z+$B,Z+$B,Z+$B,Z+$A,Z+$A,Z+$A,Z+$9,Z+$7
;  MISC GRAPHIC
Z EQM <NCL1
       .byte Z+$B,Z+$15,<NCL2+$B,Z+$A,Z+$14,<NCL2+$A,Z+$12,Z+$12
; MAN
Z EQM <WCL1
       .byte Z+$C,Z+$C,Z+$17,Z+$1F,Z+$1F,Z+$1F,Z+$24,Z+$24
; LAND ZONE
Z EQM <LCL1
       .byte Z+$B,Z+$A,Z+$9,Z+$8,Z+$8,Z+$A,Z+$A,Z+$A
; TRN TOWER
Z EQM <RCL1
       .byte Z+$B,Z+$B,Z+$B,Z+$B,Z+$B,Z+$B,Z+$6,Z+$5
; ENEMY PHOTON
Z EQM <ECL1
       .byte $00,$00,Z+$8,Z+$9,Z+$8,Z+$9,Z+$8,Z+$9
; EXPLOSION
Z EQM <XCL1
       .byte Z+$11,Z+$11,Z+$11,Z+$11,Z+$19,Z+$19,Z+$19,Z+$19
Z EQM <CCL1
       .byte Z+$A,Z+$11,Z+$A,Z+$15,Z+$14,Z+$14,Z+$14,Z+$14
;
;
PTABL4
;  SHARE WITH PLANET BLOWUP
;  CANT CROSS PAGE
       .byte $60,$60,$60,$20,$60,$20,$60,$20
       .byte $20,$60,$20,$20,$60,$20,$20,$20
       .byte $20,$60,$20,$20,$20,$20,$20,$60
       .byte $A0,$A0,$A0,$A0,$A0,$A0,$E0,$A0
       .byte $25,$25,$25,$25,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $20,$20,$20,$20,$20,$20,$20,$20
       .byte $25,$25,$25,$25,$20,$20,$20,$20
       .byte $20,$20,$20,$25,$25,$25,$25,$20
;
;
LINTB4
;  CANT CROSS PAGE
       .byte $4E,$4F,$4E,$4E,$5E,$4E,$4E,$4E
       .byte $4F,$4E,$5C,$4E,$4D,$4E,$4C,$4D
       .byte $4C,$4C,$5D,$4C,$4C,$4C,$5C,$4D
       .byte $4A,$4C,$4A,$4D,$5A,$4A,$4A,$4A
       .byte $4A,$4A,$5A,$4A,$4B,$4A,$4A,$4A
       .byte $4A,$4B,$48,$4A,$48,$4A,$58,$4A
       .byte $48,$49,$48,$48,$58,$49,$48,$46
       .byte $58,$46,$48,$46,$56,$46,$47,$46
       .byte $54,$46,$45,$44,$54,$44,$44,$42
       .byte $42,$42,$42,$41,$40,$40,$40,$40
;
;
; HYPER SHIP GRAPHICS
       .byte $00,$00,$10,$18,$18,$38,$10,$00
       .byte $00,$00,$99,$FF,$7E,$3C,$3C,$18,$18,$18
SHP4
       .byte $00,$00,$18,$18,$18,$00
       .byte $00,$00,$5A,$7E,$3C,$18,$18,$18
SHP3
       .byte $00,$00,$18,$18,$18,$00
       .byte $00,$00,$24,$3C,$3C,$18
SHP2
       .byte $00,$00,$18,$18,$18,$00
       .byte $00,$00,$08
SHP1
; SHIP COLOR
       .byte $1E,$2C,$2A,$38,$36,$44,$42,$40
SHCL
;
;
;
PLN140
; SETUP PLANET/TRENCH
       STA    WSYNC
       STA    ADDEL
       LDA    #$00 
       STA    GRAFM2
       STA    VDELM2
       STA    PRIOR
       STA    COLPF
       DEY
       LDA    PLINES 
       LSR
       LSR
       LSR
       AND    #$07 
       TAX
       LDA    SURTB1,X
       STA    CROSP1
       LDA    #<PLN350
       STA    PNTRP1 
       LDA    #>PLN198  ;TEMP, DEV.SYS.ONLY
       STA    MISC1+1
       LDA    #>PLN198+1
       STA    MISC2+1        ;  END TEMP
       LDX    IQPATH-1 
       STX    STARS 
       LDA    PROGST 
       AND    #$08 
       BEQ    TRN140
       STA    WSYNC
       STA    ADDEL
;  PLANET SETUP
       DEX
       DEX
       STX    MOON2
       LDA    XDELP0-1   ;MTNCOL
       STA    COLPF
       LDA    #>SURTB3
       STA    STARS+1
       STA    MOON2+1 
       LDA    #<PLN400
       STA    VECTP0
       LDA    #>PLN400
       STA    VECTP0+1
       LDA    #>PLN145
       STA    VECTP1+1 
       LDX    #<PLN145
PLN141
       STX    VECTP1
       LDA    ZDELP0-1   ;COLBK HOLD
       LDX    #$00 
       DEY
       JMP.ind (VECTP0)
PLN145
       LDX    #<PLN147
       JMP    PLN141
PLN147
       LDX    #<PLN100
       LDA    HCOLP1  ;PLANET COLOR
       LSR
       BIT    SHIPST 
       BVC    PLN141
;  BLOW PLANET
       BCS    PLN141
       LDA    ZDELP0-1
       STA    COLPF  ;TURN OFF MTNS
       LDA    #<PLN800
       STA    VECTP0
       LDA    RANDOM 
       STA    HPOSM0  ;FOR FUN
       AND    #$30 
       ADC    #$70 
       STA    HDELM0
       JMP    PLN141
;
;
TRN140
;  SETUP TRENCH
       STA    WSYNC
       STA    ADDEL
       LDA    #>SURTB5
       STA    STARS+1
       NOP
       NOP
       NOP
       NOP
       LDX    HOLDM0 
       LDA    HOLDM2 
       STA    HDELM2
       STX    HDELM0
       STA    WSYNC
       STA    ADDEL
       LDY    #$20 
       STY    SIZPM0
       AND    #$0F 
       LSR
       BCS    TRN144   ;DELAY
TRN144
       SEC
       NOP
       SBC    #$01 
       BPL    TRN144
       STA    HPOSM2
       STA    WSYNC
       STA    ADDEL
       JMP    TRN146   ;HUH?
;
;
PLN100
;  MOUNTAINS
       LDX    #$06 
PLN101
       LDA    PLNTB1-1,X
       STA    GRFPF0
       LDA    PLNTB2-1,X
       STA    GRFPF1
       LDA    PLNTB3-1,X
       STA    GRFPF2
       LDA    PLNTB4-1,X
       STA    GRFPF0
       LDA    PLNTB5-1,X
       DEY
       STA    GRFPF1
       LDA    PLNTB6-1,X
       STA    GRFPF2
       LDA    #$08 
       CPY    HVERP1 
       BEQ    PLN104
       LDA    #$00 
PLN104
       STA    GRAFP1
       DEX
       STA    WSYNC
       STA    ADDEL
       BNE    PLN101
; SETUP PLANET
;   X=0
       LDA    XDELP0-1 
       STA    COLBK
       STX    GRFPF0
       STX    GRFPF1
       STX    GRFPF2
       DEY
       LDA    #<PLN370
       BIT    SHIPST 
       BPL    PLN102
       LDA    #<PLN580
       STA    PNTRP1 
       CPY    HVERP1 
       BCC    PLN102
       BNE    PLN105
       LDX    #$08 
       BNE    PLN102   ;JMP
PLN105
       LDA    #>SHP4
       STA    MISC1+1 
       STA    MISC2+1
       LDA    ATRACT+1   ;SHIP COLOR 
       STA    MISC2
       LDA    #<HYP780
PLN102
       STA    VECTP1
       LDA    #>PLN370
       STA    VECTP1+1 
       LDA    #$00    ;COLBK
       JMP.ind (VECTP0)
;
;
TRN146
;  CONTINUE SETUP TRENCH
       TXA
       AND    #$0F 
       LSR
       BCS    TRN145   ;DELAY
TRN145
       SEC
       NOP
       SBC    #$01 
       BPL    TRN145
       STA    HPOSM0
       STA    WSYNC
       STA    ADDEL
       LDA    #>TRN400
       STA    VECTP0+1
       LDA    #>PLN370
       STA    VECTP1+1 
       LDA    #$FF 
       STA    GRFPF0
       STA    GRFPF1
       STA    GRFPF2
       LDA    #$00 
       STA    HDELM2
       STA    WSYNC
       STA    ADDEL
       LDA    #<PLN370
       BIT    SHIPST 
       BPL    TRN141
       LDA    #<PLN580
       STA    PNTRP1 
       LDA    #>SHP4
       STA    MISC1+1 
       STA    MISC2+1
       LDA    ATRACT+1 
       STA    MISC2    ;SHIP COLOR
       LDA    #<HYP780
TRN141
       STA    VECTP1
       LDA    #$31 
       STA    PRIOR
       LDY    #TRNTOP-6
       LDX    #$00 
       STX    HDELM0    ;X=0
       JMP    TRN400    ;ALL DONE TRN SETUP
;
;
;
;   WALLTB CANT CROSS PAGE
       .byte $00,$00,$00,$00,$00,$00
WALLTB
       .byte $00,$00,$10,$00
       .byte $10,$00,$30,$00,$30,$00,$70,$00
       .byte $70,$00,$00,$01,$00,$01,$80,$01
       .byte $80,$01,$C0,$01,$C0,$01,$E0,$01
       .byte $E0,$01,$F0,$01,$F0,$01,$F8,$01
       .byte $F8,$01,$FC,$01,$FC,$01,$FE,$01
       .byte $FE,$01,$00,$02,$00,$02,$01,$02
       .byte $01,$02,$03,$02,$03,$02,$07,$02
       .byte $07,$02,$0F,$02,$0F,$02,$1F,$02
       .byte $1F,$02,$3F,$02,$3F,$02,$7F,$02
;
       .byte $7F,$02,$FF,$02,$FF,$02,$FF,$02,$FF,$02
       .byte $7F,$02,$3F,$02,$1F,$02
;
       .byte $0F,$02,$07,$02,$03,$02,$01,$02
       .byte $FF,$01,$FE,$01,$FC,$01,$F8,$01
       .byte $F0,$01,$E0,$01,$C0,$01,$80,$01
       .byte $F0,$00,$70,$00,$30,$00,$10
;   SHARE 5
;
MOVTB5
       .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $01,$01,$01,$01,$01,$01,$01,$01
       .byte $FE,$FE,$FE,$FE,$FE,$FE,$FE,$FE
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$00
;
;
;
TRNHLP
       STX    PNTR3+1    ;FOR CLOSE
       STA    BOTSCN 
       LDA    #<STARTB-$71
       STA    STARS 
       LDA    #$3A 
       STA    HHORP1+3 
       LDA    IQWARP 
       CMP    #$80 
       ADC    PLINES 
       STA    PLINES 
       ASL
       RTS

SURTB3
;  CANT CROSS PAGE
       .byte $FF,$FF,$FE,$FF,$FF,$FD,$FF,$FF
       .byte $FB,$FF,$FF,$F7,$FF,$FF,$EF,$FF
       .byte $DF,$FF,$FF,$BF,$FF,$7F,$FF,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FE,$FF,$FD
       .byte $FB,$F7,$FF,$EF,$DF,$BF,$7F,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
       .byte $FD,$F3,$EF,$DF,$3F,$FF,$FF,$FF
       .byte $FF,$FF,$FC,$F3,$CF,$3F,$FF,$FF
       .byte $FF,$FC,$F3,$8F,$7F,$FF,$FE,$E1
       .byte $1F,$FF,$FF
SURTB4
;  CANT CROSS PAGE
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
       .byte $FF,$FD,$FF,$FB,$FF,$F7,$FF,$EF
       .byte $DF,$FF,$BF,$FF,$7F,$FF,$FF,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FE
       .byte $FD,$FB,$F7,$EF,$DF,$BF,$7F,$FF
       .byte $FF,$FF,$FF,$FF,$FF,$FE,$F9,$F7
       .byte $CF,$3F,$FF,$FF,$FF,$FF,$FC,$E3
       .byte $9F,$7F,$FF,$FF,$FC,$C3,$3F,$FF
       .byte $FE,$E1,$1F,$FF
;
PLNTB3 .byte $DF,$8F,$0B,$01
;  SHARE 2
;
; ENEMY BULLETS
       .byte $00,$00,$08,$08,$1C,$3E,$1C,$08,$08
EPL6   .byte $00,$00,$36,$1C,$08,$1C,$36,$04
EPL5   .byte $00,$00,$08,$08,$1C,$08,$08
EPL4   .byte $00,$00,$14,$08,$14,$04
EPL3   .byte $00,$00,$08,$1C,$08
EPL2   .byte $00,$00,$08,$04
EPL1
;
;
;  ENEMY PHOTON COLOR
ECL1
       .byte $6E,$5E,$4E,$3E,$4E,$5E,$6E
;  SHARE 1
;
MOVTB4
       .byte $00,$20,$40,$60,$80,$A0,$C0,$E0
       .byte $00,$20,$40,$60,$80,$A0,$C0,$E0
       .byte $20,$40,$60,$80,$A0,$C0,$E0,$00
       .byte $20,$40,$60,$80,$A0,$C0,$E0,$00
;
PLNTB5 .byte $FF,$FF,$BB,$B1,$91,$10
;
;
SURTB5
;  CANT CROSS PAGE
       .byte $FF,$FF,$FE,$FF,$FD,$FF,$FF,$FF
       .byte $FB,$FF,$F7,$FF,$FF,$FF,$EF,$FF
       .byte $DF,$FF,$BF,$FF,$7F,$FF,$FF,$FE
       .byte $FF,$FD,$FF,$FB,$FF,$F7,$FF,$EF
       .byte $FF,$DF,$FF,$BF,$FE,$7F,$FD,$FF
       .byte $F3,$FF,$EF,$FF,$9F,$FF,$7F,$FE
       .byte $FF,$F9,$FF,$E7,$FF,$9F,$FE,$7F
       .byte $F1,$FF,$CF,$FF,$3F,$FE,$FF,$F1
       .byte $FF,$0F,$F0,$FF,$0F,$FF,$FF,$E0
       .byte $FC,$1F,$83,$FF,$7F,$C0,$E0,$3F
       .byte $FF,$FF
;   SHARE 2
;
PLNTB6 .byte $FF,$FF,$77,$67,$22,$20
;
MOVTB6
       .byte $00,$20,$40,$60,$80,$A0,$C0,$E0
       .byte $00,$80,$00,$80,$00,$00,$00,$00
       .byte $00,$00,$00,$80,$00,$80,$00,$80
       .byte $20,$40,$60,$80,$A0,$C0,$E0
;  SHARE 1
MOVTB7 .byte $00,$00,$00,$00,$00,$00,$00,$00
       .byte $01,$01,$02,$02,$03,$04,$05,$07
       .byte $F8,$FA,$FB,$FC,$FD,$FD,$FE,$FE
       .byte $FF,$FF,$FF,$FF,$FF,$FF,$FF
;  SHARE 1
GRATB5
      .byte $00,$01,$02,$11,$20,$21,$22,$11
;
;
;
;
;
;
MOVER
; FINISH VBLANK STUFF
       LDA    #$2B    ;37 LINES #$30=40 VBLANK
       STA    STIM64
       STA    RANDOM+1          ;DEFINE FOR HORIZ (IF IN CHART OR TAKEOFF)
       TYA
       INX  ;X=0
       STX    GRAFP0
       STX    GRAFM2
       STX    GRAFP1
       STX    GRAFP0
       STX    GRFPF0
       STX    GRFPF1
       STX    GRFPF2
       STX    GRAFM1
       STX    GCTLM1
       STX    BOTSCN 
       STX    TEMP5    ;X=0 FOR VECT DOWN
       STX    PNTR1   ; FOR TARNUM
       STA    HITCLR
       INX   ;X=1
       STX    VDELM2
       STA    WSYNC
       STA    ADDEL
       STX    PRIOR
;  RNDNUM
       LDY    ATRACT 
       ADC    GAMTIM
       ADC    ATRACT 
       ADC    RANDOM 
       ADC    $FE00,Y   ;RANDOM CODE PAGE FE
       STA    RANDOM 
       INC    RANDOM 
;  SETUP GRAPH
       TYA     ;ATRACT
       LSR
       TAX
       LSR
       LSR
       AND    #$07 
       TAY
       LDA    GRATB5,Y
       STA    TEMP4 
       ASL
       ASL
       ASL
       ASL
       STA    TEMP13
       TXA
       AND    #$07 
       TAY
       LDA    GRATB5,Y
       STA    TEMP11
       LDA    #$56 
       STA    VWALL      ;DEFAULT
       STA    CLRDEL        ;FOR STARS
       LDX    #$04 
       LDA    PROGST 
       AND    #$B3 
       STX    VSYNC      ;OFF
       BNE    CHTSRV
MOVER1
;  HORIZ MOTION
       LDA    XDELP0-1,X
       AND    #$1F 
       TAY
       CLC
       LDA    MOVTB6,Y
       ADC    XDELP0-1,X
       STA    XDELP0-1,X
       LDA    MOVTB7,Y
       ADC    HHORP0-1,X
       STA    HHORP0-1,X
; ZMOTION
       LDA    ZDELP0-1,X
       AND    #$1F 
       TAY
       CLC
       LDA    MOVTB4,Y
       ADC    ZDELP0-1,X
       STA    ZDELP0-1,X
       LDA    MOVTB5,Y
       ADC    ZPOSP0-1,X
       BIT    PROGST 
       BVS    MOVER3      ;PLN/TRN
       CMP    #$F1      ;Z=0 CHECK
       BCC    MOVER5      ;OK
       LDY    HGRAP0-1,X
       BPL    MOVER7     ;H,V OOPS!
MOVER5
;  VERT MOTION
       STA    ZPOSP0-1,X
MOVER7
       LDA    YDELP0-1,X
       AND    #$1F 
       TAY
       CLC
       LDA    MOVTB6,Y
       ADC    YDELP0-1,X
       STA    YDELP0-1,X
       LDA    MOVTB7,Y
       ADC    HVERP0-1,X
       CMP    #$F1   ;MAX VERT CHECK
       BCC    MOVER2  ;OK
       LDA    #$00 
       LDY    HVERP0-1,X
       BPL    MOVER2
       LDA    #$F0 
MOVER2
       STA    HVERP0-1,X
       DEX
       BPL    MOVER1
MOVER4
       JMP    EXIT7    ;TO GRAPH
MOVER3
;  PLN/TRN
       STA    ZPOSP0-1,X
       DEX
       BNE    MOVER1  ;NO P1+3
;  PLANET PHOTON FIX
       LDA    YDELP0 
       AND    #$1F 
       TAY
       CLC
       LDA    MOVTB6,Y
       ADC    YDELP0 
       STA    YDELP0 
       LDA    MOVTB7,Y
       ADC    HVERP0+0 
       BPL    MOVE25
       TXA          ;X=0
MOVE25
       STA    HVERP0+0 
       JMP    EXIT7   ;TO GRAPH
;
;
CHTSRV
; SETUP FOR CHART
       AND    #$20 
       BEQ    MOVER4 ;NOT CHART
       LDX    NEWLEV
       LDA    CHTAB7,X
       STA    COLBK
       STA    HCOLP1 
       BIT    MAZSTA 
       BVC    CHTSR1
       LDA    MAZSTA 
       AND    #$BF 
       STA    MAZSTA 
       LDA    NEWLEV 
       ASL
       ADC    NEWLEV 
       ASL
       TAY
       LDX    #$17
       STX    PNTR1 
CHTSR2
       INC    PNTR1 
       BMI    CHTSR3
       LDA    #$FC 
       STA    PNTR1 
       LDA    CHTAB4,Y
       STA    PNTR1+1
       INY
CHTSR3
       LDA    #$00 
       ASL    PNTR1+1 
       BCC    CHTSR4
       LDA    #$C0 
CHTSR4
       ASL    PNTR1+1
       BCC    CHTSR5
       ORA    #$0C 
CHTSR5
       STA    CHTBLK,X
       DEX
       BPL    CHTSR2
CHTSR1
       JMP    EXIT6
;
;
;
CHTAB4
       .byte $CE,$90,$4C,$82,$5C,$67
       .byte $CD,$B6,$18,$E8,$2E,$23
       .byte $CB,$05,$56,$48,$0D,$A4
       .byte $8F,$16,$1E,$58,$38,$C0
       .byte $C1,$74,$1E,$0A,$BA,$C3
       .byte $02,$00,$52,$0A,$20,$84
       .byte $0B,$C0,$58,$32,$0F,$C1
       .byte $41,$A2,$0E,$19,$26,$03
       .byte $41,$26,$90,$58,$0E,$63
       .byte $C9,$24,$92,$49,$34,$04
       .byte $03,$E0,$A8,$AA,$2F,$84
       .byte $C7,$74,$80,$32,$6D,$C3
       .byte $41,$F0,$1E,$40,$0F,$A1
       .byte $01,$F4,$54,$51,$16,$C0
       .byte $C7,$D1,$16,$CF,$1F,$60
       .byte $09,$45,$92,$68,$9B,$06
;
;
;
TRNSRV
       STA    COLBK       ;A=0
       LDX    VWALL 
       DEX
       DEX    ;FIX CLOSE BUG
       LDY    #<SURTB5+1
       LDA    #TRNTOP
       JSR    TRNHLP
       BMI    TRNSR2
       LDY    #<SURTB5
TRNSR2
       STY    IQPATH-1 
       LDA    CENTER 
       SBC    #$40 
       CMP    #$20 
       BCC    TRNSR3
       LDA    ZPOSP1+1 
       CMP    #$16 
       BCC    TRNSR3
       LDA    #$80 
       STA    ZPOSP1+1 
TRNSR3
       RTS
;
;
PLNSRV
       BIT    PROGST 
       BVC    PLNSR1
       LDA    PROGST 
       AND    #$08 
       BEQ    TRNSRV
       LDY    #<SURTB4
       LDX    #$56    ;FOR CLOSE
       LDA    #MTNTOP
       JSR    TRNHLP
       BMI    PLNSR3
       LDY    #<SURTB3
PLNSR3
       STY    IQPATH-1 
       LDX    #$02 
       LDA    PORTB
       AND    #$08 
       BEQ    PLNSR5   ;B/W
       LDX    #$00 
       LDA    #SKYCOL
       BIT    GAMEST 
       BVS    PLNSR5
       LDA    #$50 
PLNSR5
       STX    XDELP0-1   ;MTNCOL
       LDX    ONESHT      ;STARS END?
       CPX    #$99 
       BNE    PLNSR9
       LDA    RANDOM 
       AND    #$76 
       ORA    #$40 
PLNSR9
       STA    COLBK
       STA    ZDELP0-1
       LDA    ATRACT 
       AND    #$03 
       TAY
       LDX    PLANT1,Y
       LDA    #$C0 
       BIT    SHIPST 
       BVC    PLNSR1
;  BLOWUP PLANET
       BMI    PLNSR2    ;TAKEOFF
       LDY    IQWARP 
       BPL    PLNSR2
       LDA    ATRACT 
       LSR
       AND    #$02 
       ADC    #$40 
       TAX
       LDA    ATRACT 
       AND    #$07 
       BNE    PLNSR6
       LDA    PTABL4-$E0,Y 
       ASL
       BPL    PLNSR6
       LDA    #AUDEX6-J
       STA    CH1PTR 
PLNSR6
       LDA    #AUDEXP-J
       STA    CH0SHD   ;RUMBLE?
       TYA
       ASL
PLNSR2
       STX    HCOLP1   ;PLANET COLOR
       STA    YDELP0-1  ;STAR PROB
PLNSR1
       RTS
;
;
;
;
;   BANK SELECT CODE
       .byte $FF
 ORG $3FD2
 RORG BANK4+$FD2
PON4
       STA    STROB3 ;JMP DFD5
       JMP    MOVER
EXIT7
       STA    STROB1 ;JMP DFDB
PLNTB1
       .byte $F0,$F0,$80,$80,$80,$00
       TYA
       BNE    PLN199
EXIT8
       STA    STROB3 ;JMP DFE7
       JSR    PLNSRV
       STA    STROB1 ;JMP DFF0
EXIT6
       STA    STROB3 ;JMP DFF0
       JMP    HYPER
PLN199
       JMP    PLN140
       .byte "DOUG N"
       .word PON4
       .word PON4
;
;
; **********************
;  END INCLUDE BANK4.SRC
; **********************
;
 END