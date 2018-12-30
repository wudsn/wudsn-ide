; A-Team for the Atari 2600 VCS
;
; Copyright 198? Atari
; Written by Howard Scott Warshaw
;
; PAL timing conversion by Manuel Polik (cybergoth@nexgo.de)
; PAL Color conversion by Fabrizio Zavagli (rasty@rasty.com)
;
; Compiles with DASM
;
; History
; 07.12.2.2K      - Manuel: Finished Disassembling
; 08.12.2.2K      - Manuel: Finished PAL & PAL 60 timing / bugfix
; 09.12.2.2K      - Fabrizio: Started color conversion, done with Backgrounds
; 11.12.2.2K      - Fabrizio: Finished with color conversion 
;                   (needs more real-hardware testing). Included No Cycle option
; 12.12.2.2K      - Manuel: Improved the bugfix
; 13.12.2.2K      - Fabrizio: Fixed the logo & the intro kernel
; 15.12.2.2K      - Manuel: Removed HMOVE black line in intro

      processor 6502
      include vcs.h

; Compile switches

NTSC            = 0
PAL             = 1 
PAL60           = 2
NO              = 0
YES             = 1

COMPILE_VERSION = PAL      ; Compile PAL colors 50Hz
;COMPILE_VERSION = PAL60    ; Compile PAL colors 60Hz
;COMPILE_VERSION = NTSC     ; Compile NTSC colors 60Hz

;FIX_LOGO = NO      ; Don't fix the intro logo (original)
FIX_LOGO = YES      ; Fix the intro logo

;FIX_INTRO = NO     ; Don't fix the intro glitch (original)
FIX_INTRO = YES     ; Fix the intro glitch

COLOR_CYCLE = NO           ; Don't make the border color on level 1 cycle. Hannibal's missile will not flash also.
;COLOR_CYCLE = YES           ; Make the border color on level 1 cycle (original)

;BUGFIX = NO                ; Original NTSC version behaviour
BUGFIX = YES                ; provide a fixed # of scannlines 

; First bank
       ORG $1000
       RORG $B000

       LDA    $FFF8   ;4
       JMP    START   ;3
LB006: LDX    #$04    ;2
LB008: STA    WSYNC   ;3
       LDA    $A8,X   ;4
       TAY            ;2
       LDA    LBC00,Y ;4
       STA    HMP0,X  ;4
       AND    #$0F    ;2
       TAY            ;2
LB015: DEY            ;2
       BPL    LB015   ;2
       STA    RESP0,X ;4
       DEX            ;2
       BPL    LB008   ;2
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       JMP    LBCCC   ;3

LB024: .byte $00,$80,$82,$86

       BIT    $A7     ;3
       BPL    LB036   ;2
       BVS    LB036   ;2
       LDA    $EF     ;3
       BNE    LB036   ;2
       BIT    $3C; INPT4   ;3
       BPL    LB049   ;2
LB036: BIT    $A7     ;3
       BVS    LB05D   ;2
       ROR    SWCHB   ;6
       BCS    LB057   ;2
       LDA    #$02    ;2
       BIT    $8E     ;3
       BNE    LB05D   ;2
       ORA    $8E     ;3
       STA    $8E     ;3
LB049: LDA    $82     ;3
       STA    $EA     ;3
       JSR    LBCAE   ;6
       LDA    #$02    ;2
       STA    $8E     ;3
       JMP    LB224   ;3
LB057: LDA    $8E     ;3
       AND    #$FD    ;2
       STA    $8E     ;3
LB05D: LDA    $81     ;3
       BNE    LB07C   ;2
       LDA    $82     ;3
       AND    #$03    ;2
       BNE    LB07C   ;2
       LDX    #$05    ;2
LB069:
       LDA    $DB,X   ;4
       BEQ    LB079   ;2
       CMP    #$04    ;2
       BCS    LB079   ;2
       DEC    $DB,X   ;6
       TAY            ;2
       LDA    LB024,Y ;4
       STA    $92     ;3
LB079: DEX            ;2
       BPL    LB069   ;2
LB07C: LDA    $81     ;3
       BNE    LB0C5   ;2
       BIT    $33 ;CXP1FB  ;3
       BVC    LB0C5   ;2
       LDA    $B5     ;3
       LSR            ;2
       CMP    #$21    ;2
       BCC    LB08F   ;2
       LDX    #$00    ;2
       BEQ    LB093   ;2
LB08F: TAY            ;2
       LDX    LBE2D,Y ;4
LB093: CPX    #$05    ;2
       BEQ    LB0C5   ;2
       CPX    #$02    ;2
       BNE    LB0B3   ;2
       LDA    $E0     ;3
       CMP    #$04    ;2
       BCC    LB0A5   ;2
       ORA    #$80    ;2
       STA    $E0     ;3
LB0A5: LDA    #$80    ;2
       STA    $83     ;3
       LDA    #$B5    ;2
       STA    $84     ;3
       LDA    #$84    ;2
       STA    $91     ;3
       BNE    LB0BF   ;2
LB0B3: LDA    $DB,X   ;4
       AND    #$0C    ;2
       CMP    #$0C    ;2
       BEQ    LB0C5   ;2
       LDA    #$03    ;2
       STA    $DB,X   ;4
LB0BF: LDA    #$70    ;2
       STA    $95     ;3
       STA    $B5     ;3
LB0C5: BIT    $32; CXP0FB  ;3
       BVC    LB0F2   ;2
       LDX    $81     ;3
       DEX            ;2
       BNE    LB0D4   ;2
       LDA    #$CD    ;2
       STA    $95     ;3
       BNE    LB0F2   ;2
LB0D4: DEX            ;2
       BNE    LB0F2   ;2
       LDA    #$82    ;2
       STA    $9C     ;3
       STA    $DC     ;3
       STA    $DD     ;3
       LDA    #$83    ;2
       STA    $91     ;3
       LDA    #$06    ;2
       CLC            ;2
       SED            ;2
       ADC    $9E     ;3
       STA    $9E     ;3
       LDA    #$00    ;2
       ADC    $9D     ;3
       STA    $9D     ;3
       CLD            ;2
LB0F2: BIT    $9C     ;3
       BMI    LB161   ;2
       LDX    #$00    ;2
       BIT    $30; CXM0P   ;3
       BMI    LB101   ;2
       INX            ;2
       BIT    $31; CXM1P   ;3
       BVC    LB161   ;2
LB101: LDY    $81     ;3
       BEQ    LB119   ;2
       LDA    #$80    ;2
       STA    $83     ;3
       LDA    #$B5    ;2
       STA    $84     ;3
       LDY    #$7F    ;2
       STY    $B3,X   ;4
       STY    $93,X   ;4
       LDA    #$84    ;2
       STA    $91     ;3
       BNE    LB161   ;2
LB119: LDA    $B3,X   ;4
       LSR            ;2
       CMP    #$21    ;2
       BCC    LB124   ;2
       LDA    #$00    ;2
       BEQ    LB12C   ;2
LB124: TAY            ;2
       LDA    LBE2D,Y ;4
       CMP    #$02    ;2
       BEQ    LB161   ;2
LB12C: LDY    #$7F    ;2
       STY    $B3,X   ;4
       STY    $93,X   ;4
       TAX            ;2
       LDA    $DB,X   ;4
       STA    $8B     ;3
       CMP    #$04    ;2
       BCC    LB161   ;2
       AND    #$0C    ;2
       CMP    #$0C    ;2
       BNE    LB147   ;2
       LDA    $E7     ;3
       BEQ    LB147   ;2
       DEC    $E7     ;5
LB147: LDA    #$03    ;2
       STA    $DB,X   ;4
       LDA    $8B     ;3
       LSR            ;2
       LSR            ;2
       AND    #$07    ;2
       TAX            ;2
       LDA    $BEC9,X ;4
       CMP    #$99    ;2
       BNE    LB15E   ;2
       JSR    LBCF0   ;6
       LDA    #$99    ;2
LB15E: JSR    LBCF0   ;6
LB161: BIT    $37; CXPPMM  ;3
       BPL    LB176   ;2
       LDX    $81     ;3
       DEX            ;2
       BNE    LB176   ;2
       LDA    #$80    ;2
       STA    $83     ;3
       LDA    #$B5    ;2
       STA    $84     ;3
       LDA    #$84    ;2
       STA    $91     ;3
LB176: LDX    $81     ;3
       BNE    LB1CA   ;2
       LDA    $95     ;3
       BPL    LB184   ;2
       AND    #$03    ;2
       CMP    #$03    ;2
       BEQ    LB190   ;2
LB184: LDA    $98     ;3
       BPL    LB1EE   ;2
       AND    #$03    ;2
       CMP    #$03    ;2
       BNE    LB1EE   ;2
       LDX    #$03    ;2
LB190: LDY    #$04    ;2
LB192: LDA.wy $0093,Y ;4
       BPL    LB1C1   ;2
       AND    #$03    ;2
       CMP    #$03    ;2
       BNE    LB1C1   ;2
       LDA.wy $00AA,Y ;4
       SBC    $AC,X   ;4
       BPL    LB1A6   ;2
       EOR    #$FF    ;2
LB1A6: CMP    #$04    ;2
       BCS    LB1C1   ;2
       LDA    #$7F    ;2
       STA    $95,X   ;4
       STA    $B5,X   ;4
       STA.wy $0093,Y ;5
       STA.wy $00B3,Y ;5
       LDA    #$33    ;2
       JSR    LBCF0   ;6
       LDA    #$86    ;2
       STA    $92     ;3
       BNE    LB1EE   ;2
LB1C1: DEY            ;2
       BMI    LB1EE   ;2
       CPY    #$02    ;2
       BEQ    LB1C1   ;2
       BNE    LB192   ;2
LB1CA: CPX    #$02    ;2
       BNE    LB1EE   ;2
       LDX    #$00    ;2
       BIT    $34; CXM0FB  ;3
       BVS    LB1D9   ;2
       INX            ;2
       BIT    $35; CXM1FB  ;3
       BVC    LB1EE   ;2
LB1D9: LDA    $B3,X   ;4
       AND    #$77    ;2
       JSR    LBCF0   ;6
       LDA    #$70    ;2
       STA    $93,X   ;4
       STA    $B3,X   ;4
       STA    $95     ;3
       STA    $B5     ;3
       LDA    #$88    ;2
       STA    $92     ;3
LB1EE: BIT    $36 ;CXBLPF  ;3
       BPL    LB224   ;2
       LDA    $95     ;3
       CMP    #$CD    ;2
       BNE    LB224   ;2
       LDA    $AC     ;3
       SEC            ;2
       SBC    #$08    ;2
       LSR            ;2
       LSR            ;2
       TAY            ;2
       LDA    $BE4F,Y ;4
       AND    #$03    ;2
       TAX            ;2
       LDA    $BE4F,Y ;4
       LSR            ;2
       LSR            ;2
       TAY            ;2
       LDA    $BE87,Y ;4
       AND    $D7,X   ;4
       BEQ    LB224   ;2
       EOR    #$FF    ;2
       AND    $D7,X   ;4
       STA    $D7,X   ;4
       LDA    #$33    ;2
       JSR    LBCF0   ;6
       LDA    #$08    ;2
       STA    $DB     ;3
       DEC    $E1     ;5
LB224: LDY    $81     ;3
       DEY            ;2
       BNE    LB23D   ;2
       LDA    $D7     ;3
       ORA    $D8     ;3
       ORA    $D9     ;3
       ORA    $DA     ;3
       BNE    LB23D   ;2
       LDX    $A4     ;3
       BNE    LB239   ;2
       INC    $A4     ;5
LB239: LDY    #$81    ;2
       STY    $9C     ;3
LB23D: LDX    #$01    ;2
       LDY    #$7F    ;2
LB241: LDA    $34,X; CXM0FB,X;4
       BPL    LB249   ;2
       STY    $93,X   ;4
       STY    $B3,X   ;4
LB249: DEX            ;2
       BPL    LB241   ;2
       LDX    #$02    ;2
LB24E: LDA    $93,X   ;4
       LDY    $96,X   ;4
       STY    $93,X   ;4
       STA    $96,X   ;4
       LDA    $AA,X   ;4
       LDY    $AD,X   ;4
       STY    $AA,X   ;4
       STA    $AD,X   ;4
       LDA    $B3,X   ;4
       LDY    $B6,X   ;4
       STY    $B3,X   ;4
       STA    $B6,X   ;4
       DEX            ;2
       BPL    LB24E   ;2
LB269: LDA    INTIM   ;4
       BNE    LB269   ;2
LB26E: LDA    #$02    ;2
       STA    WSYNC   ;3
       STA    VSYNC   ;3
       INC    $82     ;5
       LDA    $81     ;3
       BEQ    LB29E   ;2
       LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB29E   ;2
       LSR    $D7     ;5
       ROL    $D8     ;5
       ROR    $D9     ;5
       ROL    $DA     ;5
       BCC    LB29E   ;2
       LDA    $81     ;3
       CMP    #$02    ;2
       BNE    LB298   ;2
       LDX    $EB     ;3
       BEQ    LB298   ;2
       DEC    $EB     ;5
       BPL    LB29E   ;2
LB298: LDA    #$80    ;2
       ORA    $D7     ;3
       STA    $D7     ;3
LB29E: STA    WSYNC   ;3
       LDA    #$3F    ;2
       AND    $82     ;3
       BNE    LB2C8   ;2
       INC    $86     ;5
       LDA    $A7     ;3
       AND    #$BF    ;2
       STA    $A7     ;3
       LDX    $81     ;3
       DEX            ;2
       BNE    LB2C8   ;2
       BIT    $9C     ;3
       BMI    LB2C8   ;2
       BIT    $A5     ;3
       BMI    LB2C8   ;2
       SED            ;2
       LDA    $C6     ;3
       SEC            ;2
       SBC    #$01    ;2
       STA    $C6     ;3
       CLD            ;2
       LDA    #$82    ;2
       STA    $92     ;3
LB2C8: STA    WSYNC   ;3
       LDA    #$00    ;2

; Overscan timer!

        IF COMPILE_VERSION = PAL
            LDX    #$4B    ;
        ENDIF

        IF COMPILE_VERSION = PAL60
            LDX    #$2C    ;
        ENDIF

        IF COMPILE_VERSION = NTSC
            LDX    #$2D    ;
        ENDIF

       STA    WSYNC   ;3
       STA    VSYNC   ;3
       STX    TIM64T  ;4
       LDA    $EA     ;3
       BNE    LB2DB   ;2
       LDA    #$69    ;2
