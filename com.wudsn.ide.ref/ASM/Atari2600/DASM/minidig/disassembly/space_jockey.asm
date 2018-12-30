   LIST OFF
; ***  S P A C E  J O C K E Y  ***
; Copyright 1982 US Games Corporation
; Designer: Garry Kitchen

; Analyzed, labeled and commented
;  by Dennis Debro
; Last Update: June 14, 2004
;
; This was Garry's first Atari VCS game. Garry learned to program the VCS by
; reverse engineering the hardware and various games using his Apple II. This
; game was started by him reverse engineering Outlaw which was written by
; David Crane while at Atari.
;
; After writing Space Jockey he approached his boss and suggested selling the
; game to Activision. Instead the company decided to sell the game to US Games.
; So Space Jockey became US Games' first VCS game.
;
; Garry uses a horizontal position routine that *seems* to first appear here.
; This routine was modified over the years and has been seen in a number of
; games.
;
; To produce the PAL listing I used the Carrere Video version. The PAL version
; adjusts the vertical blank time to make the game produce 314 scan lines.
; The colors were also adjusted but it seems they missed the place in the
; kernel where Garry colors some objects directly. The speeds and the sound
; frequencies were not adjusted for the PAL timing.

   processor 6502
      
;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

   include vcs.h

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

; values for REFPx:
NO_REFLECT        = %0000
REFLECT           = %1000

; SWCHA joystick bits:
MOVE_RIGHT        = %01111111
MOVE_LEFT         = %10111111
MOVE_DOWN         = %00100000
MOVE_UP           = %00010000
NO_MOVE           = %11111111

; mask for SWCHB
BW_MASK           = %1000         ; black and white bit
SELECT_MASK       = %10
RESET_MASK        = %01

;============================================================================
; U S E R - C O N S T A N T S
;============================================================================

ROM_BASE_ADDRESS     = $F000

; frame time values
VSYNC_TIME           = $28
OVERSCAN_LINES       = 28           ; number of scanlines in overscan

   IF COMPILE_VERSION = NTSC
   
VBLANK_TIME          = $2D

   ELSE
   
VBLANK_TIME          = $6A

   ENDIF

; color constants
BLACK       =  $00
WHITE       =  $0F

   IF COMPILE_VERSION = NTSC
   
BLUE           = $80
YELLOW         = $10
GREEN_BROWN    = $E0
BRIGHT_GREEN   = $C0
GREEN          = $B0
RED            = $40
PURPLE         = $50
BRICK_RED      = $30
BROWN          = $F0
LT_BROWN       = BROWN+2
SIREN_LIGHT    = BRICK_RED

   ELSE
   
BLUE           = $D0
YELLOW         = $40
GREEN_BROWN    = YELLOW
BRIGHT_GREEN   = $50
GREEN          = $30
RED            = $80
PURPLE         = $A0
BRICK_RED      = $60
BROWN          = YELLOW
LT_BROWN       = BROWN+4
SIREN_LIGHT    = RED

   ENDIF
   
; objectType ids:
ID_BALLOON                    = 0
ID_JET_PLANE                  = 1
ID_HELICOPTER                 = 2
ID_PROP_PLANE                 = 3
ID_HOUSE                      = 4
ID_TREE                       = 5
ID_TANK_0                     = 6
ID_TANK_1                     = 7 

; game selection values
OPTION_PLAYER_MOVE_MISSILE    = %01
OPTION_ENEMY_MOVE_VERT        = %10
OPTION_PLAYER_MOVE_HORIZ      = %100
OPTION_PLAYER_COLLISIONS      = %1000

; object score values (BCD)
BALLOON_SCORE                 = $25
JET_PLANE_SCORE               = $99
HELICOPTER_SCORE              = $50
PROP_PLANE_SCORE              = $99
HOUSE_SCORE                   = $20
TREE_SCORE                    = $20
TANK_SCORE                    = $99

; kernel boundaries
KERNEL_HEIGHT                 = 153
KERNEL_ZONE_HEIGHT            = 52

SPACE_JOCKEY_XMIN             = 16
SPACE_JOCKEY_XMAX             = 131
SPACE_JOCKEY_YMIN             = 21
SPACE_JOCKEY_YMAX             = 153

ENEMY_XMAX                    = 152

MISSILE_XMIN                  = 1
MISSILE_XMAX                  = 162

SPACE_JOCKEY_MISSILE_OFFSET   = 3
ENEMY_MISSILE_OFFSET          = 8
                           

INITIAL_START_COUNT           = 32
NUMBER_OF_GROUPS              = 3   ; number of enemy groups
STARTING_LIVES                = 2   ; number of lives at the start of a game
MAX_LIVES                     = 6   ; maximum number of reserved lives
MOUNTAIN_ROLL_RATE            = 3
SELECT_DELAY                  = 30  ; number of frames to wait to check select
                                    ; switch
LOGO_HEIGHT                   = 5
NUMBER_HEIGHT                 = 8
SPACE_JOCKEY_HEIGHT           = 7
MISSILE_PIXEL_MOVEMENT        = 3

;============================================================================
; Z P - V A R I A B L E S
;============================================================================
   
spaceJockeyColors       = $80       ; $80 - $86
scoreColor              = $87
playfieldColor          = $88
backgroundColor         = $89
livesColor              = $8A
spaceJockeyGraphics     = $8B       ; $8B - $91
spaceJockeyVertPos      = $92
spaceJockeyHorzPos      = $93
pf0Data                 = $94       ; $94 - $96
pf1Data                 = $97       ; $97 - $99
pf2Data                 = $9A       ; $9A - $9C
enemyVerticalPos        = $9D       ; $9D - $9F
enemyLSB                = $A0       ; $A0 - $A2
enemyGraphicPointer     = $A3       ; $A3 - $A4
enemyColorPointer       = $A5       ; $A5 - $A6
numberOfLives           = $A7
playerScore             = $A8       ; $A8 - $AA
enemyAttributes         = $AB       ; $AB - $AD
digitPointer            = $AE       ; $AE - $B9
deathAnimPointer        = $BA       ; $BA - $BB
;--------------------------------------
playerColors            = deathAnimPointer
;--------------------------------------
tempCharHolder          = playerColors
;--------------------------------------
allowedMotion           = playerColors
;--------------------------------------
enemyVertDistance       = playerColors ; used to calculate new enemy vertical pos

loopCount               = playerColors+1
;--------------------------------------
tempGRP0Graphic         = loopCount
enemyMotion             = $BC       ; $BC - $BE
startCount              = enemyMotion
objectIds               = $BF       ; $BF - $C1
enemyHorizPos           = $C2       ; $C2 - $C4
enemyVelocity           = $C5       ; $C5 - $C7
enemyDeathAnimRate      = $C8       ; $C8 - $CA
enemyDeathSound         = $CB       ; $CB - $CD
enemyColorsLSB          = $CE       ; $CE - $CF

enemyScanline           = $D1

