; Quadrun
;
; ********************************************************
; *** Disassembly and improvements By Fabrizio Zavagli ***
; ***                   March 2003                     ***
; ********************************************************
;
; quad1.cfg contents:
;
;	ORG B000 
;	CODE B000 B3Fa
;	CODE B619 B674
;	CODE B7d1 B877
;	CODE B87c B8ae
;	CODE BA9f BAc6
;	CODE BFEA Bff7
;
; quad2.cfg contents:
;
;	ORG F000 
;	CODE F000 Fa7a
;	CODE Fbe1 FC5C
;	CODE FC9F FFD9
;	CODE FFEA FFF7

NO = 0
YES = 1

PAL50 = NO		; PAL 50hz mode

PF_COLOR = $16			; Static color for playfield (if COLOR_RAINBOWS=NO)
;PF_COLOR = $26			; Static color for playfield (if COLOR_RAINBOWS=NO)
COLOR_RAINBOWS = YES		; Color type of playfield: solid or multicolored
COLOR_CYCLING = NO		; Cycle multicolored playfield?
BACKGROUND_FLASH = NO		; Flash for background (when enemy is hit)

      processor 6502
      include "vcs.h"

       ORG $1000
       RORG $B000

       LDA    #$00    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFF2   ;3
       LDA    #$00    ;2
       STA    VBLANK  ;3
       STA    $87     ;3
       LDY    #$00    ;2
       LDA    $8B     ;3
       AND    #$01    ;2
       CMP    #$01    ;2
       BNE    LB01D   ;2
	IF COLOR_CYCLING = YES
		INC    $B2     ;5
	ELSE
		BIT $00
	ENDIF
LB01D: STA    WSYNC   ;3
       LDA    #$00    ;2
       STA    PF1     ;3
       STA    PF2     ;3
       INY            ;2
       CPY    #$02    ;2
       BNE    LB01D   ;2
       STA    WSYNC   ;3
       LDX    $B1     ;3
       LDA    #$0D    ;2	Top line of playfield
       STA    COLUPF  ;3
       LDA    LBEAB,X ;4
       STA    PF2     ;3
       INY            ;2
       LDX    #$00    ;2
LB03A: STA    WSYNC   ;3
       LDA    LBECB,X ;4
       STA    COLUPF  ;3	Playfield part 1: top 1 (not cycling)
       LDA    LBEBB,X ;4
       STA    PF2     ;3
       INX            ;2
       INY            ;2
       CPY    #$0B    ;2
       BNE    LB03A   ;2
       LDA    #$00    ;2
       STA    $9A     ;3
LB050: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB05F   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB05F   ;2
       INC    $88     ;5
LB05F: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       LDX    $9A     ;3
       LDA    LBEC3,X ;4
       STA    COLUPF  ;3	Playfield part2: top2 (not cycling)
       LDA    LBEB3,X ;4
       STA    PF1     ;3
       INC    $9A     ;5
       INY            ;2
       CPY    #$13    ;2
       BNE    LB050   ;2
       STA    WSYNC   ;3
       LDA    #$00    ;2
       STA    PF1     ;3
       STA    PF2     ;3
       LDA    $B2     ;3
       STA    COLUPF  ;3	Playfield part3: between top and middle part (cycling!)
       STA    $A3     ;3
       INY            ;2
LB087: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB096   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB096   ;2
       INC    $88     ;5
LB096: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       INC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3	Playfield part4: mid top odd lines (cycling)
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB0BC   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB0BC   ;2
       INC    $88     ;5
LB0BC: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       INC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3	Playfield: mid top even lines
       LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB0CF   ;2
       INX            ;2
LB0CF: STX    ENABL   ;3
       INY            ;2
       CPY    #$28    ;2
       BNE    LB087   ;2
LB0D6: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB0E5   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB0E5   ;2
       INC    $88     ;5
LB0E5: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       BCC    LB106   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB106   ;2
       INC    $87     ;5
LB106: INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB116   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB116   ;2
       INC    $88     ;5
LB116: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       BCC    LB12D   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB12D   ;2
       INC    $87     ;5
LB12D: LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB134   ;2
       INX            ;2
LB134: STX    ENABL   ;3
       INY            ;2
       CPY    #$30    ;2
       BNE    LB0D6   ;2
LB13B: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB14A   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB14A   ;2
       INC    $88     ;5
LB14A: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       INC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3	Playfield mid top (cycling)
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB170   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB170   ;2
       INC    $88     ;5
LB170: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       INC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3	Playfield mid top (cycling)
       LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB183   ;2
       INX            ;2
LB183: STX    ENABL   ;3
       INY            ;2
       CPY    #$3E    ;2
       BNE    LB13B   ;2
LB18A: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB199   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB199   ;2
       INC    $88     ;5
LB199: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       BCC    LB1BA   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB1BA   ;2
       INC    $87     ;5
LB1BA: INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB1CA   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB1CA   ;2
       INC    $88     ;5
LB1CA: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       BCC    LB1E1   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB1E1   ;2
       INC    $87     ;5
LB1E1: LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB1E8   ;2
       INX            ;2
LB1E8: STX    ENABL   ;3
       INY            ;2
       CPY    #$76    ;2
       BNE    LB18A   ;2
LB1EF: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB1FE   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB1FE   ;2
       INC    $88     ;5
LB1FE: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       DEC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB224   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB224   ;2
       INC    $88     ;5
LB224: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       DEC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3
       LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB237   ;2
       INX            ;2
LB237: STX    ENABL   ;3
       INY            ;2
       CPY    #$86    ;2
       BNE    LB1EF   ;2
LB23E: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB24D   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB24D   ;2
       INC    $88     ;5
LB24D: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       BCC    LB26E   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB26E   ;2
       INC    $87     ;5
LB26E: INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB27E   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB27E   ;2
       INC    $88     ;5
LB27E: CPY    $91     ;3
       LDX    $87     ;3
       STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       BCC    LB295   ;2
       LDA    LBDC0,X ;4
       STA    COLUP0  ;3
       STA    GRP0    ;3
       BEQ    LB295   ;2
       INC    $87     ;5
LB295: LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB29C   ;2
       INX            ;2
LB29C: STX    ENABL   ;3
       INY            ;2
       CPY    #$8E    ;2
       BNE    LB23E   ;2
LB2A3: LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB2B2   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB2B2   ;2
       INC    $88     ;5
LB2B2: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       DEC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3
       LDA    LBC00,Y ;4
       STA    PF1     ;3
       LDA    LBD00,Y ;4
       STA    PF2     ;3
       INY            ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB2D8   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB2D8   ;2
       INC    $88     ;5
LB2D8: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       DEC    $B2     ;5
	IF COLOR_RAINBOWS = YES
		LDA    $B2     ;3
	ELSE
		LDA #PF_COLOR
	ENDIF
       STA    COLUPF  ;3
       LDX    #$01    ;2
       CPY    $85     ;3
       BNE    LB2EB   ;2
       INX            ;2
LB2EB: STX    ENABL   ;3
       INY            ;2
       CPY    #$A0    ;2
       BNE    LB2A3   ;2
       LDA    #$00    ;2
       CPY    $93     ;3
       BCC    LB301   ;2
       LDX    $88     ;3
       LDA    LBDC6,X ;4
       BEQ    LB301   ;2
       INC    $88     ;5
LB301: STA    WSYNC   ;3
       STA    COLUP1  ;3
       STA    GRP1    ;3
       LDA    #$00    ;2
       STA    PF1     ;3
       STA    PF2     ;3
       INY            ;2
       LDX    #$07    ;2
LB310: STA    WSYNC   ;3
       LDA    #$FF    ;2
       STA    PF2     ;3
       LDA    LBEC3,X ;4
       STA    COLUPF  ;3
       LDA    LBEB3,X ;4
       STA    PF1     ;3
       DEX            ;2
       INY            ;2
       CPY    #$A9    ;2
       BNE    LB310   ;2
       LDA    #$00    ;2
       STA    GRP1    ;3
       LDX    #$07    ;2
LB32C: STA    WSYNC   ;3
       LDA    #$00    ;2
       STA    PF1     ;3
       LDA    LBECB,X ;4
       STA    COLUPF  ;3
       LDA    LBEBB,X ;4
       STA    PF2     ;3
       DEX            ;2
       INY            ;2
       CPY    #$B1    ;2
       BNE    LB32C   ;2
       STA    WSYNC   ;3
       LDA    #$00    ;2
       STA    PF1     ;3
       STA    PF2     ;3
       INY            ;2
       STY    $A5     ;3
       LDY    #$05    ;2
       LDA    #$90    ;2
       STA    WSYNC   ;3
LB353: DEY            ;2
       BPL    LB353   ;2
       STA    RESP1   ;3
       STA    HMP1    ;3
       STA    WSYNC   ;3
       LDY    $A5     ;3
       INY            ;2
       INY            ;2

	IF PAL50 = YES
       LDA    #$28    ;2
       STA    COLUP1  ;3
       LDX    $A4     ;3
       LDA    LBEA6,X ;4
       STA    GRP1    ;3
       LDA    #$00    ;2
LB360: STA    WSYNC   ;3
	STA GRP1
       INY            ;2
       CPY    #$B5+16+1    ;2
       BNE    LB360   ;2
;       STA    WSYNC   ;3
	ELSE
LB360: STA    WSYNC   ;3
       LDA    #$28    ;2
       STA    COLUP1  ;3
       LDX    $A4     ;3
       LDA    LBEA6,X ;4
       STA    GRP1    ;3
       INY            ;2
       CPY    #$B5    ;2
       BNE    LB360   ;2
       STA    WSYNC   ;3
       LDA    #$00    ;2
	ENDIF

       STA    PF1     ;3
       STA    PF2     ;3
       STA    GRP1    ;3
       LDA    #$28    ;2
       STA    COLUP0  ;3
       STA    COLUP1  ;3
       JSR    LB806   ;6
       LDY    #$06    ;2
       JSR    LB7D1   ;6	Display score

       LDA    #$00    ;2
       STA    VDELP0  ;3
       STA    VDELP1  ;3
       STA    NUSIZ0  ;3
       STA    NUSIZ1  ;3
       LDA    #$82    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
       LDA    #$00    ;2
       STA    VBLANK  ;3
       STA    PF0     ;3
       STA    PF1     ;3
       STA    PF2     ;3
       STA    GRP0    ;3
       STA    GRP1    ;3
       LDA    $DD     ;3
       STA    COLUP0  ;3
       STA    COLUP1  ;3
       LDY    #$00    ;2
LB3B5: STA    WSYNC   ;3
       INY            ;2
	IF PAL50 = YES
		CPY    #$5C+16    ;2
	ELSE
		CPY    #$5C    ;2
	ENDIF
       BNE    LB3B5   ;2
       STY    $A5     ;3
       JSR    LB806   ;6
       LDY    #$0E    ;2
       JSR    LB7D1   ;6
       LDA    #$00    ;2
       STA    VDELP0  ;3
       STA    VDELP1  ;3
       STA    NUSIZ0  ;3
       STA    NUSIZ1  ;3
       CLC            ;2
       LDA    $A5     ;3
       ADC    #$11    ;2
       STA    $A5     ;3
       LDY    $A5     ;3
LB3D9: STA    WSYNC   ;3
       INY            ;2
	IF PAL50 = YES
		CPY    #$BF+16    ;2	Level screen
	ELSE
		CPY    #$BF    ;2	Level screen
	ENDIF
       BNE    LB3D9   ;2
       DEC    $BE     ;5
       LDA    $BE     ;3
       BNE    LB3EC   ;2
       LDA    #$00    ;2
       STA    $C1     ;3
       STA    $DA     ;3