LB2DB: ASL            ;2
       EOR    $EA     ;3
       ASL            ;2
       EOR    $EA     ;3
       ASL            ;2
       ASL            ;2
       EOR    $EA     ;3
       ASL            ;2
       ROL    $EA     ;5
       LDA    $9C     ;3
       BMI    LB2EF   ;2
       JMP    LB376   ;3
LB2EF: LDX    #$05    ;2
       LDA    #$70    ;2
LB2F3: STA    $93,X   ;4
       STA    $B3,X   ;4
       DEX            ;2
       BPL    LB2F3   ;2
       LDA    $9C     ;3
       AND    #$03    ;2
       BNE    LB32B   ;2
       LDA    LBEC8   ;4
       STA    $E6     ;3
       LDA    $82     ;3
       AND    #$03    ;2
       BNE    LB31D   ;2
       LDX    $99     ;3
       INX            ;2
       CPX    #$F3    ;2
       BCS    LB320   ;2
       STX    $99     ;3
       LDA    #$20    ;2
LB316: JSR    LBCF0   ;6
       LDA    #$81    ;2
       STA    $92     ;3
LB31D: JMP    LB984   ;3
LB320: LDY    #$01    ;2
       JSR    LBD47   ;6
       LDA    #$00    ;2
       STA    $9C     ;3
       BNE    LB31D   ;2
LB32B: AND    #$02    ;2
       BNE    LB355   ;2
       LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB31D   ;2
       SED            ;2
       LDA    $C6     ;3
       SEC            ;2
       SBC    #$01    ;2
       STA    $C6     ;3
       CLD            ;2
       BCC    LB344   ;2
       LDA    #$99    ;2
       BNE    LB316   ;2
LB344: LDY    #$02    ;2
       STA    $82     ;3
       JSR    LBD47   ;6
       LDA    #$04    ;2
       STA    $DC     ;3
       LDA    #$82    ;2
       STA    $9C     ;3
       BNE    LB31D   ;2
LB355: LDA    $82     ;3
       AND    #$1F    ;2
       BNE    LB31D   ;2
       LDX    $DC     ;3
       BMI    LB36E   ;2
       DEC    $DC     ;5
       LDX    #$02    ;2
       LDA    #$99    ;2
       JSR    LBCF0   ;6
       LDA    #$81    ;2
       STA    $91     ;3
       BNE    LB31D   ;2
LB36E: LDY    #$00    ;2
       STY    $9C     ;3
       LDA    #$80    ;2
       STA    $A3     ;3
LB376: BIT    $A3     ;3
       BPL    LB3D2   ;2
       BVS    LB3AA   ;2
       LDA    #$30    ;2
       STA    $B9     ;3
       LDA    #$38    ;2
       STA    $B0     ;3
       LDX    #$00    ;2
       LDY    #$08    ;2
       JSR    LBD29   ;6
       LDA    $B1     ;3
       CMP    #$30    ;2
       BNE    LB3CF   ;2
       LDA    $A8     ;3
       CMP    #$38    ;2
       BNE    LB3CF   ;2
       SEC            ;2
       ROR    $A3     ;5
       LDA    $B1     ;3
       STA    $B2     ;3
       LDA    $A8     ;3
       ADC    #$07    ;2
       STA    $A9     ;3
       LDA    #$89    ;2
       STA    $91     ;3
       BMI    LB3CF   ;2
LB3AA: LDX    #$00    ;2
       LDA    #$06    ;2
       JSR    LBD08   ;6
       INX            ;2
       LDA    #$0A    ;2
       JSR    LBD08   ;6
       DEC    $A9     ;5
       INC    $A8     ;5
       LDA    $A9     ;3
       CMP    #$04    ;2
       BCS    LB3CF   ;2
       LDA    #$8A    ;2
       STA    $92     ;3
       LDY    #$00    ;2
       STY    $A3     ;3
       JSR    LBD47   ;6
       JMP    LB984   ;3
LB3CF: JMP    LB7E9   ;3
LB3D2: LDA    $81     ;3
       CMP    #$03    ;2
       BNE    LB42C   ;2
       BIT    $A7     ;3
       BMI    LB3FE   ;2
       LDA    #$0F    ;2
       STA    AUDC1   ;3
       LDA    $82     ;3
       ORA    #$18    ;2
       STA    AUDF1   ;3
       LDA    #$0F    ;2
       LDX    $99     ;3
       CPX    #$F3    ;2
       BCS    LB3FA   ;2
       LDA    #$00    ;2
       LDX    $99     ;3
       BMI    LB3FA   ;2
       LDA    $99     ;3
       LSR            ;2
       LSR            ;2
       EOR    #$0F    ;2
LB3FA: STA    AUDV1   ;3
       STA    $90     ;3
LB3FE: LDA    $82     ;3
       AND    #$3F    ;2
       BNE    LB408   ;2
       LDA    #$87    ;2
       STA    $91     ;3
LB408: LDA    $82     ;3
       AND    #$03    ;2
       BNE    LB429   ;2
       INC    $99     ;5
       LDY    $99     ;3
       BMI    LB429   ;2
       CPY    #$3F    ;2
       BCC    LB429   ;2
       LDY    #$00    ;2
       LDA    $A7     ;3
       CMP    #$02    ;2
       BNE    LB424   ;2
       STY    $A7     ;3
       BEQ    LB426   ;2
LB424: LDY    #$02    ;2
LB426: JSR    LBD47   ;6
LB429: JMP    LBA58   ;3
LB42C: LDA    $81     ;3
       BNE    LB454   ;2
       LDX    #$05    ;2
LB432: LDA    $DB,X   ;4
       CMP    #$04    ;2
       BCS    LB447   ;2
       TAY            ;2
       BEQ    LB440   ;2
       LDA    LBEBF,Y ;4
       BNE    LB445   ;2
LB440: STY    $D5,X   ;4
       LDA    LBEC3,X ;4
LB445: STA    $E1,X   ;4
LB447: DEX            ;2
       BPL    LB432   ;2
       INX            ;2
       BIT    $83     ;3
       BMI    LB452   ;2
       LDX    LBEC5   ;4
LB452: STX    $E3     ;3
LB454: BIT    $A5     ;3
       BPL    LB463   ;2
       BIT    $3C; INPT4   ;3
       BPL    LB45F   ;2
       JMP    LB984   ;3
LB45F: LDA    #$00    ;2
       STA    $A5     ;3
LB463: LDA    $81     ;3
       BNE    LB4C7   ;2
       BIT    $83     ;3
       BMI    LB4C7   ;2
       LDA    $E7     ;3
       BNE    LB485   ;2
       LDX    #$04    ;2
LB471: LDA    $DB,X   ;4
       CMP    #$04    ;2
       BCC    LB47C   ;2
       ROL            ;2
       SEC            ;2
       ROR            ;2
       STA    $DB,X   ;4
LB47C: DEX            ;2
       BMI    LB4B2   ;2
       CPX    #$02    ;2
       BEQ    LB47C   ;2
       BNE    LB471   ;2
LB485: LDA    $82     ;3
       ROR            ;2
       ROR            ;2
       ROR            ;2
       AND    #$07    ;2
       CMP    #$05    ;2
       BCS    LB4B2   ;2
       CMP    #$02    ;2
       BEQ    LB4B2   ;2
       TAX            ;2
       LDA    $DB,X   ;4
       BNE    LB4B2   ;2
       LDA    $86     ;3
       EOR    $D7     ;3
       EOR    $EA     ;3
       AND    #$0F    ;2
       TAY            ;2
       LDA    $8D     ;3
       CMP    #$04    ;2
       BCC    LB4AD   ;2
       LDA    LBED9,Y ;4
       BNE    LB4B0   ;2
LB4AD: LDA    LBED1,Y ;4
LB4B0: STA    $DB,X   ;4
LB4B2: LDA    $E7     ;3
       BNE    LB4C7   ;2
       LDA    $DB     ;3
       ORA    $DC     ;3
       ORA    $DE     ;3
       ORA    $DF     ;3
       BNE    LB4C7   ;2
       LDY    #$80    ;2
       STY    $9C     ;3
       JMP    LB984   ;3
LB4C7: LDX    $81     ;3
       DEX            ;2
       BNE    LB4DE   ;2
       LDA    $C6     ;3
       BNE    LB4DE   ;2
       LDX    $A4     ;3
       BNE    LB4D6   ;2
       INC    $A4     ;5
LB4D6: LDY    #$03    ;2
       JSR    LBD47   ;6
       JMP    LBA58   ;3
LB4DE: BIT    $83     ;3
       BPL    LB551   ;2
       LDX    #$05    ;2
       LDA    #$70    ;2
LB4E6: STA    $93,X   ;4
       STA    $B3,X   ;4
       DEX            ;2
       BPL    LB4E6   ;2
       BIT    $A7     ;3
       BMI    LB507   ;2
       SEC            ;2
       LDA    $84     ;3
       SBC    #$58    ;2
       LSR            ;2
       CMP    #$20    ;2
       BCS    LB507   ;2
       STA    AUDF1   ;3
       LDA    #$08    ;2
       STA    AUDV1   ;3
       STA    $90     ;3
       LDA    #$06    ;2
       STA    AUDC1   ;3
LB507: LDX    $81     ;3
       DEX            ;2
       BNE    LB51F   ;2
       LDA    #$10    ;2
       LDY    $B2     ;3
       CPY    #$20    ;2
       BCS    LB516   ;2
       LDA    #$30    ;2
LB516: STA    $B9     ;3
       LDX    #$00    ;2
       LDY    #$08    ;2
       JSR    LBD29   ;6
LB51F: LDX    $84     ;3
       DEX            ;2
       CPX    #$58    ;2
       BCS    LB54C   ;2
       BIT    $A7     ;3
       BMI    LB548   ;2
       DEC    $85     ;5
       BPL    LB548   ;2
       INC    $85     ;5
       LDA    $A0     ;3
       STA    $9D     ;3
       LDA    $A1     ;3
       STA    $9E     ;3
       LDA    $A2     ;3
       STA    $9F     ;3
       LDA    #$C0    ;2
       STA    $A7     ;3
       LDA    #$7E    ;2
       STA    $EF     ;3
       LDA    #$01    ;2
       STA    $82     ;3
LB548: LDA    #$00    ;2
       STA    $83     ;3
LB54C: STX    $84     ;3
       JMP    LB984   ;3
LB551: LDA    $81     ;3
       CMP    #$03    ;2
       BCS    LB58E   ;2
       LDX    $81     ;3
       BNE    LB591   ;2
       BIT    $A7     ;3
       BMI    LB56A   ;2
       BIT    SWCHA   ;4
       BMI    LB566   ;2
       INC    $D7     ;5
LB566: BVS    LB56A   ;2
       DEC    $D7     ;5
LB56A: LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB58E   ;2
       LDA    #$03    ;2
       LDY    $DA     ;3
       BIT    $E0     ;3
       BPL    LB581   ;2
       CPY    #$03    ;2
       BCS    LB587   ;2
       ROL    $E0     ;5
       CLC            ;2
       ROR    $E0     ;5
LB581: CPY    $D7     ;3
       BEQ    LB58E   ;2
       BCC    LB58C   ;2
LB587: DEC    $DA     ;5
       ROR            ;2
       BCS    LB58E   ;2
LB58C: INC    $DA     ;5
LB58E: JMP    LB5ED   ;3
LB591: CPX    #$01    ;2
       BEQ    LB5BF   ;2
       LDA    $EE     ;3
       BEQ    LB5AD   ;2
       LDA    $B1     ;3
       SBC    #$03    ;2
       STA    $B1     ;3
       BPL    LB5D9   ;2
       CMP    #$F0    ;2
       BCS    LB5D9   ;2
       LDY    #$00    ;2
       JSR    LBD47   ;6
       JMP    LB984   ;3
LB5AD: LDX    #$00    ;2
       LDA    $82     ;3
       AND    #$03    ;2
       BNE    LB5D9   ;2
       STA    $ED     ;3
       LDA    $EC     ;3
       JSR    LBD08   ;6
       JMP    LB5D9   ;3
LB5BF: LDX    #$00    ;2
       LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB5CC   ;2
       LDY    #$01    ;2
       JSR    LBD29   ;6
LB5CC: LDA    #$10    ;2
       BIT    SWCHA   ;4
       BEQ    LB5D9   ;2
       LDA    $8E     ;3
       AND    #$BF    ;2
       STA    $8E     ;3
LB5D9: BIT    $A7     ;3
       BMI    LB5ED   ;2
       LDA    SWCHA   ;4
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LDX    #$01    ;2
       BIT    $8E     ;3
       BVS    LB5ED   ;2
       JSR    LBD08   ;6
LB5ED: LDX    $81     ;3
       CPX    #$02    ;2
       BNE    LB61B   ;2
       LDA    $ED     ;3
       BNE    LB61B   ;2
       LDA    #$0C    ;2
       LDY    $A8     ;3
       CPY    #$10    ;2
       BCC    LB603   ;2
       CPY    #$82    ;2
       BCC    LB609   ;2
LB603: EOR    $EC     ;3
       STA    $EC     ;3
       STA    $ED     ;3
LB609: LDA    #$03    ;2
       LDY    $B1     ;3
       CPY    #$30    ;2
       BCC    LB615   ;2
       CPY    #$3B    ;2
       BCC    LB61B   ;2
LB615: EOR    $EC     ;3
       STA    $EC     ;3
       STA    $ED     ;3
LB61B: LDX    $81     ;3
       BNE    LB631   ;2
       LDA    $D7     ;3
       BMI    LB62B   ;2
       CMP    #$0C    ;2
       BCS    LB659   ;2
       INC    $D7     ;5
       BNE    LB659   ;2
LB62B: LDA    #$7F    ;2
       STA    $D7     ;3
       BNE    LB659   ;2
LB631: CPX    #$03    ;2
       BEQ    LB659   ;2
       LDA    $B2     ;3
       BNE    LB63B   ;2
       INC    $B2     ;5