enemyMissileVert        = $D3
enemyMissileHoriz       = $D4
spaceJockeyMissileVert  = $D5
spaceJockeyMissileHoriz = $D6
kernelZone              = $D7
kernelZoneEnd           = $D8
scanline                = $D9
selectDebounce          = $DA
mountainRollingRate     = $DB
randomSeed              = $DC       ; $DC - $DE
frameCount              = $DF       ; updated each frame
enemyShotVolume         = $E0
spaceJockeyShotFreq     = $E1       ; sound frequency
spaceJockDeathAnimRate  = $E2
spaceJockeyDeathSound   = $E3
attractModeTimer        = $E4
showHighScore           = $E5       ; show high score when set high (D7 = 1)
spaceJockeyHit          = $E6
enemyFiring             = $E7       ; $FF = firing $00 = not firing
spaceJockeyFiring       = $E8       ; $FF = firing $00 = not firing
gameState               = $E9       ; D7 = 0 game over
attractMode             = $EA
clearGameRAM            = $EB       ; set high to clear RAM
highScore               = $EC       ; $EC - $EE
gameSelection           = $EF

;============================================================================
; R O M - C O D E (Part 1)
;============================================================================

   SEG Bank0
   org ROM_BASE_ADDRESS
   
Start
;
; Set up everything so the power up state is known.
;
   sei
   cld                              ; clear decimal mode
   ldx #$FF
   txs                              ; point the stack to the beginning
   inx                              ; x = 0
   txa
.clearLoop
   sta VSYNC,x
   inx
   bne .clearLoop
   
   jsr InitializeGame
   inc playerScore+2
   dec attractMode                  ; reduces on game cart power up so it's
                                    ; value is negative
       
MainLoop
   lda backgroundColor
   sta COLUBK
   
   inc randomSeed
   dec randomSeed+1
   inc randomSeed+2
   
VerticalSync SUBROUTINE
   ldy #$FF
   sty VSYNC                        ; start vertical sync (D1 = 1)
   sty VBLANK                       ; turn off TIA
   
   lda #VSYNC_TIME
   sta TIM8T                        ; set timer for VSYNC wait period
   inc frameCount                   ; increment frameCount each new frame
   bne .vsyncWaitTime

   lda attractMode                  ; cycle colors when value goes negative
   bpl .skipColorCycling
   
   ldx #spaceJockeyGraphics-spaceJockeyColors-1
.cycleGameColors
   inc spaceJockeyColors,x
   dex
   bpl .cycleGameColors
.skipColorCycling
   inc attractModeTimer

   bne .vsyncWaitTime

   sty attractMode                  ; attractMode now negative
.vsyncWaitTime
   ldy INTIM
   bne .vsyncWaitTime
   sty WSYNC
   sty VSYNC                        ; end vertical sync

VerticalBlank SUBROUTINE
   lda #VBLANK_TIME
   sta TIM64T                       ; set timer for VBLANK time
   
   lda SWCHB                        ; read the console switches
   and #SELECT_MASK | RESET_MASK    ; mask the SELECT and RESET values
   cmp #SELECT_MASK | RESET_MASK    ; see if SELECT or RESET is pressed
   bne .consoleSwitchDown           ; one of the console switches is down

   lda INPT4                        ; read the fire button
   bmi .checkForGameReset           ; if not pressed then check game reset
   
.consoleSwitchDown
   sty attractMode                  ; reset the attractMode
   sty attractModeTimer             ; zero out
   ldx #10
   jsr InitLoop
   
.checkForGameReset
   lda SWCHB                        ; read the console switches
   lsr                              ; shift game reset to carry
   bcs .skipReset                   ; skip game reset
   lda clearGameRAM                 ; if negative then clear game RAM
   bmi ClearGameRAM
.setToClearGameRAM
   dec clearGameRAM                 ; show to clear RAM
;
; This routine clears RAM starting at (attractMode) and goes back to PF1
:
ClearGameRAM
   ldx #156
   lda #0
.clearRAM
   sta PF1+64,x                     ; clear RAM starting at attractMode
   dex                              ; back to PF1
   bne .clearRAM
   
   jsr InitializeGame
   bmi .convertDigits               ; unconditional branch
   
.skipReset
   ldx #0
   lsr                              ; shift game select to carry
   bcs .skipSelect
   lda clearGameRAM
   bpl .setToClearGameRAM
   lda selectDebounce
   beq .incrementGameSelection
   dec selectDebounce
   bpl .skipIncrementGameSelection
.incrementGameSelection
   stx playerScore+1                ; clear the player's score (x = 0)
   stx playerScore

   inc gameSelection                ; increase game selection
   lda gameSelection                ; get the game selection
   and #$0F                         ; mask the upper nibble
   sta gameSelection                ; store the value in the gameSelection
   clc
   adc #1                           ; add 1 to the value
   cmp #10                          ; if the value is greater than 10 then
                                    ; show the tens position value (i.e. BCD)
   bcc .setTensPosition
   sbc #10                          ; subtract 10 from the value (carry set)
   ora #16                          ; set the upper nibble to show tens value
.setTensPosition
   sta playerScore+2                ; store value to show the game selection
   ldx #SELECT_DELAY                ; reset select debounce value
.skipSelect
   stx selectDebounce
   
.skipIncrementGameSelection
   lda gameState                    ; get the current game state
   bmi .skipAttactModeProcessing    ; branch if game in progress
   
   lda INPT4                        ; read the fire button
   bmi .checkToShowHighScore        ; skip game start if not pressed
   lda clearGameRAM
   bpl .setToClearGameRAM
   lda #$FF
   sta gameState                    ; show game is in progress
   inc clearGameRAM                 ; now positive
   sty playerScore+2
   sty showHighScore                ; show the score
   beq .convertDigits               ; unconditional branch
       
.checkToShowHighScore
   lda SWCHA                        ; read the joystick values
   and #$F0                         ; only concerned with left joystick port
   cmp #$F0                         ; if the stick wasn't moved then
   beq .dontShowHighScore           ; don't show the high score
   ldy #$FF                         ; joystick was moved so show high score
.dontShowHighScore
   sty showHighScore                ; set flag to trigger showing high score
.convertDigits
   jmp BCD2DigitPtrs
   
.skipAttactModeProcessing
   lda spaceJockeyHit               ; check if the space jocky was hit
   bmi CheckGameCollisions          ; skip joystick routine if true

   lda SWCHA                        ; read the joystick values
   sta allowedMotion                ; save the value for later
   lda gameSelection                ; get the current game selection
   and #OPTION_PLAYER_MOVE_HORIZ    ; if the selection is divisible by 4
   beq .checkVerticalMotion         ; then skip horizontal movement
   
   lda allowedMotion                ; get the player joystick value
   asl
   bmi .checkRightMotion
;
; player moving left
;
   inc randomSeed+2
   dec spaceJockeyHorzPos
   dec spaceJockeyHorzPos

   lda #SPACE_JOCKEY_XMIN           ; make sure Space Jockey doesn't move
   cmp spaceJockeyHorzPos           ; too far to the left
   bcc .checkRightMotion
   sta spaceJockeyHorzPos
   
.checkRightMotion
   lda allowedMotion                ; get the player joystick value
   bmi .checkVerticalMotion
;
; player moving right
;
   inc randomSeed
   inc spaceJockeyHorzPos
   inc spaceJockeyHorzPos
   
   lda #SPACE_JOCKEY_XMAX           ; make sure Space Jockey doesn't move
   cmp spaceJockeyHorzPos           ; too far to the right
   bcs .checkVerticalMotion
   sta spaceJockeyHorzPos
   
.checkVerticalMotion
   lda allowedMotion                ; get the player joystick value
   and #MOVE_DOWN
   bne .checkUpMotion
;
; player moving down
;
   inc randomSeed
   dec spaceJockeyVertPos
   dec spaceJockeyVertPos
   
   lda #SPACE_JOCKEY_YMIN           ; make sure Space Jockey doesn't move
   cmp spaceJockeyVertPos           ; too far down the screen
   bcc .checkUpMotion
   sta spaceJockeyVertPos
   
