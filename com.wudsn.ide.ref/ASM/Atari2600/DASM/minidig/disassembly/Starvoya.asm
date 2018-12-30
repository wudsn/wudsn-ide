; ***********************************************
; * Star Voyager (aka Stella Wars) by Bob Smith *
; ***********************************************

    include vcs.h

       ORG $1000

START:
       SEI            ;2
       CLD            ;2
       LDX    #$FF    ;2
       TXS            ;2
       INX            ;2
       TXA            ;2
L1007: STA    VSYNC,X ;4
       INX            ;2
       BNE    L1007   ;2
       LDA    #$8D    ;2
       STA    $B1     ;3
       INC    $C1     ;5
       LDY    #$06    ;2
L1014: LDX    L1FF4,Y ;4
       STX    $97,Y   ;4
       DEY            ;2
       BPL    L1014   ;2
       STY    $80     ;3
       STY    $E7     ;3
L1020: LDY    #$FF    ;2
       STA    WSYNC   ;3
       STY    VSYNC   ;3
       STA    WSYNC   ;3
       LDA    SWCHB   ;4
       AND    #$02    ;2
       BEQ    L1036   ;2
       ROL    $81     ;5
       SEC            ;2
       ROR    $81     ;5
       BNE    L104B   ;2
L1036: STA    $9D     ;3
       BIT    $81     ;3
       BPL    L104B   ;2
       LDA    $81     ;3
       EOR    #$01    ;2
       AND    #$7F    ;2
       STA    $81     ;3
       TAX            ;2
       INX            ;2
       STX    $9E     ;3
       INX            ;2
       STX    $9B     ;3
L104B: STA    WSYNC   ;3
       LDX    #$00    ;2
       STX    ENABL   ;3
       STX    $F2     ;3
       BIT    INPT4   ;3
       BPL    L105A   ;2
       SEC            ;2
       ROR    $AC     ;5
L105A: LDA    $A6     ;3
       LSR            ;2
       BCS    L1068   ;2
       LDA    SWCHB   ;4
       ASL            ;2
       ASL            ;2
       TXA            ;2
       ROL            ;2
       STA    $C8     ;3
L1068: LDA    #$00    ;2
       STA    WSYNC   ;3
       STA    VSYNC   ;3
       LDA    #$2C    ;2
       STA    TIM64T  ;4
       JSR    L1732   ;6
       LDX    #$00    ;2
       LDA    #$05    ;2
       STA    CTRLPF  ;3
       INC    $9A     ;5
       BNE    L1098   ;2
       LDA    $9B     ;3
       BEQ    L1088   ;2
L1084: INC    $9B     ;5
       BEQ    L1084   ;2
L1088: DEX            ;2
       STX    $97     ;3
       INX            ;2
       STX    $8D     ;3
       INC    $AB     ;5
       BNE    L1098   ;2
       LDA    #$F3    ;2
       STA    $80     ;3
       INC    $9B     ;5
L1098: LDA    $93     ;3
       CMP    #$10    ;2
       BCC    L10A2   ;2
       LDA    $8A     ;3
       STA    COLUP0  ;3
L10A2: LDA    $A6     ;3
       ROR            ;2
       BCC    L10AD   ;2
       LDA    $8B     ;3
       EOR    $9A     ;3
       STA    COLUP1  ;3
L10AD: STA    WSYNC   ;3
L10AF: BIT    $0285   ;4
       BPL    L10AF   ;2
       STA    CXCLR   ;3
       STA    WSYNC   ;3

; Stop vertical blank

       STX    VBLANK  ; X->0
       DEX            ; X->FF
       STX    PF2     ;
       STA    WSYNC   ;
       STX    PF0     ;
       STX    PF1     ;

; Position first star:
       LDA    $F3     ;
       STA    HMBL    ; Fine Movement

       LDY    $E8     ;
       NOP            ;
L10CA: DEY            ;
       BPL    L10CA   ;
       STA    RESBL   ; 

       STA    WSYNC   ;
       STA    HMOVE   ;


       STA    WSYNC   ;3
       LDY    $83     ;3
       BEQ    L10E1   ;2
       DEY            ;2
       LDA    ($95),Y ;5
       STA    GRP1    ;3
       JMP    L10E4   ;3
L10E1: JSR    L1AC5   ; Waste 12 cycles
L10E4: LDY    $84     ;3
       BEQ    L10F0   ;2
       DEY            ;2
       LDA    ($93),Y ;5
       STA    GRP0    ;3
       JMP    L10F3   ;3
L10F0: JSR    L1AC5   ; Waste 12 cycles
L10F3: PHA            ;
       PLA            ; Waste 7 cycles
       INX            ; X->0
       STA    RESM1   ;3
       LDY    $83     ;3
       NOP            ;2
       STX    $8E     ;3
       LDA    $DD     ;3
       STA    $90     ;3
       TXA            ; A->0
       STA    HMCLR   ;3
       STA    PF2     ;3
       STA    PF1     ;3
       BEQ    L1117   ; Jump always

; Reposition Star / Waste a scannline
L110A: LDA    #$00    ;2
       STA    $8F     ;3
       LDY    $91     ;3
L1110: DEY            ;2
       BPL    L1110   ;2
       STA    RESBL   ;3

Nextline 
       STA    WSYNC   ;3
L1117: STX    HMOVE   ;3
       LDY    $83     ;3
       CPX    $A8     ;3
       BCC    L1126   ;2
       CPX    $AA     ;3
       BCS    L1126   ;2
       LDA    ($95),Y ;5
       INY            ;2
L1126: STA    GRP1    ;3
       STY    $83     ;3

; Do the crosshair
       LDA    #$00    ; 
       CPX    #$28    ; Reached line $28?
       BNE    L1132   ; N: Skip
       LDA    #$40    ; Y: Draw Crosshair
L1132: STA    PF2     ;

       LDA    #$00    ;2
       CPX    $A7     ;3
       BCC    L1144   ;2
       CPX    $A9     ;3
       BCS    L1144   ;2
       LDY    $84     ;3
       LDA    ($93),Y ;5
       INC    $84     ;5
L1144: INX            ;
       LDY    $92     ;
       STY    HMBL    ;
       STA    WSYNC   ;3
       STA    GRP0    ;3
       BIT    $8F     ;3
       BMI    L110A   ;2
       LDA    #$00    ;2
       STA    HMBL    ;3
       CPX    $90     ;3
       BNE    L115B   ;2
       LDA    #$02    ;2
L115B: STA    ENABL   ;3
       DEX            ;2
       CPX    $90     ;3
       BNE    L118C   ;2
       DEC    $8F     ;5
       INC    $8E     ;5
       LDY    $8E     ;3
       LDA.wy $00DD,Y ;4
       STA    $90     ;3
       LDA.wy $00E8,Y ;4
       STA    $91     ;3
       LDA.wy $00F3,Y ;4
       STA    $92     ;3
       INX            ;2
L1178: LDA    #$00    ;2
       CPX    #$4F    ;2
       BCC    Nextline 
       STA    WSYNC   ;3
       BEQ    L11AE   ;2
L1182: LDA    $98     ;3
       STA    HMM1    ;3
       LDA    #$02    ;2
       STA    ENAM1   ;3
       BNE    L1178   ;2
L118C: LDA    $90     ;3
       BNE    L1199   ;2
       INX            ;2
       STX    $90     ;3
       CPX    $97     ;3
       BCS    L1182   ;2
       BNE    L1178   ;2
L1199: INX            ;2
       CPX    $97     ;3
       BCS    L1182   ;2
       INX            ;2
       CPX    $90     ;3
       BNE    L11AA   ;2
       LDY    $8E     ;3
       LDA.wy $00D3,Y ;4
       STA    VDELBL  ;3
L11AA: DEX            ;2
       JMP    L1178   ;3