LB63B: CPX    #$02    ;2
       BNE    LB645   ;2
       CMP    #$23    ;2
       BCC    LB64B   ;2
       BCS    LB649   ;2
LB645: CMP    #$40    ;2
       BCC    LB64B   ;2
LB649: DEC    $B2     ;5
LB64B: LDA    $A9     ;3
       CMP    #$09    ;2
       BCS    LB653   ;2
       INC    $A9     ;5
LB653: CMP    #$80    ;2
       BCC    LB659   ;2
       DEC    $A9     ;5
LB659: BIT    $A7     ;3
       BMI    LB661   ;2
       BIT    $3C; INPT4   ;3
       BPL    LB664   ;2
LB661: JMP    LB6E5   ;3
LB664: LDA    $8E     ;3
       BPL    LB674   ;2
       LDX    $81     ;3
       BNE    LB6EA   ;2
       LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB6EA   ;2
       BEQ    LB67C   ;2
LB674: ORA    #$80    ;2
       STA    $8E     ;3
       LDA    $82     ;3
       STA    $EA     ;3
LB67C: LDX    #$00    ;2
       LDA    SWCHA   ;4
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LDY    $81     ;3
       CPY    #$02    ;2
       BEQ    LB69D   ;2
       DEY            ;2
       BEQ    LB692   ;2
       CMP    #$0F    ;2
       BEQ    LB6EA   ;2
LB692: ORA    #$80    ;2
       LDY    $81     ;3
       BEQ    LB6C0   ;2
       DEY            ;2
       BEQ    LB6A1   ;2
       BNE    LB6EA   ;2
LB69D: TAY            ;2
       LDA    LBE8F,Y ;4
LB6A1: LDX    #$00    ;2
       LDY    $95,X   ;4
       BPL    LB6AD   ;2
       LDX    #$03    ;2
       LDY    $95,X   ;4
       BMI    LB6EA   ;2
LB6AD: STA    $95,X   ;4
       LDA    $B2     ;3
       STA    $B5,X   ;4
       LDA    $A9     ;3
       ADC    #$04    ;2
       STA    $AC,X   ;4
       LDA    #$84    ;2
       STA    $92     ;3
       JMP    LB6EA   ;3
LB6C0: LDY    $93,X   ;4
       BPL    LB6D4   ;2
       INX            ;2
       LDY    $93,X   ;4
       BPL    LB6D4   ;2
       INX            ;2
       INX            ;2
       LDY    $93,X   ;4
       BPL    LB6D4   ;2
       INX            ;2
       LDY    $93,X   ;4
       BMI    LB6EA   ;2
LB6D4: STA    $93,X   ;4
       LDA    #$2D    ;2
       STA    $B3,X   ;4
       LDA    $D7     ;3
       STA    $AA,X   ;4
       LDA    #$84    ;2
       STA    $92     ;3
       JMP    LB6EA   ;3
LB6E5: ROL    $8E     ;5
       CLC            ;2
       ROR    $8E     ;5
LB6EA: LDX    $81     ;3
       BEQ    LB72B   ;2
       DEX            ;2
       BEQ    LB6F4   ;2
LB6F1: JMP    LB780   ;3
LB6F4: LDX    #$04    ;2
       LDA    $82     ;3
       AND    #$3F    ;2
       BNE    LB6F1   ;2
       LDY    $A4     ;3
       CPY    #$08    ;2
       BCS    LB705   ;2
       LDX    LBEE9,Y ;4
LB705: LDA    $93,X   ;4
       BPL    LB713   ;2
       DEX            ;2
       BMI    LB780   ;2
       CPX    #$02    ;2
       BNE    LB705   ;2
       DEX            ;2
       BNE    LB705   ;2
LB713: LDY    $B1     ;3
       STY    $B3,X   ;4
       CPY    $B2     ;3
       ROL            ;2
       LDY    $A8     ;3
       STY    $AA,X   ;4
       CPY    $A9     ;3
       ROL            ;2
       AND    #$03    ;2
       TAY            ;2
       LDA    LBEAF,Y ;4
       STA    $93,X   ;4
       BNE    LB780   ;2
LB72B: BIT    $E0     ;3
       BMI    LB780   ;2
       LDX    #$00    ;2
       BIT    $95     ;3
       BPL    LB73B   ;2
       BIT    $98     ;3
       BMI    LB780   ;2
       LDX    #$03    ;2
LB73B: LDA    $82     ;3
       AND    #$1F    ;2
       BNE    LB780   ;2
       LDA    $8D     ;3
       CMP    #$02    ;2
       BCC    LB770   ;2
       DEC    $A6     ;5
       BPL    LB770   ;2
       LDA    $86     ;3
       EOR    $EA     ;3
       AND    #$07    ;2
       TAY            ;2
       LDA    LBE6F,Y ;4
       STA    $A6     ;3
       LDA    #$2D    ;2
       STA    $B5,X   ;4
       LDA    $EA     ;3
       AND    #$01    ;2
       TAY            ;2
       LDA    LBE7B,Y ;4
       STA    $AC,X   ;4
       LDA    LBE7D,Y ;4
       STA    $95,X   ;4
       LDA    #$86    ;2
       STA    $91     ;3
       BNE    LB780   ;2
LB770: LDA    #$8D    ;2
       STA    $95,X   ;4
       LDA    #$0D    ;2
       STA    $B5,X   ;4
       LDA    $DA     ;3
       STA    $AC,X   ;4
       LDA    #$85    ;2
       STA    $91     ;3
LB780: LDA    $81     ;3
       CMP    #$02    ;2
       BNE    LB7E9   ;2
       LDA    $82     ;3
       AND    #$0F    ;2
       BNE    LB7E9   ;2
       LDA    $EA     ;3
       AND    #$07    ;2
       TAX            ;2
       LDY    LBE7F,X ;4
       LDX    #$04    ;2
LB796: LDA    $E1     ;3
       BEQ    LB7BD   ;2
       LDA    $93,X   ;4
       BMI    LB7B4   ;2
       DEC    $E1     ;5
       LDA    $E1     ;3
       AND    #$03    ;2
       BNE    LB7A8   ;2
       INC    $EB     ;5
LB7A8: LDA    $B1     ;3
       STA    $B3,X   ;4
       LDA    $A8     ;3
       STA    $AA,X   ;4
       STY    $93,X   ;4
       BPL    LB7BD   ;2
LB7B4: DEX            ;2
       BMI    LB7BD   ;2
       CPX    #$02    ;2
       BEQ    LB7B4   ;2
       BNE    LB796   ;2
LB7BD: LDA    $82     ;3
       AND    #$07    ;2
       BNE    LB7D4   ;2
       LDX    #$04    ;2
LB7C5: LDA    $93,X   ;4
       BPL    LB7CB   ;2
       DEC    $B3,X   ;6
LB7CB: DEX            ;2
       BMI    LB7D4   ;2
       CPX    #$02    ;2
       BEQ    LB7CB   ;2
       BNE    LB7C5   ;2
LB7D4: LDA    $E1     ;3
       BNE    LB7E9   ;2
       LDA    $93     ;3
       ORA    $94     ;3
       ORA    $96     ;3
       ORA    $97     ;3
       BMI    LB7E9   ;2
       LDY    #$82    ;2
       STY    $EE     ;3
       JMP    LB984   ;3
LB7E9: LDY    $A4     ;3
       LDX    $81     ;3
       DEX            ;2
       BEQ    LB7FC   ;2
       DEX            ;2
       BNE    LB805   ;2
       LDA    #$00    ;2
       CPY    #$03    ;2
       BCS    LB7FB   ;2
       LDA    #$01    ;2
LB7FB: TAY            ;2
LB7FC: LDA    $E8     ;3
       ADC    LBEF1,Y ;4
       STA    $E8     ;3
       BCC    LB82D   ;2
LB805: LDX    #$02    ;2
       LDA    #$FF    ;2
       STA    $E9     ;3
LB80B: LDA    $91,X   ;4
       BPL    LB824   ;2
       JSR    LBD08   ;6
       LDA    $A8,X   ;4
       CMP    #$8A    ;2
       BCS    LB81E   ;2
       LDA    $B1,X   ;4
       CMP    #$50    ;2
       BCC    LB824   ;2
LB81E: LSR    $91,X   ;6
       LDA    #$60    ;2
       STA    $B1,X   ;4
LB824: INX            ;2
       CPX    #$04    ;2
       BEQ    LB824   ;2
       CPX    #$07    ;2
       BCC    LB80B   ;2
LB82D: LDX    #$04    ;2
LB82F: LDA    $91,X   ;4
       BPL    LB880   ;2
       CMP    #$C0    ;2
       BCS    LB844   ;2
       LDY    $81     ;3
       DEY            ;2
       BNE    LB867   ;2
       LDY    #$00    ;2
       JSR    LBD29   ;6
       JMP    LB880   ;3
LB844: LDY    $81     ;3
       BNE    LB860   ;2
       TAY            ;2
       LDA    $8D     ;3
       CMP    #$04    ;2
       LDA    $82     ;3
       BCC    LB85A   ;2
       AND    #$07    ;2
       BEQ    LB880   ;2
       LSR            ;2
       BCS    LB880   ;2
       BCC    LB866   ;2
LB85A: AND    #$03    ;2
       BNE    LB880   ;2
       BEQ    LB866   ;2
LB860: TAY            ;2
       LDA    $82     ;3
       ROR            ;2
       BCC    LB880   ;2
LB866: TYA            ;2
LB867: JSR    LBD08   ;6
       LDA    $A8,X   ;4
       CMP    #$8A    ;2
       BCS    LB87A   ;2
       CMP    #$04    ;2
       BCC    LB87A   ;2
       LDA    $B1,X   ;4
       CMP    #$52    ;2
       BCC    LB880   ;2
LB87A: LSR    $91,X   ;6
       LDA    #$60    ;2
       STA    $B1,X   ;4
LB880: CPX    #$07    ;2
       BEQ    LB888   ;2
       LDX    #$07    ;2
       BNE    LB82F   ;2
LB888: LDA    $81     ;3
       BNE    LB89C   ;2
       LDY    $8D     ;3
       BEQ    LB89C   ;2
       LDA    $B5     ;3
       CMP    #$50    ;2
       BCC    LB89C   ;2
       LDA    $95     ;3
       EOR    #$03    ;2
       STA    $95     ;3
LB89C: LDX    $81     ;3
       BEQ    LB8E9   ;2
       CPX    #$03    ;2
       BEQ    LB8E9   ;2
       BIT    $E9     ;3
       BPL    LB8E9   ;2
       LDX    #$04    ;2
LB8AA: LDA    $93,X   ;4
       BPL    LB8E0   ;2
       LDA    #$0C    ;2
       LDY    $AA,X   ;4
       CPY    #$0B    ;2
       BCC    LB8BA   ;2
       CPY    #$86    ;2
       BCC    LB8C7   ;2
LB8BA: EOR    $93,X   ;4
       STA    $93,X   ;4
       LDY    $81     ;3
       DEY            ;2
       BNE    LB8E0   ;2
       LDA    #$80    ;2
       STA    $91     ;3
LB8C7: LDY    $81     ;3
       DEY            ;2
       BNE    LB8E0   ;2
       LDA    #$03    ;2
       LDY    $B3,X   ;4
       CPY    #$03    ;2
       BCC    LB8D8   ;2
       CPY    #$48    ;2
       BCC    LB8E0   ;2
LB8D8: EOR    $93,X   ;4
       STA    $93,X   ;4
       LDA    #$80    ;2
       STA    $91     ;3
LB8E0: DEX            ;2
       BMI    LB8E9   ;2
       CPX    #$02    ;2
       BEQ    LB8E0   ;2
       BNE    LB8AA   ;2
LB8E9: LDA    #$00    ;2
       STA    $E9     ;3
       LDA    $81     ;3
       BEQ    LB8F4   ;2
       JMP    LB984   ;3
LB8F4: STA    $89     ;3
       LDA    $8D     ;3
       CMP    #$04    ;2
       BCC    LB900   ;2
       DEC    $89     ;5
       BNE    LB90B   ;2
LB900: CLC            ;2
       TAX            ;2
       LDA    $9B     ;3
       ADC    LBEB3,X ;4
       STA    $9B     ;3
       ROR    $89     ;5
LB90B: LDX    #$04    ;2
LB90D: LDY    $D5,X   ;4
       LDA    $DB,X   ;4
       BMI    LB965   ;2
       CMP    #$04    ;2
       BCC    LB97A   ;2
       CMP    #$0C    ;2
       BCC    LB920   ;2
       BIT    $89     ;3
       BPL    LB920   ;2
       INY            ;2
LB920: INY            ;2
       BPL    LB961   ;2
       CMP    #$14    ;2
       BCC    LB92D   ;2
       CMP    #$18    ;2
       BCS    LB92D   ;2
       EOR    #$10    ;2
LB92D: EOR    #$90    ;2
       STA    $DB,X   ;4
       LDY    $99     ;3
       AND    #$0C    ;2
       CMP    #$08    ;2
       BNE    LB943   ;2
       DEY            ;2
       DEY            ;2
       CPY    #$B0    ;2
       BCS    LB95C   ;2
       LDY    #$B0    ;2
       BNE    LB95C   ;2
LB943: INY            ;2
       INY            ;2
       CPY    #$F3    ;2
       BMI    LB95C   ;2
       LDY    #$01    ;2
       LDX    $A4     ;3
       INX            ;2
       CPX    #$08    ;2
       BCC    LB954   ;2
       LDX    #$03    ;2
LB954: STX    $A4     ;3
       JSR    LBD47   ;6
       JMP    LB984   ;3
LB95C: STY    $99     ;3
       JMP    LB97A   ;3
LB961: STY    $D5,X   ;4
       BPL    LB97A   ;2
LB965: DEY            ;2
       DEY            ;2
       BPL    LB961   ;2
       LDA    $DB,X   ;4
       AND    #$0C    ;2
       CMP    #$08    ;2
       BNE    LB976   ;2
       LDA    #$71    ;2
       JSR    LBCF0   ;6
LB976: LDA    #$00    ;2
       STA    $DB,X   ;4
LB97A: DEX            ;2
       BMI    LB984   ;2
       CPX    #$02    ;2
       BNE    LB90D   ;2
       DEX            ;2
       BNE    LB90D   ;2
LB984: LDX    $81     ;3
       BNE    LB9CF   ;2
       LDX    #$04    ;2
