; Outlaw for the Atari 2600 VCS
;
; Copyright 1978 Atari
; Written by David Crane
;
; Reverse-Engineered by Manuel Polik (cybergoth@nexgo.de)
; Compiles with DASM
;
; History
; 25.01.2.1K      - Started
; 04.02.2.1K      - Finished initialisation
; 05.02.2.1K      - Finished score & magazin drawing routine
; 16.04.2.1K      - Finished the main display kernel
; 11.08.2.1K      - Finished Sound Effects
; 17.08.2.1K      - Finished Select Handling
; 08.09.2.1K      - Finished All Movement Handling
; 08.10.2.1K      - Finished Bullet Management
; 10.10.2.1K      - Release Version!

    include vcs.h

; Equates:

; RAM variables:

PF0Array            = $80   ; PF0 array, 18 Bytes
ScoreshapeLow01     = $92   ; Shape of player 1 lower score digit
ScoreshapeLow02     = $93   ; Shape of player 2 lower score digit
ScoreshapeHi01      = $94   ; Shape of player 1 higher score digit
ScoreshapeHi02      = $95   ; Shape of player 2 higher score digit
bcdScore01Backup    = $96   ; Backups score for player 1
rightScoreOnOff     = $97   ; 0F for Right score on, 00 for off
gameState           = $98   ; 0F running/EF saver/00 select/XX counter
ObstInKernelPos     = $99   ; Position were obstacle displayes in kernel
vertBouncePos       = $9A   ; Point from where bullet bounces vertically
bulletsInGun01      = $9B   ; # of bullet in gun 1, shifted bitwise
bulletsInGun02      = $9C   ; # of bullet in gun 2, shifted bitwise
gameSettingBits     = $9D   ; X/X/SINGLEPLAYER/SIXSHOOTER/X/X/WALL/COACH
soundSpeed01        = $9E   ; 00 for fast, 01 for slow frequency changes
;soundSpeed02        = $9F   ; 00 for fast, 01 for slow frequency changes
audioFreq01         = $A0   ; Current frequency of voice 0
;audioFreq02        = $A1   ; Current frequency of voice 1
deathBreak01        = $A2   ; If nonzero the first player is dead
;deathBreak02        = $A3   ; If nonzero the second player is dead
PF2Array01          = $A4   ; PF2 array 1, 18 Bytes
PF1Array            = $B6   ; PF1 array, 18 Bytes
PF2Array02          = $C8   ; PF2 array 2, 18 Bytes
frameCounter        = $DA   ; is incremented once every frame
obstacleVertPos     = $DB   ; Vertical position of cactus/coach/wall
vertPosition01      = $DC   ; Vertical position of player 1
vertPosition02      = $DD   ; Vertical position of player 2
verPlayerOff01      = $DE   ; Current offset of player 1
verPlayerOff02      = $DF   ; Current offset of player 2
audioVolume01       = $E0   ; Current volume of voice 0
;audioVolume02       = $E1   ; Current volume of voice 1
shapeOBackup11      = $E2   ; Saves starting offset of actual shape 1
shapeOBackup12      = $E3   ; Saves starting offset of actual shape 2
bulletVerPos01      = $E4   ; Vertical position of bullet 1
bulletVerPos02      = $E5   ; Vertical position of bullet 2
bulletHorPos01      = $E6   ; Horizontal Position of bullet 1
bulletHorPos02      = $E7   ; Horizontal Position of bullet 2
bouncePos01         = $E8   ; value to calculate where to bounce player
bouncePos02         = $E9   ; value to calculate where to bounce player
lineCounter         = $EA   ; Counts every half PF line that is done
shapeOffset01       = $EB   ; Points to current shape of first player
shapeOffset02       = $EC   ; Points to current shape of second player
saverColor          = $ED   ; Value to EOR colors in saver mode
selectTimer         = $EE   ; Select is processed when it counted to 00
bcdScore01          = $EF   ; Score of player 1
bcdScore02          = $F0   ; Score of player 2
bcdGameVariant      = $F1   ; Current game variant in BCD Format(1-16)

gunState01          = $F4   ; FORBIDDEN/UP/X/EMPTY/FIRE/X/X/X
gunState02          = $F5   ; FORBIDDEN/UP/X/EMPTY/FIRE/X/X/X
shapeOBackup01      = $F6   ; Saves starting offset of actual shape 1
shapeOBackup02      = $F7   ; Saves starting offset of actual shape 2
tempVar01           = $F8   ; various temporary data

tempVar03           = $FA   ; various temporary data
tempVar04           = $FB   ; various temporary data
gunStateBackup      = $FC   ; Backups the gunstate for calculations
destructOffset      = $FD   ; Offset to byte where PF gets destructed
tempVar07           = $FE   ; various temporary data
tempVar06           = $FF   ; various temporary data

; Begin source

    processor 6502
    ORG $F000

; Init colors

MainLoop:           LDY #$0F            ; Assume black & white mode
                    LDA SWCHB           ; Check console switches
                    AND #$08            ; Black & white mode?
                    BEQ BlackWhite      ; Y: B/W colors
                    LDY #$FF            ; N: Full colors
BlackWhite:         LDA bcdGameVariant  ; A -> 1-16 bcd
                    AND #$03            ; A -> 0 v 1 v 2 v 3
                    ASL                 ; 
                    ASL                 ; A-> Colorset offset (0/4/8/12)
                    TAX                 ; X-> Colorset offset (0/4/8/12)
                    STY tempVar01       ; Store full v B/W color value
                    LDY #$00            ; init counter
NextColor:          LDA gameState       ; A-> game state
                    CMP #$0F            ; game running?
                    BEQ NoSaver         ; Y: No saver
                    LDA tempVar01       ; N: saver
                    AND #$F7            ; Darker saver colors
                    STA tempVar01       ; store temporary
                    LDA colortab,X      ; A-> Color value
                    EOR saverColor      ; A-> Saver color value
                    BNE ColorFinish     ; Black? 
NoSaver:            LDA colortab,X      ; Y: A-> Color value
ColorFinish:        AND tempVar01       ; N: Filter color
                    STA.wy $0006,Y      ; Store color in register
                    INX                 ; next color
                    INY                 ; next color register
                    CPY #$04            ; all colors done?
                    BCC NextColor       ; N: Next color

                    LDA #$00            ;
                    STA lineCounter     ; Start counting with 0
                    LDA bcdScore01      ; 
                    STA bcdScore01Backup; Backup score of player 1
                    LDA gameState       ; Select pressed?
                    BNE ShowScore       ; N: Show Score
                    LDA bcdGameVariant  ; 
                    STA bcdScore01      ; Y: Show variant number

; calculate offsets for score display

ShowScore:          LDX #$02            ; Two scores to draw
ShowSecondScore:    LDA $EE,X           ; A-> player score
                    AND #$0F            ; A-> lower score nibble
                    STA tempVar03       ; store temporary
                    ASL                 ;
                    ASL                 ; multiply with 4 and add score
                    CLC                 ; so we get the offsets for the
                    ADC tempVar03       ; score shapes (0,5,10,15,20..)
                    STA $91,X           ; store lower offset
                    LDA $EE,X           ; A-> player score
                    AND #$F0            ; A-> higher score nibble
                    LSR                 ; 
                    LSR                 ; 
                    STA tempVar03       ; divide by 4 & store temporary
                    LSR                 ; divide another time by 4
                    LSR                 ; and add stored value to create
                    ADC tempVar03       ; again score offsets like above
                    STA $93,X           ; store higher offset
                    DEX                 ; second Player done?
                    BNE ShowSecondScore ; N: Do it

WaitVBlank:         LDA INTIM           ; Y: Finish VBlank!
                    BNE WaitVBlank      ;

                    STA WSYNC           ; Finsih current line
                    STA VBLANK          ; Stop vertical blank
                    LDX #$06            ; value is initializing next
                    STX CTRLPF          ; loop & sets playfield prio!

; Draw 6 blank lines

BlankLines1:        STA WSYNC           ; Finsih current line
                    DEX                 ; 6 blank lines done?
                    BNE BlankLines1     ; N: Do one more  
                    STX tempVar03       ; Y: clear tempVar03
                    STX tempVar04       ; clear tempVar04

; Draw 12 lines displaying scores
; First & Last line is blank, each line calculates next line on the fly

                    LDX #$06            ; six lines to draw