L11AE: STA    GRP0    ;3
       STA    GRP1    ;3
       LDA    #$FF    ;2
       STA    PF2     ;3
       STA    PF1     ;3
       BIT    $97     ;3
       BMI    L11C6   ;2
       LDA    $9A     ;3
       CMP    #$F4    ;2
       BCS    L11C6   ;2
       LDA    #$42    ;2
       STA    COLUPF  ;3
L11C6: LDA    $88     ;3
       STA    COLUP0  ;3
       STA    COLUP1  ;3
       LDA    $8C     ;3
       STA    COLUBK  ;3
       LDA    #$41    ;2
       STA    TIM8T   ;4
       LDA    $9E     ;3
       AND    #$F0    ;2
       LSR            ;2
       BNE    L11DE   ;2

       LDA    #$50    ;2
L11DE: STA    $F3     ;3

       STA    WSYNC   ;3
       LDA    #$1D    ;2
       STA    $F4     ;3
       STA    $F6     ;3
       STA    $F8     ;3
       STA    $FA     ;3
       LDA    #$F0    ;2
       STA    HMP0    ;3
       LDX    #$00    ;2
       STX    ENAM1   ;3
       LDA    $9E     ;3
       AND    #$0F    ;2
       ASL            ;2
       STA    RESP0   ;3
       STA    RESP1   ;3
       ASL            ;2
       ASL            ;2
       STA    $F5,X   ;4
       STA    RESBL   ;3
       LDA    $9B     ;3
       BNE    L1219   ;2
       LDA    $82     ;3
       AND    #$F0    ;2
       LSR            ;2
       STA    $F7     ;3
       LDA    $82     ;3
       AND    #$0F    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       STA    $F9     ;3
       BCC    L1232   ;2
L1219: LDA    $9C     ;3
       ADC    #$10    ;2
       BCC    L1221   ;2
       LDA    #$FF    ;2
L1221: LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       AND    #$0E    ;2
       TAX            ;2
       LDA    L1DD8,X ;4
       STA    $F7     ;3
       LDA    L1DD9,X ;4
       STA    $F9     ;3
L1232: LDA    $BE     ;3
       BNE    L124C   ;2
       LDA    $B2     ;3
       CMP    #$06    ;2
       BCC    L1240   ;2
       CMP    #$8E    ;2
       BCC    L1244   ;2
L1240: LDA    #$F0    ;2
       BNE    L1252   ;2
L1244: CMP    #$82    ;2
       BCS    L1250   ;2
       LDA    #$00    ;2
       BEQ    L1252   ;2
L124C: AND    #$F0    ;2
       BNE    L1252   ;2
L1250: LDA    #$10    ;2
L1252: EOR    #$FF    ;2
       CLC            ;2
       ADC    #$10    ;2
       AND    #$F0    ;2
       CMP    #$90    ;2
       BNE    L125F   ;2
       LDA    #$A0    ;2
L125F: CMP    #$80    ;2
       BNE    L1265   ;2
       LDA    #$70    ;2
L1265: STA    HMBL    ;3
       LDA    $C2     ;3
       BNE    L1281   ;2
       LDA    $B6     ;3
       CMP    #$C0    ;2
       BCC    L1275   ;2
       LDA    #$F0    ;2
       BNE    L1287   ;2
L1275: CMP    #$83    ;2
       BCC    L127D   ;2
       LDA    #$20    ;2
       BNE    L1287   ;2
L127D: LDA    #$00    ;2
       BEQ    L1287   ;2
L1281: CMP    #$20    ;2
       BCS    L1287   ;2
       LDA    #$20    ;2
L1287: EOR    #$80    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       EOR    #$07    ;2
       TAX            ;2
       CPX    #$07    ;2
       BNE    L1296   ;2
       DEX            ;2
L1296: LDA    $9A     ;3
       AND    #$10    ;2
       BEQ    L129E   ;2
       LDX    #$FE    ;2
L129E: STX    $C7     ;3
       INC    $C7     ;5
       LDA    $C1     ;3
       BNE    L12BC   ;2
       LDA    $B5     ;3
       CMP    #$C0    ;2
       BCC    L12B0   ;2
       LDA    #$F0    ;2
       BNE    L12C2   ;2
L12B0: CMP    #$83    ;2
       BCC    L12B8   ;2
       LDA    #$20    ;2
       BNE    L12C2   ;2
L12B8: LDA    #$00    ;2
       BEQ    L12C2   ;2
L12BC: CMP    #$20    ;2
       BCS    L12C2   ;2
       LDA    #$20    ;2
L12C2: EOR    #$80    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       EOR    #$07    ;2
       CMP    #$07    ;2
       BNE    L12D1   ;2
       LDA    #$06    ;2
L12D1: TAX            ;2
       LDA    $A6     ;3
       LSR            ;2
       BCC    L12D9   ;2
       LDX    #$FF    ;2
L12D9: STX    $C6     ;3
       LDA    $BD     ;3
       BNE    L12F5   ;2
       LDA    $B1     ;3
       CMP    #$06    ;2
       BCC    L12E9   ;2
       CMP    #$8E    ;2
       BCC    L12ED   ;2
L12E9: LDA    #$F0    ;2
       BNE    L12FB   ;2
L12ED: CMP    #$82    ;2
       BCS    L12F9   ;2
       LDA    #$00    ;2
       BEQ    L12FB   ;2
L12F5: AND    #$F0    ;2
       BNE    L12FB   ;2
L12F9: LDA    #$10    ;2
L12FB: EOR    #$80    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       TAX            ;2
       LDA    L1CE8,X ;4
       LDY    #$00    ;2
       CPX    #$08    ;2
       BCS    L1311   ;2
       STA    $83     ;3
       STY    $84     ;3
       BCC    L1315   ;2
L1311: STA    $84     ;3
       STY    $83     ;3
L1315: LDA    #$80    ;2
       LDY    #$01    ;2
       LDX    #$08    ;2
L131B: STA    $DD,X   ;4
       STY    $E8,X   ;4
       DEX            ;2
       BPL    L131B   ;2
       INX            ;2
       STX    $E1     ;3
       STX    $EC     ;3
       DEX            ;2
       STX    $E5     ;3
       LDA    #$7F    ;2
       STA    $F0     ;3
       STA    $E8     ;3
       STX    $DD     ;3
       LDX    $C6     ;3
       BMI    L1343   ;2
       INX            ;2
       LDA    $83     ;3
       ORA    $DD,X   ;4
       STA    $DD,X   ;4
       LDA    $84     ;3
       ORA    $E8,X   ;4
       STA    $E8,X   ;4
L1343: BIT    $0285   ;4
       BPL    L1343   ;2
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDX    #$1F    ;2
       TXS            ;2
       LDX    #$01    ;2
       STX    CTRLPF  ;3
       DEX            ;2
       LDY    #$06    ;2
       LDA    $9D     ;3
       LSR            ;2
       BCC    L135E   ;2
       INX            ;2
       LDY    #$03    ;2
L135E: STY    NUSIZ0  ;3
       STY    NUSIZ1  ;3
       STX    VDELP0  ;3
       STX    VDEL01  ;3
       STX    VDELBL  ;3
       BCS    L1375   ;2
       LDY    #$08    ;2
       LDA    ($F7),Y ;5
       TAX            ;2
       LDA    #$3F    ;2
       STA    PF2     ;3
       BNE    L13BC   ;2
L1375: LDA    #$80    ;2
       STA    HMP0    ;3
       STA    HMP1    ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       LDA    #$0B    ;2
       STA    $84     ;3