LB98A: LDA    $82     ;3
       ROR            ;2
       ROR            ;2
       AND    #$03    ;2
       STA    $87     ;3
       LDA    $DB,X   ;4
       CMP    #$04    ;2
       BCC    LB99E   ;2
       AND    #$FC    ;2
       ORA    $87     ;3
       STA    $DB,X   ;4
LB99E: DEX            ;2
       BMI    LB9A7   ;2
       CPX    #$02    ;2
       BNE    LB98A   ;2
       BEQ    LB99E   ;2
LB9A7: LDA    $82     ;3
       AND    #$18    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       ORA    #$04    ;2
       LDX    #$03    ;2
       LDY    $DD     ;3
       BEQ    LB9BA   ;2
       CPX    $DD     ;3
       BCS    LB9BC   ;2
LB9BA: STA    $DD     ;3
LB9BC: EOR    #$14    ;2
       LDY    $E0     ;3
       BEQ    LB9CA   ;2
       BPL    LB9C6   ;2
       ORA    #$80    ;2
LB9C6: CPX    $E0     ;3
       BCS    LB9CC   ;2
LB9CA: STA    $E0     ;3
LB9CC: JMP    LBA58   ;3
LB9CF: DEX            ;2
       BEQ    LB9E6   ;2
       BIT    $A3     ;3
       BPL    LB9E6   ;2
       LDA    $82     ;3
       LSR            ;2
       STA    $D1     ;3
       STA    $CF     ;3
       BVC    LB9EA   ;2
       STA    $C9     ;3
       STA    $CB     ;3
       JMP    LBA2C   ;3
LB9E6: LDA    #$2C    ;2
       STA    $D3     ;3
LB9EA: LDA    #$37    ;2
       BIT    $83     ;3
       BPL    LB9F2   ;2
       LDA    $84     ;3
LB9F2: STA    $CD     ;3
       LDA    $82     ;3
       AND    #$18    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       TAY            ;2
       BIT    $A3     ;3
       BMI    LBA08   ;2
       LDX    LBEFD,Y ;4
       STX    $CF     ;3
       DEX            ;2
       STX    $D1     ;3
LBA08: LDX    LBEF9,Y ;4
       STX    $C9     ;3
       DEX            ;2
       STX    $CB     ;3
       BIT    $A3     ;3
       BMI    LBA2C   ;2
       LDA    $81     ;3
       CMP    #$02    ;2
       BNE    LBA2C   ;2
       LDA    $82     ;3
       AND    #$06    ;2
       LSR            ;2
       TAY            ;2
       LDX    LBF15,Y ;4
       STX    $CF     ;3
       DEX            ;2
       STX    $D1     ;3
       LDA    #$4D    ;2
       STA    $D3     ;3
LBA2C: LDX    $81     ;3
       DEX            ;2
       BEQ    LBA3D   ;2
       LDA    $95     ;3
       BPL    LBA58   ;2
       AND    #$0F    ;2
       TAY            ;2
       LDA    LBE9F,Y ;4
       BNE    LBA52   ;2
LBA3D: BIT    $95     ;3
       BVS    LBA4B   ;2
       LDA    $82     ;3
       ROR            ;2
       AND    #$03    ;2
       CLC            ;2
       ADC    #$04    ;2
       BNE    LBA4F   ;2
LBA4B: LDA    $B5     ;3
       AND    #$03    ;2
LBA4F: ASL            ;2
       ASL            ;2
       ASL            ;2
LBA52: STA    $D5     ;3
       LDA    #$FA    ;2
       STA    $D6     ;3
LBA58: LDA    $81     ;3
       BNE    LBA68   ;2
       LDX    #$05    ;2
LBA5E: LDY    $D5,X   ;4
       LDA    LBC00,Y ;4
       STA    $CF,X   ;4
       DEX            ;2
       BPL    LBA5E   ;2
LBA68: JMP    LB006   ;3
LBA6B: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00
LBC00: .byte $70,$60,$50,$40,$30,$20,$10,$00,$F0,$E0,$D0,$C0,$B0,$A0,$90,$71
       .byte $61,$51,$41,$31,$21,$11,$01,$F1,$E1,$D1,$C1,$B1,$A1,$91,$72,$62
       .byte $52,$42,$32,$22,$12,$02,$F2,$E2,$D2,$C2,$B2,$A2,$92,$73,$63,$53
       .byte $43,$33,$23,$13,$03,$F3,$E3,$D3,$C3,$B3,$A3,$93,$74,$64,$54,$44
       .byte $34,$24,$14,$04,$F4,$E4,$D4,$C4,$B4,$A4,$94,$75,$65,$55,$45,$35
       .byte $25,$15,$05,$F5,$E5,$D5,$C5,$B5,$A5,$95,$76,$66,$56,$46,$36,$26
       .byte $16,$06,$F6,$E6,$D6,$C6,$B6,$A6,$96,$77,$67,$57,$47,$37,$27,$17
       .byte $07,$F7,$E7,$D7,$C7,$B7,$A7,$97,$78,$68,$58,$48,$38,$28,$18,$08
       .byte $F8,$E8,$D8,$C8,$B8,$A8,$98,$79,$69,$59,$49,$39,$29,$19,$09,$F9
       .byte $E9,$D9,$C9,$B9,$A9,$99

START:
       SEI            ;2
       CLD            ;2
       LDX    #$FF    ;2
       TXS            ;2
       INX            ;2
       TXA            ;2
LBC9D: STA    VSYNC,X ;4
       DEX            ;2
       BNE    LBC9D   ;2
       LDA    #$C1    ;2
       STA    $A7     ;3
       LDY    #$00    ;2
       JSR    LBD47   ;6
       JMP    LB26E   ;3

LBCAE: 
       LDX    #$3F    ;2
       LDA    #$00    ;2
LBCB2: STA    $80,X   ;4
       DEX            ;2
       BNE    LBCB2   ;2
       LDX    $80     ;3
       LDA    $BE77,X ;4
       STA    $8D     ;3
       LDA    #$06    ;2
       STA    $85     ;3
       LDA    #$02    ;2
       STA    $A7     ;3
       LDY    #$03    ;2
       JSR    LBD47   ;6
       RTS            ;6

LBCCC: LDA    INTIM   ;4
       BNE    LBCCC   ;2
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       LDA    #$69    ;2
       STA    $8B     ;3
       LDA    #$F6    ;2
       STA    $8C     ;3
       LDA    #$AD    ;2
       STA    $87     ;3
       LDA    #$F9    ;2
       STA    $88     ;3
       LDA    #$FF    ;2
       STA    $89     ;3
       LDA    #$4C    ;2
       STA    $8A     ;3
       JMP.w  $0087   ;3
LBCF0: BIT    $A7     ;3
       BMI    LBD07   ;2
       SED            ;2
       CLC            ;2
       ADC    $9F     ;3
       STA    $9F     ;3
       LDA    $9E     ;3
       ADC    #$00    ;2
       STA    $9E     ;3
       LDA    $9D     ;3
       ADC    #$00    ;2
       STA    $9D     ;3
       CLD            ;2
LBD07: RTS            ;6

LBD08: ROR            ;2
       BCS    LBD0D   ;2
       DEC    $B1,X   ;6
LBD0D: ROR            ;2
       BCS    LBD12   ;2
       INC    $B1,X   ;6
LBD12: ROR            ;2
       BCS    LBD1D   ;2
       DEC    $A8,X   ;6
       CPX    #$02    ;2
       BCC    LBD1D   ;2
       DEC    $A8,X   ;6
LBD1D: ROR            ;2
       BCS    LBD28   ;2
       INC    $A8,X   ;6
       CPX    #$02    ;2
       BCC    LBD28   ;2
       INC    $A8,X   ;6
LBD28: RTS            ;6

LBD29: LDA    $B1,X   ;4
       CMP.wy $00B1,Y ;4
       BEQ    LBD38   ;2
       BCS    LBD36   ;2
       INC    $B1,X   ;6
       BNE    LBD38   ;2
LBD36: DEC    $B1,X   ;6
LBD38: LDA    $A8,X   ;4
       CMP.wy $00A8,Y ;4
       BEQ    LBD43   ;2
       BCS    LBD44   ;2
       INC    $A8,X   ;6
LBD43: RTS            ;6

LBD44: DEC    $A8,X   ;6
       RTS            ;6

LBD47: STY    $81     ;3
       LDY    #$7F    ;2
       LDA    #$00    ;2
       STA    $83     ;3
       STA    $EE     ;3
       LDX    #$05    ;2
LBD53: STA    $93,X   ;4
       STY    $B3,X   ;4
       DEX            ;2
       BPL    LBD53   ;2
       LDY    $81     ;3
       BNE    LBDA4   ;2
       INC    $8D     ;5
       LDX    #$05    ;2
LBD62: STA    $DB,X   ;4
       STA    $D5,X   ;4
       DEX            ;2
       BPL    LBD62   ;2
       LDA    LBEC8   ;4
       STA    $E6     ;3
       LDA    #$B0    ;2
       STA    $99     ;3
       LDA    #$84    ;2
       STA    $A8     ;3
       BIT    $A7     ;3
       BMI    LBD7C   ;2
       STA    $A5     ;3
LBD7C: LDA    #$04    ;2
       STA    $DD     ;3
       LDA    #$40    ;2
       STA    $D7     ;3
       LDA    $EA     ;3
       AND    #$07    ;2
       TAX            ;2
       LDA    LBE6F,X ;4
       STA    $A6     ;3
       LDX    $8D     ;3
       CPX    #$10    ;2
       BCS    LBD9A   ;2
       LDA    LBF01,X ;4
       STA    $E7     ;3
       RTS            ;6

LBD9A: TXA            ;2
       AND    #$03    ;2
       TAX            ;2
       LDA    LBF11,X ;4
       STA    $E7     ;3
       RTS            ;6

LBDA4: DEY            ;2
       BNE    LBDE6   ;2
       LDA    #$10    ;2
       STA    $B1     ;3
       LDA    #$30    ;2
       STA    $B2     ;3
       LDA    #$40    ;2
       STA    $A9     ;3
       STA    $A8     ;3
       STA    $B0     ;3
       STA    $8E     ;3
       LDA    $A4     ;3
       AND    #$03    ;2
       TAY            ;2
       LDA    LBEB7,Y ;4
       STA    $E1     ;3
       LDA    LBEBB,Y ;4
       STA    $D7     ;3
       STA    $D8     ;3
       STA    $D9     ;3
       STA    $DA     ;3
       LDA    #$29    ;2
       BIT    SWCHB   ;4
       BVS    LBDD7   ;2
       LDA    #$38    ;2
LBDD7: STA    $C6     ;3
       LDA    #$00    ;2
       STA    $DB     ;3
       LDA    #$80    ;2
       BIT    $A7     ;3
       BMI    LBDE5   ;2
       STA    $A5     ;3
LBDE5: RTS            ;6

LBDE6: DEY            ;2
       BNE    LBE14   ;2
       LDA    #$1F    ;2
       STA    $E1     ;3
       LDA    #$05    ;2
       STA    $B2     ;3
       LDA    #$36    ;2
       STA    $B1     ;3
       STA    $A8     ;3
       LDA    #$48    ;2
       STA    $A9     ;3
       LDA    #$00    ;2
       STA    $DB     ;3
       STA    $EB     ;3
       STA    $D7     ;3
       STA    $D8     ;3
       STA    $D9     ;3
       STA    $DA     ;3
       LDA    $EA     ;3
       AND    #$03    ;2
       TAX            ;2
       LDA    LBEAF,X ;4
       STA    $EC     ;3
       RTS            ;6

LBE14: LDA    #$3E    ;2
       STA    $A9     ;3
       LDA    #$44    ;2
       STA    $A8     ;3
       LDA    #$C0    ;2
       STA    $99     ;3
       LDA    #$00    ;2
       STA    $86     ;3
       STA    $82     ;3
       STA    $83     ;3
       LDA    #$87    ;2
       STA    $91     ;3
       RTS            ;6

LBE2D: .byte $05,$05,$05,$05,$05,$05,$05,$04,$04,$04,$04,$04,$04,$03,$03,$03
       .byte $03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01
       .byte $01,$01,$1C,$18,$14,$10,$0C,$08,$04,$00,$01,$05,$09,$0D,$11,$15
       .byte $19,$1D,$1E,$1A,$16,$12,$0E,$0A,$06,$02,$03,$07,$0B,$0F,$13,$17
       .byte $1B,$1F
LBE6F: .byte $07,$0D,$09,$17,$11,$0A,$0B,$13,$FF,$00,$01,$02
LBE7B: .byte $06,$88
LBE7D: .byte $C7,$CB
LBE7F: .byte $86,$8A,$8B,$8E,$8A,$87,$8E,$86,$01,$02,$04,$08,$10,$20,$40,$80
LBE8F: .byte $00,$00,$00,$00,$00,$85,$85,$85,$00,$89,$89,$89,$00,$8D,$8D,$8D
LBE9F: .byte $00,$00,$00,$00,$00,$50,$50,$50,$00,$48,$48,$48,$00,$40,$40,$40
LBEAF: .byte $8A,$86,$89,$85
LBEB3: .byte $00,$3F,$7F,$BF

LBEB7: .byte $0C,$10,$18,$20    ; Colors?

LBEBB: .byte $64,$AA,$BD,$FF
LBEBF: .byte $00

; Color the stripe flashes when enemy is hit
    IF COMPILE_VERSION > NTSC
    .byte $22
    ELSE
    .byte $1E
    ENDIF
    .byte $4A,$18

; Main background colors (lowest to highest)
    IF COMPILE_VERSION > NTSC
LBEC3: .byte $82,$84
LBEC5: .byte $D2,$84,$82
LBEC8: .byte $80
    ELSE
LBEC3: .byte $52,$54
LBEC5: .byte $72,$54,$52
LBEC8: .byte $50
    ENDIF

       .byte $00,$00,$00,$23,$57,$99,$00,$14
