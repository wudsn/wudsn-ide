   LIST OFF
; ***  D O N K E Y  K O N G  ***
; Copyright 1982 Coleco Industries, Inc.
; Programmer: Garry Kitchen

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: 25.11.2003
;
; This was Garry's second Atari VCS game. For a second game I think this a great
; accomplishment. Remember, Garry learned to program the VCS by reverse engineering
; the hardware and various Activision games.
;
; His MainLoop is structured as...
;
; MainLoop
;  -overscan
;  -vertical blank
;  -kernel
;  jmp MainLoop
;
; Garry uses a horizontal position routine that *seems* to first appear in his
; Space Jockey game. This routine was modified over the years and has been seen
; in a number of games.
;
; To produce the PAL listing I used the CBS version. The PAL version adjusts the
; vertical blank time and overscan time to make the game produce 312 scan lines.
; The colors were also adjusted but it seems they missed the place in the kernel
; where Garry colors Mario directly. The speeds were not adjusted but the sound
; frequencies were.
;
; This game uses a lot overlays and a lot of offsets so I might have missed some
; variable meanings or table positions.

   processor 6502
      
   include vcs.h

   LIST ON

;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

NTSC            = 1             ; 1 = NTSC -or- 0 = PAL

;===============================================================================
; T I A - C O N S T A N T S
;===============================================================================

HMOVE_L7          =  $70
HMOVE_L6          =  $60
HMOVE_L5          =  $50
HMOVE_L4          =  $40
HMOVE_L3          =  $30
HMOVE_L2          =  $20
HMOVE_L1          =  $10
HMOVE_0           =  $00
HMOVE_R1          =  $F0
HMOVE_R2          =  $E0
HMOVE_R3          =  $D0
HMOVE_R4          =  $C0
HMOVE_R5          =  $B0
HMOVE_R6          =  $A0
HMOVE_R7          =  $90
HMOVE_R8          =  $80

; values for NUSIZx:
ONE_COPY          = %000
TWO_COPIES        = %001
TWO_WIDE_COPIES   = %010
THREE_COPIES      = %011
DOUBLE_SIZE       = %101
THREE_MED_COPIES  = %110
QUAD_SIZE         = %111

; values for REFPx:
NO_REFLECT        = %0000
REFLECT           = %1000

; SWCHA joystick bits:
MOVE_RIGHT        = %01111111
MOVE_LEFT         = %10111111
MOVE_DOWN         = %00100000
MOVE_UP           = %00010000
NO_MOVE           = %11111111

;============================================================================
; U S E R - C O N S T A N T S
;============================================================================

; color constants:
BLACK       =  $00
WHITE       =  $0F

   IF NTSC
   
ORANGE      =  $2F
BROWN       =  $34
TURQUISE    =  $A8
BLUE        =  $8A
YELLOW      =  $1E
BLONDE      =  YELLOW
RED         =  $46
RED_2       =  RED
SASH_RED    =  RED
PURPLE      =  $6A
LIGHT_GREEN =  $DA
BLUE_GREEN  =  $A6

   ELSE
   
ORANGE      =  $2B   
BROWN       =  $44
TURQUISE    =  $B7
BLUE        =  $C8
YELLOW      =  $28
BLONDE      =  $2E
RED         =  $44
RED_2       =  $46                  ; this seemed to a mistake in the PAL translation
SASH_RED    =  $69
PURPLE      =  $88
LIGHT_GREEN =  $38
BLUE_GREEN  =  $C8

   ENDIF

   IF NTSC

VBLANK_TIME       = $2D
OVERSCAN_TIME     = $23

   ELSE

VBLANK_TIME       = $4B
OVERSCAN_TIME     = $40

   ENDIF
   
; game state values
GAME_OVER                     = $00
START_NEW_LEVEL               = $01
LEVEL_COMPLETED               = $02

MAX_OBSTACLES                 = $04

WALKWAY_HEIGHT                = $1B
HAMMER_GROUP                  = $04
NUM_WALKWAYS                  = $05

STARTING_MARIOS               = $02 ; number of lives at the start of a game
MARIO_MOVE_RATE               = $02 ; decrement for faster mario -- increase for slower
MAX_HAMMER_TIME               = $03

HAMMER_HEIGHT                 = $0D

JUMP_HANGTIME                 = $1F
MARIO_STARTX                  = $31
BONUS_TIMER_DELAY             = $7F

PLAYER_HEIGHT                 = $14
MARIO_HEIGHT                  = $11
NUMBER_HEIGHT                 = $06

JUMPING_HEIGHT                = $07 ; increase this value for the high jump :-)

LADDER_RANGE                  = $03

FAIR_PIXEL_DELTA              = $09

OBSTACLE_HEIGHT               = $24
OBSTACLE_GRAPHIC_HEIGHT       = $08

TOP_PLATFORM_VALUE            = $0C

BARREL_SPRITE_NUMBER          = $00
FALLING_BARREL_SPRITE_NUMBER  = $01
FIREFOX_SPRITE_NUMBER         = $02

; obstacle moving state
OBSTACLE_MOVING_RIGHT   = $01
OBSTACLE_MOVING_LEFT    = $00
OBSTACLE_MOVING_DOWN    = $F0

; rivit constants
HORIZ_LEFT_RIVIT              = $36 ; horizontal position of left rivit
HORIZ_RIGHT_RIVIT             = $6A ; horizontal position of right rivit
COMPLETE_RIVIT_WALKWAY        = $12
LEFT_RIVIT_VALUE              = $06
RIGHT_RIVIT_VALUE             = $0C
MAX_FIREFOX_LADDERS           = $10

XMIN_LEVEL1                   = $24
XMAX_LEVEL1                   = $7C

; barrel constants
XMIN_ODD_LEVEL0               = $29
XMAX_ODD_LEVEL0               = $75
YMIN_LEVEL0                   = $0F
STARTING_BARREL_VERT          = TOP_PLATFORM_VALUE
STARTING_BARREL_HORIZ         = $25
BOTTOM_BARREL_PLATFORM_VALUE  = $91

; score constants
STARTING_BONUS                = $50
SMASHING_OBSTACLE             = $08

;============================================================================
; Z P - V A R I A B L E S
;============================================================================

verPosP1             = $80    ; $80 - $83

jumpHangTime         = $85
hammerTime           = $86
playerScore          = $87    ; $87-$88
marioFrameDelay      = $89
attractModeTimer     = $8A    ; incremented every other frame when it reaches
                              ; 0 then attract mode (color cycling) begins
soundIndex           = $8B
gameState            = $8C    ; 10000000 = game in progress
                              ; 00000010 = level complete (play music)
                              ; 00000001 = start of new level
                              ; 00000000 = game over
losingLifeFlag       = $8D    ; set to #$FF when Mario loses a life                              
attractMode          = $8E    ; when D7 = 1 then the game is in attract mode
soundDuration        = $8F
                              
gameScreen           = $90    ; $00 = barrels $01 = firefox
consoleDebounce      = $91    ; timer to check the console switches
backgroundColor      = $92
horPosMario          = $93
marioDirection       = $94    ;  Mario or Donkey Kong
missilePointer       = $95    ; $95 - $96
ballPointer          = $97    ; $97 - $98
holdObstacleNumber   = $99    ; used in overscan to loop through obstacles
playfieldColor       = $9A
verPosMario          = $9B
horPosHammer         = $9C

zpZero               = $9D    ; always 0 -- seems not to be used
zpZeroOrOne          = $9E    ; 0 for barrels 1 for firefox -- seems not to be used
rivits               = $9F    ; $9F-$A2

numberOfLives        = $A3
bonusTimer           = $A4
zpMarioGraphics      = $A5    ; $A5 - $C0

horPosP1             = $C1    ; $C1 - $C4
directionP1          = $C5    ; $C5 - $C8
                              ; %xxxx0001 = moving right
                              ; %xxxx0000 = moving left
                              ; %1111xxxx = moving down (ladder or off edge)
barrelLadderNumber   = $C9    ; $C9 - $CC
                              
coarseHorPosP1       = $CD    ; $CD - $D2
                              
fineHorPosP1         = $D3    ; $D3 - $D8

rightPF1Pointer      = $D9    ; $D9 - $DA
pf0Pointer           = $DB    ; $DB - $DC
                              
digitPointer         = $DD    ; $DD - $E5
;-------------------------------------------
pf2Pointer           = digitPointer
leftPF1Pointer       = digitPointer+2
obstaclePointer      = digitPointer+4  ; $E1 - $E2
marioGraphicPointer  = digitPointer+6  ; $E3 - $E4
;-------------------------------------------
marioColorPointer    = marioGraphicPointer
audioFrequecyPointer = marioGraphicPointer
marioOffset          = marioGraphicPointer+2  ; $E5
;-------------------------------------------
joystickValue        = marioOffset     ; $E5
groupCount           = joystickValue   ; $E5
;-------------------------------------------
obstacleOffset       = groupCount      ; $E5
;-------------------------------------------
loopCount            = $E6
randomSeed           = $E7
frameCount           = $E8
fireButtonDebounce   = $E9

ladderNumber         = $EA    ; holds the ladder number Mario is on
                              ; from top down
                              ; ($00 - $08) for barrels
                              ; ($12 - $21) for firefox
jumpingDirection     = $EB    ; hold whether the player was pushing right or
                              ; left on the joystick while jumping
jumpingObstacle      = $EC    ; when 0 -- Mario is jumping obstacle (add points)                              
walkwayNumber        = $ED    ; holds the walkway section Mario is in (0 - 5)
;-------------------------------------------
obstacleNumber       = walkwayNumber
;-------------------------------------------
missile1Size         = obstacleNumber
;-------------------------------------------
temp                 = missile1Size

hammerKernelVector   = $EE    ; pointer to hammer kernel ($EE - $EF)
kernelVector         = $F0    ; pointer to no ladder kerenel ($F0 - $F1)
obstaclePointerLSB   = $F2    ; $F2 - $F7
marioColorPointerLSB = $F8    ; $F8 - $FD

;===============================================================================
; R O M - C O D E (Part 1)
;===============================================================================

   SEG code
   org $F000
   
Start
;
; Set up everything so the power up state is known.
;
   sei
   cld
   ldx #$FF
   txs
   inx
   txa
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   
   jsr InitializeGame
   
   lda #STARTING_MARIOS
   sta numberOfLives
   dec consoleDebounce
   dec attractMode
       
MainLoop
   lda backgroundColor
   sta COLUBK
   ldy #$FF
   sty WSYNC                        ; end the current scan line
   sty VBLANK                       ; start the vertical blank period (turn off TIA)
   
   lda #OVERSCAN_TIME
   sta TIM64T
   
   inc randomSeed
       
   lda #<HorizontalColors
   ldy #<NullCharacter

   ldx #NUM_WALKWAYS
       
.setLSBLoop
   sta marioColorPointerLSB,x       ; set the LSB value for Mario colors
   sty obstaclePointerLSB,x         ; set the LSB value for the obstacle
   dex
   bpl .setLSBLoop
       
   inc frameCount                   ; incremented each frame
   lda frameCount
   and #BONUS_TIMER_DELAY           ; reduce timer ~ every 2 seconds
   bne .skipAttractModeSet
   lda gameState
   bpl ProcessAttractMode
       
;
; reduce the bonus timer
;
   lda bonusTimer
   sed                              ; set to decimal mode (timer stored in BCD)
   sec
   sbc #$01                         ; reduce the timer by 1 (or 100 to the player)
   sta bonusTimer
   cld
   bne ProcessAttractMode

   jsr PlayDeathSound               ; timer = 0 so play the death sound
       
;-------------------------------------------------------------ProcessAttractMode
;
; The attract mode was created to save the television from screen burnout. If a
; still picture stays on the screen for a period of time, it can permenatly burn
; itself into the screen.
;
ProcessAttractMode
   lda attractMode                  ; if not in attract mode (D7 = 0) then
   bpl .skipColorCycling            ; skip the color cycling
   inc backgroundColor              ; increase the background color
   dec playfieldColor               ; reduce the playfield color
   