.checkUpMotion
   lda allowedMotion                ; get the player joystick value
   and #MOVE_UP
   bne CheckGameCollisions
;
; player moving up
;
   dec randomSeed+1
   inc spaceJockeyVertPos
   inc spaceJockeyVertPos
   
   lda #SPACE_JOCKEY_YMAX           ; make sure Space Jockey doesn't move
   cmp spaceJockeyVertPos           ; too far up the screen
   bcs CheckGameCollisions
   sta spaceJockeyVertPos
   
CheckGameCollisions
   lda gameSelection
   and #OPTION_PLAYER_COLLISIONS    ; game #8-16 check player/player collision
   beq .noPlayerCollisions

   lda CXPPMM                       ; read the player/missle collision
   bpl .noPlayerCollisions          ; if the players hadn't collided then skip
   
   lda spaceJockeyVertPos
   sec
   sbc #SPACE_JOCKEY_HEIGHT-2
   bne LF189
       
.noPlayerCollisions
   lda spaceJockeyFiring            ; get Space Jockey firing state
   bmi .moveSpaceJockeyMissile      ; if firing then move the missile
   sta AUDV0
   ldx spaceJockeyVertPos
   dex
   dex
   stx spaceJockeyMissileVert
   lda spaceJockeyHorzPos
   clc
   adc #16
   sta spaceJockeyMissileHoriz 
   
   lda INPT4                        ; read the fire button
   ora spaceJockeyHit               ; or the value with space jockey hit state
   bmi RollingMountainAnimation     ; skip the missile fire routine
   
   dec spaceJockeyFiring            ; value now negative to show firing state
   dec spaceJockeyMissileVert
.moveSpaceJockeyMissile
   inc randomSeed
   lda #8
   sta AUDV0
   sta AUDC0
   lda spaceJockeyMissileHoriz      ; get the Space Jockey missile's horizontal
                                    ; position
   clc
   adc #MISSILE_PIXEL_MOVEMENT      ; Space Jockey missile pixel movement
   cmp #MISSILE_XMAX                ; make sure the missile doesn't go out of
   bcc .setMissileHorizontalValue   ; range
   lda #MISSILE_XMIN
   sta spaceJockeyMissileVert
.setMissileHorizontalValue
   sta spaceJockeyMissileHoriz
   lda spaceJockeyShotFreq          ; get the shot sound frequency
   clc
   adc #MISSILE_PIXEL_MOVEMENT      ; increment it by the pixel movement
   cmp #SPACE_JOCKEY_XMAX-1
   bcc .setSpaceJockeyShotFrequency
   inc spaceJockeyFiring            ; value positive to show not firing state
   lda #0                           ; used to reset the shot sound frequency
.setSpaceJockeyShotFrequency
   sta spaceJockeyShotFreq
   sta AUDF0
       
   lda CXM1P
   bpl .moveSpaceJockeyMissileVert  ; Space Jockey didn't shoot an enemy
   
   lda spaceJockeyMissileVert
LF189
   jsr FindKernelZone               ; find the "zone" the space jockey is in
   lda enemyAttributes,x            ; get the attributes value
   bmi .moveSpaceJockeyMissileVert  ; branch if the object has been shot
   ora #%10000000                   ; or the value to show that the object
   sta enemyAttributes,x            ; has been shot
   lda #$15
   sta AUDF0                        ; set the object shot sound frequency
   sta spaceJockeyMissileVert
   lda #2
   sta enemyDeathAnimRate,x         ; death animation updated every 3 frames
   lda #0
   sta enemyDeathSound,x
   sta spaceJockeyFiring            ; clear the space jockey missile data
   sta spaceJockeyMissileHoriz
   sta spaceJockeyShotFreq
   jsr IncrementScore
   lda #$0F
   sta AUDC0
.moveSpaceJockeyMissileVert
   lda spaceJockeyFiring            ; check to see if Space Jockey is firing
   bpl RollingMountainAnimation     ; if not then skip to moutain rolling
   lda spaceJockeyMissileVert       ; get the vertical position of the missile
   lsr                              ; if odd skip to mountain rolling (2LK)
   bcs RollingMountainAnimation
   lda gameSelection                ; get the game selection
   lsr                              ; if even number skip to mountain rolling
   bcc RollingMountainAnimation
   lda spaceJockeyVertPos           ; get Space Jockey vertical position
   sbc #SPACE_JOCKEY_MISSILE_OFFSET ; reduce the value by 3 for the new
   sta spaceJockeyMissileVert       ; vertical position of the missile
   
RollingMountainAnimation
   dec mountainRollingRate
   bpl .skipMountainRolling
   lda #MOUNTAIN_ROLL_RATE
   sta mountainRollingRate
   ldx #2
.rollMoutainLoop
   lda pf0Data,x
   and #$10
   adc #$FE
   ror pf2Data,x
   rol pf1Data,x
   ror pf0Data,x
   dex
   bpl .rollMoutainLoop
   
.skipMountainRolling
   lda spaceJockeyHit               ; check to see if the space jockey was hit
   bpl .spaceJockeyAnimation        ; branch if not
   dec spaceJockDeathAnimRate       ; reduce the death animation frame count
   bpl .moveEnemies                 ; branch if not negative
   ldx #$02
   stx spaceJockDeathAnimRate       ; reset the death animation frame rate
   ldx spaceJockeyDeathSound
   inx                              ; increment the death sound frequency
   cpx #16
   bcc .determineDeathAnimation
   clc
   ldy #0
   sty AUDC1                        ; clear the channel (turn off death sound)
       
   ldx #NUMBER_OF_GROUPS-1
.clearEnemiesLoop
   sty enemyVelocity,x              ; set enemy velocity to 0 to move faster
   lda enemyAttributes,x            ; get the enemy attribute value
   bcs .clearNextEnemy              ; clear next enemy if not reached left
   lsr                              ; moves D0 to carry
.clearNextEnemy
   dex
   bpl .clearEnemiesLoop
   
   bcs .moveEnemies
   dec numberOfLives                ; reduce the number of lives
   bpl .skipGameOver                ; if still positive then game not over
   sty gameState                    ; show that game is over (y = 0)
.skipGameOver
   sty spaceJockeyHit
   ldx #19
   jsr InitLoop
   sty AUDC1
   bmi .moveEnemies
       
.determineDeathAnimation
   cpx #5
   bcs .playSpaceJockeyDeathSound
   ldy #SPACE_JOCKEY_HEIGHT-2
   lda #>SpaceJockeyDeathSprites
   sta deathAnimPointer+1
   lda SpaceJockeyDeathAnimTable-1,x
   sta deathAnimPointer
.storeDeathAnimationGraphics
   lda (deathAnimPointer),y
   sta spaceJockeyGraphics,y
   dey
   bpl .storeDeathAnimationGraphics
   
.playSpaceJockeyDeathSound
   stx spaceJockeyDeathSound        ; save the current death sound value
   txa
   sta AUDF1                        ; set the death sound frequency
   eor #$FF
   sta AUDV1                        ; set the death sound volume
   lda #8
   sta AUDC1                        ; set the death sound channel
.moveEnemies
   jmp MoveEnemies
   
.spaceJockeyAnimation
   ldy #%11010101
   lda #$08
   and frameCount
   beq .setSpaceJockeyWindowGraphics
   ldy #%10101011