LBED1: .byte $0C,$08,$0C,$0C,$14,$0C,$0C,$0C
LBED9: .byte $08,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$14,$08,$0C,$08,$0C,$0C,$14,$08
LBEE9: .byte $00,$01,$01,$03,$03,$03,$04,$04
LBEF1: .byte $FF,$BF,$FF,$7F,$BF,$FF,$7F,$BF
LBEF9: .byte $0B,$16,$21,$2C
LBEFD: .byte $8F,$9A,$A5,$B0
LBF01: .byte $0F,$1C,$27,$30,$1D,$28,$30,$38,$22,$28,$2C,$35,$12,$20,$2C,$37
LBF11: .byte $20,$30,$40,$4C
LBF15: .byte $01,$0D,$19,$25,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$96,$BC,$96,$BC,$96,$BC


; Second bank

       ORG $2000
       RORG $F000

START2:
       LDA    $FFF8   ;4
       JMP    $BC96   ;3

LF006: STA    WSYNC   ;3
       LDA    #$FF    ;2
       STA    PF0     ;3
       LDY    $C8     ;3
       LDA    ($C9),Y ;5
       STA    GRP1    ;3
       LDY    $C7     ;3
       INY            ;2
       STY    $C7     ;3
       BMI    LF023   ;2
       LDA    LFF00,Y ;4
       STA    GRP0    ;3
       LDA    LFF82,Y ;4
       STA    COLUP0  ;3    Missile (rocket) sprite color on the 1st game level - on stripes
LF023: LDA    #$00    ;2
       STA    PF0     ;3
       LDX    #$1F    ;2
       TXS            ;2
       LDX    $87     ;3
       CPX    $B5     ;3
       PHP            ;3
       CPX    $B4     ;3
       PHP            ;3
       CPX    $B3     ;3
       PHP            ;3
       LDA    #$FF    ;2
       STA    WSYNC   ;3
       STA    PF0     ;3
       LDY    $C8     ;3
       LDA    ($CB),Y ;5
       STA    GRP1    ;3
       LDA    ($CD),Y ;5
       STA    COLUP1  ;3    All the characters' colors on level 1
       LDY    $C7     ;3
       BMI    LF04E   ;2
       LDA    LFF41,Y ;4
       STA    GRP0    ;3
LF04E: LDA    #$00    ;2
       STA    PF0     ;3
       INC    $87     ;5
       DEC    $C8     ;5
       BPL    LF006   ;2
; Entry point for first scene!
Entry1
       LDX    $C6     ;3
       DEX            ;2
       BPL    LF060   ;2
       JMP    LF28B   ;3
LF060: STX    $C6     ;3
       LDA    $CF,X   ;4
       STA    HMP1    ;3
       AND    #$0F    ;2
       STA    WSYNC   ;3
       LDX    #$00    ;2
       STX    GRP1    ;3
       STX    COLUBK  ;3    Flashing background (left) during gameplay (?)
       INY            ;2
       STY    $C7     ;3
       BMI    LF082   ;2
       LDX    LFF00,Y ;4
       STX    GRP0    ;3
       LDX    LFF82,Y ;4
       STX    COLUP0  ;3    Missile (rocket) sprite color on the 1st game level - in-between stripes
       LDX    LFF41,Y ;4