.skipColorCycling
   inc attractModeTimer             ; once the attractModeTimer wraps to 0 then the
   bne .skipAttractModeSet          ; attract mode state is set
   
   stx attractMode                  ; set the attract mode to cycle to colors (x = #$FF)
.skipAttractModeSet
   ldy #$00
   cpx SWCHA                        ; check the joystick value with the attract mode
   bne .endAttractMode              ; if the joystick is pushed end the color cycling
   
   lda INPT4
   bmi CheckConsoleSwitches
   
.endAttractMode
   sty attractModeTimer             ; reset attract mode timer to 0
   lda attractMode                  ; check to see if the colors are cycling
   bpl CheckConsoleSwitches
   
   sty attractMode                  ; clear the attract mode (y = 0)
   jsr InitializeGame
       
CheckConsoleSwitches
   lda SWCHB                        ; read the console switches
   lsr                              ; reset now in the carry bit
   bcs .skipReset
   
   lda consoleDebounce
   bmi ClearGameRAM
   dec consoleDebounce
;
; This routine clears RAM starting at gameScreen ($90) and goes back to PF2
; I don't know why this is done. This same type of RAM clear in also used
; in Space Jockey. I guess Garry just carried over old code.
:
ClearGameRAM
   ldx #$42
   lda #$00
.clearRAM
   sta PF1+64,x                     ; clear RAM starting gameScreen back to PF2
   dex
   bne .clearRAM
   
   jsr InitializeGame
   lda #STARTING_MARIOS             ; set the starting Mario lives
   sta numberOfLives
   bne LF0B2
   
.skipReset
   lda gameState                    ; game is progress
   bmi LF0B5
   
   lda soundDuration
   bne LF0B2
       
   ldx INPT4                        ; check the fire button
   bmi LF0B2
   
   lda gameState
   lsr
   bcs .resetBonusTimer             ; reset timer if starting a new level
   
   lda consoleDebounce
   bpl LF0B2
       
.resetBonusTimer
   lda #STARTING_BONUS
   sta bonusTimer
   ldx #$FF
   stx gameState                    ; set game state to show game not over
   
   sty frameCount
   sty consoleDebounce
   
LF0B2: JMP    LF2CE   ;3

LF0B5:
   lda losingLifeFlag
   bmi LF0BD
       
   dec marioFrameDelay
   bmi CheckMarioMovement

LF0BD:
   jmp CheckForJumpingMario

CheckMarioMovement
   lda #MARIO_MOVE_RATE             ; reset the Mario move frame rate
   sta marioFrameDelay
       
   lda SWCHA                        ; read the joystick
   ldx jumpHangTime
   beq .setJoystickValue            ; if Mario is no longer jumping then store
                                    ; the joystick direction
   lda jumpingDirection             ; store the direction of Mario's last jump
.setJoystickValue
   sta joystickValue
   ldx marioDirection
   bpl DetermineWalkway
   
   jsr DetermineLadderMovement
   bcc DetermineWalkway
   
   jmp CheckVerticalJoystickValues
       
DetermineWalkway
   ldx #NUM_WALKWAYS
   lda verPosMario
   sec
   sbc #WALKWAY_HEIGHT-5
   bcc .walkwayFound
.determineWalkwayLoop
   dex
   sbc #WALKWAY_HEIGHT+1
   bcs .determineWalkwayLoop
   
.walkwayFound
   stx walkwayNumber
   lda joystickValue
   asl                              ; right motion is now if carry bit
   bmi .skipLeftMotion              ; left motion in D7
   
   inc randomSeed
   lda #NO_REFLECT
   sta marioDirection
   dec horPosMario                  ; move Mario left
   dec $84
   ldy #XMIN_LEVEL1                 ; load y with the minimum horiz value for the firefox screen
   lda gameScreen                   ; get the current game screen
   bne .checkMinHorizPosition       ; if the Firefox screen then branch
   lda walkwayNumber
   lsr                              ; shift the walkway number right
   bcs .checkMinHorizPosition       ; if it's an odd walkway then branch
   ldy #XMIN_ODD_LEVEL0
.checkMinHorizPosition
   cpy horPosMario
   bcc CheckRampValues
   bcs .setMarioHorizPosition
.skipLeftMotion
   bcs CheckVerticalJoystickValues
   
   inc randomSeed
   lda #REFLECT
   sta marioDirection
   inc horPosMario                  ; move Mario right
   inc $84
   ldy #XMAX_LEVEL1
   lda gameScreen
   bne .checkMaxHorizPosition
   lda walkwayNumber
   lsr
   bcc .checkMaxHorizPosition
   ldy #XMAX_ODD_LEVEL0
.checkMaxHorizPosition
   cpy horPosMario
   bcs CheckRampValues
   
.setMarioHorizPosition
   sty horPosMario
   sty $84
LF12E:
   jmp CheckForJumpingMario

CheckRampValues SUBROUTINE
   lda gameScreen
   bne .doneMarioHorizMovement      ; if Firefox screen then no ramps to check
   lda walkwayNumber                ; if this is the first walkway then
   beq .doneMarioHorizMovement      ; no need to check for ramp increase/decrease
   cmp #$05                         ; if this the fifth walkway then
   beq .doneMarioHorizMovement      ; no need to check for ramp increase/decrease
   
   ldx #$07
   lda horPosMario
   ldy marioDirection
   bne .rampLoop                    ; branch if Mario is moving left
   clc
   adc #$01
.rampLoop
   dex
   bmi .doneMarioHorizMovement
   cmp RampHorizValues,x
   bne .rampLoop
   lda walkwayNumber                ; get the current walkway number
   lsr
   bcc .checkEvenNumberRamp         ; if it's even then branch
   tya                              ; move Mario direction to the accumulator
   bne .moveUpRamp                  ; branch if Mario is moving left
   beq .moveDownRamp
.checkEvenNumberRamp
   tya                              ; move Mario direction to the accumulator
   bne .moveDownRamp                ; branch if Mario is moving left
.moveUpRamp
   inc verPosMario
   bne .doneMarioHorizMovement
.moveDownRamp
   dec verPosMario
.doneMarioHorizMovement
   jmp CheckRivits

CheckVerticalJoystickValues
   lda joystickValue                ; get the joystick value
   and #MOVE_DOWN                   ; and check to see if the player is pushing down
   bne CheckForUpMotion             ; if not then check if they are pushing up
   
   dec randomSeed
   lda marioDirection               ; get the current direction of Mario
   bmi MarioMovingDown              ; if moving vertically then branch
       
   lda hammerTime                   ; if Mario is not done using the hammer
   bne LF12E                        ; then branch (can't carry it with you)
   
   ldy #$08                         ; offset for the down ladder table
   ldx #$08                         ; maximum number of ladders Mario can move down
   lda gameScreen
   beq DetermineMarioDownLadder     ; branch if barrels
   
   ldy #<FirefoxDownLadderTable-DownLadderTable+MAX_FIREFOX_LADDERS
   ldx #MAX_FIREFOX_LADDERS         ; maximum number of ladders Mario can move down
   
DetermineMarioDownLadder
   lda verPosMario
.downLadderCheckLoop
   dey
   dex
   bmi LF12E
   
   cmp DownLadderTable,y
   bne .downLadderCheckLoop
   
   lda horPosMario
   sec
   sbc LadderHorizValues,y
   cmp #LADDER_RANGE
   bcs DetermineMarioDownLadder
   
   sty ladderNumber
MarioMovingDown
   lda #$FE
   sta marioDirection
   lda verPosMario
   ldy ladderNumber
   cmp UpLadderTable,y
   bne .moveMarioDown
   
DoneMarioVerticalMovement
   jmp CheckForJumpingMario
   
.moveMarioDown
   inc verPosMario
   bne CheckRivits

CheckForUpMotion
   lda joystickValue                ; get the joystick value
   and #MOVE_UP                     ; and check to see if the player is pushing up
   bne DoneMarioVerticalMovement    ; if not then leave Mario vertical movement check
   
   dec randomSeed
   lda marioDirection               ; get the current direction of Mario
   bmi MarioMovingUp                ; Mario is moving up

   lda hammerTime                   ; if Mario is not done using the hammer
   bne DoneMarioVerticalMovement    ; then branch
   
   ldx #$09                         ; offset for the up ladder table
   ldy #$09                         ; maximum number of ladders Mario can move up
   lda gameScreen
   beq DetermineMarioUpLadder
   
   ldy #<FirefoxUpLadderTable-UpLadderTable+MAX_FIREFOX_LADDERS
   ldx #MAX_FIREFOX_LADDERS         ; maximum number of ladders Mario can move down
   
DetermineMarioUpLadder
   lda verPosMario
.upLadderCheckLoop
   dey
   dex
   bmi DoneMarioVerticalMovement
   cmp UpLadderTable,y
   bne .upLadderCheckLoop
   
   lda horPosMario
   sec
   sbc LadderHorizValues,y
   cmp #LADDER_RANGE
   bcs DetermineMarioUpLadder
   
   sty ladderNumber
MarioMovingUp
   lda #$FF
   sta marioDirection
   lda verPosMario
   ldy ladderNumber
   cmp DownLadderTable,y
   beq CheckForJumpingMario
   dec verPosMario
   
CheckRivits
   lda gameScreen                   ; rivits aren't used on the barrel screen
   beq PlayWalkingSound             ; so branch to play the walking sound
       
   ldx walkwayNumber
   cpx #$01                         ; if Mario is on the last platform then branch
   beq PlayWalkingSound             ; no rivits on the last platform
   
   lda rivits-2,x                   ; get the rivit value for the walkway
   ldy horPosMario                  ; get Mario's horizontal position
   
   cpy #HORIZ_LEFT_RIVIT            ; is Mario on the left rivit if so branch
   beq .determineLeftRivitValue
   cpy #HORIZ_RIGHT_RIVIT           ; if Mario is not on the right rivit then branch
   bne PlayWalkingSound
.determineRightRivitValue
   cmp #RIGHT_RIVIT_VALUE           ; if the right rivit has been pulled then branch
   bcs .marioStandingInTheGap
   adc #RIGHT_RIVIT_VALUE           ; show the right rivit was pulled
   bpl .rivitPulled
.determineLeftRivitValue
   cmp #COMPLETE_RIVIT_WALKWAY      ; have all rivits been pulled for the walkway
   bcs .marioStandingInTheGap       ; branch if so...
   cmp #LEFT_RIVIT_VALUE            ; if the left rivit has not been pulled then pull it
   bcc .pullLeftRivit
   cmp #RIGHT_RIVIT_VALUE
   bcc .marioStandingInTheGap
.pullLeftRivit
   clc
   adc #LEFT_RIVIT_VALUE
.rivitPulled
   sta rivits-2,x
   jsr Add100Points
   bne PlayWalkingSound
   
.marioStandingInTheGap
   lda jumpHangTime
   bne PlayWalkingSound
;
; Mario is standing in a hole where a rivit use to be so the player loses a life
;
   jsr PlayDeathSound
   
PlayWalkingSound
   lda soundDuration
   bne CheckForJumpingMario
   
   lda horPosMario
   ldx marioDirection
   bpl .walkingSoundFrequencyIndex
   lda verPosMario
.walkingSoundFrequencyIndex
   and #$03
   bne CheckForJumpingMario
   lda #$05
   sta AUDC0
   lda #$0B
   sta AUDV0
   lda #$02
   sta soundDuration
   sta soundIndex
   bne ReadFirebuttonForJump
   
CheckForJumpingMario
   lda jumpHangTime
   beq ReadFirebuttonForJump
;   
; Mario is jumping
; This routine checks to see if Mario is jumping over a barrel or Firefox
;
   ldx #MAX_OBSTACLES
.checkNextObstacle
   dex
   bmi .doneJumpingOverCheck

   lda horPosMario                  ; get the horizontal position of Mario
   sec
   sbc horPosP1,x                   ; subtract it by the obstacle's horizontal position
   tay
   iny
   cpy #$03                         ; if the value >= 3 then check the next obstacle
   bcs .checkNextObstacle
   
   lda verPosMario                  ; get Mario's vertical position
   sec
   sbc verPosP1,x                   ; subtract it by the obstacle's vertical position
   cmp #$04
   bcs .checkNextObstacle           ; if it's >= 4 then check the next obstacle
   lda jumpingObstacle
   bmi JumpingMario                 ; already awarded the 100 points
   dec jumpingObstacle

   jsr Add100Points       

   jmp JumpingMario
.doneJumpingOverCheck
   inx
   stx jumpingObstacle
   
JumpingMario
   lda soundDuration
   cmp #$01
   bne .reduceHangtime
   lda #$0C 
   sta AUDC0
   lda jumpHangTime
   lsr
   sta AUDV0
.reduceHangtime
   dec jumpHangTime
   bne LF2CE
   lda verPosMario
   clc
   adc #JUMPING_HEIGHT
   sta verPosMario
   lda #$00
   sta $84
   beq LF2CE
   
ReadFirebuttonForJump
   lda INPT4
   ora losingLifeFlag
   bmi .clearFireButtonDebounce
       
   lda hammerTime
   bne .clearFireButtonDebounce
   
   lda marioDirection
   bpl LF2AD                        ; if Mario is moving horiz then branch
   
   jsr DetermineLadderMovement
   bcs .clearFireButtonDebounce
   lda #$00
   sta marioDirection
LF2AD:
   ldy fireButtonDebounce
   bne LF2CE
   
   iny
   sty soundDuration
   dec fireButtonDebounce
   lda SWCHA
   sta jumpingDirection
   lda verPosMario
   sec
   sbc #JUMPING_HEIGHT
   sta verPosMario
   lda #JUMP_HANGTIME
   sta jumpHangTime
   sta soundIndex
   bne LF2CE
   
.clearFireButtonDebounce
   lda #$00
   sta fireButtonDebounce
   
LF2CE:
   ldx marioDirection               ; Mario moving horiz then branch
   bpl LF2DD
   
   ldx #$05
   jsr DetermineLadderMovement
   bcs LF2DA
   inx
LF2DA:
   txa
   bne LF2E8
   
LF2DD:
   lda $84
   and #$06
   lsr
   ldx jumpHangTime
   beq LF2E8
   lda #$04
LF2E8:
   tay
   lda verPosMario                  ; get the vertical position of Mario
   ldx #NUM_WALKWAYS

.walkwayLoop
   cmp #$2E
   bcc SetMarioGraphicPointers      ; no need to calculate walkway number
   dex                              ; reduce the walkway value
   sbc #WALKWAY_HEIGHT+1            ; subtract Mario's position by walkway height
   bcs .walkwayLoop
   
SetMarioGraphicPointers
   sty temp
   sta marioOffset
   adc MarioColorTable,y
   sta marioColorPointerLSB,x
       
   lda #>MarioGraphics
   sta marioGraphicPointer+1
   
   lda marioOffset
   clc
   adc MarioAnimationTable,y
   sta marioGraphicPointer
   jsr StoreMarioGraphics
   lda marioOffset
   sec
   sbc #WALKWAY_HEIGHT+2
   bcc CheckMarioWithHammer
   sta temp
   cpx #$01
   bcc CheckMarioWithHammer

   lda marioColorPointerLSB,x
   sbc #WALKWAY_HEIGHT+1
   sta marioColorPointerLSB-1,x
   lda marioGraphicPointer
   sec
   sbc #WALKWAY_HEIGHT+1
   sta marioGraphicPointer
   ldy #WALKWAY_HEIGHT
LF32A:
   dec temp
   bmi LF336
   lda (marioGraphicPointer),y
   sta zpMarioGraphics,y
   dey
   bpl LF32A
   
LF336:
   lda #$06
   sta temp
   lda #$00
LF33C:
   sta zpMarioGraphics,y
   dey
   dec temp
   bpl LF33C
       
CheckMarioWithHammer
   lda hammerTime                   ; if Mario currently has the hammer then don't
   bne .setHammerHorizPosition      ; reset the hammer time
   
   lda CXM1P
   bpl LF381
   
   lda jumpHangTime
   beq LF381
       
   lda #MAX_HAMMER_TIME             ; set the time for Mario to hold the hammer
   sta hammerTime
   
.setHammerHorizPosition
   lda #$09
   ldy marioDirection
   bne .offsetHammerPosition        ; Mario moving right so branch
   lda #$FE
.offsetHammerPosition
   clc
   adc horPosMario
   sta horPosHammer
       
   ldy #<MallotAnimation2
   ldx #<HandleAnimation2
       
   lda frameCount
   and #$08
   bne SetHammerPointers
   
   ldx #<HandleAnimation1
   ldy #<MallotAnimation1

SetHammerPointers
   sty missilePointer
   stx ballPointer
       
   lda frameCount
   bne LF381
       
   dec hammerTime
   bne LF381
   
   lda #<NoHammerAnimation
   sta missilePointer
   sta ballPointer
   
LF381:
   lda soundDuration
   beq .setAudioVolume
   cmp #$04
   bcc LF38F
       
   lda frameCount
   and #$03
   bne .waitTime
   
LF38F:
   dec soundIndex
   bmi .turnOffSound
   
   lda soundDuration
   asl
   tay

   lda AudioFrequecyTable-2,y
   sta audioFrequecyPointer
   lda AudioFrequecyTable-1,y
   sta audioFrequecyPointer+1
   
   ldy soundIndex
   lda (audioFrequecyPointer),y
   sta AUDF0
   bpl .waitTime

.turnOffSound
   lda #$00
   sta soundDuration
.setAudioVolume
   sta AUDV0

.waitTime
   ldx INTIM
   bne .waitTime

;
; start new frame
;
   stx WSYNC                        ; end current scan line
   lda #$02
   sta VSYNC                        ; start vertical sync
   sta WSYNC
   sta WSYNC
   sta WSYNC
   stx VSYNC                        ; end vertical sync
   
   lda #VBLANK_TIME
   sty WSYNC
   sta TIM64T
   
   lda gameState
   cmp #LEVEL_COMPLETED
   beq LF3F1
   
   lda gameScreen
   beq .checkBarrelsComplete
   
CheckForLevelComplete
   ldx #$03
.rivitLoop
   lda rivits,x
   cmp #COMPLETE_RIVIT_WALKWAY
   bcc .levelNotDone
   dex
   bpl .rivitLoop
   bmi .levelCompleted

.checkBarrelsComplete
   lda verPosMario
   cmp #YMIN_LEVEL0
   bne .levelNotDone
   
.levelCompleted
   lda #LEVEL_COMPLETED
   sta gameState
   
   ldx #$0A
   lda #$05
   jsr PlayMusic
   
LF3F1:
   lda soundDuration
   cmp #$05
   beq .levelNotDone
       
   lda #START_NEW_LEVEL
   sta gameState
   lda bonusTimer                   ; add bonus timer value to score
   jsr IncrementScore
   lda gameScreen                   ; get the current game screen
   eor #$01                         ; flip between 0 (barrels) and 1 (firefox)
   sta gameScreen
   
   jsr StartNewScreen
       
.levelNotDone
   lda losingLifeFlag
   bmi .doneMovingObstacles
       
   lda gameState
   bpl .doneMovingObstacles         ; game not running so branch
   
   ldx holdObstacleNumber
   lda verPosP1,x
   bne LF450
   lda gameScreen
   bne StartNewFirefox              ; branch to do firefox
;   
; doing barrels here
;
   lda verPosP1+1,x
   cpx #$03
   bne LF423
   lda verPosP1
LF423:
   tay
   beq StartNewBarrel
   cpy #$23
   bcc LF450
   
StartNewBarrel
   lda #STARTING_BARREL_VERT
   sta verPosP1,x
   lda #STARTING_BARREL_HORIZ
   sta horPosP1,x
   lda #OBSTACLE_MOVING_RIGHT
   sta directionP1,x
   bne LF449
   
StartNewFirefox
   lda randomSeed
   and #$1F
   adc #$25
   sta horPosP1,x                   ; randomly set the horizontal position of the firefox
   and #OBSTACLE_MOVING_RIGHT
   sta directionP1,x                ; set the random direction of the firefox
   lda FirefoxVerPos,x
   sta verPosP1,x
LF449:
   dex
   bpl LF44E
   ldx #MAX_OBSTACLES-1
LF44E:
   stx holdObstacleNumber
LF450:
   ldx #MAX_OBSTACLES-1
   ldy #$01
       
   lda frameCount
   lsr
   bcc LF45D                        ; if the frame count is even branch
   
   ldx #$01
   ldy #$FF
LF45D:
   sty loopCount
   
MoveObstacleLoop
   ldy verPosP1,x                   ; if the vertical position of the obstacle
   bne .moveObstacle                ; is not 0 then move it
   jmp MoveNextObstacle
   
.doneMovingObstacles
   jmp DoneMovingObstacles

.moveObstacle
   lda gameScreen
   beq MoveBarrelObject             ; branch if this is the barrel screen
   
;
; Moving Firefox sprite
;
   lda rivits,x
   cmp #LEFT_RIVIT_VALUE            ; check to see if the left rivit was removed
   bcc MoveFirefox                  ; if not then give full left motion range
   cmp #RIGHT_RIVIT_VALUE           ; check to see if the right rivit was removed
   bcc .checkLeftRivitConstraint
   
   lda #HORIZ_RIGHT_RIVIT
   cmp horPosP1,x
   beq ChangeFirefoxDirection
   lda rivits,x
   cmp #COMPLETE_RIVIT_WALKWAY
   bcc MoveFirefox
   
.checkLeftRivitConstraint
   lda #HORIZ_LEFT_RIVIT
   cmp horPosP1,x
   bne MoveFirefox
       
ChangeFirefoxDirection
   lda directionP1,x
   eor #$01
   sta directionP1,x
   
MoveFirefox
   lda directionP1,x                ; moving left then branch
   beq .moveFirefoxLeft
   
   inc horPosP1,x
   lda #XMAX_LEVEL1
   cmp horPosP1,x                   ; is the firefox at the right most pixel
   bcc .changeDirection             ; if so then change it's direction
   bcs .computeRandomDirection
   
.moveFirefoxLeft
   dec horPosP1,x
   lda #XMIN_LEVEL1
   cmp horPosP1,x                   ; is the firefox at the left most pixel
   bcs .changeDirection             ; if so then change it's direction
   
.computeRandomDirection
   lda randomSeed
   cmp #$02                         ; if the seed is less than 2
   bcc .skipRandomDirection         ; then skip random firefox direction
   ldy playerScore                  ; use player's score as an index
   cmp LF900,y                      ; compare the random seed with the number table
   bcs .doneMovingCurrentFirefox    ; if >= then don't change directions
   lda LF900,y                      ; store the number table value
   sta randomSeed                   ; in the randomSeed
   
.changeDirection
   lda directionP1,x
   eor #$01
   tay
   bpl .setFirefoxDirection         ; unconditional branch
   
.skipRandomDirection
   lda verPosP1,x                   ; get the vertical position of the firefox
   clc
   adc #FAIR_PIXEL_DELTA            ; if the difference between the vertical position
   cmp verPosMario                  ; and Mario is not between FAIR_PIXEL_DELTA then
   bne .doneMovingCurrentFirefox    ; finish firefox movement
   
   ldy #OBSTACLE_MOVING_LEFT
   lda horPosP1,x                   ; if the firefox is to the right of Mario
   cmp horPosMario                  ; then move the firefox left
   bcs .setFirefoxDirection         ; if the firefox is to the left of Mario
   ldy #OBSTACLE_MOVING_RIGHT       ; then more the firefox right
.setFirefoxDirection
   sty directionP1,x
.doneMovingCurrentFirefox
   jmp MoveNextObstacle

MoveBarrelObject SUBROUTINE
   lda directionP1,x
   beq .moveBarrelLeft              ; barrel moving left
   bmi .moveBarrelDown              ; barrel falling down
.barrelMovingRight
   inc horPosP1,x                   ; increment barrel horiz position
   bne BarrelRampMovement           ; same as jmp but saves a byte (never 0)
   
.moveBarrelLeft
   dec horPosP1,x                   ; decrement barrel horiz position
   
BarrelRampMovement
   cpy #TOP_PLATFORM_VALUE          ; if the barrel is on the top platform then
   beq .doneBarrelRampMovement      ; branch -- no ramps there
   cpy #BOTTOM_BARREL_PLATFORM_VALUE; if the barrel is on the bottom platform then
   beq .checkBarrelDone             ; branch -- no ramps
   ldy horPosP1,x                   ; get the horizontal position of the barrel
   asl
   bne LF4F0                        ; branch if not moving left
   iny
LF4F0:
   tya
   ldy #$07
.rampLoop
   dey
   bmi .doneBarrelRampMovement
   cmp RampHorizValues,y            ; if the barrel horiz position is less than
   bcc .doneBarrelRampMovement      ; the table value then branch
   bne .rampLoop
   inc verPosP1,x                   ; move barrel down the ramp
       
.doneBarrelRampMovement
   ldy playerScore
   lda randomSeed
   cmp LF900,y
   ldy #$0C
   bcs LF50C
   ldy #$FF
LF50C:
   lda verPosP1+1,x
   cpx #$03
   bne LF514
   lda verPosP1
LF514:
   sta obstacleOffset
LF516:
   lda obstacleOffset
   sbc verPosP1,x
LF51A:
   iny
   cpy #$12
   bcs MoveNextObstacle
   cmp LFC50,y
   bcc LF51A
   
   lda horPosP1,x
   sbc #$01
   cmp LadderHorizValues,y
   bne LF516
   
   lda DownLadderTable,y
   sec
   sbc #FAIR_PIXEL_DELTA
   cmp verPosP1,x
   bne LF516
   
   sty barrelLadderNumber,x
   lda directionP1,x
   ora #OBSTACLE_MOVING_DOWN
   bmi .setBarrelDirection
       
.moveBarrelDown
   inc verPosP1,x
   inc verPosP1,x
   ldy barrelLadderNumber,x
   lda UpLadderTable,y
   
   sec
   sbc #FAIR_PIXEL_DELTA
   cmp verPosP1,x
   beq LF551
   bcs MoveNextObstacle
   
LF551:
   sta verPosP1,x
   lda directionP1,x
   eor #OBSTACLE_MOVING_DOWN | OBSTACLE_MOVING_RIGHT
   
.setBarrelDirection
   sta directionP1,x
   jmp MoveNextObstacle
       
.checkBarrelDone
   lda horPosP1,x
   cmp #XMIN_LEVEL1-1               ; if the barrel is not finished (off the screen)
   bne MoveNextObstacle             ; then move the next barrel
   lda #$00                         ; reset the vertical position of the barrel so
   sta verPosP1,x                   ; it can be reused
       
MoveNextObstacle
   dex
   cpx loopCount
   beq DoneMovingObstacles
   jmp MoveObstacleLoop
       
DoneMovingObstacles
   ldx #MAX_OBSTACLES-1
LF570
   ldy #FALLING_BARREL_SPRITE_NUMBER
   lda verPosP1,x                   ; check to see if the obstacle is there
   beq .gotoNextObstacle            ; if not then branch
   lda directionP1,x                ; if the barrel is not falling down a ladder
   bpl .setRollingBarrelSprite      ; then change the sprite to the barrel sprite
   
   lda barrelLadderNumber,x
   cmp #$0D
   bcc LF585
   cmp verPosMario
   bcs .removeObstacle
.setRollingBarrelSprite
   dey                              ; y = 0 -or- BARREL_SPRITE_NUMBER
LF585:
   lda gameScreen
   beq LF58B
   ldy #FIREFOX_SPRITE_NUMBER
LF58B:
   lda verPosP1,x
   stx obstacleNumber
       
   ldx #NUM_WALKWAYS+1       
   sec
.walkwayLoop
   dex
   sbc #WALKWAY_HEIGHT+1
   bcs .walkwayLoop
   adc #WALKWAY_HEIGHT+1
   cpx #HAMMER_GROUP                ; if the obstacle is not on a hammer
   bne .calculateObstaclePointers   ; walkway then compute pointers
   
   asl CXP1FB                       ; check if the obstacle was hit by the hammer
   bpl .calculateObstaclePointers   ; obstacle not hit -- compute pointers
   
   lda #SMASHING_OBSTACLE           ; add the smashing score to the player's
   jsr IncrementScore               ; score
   ldx obstacleNumber
   
.removeObstacle
   lda #$00
   sta verPosP1,x                   ; clear the verPos of the obstacle
.gotoNextObstacle
   beq NextObstacle                 ; same as jmp -- saves a byte
   
.calculateObstaclePointers
   sta obstacleOffset
   clc
   adc ObstacleTable,y
   sta obstaclePointerLSB,x
   lda obstacleOffset
   cmp #$12
   bcc StoreObstaclePosition
   ror barrelLadderNumber+3,x
   cmp #$13
   bcc StoreObstaclePosition
   txa
   beq StoreObstaclePosition
   lda obstaclePointerLSB,x
   sbc #WALKWAY_HEIGHT+1
   sta obstaclePointerLSB-1,x
   
;
; the horizontal motion values are stored in RAM for each obstacle to save time
; in the kernel
;
StoreObstaclePosition SUBROUTINE
   ldy obstacleNumber
   lda horPosP1,y
   ldy #$FD
   sec
.coarseMoveLoop
   iny
   sbc #$0F
   bcs .coarseMoveLoop
   sty coarseHorPosP1,x
   eor #$0F
   asl
   asl
   asl
   asl
   adc #HMOVE_R7
   sta fineHorPosP1,x
   ldx obstacleNumber
   
NextObstacle
   dex
   bmi CheckToPlayDeathSound
   jmp LF570
   
CheckToPlayDeathSound
   lda losingLifeFlag
   bmi .continueDeathSound
       
   lda CXPPMM
   bpl .clearCollisions
       
   jsr PlayDeathSound
   
.continueDeathSound
   lda soundDuration
   cmp #$04
   beq .clearCollisions
   lda #$00
   sta losingLifeFlag
       
   jsr StartNewScreen
   
   ldy #START_NEW_LEVEL
   dec numberOfLives
   bpl .setGameState
   
   jsr PlayGameOverMusic
   
   ldy #GAME_OVER
   sty numberOfLives
   
.setGameState
   sty gameState

.clearCollisions
   lda #$FF
   sta CXCLR
   jsr SetupKernelJumpVector
   ldx #$03
   lda horPosHammer
       
   jsr PositionHammer
   
   ldy #$10                         ; ball size 2 clocks
   ldx #$20                         ; ball size 4 clocks
   lda missilePointer
   cmp #<MallotAnimation2
   beq LF638
   
   lda gameScreen
   beq LF630
   inx                              ; reflect the firefox playfield
LF630:
   stx CTRLPF
   sty missile1Size                 ; used in the kernel
   lda #$FF
   bne LF649
LF638:
   stx missile1Size
   lda gameScreen
   beq LF63F
   iny                              ; reflect the firefox playfield
LF63F:
   sty CTRLPF
   lda #$FE
   ldy marioDirection
   beq LF649
   lda #$04
LF649:
   clc
   adc horPosHammer
   ldx #$04
   jsr PositionHammer
   
DisplayKernel SUBROUTINE
.waitTime
   ldx INTIM
   bne .waitTime
   
   stx WSYNC
;--------------------------------------
   stx VBLANK                 ; 3         stop vertical blanking (enable TIA)
   stx REFP0                  ; 3         don't reflect player0
   stx REFP1                  ; 3         don't reflect player1
   inx                        ; 2         x = 1
   stx VDELP0                 ; 3         vertical delay GRP0 and GRP1 setting up for
   stx VDELP1                 ; 3         the 6 digit display
   
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3
   stx NUSIZ1                 ; 3
   nop                        ; 2
   ldy #HMOVE_R7              ; 2
   sty HMP0                   ; 3 = @32   move GRP0 right 7 pixels
   ldy #NUMBER_HEIGHT         ; 2
   sta RESP0                  ; 3 = @37   coarse position GRP0 @ pixel 111
   ldx #BLUE                  ; 2
   sta RESP1                  ; 3 = @42   coarse position GRP1 @ pixel 126
   lda gameState              ; 3         get the current game state
   asl                        ; 2         shift D7 to the carry bit
   bcc .colorDigits           ; 2³        carry clear -- game in progress
   ldx #LIGHT_GREEN           ; 2         bonus timer color
.colorDigits
   stx COLUP0                 ; 3
   stx COLUP1                 ; 3

   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3         move the players horizontally
.drawDigits   
   lda NumberFonts,y          ; 4         this puts the zero on the back end of
   sta digitPointer+8         ; 3         the score
   sta WSYNC
;--------------------------------------
   lda (digitPointer+6),y     ; 5
   sta GRP0                   ; 3 = @8
   lda (digitPointer+4),y     ; 5
   sta GRP1                   ; 3 = @16
   lda (digitPointer+2),y     ; 5
   sta.w GRP0                 ; 4 = @25
   lda (digitPointer),y       ; 5
   tax                        ; 2
   lda NumberFonts,y          ; 4
   sty loopCount              ; 3
   ldy digitPointer+8         ; 3
   stx GRP1                   ; 3 = @45
   sta GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sty GRP0                   ; 3 = @54
   ldy loopCount              ; 3
   dey                        ; 2
   bpl .drawDigits            ; 2³
       
   stx WSYNC
;--------------------------------------
   sta HMCLR                  ; 3 = @3       clear all horizontal movements
   ldx #$00                   ; 2
   stx VDELP0                 ; 3 = @8       turn off vertical delay of GRP0 and 
   stx VDELP1                 ; 3 = @11      GRP1
   stx GRP0                   ; 3 = @14      disable player graphics to avoid
   stx GRP1                   ; 3 = @17      bleeding into current scan line
   stx NUSIZ1                 ; 3 = @20      single pixel res for GRP1
   ldx #PLAYER_HEIGHT         ; 2
   lda playfieldColor         ; 3
   sta COLUPF                 ; 3 = @28      color the playfield -- outside of
                              ;              HBLANK but okay
   sta RESP0-PLAYER_HEIGHT,x  ; 4 = @32      wastes a cycle but saves a byte from
                              ;              sta.w RESP0
   lda marioDirection         ; 3
   bpl .setMarioReflectState  ; 2³
   
   lda verPosMario            ; 3
   and #$04                   ; 2
   asl                        ; 2
   
.setMarioReflectState
   sta REFP0                  ; 3
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ0                 ; 3            make Donkey Kong double size
   lda #BROWN                 ; 2
   sta COLUP0                 ; 3            color Donkey Kong
   lda #>ObstacleSprites      ; 2            set the MSB for the obstacles
   sta obstaclePointer+1      ; 3
   ldy numberOfLives          ; 3
   
.drawDonkeyKongLoop
   lda DonkeyKong-1,x           ; 4
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @3       draw Donkey Kong character
   lda #$00                   ; 2
   sta PF1                    ; 3 = @8       clear the PF1 register
   lda Girlfriend-1,x         ; 4
   sta GRP1                   ; 3 = @15      draw girlfriend character
   lda GirlfriendColors-2,x   ; 4
   sta COLUP1                 ; 3 = @22      color girfriend character
   cpx #$0D                   ; 2
   bcs .nextX                 ; 2³
   cpx #$05                   ; 2
   bcc .nextX                 ; 2³
   lda BarrelPFDataTable-5,x  ; 4
   sta rightPF1Pointer-5,x    ; 4
   lda LivesPFPattern,y       ; 4
   sta PF1                    ; 3 = @45      draw lives indicators
.nextX
   dex                        ; 2
   bne .drawDonkeyKongLoop    ; 2³
   
   stx NUSIZ0                 ; 3            x = 0
   lda missile1Size           ; 3
   sta NUSIZ1                 ; 3
   lda frameCount             ; 3
   sta REFP1                  ; 3
   ldy #$01                   ; 2
   
.drawDonkeyKongPlatform
   stx PF1                    ; 3            clear the playfield registers to
   stx PF2                    ; 3            avoid bleeding on next scan line
   sta WSYNC
;--------------------------------------
   lda #$0F                   ; 2
   sta PF1                    ; 3 = @5
   lda #$FF                   ; 2
   sta PF2                    ; 3 = @10
   ldx #$06                   ; 2
   lda gameScreen             ; 3            get the current game screen
   beq .zeroXLoop             ; 2³           branch if the barrel level
   ldx rivits+3               ; 3 = @20
   lda FireFoxLeftPF1Table,x  ; 4
   sta leftPF1Pointer         ; 3
   lda FireFoxPF2Table,x      ; 4
   sta pf2Pointer             ; 3
   lda FireFoxPF0Table,x      ; 4
   sta pf0Pointer             ; 3
   lda #>InitializationTable1                ; 2
   sta leftPF1Pointer+1       ; 3
   sta pf2Pointer+1           ; 3
   sta pf0Pointer+1           ; 3
   ldx #$01                   ; 2
   stx REFP1                  ; 3
.zeroXLoop
   dex                        ; 2
   bne .zeroXLoop             ; 2³
   dey                        ; 2
   bpl .drawDonkeyKongPlatform; 2³
   
   stx PF1                    ; 3
   stx PF2                    ; 3
   sec                        ; 2
   sta WSYNC
;--------------------------------------
   lda horPosMario            ; 3
.coarseMoveMario
   sbc #$0F
   bcs .coarseMoveMario
   eor #$0F
   asl
   asl
   asl
   asl
   adc #HMOVE_R7
   sta RESP0
   sta HMP0
   lda #RED_2                       ; it seems they forgot about this in the PAL
   sta COLUP0                       ; translation -- it's the same value as NTSC
   lda verPosMario
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   cmp #$0F                   ; 2
   bcs .skipMarioDraw         ; 2³
   ldy #$1C                   ; 2            first byte of Mario sprite
   bne .drawMario             ; 2³
.skipMarioDraw
   ldy #$00                   ; 2
   nop                        ; 2
.drawMario
   sty GRP0                   ; 3 = @15
   lda fineHorPosP1+5         ; 3
   ldy coarseHorPosP1+5       ; 3
LF782:
   dey                        ; 2
   bpl LF782                  ; 2³
   ldy #WALKWAY_HEIGHT        ; 2
   nop                        ; 2
   sta RESP1                  ; 3
   sta HMP1                   ; 3
   stx HMP0                   ; 3            clear player 0 horizontal movement (x = 0)
   lda #>MarioColors          ; 2
   sta marioColorPointer+1    ; 3
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   bcc .drawMario_a           ; 2³
   bcs .skipMarioDraw_a       ; 2²
.drawMario_a
   ldx #$7E                   ; 2            second byte of Mario sprite

.skipMarioDraw_a
   stx VSYNC,y                ; 4 = @12      waste a cycle and store the byte in GRP0 (y = #$1B)
   ldx #NUM_WALKWAYS+1        ; 2
   jmp EnterKernel            ; 3
   
;
; I'm not sure what the following byte is used for. Tracing the program shows that
; this bytes is never accessed. They're here to make the compiled ROM identical to
; the cart.
;
   IF NTSC

   .byte $9D
   
   ELSE
   
   brk
   
   ENDIF

EndKernel
   jmp MainLoop

BarrelHammerKernel SUBROUTINE
   stx PF2                    ; 3 = @58
JumpBarrelHammerKernel
   lda (marioColorPointer),y  ; 5
   stx PF1                    ; 3            clear the playfield registers (x = 0)
   beq .skipMarioDraw         ; 2³
   ldx zpMarioGraphics,y      ; 4
   
.skipMarioDraw
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3
   lda (missilePointer),y     ; 5
   sta ENAM1                  ; 3 = @11
   lda (ballPointer),y        ; 5
   sta ENABL                  ; 3 = @19
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @27
   stx GRP0                   ; 3 = @30
   lda (pf2Pointer),y         ; 5
   sta PF2                    ; 3 = @38
   lda (rightPF1Pointer),y    ; 5
   ldx #$00                   ; 2
   sta PF1                    ; 3 = @48
   dey                        ; 2
   cpy #WALKWAY_HEIGHT - HAMMER_HEIGHT ; 2
   bcs BarrelHammerKernel     ; 2³
   
BarrelKernel SUBROUTINE
   stx PF2                    ; 3
   lda (marioColorPointer),y  ; 5
   stx PF0                    ; 3 = @65
       
JumpBarrelKernel
   beq .skipMarioDraw         ; 2³
   ldx zpMarioGraphics,y      ; 4
       
.skipMarioDraw
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @3
   stx GRP0                   ; 3 = @6
   ldx #$00                   ; 2
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @16
   lda (leftPF1Pointer),y     ; 5
   sta PF1                    ; 3 = @24
   lda (pf2Pointer),y         ; 5
   sta PF2                    ; 3 = @32
   lda (pf0Pointer),y         ; 5
   sta PF0                    ; 3 = @40
   lda (rightPF1Pointer),y    ; 5
   sta PF1                    ; 3 = @48
   dey                        ; 2
   cpy loopCount              ; 3
   bne BarrelKernel           ; 2³
   
ContinueKernel SUBROUTINE
   lda (marioColorPointer),y  ; 5
   stx PF2                    ; 3 = @63
   sta COLUP0,x               ; 4 = @67
   bne .drawMario             ; 2³
   sta GRP0,x                 ; 4 = @73
   beq .skipMarioDraw         ; 3
.drawMario
   lda zpMarioGraphics+2      ; 3
   sta GRP0                   ; 3 = @76
;--------------------------------------
.skipMarioDraw
   stx PF1                    ; 3 = @3
   stx PF0                    ; 3 = @6
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @14
   ldx groupCount             ; 3
   beq EndKernel              ; 2³
   ldy coarseHorPosP1-1,x     ; 4
   bmi SkipObstacleMove       ; 2³
.coarseMoveObstacle
   dey                        ; 2
   bpl .coarseMoveObstacle    ; 2³
   sta RESP1                  ; 3
   lda fineHorPosP1-1,x       ; 4
   sta HMP1                   ; 3
       
SkipObstacleMove SUBROUTINE
   ldy #$01                   ; 2
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @11
   lda (marioColorPointer),y  ; 5
   sta.w COLUP0               ; 4 = @20
   bne .drawMario             ; 2³
   sta.w GRP0                 ; 4 = @26
   beq .skipMarioDraw         ; 3            always 0
.drawMario
   lda zpMarioGraphics+1      ; 3
   sta GRP0                   ; 3 = @29
.skipMarioDraw
   lda gameScreen             ; 3
   beq .loadBarrelPFPointers  ; 2³
   
   ldy rivits-3,x             ; 4 = @38
   lda FireFoxLeftPF1Table,y  ; 4
   sta leftPF1Pointer         ; 3
   lda FireFoxPF2Table,y      ; 4
   sta pf2Pointer             ; 3
   lda FireFoxPF0Table,y      ; 4
   ldy #$00                   ; 2
   sta pf0Pointer,y           ; 5 = @63
   beq .skipBarrelPFPointers  ; 2³
.loadBarrelPFPointers
   lda BarrelLeftPF1Table-1,x   ; 4 = @39
   sta leftPF1Pointer         ; 3
   lda BarrelPF2Table,x       ; 4
   sta pf2Pointer             ; 3
   lda BarrelPF0Table,x       ; 4
   sta pf0Pointer             ; 3
   lda BarrelRightPF1Table,x  ; 4
   sta rightPF1Pointer        ; 3
   dey                        ; 2 = @65
.skipBarrelPFPointers
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @73 (barrels) @74(firefox)
   lda (marioColorPointer),y  ; 5
;--------------------------------------
   sta.w COLUP0               ; 4 = @5 (barrles) @6(firefox)
   bne .drawMario_a           ; 2³
   sta.w GRP0                 ; 4 = @11 (barrels) @12 (firefox)
   beq .skipDrawMario_a       ; 3
.drawMario_a
   lda zpMarioGraphics        ; 3
   sta GRP0                   ; 3 = @14 (barrels) @15 (firefox)
.skipDrawMario_a
   ldy #WALKWAY_HEIGHT        ; 2

EnterKernel
   lda obstaclePointerLSB-1,x                  ; 4
   sta obstaclePointer        ; 3
   
   lda marioColorPointerLSB-1,x                  ; 4
   sta marioColorPointer      ; 3
   sta HMCLR                  ; 3   clear horizontal movement
   dex                        ; 2
   nop                        ; 2
   stx groupCount             ; 3
   cpx #HAMMER_GROUP          ; 2
   bne .skipHammerKernel      ; 2³
   ldx #$00                   ; 2
   jmp (hammerKernelVector)   ; 5
   
.skipHammerKernel
   lda LoopCountTable,x       ; 4
   sta loopCount              ; 3
   ldx #$00                   ; 2
   lda (marioColorPointer),y  ; 5
   jmp (kernelVector)         ; 5
       
FirefoxHammerKernel SUBROUTINE
   nop                        ; 2 = @54
   lda (marioColorPointer),y  ; 5
   bne .drawMario             ; 2³
   nop                        ; 2
   beq .skipMarioDraw         ; 2³
.drawMario
   ldx zpMarioGraphics,y      ; 4
.skipMarioDraw
   sta COLUP0                 ; 3 = @69
   lda FireFoxLeftPF2Data_1,y ; 4
   sta PF2                    ; 3
;--------------------------------------
   stx GRP0                   ; 3 = @3
   lda (missilePointer),y     ; 5
   sta ENAM1                  ; 3 = @11
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @19
   lda (ballPointer),y        ; 5
   sta ENABL                  ; 3 = @27
   lda FireFoxLeftPF1Data_1-3,y ; 4
   sta PF1                    ; 3 = @34
   lda (marioColorPointer),y  ; 5
   lda marioColorPointer,y    ; 4
   ldx #$00                   ; 2
   dey                        ; 2
   cpy #WALKWAY_HEIGHT - HAMMER_HEIGHT  ; 2
   bcs FirefoxHammerKernel    ; 2³
   
FirefoxKernel SUBROUTINE
   lda (marioColorPointer),y  ; 5

JumpFirefoxKernel
   beq .skipMarioDraw         ; 2³
   ldx zpMarioGraphics,y      ; 4
.skipMarioDraw
   sta WSYNC
;--------------------------------------
   sta COLUP0                 ; 3 = @3
   stx GRP0                   ; 3 = @6
   lda (obstaclePointer),y    ; 5
   sta GRP1                   ; 3 = @14
   lda (leftPF1Pointer),y     ; 5
   sta PF1                    ; 3 = @22
   lda (pf2Pointer),y         ; 5
   sta PF2                    ; 3 = @30
   ldx #$00                   ; 2
   lda (pf0Pointer),y         ; 5
   lda (pf0Pointer),y         ; 5
   dey                        ; 2
   cpy loopCount              ; 3
   sta PF2                    ; 3 = @50
   bne FirefoxKernel          ; 2³
   jmp ContinueKernel         ; 3
       
LF900: .byte $30,$50,$70,$90,$B0,$D0,$D0,$D0,$FF,$FF

;===============================================================================
; R O M - C O D E (Part 2)
;===============================================================================
DetermineLadderMovement
   ldy ladderNumber
   lda verPosMario
   cmp UpLadderTable,y
   beq .allowVerticalMovement
   cmp DownLadderTable,y
   beq .allowVerticalMovement
   sec
   rts
.allowVerticalMovement
   clc
   rts

SetupKernelJumpVector
   lda gameScreen                         ; get the current game screen
   asl
   asl
   adc #$03                               ; a = 3 for barrels and 7 for firefox
   tax
   ldy #$03
.vectorLoadLoop
   lda KernelVectorTable,x
   sta hammerKernelVector,y
   dex
   dey
   bpl .vectorLoadLoop
   
   ldx #$0A
   ldy #$00
   lda gameState
   bpl BCD2DigitPtrs
   ldy #bonusTimer - playerScore - 1      ; set y to have an offset to the number of lives
   
;---------------------------------------------------------------BCD2DigitPtrs
;
; Garry uses y as an offset to load the value he is going to display. If the
; game is in progress then he is going to show the timer bonus. That's why y
; is set to #$1C here.
;
; Notice that the offset of #$1C is the number of lives. The number of lives
; will never be greater than 15 so when he masks the upper nibble, it will
; always be 0.
;
BCD2DigitPtrs
   lda playerScore,y
   and #$F0
   lsr 
   adc #$00
   sta digitPointer-4,x
   lda #>NumberFonts
   sta digitPointer-3,x
   dex
   dex
   lda playerScore,y
   and #$0F
   asl
   asl
   asl
   adc #$00
   sta digitPointer-4,x
   lda #>NumberFonts
   sta digitPointer-3,x
   iny
   dex
   dex
   bpl BCD2DigitPtrs
   
   lda gameState
   bpl ExitBCD2DigitPtrs
   lda #<NullCharacter
   sta digitPointer+6
   sta digitPointer+4
ExitBCD2DigitPtrs
   rts

MarioGraphics
StationaryMarioSprite
   .byte $00 ; |        | $F969
   .byte $3F ; |  XXXXXX| $F96A
   .byte $1B ; |   XX XX| $F96B
   .byte $1B ; |   XX XX| $F96C
   .byte $3F ; |  XXXXXX| $F96D
   .byte $7B ; | XXXX XX| $F96E
   .byte $75 ; | XXX X X| $F96F
   .byte $76 ; | XXX XX | $F970
   .byte $7B ; | XXXX XX| $F971
   .byte $3F ; |  XXXXXX| $F972
   .byte $1F ; |   XXXXX| $F973
   .byte $3E ; |  XXXXX | $F974
   .byte $0F ; |    XXXX| $F975
   .byte $DB ; |XX XX XX| $F976
   .byte $6B ; | XX X XX| $F977
   .byte $1A ; |   XX X | $F978
   .byte $7E ; | XXXXXX | $F979
   .byte $1C ; |   XXX  | $F97A
RunningMarioSprite1
   .byte $00 ; |        | $F97B
   .byte $06 ; |     XX | $F97C
   .byte $02 ; |      X | $F97D
   .byte $02 ; |      X | $F97E
   .byte $EE ; |XXX XXX | $F97F
   .byte $FC ; |XXXXXX  | $F980
   .byte $BD ; |X XXXX X| $F981
   .byte $BD ; |X XXXX X| $F982
   .byte $7F ; | XXXXXXX| $F983
   .byte $F7 ; |XXXX XXX| $F984
   .byte $FE ; |XXXXXXX | $F985
   .byte $9E ; |X  XXXX | $F986
   .byte $0F ; |    XXXX| $F987
   .byte $DB ; |XX XX XX| $F988
   .byte $6B ; | XX X XX| $F989
   .byte $1A ; |   XX X | $F98A
   .byte $7E ; | XXXXXX | $F98B
   .byte $1C ; |   XXX  | $F98C
   .byte $00 ; |        | $F98D
RunningMarioSprite2
   .byte $00 ; |        | $F98E
   .byte $1C ; |   XXX  | $F98F
   .byte $0C ; |    XX  | $F990
   .byte $0D ; |    XX X| $F991
   .byte $1F ; |   XXXXX| $F992
   .byte $1F ; |   XXXXX| $F993
   .byte $0E ; |    XXX | $F994
   .byte $7E ; | XXXXXX | $F995
   .byte $7E ; | XXXXXX | $F996
   .byte $3E ; |  XXXXX | $F997
   .byte $1C ; |   XXX  | $F998
   .byte $0F ; |    XXXX| $F999
   .byte $DB ; |XX XX XX| $F99A
   .byte $6B ; | XX X XX| $F99B
   .byte $1A ; |   XX X | $F99C
   .byte $7E ; | XXXXXX | $F99D
   .byte $1C ; |   XXX  | $F99E
   .byte $00 ; |        | $F99F
   .byte $00 ; |        | $F9A0
   .byte $00 ; |        | $F9A1
   .byte $00 ; |        | $F9A2
JumpingMarioSprite
   .byte $00 ; |        | $F9A3
   .byte $00 ; |        | $F9A4
   .byte $07 ; |     XXX| $F9A5
   .byte $FF ; |XXXXXXXX| $F9A6
   .byte $FE ; |XXXXXXX | $F9A7
   .byte $BC ; |X XXXX  | $F9A8
   .byte $3F ; |  XXXXXX| $F9A9
   .byte $FF ; |XXXXXXXX| $F9AA
   .byte $FE ; |XXXXXXX | $F9AB
   .byte $3E ; |  XXXXX | $F9AC
   .byte $0F ; |    XXXX| $F9AD
   .byte $DB ; |XX XX XX| $F9AE
   .byte $6B ; | XX X XX| $F9AF
   .byte $1A ; |   XX X | $F9B0
   .byte $7E ; | XXXXXX | $F9B1
   .byte $1C ; |   XXX  | $F9B2
ClimbingMarioSprite
   .byte $00 ; |        | $F9B3
   .byte $1C ; |   XXX  | $F9B4
   .byte $1C ; |   XXX  | $F9B5
   .byte $0E ; |    XXX | $F9B6
   .byte $7E ; | XXXXXX | $F9B7
   .byte $7E ; | XXXXXX | $F9B8
   .byte $FE ; |XXXXXXX | $F9B9
   .byte $FE ; |XXXXXXX | $F9BA
   .byte $7F ; | XXXXXXX| $F9BB
   .byte $7F ; | XXXXXXX| $F9BC
   .byte $7F ; | XXXXXXX| $F9BD
   .byte $FF ; |XXXXXXXX| $F9BE
   .byte $FE ; |XXXXXXX | $F9BF
   .byte $FC ; |XXXXXX  | $F9C0
   .byte $7C ; | XXXXX  | $F9C1
   .byte $60 ; | XX     | $F9C2
   .byte $00 ; |        | $F9C3
       
JumpingSoundFrequency
   .byte $0F,$0F,$0F,$0F,$0F
   .byte $0F,$0E,$0D,$0D,$0D
   .byte $0E,$0F,$0F,$0F,$0F
   .byte $0F,$0E,$0D,$0D,$0E
       
JumpingSoundFrequency2
   .byte $0F,$0F,$0F,$0F
   .byte $0E,$0D,$0E,$0F
   .byte $0F,$0F,$0E,$0F
       
ObstacleColor
   .byte ORANGE                     ; color of hammer handle and obstacles
       
GirlfriendColors
   .byte YELLOW
   .byte YELLOW
   .byte TURQUISE
   .byte TURQUISE
   .byte TURQUISE
   .byte TURQUISE
   .byte TURQUISE
   .byte SASH_RED
   .byte TURQUISE
   .byte TURQUISE
   .byte BLONDE
   .byte BLONDE
   .byte BLONDE
   .byte BLONDE
   .byte BLONDE
   .byte BLONDE
       
;===============================================================================
; R O M - C O D E (Part 3)
;===============================================================================
       
StoreMarioGraphics SUBROUTINE
   ldy #WALKWAY_HEIGHT
.storeMarioGraphicLoop
   lda (marioGraphicPointer),y
   sta zpMarioGraphics,y
   dey
   bpl .storeMarioGraphicLoop
   rts

InitializationTable1
   .byte BLACK                   ; backgroundColor
   .byte MARIO_STARTX            ; xPosMario
   .byte REFLECT                 ; reflection of Mario
   .word MallotAnimation1        ; missile graphic pointer (hammer)
   .word HandleAnimation1        ; ball graphic pointer (hammer handle)
   .byte $03
   .byte PURPLE                  ; playfield color
   .byte $9A                     ; yPosMario
   .byte $2D                     ; xPosHammer


InitializationTable2
   .byte BLUE           ; playfield color
   .byte $85            ; yPosMario
   .byte $54            ; xPosHammer
   .byte $00
   .byte $01
   .byte $02
   .byte $03
   .byte $04
   .byte $05
   
FireFoxLeftPF1Data_1
   .byte $0F ; |    XXXX|
   .byte $0A ; |    X X |
   .byte $0F ; |    XXXX|
   .byte $0A ; |    X X |
   .byte $0F ; |    XXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $00 ; |        |
   
FireFoxLeftPF2Data_1
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $FD ; |XXXXXX X|
   .byte $55 ; | X X X X|
   .byte $FD ; |XXXXXX X|
   .byte $55 ; | X X X X|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |

FireFoxLeftPF2Data_0
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $FF ; |XXXXXXXX|
   .byte $54 ; | X X X  |
   .byte $FF ; |XXXXXXXX|
   .byte $54 ; | X X X  |
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
       
FireFoxLeftPF1Data_0
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   
FireFoxLeftPF2Data_2
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $FD ; |XXXXXX X|
   .byte $55 ; | X X X X|
   .byte $FD ; |XXXXXX X|
   .byte $55 ; | X X X X|
   .byte $FD ; |XXXXXX X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
       
;===============================================================================
; R O M - C O D E (Part 4)
;===============================================================================
InitializeGame SUBROUTINE
   ldx #$0A
.barrelLevel
   lda InitializationTable1,x
   sta backgroundColor,x
   dex
   bpl .barrelLevel

   lda gameScreen
   beq .leaveInitialization
   
   ldx #$08
.fireFoxLevel
   lda InitializationTable2,x
   sta playfieldColor,x
   dex 
   bpl .fireFoxLevel
   
.leaveInitialization
   rts

PlayDeathSound
   lda #$FF
   sta losingLifeFlag
   
   IF NTSC
   
   ldx #$11
   
   ELSE
   
   ldx #$0E
   
   ENDIF
   
   lda #$04
   bne PlayMusic
       
Add100Points
   lda #$01
;
;  ON ENTRY:
;
;     A = Value to increase score
;
IncrementScore
   sed
   clc
   adc playerScore+1
   sta playerScore+1
   lda #$00
   adc playerScore
   sta playerScore
   cld

;
; the music for scoring points and for game over are the same
;
PlayIncrementScoreMusic
PlayGameOverMusic

   IF NTSC
   
   ldx #$20
   
   ELSE
   
   ldx #$1A
   
   ENDIF
   
   lda #$03
PlayMusic
   sta soundDuration
   stx soundIndex
   lda #$0C
   sta AUDC0
   lda #$0F
   sta AUDV0
   rts

DownLadderTable
BarrelDownLadderTable
   .byte $84,$65,$68,$4A,$4C,$2E,$30,$15,$05
   
   .byte $15,$2C,$48
   
   .byte $81,$15,$31,$4D,$69,$85

FirefoxDownLadderTable   
   .byte $15,$15,$15,$15,$31,$31,$31,$31,$4D,$4D,$4D,$4D,$69,$69
   .byte $69,$69
       
KernelVectorTable
   .word JumpBarrelHammerKernel
   .word JumpBarrelKernel   
   .word FirefoxHammerKernel
   .word JumpFirefoxKernel

BarrelPFDataTable
   .word BarrelRightPF1Data_6
   .word BarrelPF0Data_6
   .word BarrelPF0Data_0
   .word BarrelPF2Data_0
   
;
; I'm not sure what the following byte is used for. Tracing the program shows that
; this byte is never accessed. They're here to make the compiled ROM identical to
; the cart.
;
   IF NTSC
   
   .byte $2A
   
   ELSE
   
   .byte $00
   
   ENDIF
   
UpLadderTable
BarrelUpLadderTable
;
; starting from the bottom
;
   .byte $9A                        ; last ladder
   .byte $82,$7F                    ; right to left
   .byte $65,$63                    ; left ot right
   .byte $49,$47                    ; right to left
   .byte $2B                        ; left to right
   .byte $15                        ; last ladder
   
   .byte $2E
   .byte $4B
   .byte $67,$9A
   .byte $2A,$46
   .byte $62,$7E
   .byte $9A
   
FirefoxUpLadderTable
;
; starting from the bottom
;
   .byte $31,$31,$31,$31
   .byte $4D,$4D,$4D,$4D
   .byte $69,$69,$69,$69
   .byte $85,$85,$85,$85

MarioColors
HorizontalColors

   REPEAT WALKWAY_HEIGHT + 2
   .byte BLACK
   REPEND
   
   .byte BLUE_GREEN
   .byte BLUE_GREEN
   .byte RED
   .byte RED
   .byte RED   
   .byte RED   
   .byte RED
   .byte RED
   .byte RED
   .byte RED
   .byte WHITE
   .byte WHITE
   .byte WHITE   
   .byte WHITE   
   .byte WHITE
   .byte RED
   .byte RED

VerticalColors
   REPEAT WALKWAY_HEIGHT + 2
   .byte BLACK
   REPEND
   
   .byte BLUE_GREEN
   .byte BLUE_GREEN
   .byte BLUE_GREEN
   .byte RED
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED   
   .byte RED
   .byte RED
   
   REPEAT WALKWAY_HEIGHT + 1
   .byte BLACK
   REPEND
   
DonkeyKong
   .byte $00 ; |        |
   .byte $E0 ; |XXX     | $FB99
   .byte $E0 ; |XXX     | $FB9A
   .byte $67 ; | XX  XXX| $FB9B
   .byte $67 ; | XX  XXX| $FB9C
   .byte $7E ; | XXXXXX | $FB9D
   .byte $7E ; | XXXXXX | $FB9E
   .byte $3E ; |  XXXXX | $FB9F
   .byte $5E ; | X XXXX | $FBA0
   .byte $DC ; |XX XXX  | $FBA1
   .byte $BC ; |X XXXX  | $FBA2
   .byte $FE ; |XXXXXXX | $FBA3
   .byte $FF ; |XXXXXXXX| $FBA4
   .byte $7F ; | XXXXXXX| $FBA5
   .byte $39 ; |  XXX  X| $FBA6
   .byte $45 ; | X   X X| $FBA7
   .byte $7D ; | XXXXX X| $FBA8
   .byte $55 ; | X X X X| $FBA9
   .byte $7C ; | XXXXX  | $FBAA
   .byte $38 ; |  XXX   | $FBAB
       
ObstacleTable
   .byte <HorizontalBarrelSprite+OBSTACLE_HEIGHT-WALKWAY_HEIGHT
   .byte <FallingBarrelSprite+OBSTACLE_HEIGHT-WALKWAY_HEIGHT
   .byte <FirefoxSprite+OBSTACLE_HEIGHT-WALKWAY_HEIGHT

FireFoxLeftPF1Table
   REPEAT NUM_WALKWAYS - 1
      .byte <FireFoxLeftPF1Data_0
      
      REPEAT NUM_WALKWAYS
         .byte <FireFoxLeftPF1Data_1-3
      REPEND
      
   REPEND
   
FireFoxPF2Table
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   
FireFoxPF0Table
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   .byte <FireFoxLeftPF2Data_1
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   
   .byte <FireFoxLeftPF1Data_0
   .byte <FireFoxLeftPF2Data_0
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
   .byte <FireFoxLeftPF2Data_2
       
LivesPFPattern
   .byte $00 ; |        |           no lives remaining
   .byte $01 ; |       X|           one life
   .byte $05 ; |     X X|           two lives
   .byte $15 ; |   X X X|           three lives
   
   IF NTSC
   
   .byte $89,$A5,$0D,$E9,$00
   
   ELSE
   
   .byte $00,$FF,$FF,$00,$00
   
   ENDIF
   
NumberFonts
   .byte $3C ; |  XXXX  | $FC00
   .byte $66 ; | XX  XX | $FC01
   .byte $66 ; | XX  XX | $FC02
   .byte $66 ; | XX  XX | $FC03
   .byte $66 ; | XX  XX | $FC04
   .byte $66 ; | XX  XX | $FC05
   .byte $3C ; |  XXXX  | $FC06
   .byte $00 ; |        | $FC07
   .byte $7E ; | XXXXXX | $FC08
   .byte $18 ; |   XX   | $FC09
   .byte $18 ; |   XX   | $FC0A
   .byte $18 ; |   XX   | $FC0B
   .byte $38 ; |  XXX   | $FC0C
   .byte $18 ; |   XX   | $FC0D
   .byte $08 ; |    X   | $FC0E
   .byte $00 ; |        | $FC0F
   .byte $7E ; | XXXXXX | $FC10
   .byte $62 ; | XX   X | $FC11
   .byte $60 ; | XX     | $FC12
   .byte $3C ; |  XXXX  | $FC13
   .byte $06 ; |     XX | $FC14
   .byte $46 ; | X   XX | $FC15
   .byte $3C ; |  XXXX  | $FC16
   .byte $00 ; |        | $FC17
   .byte $3C ; |  XXXX  | $FC18
   .byte $46 ; | X   XX | $FC19
   .byte $06 ; |     XX | $FC1A
   .byte $1C ; |   XXX  | $FC1B
   .byte $06 ; |     XX | $FC1C
   .byte $46 ; | X   XX | $FC1D
   .byte $3C ; |  XXXX  | $FC1E
   .byte $00 ; |        | $FC1F
   .byte $0C ; |    XX  | $FC20
   .byte $0C ; |    XX  | $FC21
   .byte $7E ; | XXXXXX | $FC22
   .byte $4C ; | X  XX  | $FC23
   .byte $2C ; |  X XX  | $FC24
   .byte $1C ; |   XXX  | $FC25
   .byte $0C ; |    XX  | $FC26
   .byte $00 ; |        | $FC27
   .byte $3C ; |  XXXX  | $FC28
   .byte $46 ; | X   XX | $FC29
   .byte $06 ; |     XX | $FC2A
   .byte $7C ; | XXXXX  | $FC2B
   .byte $60 ; | XX     | $FC2C
   .byte $60 ; | XX     | $FC2D
   .byte $7E ; | XXXXXX | $FC2E
   .byte $00 ; |        | $FC2F
   .byte $3C ; |  XXXX  | $FC30
   .byte $66 ; | XX  XX | $FC31
   .byte $66 ; | XX  XX | $FC32
   .byte $7C ; | XXXXX  | $FC33
   .byte $60 ; | XX     | $FC34
   .byte $62 ; | XX   X | $FC35
   .byte $3C ; |  XXXX  | $FC36
   .byte $00 ; |        | $FC37
   .byte $30 ; |  XX    | $FC38
   .byte $30 ; |  XX    | $FC39
   .byte $18 ; |   XX   | $FC3A
   .byte $0C ; |    XX  | $FC3B
   .byte $06 ; |     XX | $FC3C
   .byte $42 ; | X    X | $FC3D
   .byte $7E ; | XXXXXX | $FC3E
   .byte $00 ; |        | $FC3F
   .byte $3C ; |  XXXX  | $FC40
   .byte $66 ; | XX  XX | $FC41
   .byte $66 ; | XX  XX | $FC42
   .byte $3C ; |  XXXX  | $FC43
   .byte $66 ; | XX  XX | $FC44
   .byte $66 ; | XX  XX | $FC45
   .byte $3C ; |  XXXX  | $FC46
   .byte $00 ; |        | $FC47
   .byte $3C ; |  XXXX  | $FC48
   .byte $46 ; | X   XX | $FC49
   .byte $06 ; |     XX | $FC4A
   .byte $3E ; |  XXXXX | $FC4B
   .byte $66 ; | XX  XX | $FC4C
   .byte $66 ; | XX  XX | $FC4D
   .byte $3C ; |  XXXX  | $FC4E
   .byte $00 ; |        | $FC4F
   
LFC50: .byte $80,$90,$32,$36,$36,$3A,$32,$31,$FF,$34,$3A,$3A,$80

ObstacleSprites
NullCharacter
HorizontalBarrelSprite

   REPEAT OBSTACLE_HEIGHT - OBSTACLE_GRAPHIC_HEIGHT + 1
      .byte $00                     ; blank line
   REPEND
   
   .byte $3C ; |  XXXX  | $FC7A
   .byte $6E ; | XX XXX | $FC7B
   .byte $FB ; |XXXXX XX| $FC7C
   .byte $BF ; |X XXXXXX| $FC7D
   .byte $FD ; |XXXXXX X| $FC7E
   .byte $DF ; |XX XXXXX| $FC7F
   .byte $76 ; | XXX XX | $FC80
   .byte $3C ; |  XXXX  | $FC81
   
FallingBarrelSprite

   REPEAT OBSTACLE_HEIGHT - OBSTACLE_GRAPHIC_HEIGHT + 1
      .byte $00                     ; blank line
   REPEND
   
   .byte $7E ; | XXXXXX | $FC9F
   .byte $99 ; |X  XX  X| $FCA0
   .byte $BD ; |X XXXX X| $FCA1
   .byte $81 ; |X      X| $FCA2
   .byte $BD ; |X XXXX X| $FCA3
   .byte $99 ; |X  XX  X| $FCA4
   .byte $7E ; | XXXXXX | $FCA5
   .byte $00 ; |        | $FCA6
   
FirefoxSprite

   REPEAT OBSTACLE_HEIGHT - OBSTACLE_GRAPHIC_HEIGHT + 1
      .byte $00                     ; blank line
   REPEND
   
   .byte $38 ; |  XXX   | $FCC4
   .byte $7E ; | XXXXXX | $FCC5
   .byte $FF ; |XXXXXXXX| $FCC6
   .byte $FF ; |XXXXXXXX| $FCC7
   .byte $71 ; | XXX   X| $FCC8
   .byte $AA ; |X X X X | $FCC9
   .byte $AA ; |X X X X | $FCCA
   .byte $71 ; | XXX   X| $FCCB
   
   REPEAT OBSTACLE_HEIGHT - OBSTACLE_GRAPHIC_HEIGHT + 1
      .byte $00                     ; blank line
   REPEND
       
FirefoxVerPos
   .byte $60,$44,$28,TOP_PLATFORM_VALUE
   
;===============================================================================
; R O M - C O D E (Part 5)
;===============================================================================
StartNewScreen SUBROUTINE
   lda #$00
   ldx #$06
   ldy #<HorizontalColors
.loop
   sta verPosP1,x                   ; clear out obstacle vert position, jumpHangTime,
   dex                              ; and hammerTime
   bmi .doneStartNewScreen
   sty marioColorPointerLSB,x
   bpl .loop
.doneStartNewScreen
   jmp InitializeGame
;
; The following byte seems to just be a filler byte to push AudioFrequencyTable to the
; next page. I kept the values intact so the compiled ROM is identical to the cart.
;
   IF NTSC

   .byte $98
   
   ELSE
   
   .byte $00
   
   ENDIF

AudioFrequecyTable
   .word JumpingSoundFrequency
   .word WalkingSoundFrequency
   .word ScoringSoundFrequency
   .word DeathSoundFrequency
   .word JumpingSoundFrequency2
   .word LF900
   
DeathSoundFrequency

   IF NTSC
   
   .byte $0C,$0C,$0C,$0C
   .byte $11,$11,$11
   .byte $08,$08,$08
   .byte $0B,$0A,$09,$08,$07,$06,$05
   
   ELSE
   
   .byte $0C,$0C,$0C,$11,$11,$08,$08,$0B,$0A,$09,$08,$07,$06,$05,$00,$00,$00
   
   ENDIF

BarrelRightPF1Data_1
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $14 ; |   X X  |
   .byte $3C ; |  XXXX  |
   .byte $E8 ; |XXX X   |
   .byte $54 ; | X X X  |
   .byte $AC ; |X X XX  |
   .byte $78 ; | XXXX   |
   .byte $C0 ; |XX      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $C0 ; |XX      |
   .byte $78 ; | XXXX   |
   .byte $AF ; |X X XXXX|
   .byte $55 ; | X X X X|
   .byte $EA ; |XXX X X |
   .byte $3D ; |  XXXX X|
   .byte $07 ; |     XXX|
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $14 ; |   X X  |
   .byte $3C ; |  XXXX  |
   .byte $E8 ; |XXX X   |
   .byte $54 ; | X X X  |
   .byte $AC ; |X X XX  |
   .byte $78 ; | XXXX   |
   .byte $C0 ; |XX      |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $C0 ; |XX      |
   .byte $78 ; | XXXX   |
   .byte $AF ; |X X XXXX|
   .byte $55 ; | X X X X|
   .byte $EA ; |XXX X X |
   .byte $3D ; |  XXXX X|
   .byte $07 ; |     XXX|
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |       
BarrelRightPF1Data_6
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $FC ; |XXXXX X |
   .byte $6C ; | XX X X |
   .byte $90 ; |X  X    |
   .byte $6C ; | XX X X |
   .byte $FC ; |XXXXX X |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
;
; last byte shared so don't cross a page boundary
;
Girlfriend
   .byte $00 ; |        |
   .byte $43 ; | X    XX| $FDAD
   .byte $82 ; |X     X | $FDAE
   .byte $7E ; | XXXXXX | $FDAF
   .byte $7F ; | XXXXXXX| $FDB0
   .byte $FF ; |XXXXXXXX| $FDB1
   .byte $7E ; | XXXXXX | $FDB2
   .byte $3C ; |  XXXX  | $FDB3
   .byte $18 ; |   XX   | $FDB4
   .byte $7E ; | XXXXXX | $FDB5
   .byte $38 ; |  XXX   | $FDB6
   .byte $9C ; |X  XXX  | $FDB7
   .byte $7E ; | XXXXXX | $FDB8
   .byte $BF ; |X XXXXXX| $FDB9
   .byte $3A ; |  XXX X | $FDBA
   .byte $1F ; |   XXXXX| $FDBB
   .byte $07 ; |     XXX| $FDBC
   .byte $00 ; |        | $FDBD
   .byte $00 ; |        | $FDBE
   .byte $00 ; |        | $FDBF
   
;
; ladder values are stored right to left starting with the lowest walkway
;
LadderHorizValues
   .byte $6D                        ; walkway 0
   .byte $51,$31                    ; walkway 1
   .byte $59,$6D                    ; walkway 2
   .byte $45,$31                    ; walkway 3
   .byte $6D                        ; walkway 4
   .byte $4D                        ; walkway 5
;
; going down -- reverse order
;
   .byte $4D                        ; walkway 5
   .byte $65                        ; walkway 4
   .byte $41,$49                    ; walkway 3
   .byte $7B,$23                    ; walkway 2
   .byte $7B,$23                    ; walkway 1
   .byte $7B                        ; walkway 0
   
.firefoxLadderHorizValues
   .byte $29,$3D,$61,$75
   .byte $29,$3D,$61,$75
   .byte $29,$3D,$61,$75
   .byte $29,$3D,$61,$75
       
;===============================================================================
; R O M - C O D E (Part 6)
;===============================================================================

;-----------------------------------------------------------------PositionHammer
;
; This subroutine positions the hammer objects horizontally. There is only one
; hammer per level so doing this outside of the kernel is okay.
;
;  ON ENTRY:
;
;     A = Position
;     X = Index to object (3 = handle 4 = mallot)
;
PositionHammer SUBROUTINE
   sta WSYNC
   sec
.coarseMoveLoop
   sbc #$0F
   bcs .coarseMoveLoop
   eor #$0F
   asl
   asl
   asl
   asl
   adc #HMOVE_R7
   sta RESP0,x
   sta WSYNC
   sta HMP0,x
   rts

RampHorizValues
   .byte $75,$69,$5D,$51,$45,$3A,$2D

   IF NTSC
   
   .byte $88
   
   ELSE
   
   .byte $00
   
   ENDIF

MarioColorTable
   .byte <HorizontalColors
   .byte <HorizontalColors
   .byte <HorizontalColors
   .byte <HorizontalColors+1
   .byte <HorizontalColors+2
   .byte <VerticalColors
   .byte <HorizontalColors

WalkingSoundFrequency
   .byte $1A

BarrelRightPF1Table
   .byte <BarrelRightPF1Data_0
   .byte <BarrelRightPF1Data_1-13
   .byte <BarrelRightPF1Data_2
   .byte <BarrelRightPF1Data_3
   .byte <BarrelRightPF1Data_4
   .byte <BarrelRightPF1Data_5
   .byte <BarrelRightPF1Data_6
   
BarrelLeftPF1Data_0
   .byte $0F ; |    XXXX|
   .byte $0F ; |    XXXX|
   .byte $00 ; |        |
   .byte $06 ; |     XX |
   .byte $00 ; |        |
   .byte $06 ; |     XX |
   .byte $00 ; |        |
   .byte $06 ; |     XX |
   .byte $00 ; |        |
   .byte $06 ; |     XX |
   .byte $00 ; |        |
   .byte $06 ; |     XX |
   .byte $00 ; |        |
BarrelPF0Data_3
   .byte $06 ; |     XX |
BarrelLeftPF1Data_2
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $01 ; |       X|
   .byte $0F ; |    XXXX|
   .byte $0A ; |    X X |
   .byte $05 ; |     X X|
   .byte $0B ; |    X XX|
   .byte $0E ; |    XXX |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
BarrelPF0Data_4
   .byte $00 ; |        |
   .byte $00 ; |        |
   
BarrelLeftPF1Data_3
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $02 ; |      X |
   .byte $03 ; |      XX|
   .byte $01 ; |       X|
   .byte $02 ; |      X |
   .byte $03 ; |      XX|
   .byte $01 ; |       X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   
BarrelPF0Data_5
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
       
BarrelPF2Data_0
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $0F ; |    XXXX|
   .byte $0B ; |    X XX|
   .byte $04 ; |     X  |
   .byte $0B ; |    X XX|
   .byte $0F ; |    XXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $08 ; |    X   |
       
BarrelPF2Data_2
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
BarrelPF0Data_1
   .byte $00 ; |        |
   .byte $E0 ; |XXX     |
   .byte $BC ; |X XXXX  |
   .byte $57 ; | X X XXX|
   .byte $AA ; |X X X X |
   .byte $F5 ; |XXXX X X|
   .byte $1E ; |   XXXX |
   .byte $03 ; |      XX|
   .byte $00 ; |        |
   .byte $01 ; |       X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $01 ; |       X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $01 ; |       X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $01 ; |       X|
   
BarrelPF2Data_3
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $01 ; |       X|
   .byte $03 ; |      XX|
   .byte $1E ; |   XXXX |
   .byte $F5 ; |XXXX X X|
   .byte $AA ; |X X X X |
   .byte $57 ; | X X XXX|
   .byte $BC ; |X XXXX  |
   .byte $E0 ; |XXX     |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   
BarrelPF2Data_4
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $F0 ; |XXXX    |
   .byte $BC ; |X XXXX  |
   .byte $57 ; | X X XXX|
   .byte $AA ; |X X X X |
   .byte $F5 ; |XXXX X X|
   .byte $1E ; |   XXXX |
   .byte $03 ; |      XX|
   .byte $00 ; |        |
   .byte $21 ; |  X    X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $21 ; |  X    X|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $21 ; |  X    X|
   
BarrelPF2Data_5
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $21 ; |  X    X|
   .byte $03 ; |      XX|
   .byte $1E ; |   XXXX |
   .byte $F5 ; |XXXX X X|
   .byte $AA ; |X X X X |
   .byte $57 ; | X X XXX|
   .byte $BC ; |X XXXX  |
   .byte $E0 ; |XXX     |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |       
BarrelPF0Data_0
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $FF ; |XXXXXXXX|
   .byte $B6 ; |X XX XX |
   .byte $49 ; | X  X  X|
   .byte $B6 ; |X XX XX |
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
       
BarrelPF2Data_1       
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   
   IF NTSC
   
   .byte $A0
   
   ELSE
   
   .byte $00
   
   ENDIF
   
MarioAnimationTable
   .byte <StationaryMarioSprite-WALKWAY_HEIGHT-1; $4D
   .byte <RunningMarioSprite1-WALKWAY_HEIGHT-1; $5F
   .byte <StationaryMarioSprite-WALKWAY_HEIGHT-1; $4D
   .byte <RunningMarioSprite2-WALKWAY_HEIGHT-1; $72
   .byte <JumpingMarioSprite-WALKWAY_HEIGHT-1; $87
   .byte <ClimbingMarioSprite-WALKWAY_HEIGHT-1; $97
   .byte <StationaryMarioSprite-WALKWAY_HEIGHT-1; $4D

BarrelPF0Data_2
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $F0 ; |XXXX    |
   .byte $50 ; | X X    |
   .byte $A0 ; |X X     |
   .byte $D0 ; |XX X    |
   .byte $70 ; | XXXX   |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
BarrelRightPF1Data_0
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $10 ; |   X    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $70 ; | XXX    |
   .byte $D0 ; |XX X    |
   .byte $A0 ; |X X     |
   .byte $50 ; | X X    |
   .byte $F0 ; |XXXX    |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
BarrelRightPF1Data_2
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $40 ; | X      |
   .byte $00 ; |        |
   .byte $80 ; |X       |
   .byte $F0 ; |XXXX    |
   .byte $50 ; | X X    |
   .byte $A0 ; |X X     |
   .byte $D0 ; |XX X    |
   .byte $70 ; | XXX    |
   .byte $00 ; |        |
BarrelRightPF1Data_3
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $70 ; | XXX    |
   .byte $D0 ; |XX X    |
   .byte $A0 ; |X X     |
   .byte $50 ; | X X    |
   .byte $F0 ; |XXXX    |
   .byte $80 ; |X       |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
BarrelRightPF1Data_4
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |       
BarrelPF0Data_6
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $F0 ; |XXXX    |
   .byte $D0 ; |XX X    |
   .byte $20 ; |  X     |
   .byte $D0 ; |XX X    |
   .byte $F0 ; |XXXX    |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
NoHammerAnimation
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
BarrelRightPF1Data_5
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $F0 ; |XXXX    |
       
MallotAnimation1
   .byte $F0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
   
HandleAnimation1
   .byte $00 ; |        | 
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |   
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   
HandleAnimation2
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        | 
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |   
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |   
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   
MallotAnimation2
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        |
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |        | 
   .byte $00 ; |        |
   .byte $00 ; |        |
   .byte $00 ; |        |   
   .byte $00 ; |        |
   
   
   
   .byte $00,$00,$00,$00
   

   .byte $FF,$FF,$00,$00,$00,$00,$00,$00
       .byte $00,$00,$00
       
ScoringSoundFrequency
   .byte $0A,$0A,$0A,$0A,$0A,$0A,$0A
   .byte $06,$06,$06,$06,$06,$06,$06,$06,$06,$06,$06
   .byte $07,$07,$07,$07,$07
   .byte $08,$08,$08,$08,$08
   .byte $0A,$0A,$0A,$0A,$0A

       
BarrelLeftPF1Table
   .byte <BarrelLeftPF1Data_2-WALKWAY_HEIGHT
   .byte <BarrelLeftPF1Data_2
   .byte <BarrelLeftPF1Data_3
   .byte <BarrelLeftPF1Data_2
   .byte <BarrelLeftPF1Data_3

BarrelPF2Table
   .byte <BarrelPF2Data_0
   .byte <BarrelPF2Data_1
   .byte <BarrelPF2Data_2
   .byte <BarrelPF2Data_3
   .byte <BarrelPF2Data_4
   .byte <BarrelPF2Data_5
   
BarrelPF0Table
   .byte <BarrelPF0Data_0;$D4
   .byte <BarrelPF0Data_1;$71
   .byte <BarrelPF0Data_2-3
   .byte <BarrelPF0Data_3;$1C
   .byte <BarrelPF0Data_4;$34
   .byte <BarrelPF0Data_5;$49
   
   .byte $62                        ; ???????????

LoopCountTable
   .byte $0C,$02,$02,$02,$02,$02

   org $FFFC
   .word Start
   .word Start