DrawScores:         STA WSYNC           ; Finsih current line
                    LDA tempVar03       ; A-> starting score 1 value
                    STA PF1             ; store in PF1
                    LDY ScoreshapeHi01  ; Y-> score hi offset 1
                    LDA scoreshapedata,Y; A-> score shape data
                    AND #$F0            ; mask higher nibble
                    STA tempVar03       ; store temporary
                    LDY ScoreshapeLow01 ; Y-> score low offset 1
                    LDA scoreshapedata,Y; A-> score shape data
                    AND #$0F            ; mask lower nibble
                    ORA tempVar03       ; OR in stored higher nibble
                    STA tempVar03       ; store score 1 temporary
                    LDA tempVar04       ; A-> starting score 2 value
                    STA PF1             ; store in PF1
                    LDY ScoreshapeHi02  ; Y-> score hi offset 2
                    LDA scoreshapedata,Y; A-> score shape data
                    AND #$F0            ; mask higher nibble
                    STA tempVar04       ; store temporary
                    LDY ScoreshapeLow02 ; Y-> score low offset 2
                    LDA scoreshapedata,Y; A-> score shape data
                    AND rightScoreOnOff ; mask lower nibble
                    STA WSYNC           ; Finish current line
                    ORA tempVar04       ; OR in stored higher nibble
                    STA tempVar04       ; store score 2 temporary
                    LDA tempVar03       ; write new score 1 in
                    STA PF1             ; second line
                    DEX                 ; next score line?
                    BEQ QuitScoreLoop   ; N: Quit score loop
                    INC ScoreshapeLow01 ; adjust all four...
                    INC ScoreshapeHi01  ;
                    INC ScoreshapeLow02 ;
                    INC ScoreshapeHi02  ; ...score offsets
                    LDA tempVar04       ; write new score 2 in
                    STA PF1             ; second line
                    JMP DrawScores      ; draw next score line

; do 3 more blank lines, we've done (6+12+3=21) lines then

QuitScoreLoop:      STX PF1             ; Immediately clear playfield
                    LDX #$03            ; 3 blank lines
BlankLines2:        STA WSYNC           ; Finish Current Line
                    DEX                 ; blank lines done?
                    BNE BlankLines2     ; N: Do one more
                    LDA bcdScore01Backup; 
                    STA bcdScore01      ; Restore score 1

; Display bullets in magazin, 6 lines single resolution

                    LDX #$06            ; 6 lines to draw
DrawMagazin:        STA WSYNC           ; finish current line
                    LDA gameSettingBits ; A-> settings of actual variant
                    AND #$10            ; Six shooter game?
                    BEQ NoMagazin       ; N: No magazin drawn
                    LDA bulletsInGun01  ;
                    STA PF1             ; display bullets in gun 1
                    BNE Magazin1Done    ; Allow shooting if > 0 bullets
                    LDA gunState01      ; else permit it
                    ORA #$10            ; gun 1 -> empty
                    STA gunState01      ; store gun state 1
Magazin1Done:       JSR Shift4BitsRight ; Waste some time
                    LDA bulletsInGun02  ; 
                    STA PF1             ; display bullets in gun 2
                    BNE NoMagazin       ; Allow shooting if > 0 bullets
                    LDA gunState02      ; else permit it
                    ORA #$10            ; gun 2 -> empty
                    STA gunState02      ; store gun state 2
NoMagazin:          DEX                 ; Magazines done?
                    BNE DrawMagazin     ; N: Do another line

; Reload guns if required
; we've done (6+12+3+6+1=28) lines then

                    STA WSYNC           ; finish current line
                    LDA #$00            ;
                    STA PF1             ; Clear Playfield
                    LDA bulletsInGun01  ; Gun 1 loaded?
                    BNE DontLoad        ; Y: Don't load
                    LDA bulletsInGun02  ; N: Gun 2 loaded?
                    BNE DontLoad        ; Y: Don't load
                    LDA gunState01      ; N:
                    AND #$08            ; Shot 1 under way?
                    BNE DontLoad        ; Y: Don't load
                    LDA gunState02      ; N:
                    AND #$08            ; Shot 2 under way?
                    BNE DontLoad        ; Y: Don't load
                    LDA #$FC            ; N:
                    STA bulletsInGun01  ; Reload gun 1
                    STA bulletsInGun02  ; Reload gun 2
                    LDA gunState01      ;
                    AND #$EF            ;
                    STA gunState01      ; Gunstate -> loaded
                    LDA gunState02      ;
                    AND #$EF            ;
                    STA gunState02      ; Gunstate -> loaded

; Do 3 more blank lines 

DontLoad:           LDX #$03            ;
BlankLines3:        STA WSYNC           ;
                    DEX                 ;
                    BNE BlankLines3     ;

                    STX CTRLPF          ; Reset Playfield mode
                    JSR TopBottomBorder ; Draw top border

                    LDX #$1E            ; Move Stack to...
                    TXS                 ; ...ENAMM1!

                    LDA obstacleVertPos ; Move obstacle every 8th frame
                    LSR                 ;
                    LSR                 ;
                    LSR                 ;
                    TAX                 ;

; Main 4-line display kernel

; Draw line number #1
; Draws the playfield and player 2

NextLine:           STA WSYNC           ; Finish current line
                    LDA PF0Array,X      ; A->PF0 data (frame)
                    ASL                 ; Shift lower to...
                    ASL                 ;
                    ASL                 ;
                    ASL                 ; ... higher nibble
                    STA PF0             ; Draw PF0
                    STA tempVar01       ; And store value temporary
                    LDA #$00            ; 
                    NOP                 ;
                    STA PF1             ; Clear out PF1
                    LDA PF2Array01,X    ; A->PF2 data (obstacle)
                    STA PF2             ; Draw PF2
                    LDA PF0Array,X      ; A->PF0 data (obstacle)
                    STA PF0             ; Draw PF0
                    LDA PF1Array,X      ; A->PF1 data (obstacle)
                    STA PF1             ; Draw PF1
                    LDA PF2Array02,X    ; A->PF2 data (frame)
                    STA PF2             ; Draw PF2
                    SEC                 ; Set carry
                    LDA vertPosition02  ; A-> vertical pos player 2
                    SBC lineCounter     ; Current pos above player2?
                    BPL SkipDraw1       ; Y: SkipDraw1
                    LDA tempVar01       ; A->PF0 data (frame)
                    STA PF0             ; Draw PF0
                    LDY shapeOffset02   ; Y-> shapeOffset02
                    LDA LF6FE,Y         ; A-> player 2 shape
                    STA GRP1            ; Draw P2. Finished?
                    BEQ Player2Done     ; Y: Leave Offset
                    INC shapeOffset02   ; N: Increment Offset
                    JMP Continue1       ; All branches merge again...
Player2Done:        NOP                 ; Burn...
                    NOP                 ; ...cycles
                    JMP Continue1       ; All branches merge again...
SkipDraw1:          LDA tempVar01       ; A->PF0 data (frame)
                    STA PF0             ; Draw PF0
                    LDA tempVar01       ; Burn cycles...
                    NOP                 ;
                    NOP                 ;

; Draw line number #2
; Draws the playfield and bullet 2

                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ; ... until we're finally...
                    NOP                 ; ... at cycle 13...
                    NOP                 ; ... where all braches merge
Continue1:          LDY lineCounter     ; Y-> lineCounter
                    LDA #$00            ; A-> $00
                    NOP                 ; Burn 2 cycles
                    CPY bulletVerPos02  ; Check for bullet 2
                    STA PF1             ; Clear PF1
                    PHP                 ; En/Disable bullet 2
                    LDA PF2Array01,X    ; A->PF2 data (obstacle)
                    STA PF2             ; Draw PF2
                    LDA PF0Array,X      ; A->PF0 data (obstacle)
                    STA PF0             ; Draw PF0
                    LDA PF1Array,X      ; A->PF1 data (obstacle)
                    STA PF1             ; Draw PF1
                    LDA PF2Array02,X    ; A->PF2 data (frame)
                    STA PF2             ; Draw PF2
                    SEC                 ; Set carry
                    LDA tempVar01       ; A->PF0 data (frame)
                    STA PF0             ; Draw PF0
                    LDA #$00            ; A-> $00
                    NOP                 ; Burn 2 cycles
                    STA PF1             ; Clear PF1
                    LDA PF2Array01,X    ; A->PF2 data (obstacle)

; Draw line number #3
; Draws the playfield and bullet 1 & increments the kernels linecounter


                    STA PF2             ; Draw PF2
                    LDA vertPosition01  ; A-> vertical pos player 1
                    SBC lineCounter     ; Current pos above player1?
                    BPL SkipDraw2       ; Y: SkipDraw1
                    LDY shapeOffset01   ; Y-> shapeOffset01
                    LDA LF6FE,Y         ; A-> player 1 shape
                    TAY                 ; Y-> player 1 shape
                    LDA PF0Array,X      ; A->PF0 data (obstacle)
                    STA.w $000D         ; Draw PF0 (4 cycles!)
                    LDA lineCounter     ; A->lineCounter
                    CMP bulletVerPos01  ; Check for bullet 1
                    PHP                 ; En/Disable bullet 1
                    LDA PF1Array,X      ; A->PF1 data (obstacle)
                    STA PF1             ; Draw PF1
                    LDA PF2Array02,X    ; A->PF2 data (frame)
                    STA PF2             ; Draw PF2
                    PLA                 ; Restore...
                    PLA                 ; ...Stack to ENAMM1
                    CPY #$00            ; Player 1 finished? 
                    BEQ Player1Done     ; Y: Leave Offset
                    INC shapeOffset01   ; N: Increment Offset
                    JMP Continue2       ; All branches merge again...
Player1Done:        NOP                 ; Burn...
                    NOP                 ; ...cycles
                    JMP Continue2       ; All branches merge again...
SkipDraw2:          LDA tempVar01       ; Burn cycles...
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    NOP                 ;
                    LDA PF0Array,X      ; A->PF0 data (obstacle)
                    STA PF0             ; Draw PF0
                    LDA PF1Array,X      ; A->PF1 data (obstacle)
                    STA PF1             ; Draw PF1
                    LDA PF2Array02,X    ; A->PF2 data (frame)
                    STA PF2             ; Draw PF2
                    LDA bulletVerPos01  ; A-> bullet 1 ver pos
                    CMP lineCounter     ; Check for bullet 1
                    PHP                 ; En/Disable bullet 1
                    PLA                 ; Restore...
                    PLA                 ; ...Stack to ENAMM1
                    LDY #$00            ; Clear player 1 shape
Continue2:          INC lineCounter     ; Do next 4 lines

; Draw line number #4
; Draws the playfield and player 1 & adjusts the obstacle array offsets

                    STY GRP0            ; Draw player 1
                    LDA tempVar01       ; A->PF0 data (frame)
                    STA PF0             ; Draw PF0
                    LDA #$00            ; A-> $00
                    NOP                 ; Burn 2 cycles
                    STA PF1             ; Clear PF1
                    LDA PF2Array01,X    ; A->PF2 data (obstacle)
                    STA PF2             ; Draw PF2
                    LDA PF0Array,X      ; A->PF0 data (obstacle)
                    STA PF0             ; Draw PF0
                    LDA PF2Array02,X    ; A->PF2 data (frame)
                    TAY                 ; Y->PF2 data (frame)
                    LDA PF1Array,X      ; A->PF1 data (obstacle)
                    STA PF1             ; Draw PF1
                    LDA lineCounter     ; A->lineCounter
                    AND #$01            ; Even line? (4 scanlines!)
                    BNE PlayfieldDone   ; N: Draw same playfield again
                    INX                 ; Y: Next playfield line
                    CPX #$12            ; Obstacle bottom reached?
                    BNE PlayfieldDone   ; N: Continue with next line
                    LDX #$00            ; Y: Start over from the top
PlayfieldDone:      STY PF2             ; Draw PF2
                    LDA lineCounter     ; A-> lineCounter
                    CMP #$24            ; Display kernel finished?
                    BEQ MainKernelDone  ; Y: Finish Frame
                    JMP NextLine        ; N: Do next kernel line

; Finish screen: Draw the bootom of the border, then clear PF

MainKernelDone:     STA WSYNC           ;
                    LDX #$FF            ;
                    TXS                 ; Restore Stack
                    TXA                 ;
                    JSR SetPlayfield    ; Draw bottom border
                    JSR TopBottomBorder ;
                    STX PF0             ;
                    JSR ClearPlayField  ; Clear Playfield afterwards 
                    LDA #$22            ;
                    STA TIM64T          ; Set timer for overscan

; Play soundeffects for both players

                    LDX #$01            ; one sound channel per player
NextChannel:        LDA frameCounter    ;
                    AND soundSpeed01,X    ; change frequency this frame?
                    BNE ChannelDone     ; N: channel done
                    LDA audioVolume01,X ; Y: A -> current volume > 0?
                    BEQ ChannelDone     ; N: channel done
                    DEC audioVolume01,X ; Y: turn the volume down...
                    LDA audioVolume01,X ;
                    STA AUDV0,X         ;
                    INC audioFreq01,X   ; ...and increment the frequency
                    LDA audioFreq01,X   ;
                    STA AUDF0,X         ;
ChannelDone:        DEX                 ;
                    BPL NextChannel     ;
    
FinishOverscan:     LDA INTIM           ; Overscan done?
                    BNE FinishOverscan  ; N: Continue

; During the vertical sync the framcounter is incremented and every 256
; frames the savercolor is incremented as well

                    LDA #$2A            ;
                    STA HMCLR           ; Clear Hor-Motion Registers
                    STA WSYNC           ; Finish Current Line
                    STA VBLANK          ; Start VBLANK
                    STA VSYNC           ; Start VSYNC
                    STA TIM8T           ; Set timer for VSYNC
                    CLC                 ; 
                    LDA #$01            ; 
                    ADC frameCounter    ; 
                    STA frameCounter    ; frameCounter++
                    LDA #$00            ; in case...
                    ADC saverColor      ; ...of an overflow...
                    STA saverColor      ; change savercolor

FinishVSYNC:        LDA INTIM           ; VSYNC done?
                    BNE FinishVSYNC     ; N: Continue

                    STA WSYNC           ; Finish current line
                    STA VSYNC           ; Stop vertical sync

                    LDA #$28            ; 
                    STA TIM64T          ; Set timer for vertical blank

; Handle the select switch
; Switch to next variant & play a sound, when select timer is 
; already expired

                    LDA selectTimer     ; Eventually process select?
                    BNE DecrementTimer  ; N: Wait a little longer
                    LDA SWCHB           ; Y: Read switches
                    AND #$02            ; Select pressed?
                    BNE SkipSelect      ; N: Skip Select
                    TAX                 ; Y: A = X = 00
                    JSR SelectSFX       ; Play the 'Select' Sound
                    SED                 ; BCD on
                    CLC                 ;
                    LDA #$01            ;
                    ADC bcdGameVariant  ; Switch to next game variant
                    CMP #$17            ; Reached variant *17*?
                    BNE StoreNewVariant ; N: Accept new variant
                    LDA #$01            ; Y: Start over with variant *1*
StoreNewVariant:    STA bcdGameVariant  ; Store new variant
                    CLD                 ; BCD off
                    LDA #$1E            ;
                    STA selectTimer     ; Start the Selecttimer
                    LDA #$00            ;
                    STA gameState       ; Set select state
                    STA rightScoreOnOff ; Disable right score
                    STA bcdScore02      ; Clear right score
                    JMP ResetSelectdone ; Start over with new variant
DecrementTimer:     DEC selectTimer     ; Decrement next select timer
                    LDA SWCHB           ; Read switches
                    AND #$02            ; Stopped pressing select?
                    BEQ SkipSelect      ; N: Select handling done
                    LDA #$00            ; Y: 
                    STA selectTimer     ; Clear select timer again

; Reset shape pointers

SkipSelect:         LDA shapeOBackup01  ;
                    STA shapeOffset01   ; Reset player 1 shape pointer
                    LDA shapeOBackup02  ;
                    STA shapeOffset02   ; Reset player 2 shape pointer

; Handle reset switch

                    LDA SWCHB           ; Check switches
                    AND #$01            ; Reset?
                    BNE SkipReset       ; N: Skip reset
                    STA bcdScore01      ; Y: 
                    STA bcdScore02      ; Clear both scores
                    LDA #$0F            ;
                    STA gameState       ; Set running state
                    STA rightScoreOnOff ; Enable right score
                    JMP ResetSelectdone ; Start over after reset

SkipReset:          LDA frameCounter    ; A -> frameCounter
                    AND #$01            ; A -> 0 v 1
                    TAX                 ; X -> 0 v 1
                    LDA SWCHA           ; Load joystick input
                    CPX #$00            ; Even frame?
                    BNE OddPlayer       ; N: Move player 2
                    JSR Shift4BitsRight ; Y: Move player 1
OddPlayer:          AND #$0F            ; Mask movement bits
                    STA tempVar04       ; Store temporary
                    LDA $3C,X           ; Read fire button
                    AND #$80            ; Mask fire button
                    ORA tempVar04       ; *add* to joystick read
                    STA tempVar04       ; store complete input temporary

                    LDA SWCHB           ; Read Switches
                    CPX #$00            ; Even frame?
                    BEQ NextDifficulty  ; Y: Difficulty switch 2
                    LSR                 ; N: Difficulty switch 1
NextDifficulty:     AND #$40            ; Mask difficulty switch
                    ORA tempVar04       ; *add* to joystick read:
                    STA tempVar04       ; FIRE/DIFFICULTY/X/X/R/L/D/U
                    LDA gunState01,X    ; A -> current gunstate of X
                    STA gunStateBackup  ; Store temporary
                    LDA gameState       ; A -> gamestate
                    CMP #$0F            ; Game Running?
                    BEQ ContinueGame    ; Y: Continue game calculations
                    JMP ShortLoop       ; N: Do the short loop

; Collision checking...

ContinueGame:       LDA deathBreak01,X  ; Current player dead?
                    BNE PlayerDead      ; Y: Continue death break...
                    TXA                 ; N: Switch...
                    EOR #$01            ; ... to other...
                    TAX                 ; ... player
                    LDA $30,X           ; 
                    AND #$80            ; player hit by others missle?
                    BEQ NotHit          ; N: Continue, we're not hit
                    LDY #$3B            ; Y: Y-> Offset for deathshape
                    LDA #$FF            ; Erase bullet by:
                    STA RESMP0,X        ; 1 - Locking missile to player
                    LDA gunState01,X    ;
                    AND #$F7            ;
                    STA gunState01,X    ; 2 - Clearing FIRE state
                    TXA                 ; Switch...
                    EOR #$01            ; ... to other...
                    TAX                 ; ... player again...
                    STY shapeOffset01,X ; show death-pic now...
                    BIT tempVar04       ; Difficulty A?
                    BVC DifficultyB     ; N: Difficulty B
                    LDA #$FF            ; Y: Erase own bullet
                    STA RESMP0,X        ; 1 - Lock missile to player
                    LDA gunStateBackup  ;
                    AND #$F7            ;
                    STA gunStateBackup  ; 2 - Clear FIRE state
DifficultyB:        LDA #$1F            ; 
                    STA deathBreak01,X  ; Set up death break
                    TXA                 ; Switch...
                    EOR #$01            ; ... to other...
                    TAX                 ; ... player - again!
                    SED                 ; Decimal mode ON
                    CLC                 ; 
                    LDA bcdScore01,X    ;
                    ADC #$01            ; Increase others score by one
                    STA bcdScore01,X    ; Store it
                    CMP #$10            ; Already 10 hits?
                    BNE ContinuePlaying ; N: Continue Playing
                    STA gameState       ; Y: Game Over!
ContinuePlaying:    
                    TXA                 ; Switch to other...
                    EOR #$01            ; ... player - again!
                    TAX                 ; ... huh...
                    CLD                 ; Decimal mode OFF

                    LDA #$07            ; Select distortion 7
                    JSR DeathSFX        ;
PlayerDead:         JMP HitNotHitDone   ; Hit handling done

NotHit:             LDY deathBreak01,X  ; Check other player
                    TXA                 ; Switch to other...
                    EOR #$01            ; ... player - again!
                    TAX                 ; ... what...
                    TYA                 ; Other player dead?
                    BNE PlayerDead      ; Y: Continue death break...

; Check if player needs to move

                    LDA gameSettingBits ; 
                    AND #$04            ; Player can still move?
                    BNE StillMove       ; Y:
                    LDA gunStateBackup  ; N:
                    AND #$08            ; Bullet fired?
                    BEQ StillMove       ; N:
                    JMP MovementDone    ; Y: No movement atm

; Select shape for player X:

StillMove:          LDA #$00            ; 
                    STA shapeOffset01,X ; Set standard shape
                    BIT tempVar04       ; Fire Button pressed?
                    BMI FireNotPressed  ; N: 
                    LDA #$49            ; Y: 
                    STA shapeOffset01,X ; Set 'norm' firing shape
FireNotPressed:     BIT tempVar04       ; Fire Button pressed?
                    BMI StillNoFire     ; N:
                    LDA tempVar04       ; Y: A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$01            ; Firing 'up'?
                    BNE NoFireUp        ; N: 
                    LDA #$1F            ; Y:
                    STA shapeOffset01,X ; Set 'up' firing shape
NoFireUp:           LDA tempVar04       ; A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$02            ; Firing down?
                    BNE ShapeSelected   ; N: Done selecting
                    LDA #$2F            ; Y:
                    STA shapeOffset01,X ; Set 'down' firing shape
ShapeSelected:      JMP MovementDone    ; Done selecting
StillNoFire:        LDA $32,X           ; Read collision PX/PF
                    AND #$80            ; Cowboy hit Playfield?
                    BNE BorderReached   ; Y: Border reached!
                    LDA tempVar04       ; N: A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$0F            ; Mask movement
                    CMP #$0F            ; Any movement at all?
                    BEQ ShapeSelected   ; N: Done selecting
                    LDA tempVar04       ; Y: A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$01            ; Moving 'up'?
                    BNE NoMovingUp      ; N:
                    LDA verPlayerOff01,X; Y: Player vert Offset = $00?
                    BEQ ShapeSelected   ; Y: Done, no movement
                    LDA frameCounter    ; N: Decrement...
                    AND #$02            ; ...vertical Offset...
                    BNE NoMovingUp      ; ...every 4th...
                    DEC verPlayerOff01,X; ...frame
NoMovingUp:         LDA tempVar04       ; A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$02            ; Moving 'down'?
                    BNE NoMovingDown    ; N:
                    LDA verPlayerOff01,X; Y: Player vert Offset = $16?
                    CMP #$16            ;
                    BEQ MovementDone    ; Y: Done, no movement
                    LDA frameCounter    ; N: Increment...
                    AND #$02            ; ...vertical Offset...
                    BNE NoMovingDown    ; ...every 4th...
                    INC verPlayerOff01,X; ...frame
                    JMP NoMovingDown    ; Done here...

; The following code determines the horizontal movement of a player
; that hit the playfield. This causes the player to move 'out' 
; of the playfield again.
; the bounce value works like this:
; when negative: left border reached, move right
; when <$18: right border reached, move left
; when between $18 & $7F: each player to his side

BorderReached:      LDY #$00            ; Assume moving right
                    LDA tempVar04       ; A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$F0            ; Clear movement
                    STA tempVar04       ; tempVar4->FIRE/DIF/X/X/0/0/0/0
                    LDA bouncePos01,X   ; bounce value negtive?
                    BMI StartMove       ; Y: move player right
                    LDY #$01            ; N: Assume moving left...
                    CMP #$18            ; bounce value <$18?
                    BCC StartMove       ; Y: move player left
                    LDY #$01            ; Assume moving left...
                    STY tempVar06       ; store temporary
                    TXA                 ; A-> 0 v 1 
                    EOR tempVar06       ; A-> 1 v 0
                    TAY                 ; Y-> left (P1) v right (P2)
StartMove           LDA #$04            ; Assume moving !right!
                    CPY #$00            ; Y = 0?
                    BEQ MoveCB          ; Y: Move right!
                    ASL                 ; N: move left
MoveCB:             ORA tempVar04       ; Store a fake movement 
                    STA tempVar04       ; in tempVar 4

NoMovingDown:       LDA tempVar04       ; A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$04            ; Moving 'left'?
                    BNE NoMovingLeft    ; N: Not moving left
                    LDA #$10            ; One Pixel to the left!
                    STA HMP0,X          ; Store in fine moving register
                    LDA #$01            ; +1 to bouncePos01!
                    JMP CalcNewBouncePos;
NoMovingLeft:       LDA tempVar04       ; A->FIRE/DIFF/X/X/R/L/D/U
                    AND #$08            ; Moving 'right'?
                    BNE NoMovingRight   ; N: Not moving right
                    LDA #$F0            ; One Pixel to the right!
                    STA HMP0,X          ; Store in fine moving register
                    LDA #$FF            ; -1 to bouncePos01!
CalcNewBouncePos:   CLC                 ;
                    ADC bouncePos01,X   ;
                    STA bouncePos01,X   ; adjust bouncePos

; do the walking animation

NoMovingRight:      LDA frameCounter    ; 
                    STA tempVar07       ; store framecounter temporary
                    TXA                 ; A-> 0 v 1 (player)
                    ASL                 ; A-> 0 v 2
                    ASL                 ; A-> 0 v 4
                    CLC                 ; 
                    ADC tempVar07       ; A->frameCounter/frameCounter+4
                    TAY                 ; Y->frameCounter/frameCounter+4
                    AND #$10            ; Swap the walking shape...
                    BEQ WalkShapeOk     ; 
                    LDA #$0D            ; 
                    STA shapeOffset01,X ; ...every 32 frames
WalkShapeOk:        TYA                 ; A->Y->frameCounter/frameCounter+4
                    ORA #$F1            ; A->%1111XXX1
                    CMP #$F1            ; 2 out of 16 frames?
                    BNE MovementDone    ; N: No sound to play
                    LDA #$08            ; Y: Play the 'walk' sound FX
                    JSR WalkSFX         ;

; See if we can fire a bullet

MovementDone:       LDA gunStateBackup  ; A -> current gunstate of X
                    AND #$10            ; Gun empty?
                    BNE HitNotHitDone   ; Y: No fire
                    LDA gunStateBackup  ; A -> current gunstate of X
                    AND #$08            ; Gun already in FIRE state?
                    BNE HitNotHitDone   ; N: No fire
                    BIT tempVar04       ; Y: Fire Button pressed?
                    BPL HitNotHitDone   ; N: No fire
                    BIT gunStateBackup  ; Y: Fire is forbidden?
                    BMI HitNotHitDone   ; Y: No fire
                    LDA #$08            ; Distortion 8
                    JSR DeathSFX        ; play 'Fire' SFX
                    ASL bulletsInGun01,X; One bullet fired
                    LDA gunStateBackup  ; A -> current gunstate of X
                    ORA #$08            ; Set FIRE state
                    AND #$BF            ; 
                    STA gunStateBackup  ; Clear BOUNCEBEFORE state
                    LDA #$00            ;
                    STA saverColor      ; Clear savercolor
                    STA RESMP0,X        ; Locking missile to player

; Set the starting position of bullets
; 1. calculate vertical position

                    LDA shapeOBackup01,X; Restore...
                    STA shapeOffset01,X ; ...shapeOffset...
                    STA shapeOBackup11,X; ...and the second backup
                    TAY                 ; Y->shapeOffset
                    LDA LF6FD,Y         ; Load first control byte of
                    JSR Shift4BitsRight ; shape & select higher nibble
                    CLC                 ; 
                    ADC verPlayerOff01,X; Add vertical offset
                    STA bulletVerPos01,X; store in bullet verpos

; 2. Set horizontal position: It's the same as the bounce pos,
; so the bullets horizontal position is stored in reverse, too!

                    LDA bouncePos01,X   ;
                    STA bulletHorPos01,X;
HitNotHitDone:      
                    ASL gunStateBackup  ; Move the FIRE Button state
                    ASL tempVar04       ; from tempVar04 into
                    ROR gunStateBackup  ; tempVar 05
                    LDA deathBreak01,X  ; Player dead?
                    BEQ PlayerAlive     ; Y: It lives
                    DEC deathBreak01,X  ; N: Deathbreak continues
                    LDA gunStateBackup  ; Dead player must not fire...
                    ORA #$80            ; 
                    STA gunStateBackup  ; ...so FORBIDDEN bit is set!
PlayerAlive:        LDA #$22            ; Bounce at the bottom of...
                    STA vertBouncePos   ; ...our playfield.
                    LDA gameSettingBits ; A-> settings of actual variant
                    AND #$20            ; SinglePlayer mode?
                    BEQ SinglePlayerDone; N: Twoplayer mode
                    LDA #$58            ;
                    STA shapeOffset02   ; Set 'Target' shape
                    STA shapeOBackup12  ; Make a backup
                    LDA bulletVerPos02  ; Always tie bullet...
                    STA verPlayerOff02  ; ... to 'Target'
                    LDA frameCounter    ;
                    AND #$3F            ; 1/64th frame?
                    BNE DontCount       ; N: Done here
                    SED                 ; Y: Increment single...
                    SEC                 ; ...player counter
                    ADC bcdScore02      ; ... up to 99
                    STA bcdScore02      ;
                    CMP #$99            ; 99 reached?
                    BNE DontCount       ; N: Continue
                    STA gameState       ; Y: Game Over!

DontCount:          CLD                 ; Decimal mode Off
                    TXA                 ; Player or 'Target'?
                    BEQ SinglePlayerDone; Player: We're done
                    LDA #$1B            ; 'Target': Set bounce...
                    STA vertBouncePos   ; pos of 'Target' shape!
                    LDA gunStateBackup  ; 
                    ORA #$08            ; 
                    STA gunStateBackup  ; set FIRED state of gun
SinglePlayerDone:   LDA gunStateBackup  ; 
                    AND #$08            ; Gun Fired?
                    BEQ BounceDone      ; N: No Bullet Flying

; Move the bullets!

                    LDY shapeOBackup11,X; Y: Offset of current X shape
                    BIT gunStateBackup  ; Bullet moves UP?
                    BVC MoveBulletDown  ; N: No, move it down
                    DEY                 ; Y: Move Bullet UP
MoveBulletDown:     LDA LF6FD-1,Y       ; A-> movement value -1 v +1 v 0
                    CLC                 ;
                    ADC bulletVerPos01,X; A-> current vpos + mov val
                    STA bulletVerPos01,X; write new vertical position
                    LDY shapeOBackup11,X; Y: Offset of current X shape
                    TXA                 ; Left or right player?
                    BEQ LF4EA           ; Left: Move bullet right
                    DEY                 ; Right: Move bullet left
LF4EA:              LDA PFDone,Y        ; A-> movement value -4 v +4 v 0
                    TAY                 ; Y-> movement value -4 v +4 v 0
                    CLC                 ; 
                    ADC bulletHorPos01,X; A-> current vpos + mov val
                    STA bulletHorPos01,X; write new horizontal position
                    TYA                 ; A-> movement value -4 v +4 v 0
                    ASL                 ; 
                    ASL                 ;
                    ASL                 ;
                    ASL                 ; A-> 40 v C0
                    STA HMM0,X          ; Missile movement -4 v +4 v 0!

; Bounce the bullets!

                    LDA bulletVerPos01,X; verpos rised below 0?
                    BPL CheckBottom     ; N: check bottom border
                    LDA #$00            ; Y: Reset missile to 0
                    BEQ TopBounce       ; Jump always, bounce on top
CheckBottom:        CMP vertBouncePos   ; verpos dropped above border?
                    BCC BounceDone      ; N: Everything ok with bulets
                    LDA vertBouncePos   ; Y: Reset missle to vertB.Pos
                    BNE TopBounce       ; ...!Useless instruction!...
TopBounce:          STA bulletVerPos01,X; Store reseted bullet position
                    LDA gunStateBackup  ;
                    EOR #$40            ; Reverse bullet movement dir
                    STA gunStateBackup  ;
                    JSR SelectSFX       ; Play 'Bounce' SFX

BounceDone:         LDA gunStateBackup  ;
                    STA gunState01,X    ; Write new gunState

                    LDA $34,X        ; 
                    AND #$80            ; Bullet X hit Playfield?
                    BEQ NoBulPFCollision; N: Get outta here
                    LDA gameSettingBits ; A-> settings of actual variant
                    AND #$08            ; Shootable obstacles?
                    BNE ShootableObst   ; Y: Disintegrate obstacle
RemoveBullet:       LDA gunState01,X    ; 
                    AND #$B7            ; Clear UP & FIRE state
                    STA gunState01,X    ;
                    STA gunStateBackup  ; in backup, too
                    LDA #$02            ;
                    STA RESMP0,X        ; Locking missile to player
                    LDA #$08            ;
                    JSR WalkSFX         ; Play the 'PF Hit' sound FX
                    LDA gunStateBackup  ; 
                    STA gunState01,X    ; Write new gunState
NoBulPFCollision:   JMP PFDestructDone  ;