LB3EC: LDA    #$28    ;2
       STA    $DD     ;3
       LDA    #$82    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
LB3FB: .byte $80,$40,$7F,$70,$7F,$40,$80,$00,$03,$04,$08,$09,$08,$04,$03,$30
       .byte $08,$FC,$FE,$FC,$08,$30,$00,$C3,$24,$24,$E4,$04,$04,$E3,$7E,$18
       .byte $18,$18,$18,$78,$38,$00,$C3,$24,$24,$24,$24,$24,$C3,$3C,$66,$66
       .byte $66,$66,$66,$3C,$00,$C4,$24,$24,$24,$25,$26,$C4,$0C,$10,$3F,$7F
       .byte $3F,$10,$0C,$00,$13,$30,$50,$91,$12,$12,$11,$01,$02,$FE,$0E,$FE
       .byte $02,$01,$00,$E0,$10,$10,$E0,$00,$00,$F0,$80,$40,$7F,$70,$7F,$40
       .byte $80,$00,$0F,$00,$00,$07,$08,$08,$07,$30,$08,$FC,$FE,$FC,$08,$30
       .byte $00,$88,$48,$48,$89,$0A,$0C,$C8,$7C,$46,$06,$7C,$60,$60,$7E,$00
       .byte $24,$64,$A4,$27,$24,$22,$21,$3C,$66,$66,$66,$66,$66,$3C,$00,$23
       .byte $24,$25,$E4,$24,$44,$83,$0C,$10,$3F,$7F,$3F,$10,$0C,$00,$C7,$20
       .byte $E0,$03,$04,$04,$E3,$01,$02,$FE,$0E,$FE,$02,$01,$00,$C0,$20,$20
       .byte $C0,$00,$00,$E0,$86,$41,$7F,$70,$7F,$41,$86,$00,$0F,$08,$08,$0F
       .byte $08,$08,$0F,$3F,$0C,$8C,$CC,$8C,$3C,$1C,$00,$C4,$24,$24,$C7,$24
       .byte $24,$C7,$78,$CD,$CD,$CD,$CD,$CD,$78,$00,$24,$44,$84,$C7,$24,$22
       .byte $C1,$F1,$9B,$9B,$9B,$9B,$9B,$F1,$00,$20,$20,$20,$E0,$20,$40,$87
       .byte $E0,$30,$31,$33,$31,$30,$E0,$00,$83,$80,$80,$81,$82,$82,$F1,$61
       .byte $82,$FE,$0E,$FE,$82,$61,$00,$E0,$10,$10,$E0,$00,$00,$F0,$83,$40
       .byte $7F,$70,$7F,$40,$83,$00,$18,$18,$18,$24,$42,$42,$42,$0F,$8C,$CC
       .byte $E7,$C1,$89,$0F,$00,$1E,$21,$21,$21,$21,$21,$1E,$87,$0C,$0C,$8C
       .byte $8C,$8C,$87,$00,$00,$00,$00,$3E,$00,$00,$00,$83,$C6,$C6,$C6,$C6
       .byte $C6,$83,$00,$18,$18,$18,$24,$42,$42,$42,$C0,$61,$63,$67,$63,$61
       .byte $C0,$00,$1E,$21,$21,$21,$21,$21,$1E,$C1,$02,$FE,$0E,$FE,$02,$C1
       .byte $00,$3E,$01,$01,$1E,$20,$20,$1F,$83,$40,$7F,$70,$7F,$40,$83,$00
       .byte $01,$01,$01,$01,$01,$01,$01,$0F,$88,$C0,$EF,$CC,$8C,$0F,$00,$04
       .byte $0C,$14,$24,$44,$84,$04,$87,$CC,$CC,$8C,$0C,$0C,$C7,$00,$3C,$42
       .byte $42,$42,$42,$42,$3C,$83,$C6,$C6,$C6,$C6,$C6,$83,$00,$3C,$22,$21
       .byte $21,$21,$22,$3C,$C0,$61,$63,$67,$63,$61,$C0,$00,$1F,$00,$00,$0F
       .byte $10,$10,$0F,$C1,$02,$FE,$0E,$FE,$02,$C1,$00,$00,$80,$80,$00,$00
       .byte $00,$80,$00,$00,$00,$00,$00,$00,$00,$00,$08,$0C,$0B,$08,$08,$08
       .byte $08,$84,$CC,$B4,$84,$84,$84,$84,$00,$47,$C8,$48,$48,$48,$48,$47
       .byte $84,$84,$84,$FC,$84,$48,$30,$00,$8F,$41,$41,$41,$41,$41,$8F,$10
       .byte $28,$44,$82,$82,$82,$82,$00,$E0,$00,$00,$00,$00,$00,$E7,$7E,$40
       .byte $40,$7E,$40,$40,$7E,$00,$82,$82,$82,$83,$82,$81,$F0,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$10,$10,$10,$F0,$10,$20,$C0,$A9,$00
       STA    VBLANK  ;3
       STA    $87     ;3
       STA    PF0     ;3
       STA    PF1     ;3
       STA    PF2     ;3
       STA    GRP0    ;3
       STA    GRP1    ;3
       LDA    $DD     ;3
       STA    COLUP0  ;3
       STA    COLUP1  ;3
       LDY    #$00    ;2
LB62F: STA    WSYNC   ;3
       INY            ;2
	IF PAL50 = YES
		CPY    #$47+16    ;2
	ELSE
		CPY    #$47    ;2
	ENDIF
       BNE    LB62F   ;2
       STY    $A5     ;3
       JSR    LB806   ;6
       LDY    #$39    ;2
       JSR    LB7D1   ;6
       LDA    #$00    ;2
       STA    VDELP0  ;3
       STA    VDELP1  ;3
       STA    NUSIZ0  ;3
       STA    NUSIZ1  ;3
       CLC            ;2
       LDA    $A5     ;3
       ADC    #$3C    ;2
       STA    $A5     ;3
       LDY    $A5     ;3
LB653: STA    WSYNC   ;3
       INY            ;2
	IF PAL50 = YES
		CPY    #$BF+16    ;2	Intro screen
	ELSE
		CPY    #$BF    ;2	Intro screen
	ENDIF
       BNE    LB653   ;2
       DEC    $8B     ;5
       LDA    $8B     ;3
       BNE    LB666   ;2
       LDA    #$00    ;2
       STA    $C1     ;3
       STA    $DA     ;3
LB666: LDA    #$28    ;2
       STA    $DD     ;3
       LDA    #$82    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
LB675: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$07,$0F,$1F,$3F
       .byte $7F,$7C,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78
       .byte $78,$78,$78,$7C,$7F,$3F,$1F,$0F,$07,$00,$30,$70,$F1,$F3,$F7,$F7
       .byte $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F3,$F1,$F0,$F0,$F0,$F0,$F1,$F3
       .byte $FF,$FF,$FF,$FF,$FF,$00,$C7,$EF,$DF,$BF,$7E,$7C,$3D,$3D,$3D,$3D
       .byte $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$FD,$F9
       .byte $F1,$E1,$C0,$00,$7F,$FE,$FC,$F9,$F3,$E7,$C7,$87,$07,$07,$87,$C7
       .byte $E7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$E7,$C7,$86,$04,$00
       .byte $E6,$CF,$9F,$3F,$7F,$FF,$FF,$F9,$F0,$E6,$EF,$EF,$EF,$EF,$EF,$EF
       .byte $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$C7,$83,$01,$00,$00,$3C,$7E
       .byte $FF,$FF,$FF,$FF,$E7,$C3,$99,$BD,$BD,$BD,$BD,$BD,$BD,$BC,$BC,$BD
       .byte $BF,$BF,$BF,$BF,$BF,$BF,$3E,$3C,$38,$00,$08,$18,$B9,$FB,$FB,$FB
       .byte $FB,$FB,$FB,$7B,$7B,$7B,$03,$7F,$7F,$7F,$7F,$7F,$03,$03,$03,$03
       .byte $03,$87,$CF,$FF,$FF,$FE,$FC,$00,$63,$E7,$EF,$EF,$EF,$EF,$EF,$EF
       .byte $EF,$EF,$EF,$EF,$CF,$9F,$3F,$7F,$FF,$FF,$FF,$FF,$EF,$CF,$8F,$0F
       .byte $0E,$0C,$08,$00,$5E,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE
       .byte $DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DE,$DF,$9F,$1F,$1F
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$E0,$F0
       .byte $F8,$FC,$FE,$7E,$3E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E,$1E
       .byte $1E,$1E,$1E,$1E,$3E,$7E,$FC,$F8,$F0,$E0,$00,$00
LB7D1: STY    $D6     ;3
LB7D3: LDY    $D6     ;3
       LDA    ($D4),Y ;5
       STA    GRP0    ;3	Logo
       STA    WSYNC   ;3
       LDA    ($D2),Y ;5
       STA    GRP1    ;3
       LDA    ($D0),Y ;5
       STA    GRP0    ;3
       LDA    ($CE),Y ;5
       STA    $D7     ;3
       LDA    ($CC),Y ;5
       TAX            ;2
       LDA    ($CA),Y ;5
       TAY            ;2
       LDA    $D7     ;3
       STA    GRP1    ;3
       STX    GRP0    ;3
       STY    GRP1    ;3
       STY    GRP0    ;3
       DEC    $D6     ;5
       BPL    LB7D3   ;2
       LDA    #$00    ;2
       STA    GRP0    ;3
       STA    GRP1    ;3
       STA    GRP0    ;3
       STA    GRP1    ;3
       RTS            ;6

LB806: STA    WSYNC   ;3
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
       STY    HMP1    ;3
       NOP            ;2
       STA    RESP0   ;3
       STA    RESP1   ;3
       LDA    #$F0    ;2
       STA    HMP0    ;3
       STA    WSYNC   ;3
       STA    HMOVE   ;3
       RTS            ;6

       LDA    #$02    ;2
       STA    VBLANK  ;3
       LDA    #$00    ;2
       STA    AUDC0   ;3
       STA    AUDF0   ;3
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       STA    $E4     ;3
       STA    COLUBK  ;3
       LDX    $9F     ;3
       LDA    LBA95,X ;4
       STA    $E5     ;3
LB847: LDA    $E5     ;3
       STA    $E1     ;3
       LDA    #$AF    ;2
       STA    $DF     ;3
       LDA    #$B8    ;2
       STA    $E0     ;3
       LDA    #$01    ;2
       STA    $E3     ;3
       STA    WSYNC   ;3
LB859: JSR    LB87C   ;6
       STA    WSYNC   ;3
       LDA    $E3     ;3
       BNE    LB859   ;2
       DEC    $E6     ;5
       BNE    LB875   ;2
       LDA    #$03    ;2
       STA    $C1     ;3
       LDA    #$3C    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
LB875: JMP    LB847   ;3
LB878: .byte $00,$FF,$01,$00
LB87C: CLC            ;2
       LDA    $E1     ;3
       ADC    $E2     ;3
       STA    $E2     ;3
       BCC    LB8A9   ;2
       LDY    #$00    ;2
       LDA    $E4     ;3
       EOR    #$01    ;2
       STA    $E4     ;3
       BNE    LB89C   ;2
       LDA    ($DF),Y ;5
       BEQ    LB8AA   ;2
       AND    #$F0    ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       LSR            ;2
       STA    AUDV1   ;3
       RTS            ;6

LB89C: CLC            ;2
       INC    $DF     ;5
       BNE    LB8A3   ;2
       INC    $E0     ;5
