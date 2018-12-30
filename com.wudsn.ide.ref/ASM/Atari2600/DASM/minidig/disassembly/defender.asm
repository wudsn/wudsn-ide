; Defender for the Atari 2600 VCS
;
; Copyright 1982 Atari
; Written by Bob Polaro
;
; Reverse-Engineered by Nick Bensema & Manuel Polik
;
; Compiles with DASM
;
; History
; 24.02.1997      - Initial Release by Nick Bensema
; 18.10.2.1K      - Continued by Manuel Polik
; 08.11.2.1K      - Radar display finished
; 08.11.2.1K      - Update released

    include vcs.h

; RAM variables:

radarColor          = $90   ; Color used for P1 in radar
bcdGameVariant      = $9B   ; Current game variant in BCD Format(1-20)
frameCounter        = $A3   ; is incremented once every frame
radar1VerPos        = $AA   ; vertical position of radar dot
radar2VerPos        = $AC   ; vertical position of radar dot
enemyWave           = $D2   ; Current wave of enemies
gameColors          = $E8   ; table of the colors used in the game
;                     -$EE 

CITYGFX =   $D4
JOYSTICK = $B3

; Begin source

    processor 6502
    ORG $F000

START:
       SEI
       CLD
        ; Clear all memory
       LDX    #$FF 
       TXS
       LDA    #$00 
LF007: STA    WSYNC,X 
       DEX
       BNE    LF007
       LDX    #$FF 
       STX    $98    ;Load $98 and bcdGameVariant
       STX    bcdGameVariant    ;with #$FF
       JSR    LFD3B
       JSR    LFD1C
       STA    $A2 
       JSR    LFD17
LF01D: JSR    LF08C
       LDA    $CB 
       BNE    LF037
       LDA    $B4 
       BNE    LF02E
       JSR    LF0F0
       JSR    LF1D6
LF02E: JSR    LF227
       JSR    LF2E8
       JSR    LF33C
LF037: JSR    LF3EA
       JSR    LF551
       JSR    LF5FF
       JSR    LF628
       JSR    LF66E
       JSR    LF45B
       JSR    LF4A2
       JMP    LF6C7
LF04F: LDA    $CB 
       BEQ    LF062
       INY
       STY    $E6 
       DEC    $CB 
       LDA    $CB 
       BNE    LF084
       JSR    LFDC3
       JSR    LFCE3
LF062: JSR    LF8AB
       JSR    LF969
       JSR    LF9A2
       JSR    LF9FB
       JSR    LFA4F
       LDA    $91 
       BNE    LF07B
       JSR    LFADD  ;These two executed only
       JSR    LFB37  ;if $91 equals zero
LF07B: JSR    LFB90
       JSR    LFC0C
       JSR    LFC43
LF084: LDA    INTIM
       BNE    LF084
       JMP    LF01D
    ; Do vertical blanking
LF08C: LDA    #$FF 
       STA    WSYNC
       STA    VSYNC
       STA    VBLANK
       STA    WSYNC
       STA    WSYNC
       STA    WSYNC
       STA    WSYNC
    ; Set timer
       LDA    #$36 
       STA    TIM64T
       LDY    #$00 
       STY    PF0
       STY    VSYNC
       LDX    #$7F 
       STX    VBLANK
       LDY    $A2 
       LDA.wy $00C2,Y
       STA    $C0    ; Display value for $C2
       LDA.wy $00C4,Y
       STA    $C1    ; Display value for $C4
       ; I keep seeing stuff like this.
       ; It smells of random number generation.
       LDA    $98 
       ASL 
       EOR    $98 
       ASL 
       ASL 
       ROL    $98 
       LDA    $CB 
       BEQ    LF0CD
       LDA    #$00 
       STA    $BD 
       STA    $BF 
       JSR    LFCAC
    ; This little routine grabs the appropriate
    ; joystick readings and shifts them to a common
    ; location so that it needn't be considered further.
LF0CD: LDA    SWCHA
       LDY    $A2     ;A2 seems to be player number.
       AND.wy PLYRJOY,Y ;Y= 0: 0xF0  1: 0x0F
       STA    JOYSTICK     ;AND mask for joytick
       CPY    #$01 
       BNE    LF0E1
       ASL 
       ASL 
       ASL 
       ASL 
       STA    JOYSTICK 
LF0E1: LDX    $8D 
       BNE    LF0E7
       STX    $91 
LF0E7: CMP    #$F0 
       BEQ    LF0EF
       LDA    #$78 
       STA    $8D 
LF0EF: RTS

LF0F0: JSR    LFC7B
       LDA    $CD 
       BMI    LF13A ;Skip if less than zero.
    ;ON $CD goto LF16E, LF149, LF158
       CMP    #$01 
       BEQ    LF16E
       CMP    #$02 
       BEQ    LF149
       CMP    #$03 
       BEQ    LF158
       LDX    $BB 
        ; if ( $80 [ $BB ] & 0xF0 )== 0
       LDA    $80,X
       AND    #$F0 
       BNE    LRTS1
        ; and ( $80 [ $BB ] & 0x0F )== 4
       LDA    $80,X
       AND    #$0F 
       CMP    #$04 
       BNE    LRTS1
        ; and radar1VerPos & 0x80 == 0
       LDA    radar1VerPos 
       BMI    LRTS1
        ; and $CE & 0x80 == 0
       LDA    $CE 
       BMI    LRTS1
        ; and $A8 == $A9
       LDA    $A8 
       CMP    $A9 
       BNE    LRTS1
        ; then $AF = $C6 = $CD = 0xFF
       LDA    #$FF 
       STA    $CD 
       STA    $C6 
       STA    $AF
        ; $C7 = (radar2VerPos - 1) * 16 
       LDA    radar2VerPos 
       SEC
       SBC    #$01 
       ASL 
       ASL 
       ASL 
       ASL 
       STA    $C7
        ; $CA = $CE
        ;and if I'm right, $B9 = $BB.
       LDA    $CE 
       STA    $CA 
       STX    $B9 
LF13A: LDA    frameCounter 
       AND    $93 
       BNE    LRTS1
       LDA    $C7 
       CMP    #$17 
       BCC    LF166
       DEC    $C7 
LRTS1: RTS

LF149: CMP    $AF      ;Branched here if $CD = 2
       BCS    LF1B8    ;Branch if radar2VerPos > $AF
       LDA    frameCounter 
       AND    #$03 
       BNE    LRTS1    ;RTS if frameCounter has bits 0 or 1.
       DEC    $AF
       DEC    $C7
       RTS

LF158: LDA    $AD    ; Branched here if $CD = 3
       CMP    #$1E 
       BNE    LRTS1  ;RTS if $AD != #$1E.
       STA    $8A    ;$8A = $AD
       LDA    #$05 
       STA    $99 
       BNE    LF1C9  ; Always branch
LF166: INC    $AF    ;Branched here if $C7 < 0x17
       LDA    $AF 
       CMP    #$0E 
       BCC    LRTS1   ;Branch if $AF < $0E
LF16E: LDA    $C7     ; Branched here if $CD = 1
       LDY    #$01 
       STY    $CD     ;
       CMP    #$87 
       BCS    LF188
       LDA    frameCounter 
       AND    $93 
       BNE    LRTS1
       INC    $C7 
       LDA    $C7 
       SEC
       SBC    #$0C 
       STA    $AF 
       RTS

    ;Branch here is $C7 == 0x87
LF188: LDX    $B9 
       LDA    #$05 
       STA    $80,X
LF18E: LDY    $CA 
       LDA    $91 
       BNE    LF1C9
       LDX    $A2 
       LDA    #$31 
       STA    $8A 
       LDA    $CF,X
       ORA    LFF12,Y
       STA    $CF,X
       CMP    #$FF 
       BNE    LF1C9
       STA    $CB 
       LDX    #$07 
LF1A9: LDA    $80,X
       AND    #$0F 
       CMP    #$04 
       BNE    LF1B3
       INC    $80,X
LF1B3: DEX
       BPL    LF1A9
       BMI    LF1C9
LF1B8: LDA    $BA 
       CMP    #$32 
       BEQ    LF18E
       JSR    LFD2F
       LDA    #$05 
       STA    $9A 
       LDA    #$02 
       STA    $99 
LF1C9: LDA    #$64 
       STA    $CA 
       STA    $B9 
       LDA    #$00 
       STA    $CD 
       STA    $AF 
       RTS

LF1D6: JSR    LFC7B
       LDY    $B8 
       LDX    LFF06,Y
       LDA    frameCounter 
       AND    $93 
       BNE    LF208
       LDA    $89 
       BNE    LF208
       CPY    #$05 
       BEQ    LF1F0
       CPX    #$00 
       BNE    LF208
LF1F0: INC    $E3 
        ;if $AD < $B0
       LDA    $B0 
       CMP    $AD 
       BCC    LF1FC
        ;then
       DEC    $E3 
       DEC    $E3 
LF1FC: INC    $E0,X
       LDA    $A5 
       CMP    $A6 
       BCS    LF208
       DEC    $E0,X
       DEC    $E0,X
LF208: INC    $E4 
       LDA    frameCounter 
       AND    #$07 
       BNE    LRTS2
       DEC    $C8 
       DEC    $AE 
       DEC    $E2 
       LDA    $8B 
       BPL    LF21E
       INC    $C8 
       INC    $C8 
LF21E: LDA    $98 
       BMI    LRTS2
       INC    $E2 
       INC    $E2 
LRTS2: RTS

LF227: LDA    $91 
       BEQ    LF230
       LDA    #$01 
       STA    $CC 
       RTS

LF230: LDX    #$08 
       LDA    $B4 
       BNE    LRTS2