; Check if bullet hits the borders

ShootableObst:      LDA bulletVerPos01,X;
                    STA tempVar04       ; Temporary store bulletVerPos01
TryErasingAgain:    LDA bulletHorPos01,X; A-> Bullets horizontal pos
                    JSR Shift4BitsRight ; A-> bulletHorPos/16
                    TAY                 ; Y-> bulletHorPos/16
                    BEQ RemoveBullet    ; Left border reached
                    CMP #$09            ; (145,146,...,159)/16 = 9.X
                    BEQ RemoveBullet    ; Right border reached

; Here the Playfield gets disintegrated!

; First we calculate the vertical position where the PF was hit.
; The current bullet pos is simply added to the obstacle offset
; Example:
; Obstacle vertical offset = 2 / Bullet vertical pos = 2
; Looks on screen like this:
;
; Line: Visible:                        Obstacle stored in RAM:
; -2    Obstacle starts here!           +0
; -1                                    +1
; +0    Visible Screen starts here!     +2
; +1                                    +3
; +2    bullet starts here!             +4
;
; So we have to delete an obstacle byte in line 2+2=4!
; If we have an overflow (i.e. the sum getting >$24) we simply 
; subtract $24 as our system is repeating

                    LDA obstacleVertPos ; A->obstacleVertPos
                    LSR                 ; 
                    LSR                 ; A->obstacleVertPos/4
                    STA ObstInKernelPos ; store calc'ed pos temporary
                    LDA tempVar04       ; A-> Bullets vertical pos
                    CLC                 ;
                    ADC ObstInKernelPos ; A-> Bullet + obstacle offset
                    CMP #$24            ; Calc'ed Hitpos < 24?
                    BCC HitPosOk        ; Y: Accept value
                    SEC                 ; N: Force it into range again
                    SBC #$24            ; 
HitPosOk:           LSR                 ; A-> [0,1,...18]!
                    CLC                 ; That's our vertical position!

; Now We've to find the right position in the RAM.
; Our vertical position offset ranges from 0-18,
; but depending on wether we've to erase PF0,PF1 v PF2a/PF2b
; we've to add different offsets.
; Y is holding our hoizontal position / 16, so it's used to access
; A table that determines the RAM offset.

                    ADC ramoffsettable,Y;
                    STA destructOffset  ; Store Offset to destruction
                    AND #$7F            ; Clear highest Bit
                    TAY                 ; Y-> Offset to destruction

; The bullets horizontal position is divided by 4, since this is the 
; width in pixels of a PF Bit

                    LDA bulletHorPos01,X; A->bulletHorPos
                    LSR                 ;
                    LSR                 ; A->bulletHorPos/4
                    CMP #$14            ; Left side of the screen?
                    BCC RightSide       ; N: Go to the right side

; On the left side the PF strts with PF0, which we don't take care about
; So we jus throw the value away by shifting the whole sequence
; 4 Bits left with a little EOR trick. SBC #$04 would've probably 
; done the same...

                    EOR #$04            ; shift hit pos 4 bits left
RightSide:          AND #$07            ; Mask our Bit number
                    STA tempVar07       ; Store temporary

; Now we possibly landed on PF1 and have to reverse it according
; to our previous table selection:

                    BIT destructOffset  ; Highest bit set?
                    BPL NOTPF1          ; Y: Everythings Ok
                    LDA #$07            ; N: Reverse the bits
                    SEC                 ;
                    SBC tempVar07       ;
                    STA tempVar07       ; store corrected val temporary
NOTPF1:             LDX tempVar07       ; X-> Bit to erase
                    LDA erasemask,X     ; A-> Mask to erase Bit
                    AND.wy $0080,Y      ; Test if Bit is set
                    BNE DoErasing       ; Y: Got it! Go Erasing
                    INY                 ; N: Try next line below
                    LDA erasemask,X     ; A-> Mask to erase Bit
                    AND.wy $0080,Y      ; Test if Bit is set
                    BNE DoErasing       ; Y: Got it! Go Erasing

; If we didn't get a hit by now, something went wrong...

                    LDA frameCounter    ; N: Maybe both bullets hit?
                    AND #$01            ;
                    TAX                 ; Swap to other bullet
                    LDA tempVar04       ; A-> Bullets vertical pos
                    CMP bulletVerPos01,X; Bullet same verpos?
                    BNE DoErasing       ; N: Erase for other bullet
                    DEC tempVar04       ; Y: Try again next line...
                    DEC bulletHorPos01,X; ... shifted to the left
                    JMP TryErasingAgain ; Try again...

; Erase on bit in the PF finally!

DoErasing:          LDA erasemask,X     ; A->erasemask
                    EOR #$FF            ; inverted for deletion
                    AND.wy $0080,Y      ; ANDed to delete
                    STA.wy $0080,Y      ; Store new obstacle look
                    LDA frameCounter    ; Erase _current_ bullet...
                    AND #$01            ; ...under any circumstances
                    TAX                 ;
                    JMP RemoveBullet    ; Remove it
PFDestructDone:     TXA                 ; A-> Player X
                    BEQ NoCollisionClear; Clear collisions... 
                    STA CXCLR           ; ...every second frame
NoCollisionClear:   JSR MovePlayer      ; Move player X

ShortLoop:          BIT gameSettingBits ; Move bit 6 into V-Flag
                    BVC DontMoveObstacle; Bit 6 was set?
                    INC obstacleVertPos ; Y: Move the obstacle vertical!
                    LDA obstacleVertPos ; Get obstacles new position
                    EOR #$8F            ; obstacleVertPos = 144/6 = 24?
                    BNE DontMoveObstacle; N: Continue
                    STA obstacleVertPos ; Y: Star over with pos 0
DontMoveObstacle:   JMP MainLoop        ;
                                        
; Move a player both vertical and horizontal
; in:   X -> the player to be moved

MovePlayer:         LDY shapeOffset01,X ; 
                    LDA LF6FD,Y         ; Load first byte of shape
                    AND #$0F            ; Mask general shape offset
                    CLC                 ;
                    ADC verPlayerOff01,X; add current position offset
                    STA vertPosition01,X; store vertical position
                    LDA shapeOffset01,X ; 
                    STA shapeOBackup01,X; Backup shape start offset
                    STA WSYNC           ; Finish Current line
                    STA HMOVE           ; Move Player horizontally
                    BIT saverColor      ; In Screensaver Mode?
                    BPL AfterMovement   ; N: Continue
                    LDA #$EF            ; 
                    STA gameState       ; Y: Set saver state
AfterMovement:      RTS                 ;

; The next routine has several entry points. Depending on the taken
; entry a sound effect is played
; in:   X -> the player for whom a sound effect is played

; Play 'Select is pressed' & 'Bounce' sound 
SelectSFX:
                    LDA #$04            ;
                    STA AUDC0,X         ; Select distortion 4
                    LDY #$00            ; Fast frequency change
                    LDA #$10            ; Volume 10
                    BNE StartSFX        ; Play SFX!

; Play 'Player hit by bullet' (7) & 'Fired' (8) sound
DeathSFX:
                    LDY #$01            ; Slow frequency change
                    STA AUDC0,X         ; selects distortion 7 v 8
                    LDA #$10            ; Volume 10
                    BNE StartSFX        ; Play SFX!

; Play the 'Walk' & 'Playfield hit by Bullet' sound
WalkSFX:            
                    LDY #$00            ; Fast frequency change
                    STA AUDC0,X         ; selects distortion 8
                    LDA #$08            ; Volume 8
StartSFX:           
                    STY soundSpeed01,X    ; Store change speed
                    STA audioVolume01,X ; Set volume
                    LDA #$05            ; Start with pitch 5...
                    STA audioFreq01,X   ; ...It's increased from there
                    RTS                 ;

; Draws the borders of the action field
                                        
TopBottomBorder:    STA WSYNC           ;
                    LDA #$FF            ; A->pattern of the border
                    JSR SetPlayfield    ; Set pattern
                    LDX #$08            ;
BorderLines:        STA WSYNC           ;
                    DEX                 ;
                    BNE BorderLines     ; Draw 8 Borderlines
                    RTS                 ;
                    
; Shifts 4 or 5 bits depending on entry point
; Wastes 20 or 22 cycles depending on entry point
; in:   A -> value to shift

Shift5BitsRight:    LSR                 ;
Shift4BitsRight:    LSR                 ;
                    LSR                 ;
                    LSR                 ;
                    LSR                 ;
                    RTS                 ;

; Clears or sets playfield pattern
; in:   A -> pattern

ClearPlayField:     LDA #$00            ;
SetPlayfield:       STA PF1             ;
                    STA PF0             ;
                    STA PF2             ;
                    RTS                 ;

; Reset everything

Start:                                  
                    SEI                 ; Disable interrupts
                    CLD                 ; Binary mode
                    LDX #$00            ;
                    TXA                 ;
Clearmem:           STA $00,X           ;
                    INX                 ;
                    BNE Clearmem        ; Zero out the zeropage
                    INC bcdGameVariant  ; Start with game variation 1
ResetSelectdone:    LDX #$FF            ;
                    TXS                 ; Restore stack

; Init the current game variation
                                        
                    LDX #$01            ; Two players to init
InitBothPlayers:    LDA #$00            ;
                    STA obstacleVertPos ; Reset obstacle position
                    STA saverColor      ; Normal colors
                    STA shapeOBackup11,X; Reset shape backups
                    STA deathBreak01,X  ; Revive both players
                    STA shapeOffset01,X ; Reset to cowboy shapes
                    LDY bcdGameVariant  ; Y -> 1-16 bcd
                    DEY                 ; Y -> 0-15 bcd
                    LDA gamesettingtab,Y; A-> settings of actual variant
                    STA gameSettingBits ; store settings
                    AND #$20            ; Singleplayer?
                    BEQ TwoPlayer       ; N: Player 2 keeps cowboy shape
                    LDA #$58            ; 
                    STA shapeOffset02   ; Y: Swap to target shoot shape
TwoPlayer:          LDA #$1D            ; 
                    STA NUSIZ0,X        ; Double sized players/missiles
                    STA REFP1           ; Reflect player 2
                    LDA #$96            ; 
                    STA bouncePos01     ; Set bounce position of player 1
                    STA RESMP0,X        ; Locking missile to player
                    LDA #$0D            ;
                    STA bouncePos02     ; Set bounce position of player 2
                    LDA #$FC            ; A -> 'XXXXXX00'
                    STA bulletsInGun01,X; Load gun with 6 Bullets
                    LDA gunState01,X    ; A -> gun state
                    ORA #$80            ; Gun loaded...
                    AND #$87            ; ... & Not Fired
                    STA gunState01,X    ; store gun state
                    LDA #$05            ; 
                    STA verPlayerOff01,X; Position players vertical
                    JSR MovePlayer      ; Move player X
                    STA CXCLR           ; Clear collision registers
                    DEX                 ;
                    BPL InitBothPlayers ; Init second player

; Position Players

                    STA WSYNC           ; 
                    JSR Shift4BitsRight ; Waste 20 cycles
                    STA RESP0           ; Set Player 1
                    JSR Shift4BitsRight ;
                    JSR Shift4BitsRight ; Waste 40 cycles
                    STA RESP1           ; Set Player 2

; Init the playfield data

                    LDX #$00            ;
ContinuePFInit:     LDA #$00            ;
                    STA PF2Array01,X    ; Init PF2 arr 1 with '00000000'
                    STA PF1Array,X      ; Init PF1 array with '00000000'
                    LDA #$01            ;
                    STA PF0Array,X      ; Init PF0 array with '00000001'
                    LDA #$80            ;
                    STA PF2Array02,X    ; Init PF2 arr 2 with '10000000'
                    INX                 ; Next element
                    CPX #$12            ; All elements done?
                    BNE ContinuePFInit  ; N: continue PF init

                    LDA gameSettingBits ; A-> settings of actual variant
                    AND #$03            ; Mask WALL/COACH
                    TAX                 ; X-> WALL/COACH
                    CMP #$02            ; Variant with wall?
                    BNE NoWall          ; N: No Wall
                    LDY #$00            ; Y: Create Wall
CreateWall:         LDA #$71            ;
                    STA.wy $0080,Y      ; Init PF0 array with '01110001'
                    LDA #$E0            ;
                    STA.wy $00A4,Y      ; Init PF2 arr 1 with '11100000'
                    INY                 ; next line
                    CPY #$12            ; Wall created?
                    BNE CreateWall      ; N: continue creating wall
                    JMP MainLoop        ; Y: Start game loop

; copy all needed graphic blocks for coach or cactus to PF

NoWall:             LDA cactuscoachptr,X; A-> 0 v 10 (cactus v coach)
                    TAX                 ; X-> 0 v 10 (cactus v coach)
NextBlock:          LDA cactuscoachtab,X; A-> block position
                    CMP #$A0            ; PF obstacle finished?
                    BEQ PFDone          ; Y: Start game loop
                    JSR Shift5BitsRight ; A-> desired PF for block
                    TAY                 ; Y-> desired PF for block
                    LDA pfselecttab,Y   ; A-> PF Offset...
                    STA tempVar01         ; ...store temporary
                    LDA cactuscoachtab,X; A-> block position
                    AND #$1F            ; Mask block offset
                    CLC                 ; 
                    ADC tempVar01         ; A-> PF offset + block offset
                    TAY                 ; Y-> Block absolute position
                    INX                 ; X-> point to block start
DoBlock:            LDA cactuscoachtab,X; load block data...
                    STA tempVar01         ; ...store temporary
                    CMP #$AA            ; block finished?
                    BNE StoreBlockData  ; N: store block data
                    INX                 ;
                    JMP NextBlock       ; Y: Next block
StoreBlockData:     LDA tempVar01         ; load block data
                    STA.wy $0080,Y      ; store at desired PF position
                    INX                 ; next block line
                    INY                 ; next destination position
                    JMP DoBlock         ; continue with block
PFDone:             JMP MainLoop        ;

LF6FD: .byte $00 ; BlockOffset

LF6FE: .byte $18 ; |   XX   | $F6FE
       .byte $3E ; |  XXXXX | $F6FF
       .byte $1C ; |   XXX  | $F700
       .byte $18 ; |   XX   | $F701
       .byte $7E ; | XXXXXX | $F702
       .byte $99 ; |X  XX  X| $F703
       .byte $99 ; |X  XX  X| $F704
       .byte $99 ; |X  XX  X| $F705
       .byte $5A ; | X XX X | $F706
       .byte $3C ; |  XXXX  | $F707
       .byte $66 ; | XX  XX | $F708
       .byte $C3 ; |XX    XX| $F709
       .byte $00 ; ShapeEnd

       .byte $18 ; |   XX   | $F70B
       .byte $3E ; |  XXXXX | $F70C
       .byte $1C ; |   XXX  | $F70D
       .byte $18 ; |   XX   | $F70E
       .byte $7E ; | XXXXXX | $F70F
       .byte $99 ; |X  XX  X| $F710
       .byte $99 ; |X  XX  X| $F711
       .byte $99 ; |X  XX  X| $F712
       .byte $5A ; | X XX X | $F713
       .byte $3C ; |  XXXX  | $F714
       .byte $24 ; |  X  X  | $F715
       .byte $36 ; |  XX XX | $F716
       .byte $00 ; ShapeEnd

; horizontal bullet movement either +4 or -4
       .byte $04 ; |     X  | $F718
       .byte $FC ; |XXXXXX  | $F719

; vertical bullet movement either -1 or +1
       .byte $01 ; |       X| $F71A
       .byte $FF ; |XXXXXXXX| $F71B

       .byte $72 ; | XXX  X | $F71C
       .byte $60 ; | XX     | $F71D
       .byte $F8 ; |XXXXX   | $F71E
       .byte $72 ; | XXX  X | $F71F
       .byte $64 ; | XX  X  | $F720
       .byte $7C ; | XXXXX  | $F721
       .byte $60 ; | XX     | $F722
       .byte $60 ; | XX     | $F723
       .byte $78 ; | XXXX   | $F724
       .byte $28 ; |  X X   | $F725
       .byte $EC ; |XXX XX  | $F726
       .byte $00 ; ShapeEnd

; horizontal bullet movement either +4 or -4
       .byte $04 ; |     X  | $F728
       .byte $FC ; |XXXXXX  | $F729