L1387: LDY    $84     ;3
       LDA    L1C7D,Y ;4
       STA    GRP0    ;3
       STA    WSYNC   ;3
       LDA    L1C86,Y ;4
       STA.w  $001C   ;4
       LDA    L1C92,Y ;4
       NOP            ;2
       STA    GRP0    ;3
       LDA    L1C9E,Y ;4
       STA    $85     ;3
       LDA    L1CAA,Y ;4
       NOP            ;2
       TAX            ;2
       LDA    L1CB6,Y ;4
       TAY            ;2
       LDA    $85     ;3
       STA    GRP1    ;3
       STX    GRP0    ;3
       STY    GRP1    ;3
       STY    GRP0    ;3
       DEC    $84     ;5
       BPL    L1387   ;2
       LDY    #$07    ;2
       BNE    L140A   ;2
L13BC: STA    WSYNC   ;3
       NOP            ;2
       CPY    $C7     ;3
       PHP            ;3
       PLA            ;4
       LDA    ($F3),Y ;5
       STA    GRP0    ;3
       LDA    ($F5),Y ;5
       STA    GRP1    ;3
       LDA.wy $00DD,Y ;4
       NOP            ;2
       NOP            ;2
       STA    GRP0    ;3
       LDA.wy $00E8,Y ;4
       STA    GRP1    ;3
       LDA    ($F9),Y ;5
       STX    GRP0    ;3
       STA    GRP1    ;3
       LDA    ($F7),Y ;5
       TAX            ;2
       STA    WSYNC   ;3
       NOP            ;2
       CPY    $C7     ;3
       PHP            ;3
       PLA            ;4
       LDA    ($F3),Y ;5
       STA    GRP0    ;3
       LDA    ($F5),Y ;5
       STA    GRP1    ;3
       LDA.wy $00DD,Y ;4
       NOP            ;2
       NOP            ;2
       STA    GRP0    ;3
       LDA.wy $00E8,Y ;4
       STA    GRP1    ;3
       LDA    ($F9),Y ;5
       STX    GRP0    ;3
       STA    GRP1    ;3
       DEY            ;2
       LDA    ($F7),Y ;5
       TAX            ;2
       TYA            ;2
       BPL    L13BC   ;2
       LDY    #$03    ;2
L140A: LDX    #$FF    ;2
       STX    PF2     ;3
       TXS            ;2
       INX            ;2
       STX    GRP0    ;3
       STX    GRP1    ;3
L1414: STA    WSYNC   ;3
       DEY            ;2
       BPL    L1414   ;2

; Start vertical blank

       LDA    #$02    ;2
       STA    VBLANK  ;3
       LDA    #$20    ;2
       STA    TIM64T  ;4
       BIT    $9F     ;3
       BMI    L145D   ;2
       BVC    L145D   ;2
       BIT    $A0     ;3
       BMI    L145D   ;2
       BVC    L145D   ;2
       TXA            ;2
       ORA    $BF     ;3
       ORA    $BB     ;3
       ORA    $BC     ;3
       ORA    $C0     ;3
       BNE    L145D   ;2
       LDA    $AF     ;3
       SEC            ;2
       SBC    $B0     ;3
       CMP    #$F9    ;2
       BCS    L1446   ;2
       CMP    #$07    ;2
       BCS    L145D   ;2
L1446: LDA    $B3     ;3
       SEC            ;2
       SBC    $B4     ;3
       CMP    #$F9    ;2
       BCS    L1453   ;2
       CMP    #$07    ;2
       BCS    L145D   ;2
L1453: LDA    #$C0    ;2
       STA    $9F     ;3
       STA    $A0     ;3
       LDA    #$BA    ;2
       STA    $A3     ;3
L145D: LDY    #$FF    ;2
       LDA    #$1C    ;2
       STA    $87     ;3
       LDX    #$D6    ;2
       LDA    SWCHB   ;4
       AND    #$08    ;2
       BNE    L1470   ;2
       LDX    #$DF    ;2
       LDY    #$0F    ;2
L1470: STX    $86     ;3
       STY    $83     ;3
       LDX    $C5     ;3
       LDA    L1EE0,X ;4
       LDY    #$08    ;2
       BNE    L147F   ;2
L147D: LDA    ($86),Y ;5
L147F: AND    $80     ;3
       AND    $83     ;3
       CPY    #$06    ;2
       BCS    L148C   ;2
       STA.wy $0087,Y ;5
       BCC    L148F   ;2
L148C: STA.wy $0000,Y ;5
L148F: DEY            ;2
       BNE    L147D   ;2
       LDA    $A2     ;3
       ASL            ;2
       ASL            ;2
       ASL            ;2
       TAY            ;2
       LDA    $9A     ;3
       AND    #$03    ;2
       BEQ    L14A4   ;2
       BIT    $8D     ;3
       BPL    L14A4   ;2
       LDY    #$42    ;2
L14A4: TYA            ;2
       AND    $80     ;3
       AND    $83     ;3
       STA    COLUBK  ;3
       LDX    #$00    ;2
       LDA    $A3     ;3
       BNE    L14BD   ;2
       LDA    $A5     ;3
       BEQ    L14BD   ;2
       STA    $A4     ;3
       LDA    #$04    ;2
       STA    AUDC1   ;3
       STX    $A5     ;3
L14BD: INX            ;2
L14BE: LDY    $A3,X   ;4
       BNE    L14D4   ;2
       LDA    $9B     ;3
       BNE    L1515   ;2
       LDA    #$08    ;2
       STA    AUDC0,X ;4
       LDA    #$01    ;2
       STA    AUDV0,X ;4
       LDA    #$0B    ;2
       STA    AUDF0,X ;4
       BNE    L151B   ;2
L14D4: CPY    #$FF    ;2
       BEQ    L1519   ;2
       CPY    #$BB    ;2
       BCC    L14F4   ;2
       LDA    $9A     ;3
       AND    #$07    ;2
       BNE    L1519   ;2
       LDA    #$0F    ;2
       STA    AUDV1   ;3
       LDA    L1F00,Y ;4
       BMI    L1515   ;2
       BNE    L14EF   ;2
       STA    AUDV1   ;3
L14EF: STA    AUDF1   ;3
       DEY            ;2
       BNE    L1519   ;2
L14F4: CPY    #$6B    ;2
       BCC    L14FF   ;2
       LDA    $9B     ;3
       ROL            ;2
       AND    $9A     ;3
       BNE    L1519   ;2
L14FF: LDA    L1F00,Y ;4
       BMI    L1515   ;2
       STA    AUDF0,X ;4
       DEY            ;2
       LDA    L1F00,Y ;4
       STA    AUDV0,X ;4
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       STA    AUDC0,X ;4
       DEY            ;2
       BNE    L1519   ;2
L1515: LDY    #$00    ;2
       STY    AUDV0,X ;4
L1519: STY    $A3,X   ;4
L151B: DEX            ;2
       BPL    L14BE   ;2
       BIT    CXM1P   ;3
       BVC    L1531   ;2
       BIT    $A1     ;3
       BMI    L1531   ;2
       JSR    L1EE7   ;6
       LDA    #$C0    ;2
       STA    $A1     ;3
       STA    $97     ;3
       BNE    L154C   ;2
L1531: BIT    CXM1P   ;3
       BPL    L1550   ;2
       LDX    #$01    ;2
       BIT    $9F     ;3
       BVC    L1546   ;2
       DEX            ;2
       BIT    $A0     ;3
       BVC    L1546   ;2
       LDA    $9A     ;3
       ROR            ;2
       BCC    L1546   ;2
       INX            ;2
L1546: LDA    #$C0    ;2
       ORA    $9F,X   ;4
       STA    $9F,X   ;4
L154C: LDA    #$BA    ;2
       STA    $A3     ;3
L1550: BIT    $9F     ;3
       BVC    L157C   ;2
       BMI    L157C   ;2
       LDY    #$FF    ;2
       STY    $84     ;3
       LDY    #$FD    ;2
       BIT    $A6     ;3
       BMI    L1562   ;2
       LDY    #$03    ;2