LF236: LDA    LFE8E,X
       CMP    JOYSTICK 
       BEQ    LF240
       DEX
       BNE    LF236
LF240: LDA    LFE97,X
       STA    $93 
       LDA    LFEA0,X
       TAX
       CMP    $CC 
       BEQ    LF25F
       LDA    frameCounter 
       AND    #$0F 
       BNE    LF261
       LDA    #$FF 
       STA    $B5 
       CPX    #$00 
       BEQ    LF25F
       LDA    #$00 
       STA    $E6 
LF25F: STX    $CC 
LF261: LDA    $CD 
       CMP    #$03 
       BNE    LF26F
       LDA    #$82 
       CMP    $AD 
       BCS    LF26F
       STA    $AD 
LF26F: LDA    $AD 
       CMP    #$19 
       BNE    LF27B
       LDA    frameCounter 
       AND    #$1F 
       BNE    LF2BB
LF27B: LDY    #$00 
       LDX    $A2 
       LDA    LFEE6,X
       AND    SWCHB
       BEQ    LF288
       INY
LF288: STY    $94 
        ; if frameCounter shares bits with $94
       LDA    frameCounter 
       AND    $94   ;Could have used BIT here too.
       BNE    LF297
        ; then $AD += $93
       LDA    $AD 
       CLC
       ADC    $93 
       STA    $AD 
LF297: LDA    $AD 
       CMP    #radar1VerPos 
       BCC    LF2B5
       LDA    #$AA 
       STA    $AD 
       LDA    #$00 
       STA    $B1 
       STA    $E6 
       LDA    $88 
       BEQ    LF2B5
       LDA    #$3B 
       STA    $CB 
       LDA    $98 
       STA    $C8 
       STA    $AE 
LF2B5: LDA    $AD 
       BNE    LF2BB
       INC    $AD 
        ; if $CD == 3
LF2BB: LDA    $CD 
       CMP    #$03 
       BNE    LF2E7
        ; and $CA == $CE
       LDA    $CA 
       CMP    $CE 
       BNE    LF2E7
        ; then $C7 = $AD - 0x0F
       ; $AF = $C7 = $AD - 0x0f
       LDA    $AD 
       SEC
       SBC    #$0F 
       STA    $C7 
       STA    $AF 
       ;If $8B = 5 then X=1 else X=5
       LDX    #$05 
       CPX    $8B 
       BEQ    LF2D8
       LDX    #$01 
       ; $93 = X
LF2D8: STX    $93 
    ; $A4 = $A5 + $93
       LDA    $A5 
       CLC
       ADC    $93 
       STA    $A4 
       ; $C6 = $A4 / 2 + 0x58
       LSR 
       CLC
       ADC    #$58 
       STA    $C6 
LF2E7: RTS

LF2E8: LDA    $CC 
       STA    $94 
       CMP    #$01 
       BNE    LF2F4
       LDX    #$05 
       STX    $8B 
LF2F4: CMP    #$FF 
       BNE    LF2FC
       LDA    #$FB 
       STA    $8B 
LF2FC: LDA    $8B 
       LDX    #$00 
        ; If $89 == 5
       STX    $89 
       CMP    #$05
       BNE    LF321
        ; then go until RTS.
       STX    REFP0
       LDA    $B4 
       BNE    LRTS3
       LDA    $A5 
       CMP    #$1F 
       BCC    LRTS3
       LDA    frameCounter 
       AND    #$01 
       BNE    LF31A
       DEC    $A5 
LF31A: LDA    #$01 
       STA    $89 
       STA    $94 
       RTS

;
; Steer the ship, I think.
;
LF321: LDY    #$FF
       STY    REFP0   ;Yup, that'll rvs the ship.
        ; if $B4 == 0
       LDA    $B4 
       BNE    LRTS3
        ; and $A5 < 0x82
       LDA    $A5 
       CMP    #$82 
       BCS    LRTS3
        ; and frameCounter & 1
       LDA    frameCounter 
       AND    #$01 
       BNE    LF337
        ; then...
       INC    $A5 
LF337: STY    $89 
       STY    $94 
LRTS3: RTS

LF33C: LDA    $B4 
       BNE    LRTS3
       LDA    $8B 
       STA    $95 
       LDA    $89 
       BEQ    LF362
       LDX    #$05 
       CPX    $95 
       BNE    LF350
       LDX    #$FF 
LF350: STX    $95 
       LDA    #$00 
       CMP    $B6 
       BEQ    LF362
       CMP    $CC 
       BEQ    LF370
       CMP    $B5 
       BEQ    LF362
       STA    $94 
LF362: LDA    $94 
       BEQ    LF370
       LDA    $B6 
       CMP    #$30 
       BEQ    LF38C
       INC    $B6 
       BNE    LF38C
LF370: LDA    $B6 
       BEQ    LRTS6
       DEC    $B6 
       LDA    $B6 
       BNE    LF37C
       STA    $B5 
LF37C: LDA    $94 
       BNE    LF38C
       LDX    #$01 
       LDA    $95 
       CMP    #$05 
       BEQ    LF38A
       LDX    #$FF 
LF38A: STX    $94 
LF38C: LDA    $B6 
       BEQ    LRTS6
       SED
       CLC
       ADC    #$0D 
       LSR 
       LSR 
       LSR 
       LSR 
       CLD
       TAX
       LDA    frameCounter 
       AND    LFEB5,X
       BNE    LRTS6
       LDA    $94 
       BMI    LF3C9
       DEC    $C9 
       DEC    $C9 
       DEC    $C8 
       LDA    $CD 
       BMI    LF3B1
       DEC    $C6 
LF3B1: LDX    #$03 
LF3B3: LSR    CITYGFX+8,X     ; 0->[  DC  ] -.
       ROL    CITYGFX+4,X     ; ,- [  D8  ]<-'
       ROR    CITYGFX,X       ; `->[D4]---.
       LDA    CITYGFX,X       ; ,---------'
       AND    #$08            ; |
       BEQ    LF3C5           ; |
       LDA    CITYGFX+8,X     ; |
       ORA    #$80            ; `->[  DC  ] -.
       STA    CITYGFX+8,X
LF3C5: DEX
       BPL    LF3B3
LRTS6: RTS

LF3C9: INC    $C9 
       INC    $C9 
       INC    $C8 
       LDA    $CD 
       BMI    LF3D5
       INC    $C6 
LF3D5: LDX    #$03 
    ; This routine performs a 20-bit rotate
LF3D7: CLC
       ROL    CITYGFX,X      ;     ,- [D4] <- 0
       ROR    CITYGFX+4,X    ;     `->[D8    ] -.
      ROL    CITYGFX+8,X ;     ,- [DC    ]<-'
       BCC    LF3E6          ;     `-----------.
       LDA    CITYGFX,X      ;                 |
       ORA    #$10           ; Start at bit 4  |
       STA    CITYGFX,X      ;        [D4] <---'
LF3E6: DEX ;Repeat for all four lines of city gfx.
       BPL    LF3D7
       RTS

LF3EA: LDA    $91 
       BEQ    LF3F6
       LDA    $8D 
       BEQ    LF3F6
       LDA    $3C;INPT4
       BPL    LF3FC
    ; if RESET pressed
LF3F6: LDA    SWCHB
       ROR 
       BCS    LF40C
    ; then....
LF3FC: LDA    bcdGameVariant 
       BPL    LF404
       INC    bcdGameVariant 
       INC    bcdGameVariant 
LF404: JSR    LFD3B
       JSR    LFD1C   ; $8d = 0x78, $91 = 0x80
       BEQ    LF444
    ; if SELECT not pressed
LF40C: ROR 
       BCC    LF415
    ; then...
       LDX    #$01 
       STX    $E7 
       BNE    LF444
LF415: JSR    LFD17  ; $91 = 0xFF
       JSR    LFDE3
       DEC    $E7 
       BPL    LF444
       LDA    #$2D 
       STA    $E7 
       LDA    bcdGameVariant 
       BPL    LF429
       INC    bcdGameVariant 
LF429: 
       LDA    bcdGameVariant        
       SED                          ; BCD on
       CLC                          ;
       ADC    #$01                  ;
       STA    $9B                   ; Switch to next game variant
       LDX    #$78                  ; 
       STX    $8D                   ;
       LDX    #$00                  ;
       STX    frameCounter          ; Reset frame counter
       STX    $A2                   ;
       CMP    #$21                  ; Reached variant *21*?
       BCC    StoreNewVariant       ; N: Accept new variant
       LDA    #$01                  ; Y: Start over with variant *1*
       STA    bcdGameVariant        ; Store new variant
StoreNewVariant:
       CLD
LF444: LDA    #$10 
       STA    NUSIZ0  ; Single-width players,
       STA    NUSIZ1  ; quad-width missiles.
       LDX    gameColors 
       STX    COLUBK
       LDX    #$05   ; Ball 1 clock wide
       LDA    frameCounter 
       AND    #$0F 
       BNE    LF458
       LDX    #$25   ; Ball 4 clocks wide
LF458: STX    CTRLPF ; Reflect PLF, over players
       RTS

LF45B: LDA    $8D 
       BNE    LF463
       LDA    #$FF 
       STA    $91   ;could have done JSR LFD17 ???
LF463: LDA    frameCounter 
       BNE    LF474
       INC    $8C 
       LDA    $91 
       BNE    LF474
       DEC    $8D 
       BPL    LF474
       JSR    LFD17  ;$91 = 0xFF
LF474: LDA    SWCHB
       LDY    #$F7 
    ; If B&W, X=0x0F.  If Color, X=0xFF.
       LDX    #$0F 
       AND    #$08  ;COLOR/B&W
       BEQ    LF481
       LDX    #$FF 
LF481: LDA    $91 
       BMI    LF487
       LDY    #$FF 