LF082: TAY            ;2
       TXA            ;2
       LDX    #$1F    ;2
       TXS            ;2
       LDX    $87     ;3
       CPX    $B5     ;3
       PHP            ;3
       CPX    $B4     ;3
       PHP            ;3
       CPX    $B3     ;3
       PHP            ;3
       LDX    #$1F    ;2
       TXS            ;2
       STA    WSYNC   ;3
       STA    GRP0    ;3
       INC    $87     ;5
    IF COMPILE_VERSION > NTSC
       LDX    #$3F    ;2
    ELSE
       LDX    #$EF    ;2
    ENDIF
       STX    COLUP1  ;3    Sets sprite 1 color between stripes (resets characters' color)
       LDX    $C7     ;3
       LDA    #$00    ;2
LF0A3: DEY            ;2
       BPL    LF0A3   ;2
       STA    RESP1   ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDY    #$00    ;2
       INX            ;2
       STX    $C7     ;3
       BMI    LF0C0   ;2
       LDA    LFF00,X ;4
       STA    GRP0    ;3
       LDA    LFF82,X ;4
       STA    COLUP0  ;3    Missile (rocket) sprite color on the 1st game level - in-between stripes (at start of stripe)
       LDY    LFF41,X ;4
LF0C0: LDX    $C6     ;3
       LDA    #$FF    ;2
       CMP    $DB,X   ;4
       BMI    LF0CA   ;2
       LDA    #$00    ;2
LF0CA: STA    REFP1   ;3
       LDA    $87     ;3
       CMP    $B5     ;3
       PHP            ;3
       CMP    $B4     ;3
       PHP            ;3
       CMP    $B3     ;3
       PHP            ;3
       INC    $87     ;5
       STA    WSYNC   ;3
       STY    GRP0    ;3
       LDA    #$FF    ;2
       STA    PF0     ;3
       LDA    $E1,X   ;4
       STA    COLUBK  ;3    Main background during gameplay
       LDA    #$0A    ;2
       STA    $C8     ;3
       LDA    $DB,X   ;4
       AND    #$1F    ;2    Pick sprite's anim frame
       TAY            ;2
       LDA    #$00    ;2
       STA    PF0     ;3
       LDA    LFBD1,Y ;4
       STA    $C9     ;3
       STA    $CB     ;3
       CPX    #$02    ;2
       BNE    LF105   ;2
       BIT    $83     ;3
       BPL    LF105   ;2
       LDA    $84     ;3
       BNE    LF108   ;2
LF105: LDA    LFCD1,Y ;4
LF108: STA    $CD     ;3
       JMP    LF006   ;3
LF10D: STA    WSYNC   ;3

    IF FIX_INTRO = YES
       LDA    $FE50,X ;4
       STA    PF2     ;3
    ELSE
    ENDIF

       LDY    $C7     ;3
       INY            ;2
       STY    $C7     ;3
       BMI    LF153   ;2
       CPY    #$41    ;2
       BCS    LF13B   ;2
       LDA    #$02    ;2
       BIT    $A7     ;3
       BMI    LF122   ;2
       BEQ    LF12E   ;2
LF122: LDA    LF75C,Y ;4
       STA    GRP1    ;3
    IF COMPILE_VERSION > NTSC
       LDA    #$2E    ;2
    ELSE
       LDA    #$FE    ;2
    ENDIF
       STA    COLUP1  ;3    A-Team logo color in intro
       JMP    LF159   ;3
LF12E: LDA    LFF00,Y ;4
       STA    GRP1    ;3
       LDA    LFF82,Y ;4
       STA    COLUP1  ;3    Missile color between 2nd and 3rd level - same shape and color table as the one on level 1
       JMP    LF159   ;3
LF13B: LDY    $82     ;3
       LDA    ($87),Y ;5
       AND    $8B     ;3
       STA    GRP0    ;3
       EOR    $82     ;3
       AND    $8C     ;3
       STA    GRP1    ;3
       ORA    #$E8    ;2
       STA    COLUP1  ;3    Color of fuel exhaust in intro - P1 (color is actually obtained by the shape data)
       LDA    #$0E    ;2
       STA    COLUP0  ;3    Color of fuel exhaust in intro - P0 (color is actually obtained by the shape data)
       BNE    LF159   ;2
LF153: LDA    #$00    ;2
       STA    GRP0    ;3
       STA    GRP1    ;3
LF159:
    IF FIX_INTRO = NO
       LDA    $FE50,X ;4
       STA    PF2     ;3
    ELSE
    ENDIF
       TXA            ;2
       CLC            ;2
       ADC    $82     ;3    Increase starting color for the PF color cycle in the intro
       STA    COLUPF  ;3    Cycling PF colors in the intro screen
       LDY    $C7     ;3
       STA    WSYNC   ;3
       BMI    LF194   ;2
       CPY    #$41    ;2
       BCS    LF184   ;2
       LDA    #$02    ;2
       BIT    $A7     ;3
       BMI    LF176   ;2
       BEQ    LF17C   ;2
LF176: LDA    $F79D,Y ;4
       JMP    LF17F   ;3
LF17C: LDA    LFF41,Y ;4
LF17F: STA    GRP1    ;3
       JMP    LF194   ;3
LF184: LDA    ($87),Y ;5
       AND    $8B     ;3
       STA    GRP0    ;3
       EOR    $82     ;3
       AND    $8C     ;3
       STA    GRP1    ;3
       ORA    #$E8    ;2
       STA    COLUP1  ;3    Exhaust color again?
LF194: TYA            ;2
       LDY    #$00    ;2
       SEC            ;2
       SBC    #$5A    ;2
       BMI    LF19F   ;2
       LSR            ;2
       LSR            ;2
       TAY            ;2
LF19F: LDA    $FCF1,Y ;4
       STA    $8B     ;3
       LDA    $FEEE,Y ;4
       STA    $8C     ;3
       INX            ;2
       CPX    #$4E    ;2
       BCS    LF1B1   ;2
       JMP    LF10D   ;3
LF1B1: JMP    LF28B   ;3
LF1B4: LDY    $C7     ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       STA    GRP1    ;3
       BPL    LF1D2   ;2
       LDA    $87     ;3
       STA    COLUP0  ;3    Set bouncing missile color on game level 2
       CMP    $B1     ;3
       BNE    LF1CA   ;2
       LDA    #$0A    ;2
       STA    $C7     ;3
LF1CA: LDA    #$00    ;2
       STA    GRP0    ;3
       STA    $88     ;3
       BEQ    LF1E0   ;2
LF1D2: LDA    ($CF),Y ;5
       STA    GRP0    ;3
       LDA    ($D3),Y ;5
       STA    COLUP0  ;3    Hannibal's color on level 2
       LDA    ($D1),Y ;5
       STA    $88     ;3
       DEC    $C7     ;5
LF1E0: LDA    $87     ;3
       SEC            ;2
       SBC    $B5     ;3
       CMP    #$08    ;2
       BCS    LF1F0   ;2
       TAY            ;2
       LDA    ($D5),Y ;5
       STA    ENABL   ;3
       STA    HMBL    ;3
LF1F0: LDA    $88     ;3
       LDY    $C8     ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       STA    GRP0    ;3
       BPL    LF20E   ;2
       LDA    $87     ;3
       STA    COLUP1  ;3    Bouncing missile color on level 2?
       CMP    $B2     ;3
       BNE    LF208   ;2
       LDA    #$0A    ;2
       STA    $C8     ;3
LF208: LDA    #$00    ;2
       STA    GRP1    ;3
       BEQ    LF21A   ;2
LF20E: LDA    ($C9),Y ;5
       STA    GRP1    ;3
       LDA    ($CD),Y ;5
       STA    COLUP1  ;3    Mr T's color on levels 2 and 3
       LDA    ($CB),Y ;5
       DEC    $C8     ;5
LF21A: LDX    #$1E    ;2
       TXS            ;2
       LDX    $87     ;3
       CPX    $B4     ;3
       PHP            ;3
       CPX    $B3     ;3
       PHP            ;3
       INX            ;2
       STX    $87     ;3
       CPX    #$4A    ;2
       BCC    LF1B4   ;2
LF22C: STA    WSYNC   ;3
       STA    HMOVE   ;3
    IF COMPILE_VERSION > NTSC
       LDA    #$50    ;2
    ELSE
       LDA    #$C4    ;2
    ENDIF
       STA    COLUBK  ;3    Color for horizontal stripes on lower part of 2nd game screen
       LDA    #$00    ;2
       STA    PF0     ;3
       STA    PF1     ;3
       STA    PF2     ;3
       STA    GRP1    ;3
       STA    GRP0    ;3
       LDY    $DB     ;3
       BEQ    LF249   ;2
       LDA    $FA58,Y ;4
       BNE    LF250   ;2
LF249:
       LDA    $82     ;3    get ...?
       ROR            ;2    Shift right
       AND    #$07    ;2    Mask out 5 most significant bits (only get 3 least significant ones)
       ORA    #$50    ;2    Set bits 4 and 6 and obtain...
LF250:  ; ***
       STA    COLUPF  ;3    ...PF color of scrolling blocks at bottom of 2nd level
       LDA    $87     ;3
       SEC            ;2
       SBC    $B5     ;3
       CMP    #$08    ;2
       BCS    LF262   ;2
       TAY            ;2
       LDA    ($D5),Y ;5
       STA    ENABL   ;3
       STA    HMBL    ;3
LF262: STA    WSYNC   ;3
       STA    HMOVE   ;3
       INC    $87     ;5
       LDA    $87     ;3
       CMP    #$4E    ;2
       BCC    LF271   ;2
       JMP    LF28B   ;3
LF271: LDA    #$00    ;2
       STA    COLUBK  ;3
       LDX    $D7     ;3
       STX    PF1     ;3
       LDX    $D8     ;3
       STX    PF2     ;3
       LDX    $D9     ;3
       LDY    $DA     ;3
       LDA    LF22C   ;4
       NOP            ;2
       STX    PF2     ;3
       STY    PF1     ;3
       BNE    LF22C   ;2
LF28B: STA    WSYNC   ;3
       LDX    #$FF    ;2
       TXS            ;2
       INX            ;2
       STX    COLUPF  ;3    BG color of score panel (black)
       STX    COLUBK  ;3    Last 2 lines of main display for both game and intro screen...
       STX    GRP0    ;3
       STX    GRP1    ;3
       STX    ENAM0   ;3
       STX    ENAM1   ;3
       STX    ENABL   ;3
       LDA    #$01    ;2
       STA    CTRLPF  ;3
       LDA    $9D     ;3
       CMP    $A0     ;3
       STA    WSYNC   ;3
       BNE    LF2B7   ;2
       LDA    $9E     ;3
       CMP    $A1     ;3
       BNE    LF2B7   ;2
       LDA    $9F     ;3
       CMP    $A2     ;3
       BEQ    LF2D3   ;2
LF2B7: SED            ;2
       LDA    #$01    ;2
       CLC            ;2
       ADC    $A2     ;3
       STA    $A2     ;3
       LDA    $A1     ;3
       ADC    #$00    ;2
       STA    $A1     ;3
       LDA    $A0     ;3
       PHP            ;3
       ADC    #$00    ;2
       STA    $A0     ;3
       PLP            ;4
       CLD            ;2
       BCC    LF2D3   ;2
       INC    $85     ;5
       INX            ;2
LF2D3: STA    WSYNC   ;3
       TXA            ;2
       BEQ    LF2DC   ;2
       LDA    #$8B    ;2
       STA    $91     ;3
LF2DC: LDX    $81     ;3
       DEX            ;2
       BNE    LF2F9   ;2
       BIT    $9C     ;3
       BMI    LF2F9   ;2
       BIT    $A7     ;3
       BMI    LF2F9   ;2
       BIT    $A5     ;3
       BMI    LF2F9   ;2
       LDA    $82     ;3
       AND    #$3F    ;2
       EOR    #$3F    ;2
       LSR            ;2
       LSR            ;2
       ORA    #$70    ;2
       BNE    LF2FB   ;2
LF2F9:
    IF COMPILE_VERSION > NTSC
       LDA    #$4E    ;2
    ELSE
       LDA    #$FE    ;2
    ENDIF
LF2FB:
       STA    COLUP0  ;3    Score color
       STA    COLUP1  ;3    Score color
       LDX    #$00    ;2
       STX    HMP0    ;3
       STA    WSYNC   ;3
       STX    PF0     ;3
       STX    COLUBK  ;3    Blanks out some garbage before the last part of main screen display
       STX    PF1     ;3
       STX    PF2     ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDA    #$03    ;2
       LDY    #$00    ;2
       STY    REFP1   ;3
       STA    NUSIZ0  ;3
       STA    NUSIZ1  ;3
       STA    VDELP0  ;3
       STA    VDELP1  ;3
       STY    GRP0    ;3
       STY    GRP1    ;3
       STY    GRP0    ;3
       STY    GRP1    ;3
       NOP            ;2
       STA    RESP0   ;3
       STA    RESP1   ;3
       STY    HMP1    ;3
       LDA    #$F0    ;2
       STA    HMP0    ;3
       STY    REFP0   ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDX    #$FA    ;2
       BIT    $A5     ;3
       BPL    LF344   ;2
       LDA    $82     ;3
       AND    #$40    ;2
       BEQ    LF346   ;2
LF344: LDX    #$FE    ;2
LF346: STX    $BB     ;3
       STX    $BD     ;3
       STX    $BF     ;3
       STX    $C1     ;3
       STX    $C3     ;3
       STX    $C5     ;3
       STA    WSYNC   ;3
       LDX    $81     ;3
       DEX            ;2
       BNE    LF36D   ;2
       BIT    $9C     ;3
       BMI    LF36D   ;2
       BIT    $A7     ;3
       BMI    LF36D   ;2
       LDA    $C6     ;3
       STA    $88     ;3
       LDA    #$AA    ;2
       STA    $87     ;3
       STA    $89     ;3
       BNE    LF379   ;2
LF36D: LDA    $A0     ;3
       STA    $87     ;3
       LDA    $A1     ;3
       STA    $88     ;3
       LDA    $A2     ;3
       STA    $89     ;3
LF379: LDA    $82     ;3
       ORA    #$07    ;2
       SEC            ;2
       ROR            ;2
       ROR            ;2
       ROR            ;2
       STA    PF1     ;3
       LDA    #$FF    ;2
       STA    PF0     ;3
       STA    PF2     ;3
       STA    WSYNC   ;3
       BIT    $A5     ;3
       BPL    LF3BE   ;2
       LDA    $82     ;3
       AND    #$40    ;2
       BNE    LF3BE   ;2
       LDX    $81     ;3
       LDA    LFBF1,X ;4
       STA    $BA     ;3
       LDA    LFBF3,X ;4
       STA    $BC     ;3
       LDA    LFBF5,X ;4
       STA    $BE     ;3
       LDA    LFBF7,X ;4
       STA    $C0     ;3
       LDA    LFBF9,X ;4
       STA    $C2     ;3
       LDA    LFBFB,X ;4
       STA    $C4     ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       JMP    LF47F   ;3
LF3BE: LDA    #$42    ;2
       BIT    $A7     ;3
       BPL    LF3C7   ;2
       LDA    $82     ;3
       LSR            ;2
LF3C7: 
       STA    COLUBK  ;3    Last part of main display
       LDA    $87     ;3
       AND    #$F0    ;2
       BNE    LF3D1   ;2
       LDA    #$A0    ;2
LF3D1: LSR            ;2
       STA    $BA     ;3
       LDA    $87     ;3
       AND    #$0F    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       STA    $BC     ;3
       STA    WSYNC   ;3
       LDA    $88     ;3
       AND    #$F0    ;2
       LSR            ;2
       STA    $BE     ;3
       LDA    $88     ;3
       AND    #$0F    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       STA    $C0     ;3
       STA    WSYNC   ;3
       LDA    $89     ;3
       AND    #$F0    ;2
       LSR            ;2
       STA    $C2     ;3
       LDA    $89     ;3
       AND    #$0F    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       STA    $C4     ;3
       STA    WSYNC   ;3
       LDA    $A7     ;3
       ROR            ;2
       BCC    LF422   ;2
       LDA    #$50    ;2
       STA    $BA     ;3
       LDA    #$9E    ;2
       STA    $BC     ;3
       LDA    #$A6    ;2
       STA    $BE     ;3
       LDA    #$AE    ;2
       STA    $C0     ;3
       LDA    #$B6    ;2
       STA    $C2     ;3
       LDA    #$BE    ;2
       STA    $C4     ;3
       BNE    LF47F   ;2
LF422: BIT    $9C     ;3
       BPL    LF446   ;2
       LDA    #$20    ;2
       BIT    $82     ;3
       BEQ    LF446   ;2
       LDA    #$50    ;2
       STA    $BA     ;3
       LDA    #$C6    ;2
       STA    $BC     ;3
       LDA    #$CE    ;2
       STA    $BE     ;3
       LDA    #$D6    ;2
       STA    $C0     ;3
       LDA    #$DE    ;2
       STA    $C2     ;3
       LDA    #$E6    ;2
       STA    $C4     ;3
       BNE    LF47F   ;2
LF446: LDA    #$20    ;2
       BIT    $A7     ;3
       BEQ    LF461   ;2
       LDX    $80     ;3
       LDA    LFA61,X ;4
       STA    $C0     ;3
       LDA    #$50    ;2
       STA    $BA     ;3
       STA    $BC     ;3
       STA    $BE     ;3
       STA    $C2     ;3
       STA    $C4     ;3
       BNE    LF47F   ;2
LF461: LDY    #$50    ;2
       CPY    $BA     ;3
       BNE    LF47F   ;2
       LDA    $BC     ;3
       BNE    LF47F   ;2
       STY    $BC     ;3
       LDA    $BE     ;3
       BNE    LF47F   ;2
       STY    $BE     ;3
       LDA    $C0     ;3
       BNE    LF47F   ;2
       STY    $C0     ;3
       LDA    $C2     ;3
       BNE    LF47F   ;2
       STY    $C2     ;3
LF47F: STA    WSYNC   ;3
       LDA    #$07    ;2
       STA    $87     ;3
       JSR    LF632   ;6
       STA    WSYNC   ;3
       LDA    $81     ;3
       BEQ    LF4A2   ;2
       CMP    #$03    ;2
       BCS    LF4A2   ;2
       LDA    $82     ;3
       ROR            ;2
       BCS    LF4A2   ;2
       LDX    $DB     ;3
       BEQ    LF4A2   ;2
       LDA    LFFC3,X ;4
       STA    $92     ;3
       DEC    $DB     ;5
LF4A2: STA    WSYNC   ;3
       LDX    $85     ;3
       CPX    #$07    ;2
       BCC    LF4AC   ;2
       LDX    #$06    ;2
LF4AC: LDA    LFFCC,X ;4
       STA    NUSIZ0  ;3
       STA    $8A     ;3
       LDA    LFFD3,X ;4
       STA    NUSIZ1  ;3
       STA    $8B     ;3
    IF COMPILE_VERSION > NTSC
       LDA    #$8C    ;2
    ELSE
       LDA    #$5C    ;2
    ENDIF
       STA    COLUP0  ;3    Color of lives indicator below score
       STA    COLUP1  ;3    Color of lives indicator below score
       STA    WSYNC   ;3
       LDA    #$08    ;2
       BIT    $8A     ;3
       BMI    LF4D0   ;2
       STA    GRP0    ;3
       BIT    $8B     ;3
       BMI    LF4D0   ;2
       STA    GRP1    ;3
LF4D0: STA    WSYNC   ;3
       LDA    #$14    ;2
       BIT    $8A     ;3
       BMI    LF4E0   ;2
       STA    GRP0    ;3
       BIT    $8B     ;3
       BMI    LF4E0   ;2
       STA    GRP1    ;3
LF4E0: STA    WSYNC   ;3
       LDA    #$08    ;2
       BIT    $8A     ;3
       BMI    LF4F0   ;2
       STA    GRP0    ;3
       BIT    $8B     ;3
       BMI    LF4F0   ;2
       STA    GRP1    ;3
LF4F0: STA    WSYNC   ;3
       LDA    #$00    ;2
       STA    GRP0    ;3
       STA    GRP1    ;3

; VBLANK timer!

        IF COMPILE_VERSION = PAL
            LDX    #$41    ;
        ELSE
            LDX    #$25    ;
        ENDIF

       LDA    $81     ;3
       BNE    LF4FF   ;2
       DEX            ;2
LF4FF: STA    WSYNC   ;3
       LDA    #$0F    ;2
       STA    VBLANK  ;3
       NOP            ;2
       STX    TIM64T  ;4
       LDA    #$02    ;2
       BIT    SWCHB   ;4
       BNE    LF536   ;2
       LDA    #$08    ;2
       BIT    $8E     ;3
       BNE    LF526   ;2
       ORA    $8E     ;3
       STA    $8E     ;3
       LDA    #$00    ;2
       STA    $82     ;3
       STA    $A5     ;3
       LDA    #$A0    ;2
       STA    $A7     ;3
       BNE    LF52C   ;2
LF526: LDA    $82     ;3
       AND    #$1F    ;2
       BNE    LF53C   ;2
LF52C: INC    $80     ;5
       LDA    $80     ;3
       AND    #$03    ;2
       STA    $80     ;3
       BPL    LF53C   ;2
LF536: LDA    $8E     ;3
       AND    #$F7    ;2
       STA    $8E     ;3
LF53C: BIT    $A7     ;3
       BPL    LF543   ;2
       JMP    LFDC0   ;3
LF543: LDA    $81     ;3
       ROR            ;2
       BCC    LF550   ;2
       BIT    $83     ;3
       BMI    LF550   ;2
       LDA    #$00    ;2
       STA    AUDV0   ;3
LF550: LDA    $82     ;3
       AND    #$03    ;2
       BNE    LF55F   ;2
       LDX    $8F     ;3
       BEQ    LF55F   ;2
       DEX            ;2
       STX    $8F     ;3
       STX    AUDV0   ;3
LF55F: LDX    $90     ;3
       BEQ    LF568   ;2
       DEX            ;2
       STX    $90     ;3
       STX    AUDV1   ;3
LF568: LDA    $81     ;3
       CMP    #$02    ;2
       BNE    LF5CD   ;2
       BIT    $9C     ;3
       BPL    LF575   ;2
       JMP    LF5F6   ;3
LF575: BIT    $A3     ;3
       BPL    LF59F   ;2
       BVS    LF58B   ;2
       LDA    $B1     ;3
       LSR            ;2
       LSR            ;2
       STA    AUDV1   ;3
       LDA    #$02    ;2
       STA    AUDC1   ;3
       LDA    #$10    ;2
       STA    AUDF1   ;3
       BNE    LF5F6   ;2
LF58B: LDA    $A8     ;3
       LSR            ;2
       LSR            ;2
       LSR            ;2
       STA    AUDV1   ;3
       STA    $90     ;3
       LDA    $A9     ;3
       LSR            ;2
       STA    AUDF1   ;3
       LDA    #$0F    ;2
       STA    AUDC1   ;3
       BNE    LF5F6   ;2
LF59F: LDA    $8F     ;3
       BNE    LF5B1   ;2
       LDA    #$0E    ;2
       STA    AUDC0   ;3
       STA    AUDF0   ;3
       LDA    $82     ;3
       LSR            ;2
       LSR            ;2
       AND    #$07    ;2
       STA    AUDV0   ;3
LF5B1: BIT    $95     ;3
       BPL    LF5F6   ;2
       LDA    $B5     ;3
       SEC            ;2
       SBC    #$05    ;2
       LSR            ;2
       CMP    #$20    ;2
       BCC    LF5C1   ;2
       LDA    #$1F    ;2
LF5C1: STA    AUDF1   ;3
       LDA    #$08    ;2
       STA    AUDV1   ;3
       STA    $90     ;3
       STA    AUDC1   ;3
       BNE    LF5F6   ;2
LF5CD: LDA    $82     ;3
       ROR            ;2
       BCC    LF5F6   ;2
       LDX    $81     ;3
       BEQ    LF5F6   ;2
       DEX            ;2
       BNE    LF5F6   ;2
       LDA    $B5     ;3
       BIT    $95     ;3
       BPL    LF5E1   ;2
       BVS    LF5E9   ;2
LF5E1: BIT    $98     ;3
       BPL    LF5F6   ;2
       BVC    LF5F6   ;2
       LDA    $B8     ;3
LF5E9: ASL            ;2
       AND    #$0F    ;2
       STA    AUDV1   ;3
       STA    $90     ;3
       LDA    #$0D    ;2
       STA    AUDF1   ;3
       STA    AUDC1   ;3
LF5F6: LDX    #$01    ;2
LF5F8: LDA    $91,X   ;4
       BPL    LF614   ;2
       AND    #$3F    ;2
       TAY            ;2
       LDA    LFAC5,Y ;4
       STA    AUDC0,X ;4
       LDA    LFAD1,Y ;4
       STA    AUDF0,X ;4
       LDA    LFADD,Y ;4
       STA    AUDV0,X ;4
       STA    $8F,X   ;4
       LDA    #$00    ;2
       STA    $91,X   ;4
LF614: DEX            ;2
       BPL    LF5F8   ;2
LF617: LDA    #$28    ;2
       STA    $8B     ;3
       LDA    #$B0    ;2
       STA    $8C     ;3
       LDA    #$AD    ;2
       STA    $87     ;3
       LDA    #$F8    ;2
       STA    $88     ;3
       LDA    #$FF    ;2
       STA    $89     ;3
       LDA    #$4C    ;2
       STA    $8A     ;3
       JMP.w  $0087   ;3
LF632: LDY    $87     ;3
       LDA    ($BA),Y ;5
       STA    GRP0    ;3
       STA    WSYNC   ;3
       LDA    ($BC),Y ;5
       STA    GRP1    ;3
       LDA    ($BE),Y ;5
       STA    GRP0    ;3
       LDA    ($C0),Y ;5
       STA    $88     ;3
       LDA    ($C2),Y ;5
       TAX            ;2
       LDA    ($C4),Y ;5
       TAY            ;2
       LDA    $88     ;3
       STA    GRP1    ;3
       STX    GRP0    ;3
       STY    GRP1    ;3
       STY    GRP0    ;3
       DEC    $87     ;5
       BPL    LF632   ;2
       LDA    #$00    ;2
       STA    WSYNC   ;3
       STA    GRP0    ;3
       STA    GRP1    ;3
       STA    VDELP0  ;3
       STA    VDELP1  ;3
       STA    WSYNC   ;3
       RTS            ;6

START3:
    IF COMPILE_VERSION > NTSC
       LDA    #$7A    ;2    Load standard border PF color for all levels
    ELSE
       LDA    #$BA    ;2    Load standard border PF color for all levels
    ENDIF
       LDY    $81     ;3    If we are not on level 0...
       BNE    LF676   ;2    ... then don't change the border color
       LDA    $82     ;3    If we are on level 0, cycle the border color (and burn some retinas)
       ROR            ;2
       AND    #$0F    ;2

    IF COLOR_CYCLE = YES
       ORA    #$A0    ;2
    ELSE
    IF COMPILE_VERSION > NTSC
       LDA #$7A
    ELSE
       LDA #$BA
    ENDIF
    ENDIF
LF676:
       STA    COLUPF  ;3    Border color for all levels
       LDA    #$00    ;2
       STA    COLUBK  ;3    Top of game screen display
       STA    PF0     ;3
       STA    PF1     ;3
       STA    PF2     ;3
       STA    $87     ;3
       LDX    $81     ;3
       DEX            ;2
       STA    HMCLR   ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       STA    VBLANK  ;3
       BNE    LF69B   ;2
       LDX    #$F0    ;2
       STX    PF0     ;3
       LDX    #$FF    ;2
       STX    PF1     ;3
       STX    PF2     ;3
LF69B: STA    CXCLR   ;3
       LDX    $81     ;3
       LDA    $FFE2,X ;4
       STA    CTRLPF  ;3
       LDA    $FFDA,X ;4
       STA    NUSIZ0  ;3
       LDA    $FFDE,X ;4
       STA    NUSIZ1  ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       BIT    $A3     ;3
       BPL    LF6E2   ;2
       LDA    #$00    ;2
       STA    $D3     ;3
       STA    $CD     ;3
       LDA    #$FD    ;2
       STA    $CE     ;3
       STA    $D4     ;3
       LDA    $82     ;3
       AND    #$03    ;2
       ORA    #$F0    ;2
       TAX            ;2
       STX    $CA     ;3
       STX    $D2     ;3
       INX            ;2
       STX    $D0     ;3
       STX    $CC     ;3
       BVS    LF711   ;2
       LDA    #$FD    ;2
       STA    $CE     ;3
       LDA    #$FC    ;2
       STA    $CA     ;3
       LDA    #$FB    ;2
       STA    $CC     ;3
       BNE    LF711   ;2
LF6E2: LDA    #$FD    ;2
       STA    $CE     ;3
       LDY    $81     ;3
       BNE    LF6F8   ;2
       LDA    #$06    ;2
       STA    $C6     ;3
       LDA    #$FB    ;2
       STA    $CA     ;3
       LDA    #$FC    ;2
       STA    $CC     ;3
       BNE    LF711   ;2
LF6F8: STA    $D4     ;3
       LDA    #$FC    ;2
       STA    $CA     ;3
       STA    $D0     ;3
       LDA    #$FB    ;2
       STA    $CC     ;3
       STA    $D2     ;3
       DEY            ;2
       BEQ    LF711   ;2
       LDA    #$F8    ;2
       STA    $D0     ;3
       LDA    #$F9    ;2
       STA    $D2     ;3
LF711: STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDA    #$FF    ;2
       STA    $C7     ;3
       STA    $C8     ;3
       LDX    $81     ;3
       CPX    #$03    ;2
       BNE    LF72D   ;2
       LDA    $82     ;3
       AND    #$03    ;2
       ORA    #$F0    ;2
       STA    $88     ;3
       LDY    $99     ;3
       STY    $C7     ;3
LF72D: LDA    #$FF    ;2
       STA    $8B     ;3
       LDA    #$3E    ;2
       STA    $8C     ;3

    IF FIX_INTRO = YES
        STA WSYNC
        CPX #$03
        BEQ LF73D
        STA HMOVE
    ELSE        
        LDA $81
        BEQ LF73D
        STA WSYNC
        STA HMOVE
    ENDIF
    
LF73D:
       LDA    $FFE6,X ;4
       STA    COLUBK  ;3    Flashing in-game background (left) and main background on the intro screen
       LDA    #$00    ;2
       STA    PF1     ;3
       STA    PF2     ;3
       LDY    $81     ;3
       LDX    $FFEA,Y ;4
       LDA    $FFEF,X ;4
       PHA            ;3
       LDA    $FFEE,X ;4
       PHA            ;3
       LDY    $99     ;3
       LDA    #$00    ;2
       LDX    #$00    ;2
       RTS            ;6

; A-Team logo shape
LF75C:
    ; A - P0
        IF FIX_LOGO = NO
       .byte $00,$08,$08,$14,$1C,$36,$77,$63,$63,$63,$7F,$7F,$63,$63,$00
    ELSE
       .byte $00,$00,$00,$08,$1C,$3E,$36,$63,$63,$7F,$7F,$63,$63,$63,$00
    ENDIF

    ; dash - P0 
       .byte $08,$08,$08,$08,$00
       
       ; T - P0
       .byte $7F,$7F,$5D,$1C,$1C,$1C,$1C,$1C,$1C,$1C,$00

       ; E - P0
       .byte $00,$7F,$7F,$60,$60,$7F,$60,$60,$7F,$7F

    ; A2 - P0
       .byte $00,$08,$1C,$3E,$36,$63,$63,$7F,$7F,$63,$63,$63,$00

    ; M - P0
       .byte $00,$41,$63,$7F,$7F,$6B,$6B,$63,$63,$63,$63
       
       ; A - P1
    IF FIX_LOGO = NO
       .byte $08,$08,$1C,$1C,$3E,$77,$77,$63,$63,$7F,$7F,$63,$63,$00
    ELSE
       .byte $00,$00,$08,$1C,$3E,$36,$63,$63,$7F,$7F,$63,$63,$63,$00
    ENDIF

       ; dash - P1
       .byte $00,$08,$08,$08,$00
       
       ; T - P1
       .byte $00,$7F,$7F,$5D,$1C,$1C,$1C,$1C,$1C,$1C,$00

       ; E - P1
       .byte $00,$7F,$7F,$60,$60,$7F,$7F,$60,$60,$7F,$7F

       ; A2 - P1
       .byte $00,$08,$1C,$3E,$36,$63,$63,$7F,$7F,$63,$63,$63,$00

       ; M - P1
       .byte $00,$41,$77,$7F,$7F,$6B,$63,$63,$63,$63,$63
       
    IF BUGFIX = YES
Entry2
        ; Do an additional WSYNC before playing stage 1!
        STA WSYNC
        JMP Entry1
    ELSE
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00
    ENDIF
       
       ORG $2800
       RORG $F800

       .byte $00,$18,$5A,$7E,$42,$99,$81,$D3,$7E
       .byte $FF,$FF,$66,$00,$18,$DB,$FF,$42,$B1,$89,$D3,$7E,$7E,$7E,$66,$00
       .byte $18,$5A,$7E,$42,$99,$81,$D3,$7E,$FF,$FF,$66,$00,$18,$DB,$FF,$42
       .byte $8D,$91,$D3,$7E,$7E,$7E,$66,$00
LF831: .byte $05,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01,$00,$00,$00,$00,$00
       .byte $05,$05,$05,$00,$00,$05,$05,$00,$05,$00,$00,$00,$00,$05,$05,$05
       .byte $05,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01,$00,$00,$00,$00,$00
       .byte $05,$05,$05,$00,$00,$05,$05,$00,$05,$00,$00,$00,$05,$05,$05,$00
       .byte $05,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01,$00,$00,$00,$00,$00
       .byte $00,$05,$05,$00,$00,$05,$05,$00,$05,$00,$00,$05,$05,$05,$05,$00
       .byte $05,$00,$05,$00,$04,$00,$03,$00,$02,$00,$01,$00,$00,$00,$00,$00
       .byte $00,$05,$05,$00,$00,$05,$05,$00,$05,$00,$00,$00,$05,$05,$05,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $7E,$66,$5A,$C3,$99,$B9,$52,$C3,$FF,$FF,$00,$00,$7E,$E7,$DB,$C3
       .byte $B1,$B9,$52,$42,$7E,$7E,$00,$00,$7E,$66,$5A,$C3,$99,$B9,$52,$C3
       .byte $FF,$FF,$00,$00,$7E,$E7,$DB,$C3,$8D,$B9,$52,$42,$7E,$7E,$00,$00
LF931: .byte $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$1D,$1D,$1D,$1A,$17,$16,$16,$16
       .byte $13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$11,$11,$1A,$13,$13,$13
       .byte $14,$16,$18,$1A,$1A,$1A,$1A,$1A,$1A,$1A,$11,$11,$11,$11,$13,$13
       .byte $13,$13,$13,$13,$13,$13,$13,$13,$13,$13,$1A,$1A,$13,$13,$13,$13
LF971: .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
       .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
       .byte $05,$05,$05,$05,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C,$0C
       .byte $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $1F,$FF,$FF,$1F,$1F,$FF,$00,$10,$FF,$FF,$1F,$1F,$FF,$FF,$00,$00
       .byte $FF,$1F,$1F,$FF,$FF,$1F,$00,$F0,$1F,$1F,$FF,$FF,$1F,$1F,$00,$2F
       .byte $DF,$10,$1F,$10,$EF,$1F,$00,$E0,$3F,$FF,$10,$EF,$1F,$00,$00,$FF
       .byte $2F,$DF,$20,$1F,$EF,$2F,$00,$30,$FF,$E0,$1F,$3F,$D0,$FF,$00,$0F
       .byte $0F,$0F,$0F,$0F,$0F,$0F,$00,$1F,$1F,$1F,$1F,$1F,$00,$00,$00,$FF
       .byte $FF,$FF,$FF,$FF,$00,$00,$00

LFA58:
       .byte $00,$7E,$4E,$0E,$FE,$1E,$DE,$EE,$3E

LFA61: .byte $08,$10,$18,$20,$EA,$AA,$2A,$EE,$8A,$AA,$EE,$00,$4E,$E8,$A8,$AE
       .byte $A8,$A8,$AE,$00,$2A,$2A,$2A,$3B,$2A,$2A,$2B,$00,$A5,$A5,$A5,$AD
       .byte $BD,$B5,$A5,$00,$2B,$2A,$2A,$6B,$EA,$AA,$2B,$00,$2B,$AA,$AA,$BA
       .byte $AA,$AA,$3A,$00,$EA,$AA,$EE,$00,$00,$AB,$CA,$AA,$7B,$5A,$73,$00
       .byte $00,$B8,$20,$20,$91,$91,$BB,$00,$00,$DA,$AB,$89,$3A,$2A,$BB,$00
       .byte $00,$A5,$A9,$39,$20,$A0,$60,$00,$00,$2F,$EC,$2E,$00,$00,$00,$00
       .byte $00,$56,$75,$26
LFAC5: .byte $04,$05,$0D,$0F,$08,$02,$03,$0C,$06,$08,$0F,$0C
LFAD1: .byte $04,$08,$08,$03,$02,$1A,$1B,$05,$08,$06,$04,$0F
LFADD: .byte $09,$04,$08,$0E,$0F,$0A,$0E,$0B,$0E,$0F,$0A,$0F,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$C6,$38,$C6,$38,$54,$EE,$D6,$FE,$38,$00,$1C,$42
       .byte $1C,$5E,$BF,$BF,$F5,$FF,$7E,$38,$00,$1C,$42,$1C,$5E,$BF,$BF,$F5
       .byte $FF,$7E,$38,$00,$38,$42,$38,$7A,$FD,$FD,$AF,$FF,$7E,$1C,$00,$38
       .byte $42,$38,$7A,$FD,$FD,$AF,$FF,$7E,$1C,$00,$62,$26,$18,$0C,$3C,$2C
       .byte $0E,$4C,$20,$00,$00,$11,$14,$14,$0E,$3E,$CC,$0E,$0C,$4C,$36,$00
       .byte $0A,$0A,$0C,$06,$6E,$0C,$0E,$0C,$07,$0B,$00,$0C,$0C,$1C,$0C,$3C
       .byte $2C,$0E,$0C,$03,$05,$00,$22,$7E,$44,$76,$7E,$1F,$7F,$A5,$E7,$00
       .byte $00,$44,$7E,$22,$6E,$7E,$7E,$FF,$5A,$7E,$00,$00,$88,$7E,$11,$5A
       .byte $5A,$F8,$FE,$24,$3C,$00,$00,$91,$7E,$88,$3C,$3C,$7E,$7E,$3C,$00
       .byte $00,$00,$6C,$28,$28,$3A,$7A,$7C,$30,$38,$00,$44,$00,$CC,$48,$58
       .byte $74,$F4,$F8,$60,$70,$00,$88,$00,$66,$24,$34,$5C,$5E,$3E,$0C,$1C
       .byte $00,$22,$00,$33,$12,$1A,$0E,$1F,$1F,$06,$0E,$00,$11,$00,$63,$3E
       .byte $1E,$3C,$1E,$0E,$0C,$1C,$3E,$1C,$00,$38,$38,$38,$38,$78,$38,$18
       .byte $38,$7C,$38,$00
LFBD1: .byte $00,$00,$00,$00,$0B,$16,$21,$2C,$58,$4D,$42,$37,$84,$79,$6E,$63
       .byte $8F,$9A,$A5,$B0,$BB,$BB,$C6,$C6,$58,$4D,$42,$37,$84,$79,$6E,$63
LFBF1: .byte $65,$95
LFBF3: .byte $6D,$9D
LFBF5: .byte $75,$A5
LFBF7: .byte $7D,$AD
LFBF9: .byte $85,$B5
LFBFB: .byte $8D,$BD,$00,$00,$00,$00,$82,$6C,$6C,$BA,$28,$FE,$FE,$D6,$7C,$00
       .byte $00,$3C,$81,$3E,$B1,$BB,$7F,$E4,$FF,$3C,$38,$00,$3C,$81,$3E,$B1
       .byte $BB,$7F,$E4,$FF,$3C,$38,$00,$3C,$81,$7C,$8D,$DD,$FE,$27,$FF,$3C
       .byte $1C,$00,$3C,$81,$7C,$8D,$DD,$FE,$27,$FF,$3C,$1C,$06,$22,$0C,$1C
       .byte $1C,$2C,$64,$1E,$40,$00,$00,$31,$17,$14,$0C,$1E,$6E,$04,$1E,$00
       .byte $5C,$00,$18,$0A,$0E,$0C,$3E,$CE,$04,$1E,$01,$0A,$02,$0C,$04,$1C
       .byte $0C,$1C,$2C,$64,$1E,$00,$02,$01,$33,$22,$44,$CC,$6E,$7E,$1F,$FF
       .byte $A5,$00,$00,$66,$44,$22,$66,$76,$7E,$7E,$E7,$5A,$00,$00,$CC,$88
       .byte $11,$33,$7E,$7E,$F8,$E7,$24,$00,$00,$99,$90,$88,$99,$3C,$7E,$7E
       .byte $FF,$3C,$00,$00,$60,$2C,$28,$3A,$7A,$7E,$78,$00,$38,$7C,$38,$C0
       .byte $4C,$48,$78,$F4,$FC,$F0,$00,$70,$F8,$70,$06,$64,$24,$5C,$5E,$7E
       .byte $1E,$00,$1C,$3E,$1C,$03,$32,$12,$1E,$17,$1F,$0F,$00,$0E,$1F,$0E
       .byte $E7,$7F,$3E,$1E,$3E,$1E,$0C,$1C,$18,$1C,$00,$78,$38,$38,$38,$38
       .byte $78,$18,$38,$30,$38,$00

    ; pointers to color frames?
LFCD1: .byte $00,$16,$16,$16,$37,$37,$37,$37,$00,$00,$00,$00,$0B,$0B,$0B,$0B
       .byte $21,$21,$21,$21,$42,$42,$42,$42,$00,$00,$00,$00,$16,$16,$16,$16
       .byte $FF,$FF,$7E,$7E,$3C,$3C,$3C,$18,$18,$18,$00,$00,$00,$00,$00

    ; Color of yellow man on stage 1 (11 lines, 2 pixels high)
    IF COMPILE_VERSION > NTSC
       .byte $2b,$2c,$2c,$2c,$2f,$2f,$2c,$6C,$6C,$0C,$0C
    ELSE
       .byte $16,$1A,$1A,$1A,$1E,$1E,$1A,$4C,$4C,$0C,$0C
    ENDIF

    ; Color of green-legged thing - moving right
    IF COMPILE_VERSION > NTSC
       .byte $3A,$3A,$3A,$3A,$b4,$b4,$0E,$b6,$bA,$bE,$bE
    ELSE
       .byte $EA,$EA,$EA,$EA,$94,$94,$0E,$96,$9A,$9E,$9E
    ENDIF

    ; Color of green-legged thing - moving left (Also: color of death shape (skull&crossbones)!!!!!)
    IF COMPILE_VERSION > NTSC
       .byte $38,$38,$38,$38,$82,$82,$82,$b4,$b8,$bC,$bC
    ELSE
       .byte $E8,$E8,$E8,$E8,$52,$52,$52,$94,$98,$9C,$9C
    ENDIF
    
    ; Color of hannibal (1st stage)
    IF COMPILE_VERSION > NTSC
       .byte $00,$50,$56,$56,$56,$54,$54,$54,$6A,$54,$54
    ELSE
       .byte $00,$C2,$C8,$C8,$C8,$C6,$C6,$C6,$4A,$C6,$C6
    ENDIF
    
    ; Color of hannibal (2nd stage) (what a waste!)
    IF COMPILE_VERSION > NTSC
       .byte $00,$50,$56,$56,$56,$54,$54,$54,$6A,$54,$54
    ELSE
       .byte $00,$C2,$C8,$C8,$C8,$C6,$C6,$C6,$4A,$C6,$C6
    ENDIF

    ; Color of Mr T (which incredibly is the same for all the 3 stages! whoaaa!)
    IF COMPILE_VERSION > NTSC
       .byte $00,$2C,$2C,$00,$44,$44,$44,$44,$44,$44,$00
    ELSE
       .byte $00,$1A,$1A,$00,$36,$36,$36,$36,$36,$36,$00
    ENDIF

    ; Color of Man in Black
    IF COMPILE_VERSION > NTSC
       .byte $00,$00,$00,$00,$00,$00,$02,$6A,$6A,$00,$00
    ELSE
       .byte $00,$00,$00,$00,$00,$00,$02,$4A,$4A,$00,$00
    ENDIF
    
    ; Color of last enemy (which should represent...?)
    IF COMPILE_VERSION > NTSC
       .byte $4a,$4a,$48,$44,$44,$48,$44,$46,$48,$48,$4a
    ELSE
       .byte $2E,$2E,$2A,$26,$26,$2A,$26,$28,$2A,$2A,$2E
    ENDIF

    ; Colors Mr T cycles through when hit
    IF COMPILE_VERSION > NTSC
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$8E,$00,$00,$00,$00,$8E,$8C,$8E,$00,$00,$00,$8E,$8C
       .byte $8A,$8C,$8E,$00,$00,$00,$8E,$8C,$8A,$88,$8A,$8C,$8E,$00,$00,$8E
       .byte $8C,$8A,$88,$86,$88,$8A,$8C,$8E,$00,$00,$8E,$8C,$8A,$88,$86,$84
       .byte $86,$88,$8A,$8C,$8E,$00,$8E,$8C,$8A,$88,$86,$84,$82,$84,$86,$88
       .byte $8A,$8C,$8E,$8C,$8A,$88,$86,$84,$82,$80,$82,$84,$86,$88,$8A,$8C
       .byte $8E,$8C,$8A,$88,$86,$84,$82,$80,$82,$84,$86,$88,$8A,$8C,$8E
    ELSE
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$5E,$00,$00,$00,$00,$5E,$5C,$5E,$00,$00,$00,$5E,$5C
       .byte $5A,$5C,$5E,$00,$00,$00,$5E,$5C,$5A,$58,$5A,$5C,$5E,$00,$00,$5E
       .byte $5C,$5A,$58,$56,$58,$5A,$5C,$5E,$00,$00,$5E,$5C,$5A,$58,$56,$54
       .byte $56,$58,$5A,$5C,$5E,$00,$5E,$5C,$5A,$58,$56,$54,$52,$54,$56,$58
       .byte $5A,$5C,$5E,$5C,$5A,$58,$56,$54,$52,$50,$52,$54,$56,$58,$5A,$5C
       .byte $5E,$5C,$5A,$58,$56,$54,$52,$50,$52,$54,$56,$58,$5A,$5C,$5E
    ENDIF
    ; --

LFDC0: LDX    $EF     ;3
       BEQ    LFDEE   ;2
       LDA    $82     ;3
       AND    #$03    ;2
       BNE    LFDEB   ;2
       LDA    $EF     ;3
       LSR            ;2
       TAY            ;2
       DEC    $EF     ;5
       LDA    #$08    ;2
       STA    AUDC0   ;3
       LDA    LF831,X ;4
       STA    AUDV0   ;3
       LDA    #$06    ;2
       STA    AUDF0   ;3
       LDA    #$09    ;2
       STA    AUDV1   ;3
       LDA    LF931,Y ;4
       STA    AUDF1   ;3
       LDA    LF971,Y ;4
       STA    AUDC1   ;3
LFDEB: JMP    LF617   ;3
LFDEE: STX    AUDV0   ;3
       STX    AUDV1   ;3
       JMP    LF617   ;3
LFDF5: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FE,$86,$86,$86,$82
       .byte $82,$FE,$00,$18,$18,$18,$18,$08,$08,$08,$00,$FE,$C0,$C0,$FE,$02
       .byte $82,$FE,$00,$FE,$86,$06,$7E,$02,$82,$FE,$00,$06,$06,$FE,$82,$82
       .byte $80,$80,$00,$FE,$86,$06,$FE,$80,$82,$FE,$00,$FE,$86,$86,$FE,$80
       .byte $88,$F8,$00,$06,$06,$06,$06,$02,$02,$FE,$00,$FE,$82,$82,$FE,$44

;FE45
       .byte $44,$7C,$00,$06,$06,$06,$FE,$82,$82,$FE,$00
;FE50
    ; -- Intro screen PF shape
       .byte $00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04
       .byte $0E,$1F,$0E,$04,$0E,$04,$0E,$FF,$0E,$04,$0E,$1F,$0E,$04,$0E,$04
       .byte $0E,$FF,$0E,$04,$0E,$1F,$0E,$04,$0E,$04,$0E,$FF,$0E,$04,$0E,$1F
       .byte $0E,$04,$0E,$04,$0E,$FF,$0E,$04,$0E,$1F,$0E,$04,$0E,$04,$0E,$FF
       .byte $0E,$04,$0E,$1F,$0E,$04,$0E,$04,$0E
    ; --
       .byte $79,$85,$B5,$A5,$B5,$85,$79
       .byte $00,$17,$15,$15,$77,$55,$55,$77,$00,$11,$11,$11,$71,$51,$51,$40
       .byte $00,$49,$49,$49,$C9,$49,$49,$BE,$00,$55,$55,$55,$D9,$55,$55,$99
       .byte $00,$FC,$FE,$EE,$EC,$F8,$FE,$EE,$FC,$3C,$FF,$FF,$E7,$C3,$E7,$FF
       .byte $3C,$73,$77,$6F,$7F,$7F,$7B,$77,$67,$3E,$7F,$77,$77,$77,$77,$63
       .byte $41,$3E,$77,$6F,$1E,$3C,$7B,$77,$3E,$3E,$1C,$1C,$1C,$1C,$08,$08
       .byte $08,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; Missile (rocket) shape, odd lines
LFF00: .byte $08,$08,$08,$14,$1C,$1C,$1C,$7F,$55,$14,$14,$1C,$2A,$2A,$36,$2A
       .byte $2A,$36,$3E,$3E,$1C,$3E,$3E,$3E,$3E,$3E,$2A,$3E,$6B,$6B,$6B,$6B
       .byte $77,$77,$55,$14,$14,$3A,$2A,$6F,$36,$16,$36,$14,$14,$7F,$55,$77
       .byte $7F,$5D,$55,$5D,$5D,$5D,$55,$55,$5D,$5D,$3E,$36,$36,$3E,$36,$36
       .byte $77
; Missile shape, even lines
LFF41: .byte $08,$08,$1C,$1C,$3E,$36,$36,$5D,$1C,$1C,$14,$1C,$3E,$1C,$1C,$3E
       .byte $1C,$3E,$36,$36,$36,$2A,$2A,$2A,$2A,$2A,$2A,$2A,$6B,$7F,$7F,$7F
       .byte $5D,$5D,$5D,$49,$2E,$36,$77,$7B,$6B,$7F,$3E,$3E,$77,$1C,$14,$3E
       .byte $5D,$55,$55,$5D,$5D,$55,$55,$5D,$5D,$5D,$55,$55,$77,$5D,$3E,$77
       .byte $55

; Missile color
LFF82:
    IF COMPILE_VERSION > NTSC
       .byte $6E,$4E,$4E,$4C,$4A,$48,$48,$48,$46,$44,$44,$46,$48,$48,$48,$48
       .byte $48,$2E,$2E,$2E,$2E,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2A,$2A,$2A,$28
       .byte $28,$26,$26,$24,$4E,$4E,$4E,$4E,$4E,$4E,$4A,$4A,$48,$46,$44,$46
       .byte $48,$4A,$4E,$4A,$48,$48,$4E,$4A,$48,$46,$46,$46,$44,$44,$42,$4E
       .byte $42
    ELSE
       .byte $4E,$3E,$3E,$3C,$3A,$38,$38,$38,$36,$34,$34,$36,$38,$38,$38,$38
       .byte $38,$2E,$2E,$2E,$2E,$2C,$2C,$2C,$2C,$2C,$2C,$2C,$2A,$2A,$2A,$28
       .byte $28,$26,$26,$24,$3E,$3E,$3E,$3E,$3E,$3E,$3A,$3A,$38,$36,$34,$36
       .byte $38,$3A,$3E,$3A,$38,$38,$3E,$3A,$38,$36,$36,$36,$34,$34,$32,$3E
       .byte $32
    ENDIF

LFFC3: .byte $00,$80,$80,$82,$82,$86,$86,$81,$83
LFFCC: .byte $80,$00,$00,$01,$01,$03,$03
LFFD3: .byte $80,$80,$00,$00,$01,$01,$03,$15,$10,$20,$00,$10,$10,$20,$15,$25
       .byte $15,$15,$15
;LFFE6
       .byte $00    ; BG color of a few lines on top of game screen

    IF COMPILE_VERSION > NTSC
    .byte $D2   ; BG color of 2nd stage (Manuel: I'd say 1st stage)
    .byte $50   ; BG color of 3rd stage
    .byte $90   ; BG color of intro screen
    ELSE
    .byte $72   ; BG color of 2nd stage (Manuel: I'd say 1st stage)
    .byte $C2   ; BG color of 3rd stage
    .byte $A0   ; BG color of intro screen
    ENDIF

       .byte $00,$02,$02,$04

    IF BUGFIX = YES
    .word Entry2-1    ; Tweak vector to our bugfix entry
    ELSE
    .word Entry1-1    ; Original vector for stage 1
    ENDIF

       .word $F1B3  ; ??? scene entry
       .word $F10C  ; Original vector for the intro
       .byte $00,$00,$00,$00,$00,$00,$00,$F0,$00,$F0,$00,$F0