.setSpaceJockeyWindowGraphics
   sty spaceJockeyGraphics+2
   ldy #SIREN_LIGHT+14
   lda #$10
   and frameCount
   beq .setSirenLightColor
   ldy #SIREN_LIGHT+6
.setSirenLightColor
   sty spaceJockeyColors+5

MoveEnemies SUBROUTINE
   ldx #NUMBER_OF_GROUPS-1
.moveEnemyLoop
   lda enemyAttributes,x            ; get the enemy's attributes
   lsr                              ; shift the "moving" flag to carry
   bcs .determineEnemyMovement      ; check to move enemy (present on screen)
   jmp CheckToLaunchNewAttack
   
.determineEnemyMovement
   dec enemyMotion,x
   bpl .checkForEnemyShot
   lda enemyVelocity,x
   sta enemyMotion,x
   lda objectIds,x                  ; get the object id
   cmp #ID_HOUSE                    ; check to see if it can move vertically
   bcs .moveEnemyLeft               ; if not then move the object toward the
                                    ; space jockey
   lda gameSelection                ; get the game selection
   and #OPTION_ENEMY_MOVE_VERT      ; check if the objects can move vertically
   beq .moveEnemyLeft
;
; enemy can move randomly up or down (game options 3,4,7,8,11,12,15,16)
;
   lda randomSeed,x
   cmp #208
   bcs .moveEnemyLeft
   bpl .moveEnemyUp
.moveEnemyDown
   dec enemyVerticalPos,x
   lda EnemyVerticalFloor,x
   cmp enemyVerticalPos,x
   bcc .moveEnemyLeft
   bcs .setEnemyVerticalPosition
.moveEnemyUp
   inc enemyVerticalPos,x
   lda EnemyVerticalCeiling,x
   cmp enemyVerticalPos,x
   bcs .moveEnemyLeft
.setEnemyVerticalPosition
   sta enemyVerticalPos,x
.moveEnemyLeft
   dec enemyHorizPos,x
   bne .checkForEnemyShot
   
.removeEnemy
   lda #<JetPlane-1                 ; point to any 0 byte on $F7 page
   sta enemyLSB,x                   ; store it to erase sprite
   lda enemyAttributes,x
   and #%01111110
   sta enemyAttributes,x            ; show the enemy is no longer shot
       
   lda #INITIAL_START_COUNT
   sta enemyMotion,x
   bne .nextEnemy
   
.checkForEnemyShot
   lda enemyAttributes,x            ; get the enemy attribute value
   bpl .setEnemyAnimation           ; branch if enemy not shot
   dec enemyDeathAnimRate,x         ; decrement death animation rate
   bpl .jumpNextEnemy               ; keep current frame if positive
   lda #2
   sta enemyDeathAnimRate,x
   inc enemyDeathSound,x
   ldy enemyDeathSound,x
   cpy #16
   bcs .removeEnemy
   cpy #5
   bcs .playEnemyDeathSound
   lda ExplosionAnimationTable-1,y
   sta enemyLSB,x
   lda #<ExplosionColor
   sta enemyColorsLSB,x
.playEnemyDeathSound
   tya
   sta AUDF0
   eor #$FF
   sta AUDV0
.jumpNextEnemy
   jmp .nextEnemy
   
.setEnemyAnimation
   ldy objectIds,x                  ; object id used for table index
   lda #$02
   and frameCount
   beq .loadOddAnimationFrame
   lda EnemyAnimationTable0,y
   bne .storeAnimationLSB
.loadOddAnimationFrame
   lda EnemyAnimationTable1,y
.storeAnimationLSB
   sta enemyLSB,x
.nextEnemy
   jmp .nextEnemyGroup
   
CheckToLaunchNewAttack
   lda spaceJockeyHit
   bmi .nextEnemyGroup
   dec startCount,x                 ; decrement start count to determine when
                                    ; to launch new attack
   bpl .nextEnemyGroup              ; don't launch new attack
.launchNewEmenyAttack
   lda randomSeed,x                 ; get random seed associated to the enemy
   and #$0F                         ; mask the upper nybbles
   sta enemyVertDistance            ; save it for subtraction below
   lda EnemyVerticalCeiling,x       ; get the highest vertical point for enemy
   sbc enemyVertDistance            ; subtract distance
   sta enemyVerticalPos,x           ; store value for enemy vertical position
   lda randomSeed,x
   and #$02
   sta enemyVelocity,x
   lda randomSeed,x                 ; get random seed to determine new enemy
   lsr                              ; shift the value down 4 times (divide by
   lsr                              ; 8)
   lsr
   lsr
   cpx #0
   beq .initNewObjectId
   and #$03                         ; make sure the enemy is a "flying" enemy
.initNewObjectId
   and #$07                         ; make sure enemy value is 0 <= x <= 7
   sta objectIds,x                  ; store the new enemy id
   tay
   lda EnemyAttibutesTable,y
   sta enemyAttributes,x
   cpy #ID_HOUSE                    ; check to see if this a "flying" enemy
   bcc .initNewEnemyGraphics        ; branch if new enemy is a "flying" enemy
   lda #$18
   sta enemyVerticalPos             ; set vertical position for ground enemies
   stx enemyVelocity                ; ground enemies have no motion delay
.initNewEnemyGraphics
   lda EnemyAnimationTable0,y       ; get the first animation frame sprite
   sta enemyLSB,x                   ; store it in the enemy LSB
   lda EnemyColorTable,y            ; read the color table LSB
   sta enemyColorsLSB,x             ; and store it
   lda #ENEMY_XMAX
   sta enemyHorizPos,x              ; start enemy on right side of the screen
.nextEnemyGroup
   dex
   bmi MoveEnemyMissile
   jmp .moveEnemyLoop
   
MoveEnemyMissile
   lda spaceJockeyHit
   bmi LF397                        ; branch if the space jockey was hit
   lda enemyFiring
   bpl EnemyNotFiring
   
   ldy enemyMissileHoriz
   lda SWCHB                        ; read the console switches
   asl                              ; left difficulty value in D7
   bpl .moveEnemyShotLeft
   dey                              ; difficulty set to fast ememy shots
.moveEnemyShotLeft
   tya
   sec
   sbc #MISSILE_PIXEL_MOVEMENT
   cmp #5
   bcs .setEnemyShotPosition
   lda #16
   sta enemyMissileVert
.setEnemyShotPosition
   sta enemyMissileHoriz
   dec enemyShotVolume
   bne .playEnemyMissileSound
   inc enemyFiring
.playEnemyMissileSound
   lda enemyShotVolume
   lsr
   lsr
   lsr
   sta AUDV1
   lda #$08
   sta AUDC1
   sta AUDF1 
   bne LF397
   
EnemyNotFiring
   lda #$40
   sta enemyShotVolume              ; reset the enemy shot volume
   sta AUDC1                        ; clear the channel so no sound
   ldy SWCHB                        ; read the console switch into y
   bmi .determineEnemyShot
   lda #$A0
   cmp randomSeed
   bcs LF397                        ; skip enemy shot spawning
.determineEnemyShot
   lda spaceJockeyVertPos           ; get space jockey's vertical position
   jsr FindKernelZone               ; determine space jockey "zone"
   lda enemyAttributes,x
   bmi LF397                        ; if enemy shot then skip
   and #$05                         ; determine if enemy type can fire a shot
   eor #$05
   bne LF397                        ; branch if enemy type can't fire shot
   lda enemyHorizPos,x              ; get the enemy's horizontal position
   cmp spaceJockeyHorzPos
   bcc LF397                        ; don't fire if enemy behind space jockey
   sta enemyMissileHoriz            ; set enemy's missile horizontal position
   lda enemyVerticalPos,x           ; get enemy's vertical position
   sbc #ENEMY_MISSILE_OFFSET
   ora #$01
   sta enemyMissileVert             ; set the enemy missile vertical position
   dec enemyFiring