LB8A3: LDA    ($DF),Y ;5
       BEQ    LB8AA   ;2
       STA    AUDV1   ;3
LB8A9: RTS            ;6

LB8AA: STA    $E1     ;3
       STA    $E3     ;3
       RTS            ;6

LB8AF: .byte $9A,$86,$88,$89,$78,$76,$66,$7A,$A7,$87,$76,$6A,$87,$87,$78,$78
       .byte $97,$48,$A7,$77,$78,$98,$77,$77,$78,$76,$77,$88,$98,$88,$78,$77
       .byte $87,$77,$78,$87,$77,$87,$77,$77,$77,$88,$88,$78,$77,$88,$77,$88
       .byte $88,$78,$88,$77,$87,$78,$77,$78,$77,$77,$77,$87,$77,$77,$88,$88
       .byte $88,$88,$67,$35,$84,$9A,$99,$A9,$AA,$BA,$08,$80,$AD,$67,$64,$BA
       .byte $67,$B9,$9B,$FA,$03,$D3,$5B,$55,$A6,$7B,$75,$CB,$89,$FB,$03,$E3
       .byte $5B,$65,$B7,$5A,$95,$AC,$87,$FD,$02,$F4,$3A,$74,$C9,$06,$D8,$69
       .byte $B8,$EC,$04,$F4,$09,$A6,$AA,$14,$DA,$55,$BB,$B8,$0E,$F0,$0D,$A5
       .byte $A9,$25,$AD,$91,$6C,$B7,$DA,$07,$F8,$12,$9B,$69,$E2,$0A,$CA,$83
       .byte $7C,$F9,$01,$7F,$81,$B8,$17,$BE,$70,$5D,$D5,$77,$7F,$90,$3E,$83
       .byte $8C,$A1,$4D,$B3,$29,$9C,$E6,$0C,$F0,$09,$C7,$2A,$E7,$26,$C9,$A2
       .byte $5B,$EB,$06,$DB,$51,$CA,$43,$8E,$54,$4E,$B6,$98,$CC,$40,$6F,$52
       .byte $6E,$92,$7B,$82,$6A,$A6,$A9,$AC,$50,$8D,$52,$7E,$54,$8D,$34,$7D
       .byte $86,$AB,$6D,$60,$AA,$62,$BA,$54,$B9,$45,$B9,$76,$CA,$8D,$30,$D9
       .byte $35,$C5,$7A,$84,$7A,$76,$A9,$AA,$BB,$24,$92,$A9,$76,$96,$87,$87
       .byte $87,$87,$87,$98,$98,$78,$67,$67,$77,$88,$88,$87,$77,$87,$88,$88
       .byte $88,$77,$77,$77,$87,$88,$88,$78,$77,$67,$88,$97,$97,$78,$67,$77
       .byte $88,$88,$88,$78,$77,$77,$88,$88,$88,$88,$67,$76,$87,$88,$88,$78
       .byte $77,$77,$88,$88,$88,$99,$58,$46,$88,$89,$88,$87,$77,$76,$88,$98
       .byte $98,$99,$37,$45,$99,$78,$87,$88,$78,$76,$97,$98,$99,$9A,$34,$92
       .byte $B7,$85,$96,$89,$78,$76,$96,$A7,$A9,$CA,$15,$92,$B7,$84,$A6,$89
       .byte $87,$97,$75,$A6,$A8,$B9,$6D,$20,$7A,$58,$86,$6A,$78,$89,$58,$87
       .byte $89,$A9,$CD,$60,$C6,$82,$B6,$96,$A6,$97,$76,$85,$78,$A9,$DB,$18
       .byte $88,$46,$A7,$88,$97,$97,$76,$96,$87,$98,$AA,$4D,$84,$4B,$66,$5B
       .byte $59,$6A,$6A,$58,$78,$97,$A8,$CA,$28,$A8,$65,$B6,$96,$A5,$97,$67
       .byte $77,$78,$98,$A9,$BB,$50,$A5,$63,$78,$59,$7A,$79,$86,$76,$87,$79
       .byte $A9,$CA,$50,$78,$37,$7A,$88,$A6,$97,$77,$68,$87,$98,$A9,$CB,$30
       .byte $74,$48,$78,$98,$86,$88,$78,$77,$77,$88,$98,$A9,$5A,$45,$76,$87
       .byte $87,$88,$88,$88,$78,$77,$77,$87,$88,$98,$89,$66,$66,$77,$88,$88
       .byte $88,$88,$78,$77,$77,$87,$88,$98,$89,$67,$66,$77,$88,$88,$88,$88
       .byte $78,$77,$77,$87,$88,$00
LBA95: .byte $2A,$30,$35,$3A,$3F,$42,$45,$A5,$E7,$C6
       .byte $E7 ;.ISB;5
       BNE    LBAA6   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LBAA6: LDA    #$6B    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
       LDA    #$00    ;2
       STA    COLUBK  ;3
       LDY    #$00    ;2
LBAB7: STA    WSYNC   ;3
       INY            ;2
	IF PAL50 = YES
		CPY    #$BF+16    ;2
	ELSE
		CPY    #$BF    ;2
	ENDIF
       BNE    LBAB7   ;2
       LDA    #$82    ;2
       STA    $BF     ;3
       LDA    #$F0    ;2
       STA    $C0     ;3
       JMP    LBFEA   ;3
LBAC9: .byte $A9,$9F,$85,$BF,$A9,$F0,$85,$C0,$4C,$EA,$BF,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$3C,$66,$66,$66,$66,$66,$3C,$00,$7E
       .byte $18,$18,$18,$18,$78,$38,$00,$7E,$60,$60,$3C,$06,$46,$7C,$00,$3C
       .byte $46,$06,$0C,$06,$46,$3C,$00,$0C,$0C,$7E,$4C,$2C,$1C,$0C,$00,$7C
       .byte $46,$06,$7C,$60,$60,$7E,$00,$3C,$66,$66,$7C,$60,$62,$3C,$00,$18
       .byte $18,$08,$04,$02,$62,$7E,$00,$3C,$66,$66,$3C,$66,$66,$3C,$00,$3C
       .byte $46,$06,$3E,$66,$66,$3C,$00,$00,$00,$00,$00,$00,$00,$00,$00,$79
       .byte $85,$B5,$A5,$B5,$85,$79,$17,$15,$15,$77,$55,$55,$77,$71,$51,$11
       .byte $31,$11,$51,$70,$49,$49,$49,$C9,$49,$49,$BE,$55,$55,$55,$D9,$55
       .byte $55,$99,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00
LBC00: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01
       .byte $03,$03,$03,$03,$07,$07,$07,$07,$0F,$0F,$0F,$0F,$1F,$1F,$1F,$1F
       .byte $3F,$3F,$3F,$3F,$7F,$7F,$7F,$7F,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
       .byte $80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40
       .byte $80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40
       .byte $80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40,$80,$80,$40,$40
       .byte $80,$80,$40,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$7F,$7F,$7F,$7F,$3F
       .byte $3F,$3F,$3F,$1F,$1F,$1F,$1F,$0F,$0F,$0F,$0F,$07,$07,$07,$07,$03
       .byte $03,$03,$03,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LBD00: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$06,$06,$06,$06,$07,$07,$07,$07,$07,$07,$07,$07
       .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
       .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$80,$80,$C0,$C0,$E0,$E0,$40,$40,$E0,$E0,$C0,$C0,$80,$80,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
       .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07
       .byte $07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$07,$06,$06,$06,$06
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LBDC0: .byte $28,$7C,$38,$7C,$28,$00
LBDC6: .byte $EE,$C6,$38,$7C,$38,$C6,$EE,$00,$01,$EE,$D6,$7C,$D6,$EE,$00,$00
       .byte $01,$01,$FE,$38,$FE,$00,$00,$00,$EE,$C6,$38,$7C,$38,$C6,$EE,$00
       .byte $92,$54,$38,$FE,$38,$54,$92,$00,$82,$44,$28,$EE,$28,$44,$82,$00
       .byte $82,$44,$01,$C6,$01,$44,$82,$00,$92,$54,$38,$FE,$38,$54,$92,$00
       .byte $18,$3C,$76,$3C,$18,$00,$00,$00,$18,$3C,$5E,$3C,$18,$00,$00,$00
       .byte $18,$3C,$6E,$3C,$18,$00,$00,$00,$18,$3C,$76,$3C,$18,$00,$00,$00
       .byte $7C,$FE,$BA,$FE,$BA,$FE,$7C,$00,$FE,$7C,$38,$7C,$38,$7C,$FE,$00
       .byte $7C,$FE,$FE,$D6,$FE,$FE,$7C,$00,$7C,$FE,$BA,$FE,$BA,$FE,$7C,$00
       .byte $D6,$38,$FE,$6C,$FE,$38,$D6,$00,$6C,$38,$7C,$EE,$7C,$38,$6C,$00
       .byte $7C,$6C,$54,$FE,$54,$6C,$7C,$00,$D6,$38,$FE,$6C,$FE,$38,$D6,$00
       .byte $FE,$FE,$38,$FE,$FE,$38,$FE,$00,$FE,$FE,$6C,$FE,$FE,$6C,$FE,$00
       .byte $FE,$FE,$C6,$FE,$FE,$C6,$FE,$00,$FE,$FE,$38,$FE,$FE,$38,$FE,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LBEA6: .byte $00,$00,$80,$90,$92
LBEAB: .byte $00,$80,$C0,$E0,$F0,$F8,$FC,$FE
LBEB3: .byte $01,$03,$07,$0F,$1F,$3F,$7F,$FF
LBEBB: .byte $80,$C0,$E0,$F0,$F8,$FC,$FE,$FF
LBEC3: .byte $35,$36,$37,$38,$39,$3A,$3B,$3C
LBECB: .byte $25,$26,$27,$28,$29,$2A,$2B,$2C,$00,$00,$00,$00,$00,$00,$00,$00
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
       .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LBFEA: LDA    $C0     ;3
       AND    #$F0    ;2
       CMP    #$F0    ;2
       BNE    LBFF5   ;2
LBFF2: LDA    $FFF9   ;4
LBFF5: JMP ($00BF)     ;5
LBFF8: .byte $00
LBFF9: .byte $00,$00,$B0,$00,$B0,$00,$B0

       ORG $2000

       RORG $F000

START:
       CLD            ;2
       SEI            ;2
       LDX    #$FF    ;2
       TXS            ;2
       LDX    #$FF    ;2
       LDA    #$00    ;2
LF009: STA    VSYNC,X ;4
       DEX            ;2
       BNE    LF009   ;2
       LDA    #$00    ;2
       STA    $B4     ;3
LF012: LDA    #$03    ;2
       STA    WSYNC   ;3
       STA    VSYNC   ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       STA    WSYNC   ;3
       LDX    #$00    ;2
       STX    VSYNC   ;3
	IF PAL50 = YES
		LDA #$3a
	ELSE
		LDA    #$2B    ;2
	ENDIF
       STA    TIM64T  ;4
       LDA    $C1     ;3
       CMP    #$01    ;2
       BNE    LF03C   ;2
       LDA    $E6     ;3
       BEQ    LF03C   ;2
       LDA    #$2E    ;2
       STA    $BF     ;3
       LDA    #$B8    ;2
       STA    $C0     ;3
       JMP    LFFEA   ;3
LF03C: LDA    $C1     ;3
       CMP    #$01    ;2
       BEQ    LF059   ;2
       LDA    $C1     ;3
       CMP    #$03    ;2
       BEQ    LF059   ;2
       LDA    SWCHB   ;4
       AND    #$01    ;2
       BNE    LF059   ;2
       LDA    #$00    ;2
       STA    $B4     ;3
       STA    $B9     ;3
       STA    $C1     ;3
       STA    $DA     ;3