L1562: STY    $83     ;3
       LDX    #$00    ;2
       JSR    L1654   ;6
       STX    $BF     ;3
       STX    $BB     ;3
       LDX    $B7     ;3
       INX            ;2
       STX    $B7     ;3
       CPX    #$1B    ;2
       BNE    L157C   ;2
       LDA    #$C3    ;2
       STA    $9F     ;3
       STA    $B3     ;3
L157C: BIT    $A0     ;3
       BVC    L158B   ;2
       BMI    L158B   ;2
       DEC    $B8     ;5
       BNE    L158B   ;2
       LDX    #$01    ;2
       JSR    L1C1E   ;6
L158B: LDA    SWCHA   ;4
       JSR    L1DE8   ;6
       STX    $83     ;3
       STY    $84     ;3
       TXA            ;2
       ORA    $84     ;3
       BEQ    L159C   ;2
       LSR    $AB     ;5
L159C: LDA    $9A     ;3
       LSR            ;2
       BCC    L15EA   ;2
       LDA    $9B     ;3
       CMP    #$01    ;2
       BEQ    L160B   ;2
       LDX    #$13    ;2
L15A9: LDA    $C9,X   ;4
       BEQ    L15E5   ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       TAY            ;2
       LDA    L1CC2,Y ;4
       BNE    L15BE   ;2
       ORA    $9A     ;3
       AND    #$06    ;2
       BNE    L15E5   ;2
       EOR    #$01    ;2
L15BE: CLC            ;2
       ADC    $C8     ;3
       CPY    #$0A    ;2
       BCS    L15C9   ;2
       EOR    #$FF    ;2
       ADC    #$01    ;2
L15C9: CLC            ;2
       ADC    $C9,X   ;4
       LDY    #$01    ;2
       CPX    #$0A    ;2
       BCS    L15D3   ;2
       DEY            ;2
L15D3: CLC            ;2
       ADC.wy $0083,Y ;4
       CMP    #$97    ;2
       BCC    L15E3   ;2
       LDA    #$00    ;2
       CPX    #$0A    ;2
       BCS    L15E3   ;2
       STA    $D3,X   ;4
L15E3: STA    $C9,X   ;4
L15E5: DEX            ;2
       BPL    L15A9   ;2
       BMI    L160B   ;2
L15EA: LDX    #$03    ;2
L15EC: LDA    $9F,X   ;4
       AND    #$40    ;2
       BEQ    L15F5   ;2
       JSR    L1654   ;6
L15F5: DEX            ;2
       BPL    L15EC   ;2
       BIT    $A1     ;3
       BVC    L160B   ;2
       BMI    L160B   ;2
       LDX    $AD     ;3
       STX    $83     ;3
       LDX    $AE     ;3
       STX    $84     ;3
       LDX    #$02    ;2
       JSR    L1654   ;6
L160B: LDA    CXPPMM  ;3
       BPL    L1631   ;2
       BIT    $A0     ;3
       BVC    L161C   ;2
       BIT    $9F     ;3
       BVC    L1631   ;2
       LDA    $9A     ;3
       LSR            ;2
       BCC    L1631   ;2
L161C: BIT    $A1     ;3
       BMI    L1631   ;2
       LDA    #$C0    ;2
       STA    $A1     ;3
       STA    $9F     ;3
       LDA    #$00    ;2
       STA    $A6     ;3
       LDA    #$BA    ;2
       STA    $A3     ;3
       JSR    L1EE7   ;6
L1631: LDA    $81     ;3
       LSR            ;2
       BCC    L164C   ;2
       LDA    $9A     ;3
       AND    #$0F    ;2
       BEQ    L164C   ;2
       LDX    #$01    ;2
L163E: LDY    $AD,X   ;4
       BEQ    L1649   ;2
       BMI    L1646   ;2
       DEY            ;2
       DEY            ;2
L1646: INY            ;2
       STY    $AD,X   ;4
L1649: DEX            ;2
       BPL    L163E   ;2
L164C: BIT    $0285   ;4
       BPL    L164C   ;2
       JMP    L1020   ;3
L1654: LDA    $BB,X   ;4
       BNE    L168F   ;2
       LDA    $AF,X   ;4
       CMP    #$8E    ;2
       PHP            ;3
       CLC            ;2
       ADC    $83     ;3
       CMP    #$F0    ;2
       BCC    L166A   ;2
       SBC    #$60    ;2
       PLP            ;4
       JMP    L168A   ;3
L166A: CMP    #$A0    ;2
       BCC    L1675   ;2
       CLC            ;2
       ADC    #$60    ;2
       PLP            ;4
       JMP    L168A   ;3
L1675: PLP            ;4
       BCS    L1680   ;2
       CMP    #$8E    ;2
       BCC    L168A   ;2
       LDY    #$01    ;2
       BNE    L1686   ;2
L1680: CMP    #$8E    ;2
       BCS    L168A   ;2
       LDY    #$FF    ;2
L1686: STY    $BB,X   ;4
       LDA    #$8E    ;2
L168A: STA    $AF,X   ;4
       JMP    L16B4   ;3
L168F: LDA    $BB,X   ;4
       PHP            ;3
       CLC            ;2
       ADC    $83     ;3
       BVC    L169D   ;2
       PLP            ;4
       LDA    $BB,X   ;4
       JMP    L16B2   ;3
L169D: PLP            ;4
       BMI    L16A9   ;2
       TAY            ;2
       BEQ    L16A5   ;2
       BPL    L16B2   ;2
L16A5: LDY    #$8D    ;2
       BNE    L16AE   ;2
L16A9: TAY            ;2
       BMI    L16B2   ;2
       LDY    #$8E    ;2
L16AE: STY    $AF,X   ;4
       LDA    #$00    ;2
L16B2: STA    $BB,X   ;4
L16B4: LDA    $BF,X   ;4
       BNE    L16DE   ;2
       LDA    $B3,X   ;4
       CLC            ;2
       ADC    $84     ;3
       CMP    #$B8    ;2
       PHP            ;3
       CMP    #$A0    ;2
       BCS    L16C8   ;2
       PLP            ;4
       JMP    L16D9   ;3
L16C8: PLP            ;4
       BCS    L16CF   ;2
       LDY    #$01    ;2
       BNE    L16D5   ;2
L16CF: CMP    #$C0    ;2
       BCS    L16D9   ;2
       LDY    #$FF    ;2
L16D5: STY    $BF,X   ;4
       LDA    #$C0    ;2
L16D9: STA    $B3,X   ;4
       JMP    L1702   ;3
L16DE: LDA    $BF,X   ;4
       PHP            ;3
       CLC            ;2
       ADC    $84     ;3
       BVC    L16EB   ;2
       PLP            ;4
       LDA    $BF,X   ;4
       BNE    L1700   ;2
L16EB: PLP            ;4
       BMI    L16F7   ;2
       TAY            ;2
       BEQ    L16F3   ;2
       BPL    L1700   ;2
L16F3: LDY    #$9F    ;2
       BNE    L16FC   ;2
L16F7: TAY            ;2
       BMI    L1700   ;2
       LDY    #$C0    ;2
L16FC: STY    $B3,X   ;4
       LDA    #$00    ;2
L1700: STA    $BF,X   ;4
L1702: RTS            ;6

L1703: LDA    #$C0    ;2
       STA    $B3     ;3
       STA    $B4     ;3
       STA    $B5     ;3
       STA    $BA     ;3
       LDX    #$8E    ;2
       LDY    #$C0    ;2
       BIT    SWCHB   ;4
       BVS    L171A   ;2
       LDX    #$3B    ;2
       LDY    #$3B    ;2
L171A: STX    $B2     ;3
       STY    $B6     ;3
       JSR    L1BB8   ;6
       BIT    SWCHB   ;4
       BVS    L1728   ;2
       LDA    #$00    ;2
L1728: STA    $C2     ;3
       ASL            ;2
       STA    $BE     ;3
       LDA    #$40    ;2
       STA    $A2     ;3
       RTS            ;6