LF397:
   lda gameSelection                ; get the game selection
   and #OPTION_PLAYER_COLLISIONS    ; see if player collisions are checked
                                    ; for this game variation
   beq .checkEnemyShotPlayer
   lda CXPPMM                       ; read the player collision register
   bmi LF3A6
.checkEnemyShotPlayer
   lda CXP1FB
   asl
   bpl DetermineHighScore
LF3A6:
   lda spaceJockeyHit
   bmi DetermineHighScore
   dec spaceJockeyHit
   sta enemyFiring
   sta spaceJockeyDeathSound
   lda #$FF
   sta enemyMissileVert
   
DetermineHighScore
   ldx #-1
.highScoreLoop
   inx
   cpx #$03
   beq ResetHighScore               ; branch if reached end of score values

   lda playerScore,x                ; get the score value
   cmp highScore,x                  ; compare it to the current high score
   bcc BCD2DigitPtrs                ; if less then no new high score
   beq .highScoreLoop               ; if equal keep checking other digits
;
; the player achieved a high score!
;
ResetHighScore SUBROUTINE
   ldx #2
.highScoreLoop
   lda playerScore,x                ; get the player's score value
   sta highScore,x                  ; move it to the high score value
   dex
   bpl .highScoreLoop
       
BCD2DigitPtrs
   ldx #10
   ldy #0
   lda showHighScore
   bpl .bcd2DigitLoop
   ldy #highScore-playerScore       ; set y to have offset to the high score
       
.bcd2DigitLoop
   lda playerScore,y                ; get the value to display
   and #$F0                         ; mask the lower nybbles
   lsr                              ; divide the value by 2
   adc #<NumberFonts                ; add to get the digit offset to display
   sta digitPointer,x
   lda #>NumberFonts
   sta digitPointer+1,x
   dex
   dex
   lda playerScore,y                ; get the value to display
   and #$0F                         ; mask the upper nybbles
   asl                              ; multiply the value by 8
   asl
   asl
   adc #<NumberFonts                ; add to get the difigt offset to display
   sta digitPointer,x
   lda #>NumberFonts
   sta digitPointer+1,x
   iny                              ; next digit
   dex
   dex
   bpl .bcd2DigitLoop
   
   ldx #8
   ldy #<Blank
.suppressZeroLoop
   lda digitPointer+2,x
   cmp #<zero
   bne .clearCollisions
   sty digitPointer+2,x
   dex
   dex
   bpl .suppressZeroLoop
.clearCollisions
   lda #$FF
   sta CXCLR
       
.vblankWait
   ldx INTIM
   bne .vblankWait

DisplayKernel SUBROUTINE       
   stx WSYNC
;--------------------------------------
   stx VBLANK                 ; 3
   lda scoreColor             ; 3
   sta playerColors           ; 3
   ldy #NUMBER_HEIGHT-1       ; 2
   jsr SixCharacterDisplay    ; 6
;--------------------------------------   
   ldx #$01                   ; 2 = @07
   lda spaceJockeyHorzPos     ; 3
   jsr HorizPositionObject    ; 6
;--------------------------------------
   ldx #$03                   ; 3 = @13
   lda spaceJockeyMissileHoriz; 3
   jsr HorizPositionObject    ; 6
;--------------------------------------
   inx                        ; 2 = @12
   lda enemyMissileHoriz      ; 3
   jsr HorizPositionObject    ; 6
;--------------------------------------
   sta WSYNC
;--------------------------------------
   sta HMOVE                  ; 3
   sta WSYNC
;--------------------------------------
   sta HMCLR                  ; 3
   lda #DOUBLE_SIZE           ; 2
   sta NUSIZ1                 ; 3
   lda #$0E                   ; 2
   sta COLUPF                 ; 3
   ldx #ONE_COPY              ; 2
   stx NUSIZ0                 ; 3
   stx WSYNC
;--------------------------------------
   stx CTRLPF                 ; 3 = @03
   lda #NUMBER_OF_GROUPS      ; 2
   sta kernelZone             ; 3
   lda #KERNEL_HEIGHT         ; 2
   sta scanline               ; 3
.newKernelZone
   lda kernelZone             ; 3         get the current kernel zone
   beq .jumpToMountainKernel  ; 2³        jump to mountain kernel if 0
   tay                        ; 2 = @20   y = kernelZone
   lda scanline               ; 3
   and #$FE                   ; 2
   cmp spaceJockeyMissileVert ; 3
   php                        ; 3
   cmp spaceJockeyVertPos     ; 3
   bcs PositionEnemy          ; 2³
   lda spaceJockeyColors,x    ; 4 = @40   get the space jockey colors
   sta playerColors           ; 3         store them here for later use
   lda spaceJockeyGraphics,x  ; 4         read the space jockey graphics
   beq .storeSpaceJockeyGraph ; 2³        skip the index increment if reached
   inx                        ; 2 = @51   the end of the graphic data
.storeSpaceJockeyGraph
   sta tempGRP0Graphic        ; 3

PositionEnemy
   lda enemyHorizPos-1,y      ; 4
   sta WSYNC
;--------------------------------------
   sec                        ; 2
.coarseMoveEnemy
   sbc #15                    ; 2
   bcs .coarseMoveEnemy       ; 2³
   eor #$0F                   ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   nop                        ; 2
   adc #HMOVE_R7              ; 2
   sta RESP0                  ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMP0                   ; 3 = @03   set fine horizontal motion of enemy
   lda tempGRP0Graphic        ; 3         get space jockey graphic for scanline
   sta GRP1                   ; 3 = @09   draw space jockey
   lda playerColors           ; 3
   sta COLUP1                 ; 3 = @15
   pla                        ; 4
   sta ENAM1                  ; 3 = @22   enable/disable space jockey missile
   ldy kernelZone             ; 3
   lda enemyLSB-1,y           ; 4
   sta enemyGraphicPointer    ; 3         set the graphic pointer
   lda enemyColorsLSB-1,y     ; 4         and color pointer for the enemy
   sta enemyColorPointer      ; 3
   lda KernelZoneValues-1,y   ; 4         get the value to determine when
   sta kernelZoneEnd          ; 3         kernel zone is done
   sta WSYNC                  ; 3 = @49
;--------------------------------------
   sta HMOVE                  ; 3 = @03
   lda scanline               ; 3         get the scan line
   sec                        ; 2         reduce the number by 3 because
   sbc #$03                   ; 2         missed 3 lines of subtraction
   sta scanline               ; 3
   lda enemyVerticalPos-1,y   ; 4
   sta enemyScanline          ; 3
   ldy #0                     ; 2
   dec kernelZone             ; 5
   bpl .spaceJockeyScanline   ; 2³
.jumpToMountainKernel
   jmp MountainKernel         ; 3