LF059: LDA    $C1     ;3
       AND    #$0F    ;2
       TAX            ;2
       LDA    LFA83,X ;4
       STA    $BF     ;3
       LDA    LFA87,X ;4
       STA    $C0     ;3
       JMP    LFFEA   ;3
LF06B: LDA    INTIM   ;4
       BNE    LF06B   ;2
       LDA    $C1     ;3
       AND    #$0F    ;2
       TAX            ;2
       LDA    LFA8B,X ;4
       STA    $BF     ;3
       LDA    LFA8F,X ;4
       STA    $C0     ;3
       JMP    LFFEA   ;3
       STA    WSYNC   ;3
       LDA    #$02    ;2
       STA    VBLANK  ;3
	IF PAL50 = YES
		LDA #$3c
	ELSE
		LDA    #$23    ;2
	ENDIF
       STA    TIM64T  ;4	Overscan
       LDA    $C1     ;3
       AND    #$0F    ;2
       TAX            ;2
       LDA    LFA93,X ;4
       STA    $BF     ;3
       LDA    LFA97,X ;4
       STA    $C0     ;3
       JMP    LFFEA   ;3
LF09F: LDA    INTIM   ;4
       BNE    LF09F   ;2
       INC    $C2     ;5
       JMP    LF012   ;3
       LDA    $B4     ;3
       BEQ    LF0B0   ;2
       JMP    LF18C   ;3
LF0B0: LDA    #$00    ;2
       STA    HMBL    ;3
       STA    $8B     ;3
       STA    $97     ;3
       STA    $99     ;3
       STA    $82     ;3
       STA    $83     ;3
       STA    GRP0    ;3
       STA    GRP1    ;3
       STA    ENAM0   ;3
       STA    ENAM1   ;3
       STA    REFP0   ;3
       STA    VDELP0  ;3
       STA    NUSIZ0  ;3
       STA    REFP1   ;3
       STA    VDELP1  ;3
       STA    PF0     ;3
       STA    PF1     ;3
       STA    PF2     ;3
       STA    $BC     ;3
       STA    $BB     ;3
       STA    COLUBK  ;3
       STA    NUSIZ1  ;3
       STA    $9F     ;3
       STA    $A0     ;3
       STA    $95     ;3
       STA    $C4     ;3
       STA    $C5     ;3
       STA    $C6     ;3
       STA    $C7     ;3
       STA    $C8     ;3
       STA    $C9     ;3
       STA    $D9     ;3
       STA    AUDF0   ;3
       STA    AUDV1   ;3
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       STA    AUDV1   ;3
       STA    $A2     ;3
       STA    $A8     ;3
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $B3     ;3
       STA    $9B     ;3
       STA    $8B     ;3
       STA    $B5     ;3
       STA    $DE     ;3
       LDA    #$A5    ;2
       STA    $93     ;3
       LDA    #$1F    ;2
       STA    $E7     ;3
       LDA    #$01    ;2
       STA    $9C     ;3
       STA    $81     ;3
       STA    $96     ;3
       STA    $A1     ;3
       STA    $9E     ;3
       STA    $B8     ;3
       LDA    #$03    ;2
       STA    $E6     ;3
       STA    $A4     ;3
       LDA    #$4C    ;2
       STA    $8F     ;3
       LDA    #$50    ;2
       STA    $90     ;3
       LDA    #$27    ;2
       STA    $91     ;3
       LDA    #$28    ;2
       STA    $85     ;3
       LDA    #$27    ;2
       STA    COLUP0  ;3
       STA    COLUP1  ;3
       LDA    #$05    ;2
       STA    CTRLPF  ;3
       LDA    #$10    ;2
       STA    HMP1    ;3
       LDA    #$0F    ;2
       STA    $84     ;3
       LDA    #$55    ;2
       STA    $92     ;3
       LDA    #$FF    ;2
       STA    $86     ;3
       STA    $BE     ;3
       STA    AUDV0   ;3
       LDA    #$04    ;2
       STA    AUDC0   ;3
       LDA    #$20    ;2
       STA    $A9     ;3
       LDA    #$40    ;2
       STA    $AA     ;3
       LDA    #$60    ;2
       STA    $AB     ;3
       LDA    #$80    ;2
       STA    $AC     ;3
       LDA    #$A0    ;2
       STA    $AD     ;3
       LDA    #$E0    ;2
       STA    $AF     ;3
       LDA    #$08    ;2
       STA    $B1     ;3
       LDA    #$28    ;2
       STA    $B2     ;3
       LDA    #$4C    ;2
       STA    $B6     ;3
       LDA    #$09    ;2
       STA    $BD     ;3
       LDA    #$55    ;2
       STA    $D8     ;3
       LDA    #$01    ;2
       STA    $B4     ;3
LF18C: LDA    $B9     ;3
       BNE    LF1AD   ;2
       LDX    #$0B    ;2
LF192: LDA    LFAB8,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LF192   ;2
       LDA    #$00    ;2
       STA    $A4     ;3
       LDA    $C2     ;3
       BNE    LF1AA   ;2
       LDA    #$7F    ;2
       STA    $8B     ;3
       LDA    #$02    ;2
       STA    $C1     ;3
LF1AA: JMP    LF1B0   ;3
LF1AD: JSR    LFC20   ;6
LF1B0: LDA    #$00    ;2
       STA    $DD     ;3
       LDY    $A2     ;3
       CPY    #$00    ;2
       BEQ    LF1E9   ;2
       DEC    $A1     ;5
       BNE    LF1E9   ;2
       LDA    #$04    ;2
       STA    AUDC0   ;3
       LDA    $D9     ;3
       BEQ    LF1CA   ;2
       LDA    #$09    ;2
       STA    AUDC0   ;3
LF1CA: LDA    LFC5C,Y ;4
       STA    $A1     ;3
       INY            ;2
       LDA    LFC5C,Y ;4
       CMP    #$FF    ;2
       BEQ    LF1DC   ;2
       STA    AUDF0   ;3
       INY            ;2
       BNE    LF1E4   ;2
LF1DC: LDY    #$00    ;2
       STY    AUDF0   ;3
       LDA    #$04    ;2
       STA    AUDC0   ;3
LF1E4: STY    $A2     ;3
       JMP    LF1EB   ;3
LF1E9: STA    WSYNC   ;3
LF1EB: LDA    $DB     ;3
       CMP    #$01    ;2
       BNE    LF203   ;2
       LDX    $DC     ;3
       LDA    LF0B0,X ;4
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       DEC    $DC     ;5
       LDA    $DC     ;3
       BNE    LF203   ;2
       JSR    LFFA0   ;6
LF203: LDA    $DB     ;3
       CMP    #$02    ;2
       BNE    LF21B   ;2
       LDX    $DC     ;3
       LDA    LF1EB,X ;4
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       DEC    $DC     ;5
       LDA    $DC     ;3
       BNE    LF21B   ;2
       JSR    LFFA0   ;6
LF21B: LDA    $DB     ;3
       CMP    #$03    ;2
       BNE    LF233   ;2
       LDX    $DC     ;3
       LDA    LFB18,X ;4
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       DEC    $DC     ;5
       LDA    $DC     ;3
       BNE    LF233   ;2
       JSR    LFFA0   ;6
LF233: LDA    $8B     ;3
       EOR    $9E     ;3
       STA    $A7     ;3
       AND    #$01    ;2
       STA    $9B     ;3
       INC    $8B     ;5
       LDA    $86     ;3
       CMP    #$FF    ;2
       BEQ    LF247   ;2
       INC    $9E     ;5
LF247: LDA    $A4     ;3
       BNE    LF24E   ;2
       JMP    LF251   ;3
LF24E: JSR    LFC9F   ;6
LF251: LDA    $82     ;3
       CMP    #$01    ;2
       BEQ    LF26B   ;2
       CMP    #$03    ;2
       BEQ    LF271   ;2
       LDA    $8F     ;3
       CLC            ;2
       ADC    #$04    ;2
       STA    $90     ;3
       LDA    $91     ;3
       ADC    #$01    ;2
       STA    $85     ;3
       JMP    LF274   ;3
LF26B: JSR    LFDBD   ;6
       JMP    LF274   ;3
LF271: JSR    LFE35   ;6
LF274: LDX    $90     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LF281: DEY            ;2
       BPL    LF281   ;2
       STA    RESBL   ;3
       STA    HMBL    ;3
       STA    WSYNC   ;3
       LDA    $81     ;3
       CMP    #$02    ;2
       BEQ    LF2BB   ;2
       LDA    $81     ;3
       CMP    #$04    ;2
       BEQ    LF2BB   ;2
       LDA    CXP0FB  ;3
       BPL    LF2B4   ;2
       LDA    $8F     ;3
       CMP    #$4D    ;2
       BCC    LF2A7   ;2
       LDA    #$02    ;2
       STA    $99     ;3
       JMP    LF2B8   ;3
LF2A7: LDA    $8F     ;3
       CMP    #$4B    ;2
       BCS    LF2B1   ;2
       LDA    #$01    ;2
       STA    $99     ;3
LF2B1: JMP    LF2B8   ;3
LF2B4: LDA    #$00    ;2
       STA    $99     ;3
LF2B8: JMP    LF2DD   ;3
LF2BB: LDA    CXP0FB  ;3
       BPL    LF2D9   ;2
       LDA    $91     ;3
       CMP    #$57    ;2
       BCC    LF2CC   ;2
       LDA    #$04    ;2
       STA    $99     ;3
       JMP    LF2DD   ;3
LF2CC: LDA    $91     ;3
       CMP    #$55    ;2
       BCS    LF2D6   ;2
       LDA    #$03    ;2
       STA    $99     ;3
LF2D6: JMP    LF2DD   ;3
LF2D9: LDA    #$00    ;2
       STA    $99     ;3
LF2DD: LDA    CXP0FB  ;3
       BPL    LF2E5   ;2
       LDA    #$3D    ;2
       STA    $A2     ;3
LF2E5: LDA    $81     ;3
       CMP    #$01    ;2
       BNE    LF2FE   ;2
       LDA    $8C     ;3
       BEQ    LF2F7   ;2
       LDA    #$4C    ;2
       STA    $8F     ;3
       LDA    #$27    ;2
       STA    $91     ;3
LF2F7: LDA    #$27    ;2
       STA    $91     ;3
       JMP    LF340   ;3
LF2FE: LDA    $81     ;3
       CMP    #$02    ;2
       BNE    LF317   ;2
       LDA    $8C     ;3
       BEQ    LF310   ;2
       LDA    #$78    ;2
       STA    $8F     ;3
       LDA    #$56    ;2
       STA    $91     ;3
LF310: LDA    #$78    ;2
       STA    $8F     ;3
       JMP    LF340   ;3
LF317: LDA    $81     ;3
       CMP    #$03    ;2
       BNE    LF330   ;2
       LDA    $8C     ;3
       BEQ    LF329   ;2
       LDA    #$4C    ;2
       STA    $8F     ;3
       LDA    #$86    ;2
       STA    $91     ;3
LF329: LDA    #$85    ;2
       STA    $91     ;3
       JMP    LF340   ;3
LF330: LDA    $8C     ;3
       BEQ    LF33C   ;2
       LDA    #$1E    ;2
       STA    $8F     ;3
       LDA    #$56    ;2
       STA    $91     ;3
LF33C: LDA    #$1E    ;2
       STA    $8F     ;3