LF487: AND    $8C 
       STA    $95 
       STX    $96 
       STY    $97 
       LDX    #$06 
LF491: LDA    colortable,X
       EOR    $95 
       AND    $96 
       AND    $97 
       STA    gameColors,X
       DEX
       BPL    LF491
       STA    CXCLR
       RTS

LF4A2: LDX    #$00 
       LDY    #$00 
       STX    AUDV0
       LDA    $91 
       BNE    LF503
       LDA    $CB 
       CMP    #$97 
       BEQ    LF4F8
       BCC    LF4C5
    ; for Y = 7 to 0 step -1
       LDY    #$07 
    ; X = $98 & 7
LF4B6: LDA    $98 
       AND    #$07 
       TAX
    ; gameColors [Y] = gameColors [X]
       LDA    gameColors,X
       STA.wy $00E8,Y
    ; next Y
       DEY
       BPL    LF4B6
    ; goto LF4FA
       BMI    LF4FA
LF4C5: LDA    $B4 
       BNE    LF4FC
       LDA    $CB 
       CMP    #$3C 
       BCS    LF508
       LDA    $CD 
       BPL    LF4E6
       LDA    $AF 
       CMP    #$04 
       BCS    LF4E6
       LDX    #$05 
       LDA    $98 
       AND    #$37 
       TAY
       LDA    #$0E 
       STA    AUDV0
       BNE    LF503
LF4E6: LDA    $8A 
       BEQ    LF520
       DEC    $8A 
       CMP    #$20 
       BCS    LF4FA
       CMP    #$1F 
       BNE    LF517
       STX    $8A 
       BEQ    LF503
LF4F8: STX    $CB
    ; End skipped code 
LF4FA: LDA    $98
LF4FC: AND    #$3F 
       TAY
LF4FF: LDX    #$08 
LF501: STX    AUDV0
LF503: STX    AUDC0
       STY    AUDF0
       RTS

LF508: LDA    frameCounter 
       AND    #$2F 
       TAY
       LDX    #$01 
       LDA    #$0A 
       STA    AUDV0
       LDA    $D1 
       BEQ    LF503
LF517: LDA    frameCounter 
       AND    #$22 
       TAY
       LDX    #$0E 
       BNE    LF501
LF520: LDA    $AD 
       CMP    #$AA 
       BNE    LF52A
       LDA    $CB 
       BNE    LF4FA
LF52A: LDA    $E5 
       BNE    LF4FA
       LDA    $CB 
       BNE    LF540
       LDA    JOYSTICK 
       CMP    #$F0 
       BEQ    LF540
       LDY    #$30 
       LDX    #$08 
       LDA    #$03 
       STA    AUDV0
LF540: LDA    $E6 
       BEQ    LF549
       ROL 
       ROL 
       TAY
       BNE    LF4FF
LF549: LDA    $B2 
       CMP    #$38 
       BEQ    LF4FA
       BNE    LF503
LF551: LDA    $C0 
       BEQ    LF55D
       LDA    $8D 
       BEQ    LF55D
       LDA    $91 
       BNE    LF5C8
LF55D: LDY    $A2 
       LDA    $9A 
       BEQ    LF582
       TAX
LF564: LDA    $9D 
       CLC
       ADC    LFFDB,Y
       STA    $9D 
       DEX
       BNE    LF564
       STX    $9A 
       AND    LFFD9,Y
       CMP    LFFD5,Y
       BNE    LF582
       INC    $99 
       LDA    $9D 
       AND.wy PLYRJOY,Y
       STA    $9D 
LF582: LDA    $99 
       BEQ    LF5FE  ;was LF5FE, assembler hated it.
       DEC    $99 
       LDX    #$02 
LF58A: LDA    $9C,X
       CLC
       ADC    LFFDB,Y
       STA    $9C,X
       AND    LFFD9,Y
       CMP    LFFD7,Y
       BNE    LF5A1
       LDA    $9C,X
       AND    LFFDF,Y
       STA    $9C,X
LF5A1: AND    LFFD9,Y
       CMP    LFFD5,Y
       BNE    LF5FE
       LDA    $9C,X
       AND    PLYRJOY,Y
       STA    $9C,X
       INX
       CPX    #$04 
       BNE    LF5B8
       JSR    LFD25
LF5B8: CPX    #$06 
       BNE    LF58A
       DEX
LF5BD: LDA    $9C,X
       AND    LFFE1,Y
       STA    $9C,X
       DEX
       BPL    LF5BD
LRTS9: RTS

LF5C8: LDX    #$0A 
       STX    $9D 
       STX    $9C 
       LDY    #$04 
LF5D0: INX
       STX    $9C,Y
       DEY
       BPL    LF5D0
       LDA    bcdGameVariant 
       BMI    LF5FE
       LDA    $C0 
       BEQ    LF5FE
       JSR    LFE09
       STA    $9D 
       LDA    bcdGameVariant 
       LDX    #$01 
       CMP    #$11 
       BCC    LF5EC
       INX
LF5EC: STX    $9C 
       AND    #$0F 
       STA    $A0 
       ; IF bcdGameVariant & 0xF0
       LDA    bcdGameVariant 
       AND    #$F0 
       BEQ    LF5FE
       ; then $A1 = bcdGameVariant >> 4
       LSR 
       LSR 
       LSR 
       LSR 
       STA    $A1 
LF5FE: RTS

LF5FF: LDA    $A5 
       STA    $95 
       LDA    $B1 
       CMP    #$60 
       BNE    LF610
       ;$A5 -= $8B
       LDA    $A5 
       SEC
       SBC    $8B 
       STA    $A5 
LF610: LDA    frameCounter 
       AND    #$1F 
       BEQ    LRTS7
       LDA    $E6 
       BEQ    LRTS7
       STA    $A5 
       JSR    LFD34
       LDA    #$6B 
       STA    $B1 
       LDA    #$1F    ;player quad width. missile 8 pixels
       STA    NUSIZ0 
LRTS7: RTS

LF628: LDA    $D1 
       BEQ    LRTS4
       LDA    $CB 
       CMP    #$01 
       BEQ    LRTS4
       LDA    #$64 
       STA    $B0 
       LDA    #$5D 
       STA    $AD 
       LDX    #$46 
       LDA    frameCounter 
       AND    #$01 
       BNE    LF644
       LDX    #$4E 
LF644: STX    $A5 
       STX    $A6 
       LDA    $EC 
       STA    $8E 
       LDA    gameColors 
       STA    $8F 
       LDA    #$52 
       STA    $B1 
       LDA    enemyWave 
       CPX    #$4E 
       BEQ    LF665
       LSR 
       LSR 
       LSR 
       LSR 
       BNE    LF665
       LDA    #$85 
       STA    $B2 
       RTS
LF665: AND    #$0F 
       TAX
       LDA    DIGIND,X
       STA    $B2 
LRTS4: RTS

    ; if $B0 > 128
LF66E: LDA    #$80 
       CMP    $B0 
       BCS    LF676
    ; then $B0 = 128
       STA    $B0 
LF676: LDX    #$04 
       LDA    $A4 
       BEQ    LF68A
       STA    $A7 
    ; if $CA==$CE then $AF=$AB
       LDY    #$FF 
       LDA    $CA 
       CMP    $CE 
       BNE    LF688
       LDY    $AF 
LF688: STY    $AB 
    ;
    ; The divide-by-15 routine uses a simple technique:
    ; subtract 15 until you run out of 15s.  This is
    ; such a time-consuming task that if the number                 
    ; strays from a certain range, the routine could
    ; take a variable number of scanlines, causing the
    ; entire picture beneath it to shift as objects
    ; move.  The following lines of code circumvent this
    ; problem by subtracting the first 75 all at once.
    ;
LF68A: LDY    #$00 
       LDA    $A5,X  ;$A5 is an array of X positions
    ; if A > 82 then A-=75 : Y=5
       CMP    #$52
       BCC    LF696
       SBC    #$4B 
       LDY    #$05 
LF696: CPX    #$02   ;a CLC would have sufficed.
       ADC    #$02 
    ; Do (Y++; A-=15) while A>14
LF69A: INY           ; +2 }
       SBC    #$0F   ; +2 } * up to 10, -1
       BCS    LF69A  ; +3 }
    ; A = -A - 8
       EOR    #$FF ;
       SBC    #$06 ;
    ; Move low bits to where HMove will see it.
       ASL           ; Get a head-start
       STA    WSYNC ;BEGIN COUNT
       ASL                 ; (0) +2
       ASL                 ; (2) +2
       ASL                 ; (4) +2
       STA    HMP0,X ; (6) +4  Fine-tuning register
    ; DEY-BPL to get exact distance.
LF6AB: DEY                ; }(10)
       BPL    LF6AB  ; } + Y*5 +4
       STA    RESP0,X ; *14+5Y* +4
       DEX
       BPL    LF68A   ;Do players 1 and 0
    ; Now to fine-tune the players.
       STA    WSYNC   ;COUNT
       STA    HMOVE   ;  (0) +3
       LDY    #$05    ;  (3) +2
LF6B9: DEY            ; }(5)
       BPL    LF6B9   ; }    +29 
       STA    HMCLR   ; *34* Clear horizontal motion
       STA    WSYNC 
       STA    HMOVE   ;I don't know why a seocnd hmove?
       LDA    $95 
       STA    $A5
       RTS

    ; Take this time to convert BCD score into
    ; 0xFF5F+(digit*8)
LF6C7: LDY    #$00 
       LDX    #$00 
LF6CB: LDA    $9C,X
       STX    $93 
       LDX    $A2 
       BEQ    LF6D7
       LSR 
       LSR 
       LSR 
       LSR 
LF6D7: AND    #$0F 
       LDX    $93 
       STA    $94 
       ASL 
       ASL 
       ASL 
       SEC
       SBC    $94 
       CLC
       ADC    #$5F 
       STA.wy $00EF,Y
       LDA    #$FF 
       STA.wy $00F0,Y
       INY
       INY
       INX
       CPX    #$06 
       BNE    LF6CB
    ; Wait for timer to wink out
LF6F5: LDA    INTIM
       BNE    LF6F5

; Start main display Screen
                        
       STA    WSYNC		        ; Finish current line
       STA    VBLANK		    ; Stop blanking
       INC    frameCounter      ; A new frame!
       LDA    radarColor        ; A-> P1 objects color in radar
       STA    COLUP1            ; Set color of P1 objects
       LDA    enemyWave         ; A-> current enemy wave
       AND    #$03              ; Lowest two bits of wave...
       TAX                      ;
       LDA    gameColors+3,X    ; ...select radar frame color
       STA    WSYNC             ; Finish current line
       STA    COLUPF            ; Set radar frame color

       LDA    #$FF              ; Draw Top of radar...
       STA    PF2               ;
       LDA    #$01              ;
       STA    PF1               ; ...with the playfield

; Here the actual radar is drawn. Each radarline is two scannlines tall
; The radar shows only two object dots per frame

       LDY    #$0B              ; Do 11 radarlines
NextRadarLine 
       LDX    #$00              ; Assume no radar dot this line
       STA    WSYNC             ; Finish current line
       LDA    radarfocus,Y      ; A-> C0 v 00
       STA    PF2               ; Draw focus on top/bottom of radar
       CPY    radar1VerPos      ; Show radar dot this line?
       BNE    NoRadarDot        ; N: Show nothing
       DEX                      ; Y: Show dot
NoRadarDot
       STX    ENABL             ; En/Disable first dot
       STA    WSYNC             ; Finish current line
       LDX    #$00              ; Assume no radar dot this line
       CPY    radar2VerPos      ; Show radar dot this line?
       BNE    NoRadarDot2       ; N: Show nothing
       DEX                      ; Y: Show dot
NoRadarDot2
       STX    ENAM1             ; En/Disable second dot
       DEY                      ; All lines done?
       BPL    NextRadarLine     ; N: Do next line

       STA    WSYNC             ; Finish current line
       INY                      ; Y-> 00
       STY    ENAM0             ; Prevent bleeding of radar dots...
       STY    ENABL             ; ...in case they are still enabled.
       DEY                      ; Y-> FF
       STY    PF0               ;
       STY    PF1               ;
       STY    PF2               ; Draw playfield line accross screen
       LDY    #$0F 
       LDX    $A2 
       LDA    $CF,X
       LDX    $E9 
       CMP    #$FF 
       BNE    LF755
       LDY    #$00 
       LDX    gameColors 
LF755: STY    $97 
       STX    $96 
       LDA    $8F 
       STA    COLUP0
       LDA    $8E 
       STA    COLUP1
       LDA    #$F0 
       STA    CTRLPF
       LDY    #$84 
       STA    WSYNC
       ; Clear playfield
       LDA    #$00 
       STA    PF0
       STA    PF1
       STA    PF2
       ; Beginning of display loop.
       ; So that you see how tight code has to be,
       ; I am showing worst possible cycle counts.
LF771: LDA    #$00              ;(45)+2   (Retroactive branch)
       CPY    $B0               ;(47)+3
       BCS    LF780             ;(50)+2
       LDX    $B2               ;(52)+3
       LDA    GFXDATA,X         ;(55)+4
       BEQ    LF780             ;(59)+2
       DEC    $B2               ;(61)+5
LF780: CPY    $AD               ;(66)+3
       LDX    $B1               ;(70)+3 == *73* CYCLES!
       STA    WSYNC             ;BEGIN COUNT  (longest-case)
       STA    GRP1              ;*0* +3
       BCS    LF795             ;(3) +2    If no branches taken
       LDA    SHIPGFX,X         ;(5) +4
       CMP    #$F0              ;(9) +2
       BEQ    LF795             ;(11)+2 
       STA    GRP0              ;(13)+3
       DEC    $B1               ;(16)+5
LF795: LDX    #$01              ;(21)+2 
       TYA                      ;(23)+2 
       SBC    $AB               ;(25)+3
       AND    $92               ;(28)+3
       BNE    LF79F             ;(31)+2 
       INX                      ;(33)+2
LF79F: STX    ENAM0             ;*35*+3 
       DEY                      ;(37)+2
       CPY    $97               ;(39)+3
       BNE    LF771             ;(42)+3  (Must take branch to continue)
       LDA    $96
       STA    COLUPF
       LDX    #$00 
       STX    GRP0     ; Clear ship graphics.
       ; This display loop does not include the ship, which is
       ; why the ship is not visible in the cityscape, which we're
       ; about to draw now.
       
    ; X = Y/4
LF7AE: TYA
       LSR 
       LSR 
       STA    WSYNC
       TAX
       ; Copy appropriate graphics into playfield.
       LDA    CITYGFX,X
       STA    PF0
       LDA    CITYGFX+4,X
       STA    PF1
       LDA    CITYGFX+8,X
       STA    PF2
       ; $93 = Y/4
       STX    $93 
       LDX    #$01 
       TYA
       SBC    $AB 
       AND    $92 
       BNE    LF7CC
       INX
LF7CC: STX    ENAM0
       LDX    $93 
       DEY
       BPL    LF7AE
       STA    WSYNC
       LDA    #$00 
       STY    PF0
       STY    PF1
       STY    PF2
       LDX    #$01 
       STX    CTRLPF
       LDY    $EE 
       STA    WSYNC
       STY    COLUBK
       STA    ENAM0  ;Disable missile 0.
       STA    GRP1
       STY    COLUP1
       STA    PF0
       STA    PF1
       STA    PF2
       STA    REFP0
        ; Set both players to triple
       LDA    #$03 
       STA    NUSIZ0
       STA    NUSIZ1
       LDY    #$06 
       STX    VDELP0
       STX    VDELP1
       STY    $93 
       STY    WSYNC
LF805: DEY
       BPL    LF805
       NOP
       STA    RESP0
       STA    RESP1
       LDA    #$F0 
       STA    HMP0
       STA    WSYNC
       STA    HMOVE
       LDY    #$FE 
       LDA    gameColors 
       STA    COLUPF
       STA    WSYNC
       STY    PF2
       LDX    $EC 
       STX    COLUP0
       STX    COLUP1
LF825: LDY    $93     ;                   (61) +3
       LDA    ($F9),Y ;   p0  p1          (64) +5
       STA    GRP0    ;   F9              (69) +3
       STA    WSYNC   ; Cycle count begins
       LDA    ($F7),Y ;                   (0) +5
       STA    GRP1    ;       F7          (5) +3
       LDA    ($F5),Y ;                   (8) +5
       STA    GRP0    ;   F5              (13) +3
       LDA    ($F3),Y ;                   (16) +5
       STA    $94     ;                   (21) +3
       LDA    ($F1),Y ;                   (24) +5
       TAX            ;                   (29) +2
       LDA    ($EF),Y ;                   (31) +5
       TAY            ;                   (36) +2
       LDA    $94     ;                   (38) +3
       STA    GRP1    ;       F3          (41) +3
       STX    GRP0    ;   F1              (44) +3
       STY    GRP1    ;       EF          (47) +3
       STA    GRP0    ;   F3              (50) +3
       DEC    $93     ;                   (53) +5
       BPL    LF825   ; Branch taken, so  (58) +3
    ; End six-digit loop
       LDA    #$00 
       STA    VDELP0  ;Clear vertical delays
       STA    VDELP1 
       STA    GRP0    ;Clear players
       STA    GRP1
       STA    HMP0    ;Clear missiles.
       STA    WSYNC   ;               Cycle count:
       STA    PF2     ;Clear PF2       [0]
       LDA    $EA     ;                [3]
       STA    COLUP0  ;                [6]
       STA    COLUP1  ;                [9]
       LDY    #$08    ;                [12]
       STA    RESP0   ;                *14*
LF867: DEY            ;When 8 (17), when 0 (57)
       BNE    LF867   ;At end of loop, (59)
       STA    RESP1   ;                (61)
    ; End result: player 0 is at 0, player 1 is at 120.
       INY                ; Y = 1
       STA    WSYNC
       ; The following code amounts to this:
      ; for Y= 1 to 0 step -1
      ;  X=$C0 [Y] 
      ;  Value for repeat register is indexed from LFEDE
      ;  If number is 0 then do not display that icon.
      ; next Y
LF86F: LDX    #$03 
       LDA.wy $C0,Y
       CMP    #$03 
       BCS    LF879
       TAX   ;X = $00C0,Y
LF879: LDA    LFEDE,X
       STA.wy NUSIZ0,Y  ;NUSIZ registar for player Y
       LDA    LFEE2,X
       STA.wy $96,Y    ;AND mask, to be or not to be.
       DEY
       BPL    LF86F ; Repeat for both players.
       ;
       LDX    #$0B   ;X is separate so that the programmer
             ;can be a lazy girly-man and index from
             ;SHIPGFX instead of SHIPGFX+6.
       LDY    #$05 
LF88C: STA    WSYNC
       LDA    SHIPGFX,X  ;Get ship graphics
       AND    $96   ; Only display if $C0 > 0
       STA    GRP0
       LDA    BOMBGFX,Y  ;Get bomb graphics
       AND    $97   ; Only display if $C1 > 0
       STA    GRP1
       DEX
       DEY
       BPL    LF88C ; Go until Y runs out.
       ; Set timer
       LDA    #$26 
       STA    TIM64T
       ; Reset stack pointer (is it ever used?)
       LDX    #$FF 
       TXS           
       JMP    LF04F
LF8AB: INC    $BB 
       LDA    $BB 
       AND    #$07 
       STA    $BB 
       TAX
       JSR    LFCA0  ; Y = A = $80 [X] AND 0x0F
       STA    $93 
       INY
       LDA    $80,X
       AND    #$F0 
       BEQ    LF8C2
       LDY    #$00 
LF8C2: LDA    $00E8,Y
       STA    $90 
       LDY    $93 
       LDA    $CD 
       BEQ    LF8D6
       CPX    $B9 
       BNE    LF8D6
       LDA    $C6 
       JMP    LF8D9
LF8D6: JSR    LFCB5
LF8D9: LSR 
       LSR 
       CLC
       ADC    #$2F 
       STA    $A8 
       LDA    $CD 
       BEQ    LF8ED
       CPX    $B9 
       BNE    LF8ED
       LDA    $C7 
       JMP    LF8F0
LF8ED: JSR    LFCCA
LF8F0: LSR 
       LSR 
       LSR 
       LSR 
       CLC
       ADC    #$02 
       STA    radar2VerPos 
       LDY    $A2 
       LDA    #$FF 
       STA    radar1VerPos 
       CMP.wy $00CF,Y
       BEQ    LF949
       INC    $CE 
       LDA    $CE 
       CMP    #$05 
       BCC    LF910
       LDA    #$00 
       STA    $CE 
LF910: TAX
       LDA.wy $00CF,Y
       AND    LFF12,X
       BNE    LF949
       LDA    $C9 
       CLC
       ADC    TIMES40,X
       LSR 
       LSR 
       CLC
       ADC    #$30 
       STA    $A9 
       LDA    #$01 
       STA    radar1VerPos 
       LDA    $CD 
       BEQ    LF949
       LDA    $CA 
       CMP    $CE 
       BNE    LF949
       LDA    $CD 
       BMI    LF949
       LDA    $C7 
       LSR 
       LSR 
       LSR 
       LSR 
       STA    radar1VerPos 
       LDA    $C6 
       LSR 
       LSR 
       CLC
       ADC    #$30 
       STA    $A9 
LF949: LDA    frameCounter 
       AND    #$0F 
       BNE    LF968
       LDA    #$FF 
       STA    $CE 
       LDA    $AD 
       LSR 
       LSR 
       LSR 
       LSR 
       STA    radar1VerPos 
       LDA    $A5 
       LSR 
       CLC 
       ADC    #$58 
       LSR 
       LSR 
       CLC
       ADC    #$2F 
       STA    $A9 
LF968: RTS

LF969: LDA    #$00 
       STA    $A4 
       LDY    $A2 
       LDA    $00CF,Y
       CMP    #$FF 
       BEQ    LF9A1
       AND    LFF12,X
       BNE    LF9A1
       LDA    $C9 
       CLC
       ADC    TIMES40,X
       CPX    $CA 
       BNE    LF98D
       LDY    $CD 
       BPL    LF98B
       STA    $C6 
LF98B: LDA    $C6 
LF98D: CMP    #$59 
       BCC    LF9A1
       CMP    #$A8 
       BCS    LF9A1
       SEC
       SBC    #$58 
       STA    $94 
       CLC
       ADC    $94 
       ADC    #$02 
       STA    $A4 
LF9A1: RTS

LF9A2: LDY    #$07 
       STY    $94 
       LDA    $A6 
       STA    $95 
       LDA    $B7 
       STA    $96 
       LDA    $B0 
       STA    $97 
LF9B2: INC    $B7 
       LDA    $B7 
       AND    #$07 
       STA    $B7 
       TAX
       LDA    $80,X
       BMI    LF9D3
       AND    #$0F 
       TAY
       JSR    LFCB5
       CPX    $B9 
       BNE    LF9CB
       LDA    $C6 
LF9CB: CMP    #$59 
       BCC    LF9D3
       CMP    #$A5 
       BCC    LF9E0
LF9D3: DEC    $94 
       BPL    LF9B2
       LDA    #$FF 
       STA    $B7 
       LDA    #$00 
       STA    $A6 
       RTS

LF9E0: JSR    LFCCA
       CPX    $B9 
       BNE    LF9E9
       LDA    $C7 
LF9E9: STA    $B0 
       JSR    LFCB5
       CPX    $B9 
       BNE    LF9F4
       LDA    $C6 
LF9F4: SEC
       SBC    #$58 
       ASL 
       STA    $A6 
       RTS

LF9FB: JSR    LFDEE
       LDX    $B7 
       BMI    LFA4E
       STY    $B8 
       INY
       LDA    $00E8,Y
       STA    $8E 
       DEY
       LDA    TIMES8,Y
       STA    $B2 
       LDA    $CD 
       CMP    #$03 
       BNE    LFA24
       LDA    #$25 
       CMP    enemyWave 
       BNE    LFA24
       CMP    $AD 
       BCC    LFA24
       LDA    #$AE 
       STA    $B2 
LFA24: LDA    $80,X
       AND    #$10 
       BEQ    LFA4E
       LDA    #$38 
       STA    $B2 
       CPX    $B9 
       BNE    LFA34
       STA    $B9 
LFA34: JSR    LFCA0
       LDA    #$80 
       STA    $80,X
       CPY    #$02 
       BNE    LFA4E
       LDA    $E5 
       BNE    LFA4E
       INY
       STY    $80,X
       STA    $B2 
       LDA    $80 
       BPL    LFA4E
       STY    $80 
LFA4E: RTS

LFA4F: LDA    $91 
       BNE    LFABF
       LDA    $B4 
       BNE    LFA90
       STA    $93 
       LDA    $E6 
       BNE    LFA4E
       LDA    $30
       AND    #$40 ; M0 - P0
       BEQ    LFA7E
       LDX    $92 
       CPX    #$FC 
       BNE    LFA7C
       STA    $B9 
       LDX    $CD 
       CPX    #$02 
       BNE    LFA7C
       INC    $CD 
       LDX    #$05 
       STX    $99 
       JSR    LFD2F
       LDA    #$00   ;Clear collision
LFA7C: STA    $93 
LFA7E: LDA    $37
       BPL    LFA84  ;Branch if players don't collide
       STA    $93    ;Mark collision
LFA84: LDA    $93 
       BEQ    LFA90
       LDA    #$00 
       STA    $B6 
       LDA    #$1E 
       STA    $B4 
LFA90: LDY    $B4 
       BEQ    LRTS5
       LDA    frameCounter 
       AND    #$03 
       BNE    LFA9C
       DEC    $B4 
LFA9C: JSR    LFD34
       CPY    #$05 
       BCS    LRTS5
       LDA    LFE89,Y
       STA    $B1 
       LDA    $B4 
       BNE    LRTS5
       JSR    LF1C9
       LDA    #$32 
       STA    $CB 
       JSR    LFCAC
       LDX    $A2 
       DEC    $C2,X
       BNE    LFABF
       JSR    LFCEB
LFABF: LDA    $C2   ;Any lives left, player 1?
       BNE    LRTS5
       LDA    bcdGameVariant 
       CMP    #$11 
       BCC    LFAD9
       LDA    $C3   ;Any lives left, player 2?
       BNE    LRTS5
       LDA    frameCounter
       AND    #$1F 
       BNE    LFAD9
       LDA    $A2 
       EOR    #$01 
       STA    $A2 
LFAD9: JSR    LFD17
LRTS5: RTS

;
; Notice that LDA is used here in order to test bit 7.
; Combat, which predates Defender by four years, uses
; BIT. 
;
; This routine is only executed when $91 equals zero.
;
LFADD: LDX    $96 
       LDA    $B2 
       CMP    #$38 
       BEQ    LFB36
       LDA    $80,X 
       BMI    LFAED
       LDA    $37 ;Collision between players & missiles
       BMI    LFB02
LFAED: LDA    $E5 
       BEQ    LFB36
       LDA    $99 
       BNE    LFB36
       LDX    $B7 
       BPL    LFB02
       LDX    $A2 
       DEC    $C4,X
       LDA    #$00 
       STA    $E5 
       RTS

LFB02: JSR    LFCA0
       LDA    #$00 
       STA    $E6 
       LDA    LFEFA,Y
       STA    $9A 
       LDA    LFF00,Y
       STA    $99 
    ; Set bit 4 across $80 field.
       LDA    $80,X
       ORA    #$10 
       STA    $80,X
       CPX    $B9 
       BNE    LFB36
       LDA    $CD 
       BPL    LFB28
       LDA    $AF 
       BPL    LFB28
       INC    $CD 
       RTS

LFB28: LDA    #$02 
       STA    $CD 
       STA    $BA 
       LDA    #$32 
       CMP    $C7 
       BCS    LFB36
       STA    $BA 
LFB36: RTS

;
; This routine is called only when $91 equals zero.
;
LFB37: LDA    $B4 
       BNE    LFB8F
       LDX    $A2 
       LDA    $3C,X
       BPL    LFB4A
       LDA    #$00 
       STA    $88 
LFB45: LDA    $E6 
       BNE    LFB69
       RTS

LFB4A: LDA    $88 
       BNE    LFB45
       JSR    LFD1C
       DEC    $88 
       LDA    #$14 
       CMP    $AD 
       BCS    LFB83
       LDA    $A5 
       SEC
       SBC    #$02 
       STA    $E6 
       LDX    $8B 
       BPL    LFB69
       SEC
       SBC    #$17 
       STA    $E6 
LFB69: LDX    #$07 
       LDA    $8B 
       BPL    LFB71
       LDX    #$F9 
LFB71: TXA
       CLC
       ADC    $E6 
       TAX
       CMP    #$82 
       BCS    LFB7E
       CMP    #$00 
       BCS    LFB80
LFB7E: LDX    #$00 
LFB80: STX    $E6 
       RTS

; if ($C1 != 0 && $B7 != 0xFF)
;       $E5 = 0xFF
;       
LFB83: LDA    $C1 
       BEQ    LFB8F
       LDA    #$FF 
       CMP    $B7 
       BEQ    LFB8F
       STA    $E5 
LFB8F: RTS

LFB90: LDX    #$A0 
       LDY    #$00 
       LDA    #$FC 
       STA    $92 
       LDA    $A4 
       BNE    LFC07
       LDA    $BF 
       BNE    LFBD2
       LDA    $B7 
       BMI    LFC07
       LDY    $B8 
       CPY    #$02 
       BEQ    LFC07
       LDX    #$01 
       LDA    $B0 
       STA    $BC 
       CMP    $AD 
       BCC    LFBB6
       LDX    #$FF 
LFBB6: STX    $BE 
       LDA    $8A 
       BNE    LFBBE
       INC    $8A               ;$8A = 1
LFBBE: LDA    $A6 
       STA    $BD 
       CMP    $A5
       BCC    LFBC8
       LDX    #$FE 
LFBC8: STX    $BF 
       CPY    #$00 
       BNE    LFBD2
       LDA    #$F0 
       STA    $BF
    ; Branched here if $BF is zero. 
LFBD2: LDX    $BC
       LDY    $BD 
       CMP    #$F0 
       BNE    LFBE2
       LDA    frameCounter 
       AND    #$5A 
       BEQ    LFBFD
       BNE    LFC03
LFBE2: TXA
       CLC
       ADC    $BE 
       STA    $BC 
       CMP    #$0F 
       BCC    LFBFD
       TAX
       LDA    $BD 
       CLC
       ADC    $BF 
       STA    $BD 
       TAY
       LDA    $B4 
       BNE    LFBFD
       CPY    #$A0 
       BCC    LFC03
LFBFD: LDY    #$00 
       STY    $BF 
       LDX    #$A0 
LFC03: LDA    #$FE 
       STA    $92
    ;Branched here if $A4 or $B7 is zero. 
LFC07: STX    $AB
       STY    $A7 
       RTS

    ; for X=7 to 0 step -1
LFC0C: LDX    #$07 
LFC0E: LDA    $80,X
       BPL    LFC42
       DEX
       BPL    LFC0E
       LDA    #$00 
       TAY
       CLC
       ADC    $9A 
       ADC    $99 
       ADC    $B4 
       BNE    LFC42
       LDX    $A2 
       LDA    $CF,X
       LDX    #$07 
LFC27: ROR 
       BCS    LFC2B
       INY
LFC2B: DEX
       BPL    LFC27
       STY    $99 
       LDA    #$96 
       STA    $CB 
       STA    $D1 
       STA    $B9 
       LDA    $E5 
       BEQ    LFC42
       LDX    $A2 
       DEC    $C4,X
       INC    $E5 
LFC42: RTS

LFC43: LDA    $D3 
       BEQ    LFC7A
       LDA    $98 
       AND    #$07 
       TAX
       CPX    $B9 
       BEQ    LFC7A
       LDA    $80,X
       BPL    LFC7A
       LDY    $A2 
       LDA    $00CF,Y
       CMP    #$FF 
       BNE    LFC61
       LDY    #$05 
       BNE    LFC6B
LFC61: LDY    #$04 
       LDA    frameCounter 
       AND    #$1F 
       BNE    LFC6B
       LDY    #$01 
LFC6B: JSR    LFCB5
       CMP    #$59 
       BCC    LFC76
       CMP    #$A8 
       BCC    LFC7A
LFC76: STY    $80,X
       DEC    $D3 
LFC7A: RTS

LFC7B: JSR    LFCA6
       LDA    LFEC4,X
       STA    $93 
       CPX    #$00 
       BEQ    LFC9F
       LDX    enemyWave 
       STY    $97 
       LDY    #$01 
       CPX    #$07 
       BCC    LFC92
       DEY
LFC92: DEX
       BEQ    LFC9D
       CPY    $93 
       BEQ    LFC9D
       LSR    $93 
       BNE    LFC92
LFC9D: LDY    $97 
LFC9F: RTS

LFCA0: LDA    $80,X
       AND    #$0F 
       TAY
       RTS

LFCA6: LDA    bcdGameVariant 
       AND    #$0F 
       TAX
       RTS

;
; Clear radar1VerPos, $AB, and radar2VerPos with #$A0.
;
LFCAC: LDA    #$A0 
       STA    $AB 
       STA    radar2VerPos 
       STA    radar1VerPos 
       RTS

;
; IF LFF06[Y] = 3
;
LFCB5: STX    $93 
    ; X= LFF06 [Y]
       LDX    LFF06,Y
       LDA    #$00 
    ;if X <> 3
       CPX    #$03 
       BEQ    LFCC2
    ; then A=$E0 [X]
       LDA    $E0,X
    ; A += $C8 + $93 * 40
LFCC2: LDX    $93 
       ADC    $C8 
       ADC    TIMES40,X
       RTS

;
;If LFF0C[Y] = 3
;  A = ( $AE + $93 *40 ) / 2 + 24
;Else
;  A = ( $E3[X] + $AE + $93 *40 ) / 2 + 24
;
LFCCA: STX    $93 
       LDX    LFF0C,Y
       LDA    #$00 
       CPX    #$03 
       BEQ    LFCD7
       LDA    $E3,X
LFCD7: LDX    $93 
       ADC    $AE 
       ADC    TIMES40,X
       LSR 
       CLC
       ADC    #$18 
LFCE2: RTS

LFCE3: LDA    $D1 
       BEQ    LFCE2
       LDA    #$00 
       STA    $D1 
LFCEB: LDA    bcdGameVariant 
       CMP    #$11 
       BCC    LFD09
       LDA    $A2 
       EOR    #$01 
       TAX
       LDA    $C2,X
       BEQ    LFD09
       STX    $A2 
       CPX    #$01 
       BNE    LFD09
    ; Decrease enemyWave by one, in decimal.
       SED
       LDA    enemyWave 
       SEC
       SBC    #$01 
       STA    enemyWave 
       CLD
LFD09: JMP    LFD73

    ; Executed when enemyWave is a multiple of 5
    ; (in decimal mode).  bcdGameVariant is initialized
    ; to $FF on power-up.
LFD0C: JSR    LFCA6  ; X = bcdGameVariant AND 0x0F
       LDA    LFECD,X
       STA    $CF 
       STA    $D0 
       RTS

LFD17: LDA    #$FF 
       STA    $91 
       RTS

    ; Result of this is stored in $A2.
LFD1C: LDA    #$78 
       STA    $8D 
       LDA    #$00 
       STA    $91 
       RTS

    ; I have a hunch that this is the "extra man"
    ; routine.  If so, $C4 and $C2 represent a
    ; player's extra lives and smart bomb supply.
LFD25: STX    $93 
       LDX    $A2 
       INC    $C4,X
       INC    $C2,X
       LDX    $93 
LFD2F: LDA    #$1E  ;Called when $BA != 0x32
       STA    $8A 
       RTS

    ; $8F = gameColors [$BB]
LFD34: LDX    $BB 
       LDA    gameColors,X
       STA    $8F 
       RTS

    ; This is the first subroutine ever called in this
    ; program.
    ;
    ; The fact that certain locations are cleared
    ; here implies that this is called more than once.
LFD3B: LDA    #$00 
       STA    $A2 
       STA    $D1 
       STA    $CD 
       STA    $A4 
       STA    $9A 
       STA    $99 
       STA    $B4 
       STA    REFP0  ;Aim ship to the right.
       LDA    #$96 
       STA    $CB 
       JSR    LFDE3
       JSR    LFE09
       JSR    LFD0C
       LDA    LFEE8,X
       STA    enemyWave 
    ; Copy in city graphics.
    ; I don't know why it uses four-byte chunks.
    ; It could just copy all twelve bytes in a row.
       LDX    #$03 
LFD61: LDA    ROMCITY,X
       STA    CITYGFX,X
       LDA    ROMCITY+4,X
       STA    CITYGFX+4,X
       LDA    ROMCITY+8,X
       STA    CITYGFX+8,X
       DEX
       BPL    LFD61
LFD73: LDA    $98  ;This byte is set to $FF on powerup.
       STA    $C9 
       STA    $E3 
       STA    $E4 
       STA    $AE 
    ; This seems to set up indexes.
       LDA    #$00 
       STA    $B6 
       STA    $BD 
       STA    $BF 
       STA    $CD 
       LDA    #$FE 
       STA    $92 
       STA    $B9 
       STA    $CA 
       LDA    enemyWave 
       AND    #$0F 
       BEQ    LFD99
       CMP    #$05
       BNE    LFD9C
LFD99: JSR    LFD0C     ;Executed if low nybble
                    ;is 0 or 5.
    ; Add 1 in decimal.
LFD9C: SED
       LDA    enemyWave 
       CLC
       ADC    #$01 
       STA    enemyWave 
       CLD
       LDA    #$0F 
       STA    $D3 
       LDX    #$07 
LFDAB: LDA    LFF18,X
       STA    $80,X
       LDY    $A2  ;Y is initialized during
                ;each iteration, needlessly.
                ;I expected better.
       LDA    $00CF,Y
       CMP    #$FF 
       BNE    LFDBD
       LDA    #$05 
       STA    $80,X
LFDBD: DEX
       BPL    LFDAB
       JSR    LFDEE
LFDC3: LDA    #$32 
       STA    $AD 
       LDA    #$1E 
       STA    $A5 
       JSR    LFCAC ;Load radar1VerPos, $AB, and radar2VerPos with 0xA0
       STA    $C8 
       STA    $AB 
       LDA    #$05 
       STA    $8B 
       LDA    #$00 ;Again with LDA #$00....
                ;I'm sure they could have
                ;consolidated this into an earlier
                ;section of code.
       STA    $E0 
       STA    $E1 
       STA    $E2 
       STA    $CC 
       STA    $E6 
       RTS

;Clear $C2 through $C5 with $03
LFDE3: LDA    #$03 
       STA    $C2 
       STA    $C3 
       STA    $C4 
       STA    $C5 
       RTS

; Some relatively simple function whose purpose
; I shall discover shortly.

        ;if $B4 == 0
        ;and ( frameCounter & 7 ) == 0
        ;then $B1 = 0x60; $8F = $EE
        ;else $B1 = 0x10; $8F = $EA
LFDEE: LDA    #$10 
       STA    $B1 
       LDA    $EA 
       STA    $8F 
       LDA    $B4 
       BNE    LFE08
       LDA    frameCounter 
       AND    #$07 
       BNE    LFE08
       LDA    #$60 
       STA    $B1 
       LDA    $EE 
       STA    $8F 
LFE08: RTS

    ; I presume this routine hides the score
    ; display in order to select a level.
    ; 
    ; $9C = $9D = 0
    ; $9E = $9F = $A0 = $A1 = #$AA
LFE09: LDA    #$00 
       STA    $9C 
       STA    $9D 
       LDA    #$AA 
       STA    $9E 
       STA    $9F 
       STA    $A0 
       STA    $A1 
       RTS

SHIPGFX: .byte $F0 ; |XXXX    | $FE1A
       .byte $00 ; |        | $FE1B
       .byte $00 ; |        | $FE1C
       .byte $00 ; |        | $FE1D
       .byte $00 ; |        | $FE1E
       .byte $00 ; |        | $FE1F
       .byte $00 ; |        | $FE20
       .byte $38 ; |  XXX   | $FE21
       .byte $7F ; | XXXXXXX| $FE22 Exhaust
       .byte $7C ; | XXXXX  | $FE23
       .byte $70 ; | XXX    | $FE24
       .byte $20 ; |  X     | $FE25
       .byte $00 ; |        | $FE26
       .byte $00 ; |        | $FE27
       .byte $00 ; |        | $FE28
       .byte $00 ; |        | $FE29
       .byte $00 ; |        | $FE2A
       .byte $F0 ; |XXXX    | $FE2B
       .byte $00 ; |        | $FE2C
       .byte $00 ; |        | $FE2D
       .byte $00 ; |        | $FE2E
       .byte $04 ; |     X  | $FE2F
       .byte $08 ; |    X   | $FE30
       .byte $44 ; | X   X  | $FE31
       .byte $28 ; |  X X   | $FE32  Exploding ship
       .byte $26 ; |  X  XX | $FE33
       .byte $1C ; |   XXX  | $FE34
       .byte $28 ; |  X X   | $FE35
       .byte $04 ; |     X  | $FE36
       .byte $20 ; |  X     | $FE37
       .byte $00 ; |        | $FE38
       .byte $00 ; |        | $FE39
       .byte $00 ; |        | $FE3A
       .byte $F0 ; |XXXX    | $FE3B
       .byte $00 ; |        | $FE3C
       .byte $00 ; |        | $FE3D
       .byte $08 ; |    X   | $FE3E
       .byte $00 ; |        | $FE3F
       .byte $42 ; | X    X | $FE40
       .byte $20 ; |  X     | $FE41
       .byte $04 ; |     X  | $FE42
       .byte $41 ; | X     X| $FE43
       .byte $10 ; |   X    | $FE44
       .byte $42 ; | X    X | $FE45
       .byte $08 ; |    X   | $FE46
       .byte $40 ; | X      | $FE47
       .byte $02 ; |      X | $FE48
       .byte $20 ; |  X     | $FE49
       .byte $00 ; |        | $FE4A
       .byte $F0 ; |XXXX    | $FE4B
       .byte $00 ; |        | $FE4C
       .byte $10 ; |   X    | $FE4D
       .byte $02 ; |      X | $FE4E
       .byte $40 ; | X      | $FE4F
       .byte $00 ; |        | $FE50
       .byte $41 ; | X     X| $FE51
       .byte $00 ; |        | $FE52
       .byte $20 ; |  X     | $FE53
       .byte $02 ; |      X | $FE54
       .byte $00 ; |        | $FE55
       .byte $40 ; | X      | $FE56
       .byte $04 ; |     X  | $FE57
       .byte $00 ; |        | $FE58
       .byte $40 ; | X      | $FE59
       .byte $12 ; |   X  X | $FE5A
       .byte $F0 ; |XXXX    | $FE5B
       .byte $00 ; |        | $FE5C
       .byte $01 ; |       X| $FE5D
       .byte $40 ; | X      | $FE5E
       .byte $00 ; |        | $FE5F
       .byte $00 ; |        | $FE60
       .byte $00 ; |        | $FE61
       .byte $00 ; |        | $FE62
       .byte $00 ; |        | $FE63
       .byte $01 ; |       X| $FE64
       .byte $00 ; |        | $FE65
       .byte $00 ; |        | $FE66
       .byte $00 ; |        | $FE67
       .byte $40 ; | X      | $FE68
       .byte $00 ; |        | $FE69
       .byte $21 ; |  X    X| $FE6A
       .byte $F0 ; |XXXX    | $FE6B
       .byte $FF ; |XXXXXXXX| $FE6C
       .byte $00 ; |        | $FE6D
       .byte $00 ; |        | $FE6E
       .byte $F0 ; |XXXX    | $FE6F
       .byte $00 ; |        | $FE70
       .byte $7C ; | XXXXX  | $FE71  Exhaust
       .byte $FE ; |XXXXXXX | $FE72
       .byte $3C ; |  XXXX  | $FE73
       .byte $3C ; |  XXXX  | $FE74
       .byte $FE ; |XXXXXXX | $FE75
       .byte $7C ; | XXXXX  | $FE76
       .byte $00 ; |        | $FE77
       .byte $00 ; |        | $FE78
       .byte $00 ; |        | $FE79
       .byte $00 ; |        | $FE7A
       .byte $F0 ; |XXXX    | $FE7B
       .byte $00 ; |        | $FE7C
       .byte $FE ; |XXXXXXX | $FE7D
       .byte $7F ; | XXXXXXX| $FE7E
       .byte $00 ; |        | $FE7F
       .byte $00 ; |        | $FE80
       .byte $00 ; |        | $FE81
       .byte $00 ; |        | $FE82
       ; Bomb graphics
BOMBGFX: .byte $00 ; |        | $FE83
     .byte $00 ; |        | $FE84
     .byte $00 ; |        | $FE85
     .byte $5C ; | X XXX  | $FE86
     .byte $3E ; |  XXXXX | $FE87
     .byte $5C ; | X XXX  | $FE88
LFE89: .byte $00,$50,$40,$30,$20
LFE8E: .byte $F0,$E0,$D0,$70,$B0,$60,$50,$90,$A0
LFE97: .byte $00,$01,$FF,$00,$00,$01,$FF,$FF,$01
LFEA0: .byte $00,$00,$00,$01,$FF,$01,$01,$FF,$FF

; PF2 values that create the radar body with focus in the middle
radarfocus: .byte $C0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$C0

LFEB5: .byte $FF,$07,$03,$01,$01
    ; Index values for digits 0 through 9
DIGIND: .byte $3F,$46,$4D,$54,$5B,$62,$69,$70,$77,$7E
LFEC4: .byte $0F,$07,$03,$07,$07,$03,$07,$07,$03
    ;Indexed by (bcdGameVariant AND 0x0F)
LFECD: .byte $07,$07,$07,$FF,$07,$07,$FF,$07
       .byte $07,$FF,$07,$07,$07,$07,$07,$07
       .byte $07  ;Extra byte.  Will investigate.
       ; Copied to NUSIZ registers
LFEDE: .byte $F0,$F0,$F1,$F3
    ; Copied to $96 and $97.
LFEE2: .byte $00,$FF,$FF,$FF
    ; 0x40 << X
LFEE6: .byte $40,$80
LFEE8: .byte $00,$00,$00,$00,$02,$02,$02,$04,$04,$04
    ; 0x28 * X  or  40 * x
TIMES40: .byte $00,$28,$50,$78,$9B,$AF,$64,$5A
    ; Some wacky indexing happens here.
LFEFA: .byte $05,$00,$00,$00,$05,$05
LFF00: .byte $02,$02,$0A,$05,$01,$01
LFF06: .byte $03,$00,$02,$00,$02,$01
LFF0C: .byte $01,$00,$03,$00,$03,$00
    ; 0x80 >> X
LFF12: .byte $80,$40,$20,$10,$08,$04
    ;These eight bytes are copied into $80,
    ;with some exceptions.
LFF18: .byte $00,$02,$02,$04,$04,$04,$04,$80
    ; (X+1) * 8 table
TIMES8: .byte $08,$10,$18,$20,$28,$30
    ; Graphics are stored here.
GFXDATA: .byte $00 ; |        | $FF26
    ; Minelayer
       .byte $00 ; |        | $FF27
       .byte $00 ; |        | $FF28
       .byte $00 ; |        | $FF29
       .byte $00 ; |        | $FF2A
       .byte $F8 ; |XXXXX   | $FF2B
       .byte $D8 ; |XX XX   | $FF2C
       .byte $D8 ; |XX XX   | $FF2D
       .byte $F8 ; |XXXXX   | $FF2E
       .byte $00 ; |        | $FF2F
    ; Baiter
       .byte $00 ; |        | $FF30
       .byte $00 ; |        | $FF31
       .byte $00 ; |        | $FF32
       .byte $00 ; |        | $FF33
       .byte $7E ; | XXXXXX | $FF34
       .byte $E7 ; |XXX  XXX| $FF35
       .byte $7E ; | XXXXXX | $FF36
       .byte $00 ; |        | $FF37
    ; Thing that splits into swarmers
       .byte $10 ; |   X    | $FF38
       .byte $54 ; | X X X  | $FF39
       .byte $38 ; |  XXX   | $FF3A
       .byte $FE ; |XXXXXXX | $FF3B
       .byte $38 ; |  XXX   | $FF3C
       .byte $54 ; | X X X  | $FF3D
       .byte $10 ; |   X    | $FF3E
       .byte $00 ; |        | $FF3F
    ; Swarmer
       .byte $42 ; | X    X | $FF40
       .byte $E7 ; |XXX  XXX| $FF41
       .byte $42 ; | X    X | $FF42
       .byte $04 ; |     X  | $FF43
       .byte $4E ; | X  XXX | $FF44
       .byte $E4 ; |XXX  X  | $FF45
       .byte $40 ; | X      | $FF46
       .byte $00 ; |        | $FF47
    ; Lander
       .byte $FF ; |XXXXXXXX| $FF48
       .byte $7E ; | XXXXXX | $FF49
       .byte $24 ; |  X  X  | $FF4A
       .byte $18 ; |   XX   | $FF4B
       .byte $3C ; |  XXXX  | $FF4C
       .byte $3C ; |  XXXX  | $FF4D
       .byte $18 ; |   XX   | $FF4E
       .byte $00 ; |        | $FF4F
    ; Mutant
       .byte $C3 ; |XX    XX| $FF50
       .byte $3C ; |  XXXX  | $FF51
       .byte $24 ; |  X  X  | $FF52
       .byte $18 ; |   XX   | $FF53
       .byte $3C ; |  XXXX  | $FF54
       .byte $3C ; |  XXXX  | $FF55
       .byte $44 ; | X   X  | $FF56
       .byte $00 ; |        | $FF57
       .byte $10 ; |   X    | $FF58
       .byte $20 ; |  X     | $FF59
       .byte $40 ; | X      | $FF5A
       .byte $14 ; |   X X  | $FF5B
       .byte $28 ; |  X X   | $FF5C
       .byte $54 ; | X X X  | $FF5D
       .byte $20 ; |  X     | $FF5E
    ; 0
       .byte $7E ; | XXXXXX | $FF5F
       .byte $72 ; | XXX  X | $FF60
       .byte $72 ; | XXX  X | $FF61
       .byte $72 ; | XXX  X | $FF62
       .byte $72 ; | XXX  X | $FF63
       .byte $72 ; | XXX  X | $FF64
       .byte $7E ; | XXXXXX | $FF65
    ; 1
       .byte $1C ; |   XXX  | $FF66
       .byte $1C ; |   XXX  | $FF67
       .byte $1C ; |   XXX  | $FF68
       .byte $1C ; |   XXX  | $FF69
       .byte $1C ; |   XXX  | $FF6A
       .byte $1C ; |   XXX  | $FF6B
       .byte $3C ; |  XXXX  | $FF6C
    ; 2
       .byte $7E ; | XXXXXX | $FF6D
       .byte $40 ; | X      | $FF6E
       .byte $7E ; | XXXXXX | $FF6F
       .byte $0E ; |    XXX | $FF70
       .byte $0E ; |    XXX | $FF71
       .byte $4E ; | X  XXX | $FF72
       .byte $7E ; | XXXXXX | $FF73
    ; 3
       .byte $7E ; | XXXXXX | $FF74
       .byte $4E ; | X  XXX | $FF75
       .byte $0E ; |    XXX | $FF76
       .byte $1C ; |   XXX  | $FF77
       .byte $0E ; |    XXX | $FF78
       .byte $4E ; | X  XXX | $FF79
       .byte $7E ; | XXXXXX | $FF7A
    ; 4
       .byte $1C ; |   XXX  | $FF7B
       .byte $1C ; |   XXX  | $FF7C
       .byte $7E ; | XXXXXX | $FF7D
       .byte $5C ; | X XXX  | $FF7E
       .byte $5C ; | X XXX  | $FF7F
       .byte $5C ; | X XXX  | $FF80
       .byte $7C ; | XXXXX  | $FF81
    ; 5
       .byte $7E ; | XXXXXX | $FF82
       .byte $4E ; | X  XXX | $FF83
       .byte $0E ; |    XXX | $FF84
       .byte $7E ; | XXXXXX | $FF85
       .byte $40 ; | X      | $FF86
       .byte $4E ; | X  XXX | $FF87
       .byte $7E ; | XXXXXX | $FF88
    ; 6
       .byte $7E ; | XXXXXX | $FF89
       .byte $4E ; | X  XXX | $FF8A
       .byte $4E ; | X  XXX | $FF8B
       .byte $7E ; | XXXXXX | $FF8C
       .byte $40 ; | X      | $FF8D
       .byte $4E ; | X  XXX | $FF8E
       .byte $7E ; | XXXXXX | $FF8F
    ; 7
       .byte $0E ; |    XXX | $FF90
       .byte $0E ; |    XXX | $FF91
       .byte $0E ; |    XXX | $FF92
       .byte $0E ; |    XXX | $FF93
       .byte $0E ; |    XXX | $FF94
       .byte $4E ; | X  XXX | $FF95
       .byte $7E ; | XXXXXX | $FF96
    ; 8
       .byte $7E ; | XXXXXX | $FF97
       .byte $4E ; | X  XXX | $FF98
       .byte $4E ; | X  XXX | $FF99
       .byte $7E ; | XXXXXX | $FF9A
       .byte $72 ; | XXX  X | $FF9B
       .byte $72 ; | XXX  X | $FF9C
       .byte $7E ; | XXXXXX | $FF9D
    ; 9
       .byte $7E ; | XXXXXX | $FF9E
       .byte $72 ; | XXX  X | $FF9F
       .byte $02 ; |      X | $FFA0
       .byte $7E ; | XXXXXX | $FFA1
       .byte $72 ; | XXX  X | $FFA2
       .byte $72 ; | XXX  X | $FFA3
       .byte $7E ; | XXXXXX | $FFA4
    ; Space
       .byte $00 ; |        | $FFA5
       .byte $00 ; |        | $FFA6
       .byte $00 ; |        | $FFA7
       .byte $00 ; |        | $FFA8
       .byte $00 ; |        | $FFA9
       .byte $00 ; |        | $FFAA
       .byte $00 ; |        | $FFAB
    ; (C) 1981 Atari
       .byte $79 ; | XXXX  X| $FFAC
       .byte $85 ; |X    X X| $FFAD
       .byte $B5 ; |X XX X X| $FFAE
       .byte $A5 ; |X X  X X| $FFAF
       .byte $B5 ; |X XX X X| $FFB0
       .byte $85 ; |X    X X| $FFB1
       .byte $79 ; | XXXX  X| $FFB2
       .byte $17 ; |   X XXX| $FFB3
       .byte $15 ; |   X X X| $FFB4
       .byte $15 ; |   X X X| $FFB5
       .byte $77 ; | XXX XXX| $FFB6
       .byte $55 ; | X X X X| $FFB7
       .byte $55 ; | X X X X| $FFB8
       .byte $77 ; | XXX XXX| $FFB9
       .byte $41 ; | X     X| $FFBA
       .byte $41 ; | X     X| $FFBB
       .byte $41 ; | X     X| $FFBC
       .byte $41 ; | X     X| $FFBD
       .byte $41 ; | X     X| $FFBE
       .byte $41 ; | X     X| $FFBF
       .byte $40 ; | X      | $FFC0
       .byte $49 ; | X  X  X| $FFC1
       .byte $49 ; | X  X  X| $FFC2
       .byte $49 ; | X  X  X| $FFC3
       .byte $C9 ; |XX  X  X| $FFC4
       .byte $49 ; | X  X  X| $FFC5
       .byte $49 ; | X  X  X| $FFC6
       .byte $BE ; |X XXXXX | $FFC7
       .byte $55 ; | X X X X| $FFC8
       .byte $55 ; | X X X X| $FFC9
       .byte $55 ; | X X X X| $FFCA
       .byte $D9 ; |XX XX  X| $FFCB
       .byte $55 ; | X X X X| $FFCC
       .byte $55 ; | X X X X| $FFCD
       .byte $99 ; |X  XX  X| $FFCE
    ; Author's initials
       .byte $00 ; |        | $FFCF
       .byte $C4 ; |XX   X  | $FFD0
       .byte $A4 ; |X X  X  | $FFD1
       .byte $C6 ; |XX   XX | $FFD2
       .byte $A5 ; |X X  X X| $FFD3
       .byte $C6 ; |XX   XX | $FFD4
LFFD5: .byte $0A,$A0
LFFD7: .byte $0B,$B0
LFFD9: .byte $0F,$F0
LFFDB: .byte $01,$10
PLYRJOY: .byte $F0,$0F
LFFDF: .byte $F1,$1F
LFFE1: .byte $FA,$AF
    ; City graphics in ROM. 
    ; Arrangement is a bit tricky to explain.
ROMCITY: .byte $E0,$60,$40,$40 ;...1 .... .11. .... ..1.
     .byte $7B,$79,$59,$10 ;.1.1 1..1 .11. .11. ..1.
     .byte $CE,$C6,$C6,$C0 ;.111 1..1 .11. .11. .11.
                   ;.111 1.11 .11. .111 .111
    ; Remember that PF1 is reversed.

colortable: .byte $00,$88,$8F,$FF,$1D,$1A,$37,$00
      .byte $00,$00,$00,$00,$00
      .word START
      .word START