.kernelZoneLoop
   dec scanline               ; 5         reduce scan line count
   lda scanline               ; 3
   cmp kernelZoneEnd          ; 3         see if we reached end of kernel zone
   beq .newKernelZone         ; 2³
   lsr                        ; 2
   bcc .spaceJockeyScanline   ; 2³        space jockey updated on even lines
   lda enemyMissileVert       ; 3
   cmp scanline               ; 3
   php                        ; 3
   pla                        ; 4
   sta ENABL                  ; 3         enable/disable enemy missile
   lda enemyScanline          ; 3
   cmp scanline               ; 3
   bcc .clearEnemyGraphics    ; 2³
   lda (enemyColorPointer),y  ; 5         get the enemy colors
   sta playerColors           ; 3         save the value for later
   lda (enemyGraphicPointer),y; 5         get the enemy graphics
   beq .drawEnemyGraphic      ; 2³        skip index increment if zero
   iny                        ; 2         increment enemy index
   bne .drawEnemyGraphic      ; 3         unconditional branch
.clearEnemyGraphics
   lda #0                     ; 2         clear enemy next scan line
.drawEnemyGraphic
   sta WSYNC                  ; 3
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda playerColors           ; 3
   sta COLUP0                 ; 3 = @09
   jmp .kernelZoneLoop        ; 3
   
.spaceJockeyScanline
   lda spaceJockeyMissileVert ; 3 = @33
   cmp scanline               ; 3
   php                        ; 3
   pla                        ; 4
   sta ENAM1                  ; 3 = @46   enable/disable space jockey missile
   lda scanline               ; 3
   cmp spaceJockeyVertPos     ; 3
   bcs .spaceJockeyOutOfRange ; 2³
   lda spaceJockeyColors,x    ; 4         get the space jockey colors
   sta playerColors           ; 3         save the value for later
   lda spaceJockeyGraphics,x  ; 4         get the space jockey graphics
   beq .drawSpaceJockey       ; 2³        skip index increment if zero
   inx                        ; 2         increment space jockey index
   bne .drawSpaceJockey       ; 3         unconditional branch
.spaceJockeyOutOfRange
   lda #$BC                   ; 2         set the space jockey color variable
   sta playerColors           ; 3         this was missed in PAL conversion
   lda #0                     ; 2         clear space jockey next scan line
.drawSpaceJockey
   sta WSYNC                  ; 3
;--------------------------------------
   sta GRP1                   ; 3 = @03
   lda playerColors           ; 3
   sta COLUP1                 ; 3 = @09
   jmp .kernelZoneLoop        ; 3
       
KernelZoneValues
   .byte 6,51,101
   
MountainKernel SUBROUTINE
   lda playfieldColor         ; 3 = @35
   sta COLUPF                 ; 3 = @38
   ldx #0                     ; 2
.mountainScanline
   lda pf0Data,x              ; 4
   sta WSYNC                  ; 3 = @47
;--------------------------------------
   sta PF0                    ; 3 = @03
   lda pf1Data,x              ; 4
   sta PF1                    ; 3 = @10
   lda pf2Data,x              ; 4
   sta PF2                    ; 3 = @17
   inx                        ; 2
.mountainZoneLoop
   dec scanline               ; 5         reduce scan line count
   lda scanline               ; 3
   beq LivesKernel            ; 2²        do lives kernel if done
   lsr                        ; 2
   bcc .mountainScanline      ; 2²        mountain updated on even scan line
   lda enemyScanline          ; 3
   cmp scanline               ; 3
   bcc .clearEnemyGraphics    ; 2³
   lda (enemyColorPointer),y  ; 5 = @46   get the enemy colors
   sta playerColors           ; 3         save the value for later
   lda (enemyGraphicPointer),y; 5         get the enemy graphics
   beq .drawEnemyGraphic      ; 2³        skip index increment if zero
   iny                        ; 2 = @58   increment enemy index
   bne .drawEnemyGraphic      ; 3         unconditional branch
.clearEnemyGraphics
   lda #0                     ; 2 = @62   clear enemy next scan line
.drawEnemyGraphic
   sta WSYNC                  ; 3
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda playerColors           ; 3
   sta COLUP0                 ; 3 = @09
   jmp .mountainZoneLoop      ; 3
;
; game kernel is done--draw the lives indicators or the game logo
;
LivesKernel SUBROUTINE
   sta WSYNC
;--------------------------------------
   ldx playfieldColor         ; 3
   stx COLUBK                 ; 3 = @06
   sta PF0                    ; 3 = @09
   sta PF1                    ; 3 = @12
   sta PF2                    ; 3 = @15
   ldx #$0A                   ; 2
   lda gameState              ; 3
   bpl DrawGameLogo           ; 2³           game is over -- draw the logo
   ldy numberOfLives          ; 3 = @25
livesIndicatorLoop
   lda #<LivesIndicator       ; 2
   dey                        ; 2
   bpl .storeIndicatorIcon    ; 2³           draw the indicator icon until
   lda #<Blank                ; 2            y or lives = 0
   
.storeIndicatorIcon
   sta digitPointer,x         ; 4
   dex                        ; 2
   dex                        ; 2
   bpl livesIndicatorLoop     ; 2³
   bmi .drawIt                ; 3
DrawGameLogo
   lda #<SpaceJockeyLogo      ; 2
   clc                        ; 2
.drawGameLogoLoop:
   sta digitPointer,x         ; 4
   adc #LOGO_HEIGHT           ; 2
   dex                        ; 2
   dex                        ; 2
   bpl .drawGameLogoLoop      ; 2³
   
.drawIt

   IF COMPILE_VERSION = PAL
   
   sta WSYNC
   
   ENDIF
   
   ldy livesColor             ; 3
   sty playerColors           ; 3
   ldx #0                     ; 2
   ldy #LOGO_HEIGHT-1         ; 2
   jsr SixCharacterDisplay    ; 6

Overscan
;
; loop until overscan period is over and jump back to the main loop to start a
; new frame
;
   ldx #OVERSCAN_LINES
.overscanLoop
   sta WSYNC
   dex
   bne .overscanLoop
       
   jmp MainLoop

FindKernelZone
   ldx #-1
.kernelZoneLoop
   inx
   sec
   sbc #KERNEL_ZONE_HEIGHT
   bpl .kernelZoneLoop
   rts

HorizPositionObject SUBROUTINE
   sta WSYNC                  ; 3
   sec                        ; 2
.coarseMoveLoop
   sbc #15                    ; 2
   bcs .coarseMoveLoop        ; 2³
   eor #$0F                   ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   asl                        ; 2
   adc #HMOVE_R7              ; 2
   sta RESP0,x                ; 4
   sta WSYNC
;--------------------------------------
   sta HMP0,x                 ; 4
   rts                        ; 6

SixCharacterDisplay
   stx GRP0                   ; 3
   stx GRP1                   ; 3
   stx WSYNC
;--------------------------------------
   lda #59                    ; 2
   jsr HorizPositionObject    ; 6
   lda #67                    ; 2
   inx                        ; 2
   jsr HorizPositionObject    ; 6
   stx VDELP0                 ; 3
   stx VDELP1                 ; 3
   ldx #THREE_COPIES          ; 2
   stx NUSIZ0                 ; 3
   stx NUSIZ1                 ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   sta HMOVE                  ; 3
   lda playerColors           ; 3
   sta COLUP0                 ; 3 = @9
   sta COLUP1                 ; 3 = @12
.drawGraphicsLoop
   lda (digitPointer),y       ; 5
   sta tempCharHolder         ; 3
   sta WSYNC                  ; 3