LF340: LDA    #$00    ;2
       STA    $8C     ;3
       LDX    $8F     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LF351: DEY            ;2
       BPL    LF351   ;2
       STA    RESP0   ;3
       STA    HMP0    ;3
       STA    WSYNC   ;3
       LDA    $B5     ;3
       BEQ    LF361   ;2
       JMP    LF4D9   ;3
LF361: LDA    $D9     ;3
       BEQ    LF390   ;2
       LDA    $9C     ;3
       CMP    #$01    ;2
       BNE    LF390   ;2
       LDA    $A7     ;3
       AND    #$04    ;2
       CMP    #$04    ;2
       BNE    LF377   ;2
       LDA    #$04    ;2
       STA    $9F     ;3
LF377: LDA    $A7     ;3
       AND    #$01    ;2
       STA    $9D     ;3
       BEQ    LF390   ;2
       LDA    $A7     ;3
       AND    #$07    ;2
       CMP    #$02    ;2
       BEQ    LF38C   ;2
       STA    $9F     ;3
       JMP    LF390   ;3
LF38C: LDA    #$04    ;2
       STA    $9F     ;3
LF390: LDA    $9F     ;3
       CMP    #$01    ;2
       BEQ    LF3AD   ;2
       CMP    #$02    ;2
       BEQ    LF3B0   ;2
       CMP    #$03    ;2
       BEQ    LF3B3   ;2
       CMP    #$04    ;2
       BEQ    LF3B6   ;2
       CMP    #$05    ;2
       BEQ    LF3B9   ;2
       CMP    #$06    ;2
       BEQ    LF3BC   ;2
       JMP    LF3C0   ;3
LF3AD: JMP    LF44B   ;3
LF3B0: JMP    LF4D9   ;3
LF3B3: JMP    LF5D2   ;3
LF3B6: JMP    LF676   ;3
LF3B9: JMP    LF722   ;3
LF3BC: LDA    #$01    ;2
       STA    $D9     ;3
LF3C0: LDA    $D9     ;3
       BNE    LF3CE   ;2
       LDA    $DA     ;3
       CMP    #$01    ;2
       BNE    LF3CE   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LF3CE: LDA    CXP1FB  ;3
       AND    #$40    ;2
       BEQ    LF3E8   ;2
       JSR    LFBD9   ;6
       JSR    LFEF1   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $BC     ;3
       LDA    #$01    ;2
       STA    $A2     ;3
       INC    $A0     ;5
LF3E8: JSR    LFF06   ;6
       LDA    $A0     ;3
       CMP    #$05    ;2
       BNE    LF406   ;2
       INC    $9F     ;5
       LDA    #$1F    ;2
       STA    $E7     ;3
       JSR    LFBF1   ;6
       LDA    #$00    ;2
       STA    $A0     ;3
       LDA    #$02    ;2
       STA    $DA     ;3
       LDA    #$03    ;2
       STA    $E6     ;3
LF406: LDA    $A8     ;3
       CMP    #$18    ;2
       BNE    LF410   ;2
       LDA    #$00    ;2
       STA    $A8     ;3
LF410: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF41A   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF41A: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF423   ;2
       JMP    LF42F   ;3
LF423: LDA    #$00    ;2
       STA    $9C     ;3
       STA    $B3     ;3
       JSR    LFF5F   ;6
       JSR    LFF3C   ;6
LF42F: LDA    $9D     ;3
       CMP    #$00    ;2
       BEQ    LF443   ;2
       DEC    $93     ;5
       LDA    $93     ;3
       CMP    #$00    ;2
       BNE    LF448   ;2
       JSR    LFF7E   ;6
       JMP    LF448   ;3
LF443: INC    $93     ;5
       JSR    LFF27   ;6
LF448: JMP    LF7CC   ;3
LF44B: LDA    $D9     ;3
       BNE    LF459   ;2
       LDA    $DA     ;3
       CMP    #$02    ;2
       BNE    LF459   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LF459: LDA    CXP1FB  ;3
       AND    #$40    ;2
       BEQ    LF478   ;2
       LDX    #$05    ;2
LF461: JSR    LFBD9   ;6
       DEX            ;2
       BNE    LF461   ;2
       JSR    LFEF1   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $BC     ;3
       LDA    #$0E    ;2
       STA    $A2     ;3
       INC    $A0     ;5
LF478: JSR    LFF06   ;6
       LDA    $A0     ;3
       CMP    #$05    ;2
       BNE    LF494   ;2
       LDA    #$00    ;2
       STA    $A0     ;3
       LDA    #$1F    ;2
       STA    $E7     ;3
       JSR    LFBF1   ;6
       LDA    #$03    ;2
       STA    $9F     ;3
       STA    $DA     ;3
       STA    $E6     ;3
LF494: LDA    $A9     ;3
       CMP    #$38    ;2
       BNE    LF49E   ;2
       LDA    #$20    ;2
       STA    $A9     ;3
LF49E: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF4A8   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF4A8: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF4B1   ;2
       JMP    LF4BD   ;3
LF4B1: LDA    #$00    ;2
       STA    $9C     ;3
       STA    $B3     ;3
       JSR    LFF5F   ;6
       JSR    LFF3C   ;6
LF4BD: LDA    $9D     ;3
       CMP    #$00    ;2
       BEQ    LF4D1   ;2
       DEC    $93     ;5
       LDA    $93     ;3
       CMP    #$00    ;2
       BNE    LF4D6   ;2
       JSR    LFF7E   ;6
       JMP    LF4D6   ;3
LF4D1: INC    $93     ;5
       JSR    LFF27   ;6
LF4D6: JMP    LF7CC   ;3
LF4D9: LDA    #$00    ;2
       STA    $AE     ;3
       LDA    CXPPMM  ;3
       BPL    LF4FB   ;2
       JSR    LFBE5   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $B8     ;3
       JSR    LFFAB   ;6
       LDA    #$00    ;2
       STA    $B5     ;3
       LDA    #$4B    ;2
       STA    $B6     ;3
       LDA    #$0E    ;2
       STA    $A2     ;3
LF4FB: LDA    $8B     ;3
       AND    #$01    ;2
       CMP    #$01    ;2
       BNE    LF505   ;2
	IF COLOR_CYCLING = YES
		INC    $B2     ;5
	ELSE
		BIT $00
	ENDIF
LF505: LDA    #$57    ;2
       STA    $93     ;3
       LDA    $AA     ;3
       CMP    #$58    ;2
       BNE    LF513   ;2
       LDA    #$40    ;2
       STA    $AA     ;3
LF513: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF51D   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF51D: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF526   ;2
       JMP    LF539   ;3
LF526: LDA    #$00    ;2
       STA    $9C     ;3
       JSR    LFF5F   ;6
       LDA    #$00    ;2
       STA    $AE     ;3
       LDA    $9B     ;3
       STA    $9D     ;3
       LDA    #$00    ;2
       STA    $B0     ;3
LF539: LDA    $B8     ;3
       CMP    #$01    ;2
       BNE    LF552   ;2
       LDA    $A7     ;3
       AND    #$01    ;2
       CMP    #$01    ;2
       BNE    LF54E   ;2
       LDA    #$02    ;2
       STA    $B7     ;3
       JMP    LF552   ;3
LF54E: LDA    #$04    ;2
       STA    $B7     ;3
LF552: LDA    #$01    ;2
       STA    $B8     ;3
       LDA    $B7     ;3
       CMP    #$04    ;2
       BNE    LF58C   ;2
       LDA    $8B     ;3
       AND    #$01    ;2
       BNE    LF564   ;2
       DEC    $B6     ;5
LF564: LDA    $B6     ;3
       CMP    #$0E    ;2
       BNE    LF5B9   ;2
       JSR    LFFAB   ;6
       LDA    $B1     ;3
       BEQ    LF57D   ;2
       DEC    $B1     ;5
       LDA    $B1     ;3
       CMP    #$00    ;2
       BNE    LF57D   ;2
       LDA    #$00    ;2
       STA    $A4     ;3
LF57D: LDA    #$01    ;2
       STA    $9C     ;3
       LDA    #$01    ;2
       STA    $B8     ;3
       LDA    #$4B    ;2
       STA    $B6     ;3
       JMP    LF5B9   ;3
LF58C: LDA    $8B     ;3
       AND    #$01    ;2
       BNE    LF594   ;2
       INC    $B6     ;5
LF594: LDA    $B6     ;3
       CMP    #$8A    ;2
       BNE    LF5B9   ;2
       JSR    LFFAB   ;6
       LDA    $B1     ;3
       BEQ    LF5AD   ;2
       DEC    $B1     ;5
       LDA    $B1     ;3
       CMP    #$00    ;2
       BNE    LF5AD   ;2
       LDA    #$00    ;2
       STA    $A4     ;3
LF5AD: LDA    #$01    ;2
       STA    $9C     ;3
       LDA    #$01    ;2
       STA    $B8     ;3
       LDA    #$4B    ;2
       STA    $B6     ;3
LF5B9: LDX    $B6     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LF5C6: DEY            ;2
       BPL    LF5C6   ;2
       STA    RESP1   ;3
       STA    HMP1    ;3
       STA    WSYNC   ;3
       JMP    LF7E2   ;3
LF5D2: LDA    $D9     ;3
       BNE    LF5E0   ;2
       LDA    $DA     ;3
       CMP    #$03    ;2
       BNE    LF5E0   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LF5E0: LDA    CXP1FB  ;3
       AND    #$40    ;2
       BEQ    LF5FF   ;2
       LDX    #$02    ;2
LF5E8: JSR    LFBE5   ;6
       DEX            ;2
       BNE    LF5E8   ;2
       JSR    LFEF1   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $BC     ;3
       LDA    #$0E    ;2
       STA    $A2     ;3
       INC    $A0     ;5
LF5FF: JSR    LFF06   ;6
       LDA    $A0     ;3
       CMP    #$05    ;2
       BNE    LF61D   ;2
       INC    $9F     ;5
       LDA    #$1F    ;2
       STA    $E7     ;3
       JSR    LFBF1   ;6
       LDA    #$00    ;2
       STA    $A0     ;3
       LDA    #$04    ;2
       STA    $DA     ;3
       LDA    #$03    ;2
       STA    $E6     ;3
LF61D: LDA    $AC     ;3
       CMP    #$98    ;2
       BNE    LF627   ;2
       LDA    #$80    ;2
       STA    $AC     ;3
LF627: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF631   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF631: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF63A   ;2
       JMP    LF646   ;3
LF63A: LDA    #$00    ;2
       STA    $9C     ;3
       STA    $B3     ;3
       JSR    LFF5F   ;6
       JSR    LFF3C   ;6
LF646: LDA    $9D     ;3
       CMP    #$00    ;2
       BEQ    LF664   ;2
       LDA    $93     ;3
       CMP    #$5A    ;2
       BNE    LF656   ;2
       LDA    #$00    ;2
       STA    $9D     ;3
LF656: DEC    $93     ;5
       LDA    $93     ;3
       CMP    #$00    ;2
       BNE    LF673   ;2
       JSR    LFF7E   ;6
       JMP    LF673   ;3
LF664: LDA    $93     ;3
       CMP    #$51    ;2
       BNE    LF66E   ;2
       LDA    #$01    ;2
       STA    $9D     ;3
LF66E: INC    $93     ;5
       JSR    LFF27   ;6
LF673: JMP    LF7CC   ;3
LF676: LDA    $D9     ;3
       BNE    LF684   ;2
       LDA    $DA     ;3
       CMP    #$04    ;2
       BNE    LF684   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LF684: LDA    CXP1FB  ;3
       AND    #$40    ;2
       BEQ    LF6A3   ;2
       LDX    #$05    ;2
LF68C: JSR    LFBE5   ;6
       DEX            ;2
       BNE    LF68C   ;2
       JSR    LFEF1   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $BC     ;3
       LDA    #$0E    ;2
       STA    $A2     ;3
       INC    $A0     ;5
LF6A3: JSR    LFF06   ;6
       LDA    $A0     ;3
       CMP    #$05    ;2
       BNE    LF6C1   ;2
       INC    $9F     ;5
       LDA    #$03    ;2
       STA    $E6     ;3
       LDA    #$1F    ;2
       STA    $E7     ;3
       JSR    LFBF1   ;6
       LDA    #$00    ;2
       STA    $A0     ;3
       LDA    #$05    ;2
       STA    $DA     ;3
LF6C1: LDA    $AD     ;3
       CMP    #$B8    ;2
       BNE    LF6CB   ;2
       LDA    #$A0    ;2
       STA    $AD     ;3
LF6CB: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF6D5   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF6D5: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF6DE   ;2
       JMP    LF6EA   ;3
LF6DE: LDA    #$00    ;2
       STA    $9C     ;3
       STA    $B3     ;3
       JSR    LFF5F   ;6
       JSR    LFF3C   ;6
LF6EA: LDA    $9D     ;3
       CMP    #$00    ;2
       BEQ    LF70C   ;2
       LDA    $93     ;3
       CMP    #$74    ;2
       BCS    LF6FE   ;2
       CMP    #$40    ;2
       BCC    LF6FE   ;2
       DEC    $93     ;5
       DEC    $93     ;5
LF6FE: DEC    $93     ;5
       LDA    $93     ;3
       CMP    #$00    ;2
       BNE    LF71F   ;2
       JSR    LFF7E   ;6
       JMP    LF71F   ;3
LF70C: LDA    $93     ;3
       CMP    #$41    ;2
       BCC    LF71A   ;2
       CMP    #$74    ;2
       BCS    LF71A   ;2
       INC    $93     ;5
       INC    $93     ;5
LF71A: INC    $93     ;5
       JSR    LFF27   ;6
LF71F: JMP    LF7CC   ;3
LF722: LDA    $D9     ;3
       BNE    LF730   ;2
       LDA    $DA     ;3
       CMP    #$05    ;2
       BNE    LF730   ;2
       LDA    #$01    ;2
       STA    $C1     ;3
LF730: LDA    CXP1FB  ;3
       AND    #$40    ;2
       BEQ    LF74A   ;2
       JSR    LFBF1   ;6
       JSR    LFEF1   ;6
       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $BC     ;3
       LDA    #$0E    ;2
       STA    $A2     ;3
       INC    $A0     ;5
LF74A: JSR    LFF06   ;6
       LDA    $A0     ;3
       CMP    #$05    ;2
       BNE    LF766   ;2
       LDA    #$06    ;2
       STA    $9F     ;3
       JSR    LFBF1   ;6
       LDA    #$00    ;2
       STA    $A0     ;3
       LDA    #$03    ;2
       STA    $E6     ;3
       LDA    #$1F    ;2
       STA    $E7     ;3
LF766: LDA    $AB     ;3
       CMP    #$78    ;2
       BNE    LF770   ;2
       LDA    #$60    ;2
       STA    $AB     ;3
LF770: LDA    $AF     ;3
       CMP    #$E0    ;2
       BNE    LF77A   ;2
       LDA    #$C0    ;2
       STA    $AF     ;3
LF77A: LDA    $9C     ;3
       CMP    #$01    ;2
       BEQ    LF783   ;2
       JMP    LF78F   ;3
LF783: LDA    #$00    ;2
       STA    $9C     ;3
       STA    $B3     ;3
       JSR    LFF5F   ;6
       JSR    LFF3C   ;6
LF78F: LDA    $9D     ;3
       CMP    #$00    ;2
       BEQ    LF7A3   ;2
       DEC    $93     ;5
       LDA    $93     ;3
       CMP    #$00    ;2
       BNE    LF7A8   ;2
       JSR    LFF7E   ;6
       JMP    LF7C9   ;3
LF7A3: INC    $93     ;5
       JSR    LFF27   ;6
LF7A8: LDA    $96     ;3
       CMP    #$00    ;2
       BEQ    LF7BD   ;2
LF7AE: LDA    $92     ;3
       CMP    #$5D    ;2
       BEQ    LF7BD   ;2
       INC    $92     ;5
       LDA    #$01    ;2
       STA    $96     ;3
       JMP    LF7C9   ;3
LF7BD: LDA    $92     ;3
       CMP    #$3C    ;2
       BEQ    LF7AE   ;2
       DEC    $92     ;5
       LDA    #$00    ;2
       STA    $96     ;3
LF7C9: JMP    LF7CC   ;3
LF7CC: LDX    $92     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LF7D9: DEY            ;2
       BPL    LF7D9   ;2
       STA    RESP1   ;3
       STA    HMP1    ;3
       STA    WSYNC   ;3
LF7E2: LDA    $BC     ;3
       BEQ    LF7F6   ;2
       LDA    $BD     ;3
       BEQ    LF7F9   ;2
       LDA    $8B     ;3
       AND    #$01    ;2
       CMP    #$01    ;2
       BNE    LF7F6   ;2
       INC    $BB     ;5
       DEC    $BD     ;5
LF7F6: JMP    LF803   ;3
LF7F9: LDA    #$00    ;2
       STA    $BC     ;3
       STA    $BB     ;3
       LDA    #$09    ;2
       STA    $BD     ;3
LF803: LDA    $BB     ;3
	IF BACKGROUND_FLASH = YES
	       STA    COLUBK  ;3
	ELSE
	       STA COLUPF
	ENDIF
       LDA    $82     ;3
       BEQ    LF813   ;2
       LDA    $A4     ;3
       BEQ    LF80F   ;2
LF80F: LDA    #$00    ;2
       STA    $C1     ;3
LF813: LDA    $82     ;3
       BNE    LF864   ;2
       LDA    $DE     ;3
       BNE    LF864   ;2
       LDA    $D9     ;3
       BEQ    LF864   ;2
       LDA    $A0     ;3
       BNE    LF864   ;2
       LDA    #$07    ;2
       STA    $B1     ;3
       LDA    $A4     ;3
       CMP    #$03    ;2
       BNE    LF830   ;2
       JSR    LFBFD   ;6
LF830: LDA    $A4     ;3
       CMP    #$02    ;2
       BNE    LF83E   ;2
       LDX    #$05    ;2
LF838: JSR    LFBF1   ;6
       DEX            ;2
       BNE    LF838   ;2
LF83E: LDA    $A4     ;3
       CMP    #$01    ;2
       BNE    LF852   ;2
       JSR    LFBF1   ;6
       JSR    LFBF1   ;6
       LDX    #$05    ;2
LF84C: JSR    LFBE5   ;6
       DEX            ;2
       BNE    LF84C   ;2
LF852: LDA    #$1F    ;2
       STA    $E7     ;3
       LDA    #$03    ;2
       STA    $E6     ;3
       LDA    #$06    ;2
       STA    $DA     ;3
       LDA    #$01    ;2
       STA    $C1     ;3
       STA    $DE     ;3
LF864: LDA    $D9     ;3
       BEQ    LF893   ;2
       LDA    $9C     ;3
       CMP    #$01    ;2
       BNE    LF893   ;2
       LDA    $A7     ;3
       AND    #$04    ;2
       CMP    #$04    ;2
       BNE    LF87A   ;2
       LDA    #$04    ;2
       STA    $9F     ;3
LF87A: LDA    $A7     ;3
       AND    #$01    ;2
       STA    $9D     ;3
       BEQ    LF893   ;2
       LDA    $A7     ;3
       AND    #$07    ;2
       CMP    #$02    ;2
       BEQ    LF88F   ;2
       STA    $9F     ;3
       JMP    LF893   ;3
LF88F: LDA    #$04    ;2
       STA    $9F     ;3
LF893: STA    WSYNC   ;3
       STA    HMOVE   ;3
       STA    CXCLR   ;3
       LDA    $AE     ;3
       CMP    #$01    ;2
       BNE    LF8B5   ;2
       LDA    $8B     ;3
       AND    #$07    ;2
       CMP    #$07    ;2
       BNE    LF8AE   ;2
       LDA    $AF     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $AF     ;3
LF8AE: LDA    $AF     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF8B5: LDA    $B5     ;3
       BEQ    LF8BC   ;2
       JMP    LF8FE   ;3
LF8BC: LDA    $9F     ;3
       CMP    #$01    ;2
       BEQ    LF8E8   ;2
       CMP    #$02    ;2
       BEQ    LF8FE   ;2
       CMP    #$03    ;2
       BEQ    LF914   ;2
       CMP    #$04    ;2
       BEQ    LF92A   ;2
       CMP    #$05    ;2
       BEQ    LF940   ;2
       LDA    $8B     ;3
       AND    #$0F    ;2
       CMP    #$0F    ;2
       BNE    LF8E1   ;2
       LDA    $A8     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $A8     ;3
LF8E1: LDA    $A8     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF8E8: LDA    $8B     ;3
       AND    #$1F    ;2
       CMP    #$1F    ;2
       BNE    LF8F7   ;2
       LDA    $A9     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $A9     ;3
LF8F7: LDA    $A9     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF8FE: LDA    $8B     ;3
       AND    #$07    ;2
       CMP    #$07    ;2
       BNE    LF90D   ;2
       LDA    $AA     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $AA     ;3
LF90D: LDA    $AA     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF914: LDA    $8B     ;3
       AND    #$0F    ;2
       CMP    #$0F    ;2
       BNE    LF923   ;2
       LDA    $AC     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $AC     ;3
LF923: LDA    $AC     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF92A: LDA    $8B     ;3
       AND    #$0F    ;2
       CMP    #$0F    ;2
       BNE    LF939   ;2
       LDA    $AD     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $AD     ;3
LF939: LDA    $AD     ;3
       STA    $88     ;3
       JMP    LF953   ;3
LF940: LDA    $8B     ;3
       AND    #$0F    ;2
       CMP    #$0F    ;2
       BNE    LF94F   ;2
       LDA    $AB     ;3
       CLC            ;2
       ADC    #$08    ;2
       STA    $AB     ;3
LF94F: LDA    $AB     ;3
       STA    $88     ;3
LF953: LDA    #$00    ;2
       STA    GRP1    ;3
       STA    ENABL   ;3
       LDA    $A4     ;3
       BNE    LF9CC   ;2
       LDA    $B9     ;3
       BEQ    LF9A3   ;2
       LDA    $BE     ;3
       CMP    #$01    ;2
       BEQ    LF974   ;2
       LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDX    $BE     ;3
       LDA    LFB39,X ;4
       STA    AUDC1   ;3
       STA    AUDF1   ;3
LF974: LDA    $BE     ;3
       BEQ    LF986   ;2
       LDA    #$00    ;2
       STA    $C1     ;3
       LDA    $8B     ;3
       AND    #$01    ;2
       CMP    #$01    ;2
       BNE    LF986   ;2
       INC    $BB     ;5
LF986: DEC    $BE     ;5
       LDA    $BE     ;3
       BNE    LF9CC   ;2
       LDA    #$01    ;2
       STA    $BE     ;3
       JSR    LFFC9   ;6
       LDA    #$00    ;2
       STA    $BB     ;3
       LDA    $C2     ;3
       BNE    LF9A3   ;2
       LDA    #$7F    ;2
       STA    $8B     ;3
       LDA    #$02    ;2
       STA    $C1     ;3
LF9A3: LDA    SWCHB   ;4
       AND    #$01    ;2
       BEQ    LF9CC   ;2
       LDA    INPT4   ;3
       BMI    LF9B5   ;2
       JSR    LFFC9   ;6
       LDA    #$80    ;2
       STA    $BA     ;3
LF9B5: LDA    $BA     ;3
       BEQ    LF9CC   ;2
       LDA    INPT4   ;3
       BPL    LF9CC   ;2
       LDA    #$01    ;2
       STA    $B9     ;3
       LDA    #$00    ;2
       STA    $BA     ;3
       LDA    #$01    ;2
       STA    $DA     ;3
       JMP    LF0B0   ;3
LF9CC: JMP    LF06B   ;3
       LDA    #$00    ;2
       STA    AUDF0   ;3
       LDA    #$00    ;2
       STA    AUDF1   ;3
       STA    AUDC1   ;3
       STA    AUDV1   ;3
       LDA    $DA     ;3
       CMP    #$02    ;2
       BEQ    LFA06   ;2
       LDA    $DA     ;3
       CMP    #$03    ;2
       BEQ    LFA20   ;2
       LDA    $DA     ;3
       CMP    #$04    ;2
       BEQ    LFA2D   ;2
       LDA    $DA     ;3
       CMP    #$05    ;2
       BEQ    LFA13   ;2
       LDA    $DA     ;3
       CMP    #$06    ;2
       BEQ    LFA3A   ;2
       LDX    #$0B    ;2
LF9FB: LDA    LFAC4,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LF9FB   ;2
       JMP    LFA44   ;3
LFA06: LDX    #$0B    ;2
LFA08: LDA    LFAD0,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA08   ;2
       JMP    LFA44   ;3
LFA13: LDX    #$0B    ;2
LFA15: LDA    LFADC,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA15   ;2
       JMP    LFA44   ;3
LFA20: LDX    #$0B    ;2
LFA22: LDA    LFAE8,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA22   ;2
       JMP    LFA44   ;3
LFA2D: LDX    #$0B    ;2
LFA2F: LDA    LFAF4,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA2F   ;2
       JMP    LFA44   ;3
LFA3A: LDX    #$0B    ;2
LFA3C: LDA    LFB00,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA3C   ;2
LFA44: JMP    LF06B   ;3
       LDA    INPT4   ;3
       BMI    LFA4F   ;2
       LDA    #$80    ;2
       STA    $BA     ;3
LFA4F: LDA    $BA     ;3
       BEQ    LFA62   ;2
       LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDA    #$04    ;2
       STA    AUDC1   ;3
       LDX    $8B     ;3
       LDA    LFB39,X ;4
       STA    AUDF1   ;3
LFA62: LDX    #$0B    ;2
LFA64: LDA    LFB0C,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       BPL    LFA64   ;2
       JMP    LF06B   ;3
       LDX    #$0B    ;2
LFA71: LDA    LFAB8,X ;4
       STA    $CA,X   ;4
       DEX            ;2
       DEX            ;2
       BPL    LFA71   ;2
       JMP    LF09F   ;3
LFA7D: .byte $4C,$9F,$F0,$4C,$9F,$F0
LFA83: .byte $A9,$CF,$47,$9C
LFA87: .byte $F0,$F9,$FA,$BA
LFA8B: .byte $0B,$9F,$17,$B1
LFA8F: .byte $B0,$B3,$B6,$BA
LFA93: .byte $6F,$7D,$80,$C9
LFA97: .byte $FA,$FA,$FA,$BA,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00,$00,$00,$00
LFAAD: .byte $00,$08,$10,$18,$20,$28,$30,$38,$40,$48,$50
LFAB8: .byte $74,$BB,$6D,$BB,$66,$BB,$5F,$BB,$58,$BB,$50,$BB
LFAC4: .byte $46,$B4,$37,$B4,$28,$B4,$19,$B4,$0A,$B4,$FB,$B3
LFAD0: .byte $A0,$B4,$91,$B4,$82,$B4,$73,$B4,$64,$B4,$55,$B4
LFADC: .byte $FA,$B4,$EB,$B4,$DC,$B4,$CD,$B4,$BE,$B4,$AF,$B4
LFAE8: .byte $54,$B5,$45,$B5,$36,$B5,$27,$B5,$18,$B5,$09,$B5
LFAF4: .byte $AE,$B5,$9F,$B5,$90,$B5,$81,$B5,$72,$B5,$63,$B5
LFB00: .byte $08,$B6,$F9,$B5,$EA,$B5,$DB,$B5,$CC,$B5,$BD,$B5
LFB0C: .byte $97,$B7,$5D,$B7,$23,$B7,$E9,$B6,$AF,$B6,$75,$B6
LFB18: .byte $3C,$3D,$3E,$3F,$40,$41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B
       .byte $4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,$5B
       .byte $5C
LFB39: .byte $33,$23,$13,$03,$F3,$E3,$D3,$C3,$B3,$A3,$93,$83,$64,$54,$44,$34
       .byte $24,$14,$04,$F4,$E4,$D4,$C4,$B4,$A4,$94,$84,$65,$55,$45,$35,$25
       .byte $15,$05,$F5,$E5,$D5,$C5,$B5,$A5,$95,$85,$66,$56,$46,$36,$26,$16
       .byte $06,$F6,$E6,$D6,$C6,$B6,$A6,$96,$86,$67,$57,$47,$37,$27,$17,$07
       .byte $F7,$E7,$D7,$C7,$B7,$A7,$97,$87,$68,$58,$48,$38,$28,$18,$08,$F8
       .byte $E8,$D8,$C8,$B8,$A8,$98,$88,$69,$59,$49,$39,$29,$19,$09,$F9,$E9
       .byte $D9,$C9,$B9,$A9,$99,$89,$6A,$5A,$4A,$3A,$2A,$1A,$0A,$FA,$EA,$DA
       .byte $CA,$BA,$AA,$9A,$8A,$6B,$5B,$4B,$3B,$2B,$1B,$0B,$FB,$EB,$DB,$CB
       .byte $BB,$AB,$9B,$8B,$6C,$5C,$4C,$3C,$2C,$1C,$0C,$FC,$EC,$DC,$CC,$BC
       .byte $AC,$9C,$8C,$6D,$5D,$4D,$3D,$2D,$1D,$0D,$FD,$ED,$DD,$CD,$BD,$AD
LFBD9: .byte $E6,$C5,$A5,$C5,$C9,$0A,$90,$3E
       LDA    #$00    ;2
       STA    $C5     ;3
LFBE5: INC    $C6     ;5
       LDA    $C6     ;3
       CMP    #$0A    ;2
       BCC    LFC1F   ;2
       LDA    #$00    ;2
       STA    $C6     ;3
LFBF1: INC    $C7     ;5
       LDA    $C7     ;3
       CMP    #$0A    ;2
       BCC    LFC1F   ;2
       LDA    #$00    ;2
       STA    $C7     ;3
LFBFD: INC    $C8     ;5
       LDA    $C8     ;3
       CMP    #$0A    ;2
       BCC    LFC1F   ;2
       LDA    #$00    ;2
       STA    $C8     ;3
       INC    $C9     ;5
       LDA    $C9     ;3
       CMP    #$0A    ;2
       BCC    LFC1F   ;2
       LDA    #$00    ;2
       STA    $C4     ;3
       STA    $C5     ;3
       STA    $C6     ;3
       STA    $C7     ;3
       STA    $C8     ;3
       STA    $C9     ;3
LFC1F: RTS            ;6

LFC20: LDX    $C4     ;3
       LDA    LFAAD,X ;4
       LDY    #$00    ;2
       STA    $00CA,Y ;5
       LDX    $C5     ;3
       LDA    LFAAD,X ;4
       LDY    #$02    ;2
       STA    $00CA,Y ;5
       LDX    $C6     ;3
       LDA    LFAAD,X ;4
       LDY    #$04    ;2
       STA    $00CA,Y ;5
       LDX    $C7     ;3
       LDA    LFAAD,X ;4
       LDY    #$06    ;2
       STA    $00CA,Y ;5
       LDX    $C8     ;3
       LDA    LFAAD,X ;4
       LDY    #$08    ;2
       STA    $00CA,Y ;5
       LDX    $C9     ;3
       LDA    LFAAD,X ;4
       LDY    #$0A    ;2
       STA    $00CA,Y ;5
LFC5C: RTS            ;6

LFC5D: .byte $02,$1F,$02,$19,$02,$18,$02,$12,$02,$0F,$01,$FF,$00,$03,$1F,$02
       .byte $1B,$02,$18,$02,$17,$02,$14,$02,$12,$02,$10,$02,$0F,$03,$0D,$02
       .byte $0F,$02,$10,$02,$12,$02,$14,$02,$17,$02,$18,$02,$1B,$01,$FF,$01
       .byte $02,$05,$06,$07,$08,$09,$0A,$0B,$0C,$01,$FF,$01,$02,$05,$06,$07
       .byte $01,$FF
LFC9F: LDA    SWCHA   ;4
       STA    $86     ;3
       LDA    $81     ;3
       CMP    #$01    ;2
       BEQ    LFCB9   ;2
       LDA    $81     ;3
       CMP    #$02    ;2
       BEQ    LFCBC   ;2
       LDA    $81     ;3
       CMP    #$03    ;2
       BEQ    LFCBF   ;2
       JMP    LFD8E   ;3
LFCB9: JMP    LFCC2   ;3
LFCBC: JMP    LFD12   ;3
LFCBF: JMP    LFD41   ;3
LFCC2: LDA    $86     ;3
       AND    #$20    ;2
       BNE    LFCCB   ;2
       JSR    LFECF   ;6
LFCCB: LDA    $82     ;3
       BNE    LFCE9   ;2
       LDA    $85     ;3
       CMP    #$28    ;2
       BEQ    LFCD9   ;2
       CMP    #$86    ;2
       BNE    LFCE9   ;2
LFCD9: LDA    INPT4   ;3
       BMI    LFCE9   ;2
       LDA    #$01    ;2
       STA    $82     ;3
       LDA    $95     ;3
       BNE    LFCE9   ;2
       LDA    #$30    ;2
       STA    $A2     ;3
LFCE9: LDA    $86     ;3
       AND    #$80    ;2
       BNE    LFCFF   ;2
       LDA    $99     ;3
       CMP    #$02    ;2
       BEQ    LFCFB   ;2
       INC    $8F     ;5
       RTS            ;6

       JMP    LFCFF   ;3
LFCFB: JSR    LFEBE   ;6
       RTS            ;6

LFCFF: LDA    $86     ;3
       AND    #$40    ;2
       BNE    LFD11   ;2
       LDA    $99     ;3
       CMP    #$01    ;2
       BEQ    LFD0E   ;2
       DEC    $8F     ;5
       RTS            ;6

LFD0E: JSR    LFEE0   ;6
LFD11: RTS            ;6

LFD12: LDA    $86     ;3
       AND    #$40    ;2
       BNE    LFD1B   ;2
       JSR    LFEE0   ;6
LFD1B: LDA    $86     ;3
       AND    #$10    ;2
       BNE    LFD2E   ;2
       LDA    $99     ;3
       CMP    #$03    ;2
       BEQ    LFD2A   ;2
       DEC    $91     ;5
       RTS            ;6

LFD2A: JSR    LFEAD   ;6
       RTS            ;6