; vertical bullet movement either -1 or +1
       .byte $FF ; |XXXXXXXX| $F72A
       .byte $01 ; |       X| $F72B

       .byte $82 ; |X     X | $F72C
       .byte $60 ; | XX     | $F72D
       .byte $F8 ; |XXXXX   | $F72E
       .byte $70 ; | XXX    | $F72F
       .byte $60 ; | XX     | $F730
       .byte $70 ; | XXX    | $F731
       .byte $6C ; | XX XX  | $F732
       .byte $62 ; | XX   X | $F733
       .byte $78 ; | XXXX   | $F734
       .byte $28 ; |  X X   | $F735
       .byte $EC ; |XXX XX  | $F736
       .byte $00 ; ShapeEnd

       .byte $04 ; |     X  | $F738
       .byte $30 ; |  XX    | $F739
       .byte $7C ; | XXXXX  | $F73A
       .byte $38 ; |  XXX   | $F73B
       .byte $30 ; |  XX    | $F73C
       .byte $70 ; | XXX    | $F73D
       .byte $B0 ; |X XX    | $F73E
       .byte $B1 ; |X XX   X| $F73F
       .byte $7F ; | XXXXXXX| $F740
       .byte $00 ; ShapeEnd

; horizontal bullet movement either +4 or -4
       .byte $04 ; |     X  | $F742
       .byte $FC ; |XXXXXX  | $F743

; vertical bullet movement always zero at 0°
       .byte $00 ; |        | $F744
       .byte $00 ; |        | $F745

       .byte $62 ; | XX   X | $F746
       .byte $60 ; | XX     | $F747
       .byte $F8 ; |XXXXX   | $F748
       .byte $70 ; | XXX    | $F749
       .byte $67 ; | XX  XXX| $F74A
       .byte $7C ; | XXXXX  | $F74B
       .byte $60 ; | XX     | $F74C
       .byte $60 ; | XX     | $F74D
       .byte $78 ; | XXXX   | $F74E
       .byte $28 ; |  X X   | $F74F
       .byte $EC ; |XXX XX  | $F750

; horizontal "Target" movement always zero at 90°
       .byte $00 ; ShapeEnd
       .byte $00 ; |        | $F752

; vertical "Target" movement either -1 or +1
       .byte $01 ; |       X| $F753
       .byte $FF ; |XXXXXXXX| $F754

       .byte $00 ; BlockOffset
       .byte $3C ; |  XXXX  | $F756
       .byte $42 ; | X    X | $F757
       .byte $99 ; |X  XX  X| $F758
       .byte $A5 ; |X X  X X| $F759
       .byte $99 ; |X  XX  X| $F75A
       .byte $42 ; | X    X | $F75B
       .byte $3C ; |  XXXX  | $F75C

cactuscoachptr: .byte $00, $10

scoreshapedata: .byte $0E ; |    XXX |
                .byte $0A ; |    X X |
                .byte $0A ; |    X X |
                .byte $0A ; |    X X |
                .byte $0E ; |    XXX |

                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |

                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $EE ; |XXX XXX |
                .byte $88 ; |X   X   |
                .byte $EE ; |XXX XXX |

                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $66 ; | XX  XX |
                .byte $22 ; |  X   X |
                .byte $EE ; |XXX XXX |

                .byte $AA ; |X X X X |
                .byte $AA ; |X X X X |
                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |

                .byte $EE ; |XXX XXX |
                .byte $88 ; |X   X   |
                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $EE ; |XXX XXX |

                .byte $EE ; |XXX XXX |
                .byte $88 ; |X   X   |
                .byte $EE ; |XXX XXX |
                .byte $AA ; |X X X X |
                .byte $EE ; |XXX XXX |

                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |
                .byte $22 ; |  X   X |

                .byte $EE ; |XXX XXX |
                .byte $AA ; |X X X X |
                .byte $EE ; |XXX XXX |
                .byte $AA ; |X X X X |
                .byte $EE ; |XXX XXX |

                .byte $EE ; |XXX XXX |
                .byte $AA ; |X X X X |
                .byte $EE ; |XXX XXX |
                .byte $22 ; |  X   X |
                .byte $EE ; |XXX XXX |

colortab: .byte $48,$24,$88,$66
          .byte $26,$48,$68,$84
          .byte $38,$64,$44,$16
          .byte $54,$88,$18,$26

cactuscoachtab: .byte $06 ; BlockPosition
                .byte $51 ; | X X   X|
                .byte $51 ; | X X   X|
                .byte $71 ; | XXX   X|
                .byte $11 ; |   X   X|
                .byte $11 ; |   X   X|
                .byte $11 ; |   X   X|
                .byte $11 ; |   X   X|
                .byte $11 ; |   X   X|

                .byte $AA ; BlockEnd
                .byte $48 ; BlockPosition

                .byte $40 ; | X      |
                .byte $40 ; | X      |
                .byte $C0 ; |XX      |

                .byte $AA ; BlockEnd
                .byte $A0 ; cactus data end
                .byte $04 ; BlockPosition

                .byte $71 ; | XXX   X|
                .byte $F1 ; |XXXX   X|
                .byte $E1 ; |XXX    X|
                .byte $C1 ; |XX     X|
                .byte $C1 ; |XX     X|
                .byte $F1 ; |XXXX   X|
                .byte $F1 ; |XXXX   X|
                .byte $F1 ; |XXXX   X|

                .byte $AA ; BlockEnd
                .byte $68 ; BlockPosition

                .byte $40 ; | X      |
                .byte $40 ; | X      |
                .byte $E0 ; |XXX     |
                .byte $40 ; | X      |
                .byte $40 ; | X      |

                .byte $AA ; BlockEnd
                .byte $44 ; BlockPosition

                .byte $E0 ; |XXX     |
                .byte $F0 ; |XXXX    |
                .byte $70 ; | XXX    |
                .byte $30 ; |  XX    |
                .byte $34 ; |  XX X  |
                .byte $F4 ; |XXXX X  |
                .byte $FE ; |XXXXXXX |
                .byte $F4 ; |XXXX X  |
                .byte $04 ; |     X  |

                .byte $AA ; BlockEnd
                .byte $A0 ; coach data end

pfselecttab: .byte $00 ; PF0Array
             .byte $12 ; dummy
             .byte $24 ; PF2Array01
             .byte $36 ; PF1Array
             .byte $48 ; PF2Array02

ramoffsettable: .byte $48 ; | X  X   | $F7D3
                .byte $48 ; | X  X   | $F7D4
                .byte $B6 ; |X XX XX | $F7D5
                .byte $B6 ; |X XX XX | $F7D6
                .byte $00 ; |        | $F7D7
                .byte $24 ; |  X  X  | $F7D8
                .byte $24 ; |  X  X  | $F7D9
                .byte $92 ; |X  X  X | $F7DA
                .byte $92 ; |X  X  X | $F7DB

erasemask:  .byte $80 ; |X       | $F7DC
            .byte $40 ; | X      | $F7DD
            .byte $20 ; |  X     | $F7DE
            .byte $10 ; |   X    | $F7DF
            .byte $08 ; |    X   | $F7E0
            .byte $04 ; |     X  | $F7E1
            .byte $02 ; |      X | $F7E2
            .byte $01 ; |       X| $F7E3

gamesettingtab:
;                              S      
;                              I      
;                              NS      
;                              GIS     
;                              LXH     
;                              ESO    
;                             MPHON   
;                             OLOTO C  
;                             VAOASWO   
;                             IYTBTAA   
;                             NEELULC   
;                             GRRENLH   
                .byte $00 ; |        | Variant 01
                .byte $04 ; |     X  | Variant 02
                .byte $08 ; |    X   | Variant 03
                .byte $18 ; |   XX   | Variant 04
                .byte $01 ; |       X| Variant 05
                .byte $41 ; | X     X| Variant 06
                .byte $09 ; |    X  X| Variant 07
                .byte $49 ; | X  X  X| Variant 08
                .byte $59 ; | X XX  X| Variant 09
                .byte $00 ; |        | not used -> BCD!
                .byte $00 ; |        | not used -> BCD!
                .byte $00 ; |        | not used -> BCD!
                .byte $00 ; |        | not used -> BCD!
                .byte $00 ; |        | not used -> BCD!
                .byte $00 ; |        | not used -> BCD!
                .byte $1A ; |   XX X | Variant 10
                .byte $4A ; | X  X X | Variant 11
                .byte $5A ; | X XX X | Variant 12
                .byte $20 ; |  X     | Variant 13
                .byte $28 ; |  X X   | Variant 14
                .byte $61 ; | XX    X| Variant 15
                .byte $69 ; | XX X  X| Variant 16

        ORG $F7FA

        .word Start
        .word Start
        .word Start