;--------------------------------------
   lda (digitPointer+10),y    ; 5
   sta GRP0                   ; 3 = @8
   lda (digitPointer+8),y     ; 5
   sta GRP1                   ; 3 = @16
   lda (digitPointer+6),y     ; 5
   sta GRP0                   ; 3 = @24
   lda (digitPointer+4),y     ; 5
   tax                        ; 2
   lda (digitPointer+2),y     ; 5
   sty loopCount              ; 3
   ldy tempCharHolder         ; 3
   stx GRP1                   ; 3 = @45
   sta GRP0                   ; 3 = @48
   sty GRP1                   ; 3 = @51
   sty GRP0                   ; 3 = @54
   ldy loopCount              ; 3
   dey                        ; 2
   bpl .drawGraphicsLoop      ; 2³
   lda #$00                   ; 2
   sta VDELP0                 ; 3 = @66
   sta VDELP1                 ; 3 = @69
   sta GRP0                   ; 3 = @72
   sta GRP1                   ; 3 = @75
   rts                        ; 6

InitializeGame
   ldx #39
InitLoop
   lda InitTable,x
   sta spaceJockeyColors,x
   dex
   bpl InitLoop
   rts

IncrementScore SUBROUTINE
   ldy objectIds,x                  ; get the object id
   lda ScoreTable,y                 ; read score value based on the object id
   sed                              ; set decimal mode
   cmp #$90                         ; if greater than $90 then carry is set
       
   ldy playerScore+1                ; save the digit for later
   ldx #$02
.incrementScoreLoop
   adc playerScore,x                ; increase the score
   sta playerScore,x
   lda #$00
   dex
   bpl .incrementScoreLoop
   cld                              ; clear decimal mode
   tya
   eor playerScore+1
   and #$F0
   beq .leaveRoutine
;
; check for bonus life
;
   ldy numberOfLives                ; get the number of lives
   iny                              ; increase the life count
   cpy #MAX_LIVES+1                 ; if number of lives is greater than the
   bcs .leaveRoutine                ; max allowed then leave the routine
   sty numberOfLives                ; set the number of lives
.leaveRoutine
   rts

EnemyAnimationTable0
   .byte <Balloon,<JetPlane,<Helicopter0
   .byte <PropPlane0,<House,<Tree,<Tank0,<Tank0
       
EnemyAnimationTable1
   .byte <Balloon,<JetPlane,<Helicopter1
   .byte <PropPlane1,<House,<Tree,<Tank1,<Tank1
       
EnemyColorTable
   .byte <BalloonColor,<JetPlaneColor,<HelicopterColor,<PropPlaneColor
   .byte <HouseColor,<TreeColor,<TankColor,<TankColor
   
ExplosionAnimationTable
   .byte <Explosion1,<Explosion2,<Explosion3,<JetPlane-1

SpaceJockeyDeathAnimTable
   .byte <SpaceJockeyDeath1,<SpaceJockeyDeath2
   .byte <SpaceJockeyDeath3,<Blank
;
; These are the attributes assigned to each obstacle.;
; D7 is used to determine if the enemy has been shot.
; D2 and D0 determines if the enemy has the ability to shoot at the player.
; D0 = 0 determines if the obstacle has reached the left side of the screen
;
EnemyAttibutesTable
   .byte %00001011                  ; balloon
   .byte %00001111                  ; jet plane
   .byte %00001111                  ; helicopter
   .byte %00001111                  ; prop plane
   .byte %00000001                  ; house
   .byte %00000001                  ; tree
   .byte %00000101                  ; tank 0
   .byte %00000111                  ; tank 1
       
SpaceJockeyDeathSprites
SpaceJockeyDeath1
   .byte $18 ; |...XX...|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
SpaceJockeyDeath2
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   .byte $18 ; |...XX...|
   .byte $24 ; |..X..X..|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
SpaceJockeyDeath3       
   .byte $24 ; |..X..X..|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   
   REPEAT (5 - COMPILE_VERSION * 2)
      .byte $00 ; |........|
   REPEND
       
SpaceJockeyLogo
   .byte $E8 ; |XXX.X...|
   .byte $28 ; |..X.X...|
   .byte $EE ; |XXX.XXX.|
   .byte $8A ; |X...X.X.|
   .byte $FE ; |XXXXXXX.|
   
   .byte $B7 ; |X.XX.XXX|
   .byte $B5 ; |X.XX.X.X|
   .byte $F4 ; |XXXX.X..|
   .byte $B5 ; |X.XX.X.X|
   .byte $F7 ; |XXXX.XXX|
   
   .byte $73 ; |.XXX..XX|
   .byte $41 ; |.X.....X|
   .byte $71 ; |.XXX...X|
   .byte $41 ; |.X.....X|
   .byte $71 ; |.XXX...X|
   
   .byte $BD ; |X.XXXX.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $B5 ; |X.XX.X.X|
   .byte $BD ; |X.XXXX.X|
   
   .byte $D6 ; |XX.X.XX.|
   .byte $56 ; |.X.X.XX.|
   .byte $1C ; |...XXX..|
   .byte $5A ; |.X.XX.X.|
   .byte $DA ; |XX.XX.X.|
   
   .byte $E6 ; |XXX..XX.|
   .byte $86 ; |X....XX.|
   .byte $ED ; |XXX.XX.X|
   .byte $8D ; |X...XX.X|
   .byte $ED ; |XXX.XX.X|
       
NumberFonts
zero
   .byte $3C ; |..XXXX..|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $3C ; |..XXXX..|
one   
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $38 ; |..XXX...|
two   
   .byte $7E ; |.XXXXXX.|
   .byte $46 ; |.X...XX.|
   .byte $40 ; |.X......|
   .byte $3C ; |..XXXX..|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $3C ; |..XXXX..|
three   
   .byte $3E ; |..XXXXX.|
   .byte $4E ; |.X..XXX.|
   .byte $0E ; |....XXX.|
   .byte $1C ; |...XXX..|
   .byte $1C ; |...XXX..|
   .byte $0E ; |....XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $3C ; |..XXXX..|
four   
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $7E ; |.XXXXXX.|
   .byte $4C ; |.X..XX..|
   .byte $4C ; |.X..XX..|
   .byte $4C ; |.X..XX..|
   .byte $4C ; |.X..XX..|
   .byte $4C ; |.X..XX..|
five   
   .byte $7C ; |.XXXXX..|
   .byte $4E ; |.X  XXX.|
   .byte $0E ; |....XXX.|
   .byte $0E ; |....XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $40 ; |.X......|
   .byte $40 ; |.X......|
   .byte $7E ; |.XXXXXX.|
six   
   .byte $3C ; |..XXXX..|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $7C ; |.XXXXX..|
   .byte $40 ; |.X......|
   .byte $42 ; |.X....X.|
   .byte $3C ; |..XXXX..|
seven   
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $0C ; |....XX..|
   .byte $0C ; |....XX..|
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $46 ; |.X...XX.|
   .byte $7E ; |.XXXXXX.|
eight   
   .byte $3C ; |..XXXX..|
   .byte $4E ; |.X..XXX.|
   .byte $4E ; |.X..XXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $3C ; |..XXXX..|
nine   
   .byte $3C ; |..XXXX..|
   .byte $42 ; |.X....X.|
   .byte $02 ; |......X.|
   .byte $3E ; |..XXXXX.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $72 ; |.XXX..X.|
   .byte $3C ; |..XXXX..|
Blank
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
   .byte $00 ; |........|
LivesIndicator
   .byte $30 ; |..XX....|
   .byte $78 ; |.XXXX...|
   .byte $B4 ; |X.XX.X..|
   .byte $78 ; |.XXXX...|
   .byte $30 ; |..XX....|
   