L1732: LDA    $9A     ;3
       LSR            ;2
       BCS    L173A   ;2
       JMP    L1994   ;3
L173A: LDA    $9B     ;3
       CMP    #$02    ;2
       BCC    L1744   ;2
       BIT    INPT4   ;3
       BPL    L174A   ;2
L1744: LDA    SWCHB   ;4
       LSR            ;2
       BCS    L1760   ;2
L174A: LDX    #$99    ;2
       STX    $82     ;3
       LDA    #$00    ;2
       LDX    #$2B    ;2
L1752: STA    $9A,X   ;4
       DEX            ;2
       BNE    L1752   ;2
       DEX            ;2
       STX    $80     ;3
       JSR    L1703   ;6
       JMP    L1A40   ;3
L1760: LDA    $98     ;3
       EOR    #$F0    ;2
       CLC            ;2
       ADC    #$10    ;2
       STA    $98     ;3
       BIT    SWCHB   ;4
       BVS    L1777   ;2
       LDA    $9A     ;3
       AND    #$02    ;2
       BEQ    L1777   ;2
       JMP    L1844   ;3
L1777: LDA    $A6     ;3
       LSR            ;2
       BCS    L177F   ;2
       JMP    L181C   ;3
L177F: LDX    $BA     ;3
       DEX            ;2
       BNE    L17E5   ;2
       LDA    $A2     ;3
       AND    #$0F    ;2
       CMP    #$0A    ;2
       BCS    L17E9   ;2
       ADC    #$03    ;2
       STA    $83     ;3
       STA    AUDV0   ;3
       LDA    #$18    ;2
       SBC    $83     ;3
       STA    AUDF0   ;3
       LDA    #$FF    ;2
       STA    $A3     ;3
       LDY    $C5     ;3
       LDA    $C2     ;3
       ORA    $BE     ;3
       BNE    L180A   ;2
       LDA    $B2     ;3
       CMP    #$1F    ;2
       BCC    L180A   ;2
       CMP    #$57    ;2
       BCS    L180A   ;2
       LDX    $B6     ;3
       CPX    #$0B    ;2
       BCC    L180A   ;2
       CPX    #$6B    ;2
       BCS    L180A   ;2
       CMP    #$33    ;2
       BCC    L17CA   ;2
       CMP    #$43    ;2
       BCS    L17CA   ;2
       CPX    #$2B    ;2
       BCC    L17CA   ;2
       CPX    #$4B    ;2
       BCS    L17CA   ;2
       BCC    L17CF   ;2
L17CA: JSR    L1C61   ;6
       BNE    L180A   ;2
L17CF: LDX    #$08    ;2
       STX    AUDC0   ;3
       LDX    #$07    ;2
       INC    $A2     ;5
       INC    $C8     ;5
       SED            ;2
       LDA    $82     ;3
       ADC    #$11    ;2
       BCC    L17E2   ;2
       LDA    #$99    ;2
L17E2: STA    $82     ;3
       CLD            ;2
L17E5: STX    $BA     ;3
       BNE    L1819   ;2
L17E9: LDY    $C5     ;3
       INY            ;2
       CPY    #$07    ;2
       BNE    L1801   ;2
       LDY    #$01    ;2
       STY    $9A     ;3
       INC    $9B     ;5
       LDA    #$04    ;2
       STA    AUDC1   ;3
       LDA    #$F3    ;2
       STA    $A4     ;3
       DEY            ;2
       BEQ    L180A   ;2
L1801: LDA    #$0A    ;2
       CLC            ;2
       ADC    $9C     ;3
       BCS    L180A   ;2
       STA    $9C     ;3
L180A: STY    $C5     ;3
       JSR    L1703   ;6
       LDA    #$00    ;2
       STA    $A1     ;3
       STA    $C8     ;3
       STA    $A6     ;3
       STA    $A3     ;3
L1819: JMP    L1991   ;3
L181C: BIT    $A1     ;3
       BVC    L1844   ;2
       BMI    L1844   ;2
       LDX    $B9     ;3
       BEQ    L1844   ;2
       DEX            ;2
       STX    $B9     ;3
       CPX    #$18    ;2
       BCS    L1833   ;2
       LDA    $A6     ;3
       ORA    #$20    ;2
       STA    $A6     ;3
L1833: CPX    #$00    ;2
       BNE    L1844   ;2
       LDX    #$02    ;2
       JSR    L1C1E   ;6
       LDA    #$00    ;2
       STA    $A6     ;3
       STA    $A9     ;3
       STA    $AA     ;3
L1844: LDA    $81     ;3
       LSR            ;2
       BCC    L1875   ;2
       LDA    SWCHA   ;4
       ASL            ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       JSR    L1DE8   ;6
       STX    $85     ;3
       LDX    #$00    ;2
       JSR    L1C51   ;6
       DEY            ;2
       TYA            ;2
       EOR    #$FF    ;2
       STA    $85     ;3
       INX            ;2
       JSR    L1C51   ;6
       LDA    $A6     ;3
       LSR            ;2
       BCS    L1872   ;2
       BIT    INPT5   ;3
       BMI    L1872   ;2
       LDA    #$00    ;2
       JMP    L18DD   ;3
L1872: JMP    L18FA   ;3
L1875: LDY    #$01    ;2
       LDX    #$00    ;2
       LDA    $9A     ;3
       AND    #$06    ;2
       BNE    L18D2   ;2
       JSR    L1BB8   ;6
       AND    #$07    ;2
       PHP            ;3
       LDA    $A6     ;3
       PLP            ;4
       BNE    L188C   ;2
       EOR    #$40    ;2
L188C: STA    $A6     ;3
       AND    #$40    ;2
       BEQ    L18A9   ;2
       LDA    $BD     ;3
       BEQ    L189A   ;2
       BMI    L18A6   ;2
       BPL    L18A4   ;2
L189A: LDA    $B1     ;3
       CMP    #$3B    ;2
       BCC    L18A6   ;2
       CMP    #$8E    ;2
       BCS    L18A6   ;2
L18A4: LDY    #$FF    ;2
L18A6: JMP    L18BE   ;3
L18A9: LDA    $C1     ;3
       BEQ    L18B1   ;2
       BMI    L18BD   ;2
       BPL    L18BB   ;2
L18B1: LDA    $B5     ;3
       CMP    #$3B    ;2
       BCC    L18BD   ;2
       CMP    #$C1    ;2
       BCS    L18BD   ;2
L18BB: LDY    #$FF    ;2
L18BD: INX            ;2
L18BE: STY    $85     ;3
       LDA    $A6     ;3
       AND    #$20    ;2
       BEQ    L18CF   ;2
       LDA    $85     ;3
       EOR    #$FF    ;2
       CLC            ;2
       ADC    #$01    ;2
       STA    $85     ;3
L18CF: JSR    L1C51   ;6
L18D2: LDA    $9A     ;3
       AND    #$02    ;2
       BNE    L18FA   ;2
       JSR    L1BB8   ;6
       AND    #$79    ;2
L18DD: ORA    $BD     ;3
       ORA    $C1     ;3
       ORA    $A0     ;3
       BNE    L18FA   ;2
       BIT    $A1     ;3
       BMI    L18FA   ;2
       LDA    $B9     ;3
       LSR            ;2
       STA    $B8     ;3
       LDA    $B1     ;3
       STA    $B0     ;3
       LDA    $B5     ;3
       STA    $B4     ;3
       LDA    #$40    ;2
       STA    $A0     ;3
L18FA: LDA    $A6     ;3
       AND    #$01    ;2
       ORA    $9B     ;3
       BNE    L1931   ;2
       BIT    $AC     ;3
       BPL    L1918   ;2
       BIT    INPT4   ;3
       BMI    L1918   ;2
       BIT    SWCHB   ;4
       BMI    L1915   ;2
       JSR    L1BC2   ;6
       JMP    L1918   ;3
L1915: JSR    L1BFF   ;6
L1918: LDA    $81     ;3
       LSR            ;2
       BCS    L192F   ;2
       BIT    INPT5   ;3
       BMI    L192F   ;2
       BIT    SWCHB   ;4
       BMI    L192C   ;2
       JSR    L1BFF   ;6
       JMP    L192F   ;3
L192C: JSR    L1BC2   ;6
L192F: LDA    $A1     ;3
L1931: BNE    L1991   ;2
       STA    $A6     ;3
       LDA    #$40    ;2
       STA    $A1     ;3
       JSR    L1BB8   ;6
       TAY            ;2
       LDA    $81     ;3
       LSR            ;2
       TYA            ;2
       BCC    L1959   ;2
       AND    #$3F    ;2
       ADC    #$31    ;2
       STA    $B5     ;3
       TYA            ;2
       LSR            ;2
       AND    #$3F    ;2
       ADC    #$31    ;2
       STA    $B1     ;3
       LDA    #$00    ;2
       STA    $BD     ;3
       STA    $C1     ;3
       BEQ    L1967   ;2
L1959: STA    $BD     ;3
       ROR            ;2
       ROR            ;2
       STA    $C1     ;3
       LDA    #$C0    ;2
       STA    $B5     ;3
       LDA    #$8E    ;2
       STA    $B1     ;3
L1967: LDY    #$FF    ;2
       STY    $B9     ;3
       INY            ;2
       STY    $AD     ;3
       STY    $AE     ;3
       STY    $C3     ;3
       LDX    $C5     ;3
       INX            ;2
       CPX    $C4     ;3
       BCC    L1983   ;2
       LDA    #$04    ;2
       STA    AUDC1   ;3
       LDA    #$CF    ;2
       INC    $C4     ;5
       BNE    L198F   ;2
L1983: LDA    #$01    ;2
       STA    $A6     ;3
       STY    $C4     ;3
       LDA    #$0C    ;2
       STA    AUDC1   ;3
       LDA    #$E8    ;2
L198F: STA    $A4     ;3
L1991: JMP    L1A40   ;3
L1994: LDX    #$09    ;2
L1996: LDA    $D3,X   ;4
       BEQ    L19A0   ;2
       DEX            ;2
       BPL    L1996   ;2
       JMP    L1A40   ;3
L19A0: STX    $83     ;3
       LDX    #$09    ;2
L19A4: LDA    $D3,X   ;4
       BEQ    L19AC   ;2
       CMP    #$40    ;2
       BCC    L19BD   ;2
L19AC: DEX            ;2
       BPL    L19A4   ;2
       LDX    #$00    ;2
       LDA    $D3,X   ;4
       BNE    L19B7   ;2
       STA    $83     ;3
L19B7: STX    $84     ;3
       LDA    #$38    ;2
       BNE    L1A05   ;2
L19BD: STA    $85     ;3
       CPX    #$09    ;2
       BNE    L19C9   ;2
       STX    $84     ;3
       LDA    #$60    ;2
       BNE    L1A05   ;2
L19C9: INX            ;2
       STX    $84     ;3
       SEC            ;2
       SBC    $D3,X   ;4
       BEQ    L19FC   ;2
       CMP    $85     ;3
       BNE    L19E3   ;2
       STX    $83     ;3
       CMP    #$88    ;2
       BCC    L19DF   ;2
       LDA    #$00    ;2
       BEQ    L19FC   ;2
L19DF: ADC    #$08    ;2
       BNE    L19FC   ;2
L19E3: CMP    #$F0    ;2
       BCC    L19F2   ;2
       LDA    $D3,X   ;4
       CPX    #$09    ;2
       BNE    L19BD   ;2
       LDA    #$00    ;2
       JMP    L1A05   ;3
L19F2: EOR    #$FF    ;2
       ADC    #$01    ;2
       LSR            ;2
       DEX            ;2
       CLC            ;2
       ADC    $D3,X   ;4
       INX            ;2
L19FC: CPX    $83     ;3
       BEQ    L1A05   ;2
       BCC    L1A05   ;2
       DEC    $84     ;5
       DEX            ;2
L1A05: STA    $85     ;3
       CPX    $83     ;3
       BEQ    L1A31   ;2
       BCC    L1A20   ;2
       LDX    $83     ;3
L1A0F: INX            ;2
       LDY    $D3,X   ;4
       LDA    $C9,X   ;4
       DEX            ;2
       STA    $C9,X   ;4
       STY    $D3,X   ;4
       INX            ;2
       CPX    $84     ;3
       BNE    L1A0F   ;2
       BEQ    L1A31   ;2
L1A20: LDX    $83     ;3
L1A22: DEX            ;2
       LDY    $D3,X   ;4
       LDA    $C9,X   ;4
       INX            ;2
       STY    $D3,X   ;4
       STA    $C9,X   ;4
       DEX            ;2
       CPX    $84     ;3
       BNE    L1A22   ;2
L1A31: LDA    $85     ;3
       LDX    $84     ;3
       STA    $D3,X   ;4
       JSR    L1BB8   ;6
       AND    #$1F    ;2
       ADC    #$40    ;2
       STA    $C9,X   ;4
L1A40: LDA    #$1E    ;2
       STA    $94     ;3
       STA    $96     ;3
       LDX    #$00    ;2
       STX    $86     ;3
       LDA    $9A     ;3
       LSR            ;2
       BCS    L1A53   ;2
       BIT    $9F     ;3
       BVS    L1A5D   ;2
L1A53: INX            ;2
       BIT    $A0     ;3
       BVS    L1A5D   ;2
       DEX            ;2
       BIT    $9F     ;3
       BVC    L1A60   ;2
L1A5D: JSR    L1AC6   ;6
L1A60: LDA    $86     ;3
       PHA            ;3
       LDA    $A6     ;3
       LDX    #$00    ;2
       STX    $86     ;3
       LDX    #$02    ;2
       LSR            ;2
       BCC    L1A6F   ;2
       INX            ;2
L1A6F: JSR    L1AC6   ;6
       LDA    $86     ;3
       STA    $83     ;3
       PLA            ;4
       STA    $84     ;3
       LDX    #$09    ;2
       LDY    #$FF    ;2
L1A7D: LDA    $D3,X   ;4
       BNE    L1A85   ;2
       TYA            ;2
       JMP    L1A87   ;3
L1A85: LDY    #$00    ;2
L1A87: LSR            ;2
       CMP    #$26    ;2
       BEQ    L1A90   ;2
       CMP    #$27    ;2
       BNE    L1A91   ;2
L1A90: TYA            ;2
L1A91: STA    $DD,X   ;4
       DEX            ;2
       BPL    L1A7D   ;2
       LDX    #$09    ;2
L1A98: LDA    $C9,X   ;4
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       STA    $86     ;3
       TAY            ;2
       LDA    $C9,X   ;4
       AND    #$0F    ;2
       CLC            ;2
       ADC    $86     ;3
       CMP    #$0F    ;2
       BCC    L1AAF   ;2
       SBC    #$0F    ;2
       INY            ;2
L1AAF: SEC            ;2
       SBC    #$08    ;2
       EOR    #$FF    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       STA    $F3,X   ;4
       CPY    #$0A    ;2
       BNE    L1AC0   ;2
       LDY    #$00    ;2
L1AC0: STY    $E8,X   ;4
       DEX            ;2
       BPL    L1A98   ;2
L1AC5: RTS            ;6

L1AC6: LDA    $B7,X   ;4
       STX    $83     ;3
       LDY    L1D9A,X ;4
       LDX    #$00    ;2
L1ACF: CMP    L1D00,Y ;4
       BCS    L1AD8   ;2
       INY            ;2
       INX            ;2
       BNE    L1ACF   ;2
L1AD8: TXA            ;2
       LDX    $83     ;3
       LDY    $9F,X   ;4
       BPL    L1B1D   ;2
       CPX    #$02    ;2
       BCS    L1AE7   ;2
       INC    $94     ;5
       BNE    L1AE9   ;2
L1AE7: INC    $96     ;5
L1AE9: PHA            ;3
       LDA    $9A     ;3
       AND    #$07    ;2
       BEQ    L1AFC   ;2
       CPX    #$01    ;2
       BNE    L1B0F   ;2
       BIT    $9F     ;3
       BVC    L1B0F   ;2
       CMP    #$01    ;2
       BNE    L1B0F   ;2
L1AFC: INY            ;2
       CPY    #$C4    ;2
       BNE    L1B0F   ;2
       LDA    #$C0    ;2
       STA    $B3,X   ;4
       LDY    #$00    ;2
       STY    $BF,X   ;4
       STY    $BB,X   ;4
       LDA    #$8E    ;2
       STA    $AF,X   ;4
L1B0F: STY    $9F,X   ;4
       PLA            ;4
       CLC            ;2
       ADC    #$02    ;2
       LSR            ;2
       CLC            ;2
       ADC    $9F,X   ;4
       AND    #$3F    ;2
       LDX    #$04    ;2
L1B1D: STA    $84     ;3
       ASL            ;2
       ASL            ;2
       TAY            ;2
       LDA    $84     ;3
       CLC            ;2
       ADC    L1CFA,X ;4
       TAX            ;2
       LDA    $83     ;3
       AND    #$02    ;2
       STA    $85     ;3
       LDA    L1DB7,X ;4
       SEC            ;2
       SBC    L1DB6,X ;4
       STA    $87     ;3
       LDA    L1DB6,X ;4
       LDX    $85     ;3
       STA    $93,X   ;4
       TXA            ;2
       LSR            ;2
       TAX            ;2
       LDA    L1EC0,Y ;4
       STA    NUSIZ0,X;4
       LDX    $83     ;3
       LDA    $B3,X   ;4
       STX    $84     ;3
       LSR    $83     ;5
       LDX    $83     ;3
       STA    VDELP0,X;4
       CMP    #$C0    ;2
       BCC    L1B5A   ;2
       ROR            ;2
       BMI    L1B5B   ;2
L1B5A: LSR            ;2
L1B5B: CLC            ;2
       ADC    L1EC3,Y ;4
       STA    $A7,X   ;4
       CMP    #$C0    ;2
       BCC    L1B72   ;2
       PHA            ;3
       EOR    #$FF    ;2
       CLC            ;2
       ADC    #$01    ;2
       STA    $86     ;3
       LDA    #$00    ;2
       STA    $A7,X   ;4
       PLA            ;4
L1B72: CLC            ;2
       ADC    $87     ;3
       CMP    #$C0    ;2
       BCC    L1B7D   ;2
       LDA    #$00    ;2
       STA    $86     ;3
L1B7D: STA    $A9,X   ;4
       LDX    $84     ;3
       LDA    $AF,X   ;4
       CLC            ;2
       ADC    L1EC2,Y ;4
       CMP    #$A0    ;2
       BCC    L1B8E   ;2
       CLC            ;2
       ADC    #$60    ;2
L1B8E: PHA            ;3
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       STA    $85     ;3
       TAY            ;2
       PLA            ;4
       AND    #$0F    ;2
       CLC            ;2
       ADC    $85     ;3
       CMP    #$0F    ;2
       BCC    L1BA3   ;2
       SBC    #$0F    ;2
       INY            ;2
L1BA3: SEC            ;2
       SBC    #$08    ;2
       STA    WSYNC   ;3
       EOR    #$FF    ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       ASL            ;2
       LDX    $83     ;3
       STA    HMP0,X  ;4
L1BB2: DEY            ;2
       BPL    L1BB2   ;2
       STA    RESP0,X ;4
       RTS            ;6

L1BB8: LDA    $99     ;3
       ASL            ;2
       EOR    $99     ;3
       ASL            ;2
       ASL            ;2
       ROL    $99     ;5
       RTS            ;6

L1BC2: BIT    $9F     ;3
       BVS    L1BFE   ;2
       LDA    $82     ;3
       SED            ;2
       SEC            ;2
       SBC    #$01    ;2
       CLD            ;2
       BCC    L1BFE   ;2
       STA    $82     ;3
       LDA    #$4E    ;2
       STA    $B3     ;3
       LDA    #$40    ;2
       STA    $9F     ;3
       LDA    #$00    ;2
       STA    $B7     ;3
       STA    $BF     ;3
       STA    $BB     ;3
       LDX    #$94    ;2
       LDA    $A6     ;3
       EOR    #$80    ;2
       STA    $A6     ;3
       BPL    L1BED   ;2
       LDX    #$84    ;2
L1BED: STX    $AF     ;3
       LDA    #$8B    ;2
L1BF1: LDX    #$01    ;2
       LDY    $A3,X   ;4
       BEQ    L1BFC   ;2
       DEX            ;2
       LDY    $A3,X   ;4
       BNE    L1BFE   ;2
L1BFC: STA    $A3,X   ;4
L1BFE: RTS            ;6

L1BFF: LDX    #$FF    ;2
       CPX    $97     ;3
       BNE    L1BFE   ;2
       INX            ;2
       STX    $AC     ;3
       SED            ;2
       LDA    $82     ;3
       SBC    #$10    ;2
       CLD            ;2
       BCC    L1BC2   ;2
       STA    $82     ;3
       LDA    #$28    ;2
       STA    $97     ;3
       LDA    #$F0    ;2
       STA    $9A     ;3
       LDA    #$6A    ;2
       BNE    L1BF1   ;2
L1C1E: LDY    #$C3    ;2
       LDA    $AF,X   ;4
       CMP    #$0A    ;2
       BCC    L1C4E   ;2
       CMP    #$6E    ;2
       BCS    L1C4E   ;2
       LDA    $B3,X   ;4
       CMP    #$04    ;2
       BCC    L1C4E   ;2
       CMP    #$68    ;2
       BCS    L1C4E   ;2
       LDA    #$F8    ;2
       STA    $9A     ;3
       SEC            ;2
       ROR    $8D     ;5
       LDA    #$BA    ;2
       STA    $A3     ;3
       SED            ;2
       LDA    $82     ;3
       SBC    #$15    ;2
       STA    $82     ;3
       CLD            ;2
       BCS    L1C4C   ;2
       JSR    L1C61   ;6
L1C4C: LDY    #$C0    ;2
L1C4E: STY    $9F,X   ;4
       RTS            ;6

L1C51: LDA    $AD,X   ;4
       CLC            ;2
       ADC    $85     ;3
       CMP    #$04    ;2
       BEQ    L1C60   ;2
       CMP    #$FC    ;2
       BEQ    L1C60   ;2
       STA    $AD,X   ;4
L1C60: RTS            ;6

L1C61: LDA    #$BA    ;2
       STA    $A3     ;3
       LDA    #$C7    ;2
       STA    $A5     ;3
       LDA    #$80    ;2
       STA    $9A     ;3
       STA    $8D     ;3
       LDA    #$C0    ;2
       STA    $A1     ;3
       STA    $A0     ;3
       LDX    #$01    ;2
       STX    $9B     ;3
       DEX            ;2
       STX    $A6     ;3
       RTS            ;6

L1C7D: .byte $00,$00,$00,$8B,$8A,$BA,$AB,$AA,$BB
L1C86: .byte $00,$00,$00,$B8,$A0,$A0,$B8,$88,$B8,$00,$00,$00
L1C92: .byte $00,$3F,$40,$49,$89,$89,$89,$89,$48,$40,$3F,$00
L1C9E: .byte $00,$FF,$00,$54,$54,$57,$54,$54,$A3,$00,$FF,$00
L1CAA: .byte $00,$FF,$00,$99,$A5,$AD,$A1,$A5,$19,$00,$FF,$00
L1CB6: .byte $00,$FC,$02,$32,$49,$41,$41,$49,$32,$02,$FC,$00
L1CC2: .byte $03,$03,$03,$02,$02,$02,$01,$01,$01,$00,$00,$01,$01,$01,$02,$02
       .byte $02,$03,$03,$03,$00,$C2,$00,$0A,$8A,$1C,$A8,$46,$A8,$00,$02,$00
       .byte $0A,$0A,$0F,$08,$06,$08
L1CE8: .byte $40,$40,$20,$10,$08,$04,$02,$01,$80,$40,$20,$10,$08,$04,$02,$02
       .byte $00,$00
L1CFA: .byte $00,$04,$08,$10,$19,$5B
L1D00: .byte $00,$FE,$86,$86,$82,$82,$82,$FE,$00,$18,$18,$18,$18,$08,$08,$08
       .byte $00,$FE,$C0,$C0,$FE,$02,$82,$FE,$00,$FE,$86,$06,$7E,$04,$84,$FC
       .byte $00,$0C,$0C,$7E,$44,$44,$44,$40,$00,$FE,$86,$06,$FE,$80,$80,$FE
       .byte $00,$FE,$86,$86,$FE,$80,$82,$FE,$00,$0C,$0C,$0C,$0C,$04,$04,$7C
       .byte $00,$FE,$86,$86,$FE,$44,$44,$7C,$00,$06,$06,$06,$FE,$82,$82,$FE
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$E5,$84,$84,$84,$8E,$00,$00
       .byte $A5,$AA,$EA,$AA,$48,$00,$00,$13,$AA,$AA,$AA,$92,$00,$00,$EA,$AE
       .byte $8A,$AA,$E4,$00,$00,$85,$84,$E4,$A4,$EE,$00,$00,$AC,$EA,$AA,$AA
       .byte $4C,$00,$00,$8A,$88,$A8,$D8,$88,$00,$00,$00,$00,$41,$63,$36,$1C
       .byte $08,$00,$41,$63,$36,$5D,$6B,$36,$1C,$08
L1D9A: .byte $9E,$A2,$A6,$AE,$0D,$08,$05,$00,$40,$10,$08,$00,$C0,$B0,$A0,$90
       .byte $10,$0A,$05,$00,$80,$60,$40,$08,$06,$04,$02,$00
L1DB6: .byte $00
L1DB7: .byte $01,$04,$09,$10,$11,$14,$19,$20,$21,$24,$29,$30,$3A,$48,$5A,$70
       .byte $71,$74,$79,$80,$8A,$98,$AA,$C0,$00,$01,$04,$09,$10,$1A,$28,$3A
       .byte $50
L1DD8: .byte $5E
L1DD9: .byte $65,$88,$50,$91,$50,$91,$88,$91,$91,$57,$50,$6C,$73,$7A,$81
L1DE8: LDX    #$00    ;2
       LDY    #$00    ;2
       ASL            ;2
       BCS    L1DF0   ;2
       DEX            ;2
L1DF0: ASL            ;2
       BCS    L1DF4   ;2
       INX            ;2
L1DF4: ASL            ;2
       BCS    L1DF8   ;2
       INY            ;2
L1DF8: ASL            ;2
       BCS    L1DFC   ;2
       DEY            ;2
L1DFC: RTS            ;6

L1DFD: .byte $52,$47,$53,$38,$10,$7C,$10,$38,$7C,$7C,$7C,$38,$7C,$FE,$FE,$FE
       .byte $FE,$FE,$7C,$10,$10,$38,$10,$10,$28,$7C,$28,$10,$10,$54,$38,$FE
       .byte $38,$54,$10,$10,$10,$28,$00,$00,$38,$44,$28,$00,$00,$00,$7C,$C6
       .byte $6C,$00,$00,$00,$00,$10,$38,$6C,$44,$28,$00,$00,$00,$00,$00,$00
       .byte $00,$10,$38,$6C,$D6,$82,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $10,$38,$6C,$54,$54,$44,$6C,$28,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$10,$28,$38,$6C,$FE,$D6,$D6,$82,$82,$C6,$C6,$44,$00,$00
       .byte $00,$00,$00,$10,$38,$28,$38,$7C,$44,$44,$44,$7C,$FE,$82,$82,$82
       .byte $82,$82,$FE,$7C,$7C,$44,$44,$44,$44,$44,$44,$7C,$7C,$FE,$FE,$82
       .byte $82,$82,$82,$82,$82,$82,$82,$82,$82,$FE,$FE,$7C,$7C,$7C,$44,$44
       .byte $44,$44,$44,$44,$44,$44,$44,$44,$44,$44,$7C,$7C,$7C,$FE,$FE,$FE
       .byte $82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82,$82
       .byte $FE,$FE,$FE
L1EC0: .byte $10,$01
L1EC2: .byte $0C
L1EC3: .byte $0A,$10,$03,$0C,$09,$10,$05,$0C,$08,$10,$07,$0C,$07,$15,$0A,$07
       .byte $06,$15,$0E,$07,$04,$17,$14,$00,$02,$17,$1C,$00,$00
L1EE0: .byte $A8,$0A,$FA,$38,$DA,$6A,$5A
L1EE7: LDA    #$01    ;2
       LDX    $C3     ;3
       BNE    L1EFE   ;2
       STA    $C3     ;3
       SED            ;2
       CLC            ;2
       ADC    $9E     ;3
       STA    $9E     ;3
       CLD            ;2
       LDA    #$05    ;2
       ADC    $9C     ;3
       BCS    L1EFE   ;2
       STA    $9C     ;3
L1EFE: RTS            ;6

L1EFF: .byte $DF
L1F00: .byte $10,$28,$18,$20,$08,$24,$18,$50,$24,$02,$08,$A8,$3C,$52,$24,$20
       .byte $20,$00,$48,$20,$14,$10,$24,$20,$08,$40,$00,$20,$00,$44,$80,$48
       .byte $12,$58,$A2,$20,$48,$00,$80,$00,$00,$00,$04,$20,$00,$10,$00,$28
       .byte $40,$10,$24,$00,$40,$10,$00,$08,$00,$00,$00,$00,$00,$00,$04,$00
       .byte $40,$00,$20,$00,$00,$08,$00,$00,$20,$00,$04,$00,$00,$00,$00,$00
       .byte $FF,$11,$0A,$12,$09,$13,$0B,$14,$0A,$15,$09,$16,$08,$17,$07,$18
       .byte $06,$19,$05,$1A,$04,$1B,$03,$1C,$02,$1D,$01,$FF,$81,$1D,$82,$1C
       .byte $82,$1B,$83,$1B,$83,$1A,$84,$19,$84,$19,$85,$18,$87,$0A,$89,$0A
       .byte $8B,$0B,$8B,$0C,$8B,$0C,$8A,$0D,$87,$0E,$84,$0E,$FF,$21,$0C,$21
       .byte $0C,$21,$0C,$21,$0C,$21,$0C,$21,$0C,$22,$0B,$22,$08,$24,$07,$24
       .byte $07,$24,$07,$25,$08,$28,$08,$28,$09,$28,$09,$2E,$06,$2E,$05,$2F
       .byte $05,$2F,$06,$2F,$06,$27,$07,$2F,$07,$2F,$07,$FF,$18,$18,$18,$00
       .byte $13,$13,$00,$13,$13,$00,$13,$13,$FF,$17,$00,$17,$00,$17,$00,$17
       .byte $FF,$08,$08,$08,$08,$08,$08,$07,$07,$00,$00,$09,$09,$09,$09,$09
       .byte $09,$00,$0C,$0C,$0C,$00,$13,$13,$13,$FF,$13,$13,$13,$17,$00,$13
       .byte $13,$17,$1A,$1D
L1FF4: .byte $FF,$E0,$69,$FF,$02,$11,$01,$01,$00,$10,$00,$10
