   LIST OFF
; ***  B E R Z E R K  ***
; Copyright 1982 Atari, Inc
; Programmer: Dan Hitchens

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: December 29, 2004
;
; - Dan seems to use a form of .skipDraw which was developed by
;   Thomas Jentzsch (see
;   http://www.biglist.com/lists/stella/archives/200102/msg00282.html)
;   It doesn't use illegal opcodes like the one referenced above. It looks
;   more like my first attempt. Where two variables are used (upper and
;   lower boundaries) to determine if it's time to draw the sprite.
; - This game adjusts game speed so PAL and NTSC game speeds are virtually
;   identical. Notice how the frame delay values for PAL are 1.2 times that
;   of the NTSC values.
; - It looks as if it was planned for the robots to fire diagonally. The
;   values are present in the ROM but would need a little adjusting to get it
;   accurate.
; - Looks as if RAM locations $FA and $FB are not used
; - Evil Otto is launched at ~12 seconds after entering a board
; - A number flags and RAM overlays are used in this game so I may not have
;   identified them all correctly.

   processor 6502
      
;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

   include vcs.h
   include macro.h

   LIST ON

;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

NTSC                    = 0
PAL                     = 1

COMPILE_VERSION         = NTSC      ; change this to compile for different
                                    ; regions
                                    
;============================================================================
; T I A - C O N S T A N T S
;============================================================================

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
MSBL_SIZE1        = %000000
MSBL_SIZE2        = %010000
MSBL_SIZE4        = %100000
MSBL_SIZE8        = %110000

VERTICAL_DELAY    = 1

; values for REFPx:
NO_REFLECT        = %0000
REFLECT           = %1000

; SWCHA joystick bits:
MOVE_RIGHT        = %1000
MOVE_LEFT         = %0100
MOVE_DOWN         = %0010
MOVE_UP           = %0001
NO_MOVE           = %0000

; mask for SWCHB
BW_MASK           = %1000         ; black and white bit
SELECT_MASK       = %10
RESET_MASK        = %01

;============================================================================
; U S E R - C O N S T A N T S
;============================================================================

ROMTOP         = $F000

; color constants
BLACK          =  $00
WHITE          =  $0E

   IF COMPILE_VERSION = NTSC
   
VBLANK_TIME    = $2C
OVERSCAN_TIME  = $24

; NTSC color constants
YELLOW         = $10
RED            = $30
RED_2          = $40
RED_3          = RED_2
RED_4          = RED
PURPLE         = $50
BLUE           = $88
GREEN_BLUE     = $A8
LT_GREEN       = $CA
BROWN          = $F0
BROWN_2        = BROWN

PLAYER_FRACTIONAL_DELAY    = $70    ; move 7 out of 16 frames

; Robot movement frame delay values
ROBOT_MOVE_DELAY_0         = $20    ; move 4 out of 32 frames
ROBOT_MOVE_DELAY_1         = $28    ; move 5 out of 32 frames
ROBOT_MOVE_DELAY_2         = $30    ; move 6 out of 32 frames
ROBOT_MOVE_DELAY_3         = $38    ; move 7 out of 32 frames
ROBOT_MOVE_DELAY_4         = $40    ; move 8 out of 32 frames
ROBOT_MOVE_DELAY_5         = $48    ; move 9 out of 32 frames
ROBOT_MOVE_DELAY_6         = $50    ; move 10 out of 32 frames
ROBOT_MOVE_DELAY_7         = $58    ; move 11 out of 32 frames

; Robot missile frame delay values
ROBOT_MISSILE_DELAY_0      = $38    ; move 7 out of 32 frames
ROBOT_MISSILE_DELAY_1      = $40    ; move 8 out of 32 frames
ROBOT_MISSILE_DELAY_2      = $50    ; move 10 out of 32 frames
ROBOT_MISSILE_DELAY_3      = $60    ; move 12 out of 32 frames
ROBOT_MISSILE_DELAY_4      = $78    ; move 15 out of 32 frames
ROBOT_MISSILE_DELAY_5      = $90    ; move 18 out of 32 frames
ROBOT_MISSILE_DELAY_6      = $B0    ; move 22 out of 32 frames
ROBOT_MISSILE_DELAY_7      = $D0    ; move 26 out of 32 frames

   ELSE
   
VBLANK_TIME    = $36
OVERSCAN_TIME  = $2B

; PAL color constants
BLACK2         = $10
YELLOW         = $20
BROWN          = $40
RED            = $60
RED_2          = RED
RED_3          = BROWN
RED_4          = RED_3
GREEN_BLUE     = $56
LT_GREEN       = $5E
PURPLE         = $A0
BLUE           = $DA
BROWN_2        = $F0

PLAYER_FRACTIONAL_DELAY    = $86    ; move 7 out of 16 frames

; Robot movement frame delay values
ROBOT_MOVE_DELAY_0         = $26    ; move 4 out of 32 frames
ROBOT_MOVE_DELAY_1         = $30    ; move 5 out of 32 frames
ROBOT_MOVE_DELAY_2         = $3A    ; move 6 out of 32 frames
ROBOT_MOVE_DELAY_3         = $43    ; move 7 out of 32 frames
ROBOT_MOVE_DELAY_4         = $4D    ; move 8 out of 32 frames
ROBOT_MOVE_DELAY_5         = $56    ; move 9 out of 32 frames
ROBOT_MOVE_DELAY_6         = $60    ; move 10 out of 32 frames
ROBOT_MOVE_DELAY_7         = $6A    ; move 11 out of 32 frames

; Robot missile frame delay values
ROBOT_MISSILE_DELAY_0      = $43    ; move 7 out of 32 frames
ROBOT_MISSILE_DELAY_1      = $4D    ; move 8 out of 32 frames
ROBOT_MISSILE_DELAY_2      = $60    ; move 10 out of 32 frames
ROBOT_MISSILE_DELAY_3      = $73    ; move 12 out of 32 frames
ROBOT_MISSILE_DELAY_4      = $90    ; move 15 out of 32 frames
ROBOT_MISSILE_DELAY_5      = $AD    ; move 18 out of 32 frames
ROBOT_MISSILE_DELAY_6      = $D3    ; move 22 out of 32 frames
ROBOT_MISSILE_DELAY_7      = $FA    ; move 26 out of 32 frames

   ENDIF

COLOR_LIGHT_LUM            = $F7

H_FONT                     = 7
H_ROBOT                    = 9
H_PLAYER                   = 12

H_KERNEL                   = 176

XMIN                       = 0
XMAX                       = 149
XMAX_PLAYER                = XMAX - 3

YMIN                       = 0

MAX_GAME_SELECTION         = $12    ; BCD

SELECT_DELAY               = 26

MAX_ROBOTS                 = 8

INIT_NUM_LIVES             = 3

SHOOTING_ROBOT_SCORE       = $50    ; BCD

ROBOT_STAND_ANIM_OFFSET    = 0
ROBOT_LEFT_ANIM_OFFSET     = 9
ROBOT_RIGHT_ANIM_OFFSET    = 12
ROBOT_UP_ANIM_OFFSET       = 15
ROBOT_DOWN_ANIM_OFFSET     = 19
ROBOT_DEATH_ANIM_OFFSET    = 23

PLAYER_STAND_ANIM_OFFSET   = 0
PLAYER_RUN_ANIM_OFFSET     = 1
PLAYER_DEATH_ANIM_OFFSET   = 3

; game variation flags
EXTRA_LIFE_2000            = %10000000
EXTRA_LIFE_1000            = %01000000
OTTO_INVINCIBLE            = %00100000
OTTO_REBOUND               = %00010000
NO_OTTO                    = %00001000
ROBOT_SHOOTING             = %00000001

; player starting location values
PLAYER_ENTERING_NORTH      = 0
PLAYER_ENTERING_SOUTH      = 1
PLAYER_ENTERING_WEST       = 2
PLAYER_ENTERING_EAST       = 3

ROBOT_SHOOTING_RIGHT       = %0001
ROBOT_SHOOTING_LEFT        = %0010
ROBOT_SHOOTING_DOWN        = %0100
ROBOT_SHOOTING_UP          = %1000

XROBOT_MISSILE_BOX         = 8
YROBOT_MISSILE_BOX         = 6

;============================================================================
; M A C R O S
;============================================================================

;
; time wasting macros
;

   MAC SLEEP_3
      lda playerGraphicPointer
   ENDM
      
   MAC SLEEP_4
      nop
      nop
   ENDM
      
   MAC SLEEP_8
      nop
      SLEEP_3
      SLEEP_3
   ENDM
   
   MAC SLEEP_9
      SLEEP_3
      SLEEP_3
      SLEEP_3
   ENDM
   
;============================================================================
; Z P - V A R I A B L E S
;============================================================================

gameSelection           = $80
gameState               = $81
mazeNumber              = $82
mazeOffset              = $83       ; offset into maze drawing data
frameCount              = $84

START_GAME_RAM          = $85
;--------------------------------------
colorEOR                = $85
selectDebounce          = $86
attractModeTimer        = $87
gameVariation           = $88
playerGraphicPointer    = $89       ; $89 - $8A
playerVertPos           = $8B
player0Scanline         = $8C
playerUpperBoundary     = $8D
playerDirection         = $8E
playerMissilePointer    = $8F       ; $8F - $90
playerAnimationIndex    = $91
playerMotion            = $92       ; fractional delay for player movement
playerHorizPos          = $93
playerMissileFlightTime = $94
playerMissileDirection  = $95
playerMissileHorizPos   = $96
playerMissileVertPos    = $97
robotMissilePointer     = $98       ; $98 - $99
robotMissileDirection   = $9A
robotMissileDelay       = $9B       ; fractional delay value for missile
robotMissileFlightTime  = $9C
robotMissileHorizPos    = $9D
robotMissileVertPos     = $9E
delayRobotAnimation     = $9F
;--------------------------------------
robotFineHoriz          = delayRobotAnimation   ; $9F - $A6
;--------------------------------------
upperPlayfieldLimit     = $A6       ; upper scanline limit for screen transition
robotCoarseHoriz        = $A7       ; $A7 - $AE
evilOttoHorizPos        = $AE
robotPointers           = $AF       ; $AF - $B6
robotMotion             = $B7       ; fractional delay for robot movement
robotVertPos            = $B8       ; $B8 - $C0
robotHorizPos           = $C1       ; $C1 - $C8
;--------------------------------------
tempOttoVertPos         = $C8
playerCollisions        = $C9       ; $C9 - $D0
;--------------------------------------
lowerPlayfieldLimit     = $D0       ; lower scanline limit for screen transition
prevEvilOttoVertPos     = $D1
robotAnimationIndex     = $D2       ; $D2 - $D9
evilOttoVertPos         = $D9
numberOfLives           = $DA
numberRobotsKilled      = $DB
gameLevel               = $DC       ; incremented when level is completed
playerScore             = $DD       ; $DD - $DF
robotMotionDelay        = $E0
mazePF0Value            = $E1
playerStartingLocation  = $E2
random                  = $E3       ; $E3 - $E4
initRobotDelay          = $E5       ; robots not active until value is 255
temp01                  = $E6
;--------------------------------------
lsbDigitPointer         = temp01
;--------------------------------------
robotGraphics           = lsbDigitPointer
;--------------------------------------
tempPlayerExitingPos    = robotGraphics
temp02                  = $E7       ; used for various things
loopCount               = $E8
;--------------------------------------
randomNumberMax         = loopCount
lastRobotVertPos        = $E9
;--------------------------------------
tempCharHolder          = lastRobotVertPos
;--------------------------------------
compRobotToMove         = tempCharHolder
digitPointer            = $EA          ; $EA - $F5
evilOttoLaunchTimer     = $F6
audioIndex              = $F7
robotMissileSoundIndex  = $F8
ottoVerticalDelta       = $F9
kernelSection           = $FC
playerGraphicLSB        = $FD
;--------------------------------------
player0Graphic          = playerGraphicLSB
robotCoarsePos          = $FE       ; value to coarse move robot in kernel

;============================================================================
; R O M - C O D E (Part 1)
;============================================================================

   SEG Bank0
   org ROMTOP

Start
   jmp ColdStart
   
.waste15Cycles
   SLEEP_9                    ; 9
   jmp .drawMazeData          ; 3
       
.waste10Cycles
   SLEEP_4                    ; 4
   jmp .drawMazeData          ; 3
       
ReadCollisionsForSection
   lda CXP1FB                 ; 3         read player1/PF collision
   ora CXM0P                  ; 3         or player0 missile collisions
   ora CXPPMM                 ; 3         or player/player and 
   and #%10000000             ; 2         mask ball, M0/M0, M0/P0 collisions
   bit CXM1P                  ; 3
   bvc .setCollisions         ; 2³
   ora #1                     ; 2         show a robot shot this robot
.setCollisions
   sta playerCollisions,x     ; 4
   sta WSYNC
;--------------------------------------
   SLEEP_3                    ; 3
   lda player0Graphic         ; 3
   sta GRP0                   ; 3 = @09
   lda (playerMissilePointer),y; 5
   sta ENAM0                  ; 3 = @17
   SLEEP_8                    ; 8
   cpy player0Scanline        ; 3 = @28
   bcc .waste15Cycles         ; 2³
   cpy playerUpperBoundary    ; 3
   bcs .waste10Cycles         ; 2³
   lda (playerGraphicPointer),y; 5
   sta player0Graphic         ; 3
.drawMazeData
   iny                        ; 2 = @45
   tya                        ; 2
   lsr                        ; 2
   clc                        ; 2
   adc mazeOffset             ; 3
   tax                        ; 2
   lda MazePF2Data,x          ; 4
   sta PF2                    ; 3 = @63
   lda MazePF1Data,x          ; 4
   sta PF1                    ; 3 = @70
   lda MazePF0Data,x          ; 4
;--------------------------------------
   ora mazePF0Value           ; 3
   sta PF0                    ; 3 = @04
   lda robotGraphics          ; 3
   sta GRP1                   ; 3 = @10   draw Robot
   ldx robotCoarsePos         ; 3
   bmi CoarseMoveRobotOnRight ; 2³
   SLEEP_3                    ; 3
.coarseMoveRobot
   dex                        ; 2
   bpl .coarseMoveRobot       ; 2³
   sta RESP1                  ; 3
   lda (robotMissilePointer),y; 5
   sta ENAM1                  ; 3
   ldx kernelSection          ; 3
   lda robotPointers,x        ; 4
   tax                        ; 2
   lda RobotGraphics,x        ; 4
   sta robotGraphics          ; 3
   jmp NextRobotKernelSection ; 3
       
CoarseMoveRobotOnRight SUBROUTINE
   lda (robotMissilePointer),y; 5
   sta ENAM1                  ; 3 = @24
   ldx kernelSection          ; 3
   lda robotPointers,x        ; 4
   tax                        ; 2
   lda RobotGraphics,x        ; 4
   sta robotGraphics          ; 3
   ldx robotCoarsePos         ; 3 = @43
.coarseMoveRobot
   inx                        ; 2
   bmi .coarseMoveRobot       ; 2³
   sta RESP1                  ; 3
NextRobotKernelSection
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
JumpIntoGameKernel
   lda player0Graphic         ; 3
   sta GRP0                   ; 3 = @09
   lda (playerMissilePointer),y; 5
   sta ENAM0                  ; 3 = @17
   SLEEP_8                    ; 8
   cpy player0Scanline        ; 3 = @28
   bcc .waste12Cycles         ; 2³+1
   cpy playerUpperBoundary    ; 3
   bcs .waste7Cycles          ; 2³+1
   lda (playerGraphicPointer),y; 5
   sta player0Graphic         ; 3
.drawMazeData
   iny                        ; 2 = @45
   tya                        ; 2
   lsr                        ; 2
   clc                        ; 2
   adc mazeOffset             ; 3
   tax                        ; 2
   lda MazePF2Data,x          ; 4
   sta PF2                    ; 3 = @63
   lda MazePF1Data,x          ; 4
   sta PF1                    ; 3 = @70
   lda MazePF0Data,X          ; 4
;--------------------------------------
   ora mazePF0Value           ; 3
   sta PF0                    ; 3 = @04
   lda robotGraphics          ; 3
   sta GRP1                   ; 3 = @10
   lda (robotMissilePointer),y; 5
   sta ENAM1                  ; 3 = @18
   ldx kernelSection          ; 3
   tya                        ; 2
   cmp robotVertPos,x         ; 4
   bne DoneRobotKernelSection ; 2³
   lda robotFineHoriz,x       ; 4
   sta HMP1                   ; 3 = @36
   lda robotCoarseHoriz,x     ; 4
   sta robotCoarsePos         ; 3
   lda #0                     ; 2
   sta robotGraphics          ; 3
   jmp ReadCollisionsForSection; 3
       
DoneRobotKernelSection
   bcc .skipRobotDraw         ; 2³
   sec                        ; 2         not needed -- carry already set
   sbc #MAX_ROBOTS+1          ; 2
   bmi .drawNextRobotLine     ; 2³
   cmp robotVertPos,x         ; 4
   bcc .drawNextRobotLine     ; 2³
   inc kernelSection          ; 5
.drawNextRobotLine
   inc robotPointers,x        ; 6         increment robot pointer offset
   lda robotPointers,x        ; 4         to draw next robot line
   tax                        ; 2
   lda RobotGraphics,x        ; 4
.setRobotGraphics
   sta robotGraphics          ; 3
   sta WSYNC
;--------------------------------------
   jmp JumpIntoGameKernel     ; 3
       
.skipRobotDraw
   cpy #(H_KERNEL / 2) - 1    ; 2
   bcs LastKernelSection      ; 2³+1
   lda #0                     ; 2
   jmp .setRobotGraphics      ; 3         could use unconditional branch
       
.waste12Cycles
   SLEEP_8                    ; 8
   jmp .drawMazeData          ; 3
       
.waste7Cycles
   SLEEP_3                    ; 3
   jmp .drawMazeData          ; 3
       
LastKernelSection
   sta WSYNC
;--------------------------------------
   lda player0Graphic         ; 3
   sta GRP0                   ; 3 = @06
   lda (playerMissilePointer),y;5
   sta ENAM0                  ; 3 = @14
   cpy playerUpperBoundary    ; 3
   bcs .skipPlayerGraphicSet  ; 2³
   lda (playerGraphicPointer),y;5
   sta player0Graphic         ; 3
.skipPlayerGraphicSet
   sta WSYNC
;--------------------------------------
   lda #%11100000             ; 2
   sta PF0                    ; 3 = @05
   lda #%11111111             ; 2
   sta PF1                    ; 3 = @10
   lda #%00000111             ; 2
   ldx playerStartingLocation ; 3
   cpx #PLAYER_ENTERING_SOUTH ; 2
   bne .setPF2ForNextScanline ; 2³
   lda #%11111111             ; 2
.setPF2ForNextScanline
   sta PF2                    ; 3 = @24
   sta WSYNC
;--------------------------------------
   lda player0Graphic         ; 3
   sta GRP0                   ; 3 = @06
   lda #0                     ; 2
   sta GRP1                   ; 3 = @11
   sta WSYNC
;--------------------------------------
   sta GRP1                   ; 3 = @03
   sta GRP0                   ; 3 = @06
   sta WSYNC
;--------------------------------------
   lda CXP1FB                 ; 3         read player1/PF collision
   ora CXM0P                  ; 3         or player0 missile collisions
   ora CXPPMM                 ; 3         or player/player and 
   and #%10000000             ; 2         mask ball, M0/M0, M0/P0 collisions
   bit CXM1P                  ; 3
   bvc .setCollisions         ; 2³
   ora #1                     ; 2         show a robot shot this robot
.setCollisions
   ldx kernelSection          ; 3
   sta playerCollisions,x     ; 4
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05   clear the playfield graphics
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   sta REFP0                  ; 3 = @14
   sta HMP1                   ; 3 = @17
   lda #THREE_COPIES          ; 2
   sta NUSIZ0                 ; 3 = @22
   sta NUSIZ1                 ; 3 = @25
   lda #YELLOW+12             ; 2
   eor colorEOR               ; 3
   sta COLUP0                 ; 3 = @33
   sta COLUP1                 ; 3 = @36
   lda #VERTICAL_DELAY        ; 2
   sta VDELP0                 ; 3 = @41
   sta VDELP1                 ; 3 = @44
   ldx #6                     ; 2
   sta WSYNC
;--------------------------------------
.wait34Cycles
   dex                        ; 2
   bpl .wait34Cycles          ; 2³
   nop                        ; 2
   sta RESP0                  ; 3 = @39
   sta RESP1                  ; 3 = @42   player 1 @ pixel 126
   lda #HMOVE_R1              ; 2
   sta HMP0                   ; 3 = @47   player 0 @ pixel 118
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   lda #H_FONT-1              ; 2
   sta loopCount              ; 3
.drawLoop
   ldy loopCount              ; 3
   lda (digitPointer),y       ; 5
   sta GRP0                   ; 3 = @72
   sta WSYNC
;--------------------------------------
   lda (digitPointer+2),y     ; 5
   sta GRP1                   ; 3 = @08
   lda (digitPointer+4),y     ; 5
   sta GRP0                   ; 3 = @16
   lda (digitPointer+6),y     ; 5
   sta tempCharHolder         ; 3
   lda (digitPointer+8),y     ; 5
   tax                        ; 2
   lda (digitPointer+10),y    ; 5
   tay                        ; 2
   lda tempCharHolder         ; 3
   sta GRP1                   ; 3 = @44
   stx GRP0                   ; 3 = @47
   sty GRP1                   ; 3 = @50
   sta GRP0                   ; 3 = @53
   dec loopCount              ; 5
   bpl .drawLoop              ; 2³
   lda #0                     ; 2
   sta GRP0                   ; 3 = @65
   sta GRP1                   ; 3 = @68
   sta GRP0                   ; 3 = @71
   sta NUSIZ0                 ; 3 = @74
;--------------------------------------
   sta NUSIZ1                 ; 3 = @01
   
   IF COMPILE_VERSION = NTSC
   
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      sta WSYNC
      
   ELSE
   
      ldx #20
.skip21Scanlines
      sta WSYNC
      dex
      bpl .skip21Scanlines
      
   ENDIF
   
   lda #3
   sta VBLANK                       ; disable TIA (D1 = 1)
   lda #OVERSCAN_TIME
   sta TIM64T                       ; set timer for overscan wait
   lda gameState                    ; get the current game state
   bpl .skipPlayerExitingRoom       ; branch if not exiting room
   jmp SetupForPlayerExitingRoom
       
.skipPlayerExitingRoom
   ldx #START_GAME_RAM              ; set x to point to start of game RAM
   lda numberOfLives                ; get number of lives remaining
   bpl ReadConsoleSwitches          ; if positive skip joystick quick start
   lda INPT4                        ; read joystick button for quick start
   bpl .resetGame                   ; button pressed so reset game
ReadConsoleSwitches
   lda SWCHB                        ; read console switches
   and #RESET_MASK                  ; mask values to get RESET value
   bne .skipGameReset               ; branch if RESET not pressed
.resetGame
   ldy frameCount                   ; get frame count for random seed MSB
   lda #0
   jmp ClearRAM                     ; clear game RAM (remember x set to start
                                    ; of game RAM)       
.skipGameReset
   lda gameSelection                ; get current game selection
   bne .checkSelectSwitchDown
   inc gameSelection                ; increment game selection so value = 1
.checkSelectSwitchDown
   lda SWCHB                        ; read console switches
   and #SELECT_MASK                 ; mask the SELECT value
   bne .setSelectDebounce
   sta AUDV0                        ; turn off game sounds player is
   sta AUDV1                        ; selecting a game (a = 0)
   lda selectDebounce               ; get select debounce flag
   bne .reduceSelectDebounce
   lda gameSelection                ; get the current game selection
   cmp #MAX_GAME_SELECTION
   bcc IncrementGameSelection
   lda #0
IncrementGameSelection
   clc
   sed                              ; set to decimal mode
   adc #1                           ; increase game number by 1
   cld                              ; clear decimal mode
SetGameSelection
   sta gameSelection                ; get current game selection
   sta playerScore+1                ; place in player score to display
   lda #$AA
   sta playerScore                  ; set these values to point to the Blank
   sta playerScore+2                ; character
   sta numberOfLives                ; set number of lives so joystick quick
                                    ; start is available
   sta initRobotDelay
   lda #SELECT_DELAY
.setSelectDebounce
   sta selectDebounce
.reduceSelectDebounce
   dec selectDebounce
   lda numberOfLives
   bpl .skipAttractModeColorCycling ; branch if not selecting a game
   lda frameCount                   ; get the current frame count
   bne ColorForAttractMode
   inc colorEOR                     ; updated every 255 frames
ColorForAttractMode
   ldx #3
.attractModeLoop
   lda AttractModeColors,x
   eor colorEOR
   and #COLOR_LIGHT_LUM
   sta COLUP0,x
   dex
   bpl .attractModeLoop
   jmp DetermineEvilOttoParameters
       
.skipAttractModeColorCycling
   lda initRobotDelay               ; get starting robot delay
   cmp #$FF
   beq DetermineToTurnOffMissiles
   sec                              ; set carry
   ror initRobotDelay               ; shift bits right and move carry into D7
   jmp DetermineEvilOttoParameters
       
DetermineToTurnOffMissiles
   ldx #0
   ldy #3
   lda robotMissileHorizPos         ; get robot's missile horizontal position
.checkRobotMissileXLimit
   cmp MissileVerticalLimitsTable,y ; see if the missile is out of range
   beq TurnOffRobotMissile          ; turn off missile if out of range
   dey
   bpl .checkRobotMissileXLimit
   lda robotMissileVertPos          ; get the missile's vertical position
   beq TurnOffRobotMissile          ; turn off missile if reached upper limit
   cmp #(H_KERNEL - 8) / 2
   beq TurnOffRobotMissile          ; turn off missile if reached lower limit
   bit CXPPMM
   bvs TurnOffRobotMissile          ; branch if missiles collided
   bit CXM1P
   bvs TurnOffRobotMissile          ; branch if robot missile hit robot
   bmi TurnOffRobotMissile          ; branch if robot missile hit player
   bit CXM1FB
   bpl CheckToTurnOffPlayerMissile  ; branch if robot missile did not hit PF
TurnOffRobotMissile
   lda robotMissileDirection        ; get the robot's missile direction
   cmp #%00001111
   beq .resetRobotMissileLSB        ; branch if no direction (not moving)
   stx robotMissileDirection        ; set robot missile direction to 0
.resetRobotMissileLSB
   stx robotMissilePointer
   stx AUDV1                        ; turn off sound channel 1
   lda #>MazePF0Data
   sta robotMissilePointer+1        ; set MSB for robot missile pointer
CheckToTurnOffPlayerMissile
   ldy #3
   lda playerMissileHorizPos        ; get player's missile horizontal position
.checkPlayerMissileXLimit
   cmp MissileVerticalLimitsTable,y ; see if the missile is out of range
   beq TurnOffPlayerMissile
   dey
   bpl .checkPlayerMissileXLimit
   lda playerMissileVertPos         ; get player's missile vertical position
   beq TurnOffPlayerMissile         ; turn off missile if reached upper limit
   cmp #(H_KERNEL - 8) / 2
   beq TurnOffPlayerMissile         ; turn off missile if reached lower limit
   bit CXPPMM
   bvs TurnOffPlayerMissile         ; branch if missiles collided
   bit CXM0P
   bvs TurnOffPlayerMissile         ; branch if player missile hit Otto
   bmi TurnOffPlayerMissile         ; branch if player missile hit robot
   bit CXM0FB
   bvs TurnOffPlayerMissile         ; branch if player missile hit BALL???
   bpl DeterminePlayerSpriteAnimation; branch if player missile didn't hit PF
TurnOffPlayerMissile
   stx AUDV0
   stx playerMissileFlightTime
   stx playerMissilePointer
   lda #>MazePF0Data
   sta playerMissilePointer+1       ; set MSB for player missile pointer
   bit CXM0P
   bvc DeterminePlayerSpriteAnimation; branch if player missile didn't hit Otto
   lda gameVariation                ; get the game variation
   and #OTTO_REBOUND
   beq DeterminePlayerSpriteAnimation
   lda #2
   sta evilOttoLaunchTimer          ; set Otto to launch in ~4 seconds
   sta CXCLR                        ; clear all collisions
DeterminePlayerSpriteAnimation
   lda playerAnimationIndex         ; get player animation index
   cmp #PLAYER_DEATH_ANIM_OFFSET
   bcc CheckPlayerOttoCollision
   bpl DetermineDeathAnimationSprite
   ldy #3
   dec numberOfLives
   jmp IncrementGameLevel
       
DetermineDeathAnimationSprite
   inc playerAnimationIndex         ; increment animation index
   ldx #<PlayerStationary-PlayerSprites
   and #2
   beq .setDeathAudioFrequency
   ldx #<PlayerDeath-PlayerSprites  ; pointer to death animation sprite
   lda #1
.setDeathAudioFrequency
   sta AUDF0
   stx playerGraphicLSB
   lda #14
   sta AUDV0
   jmp DeterminePlayerMissileActive
       
CheckPlayerOttoCollision
   lda evilOttoLaunchTimer          ; get Otto launch timer
   cmp #3                           ; don't check Otto's movement if not
   bcc CheckPlayerHarmfulCollisions ; time to launch
   lda frameCount                   ; get current frame count
   ror                              ; rotate D0 into carry
   bcs ReadJoystickValues           ; branch if on an odd frame count
   lda evilOttoHorizPos             ; get Evil Otto's horizontal position
   clc                              ; no need -- carry cleared above
   adc #7
   cmp playerHorizPos               ; compare with player horizontal position
   bcc CheckPlayerHarmfulCollisions
   lda playerHorizPos               ; get player's horizontal position
   clc
   adc #7                           ; could add 6 to save a byte (carry set)
   cmp evilOttoHorizPos             ; compare with Otto's horizontal position
   bcc CheckPlayerHarmfulCollisions
   lda evilOttoVertPos              ; get Otto's vertical position
   clc
   adc #H_PLAYER-1                  ; could add 10 to save a byte (carry set)
   cmp playerVertPos                ; compare with player vertical position
   bcc CheckPlayerHarmfulCollisions
   lda playerVertPos                ; get player's vertical position
   clc
   adc #H_PLAYER+8                  ; could add 19 to save a byte (carry set)
   cmp evilOttoVertPos              ; compare with Otto's vertical position
   bcs .playerHarmfulCollision
CheckPlayerHarmfulCollisions
   bit CXM1P
   bmi .playerHarmfulCollision      ; branch if robot missile hit player
   bit CXPPMM
   bmi .playerHarmfulCollision      ; branch if players collided
   bit CXP0FB
   bpl ReadJoystickValues           ; branch if player didn't hit PF
.playerHarmfulCollision
   lda #PLAYER_DEATH_ANIM_OFFSET
   sta playerAnimationIndex
   lda #8
   sta AUDC0
   sta audioIndex
   jmp DetermineDeathAnimationSprite
       
ReadJoystickValues
   lda #0
   sta temp02
   lda #127
   sta randomNumberMax              ; set random number ceiling
   lda SWCHA                        ; read the joystick values
   lsr                              ; shift player1's values to lower nybbles
   lsr
   lsr
   lsr
   eor #$0F                         ; flip the bits so high bit shows movement
   and #$0F                         ; mask the upper nybbles
   bne .setPlayerDirection
   lda #PLAYER_STAND_ANIM_OFFSET
   sta playerAnimationIndex
   sta playerGraphicLSB
   sta playerMotion                 ; reset player fractional movement delay
   lda frameCount                   ; get current frame count
   bne CheckForFireButtonPressed    ; branch if not rolled over from 255
   inc attractModeTimer             ; increment attract mode timer
   bne CheckForFireButtonPressed    ; branch if not rolled over from 255
   lda gameSelection                ; get current game selection
   jmp SetGameSelection             ; make game go into attract mode
       
.setPlayerDirection
   sta playerDirection              ; save as player direction
CheckForFireButtonPressed
   ldx playerAnimationIndex
   lda PlayerHorizAnimationTable,x
   sta playerGraphicLSB
   lda INPT4                        ; read the joystick fire button
   bmi DeterminePlayerMissileActive ; branch if fire button not pressed
   lda #0
   sta playerMotion                 ; reset player fractional movement delay
   lda playerDirection              ; get the player's direction
   and #MOVE_DOWN | MOVE_UP         ; mask to get up/down value
   tax                              ; move to x for table lookup
   lda PlayerShootingAnimationTable,x
   sta playerGraphicLSB
   lda playerMissileFlightTime
   bne DeterminePlayerMissileActive
   jsr NextRandom
   inc playerMissileFlightTime
   ldx playerDirection              ; get the player's direction
   stx playerMissileDirection       ; save it in the missile direction
   lda playerHorizPos               ; get the player's horizontal position
   clc
   adc InitMissileXOffsetTable,x
   sta playerMissileHorizPos        ; set player's missile horizontal position
   lda playerVertPos                ; get player's vertical position
   lsr                              ; divide by 2 for 2LK
   clc
   adc InitMissileYOffsetTable,x
   sta playerMissileVertPos
   lda #10
   sta AUDC0
   lda #$FF
   sta audioIndex
DeterminePlayerMissileActive
   lda playerMissileFlightTime      ; get player missile flight time
   beq DetermineToMovePlayer        ; branch if time out
   ldx playerMissileDirection       ; get direction missile is moving
   lda playerMissileVertPos
   clc
   adc VerticalPixelOffsets,x
   sta playerMissileVertPos
   lda #<MazePF0Data+90
   sec
   sbc playerMissileVertPos
   sta playerMissilePointer
   lda #>MazePF0Data
   sta playerMissilePointer+1
   lda audioIndex
   bpl DeterminePlayerMissilePointer
   lsr
   sta AUDV0
   and #$0F
   beq .skipAudioIndexDecrement
   dec audioIndex
.skipAudioIndexDecrement
   eor #$0F
   sta AUDF0
DeterminePlayerMissilePointer
   lda #ONE_COPY
   sta NUSIZ0
   lda HorizontalPixelOffsets,x
   beq .calculatePlayerMissileOffset
   asl                              ; multiply the value by 2
   clc
   adc playerMissileHorizPos
   sta playerMissileHorizPos
   ldx #MSBL_SIZE4
   stx NUSIZ0
   lda #(H_KERNEL / 2)
.calculatePlayerMissileOffset
   clc
   adc playerMissilePointer
   sta playerMissilePointer
DetermineToMovePlayer
   lda playerAnimationIndex
   cmp #PLAYER_DEATH_ANIM_OFFSET
   bcs DetermineEvilOttoParameters
   lda playerMotion                 ; get the player's fractional delay
   clc
   adc #PLAYER_FRACTIONAL_DELAY     ; add in the fractional delay value
   sta playerMotion                 ; set player's fractional delay
   bcc DetermineEvilOttoParameters  ; skip player movement if no roll over
   dec playerAnimationIndex         ; reduce player animation index
   bpl SetPlayerPositions           ; branch if the value didn't roll over
   lda #PLAYER_RUN_ANIM_OFFSET+1
   sta playerAnimationIndex         ; reset animation index for roll over
SetPlayerPositions
   ldx playerDirection              ; get the player's directions
   lda playerVertPos                ; get player's vertical position
   clc
   adc VerticalPixelOffsets,x       ; add vertical pixel values to move
   sta playerVertPos                ; player up or down
   lda playerHorizPos               ; get player's horizontal position
   clc
   adc HorizontalPixelOffsets,x     ; add horizontal pixel value to move
   sta playerHorizPos               ; player left or right
   ldy #PLAYER_ENTERING_WEST        ; assume player is exiting left
   lda playerHorizPos               ; get player's horizontal position
   beq .playerExitingScreen
   iny                              ; check for exiting right (y = 3)
   cmp #XMAX_PLAYER
   bcs .playerExitingScreen
   ldy #PLAYER_ENTERING_NORTH       ; assume player is exiting up
   lda playerVertPos                ; get player's vertical position
   cmp #YMIN + 2
   bcc .playerExitingScreen
   iny                              ; check for exiting down (y = 1)
   cmp #(H_KERNEL - H_PLAYER*2)
   bne DetermineEvilOttoParameters
.playerExitingScreen
   jmp IncrementGameLevel

DetermineEvilOttoParameters
   lda playerDirection
   asl                              ; move right value in D4
   sta REFP0                        ; set player REFLECT state
   lda playerVertPos
   jsr CalculateP0GraphicPointers
   lda #>PlayerSprites
   sta playerGraphicPointer+1
   lda playerMissileHorizPos
   jsr DetermineDiv15Position
   ldx #2
   jsr MoveObjectHorizontally       ; move player's missile
   lda frameCount                   ; get the current frame count
   ror                              ; move D0 to carry
   bcs .calcPlayerXPos              ; branch if on an odd frame
   lda robotVertPos+MAX_ROBOTS-2
   cmp #$7F
   bne .calcPlayerXPos
   lda gameVariation                ; get the game variation
   and #OTTO_INVINCIBLE|OTTO_REBOUND
   beq .calcPlayerXPos
   ldx evilOttoLaunchTimer          ; get Otto launch timer
   cpx #3                           ; branch to move Otto if time to launch
   bcs DetermineEvilOttoMovement
   lda frameCount                   ; get the current frame count
   bne .calcPlayerXPos
   inc evilOttoLaunchTimer          ; increment when frame count rolls to 256
   lda #1                           ; set to increment Otto's vertical
   sta ottoVerticalDelta            ; position by 1
   ldy playerStartingLocation       ; get the player's starting location
   lda InitVerticalPosition,y       ; read initial vertical position
   sta evilOttoVertPos              ; set it to Otto's vertical position
   sta prevEvilOttoVertPos
   adc #16
   sta tempOttoVertPos
   lda InitHorizontalPosition,y     ; read initial horizontal position
   sta evilOttoHorizPos             ; set it to Otto's horizontal position
.calcPlayerXPos
   jmp CalcPlayerXPos

DetermineEvilOttoMovement
   lda robotVertPos                 ; get the last robot's vertical postion
   cmp #$7F                         ; if not on the screen move Otto faster
   beq .moveEvilOtto
   lda robotMotionDelay             ; get the robot delay value
   asl                              ; multiply by 2 so Otto moves twice as fast
   adc robotMotion
   bcc .setFullEvilOttoSprite
.moveEvilOtto
   lda ottoVerticalDelta
   clc
   adc evilOttoVertPos              ; change Otto's vertical position
   sta evilOttoVertPos
   cmp prevEvilOttoVertPos          ; compare with Otto's previous position
   bcs .determineToBounceOttoUp     ; branch if greater than previous position
   ldx #3                           ; increment Otto's vertical position by 3
.setOttoVerticalDelta
   stx ottoVerticalDelta
   lda prevEvilOttoVertPos          ; get Otto's previous vertical position
   cmp playerVertPos                ; compare with player's vertical position
   bcs .moveOttoUp                  ; branch if Otto is below player
   inc prevEvilOttoVertPos          ; increment Otto's previous position
   inc prevEvilOttoVertPos
   inc prevEvilOttoVertPos          ; do it two more times so fall through
   inc prevEvilOttoVertPos          ; doesn't affect value
.moveOttoUp
   dec prevEvilOttoVertPos
   dec prevEvilOttoVertPos
   lda prevEvilOttoVertPos          ; get Otto's previous vertical position
   clc
   adc #20
   cmp #H_KERNEL - [(H_PLAYER - 1) * 2] + 1
   bcc .setTempOttoVertPos
   lda #H_KERNEL - [(H_PLAYER - 1) * 2]
.setTempOttoVertPos
   sta tempOttoVertPos
DetermineOttoPosition
   ldx ottoVerticalDelta            ; get Otto's vertical delta value
   bmi DetermineOttoHorizPosition   ; branch if we will be moving Otto down
   lda prevEvilOttoVertPos          ; get Otto's previous vertical position
   adc #5
   cmp evilOttoVertPos
   bcs DetermineOttoHorizPosition
   lda tempOttoVertPos
   sta evilOttoVertPos
   lda #<EvilOttoSprite_1 - EvilOttoSprites + 2
   jmp .setEvilOttoGraphicLSB       ; could use unconditional branch

DetermineOttoHorizPosition
   lda evilOttoHorizPos             ; get Otto's horizontal position
   cmp playerHorizPos               ; compare with player's horiz position
   beq .setFullEvilOttoSprite
   bcs .moveOttoLeft                ; if greater move Otto lwft
   inc evilOttoHorizPos             ; move Otto right
   inc evilOttoHorizPos             ; again so fall through won't change value
.moveOttoLeft
   dec evilOttoHorizPos             ; move Otto left
.setFullEvilOttoSprite
   lda #<EvilOttoSprite_0 - EvilOttoSprites + 1
.setEvilOttoGraphicLSB
   sta playerGraphicLSB
   lda evilOttoVertPos
   jsr CalculateP0GraphicPointers
   lda #>EvilOttoSprites
   sta playerGraphicPointer+1
   lda evilOttoHorizPos
   jmp CalcOttoXPos
       
.determineToBounceOttoUp
   cmp tempOttoVertPos
   bcc DetermineOttoPosition
   ldx #-4                          ; set Otto vertical delta to move up
   jmp .setOttoVerticalDelta        ; 4 pixels
       
CalcPlayerXPos
   lda playerHorizPos               ; get the player's horizontal position
CalcOttoXPos
   jsr DetermineDiv15Position
   ldx #0
   jsr MoveObjectHorizontally       ; move player horizontally
VerticalSync SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   lda #%00000011
   sta WSYNC                        ; wait for next scan line
   sta VBLANK                       ; diable TIA (D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta WSYNC
   inc frameCount
   sta WSYNC
   ldy #VBLANK_TIME
   sty WSYNC
   sty TIM64T                       ; set timer for VBLANK time
   ldy #0
   sty VSYNC                        ; end veritcal sync (D1 = 0)
   lda playerScore
   ora playerScore+1
   ora playerScore+2
   beq .skipBCDToDigits
   ldx #10
   lda #<Blank
.blankScoreGraphicsLoop
   sta digitPointer,x
   dex
   dex
   bpl .blankScoreGraphicsLoop
   lda gameState                    ; get the current game state
   bpl CheckToShowLevelBonus
   ldx #10
   ldy numberOfLives
.livesPointerLoop
   dey
   bmi .jumpToLivesKernel
   lda #<LivesIndicator
   sta digitPointer,x
   dex
   dex
   bpl .livesPointerLoop
.jumpToLivesKernel
   jmp DisplayLivesKernel

CheckToShowLevelBonus
   lda numberOfLives                ; get the number of lives remaining
   bmi BCDToDigits                  ; if negative -- game over
   lda robotVertPos                 ; get the robot's vertical position
   cmp #$7F
   bne BCDToDigits                  ; branch if not all robots shot
   lda #<zero
   sta digitPointer+2               ; point to zero sprite
   ldx numberRobotsKilled           ; get number of robots killed this round
   lda NumberTable,x                ; load the number pointer
   sta digitPointer
   jmp .skipBCDToDigits
       
BCDToDigits
   ldy #2
   lda #10
   sta lsbDigitPointer
.bcdToDigitsLoop
   lda playerScore,y                ; get the player's score
   and #$0F                         ; mask the upper nybbles and move it to x
   tax                              ; to read number table
   lda NumberTable,x                ; get the LSB for the number to show
   ldx lsbDigitPointer
   sta digitPointer,x               ; store it in the graphics pointer
   dec lsbDigitPointer              ; decrement twice to only update LSBs
   dec lsbDigitPointer
   lda playerScore,y                ; get the player's score
   lsr                              ; move upper nybble to lower nybble
   lsr
   lsr
   lsr
   tax                              ; move it to x to read number table
   lda NumberTable,x                ; get the LSB for the number to show
   ldx lsbDigitPointer
   sta digitPointer,x               ; store it in the graphics pointer
   dec lsbDigitPointer
   dey
   dec lsbDigitPointer
   bpl .bcdToDigitsLoop
   ldx #0
.suppressZeroLoop
   lda digitPointer,x               ; cycle through the digit pointers to
   cmp #<zero                       ; find one that points to zero (starting
   bne .skipBCDToDigits             ; from the 1st pointer)
   lda #<Blank                      ; if one is found then set the LSB to
   sta digitPointer,x               ; point to the space
   inx
   inx
   cpx #10
   bcc .suppressZeroLoop
.skipBCDToDigits
   lda gameState                    ; get the current game state
   bmi .jumpToLivesKernel
   jsr NextRandom                   ; re-seed random number
   ldx #0                           ; set to assume robot not to be animated
   clc
   lda robotMotion                  ; get the robot motion value
   adc robotMotionDelay
   sta robotMotion
   bcc .setRobotAnimationDelayValue
   ldx #1                           ; set to show robot is to be animated
.setRobotAnimationDelayValue
   stx delayRobotAnimation
   ldx #0
   stx temp01
.robotMovementLoop
   lda robotVertPos,x               ; get robot's vertical position
   cmp #$7F                         ; see if robot is on the screen
   beq .jmpToNextRobotMovement      ; branch if not on the screen
   ldy robotAnimationIndex,x        ; get the robot's animation index
   cpy #ROBOT_DEATH_ANIM_OFFSET     ; see if the robot is dieing
   bcc .skipRobotDieingCheck        ; branch if robot not dieing
   jmp CheckForRobotDieing
       
.skipRobotDieingCheck
   jsr DetermineTimeToMoveRobot
   bcs .jmpToNextRobotMovement
   lda delayRobotAnimation          ; get the delay flag for robot animation
   beq .jmpToNextRobotMovement      ; branch if robot not to be animated
   cpy #ROBOT_LEFT_ANIM_OFFSET-1
   bcs .doRobotHorizMovement
.setRobotAnimIndexFromTable
   lda RobotAnimationTable,y
   sta robotAnimationIndex,x
   jmp .nextRobotMovement
       
.setAnimationIndexToStand
   ldy #ROBOT_STAND_ANIM_OFFSET
   jmp .setRobotAnimIndexFromTable  ; could use unconditional branch
       
.doRobotHorizMovement
   cpy #ROBOT_STAND_ANIM_OFFSET+8
   bne CheckRobotHorizontalMovement
   lda initRobotDelay
   cmp #$FF
   bne .setRobotAnimIndexFromTable
   jsr DetermineRobotToMove
   cpx compRobotToMove
   bne .setAnimationIndexToStand
   lda random+1
   bpl DetermineRobotMovement
   ldy #ROBOT_DOWN_ANIM_OFFSET      ; assume robot is to move down
   lda playerVertPos                ; get the player's vertical position
   lsr                              ; divide by 2 for 2LK
   cmp robotVertPos,x               ; compare with robot's vertical position
   beq .setAnimationIndexToStand
   bcs .jmpToSetRobotAnimationIndex
   ldy #ROBOT_UP_ANIM_OFFSET+1
.jmpToSetRobotAnimationIndex
   jmp .setRobotAnimationIndex

DetermineRobotMovement
   ldy #ROBOT_RIGHT_ANIM_OFFSET
   lda robotHorizPos,x              ; get robot's horizontal position
   cmp playerHorizPos               ; compare with player's horiz position
   beq .setAnimationIndexToStand
   bcc .setRobotAnimationIndex      ; set robot animation to walk right
   ldy #ROBOT_LEFT_ANIM_OFFSET      ; set animation sprite to walk left
.setRobotAnimationIndex
   sty robotAnimationIndex,x        ; set robot animation index
.jmpToNextRobotMovement
   jmp .nextRobotMovement

CheckRobotHorizontalMovement
   cpy #ROBOT_RIGHT_ANIM_OFFSET
   bcs .checkToMoveRobotRight
   lda robotHorizPos,x              ; get robot's horizontal position
   cmp playerHorizPos               ; compare with player's horiz position
   bcc .setAnimationIndexToStand
   beq .setAnimationIndexToStand
   dec robotHorizPos,x              ; move robot to the left
   jmp .setRobotAnimIndexFromTable
       
.checkToMoveRobotRight
   cpy #ROBOT_UP_ANIM_OFFSET
   bcs CheckRobotVerticalMovement
   lda robotHorizPos,x              ; get robot's horizontal position
   cmp playerHorizPos               ; compare with player's horiz position
   bcs .setAnimationIndexToStand
   inc robotHorizPos,x              ; move robot to the right
   jmp .setRobotAnimIndexFromTable
       
CheckRobotVerticalMovement
   cpy #ROBOT_DOWN_ANIM_OFFSET
   bcs .checkToMoveRobotDown
   lda playerVertPos                ; get the player's vertical position
   lsr                              ; divide by 2 for 2LK
   adc #3                           ; add 3 to the value and
   cmp robotVertPos,x               ; compare to robot's vertical position
   beq .setAnimationIndexToStand
   bcs DetermineRobotMovement
   cpy #ROBOT_UP_ANIM_OFFSET
   beq .setAnimIndexFromTable
   cpy #ROBOT_UP_ANIM_OFFSET+2
   beq .setAnimIndexFromTable
   txa
   beq .moveRobotUp
   lda robotVertPos-1,x
   clc
   adc #H_ROBOT+1
   cmp robotVertPos,x
   bcs DetermineRobotMovement
.moveRobotUp
   dec robotVertPos,x
.setAnimIndexFromTable
   jmp .setRobotAnimIndexFromTable

.checkToMoveRobotDown
   lda playerVertPos                ; get the player's vertical position
   lsr                              ; divide by 2 for 2LK
   cmp robotVertPos,x               ; compare with robot's vertical position
   beq DetermineRobotMovement
   bcc DetermineRobotMovement
   cpy #ROBOT_DOWN_ANIM_OFFSET
   beq .skipRobotMovingDown
   cpy #ROBOT_DOWN_ANIM_OFFSET+2
   beq .skipRobotMovingDown
   lda robotVertPos+1               ; get the next robot's vertical position
   cmp #$7F                         ; see if robot is on the screen
   beq .moveRobotDown               ; branch if not on the screen
   lda robotVertPos,x               ; get the robot's vertical position
   clc
   adc #H_ROBOT+2                   ; add the robot height plus pad of 2
   cmp robotVertPos+1,x             ; compare with next robot's position
   bcs DetermineRobotMovement
.moveRobotDown
   inc robotVertPos,x
.skipRobotMovingDown
   jmp .setRobotAnimIndexFromTable

CheckForRobotDieing
   lda playerCollisions+1,x
   beq .incrementRobotAnimation
   inc temp01
.incrementRobotAnimation
   inc robotAnimationIndex,x
   lda robotAnimationIndex,x
   cmp #ROBOT_DEATH_ANIM_OFFSET+4
   bcc .nextRobotMovement
   jsr SortRobotVariables
   lda #SHOOTING_ROBOT_SCORE
   jsr IncrementScore
   inc numberRobotsKilled
   jmp .robotMovementLoop
       
.nextRobotMovement
   inx
   cpx #MAX_ROBOTS
   beq .doneRobotMovementLoop
   jmp .robotMovementLoop

   IF COMPILE_VERSION = NTSC
   
.doneRobotMovementLoop
   lda robotVertPos+MAX_ROBOTS-1
   cmp #$7F
   bne .jmpCalcRobotMissileXPos
   lda initRobotDelay
   
   ELSE
   
.doneRobotMovementLoop
   lda initRobotDelay
   
   ENDIF
   
   cmp #$FF
   beq DetermineToFireRobotMissile
.jmpCalcRobotMissileXPos
   jmp CalcRobotMissileXPos

DetermineToFireRobotMissile
   lda gameLevel                    ; get current game level
   lsr                              ; divide value by 2
   beq .jmpCalcRobotMissileXPos     ; don't fire missiles if first game board
   lda robotMissileDirection        ; get current robot missile direction
   cmp #%00001111
   bne .checkForRobotShootingGame
   inc robotMissileFlightTime
   bpl .jmpCalcRobotMissileXPos
   lda #%00000000
   sta robotMissileDirection        ; clear robot missile direction
.checkForRobotShootingGame
   lda gameVariation                ; get the game variation
   ror                              ; move ROBOT_SHOOTING to carry
   bcc .jmpCalcRobotMissileXPos     ; branch if robot's not shooting
   lda robotMissileDirection        ; get robot missile direction
   beq .determineToLaunchNewMissile
   jmp .determineRobotMissileSize

.determineToLaunchNewMissile
   lda delayRobotAnimation          ; get flag to animate robot this frame
   bne .jmpCalcRobotMissileXPos     ; branch if robot to be animated
   lda #-1
   sta robotMissileDelay
   lda frameCount                   ; get current frame count
   and #7                           ; make value 0 <= a <= 7
   tax
   lda robotVertPos,x               ; get robot's vertical position
   cmp #$7F                         ; see if robot is on the screen
   beq .jmpCalcRobotMissileXPos     ; branch if robot not on the screen
   lda robotAnimationIndex,x        ; get the robot's animation index
   cmp #ROBOT_DEATH_ANIM_OFFSET     ; see if the robot is dieing
   bcs .jmpCalcRobotMissileXPos     ; branch if robot is dieing
   lda playerHorizPos               ; get the player's horizontal position
   sec
   sbc #XROBOT_MISSILE_BOX
   cmp robotHorizPos,x              ; compare with robot's horizontal position
   bcs .checkToLaunchMissileVertically
   clc                              ; not needed -- carry already clear
   adc #XROBOT_MISSILE_BOX*2
   cmp robotHorizPos,x              ; compare with robot's horizontal position
   bcc .checkToLaunchMissileVertically
   ldy #ROBOT_SHOOTING_DOWN
   lda playerVertPos                ; get the player's vertical position
   lsr                              ; divide by 2 for 2LK
   cmp robotVertPos,x               ; compare with robot's vertical position
   bcs .jmpToLaunchRobotMissile
   ldy #ROBOT_SHOOTING_UP
.jmpToLaunchRobotMissile
   jmp LaunchRobotMissile

.checkToLaunchMissileVertically
   lda playerVertPos                ; get player's vertical position
   lsr                              ; divide by 2 for 2LK
   sec
   sbc #YROBOT_MISSILE_BOX
   cmp robotVertPos,x               ; compare with robot's vertical position
   bcs .jmpCalcRobotMissileXPos
   clc                              ; not needed -- carry already clear
   adc #YROBOT_MISSILE_BOX*2
   cmp robotVertPos,x
   bcc .jmpCalcRobotMissileXPos
   ldy #ROBOT_SHOOTING_LEFT
   lda robotHorizPos,x              ; get robot's horizontal position
   cmp playerHorizPos               ; compare with player's horizontal position
   bcs LaunchRobotMissile
   ldy #ROBOT_SHOOTING_RIGHT
LaunchRobotMissile
   lda robotAnimationIndex,x
   cmp #ROBOT_LEFT_ANIM_OFFSET
   bcc .setRobotMissileInitPosition
   lda #ROBOT_STAND_ANIM_OFFSET
   sta robotAnimationIndex,x
.setRobotMissileInitPosition
   lda #-1
   sta robotMissileSoundIndex
   lda InitRobotMissileYOffset,y
   clc
   adc robotVertPos,x
   sta robotMissileVertPos
   lda InitRobotMissileXOffset,y
   clc
   adc robotHorizPos,x
   sta robotMissileHorizPos
   sty robotMissileDirection
.determineRobotMissileSize
   lda robotMissileDirection        ; get missile direction
   and #%00000011                   ; mask vertical values (keep horiz values)
   beq DetermineMoveRobotMissile    ; branch if not moving horizontally
   lda #MSBL_SIZE4
   sta NUSIZ1                       ; set robot missile size to 4 clocks
DetermineMoveRobotMissile
   lda gameLevel                    ; get current game level
   cmp #16                          ; if greater than 15 then move robot
   bcs .moveRobotMissile            ; missile every frame
   ror                              ; divide by 2 and move D0 to carry
   tax
   lda RobotMissileDelayTable,x
   adc robotMissileDelay            ; carry clear when even game level
   sta robotMissileDelay
   bcc CalcRobotMissileXPos
.moveRobotMissile
   lda robotMissileDirection        ; get missile direction
   beq CalcRobotMissileXPos         ; branch if missile not moving
   cmp #$0F
   beq CalcRobotMissileXPos         ; again...branch if missile not moving
   and #%00001100                   ; mask horiz values (keep vertical values)
   beq CalcRobotMissilePointers     ; branch if not moving vertically
   and #%00000100
   beq .moveRobotMissileUp
   inc robotMissileVertPos          ; move robot missile down
   inc robotMissileVertPos          ; increment again so fall through doesn't
                                    ; change value
.moveRobotMissileUp
   dec robotMissileVertPos
CalcRobotMissilePointers
   lda #<MazePF0Data+90
   sec
   sbc robotMissileVertPos
   sta robotMissilePointer
   lda #>MazePF0Data
   sta robotMissilePointer+1
   lda robotMissileSoundIndex
   bpl .skipRobotMissileSound
   lsr                              ; divide the value by 2
   sta AUDV1                        ; to set the volume
   and #$0F
   beq .skipReduceMissileSoundIndex
   dec robotMissileSoundIndex
.skipReduceMissileSoundIndex
   eor #$0F
   sta AUDF1
   lda #$0E
   sta AUDC1
.skipRobotMissileSound
   lda robotMissileDirection        ; get missile direction
   and #%00000011                   ; mask vertical values (keep horiz values)
   beq CalcRobotMissileXPos         ; branch if not moving horizontally
   and #%00000001
   beq .moveRobotMissileLeft
   inc robotMissileHorizPos         ; move robot missile right
   inc robotMissileHorizPos
   inc robotMissileHorizPos         ; increment 2 more times so fall through
   inc robotMissileHorizPos         ; doesnt change value
.moveRobotMissileLeft
   dec robotMissileHorizPos
   dec robotMissileHorizPos
   lda #(H_KERNEL / 2)
   clc
   adc robotMissilePointer
   sta robotMissilePointer
CalcRobotMissileXPos SUBROUTINE
   lda robotMissileHorizPos
   jsr DetermineDiv15Position
   ldx #3
   jsr MoveObjectHorizontally       ; move robot's missile
   lda robotMissileSoundIndex
   bmi SetRobotVariables
   sta AUDV1
   beq .skipReduceMissileSoundIndex
   dec robotMissileSoundIndex
.skipReduceMissileSoundIndex
   eor #$0F
   sta AUDF1
   lda #8
   sta AUDC1
SetRobotVariables
   ldx #MAX_ROBOTS-1
.setRobotGraphicPointers
   ldy robotAnimationIndex,x        ; get robot animation index
   lda RobotAnimationTableOffsets,y ; get the LSB value from table
   sta robotPointers,x              ; set robot graphic pointer
   dex
   bpl .setRobotGraphicPointers
   ldx #MAX_ROBOTS-1
.setRobotPositionValues
   lda robotVertPos,x
   cmp #$7F
   beq .nextRobot
   lda robotHorizPos,x              ; get robot's horizontal position
   jsr DetermineDiv15Position
   sta robotFineHoriz,x             ; set robot's fine horiz value
   dey                              ; reduce coarse position
   tya                              ; move coarse position to accumulator
   cmp #5                           ; if it's less than 5 set coarse value
   bcc .setRobotsCoarseHorizPos
   sbc #4                           ; subtract value by 4
   eor #$FF                         ; make negative to show robot on right
   tay                              ; move coarse value back to y
   iny                              ; increment coarse value
.setRobotsCoarseHorizPos
   sty robotCoarseHoriz,x
.nextRobot
   dex
   bpl .setRobotPositionValues
   ldy #0
   sty kernelSection                ; re-initialize kernel section
   sty temp01
   sty player0Graphic               ; clear player0 graphic buffer
   sty GRP0                         ; clear player0's graphic register
   sty ENAM1                        ; disable robot missile
   sty ENAM0                        ; disable player missile
   sty VDELP1                       ; don't VDEL the robots
   lda colorEOR
   bne DisplayKernel
   lda #RED+12
   sta COLUP0                       ; color player0
   lda initRobotDelay
   cmp #$FF
   beq DetermineRobotColor
   
   IF COMPILE_VERSION = NTSC
   
      tya                              ; a = 0
      
   ENDIF
   
   sty COLUP0                       ; set player's color to BLACK
   jmp .setRobotColor               ; could use unconditional branch
       
DetermineRobotColor
   lda gameLevel                    ; get the current game level
   lsr                              ; divide value by 2
   and #7                           ; make value 0 <= x <= 7
   tax                              ; move to x for robot color lookup
   
   IF COMPILE_VERSION = NTSC
   
      lda RobotColorTable,x            ; get the color for robots
.setRobotColor
      sta COLUP1
DisplayKernel SUBROUTINE
      lda #%11100000
      sta PF0
      lda #%11111111
      sta PF1
      lda #%00000111
      ldx playerStartingLocation       ; get the player's starting location
      bne .setMazePF2Value             ; branch if player not entering from north
      lda #%11111111
.setMazePF2Value
      sta PF2
.waitTime
      lda INTIM
      bne .waitTime
      sta WSYNC                        ; wait for next scan line
      sta HMOVE
      sta WSYNC
      sta VBLANK                       ; enable TIA (D1 = 0)
      
   ELSE
   
      ldy RobotColorTable,x            ; get the color for robots
      lda SWCHB
      and #BW_MASK
      bne .setRobotColor
      lda PALRobotBWValues,x
      ror
      tay
.setRobotColor
      sty COLUP1
DisplayKernel SUBROUTINE
.waitTime
      lda INTIM
      bne .waitTime
      sta WSYNC
      sta HMOVE
      sta VBLANK
      ldx #21
.skip22Scanlines
      sta WSYNC
      dex
      bne .skip22Scanlines
      lda #%11100000
      sta PF0
      lda #%11111111
      sta PF1
      lda #%00000111
      ldx playerStartingLocation       ; get the player's starting location
      bne .setMazePF2Value             ; branch if player not entering from north
      lda #%11111111
.setMazePF2Value
      sta PF2

   ENDIF
  
   sta WSYNC
   sta HMCLR                        ; clear all horizontal motions
   sta CXCLR                        ; clear all collisions
   ldy #2
   cpy player0Scanline
   bcc .skipPlayerGraphicSet
   lda (playerGraphicPointer),y
   sta player0Graphic
.skipPlayerGraphicSet
   iny
   sta WSYNC
   sta WSYNC
   jmp JumpIntoGameKernel
       
IncrementGameLevel
   sty tempPlayerExitingPos         ; save the player's exiting position
   inc gameLevel
   lda robotVertPos
   cmp #$7F                         ; if all robots not killed
   bne .skipLevelBonus              ; then skip level bonus
   lda numberRobotsKilled           ; get number of robots killed
   asl                              ; multiply the value by 16 to add to
   asl                              ; player's score
   asl
   asl
   jsr IncrementScore
.skipLevelBonus
   lda #$7F
   sta robotVertPos                 ; set the last robot and
   sta playerVertPos                ; player to out of range (don't show them)
   lda gameLevel                    ; get the current game level
   lsr                              ; divide the value by 2
   and #$07                         ; make the value 0 <= a <= 7
   tax
   lda RobotMotionDelayTable,x
   sta robotMotionDelay
   lda #%00001111
   sta robotMissileDirection        ; set to no missile direction
   lda #0
   sta robotMissileFlightTime
   sta frameCount                   ; reset frame count
   sta robotMissilePointer          ; turn off robot missile
   sta upperPlayfieldLimit
   sta audioIndex
   sta AUDV1                        ; turn off sound channel 1
   sta playerAnimationIndex         ; set player animation state to standing
   sta playerMissileFlightTime
   sta playerMissilePointer         ; turn off player missile
   sta evilOttoLaunchTimer          ; reset Otto launch timer
   lda #(H_KERNEL / 2)
   sta lowerPlayfieldLimit
   lda gameState                    ; get the current game state
   cmp #%00000011
   bne .setGameStateToExiting
   lda #5
   sta audioIndex
.setGameStateToExiting
   lda #$FF
   sta gameState
   jmp DetermineEvilOttoParameters
       
SetupForPlayerExitingRoom
   ldy tempPlayerExitingPos
   cpy #PLAYER_ENTERING_SOUTH
   beq .skipIncrementUpperPFLimit
   inc upperPlayfieldLimit
.skipIncrementUpperPFLimit
   cpy #PLAYER_ENTERING_NORTH
   beq .skipDecrementLowerPFLimit
   dec lowerPlayfieldLimit
.skipDecrementLowerPFLimit
   lda upperPlayfieldLimit
   cmp lowerPlayfieldLimit
   bcs SetupForNewScreen
   jmp DetermineEvilOttoParameters
       
SetupForNewScreen
   lda #%00000010
   sta gameState
   ldx #%00000000
   cpy #PLAYER_ENTERING_WEST
   bcc .setMazePF0Value
   ldx #%00100000
.setMazePF0Value
   stx mazePF0Value
   lda StartingLocationValues,y
   sta playerStartingLocation
   tay
   lda InitVerticalPosition,y
   sta playerVertPos
   lda InitHorizontalPosition,y
   sta playerHorizPos
   jsr DetermineDiv15Position
   ldx #0
   jsr MoveObjectHorizontally       ; move player horizontally
   lda random+1                     ; get high random seed
   and #%00000011                   ; make sure 0 <= a <= 3 (4 mazes)
   cmp mazeNumber
   bne .setMazeNumber
   eor #%00000010
.setMazeNumber
   sta mazeNumber
   tay
   lda MazeOffsetTable,y
   sta mazeOffset
   
   IF COMPILE_VERSION = NTSC
   
      jsr ResetRobotsForNewBoard
      jmp DetermineEvilOttoParameters
       
DisplayLivesKernel SUBROUTINE
; NOTE: we are still in vertical blank here...
      lda #0
      sta PF0                          ; clear playfield registers
      sta PF1
      sta PF2
   
   ELSE
   
ResetRobotsForNewBoard
      ldx #MAX_ROBOTS-1
      lda #0
      sta numberRobotsKilled           ; re-initialize number robots killed
      sta initRobotDelay
      sta temp02
      lda #135
      sta randomNumberMax              ; set random number ceiling
      lda #75                          ; initial vertical position of robot
.nextRobot
      sta lastRobotVertPos
      sta robotVertPos,x               ; set robot's vertical position
      jsr NextRandom                   ; get a random number
      sta robotHorizPos,x              ; set robot random horizontal position
      jsr NextRandom                   ; re-seed random number
      and #7                           ; and with 7 to get standing animation
      sta robotAnimationIndex,x        ; set standing animation of robot
      lda lastRobotVertPos
      sec
      sbc #H_ROBOT+1
      dex
      bpl .nextRobot
      jmp DetermineEvilOttoParameters
      
DisplayLivesKernel SUBROUTINE
      lda #0

   ENDIF

   sta AUDV0                        ; turn off audio volume
   ldx audioIndex
   beq .waitTime
   lda frameCount                   ; get the current frame count
   and #$07                         ; update the frequency every 8 frames
   bne .skipSetAudioFrequency
   lda AudioFrequencyTable,x
   sta AUDF0
   dec audioIndex
.skipSetAudioFrequency
   lda #13
   sta AUDC0
   lda #13                          ; load accumulator with 13 again ???
   sta AUDV0
.waitTime
   ldx INTIM
   bne .waitTime
   
   IF COMPILE_VERSION = NTSC
   
      stx WSYNC
      stx VBLANK                       ; enable TIA (D1 = 0)
      
   ELSE
   
      stx VBLANK                       ; enable TIA (D1 = 0)
      ldx #21
.skip22Scanlines
      sta WSYNC
      dex
      bne .skip22Scanlines
      
   ENDIF
   
   lda upperPlayfieldLimit
   beq DrawUpperPlayfieldBoarder
ClearUpperPlayfield
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05   clear playfield registers
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   cpx upperPlayfieldLimit    ; 3
   bne ClearUpperPlayfield    ; 2³
DrawUpperPlayfieldBoarder
   cpx lowerPlayfieldLimit    ; 3
   beq ClearLowerPlayfield    ; 2³
   cpx #2                     ; 2
   bcs DrawShrinkingPlayfield ; 2³
   sta WSYNC
;--------------------------------------
   lda #%11100000             ; 2
   sta PF0                    ; 3 = @05
   lda #%11111111             ; 2
   sta PF1                    ; 3 = @10
   lda #%00000111             ; 2
   sta PF2                    ; 3 = @15
   inx                        ; 2
   sta WSYNC
;--------------------------------------
   jmp DrawUpperPlayfieldBoarder; 3         could use unconditional branch
       
DrawShrinkingPlayfield
   cpx #86                    ; 2
   bcs DrawLowerPlayfieldBoarder; 2³
   sta WSYNC
;--------------------------------------
   txa                        ; 2
   lsr                        ; 2
   clc                        ; 2
   adc mazeOffset             ; 3
   tay                        ; 2
   lda MazePF0Data+1,y        ; 4
   sta PF0                    ; 3 = @18
   lda MazePF1Data+1,y        ; 4
   sta PF1                    ; 3 = @25
   lda MazePF2Data+1,y        ; 4
.jumpIntoShrinkingPF
   sta PF2                    ; 3 = @32
   inx                        ; 2
   sta WSYNC
;--------------------------------------
   cpx lowerPlayfieldLimit    ; 3
   bne DrawShrinkingPlayfield ; 2³
ClearLowerPlayfield
   cpx #(H_KERNEL / 2)        ; 2
   beq .jumpToScoreKernel     ; 2³
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   sta WSYNC
;--------------------------------------
   inx                        ; 2
   jmp ClearLowerPlayfield    ; 3         could use unconditional branch
       
.jumpToScoreKernel
   jmp ScoreKernel            ; 3

DrawLowerPlayfieldBoarder
   sta WSYNC
;--------------------------------------
   lda #%11100000             ; 2
   sta PF0                    ; 3 = @05
   lda #%11111111             ; 2
   sta PF1                    ; 3 = @10
   lda #%00000111             ; 2
   jmp .jumpIntoShrinkingPF   ; 3         could use unconditional branch
       
ColdStart
   ldy INTIM                        ; this is used for random number seed
   ldx #$FF
   txs                              ; set stack to beginning
   inx                              ; x = 0
   txa
ClearRAM
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   cld                              ; clear decimal mode
   sta COLUBK                       ; set background color to BLACK (a = 0)
   lda #BLUE
   sta COLUPF                       ; color the playerfield (i.e. maze)
   lda #%00010001                   ; set BALL to 2 clocks (not used) and
   sta CTRLPF                       ; REFLECT the playfield
   lda #$7F
   sta robotVertPos+MAX_ROBOTS
   sty random+1                     ; set the random number seed
   tya
   eor #%10110101
   sta random
   lda #%00001111
   sta robotMissileDirection        ; set missile to no direction (not moving)
   ldx #INIT_NUM_LIVES-1
   lda gameState
   bne .setNumberOfLives
   ldx #-1
.setNumberOfLives
   stx numberOfLives
   ldy #MOVE_DOWN
   sty playerDirection
   iny                              ; y = 3
   ldx #11
.setCopyrightLoop
   lda CopyrightLiteral,x
   sta digitPointer,x
   dex
   bpl .setCopyrightLoop
   ldx gameSelection
   lda GameVariationTable,x         ; set the game variation based on game
   sta gameVariation                ; selection
   inc attractModeTimer
   jmp IncrementGameLevel
       
CopyrightLiteral
   .word Blank,Copyright_0,Copyright_1,Copyright_2,Copyright_3,Copyright_4
   
CalculateP0GraphicPointers
   sta VDELP0                       ; VDEL the player if on an odd line (2LK)
   lsr                              ; divide by 2 for a 2LK
   sta player0Scanline              ; set scan line number for player0
   clc
   adc #H_PLAYER+1                  ; add with player height
   sta playerUpperBoundary          ; save for sprite drawing ceiling
   lda #H_KERNEL - 7
   sec
   sbc player0Scanline
   clc
   adc playerGraphicLSB
   sta playerGraphicPointer
   rts

IncrementScore
   ldy playerScore+1
   sty temp02                       ; save the thousands value of the score
   ldy #2
   sed
   clc
.incrementScoreLoop
   adc playerScore,y                ; increment score by accumulator
   sta playerScore,y
   lda #0
   dey
   bpl .incrementScoreLoop
   cld
   bit gameVariation                ; check for bonus life variation
   bvs .checkScorePass1000          ; check if score passed 100 for extra life
   bpl .leaveRoutine                ; leave if no bonus to be rewarded
   lda temp02                       ; load the saved thousands value (BCD)
   and #%00011111
   cmp #$19
   bne .leaveRoutine                ; didn't pass 2000 so no bonus life
.checkScorePass1000
   lda temp02                       ; load the saved thousands value (BCD)
   and #%00001111
   cmp #$09
   bne .leaveRoutine                ; didn't pass 1000 so no bonus life
   lda temp02                       ; load the saved thousands value (BCD)
   cmp playerScore+1                ; leave if it equals the value when coming
   beq .leaveRoutine                ; to routine
   lda #%00000011
   sta gameState
   inc numberOfLives
.leaveRoutine
   rts

NextRandom SUBROUTINE
   lda random
   asl                              ; shift random left (D7 into carry)
   eor random                       ; flip bits
   asl                              ; shift D6 of random into carry
   asl
   rol random+1                     ; rotate carry (D6 from random) into D0
   rol random                       ; rotate carry (D7 from random+1) into D0
   lda random+1
   and #%01111111                   ; mask D7 (0 <= a <= 127)
   sta temp01                       ; save value for later
.recomputeRandom
   clc
   adc temp02
   sec
   cmp randomNumberMax
   bcc .leaveRoutine
   beq .leaveRoutine
   lsr temp01                       ; divide temp01 by 2
   lda temp01                       ; and load accumulator with new value
   jmp .recomputeRandom
       
.leaveRoutine
   rts

   IF COMPILE_VERSION = NTSC
   
ResetRobotsForNewBoard
      ldx #MAX_ROBOTS-1
      lda #0
      sta numberRobotsKilled           ; re-initialize number robots killed
      sta initRobotDelay
      sta temp02
      lda #135
      sta randomNumberMax              ; set random number ceiling
      lda #75                          ; initial vertical position of robot
.nextRobot
      sta lastRobotVertPos
      sta robotVertPos,x               ; set robot's vertical position
      jsr NextRandom                   ; get a random number
      sta robotHorizPos,x              ; set robot random horizontal position
      jsr NextRandom                   ; re-seed random number
      and #7                           ; and with 7 to get standing animation
      sta robotAnimationIndex,x        ; set standing animation of robot
      lda lastRobotVertPos
      sec
      sbc #H_ROBOT+1
      dex
      bpl .nextRobot
      rts
      
   ENDIF

DetermineTimeToMoveRobot
   lda temp01
   bne .setToAllowRobotMovement
   lda playerCollisions+1,x         ; get section player collisions
   beq .setToAllowRobotMovement     ; branch if no collisions
   lda #ROBOT_DEATH_ANIM_OFFSET
   sta robotAnimationIndex,x        ; set the robot animation to dieing
   lda initRobotDelay
   cmp #$FF
   beq .setToSkipRobotMovement
   jsr SortRobotVariables
.setToSkipRobotMovement
   inc temp01
   sec
   rts

.setToAllowRobotMovement
   clc
   rts

SortRobotVariables
   txa                              ; move robot index to the accumulator
   tay                              ; save it in y for later
.sortLoop
   lda playerCollisions+2,x         ; get the player's collision value
   sta playerCollisions+1,x         ; bubble it up
   lda robotAnimationIndex+1,x      ; get the robot's collision value
   sta robotAnimationIndex,x        ; and bubble it up
   lda robotHorizPos+1,x            ; get the robot's horizontal position
   sta robotHorizPos,x              ; and bubble it up
   lda robotVertPos+1,x             ; get the robot's vertical position
   sta robotVertPos,x               ; and bubble it up
   inx                              ; increment robot index for next robot
   cmp #$7F                         ; see if the last robot is to be shown
   bne .sortLoop
   inc robotMotionDelay
   inc robotMotionDelay
   lda #$08
   sta AUDC1
   lda #$0F
   sta robotMissileSoundIndex
   tya                              ; move saved robot index to accumulator
   tax                              ; so we can restore it to x
   rts

DetermineRobotToMove
   ldy #3                           ; assume robot 3 will be selected to move
   lda #0
.determineBasedOnHorizPos
   clc
   adc #34
   cmp playerHorizPos
   bcs .determineBasedOnVertPos
   dey                              ; reduce initial robot number to move
   bpl .determineBasedOnHorizPos
.determineBasedOnVertPos
   lda playerVertPos
   cmp #(H_KERNEL / 2) - H_ROBOT + 1
   bcs .getRandomRobotNumber        ; branch if player in bottom half of PF
   iny
   iny
   iny
   iny
.getRandomRobotNumber
   tya                              ; move initial robot number to accumulator
   eor random+1                     ; flip bits based on random seed
   and #7                           ; make sure 0 <= a <= 7
   sta compRobotToMove              ; set the computed robot number to move
   rts

   BOUNDARY 0
MazePF0Data
MazePFData_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   
   REPEAT 16
      .byte $00 ; |........|
   REPEND
   
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
MazePF0Data_1
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   
   REPEAT 16
      .byte $00 ; |........|
   REPEND
   
   .byte $E0 ; |XXX.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
MazePF0Data_2
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $2F ; |..X.XXXX|
   .byte $2F ; |..X.XXXX|
   .byte $2F ; |..X.XXXX|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   
   REPEAT 16
      .byte $00 ; |........|
   REPEND
   
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
MazePF0Data_3
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   
   REPEAT 16
      .byte $00 ; |........|
   REPEND
   
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
   .byte $20 ; |..X.....|
;
; NOTE: Below values not used for maze data...they are used for missile data
;
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|

   IF COMPILE_VERSION = NTSC
   
      REPEAT 88
         .byte $00 ; |........|
      REPEND
      
   ELSE
       
      REPEAT 80
         .byte $00 ; |........|
      REPEND

PALRobotBWValues
   .byte BLACK2+8,BLACK+8,BLACK2+12,BLACK2+4,BLACK+12,BLACK2,BLACK2+8,BLACK+4
       
   ENDIF
   
NumberTable
   .byte <zero,<one,<two,<three,<four
   .byte <five,<six,<seven,<eight,<nine,<Blank
   
NumberFonts
zero
   .byte $7E ; |.XXXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $7E ; |.XXXXXX.|
one
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $3C ; |..XXXX..|
two
   .byte $7E ; |.XXXXXX.|
   .byte $40 ; |.X......|
   .byte $7E ; |.XXXXXX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $4E ; |.X  XXX.|
   .byte $7E ; |.XXXXXX.|
three
   .byte $7E ; |.XXXXXX.|
   .byte $4E ; |.X..XXX.|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $0E ; |....XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
four
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $5C ; |.X.XXX..|
   .byte $5C ; |.X.XXX..|
   .byte $5C ; |.X.XXX..|
   .byte $7C ; |.XXXXX..|
five
   .byte $7E ; |.XXXXXX.|
   .byte $4E ; |.X  XXX.|
   .byte $0E ; |....XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $40 ; |.X......|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
six
   .byte $7E ; |.XXXXXX.|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $40 ; |.X......|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
seven
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
eight
   .byte $7E ; |.XXXXXX.|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $7E ; |.XXXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $7E ; |.XXXXXX.|
nine
   .byte $7E ; |.XXXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $02 ; |......X.|
   .byte $7E ; |.XXXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $7E ; |.XXXXXX.|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
LivesIndicator
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
Copyright_0
   .byte $79 ; |.XXXX..X|
   .byte $85 ; |X....X.X|
   .byte $B5 ; |X.XX X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $85 ; |X....X.X|
   .byte $79 ; |.XXXX..X|
Copyright_1
   .byte $17 ; |...X.XXX|
   .byte $15 ; |...X.X.X|
   .byte $15 ; |...X.X.X|
   .byte $77 ; |.XXX.XXX|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $77 ; |.XXX.XXX|
Copyright_2
   .byte $71 ; |.XXX...X|
   .byte $41 ; |.X.....X|
   .byte $41 ; |.X.....X|
   .byte $71 ; |.XXX...X|
   .byte $11 ; |...X...X|
   .byte $51 ; |.X.X...X|
   .byte $70 ; |.XXX....|
Copyright_3
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $C9 ; |XX..X..X|
   .byte $49 ; |.X..X..X|
   .byte $49 ; |.X..X..X|
   .byte $BE ; |X.XXXXX.|
Copyright_4
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $D9 ; |XX.XX..X|
   .byte $55 ; |.X.X.X.X|
   .byte $55 ; |.X.X.X.X|
   .byte $99 ; |X..XX..X|
   
MissileVerticalLimitsTable
   .byte XMIN, XMIN+1, XMAX-1, XMAX
   
InitRobotMissileYOffset
   .byte 0                          ; not moving
   .byte 7                          ; missile traveling right
   .byte 7                          ; missile traveling left
   .byte 0                          ; left and right (IMPOSSIBLE)
   .byte 6                          ; missile traveling south
   .byte 6                          ; south and right
   .byte 0                          ; south and left
   .byte 0                          ; south and left and right (IMPOSSIBLE)
   .byte 1                          ; missile traveling north
   .byte 6                          ; north and right
   .byte 0                          ; north and left
       
InitRobotMissileXOffset
   .byte 3                          ; not moving
   .byte 9                          ; traveling right
   .byte 3                          ; traveling left
   .byte 3                          ; left and right (IMPOSSIBLE)
   .byte 4                          ; traveling south
   .byte 10                         ; south and right
   .byte 3                          ; south and left
   .byte 3                          ; south and left and right (IMPOSSIBLE)
   .byte 4                          ; traveling north
   .byte 3                          ; north and right
   .byte 3                          ; north and left
       
RobotMotionDelayTable
   .byte ROBOT_MOVE_DELAY_0
   .byte ROBOT_MOVE_DELAY_1
   .byte ROBOT_MOVE_DELAY_2
   .byte ROBOT_MOVE_DELAY_3
   .byte ROBOT_MOVE_DELAY_4
   .byte ROBOT_MOVE_DELAY_5
   .byte ROBOT_MOVE_DELAY_6
   .byte ROBOT_MOVE_DELAY_7

PlayerHorizAnimationTable
   .byte <PlayerStationary-PlayerSprites
   .byte <PlayerRunning0-PlayerSprites
   .byte <PlayerRunning1-PlayerSprites
   .byte <PlayerDeath-PlayerSprites
          
VerticalPixelOffsets
   .byte 0, -1, 1, 0, 0, -1, 1, 0, 0, -1, 1, 0, 0, 0, 0, 0
   
HorizontalPixelOffsets
   .byte 0, 0, 0, 0, -1, -1, -1, -1, 1, 1, 1, 1, 0, 0, 0, 0
       
RobotColorTable
   .byte YELLOW+10,RED_4+6,BLACK+12,LT_GREEN,RED_2+12
   .byte GREEN_BLUE,BROWN+12,PURPLE+8
   
PlayerShootingAnimationTable
   .byte <PlayerFireHoriz-PlayerSprites
   .byte <PlayerFireUp-PlayerSprites
   .byte <PlayerFireDown-PlayerSprites
   .byte <PlayerFireHoriz-PlayerSprites
       
InitMissileYOffsetTable
   .byte 0, 2, 7, 0, 5, 5, 7, 0, 5, 5, 7
       
InitMissileXOffsetTable
   .byte 0, 7, 8, 0, 0, 0, 0, 0, 6, 6, 6
       
AttractModeColors
   .byte RED_3
   .byte BLACK+1
   .byte BROWN_2+2
   
AudioFrequencyTable
   .byte $84,$00,$1F,$10,$02,$0A,$11,$18
       
MazePF1Data
MazePF1Data_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $0F ; |....XXXX|
   .byte $0F ; |....XXXX|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MazePF1Data_1
   REPEAT 31
      .byte $00 ; |........|
   REPEND
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MazePF1Data_2
   REPEAT 42
      .byte $00 ; |........|
   REPEND
MazePF1Data_3
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $08 ; |....X...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
       
   BOUNDARY (H_KERNEL - 7)

PlayerSprites
PlayerStationary
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $5A ; |.X XX.X.|
   .byte $5A ; |.X XX.X.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
PlayerRunning0
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $58 ; |.X.XX...|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $08 ; |....X...|
   .byte $64 ; |.XX..X..|
   .byte $44 ; |.X...X..|
   .byte $00 ; |........|
PlayerRunning1
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $F4 ; |XXXX.X..|
   .byte $82 ; |X.....X.|
   .byte $03 ; |......XX|
   .byte $00 ; |........|
   .byte $00 ; |........|
PlayerDeath
   .byte $3C ; |..XXXX..|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $3C ; |..XXXX..|
   .byte $C3 ; |XX....XX|
   .byte $A5 ; |X.X..X.X|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
   .byte $26 ; |..X..XX.|
   .byte $22 ; |..X...X.|
   .byte $2E ; |..X.XXX.|
   .byte $38 ; |..XXX...|
PlayerFireHoriz
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $1E ; |...XXXX.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
PlayerFireDown
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $3A ; |..XXX.X.|
   .byte $3A ; |..XXX.X.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
PlayerFireUp
   .byte $00 ; |........|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $02 ; |......X.|
   .byte $1C ; |...XXX..|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
       
   BOUNDARY 0
   
MazePF2Data
MazePF2Data_0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MazePF2Data_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $07 ; |.....XXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
MazePF2Data_2
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
MazePF2Data_3
   .byte $04 ; |.....X..|
   .byte $04 ; |.....X..|
   
   REPEAT 40
      .byte $00 ; |........|
   REPEND
   
   BOUNDARY (H_KERNEL - 7)
   
EvilOttoSprites
EvilOttoSprite_0
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $C3 ; |XX....XX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
EvilOttoSprite_1
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $DB ; |XX.XX.XX|
   .byte $FF ; |XXXXXXXX|
   .byte $7F ; |.XXXXXXX|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|

GameVariationTable
   .byte EXTRA_LIFE_1000|NO_OTTO|ROBOT_SHOOTING
   .byte EXTRA_LIFE_1000|NO_OTTO|ROBOT_SHOOTING
   .byte EXTRA_LIFE_1000|OTTO_REBOUND|ROBOT_SHOOTING
   .byte EXTRA_LIFE_1000|OTTO_INVINCIBLE|ROBOT_SHOOTING
   .byte EXTRA_LIFE_2000|NO_OTTO|ROBOT_SHOOTING
   .byte EXTRA_LIFE_2000|OTTO_REBOUND|ROBOT_SHOOTING
   .byte EXTRA_LIFE_2000|OTTO_INVINCIBLE|ROBOT_SHOOTING
   .byte NO_OTTO|ROBOT_SHOOTING
   .byte OTTO_REBOUND|ROBOT_SHOOTING
   .byte OTTO_INVINCIBLE|ROBOT_SHOOTING
   .byte 0,0,0,0,0,0                ; values not used (game selection in BCD)
   .byte EXTRA_LIFE_1000|OTTO_INVINCIBLE
   .byte EXTRA_LIFE_1000|OTTO_REBOUND
   .byte EXTRA_LIFE_1000|NO_OTTO    ; children's version

;============================================================================
; R O M - C O D E (Part 2)
;============================================================================

DetermineDiv15Position
   ldy #0                           ; set to 0 for coarse value move
   clc
   adc #1                           ; increment x position by 1
   cmp #45                          ; compare the value with mid point
   bcc .skipXPosReduction
   ldy #3                           ; set to 3 for coarse value move
   sbc #45                          ; reduce x position by mid point
.skipXPosReduction
   sec
.divideBy15
   iny                              ; increment y each iteration for coarse
   sbc #15                          ; position loop
   bcs .divideBy15
   eor #$FF                         ; flip the bits of the remainder
   sbc #6                           ; subtract the value by 6
   asl                              ; shift value to upper nybbles for fine
   asl                              ; motion
   asl
   asl
   rts

MoveObjectHorizontally
   sta WSYNC                        ; wait for next scan line
   SLEEP_4                          ; waste 4 cycles
   sta HMP0,x                       ; set fine motion value
   lda HMP0                         ; waste 3 cycles so subtraction start @ 11
.coarseMoveLoop
   dey
   bpl .coarseMoveLoop
   sta RESP0,x                      ; set object's coarse position
   rts

RobotAnimationTableOffsets
StandingAnimationOffset
   .byte <StandingAnimation0-RobotGraphics
   .byte <StandingAnimation0-RobotGraphics
   .byte <StandingAnimation1-RobotGraphics
   .byte <StandingAnimation2-RobotGraphics
   .byte <StandingAnimation3-RobotGraphics
   .byte <StandingAnimation4-RobotGraphics
   .byte <StandingAnimation5-RobotGraphics
   .byte <StandingAnimation6-RobotGraphics
   .byte <StandingAnimation7-RobotGraphics
WalkingLeftAnimationOffset
   .byte <WalkingLeftAnimation0-RobotGraphics
   .byte <WalkingLeftAnimation1-RobotGraphics
   .byte <WalkingLeftAnimation1-RobotGraphics
WalkingRightAnimationOffset
   .byte <WalkingRightAnimation0-RobotGraphics
   .byte <WalkingRightAnimation1-RobotGraphics
   .byte <WalkingRightAnimation1-RobotGraphics
WalkingUpAnimationOffset
   .byte <WalkingUpAnimation0-RobotGraphics
   .byte <StandingAnimation0-RobotGraphics
   .byte <WalkingUpAnimation1-RobotGraphics
   .byte <StandingAnimation0-RobotGraphics
WalkingDownAnimationOffset
   .byte <StandingAnimation4-RobotGraphics
   .byte <WalkingDownAnimation1-RobotGraphics
   .byte <StandingAnimation4-RobotGraphics
   .byte <WalkingDownAnimation0-RobotGraphics
DeathAnimationOffset
   .byte <DeathAnimation0-RobotGraphics
   .byte <DeathAnimation1-RobotGraphics
   .byte <DeathAnimation2-RobotGraphics
   .byte <DeathAnimation2-RobotGraphics
   
RobotAnimationTable
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+1
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+2
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+3
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+4
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+5
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+6
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+7
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets+8
   .byte <StandingAnimationOffset-RobotAnimationTableOffsets
   
   .byte <WalkingLeftAnimationOffset-RobotAnimationTableOffsets+1
   .byte <WalkingLeftAnimationOffset-RobotAnimationTableOffsets+2
   .byte <WalkingLeftAnimationOffset-RobotAnimationTableOffsets
   
   .byte <WalkingRightAnimationOffset-RobotAnimationTableOffsets+1
   .byte <WalkingRightAnimationOffset-RobotAnimationTableOffsets+2
   .byte <WalkingRightAnimationOffset-RobotAnimationTableOffsets
   
   .byte <WalkingUpAnimationOffset-RobotAnimationTableOffsets+1
   .byte <WalkingUpAnimationOffset-RobotAnimationTableOffsets+2
   .byte <WalkingUpAnimationOffset-RobotAnimationTableOffsets+3
   .byte <WalkingUpAnimationOffset-RobotAnimationTableOffsets
   
   .byte <WalkingDownAnimationOffset-RobotAnimationTableOffsets+1
   .byte <WalkingDownAnimationOffset-RobotAnimationTableOffsets+2
   .byte <WalkingDownAnimationOffset-RobotAnimationTableOffsets+3
   .byte <WalkingDownAnimationOffset-RobotAnimationTableOffsets
       
RobotGraphics
RobotStandingAnimation
StandingAnimation0
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation1
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation2
   .byte $3C ; |..XXXX..|
   .byte $1E ; |...XXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation3
   .byte $3C ; |..XXXX..|
   .byte $4E ; |.X..XXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation4
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation5
   .byte $3C ; |..XXXX..|
   .byte $72 ; |.XXX..X.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation6
   .byte $3C ; |..XXXX..|
   .byte $78 ; |.XXXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
StandingAnimation7
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $66 ; |.XX..XX.|
   .byte $00 ; |........|
   
RobotWalkingAnimation
WalkingLeftAnimation0
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $6C ; |.XX.XX..|
   .byte $00 ; |........|
WalkingLeftAnimation1
   .byte $3C ; |..XXXX..|
   .byte $3E ; |..XXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
   .byte $00 ; |........|
WalkingRightAnimation0
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $36 ; |..XX.XX.|
   .byte $00 ; |........|
WalkingRightAnimation1
   .byte $3C ; |..XXXX..|
   .byte $7C ; |.XXXXX..|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $1C ; |...XXX..|
   .byte $00 ; |........|
   
WalkingUpAnimation0
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $64 ; |.XX..X..|
   .byte $06 ; |.....XX.|
WalkingUpAnimation1
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $26 ; |..X..XX.|
   .byte $60 ; |.XX.....|
   
WalkingDownAnimation0
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $64 ; |.XX..X..|
   .byte $06 ; |.....XX.|
WalkingDownAnimation1
   .byte $3C ; |..XXXX..|
   .byte $66 ; |.XX..XX.|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $BD ; |X.XXXX.X|
   .byte $24 ; |..X..X..|
   .byte $24 ; |..X..X..|
   .byte $26 ; |..X..XX.|
   .byte $60 ; |.XX.....|
   
RobotDeathAnimation
DeathAnimation0
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
DeathAnimation1
   .byte $14 ; |...X.X..|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $52 ; |.X.X..X.|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
DeathAnimation2
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   .byte $00 ; |........|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $00 ; |........|
   
MazeOffsetTable
.init_maze_offset SET 0
   REPEAT 4
   .byte .init_maze_offset * [(H_KERNEL / 2) - 4] / 2
.init_maze_offset SET .init_maze_offset + 1
   REPEND
   
StartingLocationValues
   .byte PLAYER_ENTERING_SOUTH
   .byte PLAYER_ENTERING_NORTH
   .byte PLAYER_ENTERING_EAST
   .byte PLAYER_ENTERING_WEST
       
InitHorizontalPosition
   .byte XMAX_PLAYER / 2, XMAX_PLAYER / 2, XMIN + 6, XMAX_PLAYER - 7
   
InitVerticalPosition
   .byte YMIN + 8, 142
   .byte [(H_KERNEL / 2) - (H_PLAYER + 2)], [(H_KERNEL / 2) - (H_PLAYER + 2)]

RobotMissileDelayTable
   .byte ROBOT_MISSILE_DELAY_0
   .byte ROBOT_MISSILE_DELAY_1
   .byte ROBOT_MISSILE_DELAY_2
   .byte ROBOT_MISSILE_DELAY_3
   .byte ROBOT_MISSILE_DELAY_4
   .byte ROBOT_MISSILE_DELAY_5
   .byte ROBOT_MISSILE_DELAY_6
   .byte ROBOT_MISSILE_DELAY_7
   
   BOUNDARY 252
   
   .word Start
   .word 0