LFD2E: LDA    $86     ;3
       AND    #$20    ;2
       BNE    LFD40   ;2
       LDA    $99     ;3
       CMP    #$04    ;2
       BEQ    LFD3D   ;2
       INC    $91     ;5
       RTS            ;6

LFD3D: JSR    LFECF   ;6
LFD40: RTS            ;6

LFD41: LDA    $86     ;3
       AND    #$10    ;2
       BNE    LFD4A   ;2
       JSR    LFEAD   ;6
LFD4A: LDA    $82     ;3
       BNE    LFD68   ;2
       LDA    $85     ;3
       CMP    #$28    ;2
       BEQ    LFD58   ;2
       CMP    #$86    ;2
       BNE    LFD68   ;2
LFD58: LDA    INPT4   ;3
       BMI    LFD68   ;2
       LDA    #$03    ;2
       STA    $82     ;3
       LDA    $95     ;3
       BNE    LFD68   ;2
       LDA    #$30    ;2
       STA    $A2     ;3
LFD68: LDA    $86     ;3
       AND    #$80    ;2
       BNE    LFD7B   ;2
       LDA    $99     ;3
       CMP    #$02    ;2
       BEQ    LFD77   ;2
       INC    $8F     ;5
       RTS            ;6

LFD77: JSR    LFEBE   ;6
       RTS            ;6

LFD7B: LDA    $86     ;3
       AND    #$40    ;2
       BNE    LFD8D   ;2
       LDA    $99     ;3
       CMP    #$01    ;2
       BEQ    LFD8A   ;2
       DEC    $8F     ;5
       RTS            ;6

LFD8A: JSR    LFEE0   ;6
LFD8D: RTS            ;6

LFD8E: LDA    $86     ;3
       AND    #$80    ;2
       BNE    LFD97   ;2
       JSR    LFEBE   ;6
LFD97: LDA    $86     ;3
       AND    #$10    ;2
       BNE    LFDAA   ;2
       LDA    $99     ;3
       CMP    #$03    ;2
       BEQ    LFDA6   ;2
       DEC    $91     ;5
       RTS            ;6

LFDA6: JSR    LFEAD   ;6
       RTS            ;6

LFDAA: LDA    $86     ;3
       AND    #$20    ;2
       BNE    LFDBC   ;2
       LDA    $99     ;3
       CMP    #$04    ;2
       BEQ    LFDB9   ;2
       INC    $91     ;5
       RTS            ;6

LFDB9: JSR    LFECF   ;6
LFDBC: RTS            ;6

LFDBD: LDA    $85     ;3
       CMP    #$31    ;2
       BCC    LFDFB   ;2
       LDA    CXP0FB  ;3
       AND    #$40    ;2
       BEQ    LFDD7   ;2
       LDA    #$00    ;2
       STA    $82     ;3
       JSR    LFFBC   ;6
       LDA    #$00    ;2
       STA    $95     ;3
       JMP    LFE13   ;3
LFDD7: LDA    $85     ;3
       CMP    #$9A    ;2
       BNE    LFDE8   ;2
       LDA    $A4     ;3
       BEQ    LFDE8   ;2
       SEC            ;2
       LDA    $A4     ;3
       SBC    #$01    ;2
       STA    $A4     ;3
LFDE8: LDA    $85     ;3
       CMP    #$9C    ;2
       BCC    LFDFB   ;2
       LDA    INPT4   ;3
       BPL    LFDF8   ;2
       LDA    #$00    ;2
       STA    $82     ;3
       STA    $95     ;3
LFDF8: JMP    LFE13   ;3
LFDFB: INC    $85     ;5
       LDA    $85     ;3
       CMP    #$9A    ;2
       BNE    LFE0F   ;2
       LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDA    #$11    ;2
       STA    $DC     ;3
       LDA    #$02    ;2
       STA    $DB     ;3
LFE0F: LDA    #$01    ;2
       STA    $95     ;3
LFE13: LDA    $82     ;3
       CMP    #$01    ;2
       BEQ    LFE1E   ;2
       CMP    #$03    ;2
       BEQ    LFE1E   ;2
       RTS            ;6

LFE1E: LDX    $90     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LFE2B: DEY            ;2
       BPL    LFE2B   ;2
       STA    RESBL   ;3
       STA    HMBL    ;3
       STA    WSYNC   ;3
       RTS            ;6

LFE35: LDA    $85     ;3
       CMP    #$81    ;2
       BCS    LFE73   ;2
       LDA    CXP0FB  ;3
       AND    #$40    ;2
       BEQ    LFE4F   ;2
       LDA    #$00    ;2
       STA    $82     ;3
       JSR    LFFBC   ;6
       LDA    #$00    ;2
       STA    $95     ;3
       JMP    LFE8B   ;3
LFE4F: LDA    $85     ;3
       CMP    #$15    ;2
       BNE    LFE60   ;2
       LDA    $A4     ;3
       BEQ    LFE60   ;2
       SEC            ;2
       LDA    $A4     ;3
       SBC    #$01    ;2
       STA    $A4     ;3
LFE60: LDA    $85     ;3
       CMP    #$13    ;2
       BCS    LFE73   ;2
       LDA    INPT4   ;3
       BPL    LFE70   ;2
       LDA    #$00    ;2
       STA    $82     ;3
       STA    $95     ;3
LFE70: JMP    LFE8B   ;3
LFE73: DEC    $85     ;5
       LDA    $85     ;3
       CMP    #$15    ;2
       BNE    LFE87   ;2
       LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDA    #$11    ;2
       STA    $DC     ;3
       LDA    #$02    ;2
       STA    $DB     ;3
LFE87: LDA    #$03    ;2
       STA    $95     ;3
LFE8B: LDA    $82     ;3
       CMP    #$03    ;2
       BEQ    LFE96   ;2
       CMP    #$01    ;2
       BEQ    LFE96   ;2
       RTS            ;6

LFE96: LDX    $90     ;3
       LDA    LFB39,X ;4
       AND    #$0F    ;2
       TAY            ;2
       LDA    LFB39,X ;4
       STA    WSYNC   ;3
LFEA3: DEY            ;2
       BPL    LFEA3   ;2
       STA    RESBL   ;3
       STA    HMBL    ;3
       STA    WSYNC   ;3
       RTS            ;6

LFEAD: LDA    #$01    ;2
       STA    $81     ;3
       LDA    #$03    ;2
       STA    $83     ;3
       LDA    #$4C    ;2
       STA    $8F     ;3
       LDA    #$27    ;2
       STA    $91     ;3
       RTS            ;6

LFEBE: LDA    #$02    ;2
       STA    $81     ;3
       LDA    #$04    ;2
       STA    $83     ;3
       LDA    #$78    ;2
       STA    $8F     ;3
       LDA    #$56    ;2
       STA    $91     ;3
       RTS            ;6

LFECF: LDA    #$03    ;2
       STA    $81     ;3
       LDA    #$01    ;2
       STA    $83     ;3
       LDA    #$4C    ;2
       STA    $8F     ;3
       LDA    #$86    ;2
       STA    $91     ;3
       RTS            ;6

LFEE0: LDA    #$04    ;2
       STA    $81     ;3
       LDA    #$02    ;2
       STA    $83     ;3
       LDA    #$1E    ;2
       STA    $8F     ;3
       LDA    #$56    ;2
       STA    $91     ;3
       RTS            ;6

LFEF1: LDA    $A7     ;3
       AND    #$03    ;2
       CMP    #$03    ;2
       BNE    LFEFD   ;2
       LDA    #$01    ;2
       STA    $B5     ;3
LFEFD: CMP    #$02    ;2
       BNE    LFF05   ;2
       LDA    #$01    ;2
       STA    $B5     ;3
LFF05: RTS            ;6

LFF06: LDA    $B3     ;3
       CMP    #$01    ;2
       BEQ    LFF26   ;2
       LDA    CXPPMM  ;3
       BPL    LFF26   ;2
       LDA    $A4     ;3
       CMP    #$01    ;2
       BNE    LFF1A   ;2
       LDA    $82     ;3
       BNE    LFF26   ;2
LFF1A: LDA    $A4     ;3
       BEQ    LFF26   ;2
       DEC    $A4     ;5
       LDA    #$01    ;2
       STA    $A2     ;3
       STA    $B3     ;3
LFF26: RTS            ;6

LFF27: LDA    $93     ;3
       CMP    #$C0    ;2
       BNE    LFF3B   ;2
       LDA    #$01    ;2
       STA    $9C     ;3
       LDA    $A7     ;3
       AND    #$1F    ;2
       TAX            ;2
       LDA    LFB18,X ;4
       STA    $92     ;3
LFF3B: RTS            ;6

LFF3C: LDA    #$00    ;2
       STA    $AE     ;3
       LDA    $9B     ;3
       STA    $9D     ;3
       LDA    $B0     ;3
       CMP    #$01    ;2
       BEQ    LFF5A   ;2
       LDA    $B1     ;3
       BEQ    LFF5A   ;2
       DEC    $B1     ;5
       LDA    $B1     ;3
       CMP    #$00    ;2
       BNE    LFF5A   ;2
       LDA    #$00    ;2
       STA    $A4     ;3
LFF5A: LDA    #$00    ;2
       STA    $B0     ;3
       RTS            ;6

LFF5F: LDA    $9F     ;3
       CMP    #$00    ;2
       BNE    LFF69   ;2
       LDA    #$00    ;2
       STA    $A8     ;3
LFF69: LDA    $9F     ;3
       CMP    #$01    ;2
       BNE    LFF73   ;2
       LDA    #$20    ;2
       STA    $A9     ;3
LFF73: LDA    $9F     ;3
       CMP    #$02    ;2
       BNE    LFF7D   ;2
       LDA    #$40    ;2
       STA    $AA     ;3
LFF7D: RTS            ;6

LFF7E: LDA    #$01    ;2
       STA    $9C     ;3
       LDA    $A7     ;3
       AND    #$1F    ;2
       TAX            ;2
       LDA    LFB18,X ;4
       STA    $92     ;3
       RTS            ;6

       LDA    #$01    ;2
       STA    $AE     ;3
       STA    $B0     ;3
       STA    $B8     ;3
       STA    $AE     ;3
       LDA    #$00    ;2
       STA    $B5     ;3
       LDA    #$4B    ;2
       STA    $B6     ;3
       RTS            ;6

LFFA0: LDA    #$00    ;2
       STA    AUDV1   ;3
       STA    AUDC1   ;3
       STA    AUDF1   ;3
       STA    $DB     ;3
       RTS            ;6

LFFAB: LDA    $A4     ;3
       BEQ    LFFBB   ;2
       LDA    #$03    ;2
       STA    $DB     ;3
       LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDA    #$11    ;2
       STA    $DC     ;3
LFFBB: RTS            ;6

LFFBC: LDA    #$FF    ;2
       STA    AUDV1   ;3
       LDA    #$11    ;2
       STA    $DC     ;3
       LDA    #$01    ;2
       STA    $DB     ;3
       RTS            ;6

LFFC9: LDA    #$00    ;2
       STA    $A2     ;3
       STA    AUDV0   ;3
       STA    AUDV1   ;3
       STA    AUDC0   ;3
       STA    AUDC1   ;3
       STA    AUDF0   ;3
       STA    AUDF1   ;3
       RTS            ;6

LFFDA: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
LFFEA: LDA    $C0     ;3
       AND    #$F0    ;2
       CMP    #$F0    ;2
       BEQ    LFFF5   ;2
       LDA    LFFF8   ;4
LFFF5: JMP ($00BF)     ;5
LFFF8: .byte $00,$00,$00,$F0,$00,$F0,$00,$F0