EnemyVerticalCeiling
   .byte 52,103,154
   
EnemyVerticalFloor
   .byte 26,77,127
       
ScoreTable
   .byte BALLOON_SCORE,JET_PLANE_SCORE,HELICOPTER_SCORE
   .byte PROP_PLANE_SCORE,HOUSE_SCORE,TREE_SCORE,TANK_SCORE,TANK_SCORE
       
InitTable
;
; Space Jockey Colors
;
   IF COMPILE_VERSION = NTSC
   
      .byte GREEN+12,GREEN+8,GREEN+4,GREEN+8
      .byte GREEN+12,BRICK_RED+14,GREEN+12
      
   ELSE
   
      .byte GREEN+12,GREEN+10,GREEN+8,GREEN+10
      .byte GREEN+12,BRICK_RED+14,GREEN+12
      
   ENDIF
   
   .byte BLUE+10                    ; score color
   .byte LT_BROWN                   ; playfieldColor
   .byte BLACK                      ; background color
   .byte BLUE+14                    ; livesColor
;
; Space Jockey graphics
;
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $99 ; |X..XX..X|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|

   .byte SPACE_JOCKEY_YMIN          ; Space Jockey start vertical position
   .byte SPACE_JOCKEY_XMIN          ; Space Jockey start horizontal position
;
; initial playfield data
;
   .byte $8F,$DF,$FF                ; PF0
   .byte $81,$C3,$E7                ; PF1
   .byte $81,$C3,$E7                ; PF2
       
   .byte 48,80,133                  ; initial enemy vertical positions
   .byte <JetPlane-1,<JetPlane-1    ; these last values just point to a zero
   .byte <JetPlane-1                ; byte that resides on page $F7 so no
   .word JetPlane-1, JetPlane-1     ; sprite is displayed
   .byte STARTING_LIVES
   
EnemySprites
Balloon
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $5A ; |.X.XX.X.|
   .byte $5A ; |.X.XX.X.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $00 ; |........|
JetPlane
   .byte $01 ; |.......X|
   .byte $03 ; |......XX|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $30 ; |..XX....|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Helicopter0
   .byte $1F ; |...XXXXX|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $F9 ; |XXXXX..X|
   .byte $FF ; |XXXXXXXX|
   .byte $F8 ; |XXXXX...|
   .byte $70 ; |.XXX....|
   .byte $28 ; |..X.X...|
   .byte $FC ; |XXXXXX..|
   .byte $00 ; |........|
Helicopter1
   .byte $F0 ; |XXXX....|
   .byte $10 ; |...X....|
   .byte $70 ; |.XXX....|
   .byte $F8 ; |XXXXX...|
   .byte $FF ; |XXXXXXXX|
   .byte $F9 ; |XXXXX..X|
   .byte $70 ; |.XXX....|
   .byte $28 ; |..X.X...|
   .byte $FC ; |XXXXXX..|
   .byte $00 ; |........|
PropPlane0
   .byte $99 ; |X..XX..X|
   .byte $BD ; |X.XXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $3F ; |..XXXXXX|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
PropPlane1
   .byte $19 ; |...XX..X|
   .byte $3D ; |..XXXX.X|
   .byte $FF ; |XXXXXXXX|
   .byte $BF ; |X.XXXXXX|
   .byte $98 ; |X..XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
House
   .byte $19 ; |...XX..X|
   .byte $3D ; |..XXXX.X|
   .byte $7F ; |.XXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $BD ; |X.XXXX.X|
   .byte $A5 ; |X.X..X.X|
   .byte $E7 ; |XXX..XXX|
   .byte $E7 ; |XXX..XXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $00 ; |........|
Tree
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $FF ; |XXXXXXXX|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $18 ; |...XX...|
   .byte $58 ; |.X.XX...|
   .byte $38 ; |..XXX...|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $00 ; |........|
Tank0
   .byte $06 ; |.....XX.|
   .byte $06 ; |.....XX.|
   .byte $FA ; |XXXXX.X.|
   .byte $1A ; |...XX.X.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $FE ; |XXXXXXX.|
   .byte $7F ; |.XXXXXXX|
   .byte $54 ; |.X.X.X..|
   .byte $00 ; |........|
Tank1
   .byte $03 ; |......XX|
   .byte $03 ; |......XX|
   .byte $FA ; |XXXXX.X.|
   .byte $1A ; |...XX.X.|
   .byte $1E ; |...XXXX.|
   .byte $1E ; |...XXXX.|
   .byte $54 ; |.X.X.X..|
   .byte $7F ; |.XXXXXXX|
   .byte $FE ; |XXXXXXX.|
   .byte $2A ; |..X.X.X.|
   .byte $00 ; |........|
Explosion1
   .byte $81 ; |X......X|
   .byte $66 ; |.XX..XX.|
   .byte $7E ; |.XXXXXX.|
   .byte $3C ; |..XXXX..|
   .byte $3C ; |..XXXX..|
   .byte $7E ; |.XXXXXX.|
   .byte $66 ; |.XX..XX.|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
Explosion2
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
   .byte $42 ; |.X....X.|
   .byte $18 ; |...XX...|
   .byte $18 ; |...XX...|
   .byte $42 ; |.X....X.|
   .byte $24 ; |..X..X..|
   .byte $81 ; |X......X|
   .byte $00 ; |........|
   
EnemyColors
BalloonColor
   .byte BLUE+2,BLUE+4,BLUE+6,BLUE+8,BLUE+6,BLUE+4
   .byte BLUE+2,GREEN_BROWN+4,GREEN_BROWN+4,YELLOW+10,YELLOW+10
JetPlaneColor
   .byte BRIGHT_GREEN+10,BRIGHT_GREEN+10
   .byte BLACK+8,BLACK+8,GREEN+6,GREEN+6
HelicopterColor
   .byte WHITE-3,BLACK+6,RED+4,RED+8,RED+12
   .byte RED+8,RED+4,BLACK+6,BLACK+6
PropPlaneColor
   .byte PURPLE+8,PURPLE+6,PURPLE+4
   .byte PURPLE+8,PURPLE+15,PURPLE+15
HouseColor
   .byte BLACK+6,BLACK+6,BLACK+6,BLACK+6
   .byte BRICK_RED+4,BRICK_RED+4,BRICK_RED+4,BRICK_RED+4,BRICK_RED+4
   .byte LT_BROWN,LT_BROWN,LT_BROWN
TreeColor
   .byte BRIGHT_GREEN+4,BRIGHT_GREEN+4,BRIGHT_GREEN+8,BRIGHT_GREEN+8
   .byte BRIGHT_GREEN+12,BRIGHT_GREEN+12,BRIGHT_GREEN+8
   .byte BROWN+8,BROWN+8,BROWN+8,BROWN+6,BROWN+6
TankColor
   .byte BLUE+8,BLUE+8,BLUE+8,BLUE+8
   .byte BLACK+12,BLACK+12
   .byte BLACK+6,BLACK+6,BLACK+6,BLACK+6
ExplosionColor
   .byte WHITE,WHITE,WHITE,WHITE
   .byte WHITE,WHITE,WHITE,WHITE
   
Explosion3
   .byte $24 ; |..X..X..|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $81 ; |X......X|
   .byte $42 ; |.X....X.|
   .byte $81 ; |X......X|
   .byte $24 ; |..X..X..|
       
   org ROM_BASE_ADDRESS + 2048 - 4  ; 2K ROM
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector


