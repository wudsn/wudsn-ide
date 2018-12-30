   LIST OFF
; ***  S U R R O U N D  ***
; Copyright 1977 Atari, Inc.
; Designer: Alan Miller

; Analyzed, labeled and commented
;  by Thomas Jentzsch (JTZ)
; Last Update: Aug 25, 2001 (v0.1)
;  by Dennis Debro
; Last Update: Sept 10, 2004

   processor 6502
      
;
; NOTE: You must compile this with vcs.h version 105 or greater.
;
TIA_BASE_READ_ADDRESS = $30         ; set the read address base so this runs on
                                    ; the real VCS and compiles to the exact
                                    ; ROM image

   include ..\..\..\vcs.h

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

; SWCHA joystick bits:
PLAYER0_JOYSTICK_MASK   = $F0
PLAYER1_JOYSTICK_MASK   = $0F

MOVE_RIGHT        = %10000000
MOVE_LEFT         = %01000000
MOVE_DOWN         = %00100000
MOVE_UP           = %00010000
NO_MOVE           = %11111111

PLAYER0_NO_MOVE   = NO_MOVE & PLAYER0_JOYSTICK_MASK
PLAYER1_NO_MOVE   = NO_MOVE & PLAYER1_JOYSTICK_MASK

; mask for SWCHB
BW_MASK           = %1000         ; black and white bit
SELECT_MASK       = %10
RESET_MASK        = %01

;============================================================================
; U S E R - C O N S T A N T S
;============================================================================

ROM_BASE_ADDRESS     = $F000

   IF COMPILE_VERSION = NTSC

H_KERNEL             = 200
H_KERNEL_SECTION     = 9
KERNEL_SKIPLINES     = 3
BOTTOM_BORDER_START  = 256-H_KERNEL+3
KERNEL_END           = 232

   ELSE

H_KERNEL             = 239
H_KERNEL_SECTION     = 10
KERNEL_SKIPLINES     = 14
BOTTOM_BORDER_START  = 256-H_KERNEL+2
KERNEL_END           = 213

   ENDIF

H_DIGIT              = 5
VBLANK_TIME          = 40

NUM_PLAYERS          = 2
NUM_ROWS             = 20           ; number of playfield rows (blocks)

XMIN                 = 0
XMAX                 = 40
YMIN                 = 0
YMAX                 = 20

INIT_AMATEUR_MIN_BOUNDARY  = 3
INIT_PRO_MIN_BOUNDARY      = 6

PLAYER_START_Y       = 10
PLAYER1_START_X      = 10
PLAYER2_START_X      = 30

MAX_SCORE            = $10          ; BCD

SELECT_DELAY         = 63
FRAME_DELAY          = 16           ; frame delay in gameSpeed upper nybbles

MAX_GAME_SELECTION   = 14

;game state values
SYSTEM_POWERUP       = %00010000
GAME_RUNNING         = %11111111

;player state flags
PLAYER1_COLL_MASK    = %01000000
PLAYER2_COLL_MASK    = %10000000
PLAYER_COLL_MASK     = PLAYER1_COLL_MASK | PLAYER2_COLL_MASK

; game variation flags
NOGRAFFITI      = %10000000
SPEEDUP         = %01000000
NOGRAFFITI2     = %00100000     ; always same as NOGRAFFITI
SINGLEPLAYER    = %00010000
WRAPAROUND      = %00001000
ERASE           = %00000100
DIAGONAL        = %00000001

;============================================================================
; Z P - V A R I A B L E S
;============================================================================
   SEG.U variables
   org $80

playfieldGraphics          ds 100
;--------------------------------------
pf0Graphics                = playfieldGraphics
leftPF1Graphics            = playfieldGraphics+NUM_ROWS
leftPF2Graphics            = leftPF1Graphics+NUM_ROWS
rightPF1Graphics           = leftPF2Graphics+NUM_ROWS
rightPF2Graphics           = rightPF1Graphics+NUM_ROWS
frameCount                 ds 1
nextKernelSection          ds 1
;--------------------------------------
playerJoystickValues       = nextKernelSection
;--------------------------------------
playerMovingHorizontal     = playerJoystickValues
;--------------------------------------
playfieldRAMPointer0       = playerMovingHorizontal
workingJoystickValue       ds 1
;--------------------------------------
minBoundaryLookup          = workingJoystickValue
tempPlayfieldPattern       ds 1
;--------------------------------------
hueMask                    = tempPlayfieldPattern
;--------------------------------------
playfieldRAMPointer1       = tempPlayfieldPattern
;--------------------------------------
combinedMotionValues       = playfieldRAMPointer1
;--------------------------------------
scoreGraphic1              = combinedMotionValues
tempJoystickValues         ds 1
;--------------------------------------
scoreGraphic2              = tempJoystickValues
;--------------------------------------
colorXOR                   = scoreGraphic2
playfieldLowerBoundary     ds 1
;--------------------------------------
playfieldLeftBoundary      = playfieldLowerBoundary
;--------------------------------------
playfieldRightBoundary     = playfieldLeftBoundary
computerMotion             ds 1
;--------------------------------------
computerJoystickValue      = computerMotion

playfieldUpperBoundary     ds 1
;--------------------------------------
playfieldMinBoundary       = playfieldUpperBoundary
gameSpeed                  ds 1
playerVertPos              ds 2
;--------------------------------------
player1VertPos             = playerVertPos
player2VertPos             = player1VertPos+1
playerHorizPos             ds 2
;--------------------------------------
player1HorizPos            = playerHorizPos
player2HorizPos            = player1HorizPos+1
gameVariation              ds 1
playerMotion               ds 2
;--------------------------------------
player1Motion              = playerMotion
player2Motion              = player1Motion+1
colorCycleTimer            ds 1
selectDebounce             ds 1
playerScores               ds 2
;--------------------------------------
player1Score               = playerScores
player2Score               = playerScores+1
gameState                  ds 1
gameSelection              ds 1
unused                     ds 1
playerState                ds 1
joystickValues             ds 1
randomMotionSeed           ds 1

;============================================================================
; R O M - C O D E
;============================================================================

   SEG Bank0
   org ROM_BASE_ADDRESS

DisplayKernel SUBROUTINE
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; end last scan line
   sta VBLANK                       ; enable TIA (D1 = 0)
   lda #%00000010                   ; set playfield to SCORE mode (i.e.
   sta CTRLPF                       ; player colors same as score)
   ldx #KERNEL_SKIPLINES
.skipKernelLines
   sta WSYNC
   sta HMCLR
   dex
   bne .skipKernelLines
   ldx #5
   lda #0
   sta scoreGraphic1
   sta scoreGraphic2
ScoreKernel
   sta WSYNC
;--------------------------------------
   lda scoreGraphic1          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @06
   lda player1Score           ; 3         get player1's score
   and #$F0                   ; 2         mask lower nybbles
   lsr                        ; 2         move upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   lda DigitOfsTab,y          ; 4
   clc                        ; 2
   adc DigitOfs2Tab,x         ; 4
   tay                        ; 2
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic1          ; 3         save it in the score graphic
   lda scoreGraphic2          ; 3         get the score graphic for display
   sta PF1                    ; 3 = @48
   lda player1Score           ; 3         get player1's score
   and #$0F                   ; 2         mask upper nybbles
   tay                        ; 2
   lda DigitOfsTab,y          ; 4
   clc                        ; 2
   adc DigitOfs2Tab,x         ; 4
   sta WSYNC
;--------------------------------------
   tay                        ; 2
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2         mask the upper nybble
   ora scoreGraphic1          ; 3         or with score graphic to get LSB
   sta scoreGraphic1          ; 3         value
   sta PF1                    ; 3 = @17
   lda player2Score           ; 3         get player2's score
   and #$F0                   ; 2         mask lower nybbles
   lsr                        ; 2         move upper nybbles to lower nybbles
   lsr                        ; 2
   lsr                        ; 2
   lsr                        ; 2
   tay                        ; 2
   lda DigitOfsTab,y          ; 4
   ldy scoreGraphic2          ; 3
   sty PF1                    ; 3 = @44
   clc                        ; 2
   adc DigitOfs2Tab,x         ; 4
   tay                        ; 2
   lda NumberFonts,y          ; 4         read the number fonts
   and #$F0                   ; 2         mask the lower nybble
   sta scoreGraphic2          ; 3         save it in the score graphic
   lda player2Score           ; 3         get player2's score
   and #$0F                   ; 2         mask upper nybbles
   sta WSYNC
;--------------------------------------
   tay                        ; 2
   lda DigitOfsTab,y          ; 4
   ldy scoreGraphic1          ; 3
   sty PF1                    ; 3 = @12
   clc                        ; 2
   adc DigitOfs2Tab,x         ; 4
   tay                        ; 2
   lda NumberFonts,y          ; 4         read the number fonts
   and #$0F                   ; 2
   and gameState              ; 3
   and gameState              ; 3
   ora scoreGraphic2          ; 3         or with score graphic to get LSB
   sta scoreGraphic2          ; 3         value
   sta PF1                    ; 3 = @41
   dex                        ; 2
   bmi GameKernel             ; 2³
   jmp ScoreKernel            ; 3
       
GameKernel
   sta WSYNC
;--------------------------------------
   lda #0                     ; 2
   sta PF0                    ; 3 = @05   clear the playfield graphics
   sta PF1                    ; 3 = @08
   sta PF2                    ; 3 = @11
   sta CTRLPF                 ; 3 = @14   non-reflective playfield
   ldy #256-H_KERNEL          ; 2
   lda #256-H_KERNEL+2        ; 2
   sta nextKernelSection      ; 3
   ldx #-1                    ; 2
.gameKernelLoop
   cpy #BOTTOM_BORDER_START   ; 2
   bcc .drawBorder            ; 2³+1
   cpy nextKernelSection      ; 3
   bcs .endKernelSection      ; 2³
.kernelSectionLoop
   sta WSYNC
;--------------------------------------
   lda pf0Graphics,x          ; 4         get the PF0 data
   asl                        ; 2         shift the lower nybbles to the upper
   asl                        ; 2         nybbles for the left PF0 values
   asl                        ; 2
   asl                        ; 2
   sta PF0                    ; 3 = @15   display left PF0 pattern
   lda leftPF1Graphics,x      ; 4         get the left PF1 data
   sta PF1                    ; 3 = @22   display left PF1 pattern
   lda leftPF2Graphics,x      ; 4
   sta PF2                    ; 3 = @29
   lda pf0Graphics,x          ; 4
   sta PF0                    ; 3 = @36   only upper nybbles used for PF0
   lda rightPF1Graphics,x     ; 4
   sta PF1                    ; 3 = @43
   iny                        ; 2
   lda rightPF2Graphics,x     ; 4
   sta PF2                    ; 3 = @52
   cpy nextKernelSection      ; 3
   bcc .kernelSectionLoop     ; 2³
.endKernelSection
   inx                        ; 2
   lda #$0F                   ; 2
   cpx player1VertPos         ; 3
   beq .drawPlayer1           ; 2³
   lda #0                     ; 2
.drawPlayer1
   sta WSYNC
;--------------------------------------
   sta GRP0                   ; 3 = @03
   lda #$0F                   ; 2
   cpx player2VertPos         ; 3
   beq .drawPlayer2           ; 2³
   lda #0                     ; 2
.drawPlayer2
   sta GRP1                   ; 3 = @15
   lda #0                     ; 2
   sta PF0                    ; 3 = @20
   sta PF1                    ; 3 = @23
   sta PF2                    ; 3 = @26
   tya                        ; 2
   clc                        ; 2
   adc #H_KERNEL_SECTION      ; 2
   sta nextKernelSection      ; 3
.contKernel
   iny                        ; 2
   beq .endGameKernel         ; 2³
   cpy #KERNEL_END            ; 2
   bcc .gameKernelLoop        ; 2³+1
.drawBorder
   lda #$FF                   ; 2
   sta WSYNC
;--------------------------------------
   sta PF0                    ; 3 = @03
   sta PF1                    ; 3 = @06
   sta PF2                    ; 3 = @09
   lda #0                     ; 2
   sta GRP0                   ; 3 = @14
   sta GRP1                   ; 3 = @17
   beq .contKernel            ; 3         unconditional branch
       
.endGameKernel
   lda #0                     ; 2
   sta ENAM0                  ; 3 = @45   disable missle graphics (missiles
   sta ENAM1                  ; 3 = @48   aren't used in this game)
   rts                        ; 6

VerticalSync SUBROUTINE
   lda #42
   sta HMCLR                        ; clear all horizontal motion
   sta WSYNC                        ; end last scan line
   sta VBLANK                       ; disable TIA (D1 = 1)
   sta VSYNC                        ; start vertical sync (D1 = 1)
   sta TIM8T                        ; set vertical sync wait time
   inc frameCount
   inc randomMotionSeed             ; used to help decide computer direction
.waitTime
   lda INTIM
   bne .waitTime
   sta WSYNC                        ; end last scan line
   sta VSYNC                        ; end vertical sync (D1 = 0)
   lda #VBLANK_TIME
   sta TIM64T                       ; set vertical blank wait time
   rts

SinglePlayerGame
   lda #-1
   sta playfieldLowerBoundary
   sta playfieldUpperBoundary
   lda #INIT_PRO_MIN_BOUNDARY
   bit SWCHB                        ; get P0 difficutly setting
   bvs DeterminePlayfieldUpperBoundary
   lda #INIT_AMATEUR_MIN_BOUNDARY
DeterminePlayfieldUpperBoundary
   sta minBoundaryLookup
   lda #$00
   sta playfieldRAMPointer1+1       ; set RAM pointer MSB to read ZP
   ldy player1HorizPos              ; get the computer's horizontal position
   lda PFGraphicsPointerTable,y     ; read the LSB for the playfield graphics
   sta playfieldRAMPointer1
   ldx #MOVE_UP
   stx computerMotion               ; set computer motion to up
   ldx player1HorizPos              ; get the computer's horizontal position
   ldy player1VertPos               ; get the computer's vertical position
.computePFUpperBoundary
   inc playfieldUpperBoundary
   dey                              ; check next upper position
   bmi .foundPFUpperBoundary        ; found limit if vertically out of range
   lda PlayfieldPatternTable,x      ; get the playfield pattern
   and (playfieldRAMPointer1),y     ; and with current playfield value
   beq .computePFUpperBoundary      ; if empty then limit hasn't been found
.foundPFUpperBoundary
   lda minBoundaryLookup            ; get min lookup value
   cmp playfieldUpperBoundary       ; if less than value found then
   bcs DeterminePlayfieldLowerBoundary
   sta playfieldUpperBoundary       ; set it to PF upper boundary
DeterminePlayfieldLowerBoundary
   ldy player1VertPos               ; get the computer's vertical position
   ldx player1HorizPos              ; get the computer's horizontal position
.computePFLowerBoundary
   inc playfieldLowerBoundary
   iny                              ; check next lower position
   cpy #YMAX+1
   bcs .foundPFLowerBoundary        ; found limit if vertically out of range
   lda PlayfieldPatternTable,x      ; get the playfield pattern
   and (playfieldRAMPointer1),y     ; and with current playfield value
   beq .computePFLowerBoundary      ; if empty then limit hasn't been found
.foundPFLowerBoundary
   lda playfieldLowerBoundary       ; get lower boundary
   cmp playfieldUpperBoundary       ; compare with the upper boundary
   bcc DeterminePlayfieldLeftBoundary
   ldx playfieldUpperBoundary       ; if greater use a random value to
   cpx minBoundaryLookup            ; determine motion
   bcc .setComputerMotionToDown
   bit randomMotionSeed
   bvs DeterminePlayfieldLeftBoundary
   cmp minBoundaryLookup
   bcc .setComputerMotionToDown
   lda minBoundaryLookup
.setComputerMotionToDown
   sta playfieldMinBoundary
   ldx #MOVE_DOWN
   stx computerMotion
DeterminePlayfieldLeftBoundary
   ldy player1VertPos               ; get the computer's vertical position
   ldx player1HorizPos              ; get the computer's horizontal position
   lda #-1
   sta playfieldLeftBoundary
.computePFLeftBoundary
   inc playfieldLeftBoundary
   dex                              ; check next left position
   bmi .foundPFLeftBoundary         ; found limit if horizontally out of range
   lda PFGraphicsPointerTable,x     ; read the LSB for the playfield graphics
   sta playfieldRAMPointer1
   lda (playfieldRAMPointer1),y     ; get the current playfield value
   and PlayfieldPatternTable,x      ; and with playfield pattern
   beq .computePFLeftBoundary       ; if empty then limit hasn't been found
.foundPFLeftBoundary
   lda playfieldLeftBoundary        ; get left boundary
   cmp playfieldMinBoundary         ; compare with minimum value
   bcc DeterminePlayfieldRightBoundary
   ldx playfieldMinBoundary         ; if greater use a random value to
   cpx minBoundaryLookup            ; determine motion
   bcc .setComputerMotionToLeft
   bit randomMotionSeed
   bvs DeterminePlayfieldRightBoundary
   cmp minBoundaryLookup
   bcc .setComputerMotionToLeft
   lda minBoundaryLookup
.setComputerMotionToLeft
   sta playfieldMinBoundary
   ldx #MOVE_LEFT
   stx computerMotion
DeterminePlayfieldRightBoundary
   ldy player1VertPos               ; get the computer's vertical position
   ldx player1HorizPos              ; get the computer's horizontal position
   lda #-1
   sta playfieldRightBoundary
.computePFRightBoundary
   inc playfieldRightBoundary
   inx                              ; check next right position
   cpx #XMAX+1                      ; found limit if horizontally out of range
   beq .foundPFRightBoundary
   lda PFGraphicsPointerTable,x     ; read the LSB for the playfield graphics
   sta playfieldRAMPointer1
   lda (playfieldRAMPointer1),y     ; get the current playfield value
   and PlayfieldPatternTable,x      ; and with playfield pattern
   beq .computePFRightBoundary      ; if empty then limit hasn't been found
.foundPFRightBoundary
   lda playfieldRightBoundary       ; get right boundary
   cmp playfieldMinBoundary         ; compare with minimum value
   bcc .setComputerJoystickValue
   ldx playfieldMinBoundary         ; if greater use a random value to
   cpx minBoundaryLookup            ; determine motion
   bcc .setComputerMotionToRight
   bit randomMotionSeed
   bvs .setComputerJoystickValue
   cmp minBoundaryLookup
   bcc .setComputerMotionToRight
   lda minBoundaryLookup            ; not needed as accumulator changes below
.setComputerMotionToRight
   lda #MOVE_RIGHT
   sta computerMotion
.setComputerJoystickValue
   lda computerMotion               ; get computer's motion
   eor #$FF                         ; flip the bits to look like SWCHA
   and #PLAYER0_JOYSTICK_MASK
   sta computerJoystickValue        ; set the computer's joystick value
   lda joystickValues               ; get the joystick values
   and #PLAYER1_JOYSTICK_MASK
   ora computerJoystickValue
   sta joystickValues               ; combine computer joystick value
   jmp DeterminePlayerMovements
       
PerformGameLogic
   lda gameVariation                ; get the current game variation
   and #SINGLEPLAYER                ; mask for the single player option
   cmp #SINGLEPLAYER                ; if this is not a single player game
   bne .performTwoPlayerGameLogic   ; then process for 2 players
   jmp SinglePlayerGame
       
.performTwoPlayerGameLogic
   lda gameVariation                ; get the current game variation
   bpl .readJoystickForGraffiti     ; do graffiti logic if a graffiti game
DeterminePlayerMovements
   lda joystickValues               ; get joystick values (looks like SWCHA)
   eor #$FF                         ; flip the bits
   sta tempJoystickValues           ; save the values
   and #PLAYER0_JOYSTICK_MASK
   sta workingJoystickValue
   lda player2Motion                ; get player2's motion
   lsr                              ; move it to the lower nybbles
   lsr
   lsr
   lsr
   ora player1Motion                ; combine the player motion values
   sta combinedMotionValues         ; save for later
   ldx #NUM_PLAYERS
   bit SWCHB                        ; read the difficulty switches
   bvs .nextPlayerDifficulty
   and #PLAYER0_JOYSTICK_MASK
   cmp #MOVE_UP
   beq .joystickMoved
   cmp #MOVE_DOWN
   beq .joystickMoved
   cmp #MOVE_LEFT
   beq .joystickMoved
   cmp #MOVE_RIGHT
   beq .joystickMoved
.nextPlayerDifficulty
   dex
.checkPlayer2Difficulty
   bit SWCHB                        ; read the difficulty switches
   bmi .nextPlayer
   lda tempJoystickValues           ; get the temporary joystick values
   and #PLAYER1_JOYSTICK_MASK
   sta workingJoystickValue
   lda combinedMotionValues
   and #PLAYER1_JOYSTICK_MASK
   cmp #MOVE_UP>>4
   beq .joystickMoved
   cmp #MOVE_DOWN>>4
   beq .joystickMoved
   cmp #MOVE_LEFT>>4
   beq .joystickMoved
   cmp #MOVE_RIGHT>>4
   bne .nextPlayer
.joystickMoved
   lda combinedMotionValues         ; get the combined motions
   asl
   and workingJoystickValue
   and #%10101010
   eor tempJoystickValues
   sta tempJoystickValues
   lda combinedMotionValues
   lsr
   and workingJoystickValue
   and #%01010101
   eor tempJoystickValues
   sta tempJoystickValues
.nextPlayer
   lda tempJoystickValues
   dex
   bne .checkPlayer2Difficulty
   eor #$FF                         ; flip bits to look like SWCHA values
   jmp CalculateMovements
       
.readJoystickForGraffiti
   lda SWCHA
CalculateMovements
   ldx #0
   sta workingJoystickValue
.calculateMovementLoop
   ldy #0
   sty playerMovingHorizontal       ; clear horizontal movement flag
   asl                              ; player 0 right motion value in carry
   bcs .checkP0LeftMovement
   lda #MOVE_RIGHT
   sta playerMotion,x
   jmp MovePlayerRight
       
.checkP0LeftMovement
   asl                              ; player 0 left motion value in carry
   bcs .checkP0DownMovement
   lda #MOVE_LEFT
   sta playerMotion,x
   jmp MovePlayerLeft
       
.checkP0DownMovement
   asl                              ; player 0 down motion value in carry
   bcs .checkP0UpMovement
   lda #MOVE_DOWN
   sta playerMotion,x
   jmp MovePlayerDown
       
.checkP0UpMovement
   asl                              ; player 0 up motion value in carry
   bcs JoystickNotMoved
   lda #MOVE_UP
   sta playerMotion,x
   jmp MovePlayerUp
       
JoystickNotMoved
   lda gameVariation                ; get the current game variation
   asl                              ; move GRAFFITI mode to carry
   bcs .processOldDirections        ; move based on directions if not GRAFFITI
   jmp .checkNextPlayersDirections
       
.processOldDirections
   lda playerMotion,x               ; get the player's direction
   asl                              ; right motion value in carry
   bcc .checkLeftMovement
   inc playerMovingHorizontal       ; show player moving horizontally
   jmp MovePlayerRight
       
.checkLeftMovement
   asl                              ; left motion value in carry
   bcc .checkDownMovement
   inc playerMovingHorizontal       ; show player moving horizontally
   jmp MovePlayerLeft
       
.checkDownMovement
   asl                              ; down motion value in carry
   bcc .checkUpMovement
   jmp MovePlayerDown
       
.checkUpMovement
   asl                              ; up motion value in carry
   bcc .nextPlayerDirections
   jmp MovePlayerUp
       
.nextPlayerDirections
   jmp .checkNextPlayersDirections

MovePlayerDown
   lda playerVertPos,x              ; get the player's vertical position
   clc
   adc #1                           ; increment vertical position by 1
   sbc #YMAX-1
   bmi .wrapPlayerToTop
   lda #YMIN
   sta playerVertPos,x
   beq .checkNextPlayersDirections  ; unconditional branch
   
.wrapPlayerToTop
   adc #YMAX
   sta playerVertPos,x
   jmp .checkNextPlayersDirections
       
MovePlayerUp
   lda playerVertPos,x              ; get the player's vertical position
   sec
   sbc #1                           ; reduce vertical position by 1
   bpl .setPlayerVerticalPosition
   lda #YMAX-1
.setPlayerVerticalPosition
   sta playerVertPos,x
   jmp .checkNextPlayersDirections
       
CheckToMoveDiagonally
   lda gameVariation                ; get the current game variation
   ror                              ; diagonal flag no in carry
   bcc .checkNextPlayersDirections
   lda #1
   cmp playerMovingHorizontal
   bne .playerNotMovingHoriz
   ldy #0
   lda playerMotion,x               ; get the player's direction
   asl                              ; shift left twice so down bit is in D7
   asl
   jmp .checkDownMovement           ; this will shift down bit into carry
       
.playerNotMovingHoriz
   lda workingJoystickValue
   cpx #1                           ; see if this is player 1 or 2
   bcc .shiftDownBitToCarry
   asl                              ; we are processing player 2 so move
   asl                              ; player2's joystick values to upper
   asl                              ; nybbles
   asl
.shiftDownBitToCarry
   asl
   asl
   asl
   bcs .checkDiagonalUpMovement
   lda #MOVE_DOWN
   ora playerMotion,x
   and #~MOVE_UP
   sta playerMotion,x
   jmp MovePlayerDown
       
.checkDiagonalUpMovement
   asl                              ; shift up bit into carry
   bcs .checkNextPlayersDirections
   lda #MOVE_UP
   ora playerMotion,x
   and #~MOVE_DOWN
   sta playerMotion,x
   jmp MovePlayerUp
       
.checkNextPlayersDirections
   inx
   cpx #NUM_PLAYERS
   bcs .delayPlayerMovement
   lda workingJoystickValue
   asl                              ; shift player2's joystick values to
   asl                              ; upper nybbles
   asl
   asl
   jmp .calculateMovementLoop
       
MovePlayerRight
   lda #HMOVE_R4
   sta HMP0,x                       ; move player 4 pixels to the right
   inc playerHorizPos,x             ; increment player horizontal position
   lda #XMAX
   cmp playerHorizPos,x
   bne .diagonalMovementCheck
   lda #XMIN
   sta playerHorizPos,x
   jmp CheckToMoveDiagonally
       
MovePlayerLeft
   lda #HMOVE_L4
   sta HMP0,x                       ; move player 4 pixels to the left
   dec playerHorizPos,x             ; reduce player horizontal position
   bpl .diagonalMovementCheck
   lda #XMAX-1
   sta playerHorizPos,x
.diagonalMovementCheck
   jmp CheckToMoveDiagonally

.delayPlayerMovement
   lda #$F0
   ora gameSpeed                    ; delay player movement for 15 frames
   sta gameSpeed
   rts

Start
   sei
   cld                              ; clear decimal mode
   lda #SYSTEM_POWERUP
   sta gameState                    ; show system is in power up state
   jmp InitRound
       
MainLoop
   jsr VerticalSync
   lda gameState                    ; get the current game state
   bmi ReadJoysticks                ; read joysticks if game in progress
   jmp ReadGameSelectAndReset
       
ReadJoysticks
   lda SWCHA                        ; get player joystick values
   and #PLAYER0_JOYSTICK_MASK       ; mask player2's joystick values
   cmp #PLAYER0_NO_MOVE
   beq .checkPlayer2Joystick
   sta playerJoystickValues         ; save joystick value temporarily
   lda joystickValues               ; get current joystick values
   and #PLAYER1_JOYSTICK_MASK       ; mask to isolate player 2's values
   ora playerJoystickValues         ; combine player1's joystick value
   sta joystickValues
.checkPlayer2Joystick:
   lda SWCHA                        ; get player joystick values
   and #PLAYER1_JOYSTICK_MASK       ; mask to isolate player 2's values
   cmp #PLAYER1_NO_MOVE
   beq .skipPlayer2Joystick         ; skip joystick logic if not moved
   sta playerJoystickValues         ; save joystick value temporarily
   lda joystickValues               ; get current joystick values
   and #PLAYER0_JOYSTICK_MASK       ; mask to isolate player 1's values
   ora playerJoystickValues         ; combine player2's joystick value
   sta joystickValues
.skipPlayer2Joystick
   lda gameVariation                ; get the current game variation
   and #NOGRAFFITI2
   beq CheckForSpeedUp
   jsr CheckCollisions
CheckForSpeedUp
   bit gameVariation                ; check game variation for speed up
   bvc .skipSpeedIncrease           ; skip speed increase if not SPEEDUP
   lda frameCount                   ; get the current frame count
   bne .skipSpeedIncrease           ; skip speed increase if no roll over
   lda gameSpeed
   and #$0F
   cmp #4
   bcc .skipSpeedIncrease
   dec gameSpeed
   dec gameSpeed
   dec gameSpeed
.skipSpeedIncrease
   lda gameSpeed                    ; get the game speed
   and #$F0                         ; keep the frame delay value
   cmp #32
   bne .checkGameDelay
   bit playerState                  ; if either player was hit this round
   bmi .checkGameDelay              ; then don't turn off the sound
   bvs .checkGameDelay
   lda #0
   sta AUDV0                        ; turn off sound channel 0
.checkGameDelay
   lda gameSpeed                    ; get the game speed
   and #$F0                         ; keep the frame delay value
   cmp #0                           ; skip player updates if not 0
   bne ReadGameSelectAndReset
   jsr UpdatePlayfield
   jsr PerformGameLogic
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; move all objects horizontally
   lda gameSpeed
   and #$0F                         ; mask frame delay nybbles
   sta gameSpeed                    ; move lower nybbles to frame delay
   asl                              ; nybbles
   asl
   asl
   asl
   ora gameSpeed
   sta gameSpeed
   lda #8
   bit gameVariation
   bmi .setVolume
   lda #0
.setVolume
   sta AUDV0
   lda #$0C
   sta AUDC0
   lda gameSpeed
   asl
   sta AUDF0
ReadGameSelectAndReset
   jsr CheckForGameSelectOrReset
EnterDisplayKernel
   jsr DisplayKernel
   lda gameSpeed
   sec
   sbc #FRAME_DELAY                       ; reduce the frame delay value
   sta gameSpeed
   jmp MainLoop
       
UpdatePlayfield SUBROUTINE
   ldx #0
   stx playfieldRAMPointer0+1
.playfieldLoop
   ldy playerHorizPos,x             ; get the player's horizontal position
   lda PFGraphicsPointerTable,y     ; read the LSB for the playfield graphics
   sta playfieldRAMPointer0
   lda PlayfieldPatternTable,y
   sta tempPlayfieldPattern
   ldy playerVertPos,x              ; get the player's vertical position
   lda gameVariation                ; get the current game variation
   lsr                              ; shift right 3 times so ERASE option
   lsr                              ; is in carry
   lsr
   bcc .skipErase
   lda INPT4,x                      ; read the joystick button
   bmi .skipErase                   ; skip erase if not pressed
   lda tempPlayfieldPattern
   eor #$FF                         ; flip the bits
   and (playfieldRAMPointer0),y
   sta (playfieldRAMPointer0),y
   jmp .nextPlayer
       
.skipErase
   lda tempPlayfieldPattern
   ora (playfieldRAMPointer0),y
   sta (playfieldRAMPointer0),y
.nextPlayer
   inx
   cpx #NUM_PLAYERS
   bcc .playfieldLoop
   rts

InitRound
   ldx #$FF
   lda #0
   sta PF0                          ; clear playfield graphic registers
   sta PF1
   sta PF2
   txs                              ; set stack to the beginning
   jsr DisplayKernel
   jsr VerticalSync
   lda #0
   ldx #NUM_ROWS*4
.clearPlayfieldLoop
   sta leftPF1Graphics-1,x
   dex
   bne .clearPlayfieldLoop
   lda gameVariation                ; get the current game variation
   and #WRAPAROUND
   bne InitializeWrapAroundPF
   ldx #NUM_ROWS
   lda #%00000001                   ; remember PF0 is displayed as D4 - D7
.setLeftPFColumnLoop                ; and lower nybbles hold left PF0 values
   sta pf0Graphics-1,x              ; set PF0 values to have column on left
   dex
   bne .setLeftPFColumnLoop
   ldx #NUM_ROWS
   lda #%10000000                   ; remember PF2 is displayed as D0 - D7
.setRightPFColumnLoop
   sta rightPF2Graphics-1,x         ; set PF2 values to have column on right
   dex
   bne .setRightPFColumnLoop
   lda #%11111111
   sta pf0Graphics
   sta pf0Graphics+NUM_ROWS-1
   sta leftPF1Graphics
   sta leftPF1Graphics+NUM_ROWS-1
   sta leftPF2Graphics
   sta leftPF2Graphics+NUM_ROWS-1
   sta rightPF1Graphics
   sta rightPF1Graphics+NUM_ROWS-1
   sta rightPF2Graphics
   sta rightPF2Graphics+NUM_ROWS-1
   jmp ClearGameTIARegisters
       
InitializeWrapAroundPF
   lda #0
   ldx #NUM_ROWS
.clearPFBordersLoop
   sta pf0Graphics-1,x              ; clear the left and right playfield
   sta rightPF2Graphics-1,x         ; variables to have no left/right borders
   dex
   bne .clearPFBordersLoop
ClearGameTIARegisters
   lda #0
   ldx #CXCLR-RSYNC+1
.clearTIALoop
   sta NUSIZ0+63,x
   dex
   bne .clearTIALoop
   lda #PLAYER_START_Y
   sta player1VertPos
   sta player2VertPos
   sta player1HorizPos
   lda #PLAYER2_START_X
   sta player2HorizPos
   sta playerState
   sta WSYNC                        ; wait for next scan line
   ldy #5
.positionPlayer0Loop
   dey
   bpl .positionPlayer0Loop
   sta RESP0
   sta WSYNC                        ; wait for next scan line
   ldy #10
.positionPlayer1Loop
   dey
   bpl .positionPlayer1Loop
   sta RESP1
   lda #HMOVE_L3
   sta HMP0
   lda #HMOVE_R2
   sta HMP1
   sta WSYNC                        ; wait for next scan line
   sta HMOVE                        ; move all objects horizontally
   lda #NO_MOVE
   sta joystickValues
   sta gameSpeed                    ; set initial game speed
   sta AUDF0
   lda gameSelection                ; get current game selection
   and #7
   asl                              ; multiply by 4 to get color table offset
   asl
   tay
   ldx #0
   lda SWCHB                        ; read the console switches
   and #BW_MASK                     ; mask to get B/W switch value
   bne .setColorsLoop
   ldy #32
.setColorsLoop
   lda GameColorTable,y
   sta COLUP0,x
   iny
   inx
   cpx #4
   bcc .setColorsLoop
   lda #0
   sta AUDV0                        ; turn off game sounds
   sta AUDV1
   sta frameCount                   ; reset frame count
   lda gameVariation                ; get the current game variation
   and #SINGLEPLAYER
   bne .setPlayer2InitMotion
   lda #MOVE_RIGHT
   sta player1Motion                ; start player 1 moving right
.setPlayer2InitMotion
   lda #MOVE_LEFT
   sta player2Motion                ; start player 2 moving left
   lda #$0C
   sta AUDC0
   jmp EnterDisplayKernel
       
CheckForGameSelectOrReset SUBROUTINE
   lda gameState                    ; get the current game state
   cmp #SYSTEM_POWERUP              ; read console switches if not powering up
   bne .checkForResetSwitch
   lda #-1
   sta gameSelection
   bne ShowGameSelection
       
.checkForResetSwitch
   lda SWCHB                        ; read the console switches
   ror                              ; RESET now in carry
   bcs .skipGameReset
   lda #GAME_RUNNING                ; RESET pressed so show that game is
   sta gameState                    ; in progress
   lda #0
   sta player1Score                 ; clear the player scores
   sta player2Score
   sta selectDebounce
   sta colorCycleTimer
   lda frameCount                   ; get the current frame count
   and #1                           ; make the frame count between 0 and 1
   sta frameCount
   lda #15
   sta unused
   jmp InitRound
       
.skipGameReset
   lda frameCount                   ; get current frame count
   and #SELECT_DELAY                ; the select switch is checked ~ every 60
   bne .checkGameSelectSwitch       ; frames or ~ every second
   sta selectDebounce               ; reset select debounce flag
.checkGameSelectSwitch
   lda frameCount
   and #$FF
   bne .checkForSelectSwitch
   inc colorCycleTimer
   bne .checkForSelectSwitch
   lda #0                           ; reset gameState so right score not shown
   sta gameState                    ; and color's could cycle for attract mode
.checkForSelectSwitch
   lda SWCHB                        ; read the console switches
   and #SELECT_MASK                 ; mask to find SELECT value
   beq .selectSwitchPressed
   sta selectDebounce               ; show SELECT not pressed this frame
   bne DetermineGameColors          ; unconditional branch
   
.selectSwitchPressed
   bit selectDebounce               ; if SELECT held then skip SELECT button
   bmi DetermineGameColors          ; logic
   lda #$FF
   sta selectDebounce               ; show the SELECT button is held
   inc gameSelection                ; increment game selection
ShowGameSelection
   ldx #0
   stx player1Score                 ; clear player1's score
   ldx gameSelection                ; get current game selection
.setGameSelectionDisplay
   sed
   lda player1Score                 ; the player's score is incremented by 1
   clc                              ; to show the current game selection
   adc #1
   sta player1Score
   cld
   dex
   bne .setGameSelectionDisplay
   ldx #0
   stx player2Score                 ; clear player2's score
   stx unused
   stx gameState
   stx frameCount                   ; clear frame count
   lda gameSelection                ; get current game selection
   cmp #MAX_GAME_SELECTION
   bcc .skipGameSelectionReset
   stx player1Score                 ; clear player's score
   stx gameSelection                ; clear game selection
.skipGameSelectionReset
   sed
   clc
   lda player1Score
   adc #1
   sta player1Score
   cld
   ldx gameSelection                ; get current game selection
   lda GameVariationTable,x         ; set the game variation based on game
   sta gameVariation                ; selection
DetermineGameColors
   lda gameSelection                ; get current game selection
   and #7
   asl                              ; multiply by 4 to get color table offset
   asl
   tay
   ldx #0
   lda gameState                    ; get the current game state
   and #$F0                         ; keep upper nybbles to see if game active
   eor #$FF                         ; flip the bits
   and colorCycleTimer
   sta colorXOR
   lda #$FF
   sta hueMask                      ; assume color (i.e. keep color hues)
   lda SWCHB                        ; read the console switches
   and #BW_MASK                     ; mask to get B/W switch value
   bne .setColorsLoop
   lda #$0F
   sta hueMask                      ; mask hues for B/W option
   ldy #32                          ; index for B/W values
.setColorsLoop
   lda GameColorTable,y
   eor colorXOR
   and hueMask                      ; mask color hue
   bit gameState                    ; don't cycle colors if game in progress
   bvs .skipColorSet
   sta COLUP0,x
   lda #0
   sta AUDV0                        ; turn off channel 0 sound
.skipColorSet
   iny
   inx
   cpx #4
   bcc .setColorsLoop
   lda #0
   sta PF0                          ; clear playfield registers
   sta PF1
   sta PF2
   rts

CheckCollisions
   lda CXP0FB                       ; read playfield collisions for player 0
   bpl .checkPlayer1Collisions      ; check player 1 if not collided with PF
   bit playerState
   bvs PlayCollisionSound
   lda #~PLAYER2_COLL_MASK
   sta playerState
   sed
   lda player2Score                 ; get player2's score
   clc                              ; player1 hit the playfield so
   adc #1                           ; increment player2's score
   cld
   sta player2Score
   cmp #MAX_SCORE
   bne .checkPlayer1Collisions
   lda #$0F
   sta gameState
.checkPlayer1Collisions
   lda CXP1FB                       ; read playfield collisions for player 1
   bpl .donePlayerCollisionCheck
   bit playerState
   bmi PlayCollisionSound
   lda playerState
   ora #PLAYER2_COLL_MASK
   sta playerState
   sed
   lda player1Score                 ; get player1's score
   clc                              ; player2 hit the playfield so
   adc #1                           ; increment player1's score
   cld
   sta player1Score
   cmp #MAX_SCORE
   bne .donePlayerCollisionCheck
   lda #$0F
   sta gameState
.donePlayerCollisionCheck
   lda playerState
   and #PLAYER_COLL_MASK
   beq .leaveSubroutine
   jmp .incrementFrameDelay
       
.leaveSubroutine
   rts

PlayCollisionSound
   lda frameCount                   ; set collision volume and frequency
   and #3                           ; every fourth frame
   bne .setCollisionVolume
   lda #1
   sta AUDC0                        ; set collision audio channel
   lda #6
   sta AUDF0                        ; set initial collision volume
   bne .checkToReduceCollisionVolume
       
.setCollisionVolume
   lda playerState
   sta AUDV0                        ; set game volume (only lower nybble used)
   lda #$0E
   sta AUDF0
.checkToReduceCollisionVolume
   lda frameCount
   and #$0F                         ; decrement collision volume every 15
   bne .incrementFrameDelay         ; frames
   dec playerState                  ; reduce collision volume
   lda playerState
   and #$0F                         ; check the collision volume values
   bne CheckToFlashPlayer           ; if not done check for flashing player
   jmp InitRound
       
CheckToFlashPlayer
   lda gameSelection                ; get current game selection
   and #7
   asl                              ; multiply by 4 to get color table offset
   asl
   tay
   lda SWCHB                        ; read the console switches
   and #BW_MASK                     ; mask to get B/W switch value
   bne .checkToFlashPlayer2
   ldy #32                          ; index for B/W values
.checkToFlashPlayer2
   bit playerState                  ; see if player2 hit player1
   bpl .checkToFlashPlayer1         ; if not check to whether to flash player1
   lda playerState                  ; get the player state
   and #%00100000                   ; see if player2 was shown this frame
   bne .clearPlayer2
   lda playerState
   ora #%00100000                   ; set to show player2 shown this frame
   sta playerState
   iny                              ; increment y to point to player2 color
   lda GameColorTable,y             ; read color table
   dey                              ; restore y to point to player1 color
   sta COLUP1                       ; color player2
   jmp .checkToFlashPlayer1
       
.clearPlayer2
   lda playerState
   eor #%00100000                   ; flip D5 to show player2 masked this frame
   sta playerState
   iny                              ; increment y to point to background color
   iny
   lda GameColorTable,y             ; read color table
   dey                              ; restore y to point to player1 color
   dey
   sta COLUP1                       ; color player2
.checkToFlashPlayer1
   bit playerState                  ; see if player1 hit player2
   bvc .incrementFrameDelay
   lda playerState
   and #%00010000                   ; see if player1 was shown this frame
   bne .clearPlayer1
   lda playerState
   ora #%00010000
   sta playerState                  ; set to show player1 shown this frame
   lda GameColorTable,y             ; read color table
   sta COLUP0                       ; color player1
   jmp .incrementFrameDelay
       
.clearPlayer1
   lda playerState
   eor #%00010000                   ; flip D4 to show player1 masked this frame
   sta playerState
   iny                              ; increment y to point to background color
   iny
   lda GameColorTable,y             ; read color table
   sta COLUP0                       ; color player1
.incrementFrameDelay
   lda gameSpeed
   clc
   adc #FRAME_DELAY
   sta gameSpeed
   rts

PFGraphicsPointerTable
   .byte pf0Graphics,pf0Graphics,pf0Graphics,pf0Graphics
   .byte leftPF1Graphics,leftPF1Graphics,leftPF1Graphics,leftPF1Graphics
   .byte leftPF1Graphics,leftPF1Graphics,leftPF1Graphics,leftPF1Graphics
   .byte leftPF2Graphics,leftPF2Graphics,leftPF2Graphics,leftPF2Graphics
   .byte leftPF2Graphics,leftPF2Graphics,leftPF2Graphics,leftPF2Graphics
   .byte pf0Graphics,pf0Graphics,pf0Graphics,pf0Graphics
   .byte rightPF1Graphics,rightPF1Graphics,rightPF1Graphics,rightPF1Graphics
   .byte rightPF1Graphics,rightPF1Graphics,rightPF1Graphics,rightPF1Graphics
   .byte rightPF2Graphics,rightPF2Graphics,rightPF2Graphics,rightPF2Graphics
   .byte rightPF2Graphics,rightPF2Graphics,rightPF2Graphics,rightPF2Graphics
   
PlayfieldPatternTable
   .byte $01,$02,$04,$08
   .byte $80,$40,$20,$10,$08,$04,$02,$01
   .byte $01,$02,$04,$08,$10,$20,$40,$80
   .byte $10,$20,$40,$80
   .byte $80,$40,$20,$10,$08,$04,$02,$01       
   .byte $01,$02,$04,$08,$10,$20,$40,$80
       
NumberFonts
zero
   .byte $0E ; |....XXX.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0A ; |....X.X.|
   .byte $0E ; |....XXX.|
one
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
two
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
three
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $66 ; |.XX..XX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
four
   .byte $AA ; |X.X.X.X.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
five
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|
six
   .byte $EE ; |XXX.XXX.|
   .byte $88 ; |X...X...|
   .byte $EE ; |XXX XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
seven
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
   .byte $22 ; |..X...X.|
eight
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
nine
   .byte $EE ; |XXX.XXX.|
   .byte $AA ; |X.X.X.X.|
   .byte $EE ; |XXX.XXX.|
   .byte $22 ; |..X...X.|
   .byte $EE ; |XXX.XXX.|

GameColorTable
;
; organized as...
; P0/P1/PF/BK
;
   IF COMPILE_VERSION = NTSC

   .byte $C8,$84,$3A,$44
   .byte $46,$EA,$5A,$88
   .byte $2A,$46,$B4,$E8
   .byte $3A,$86,$E8,$46
   .byte $2A,$56,$E8,$A4
   .byte $36,$2C,$C8,$A2
   .byte $C8,$2A,$83,$46
   .byte $86,$2C,$48,$E8
       
   ELSE
   
   .byte $CA,$84,$3A,$2E
   .byte $84,$2E,$CE,$E8
   .byte $CE,$3A,$2E,$82
   .byte $CE,$2E,$82,$3A
   .byte $82,$3A,$2E,$CE
   .byte $86,$2E,$3F,$32
   .byte $2E,$3A,$CF,$C2
   .byte $2E,$86,$EF,$3A

   ENDIF
   
   .byte $00,$0E,$04,$08
       
DigitOfsTab
    .byte H_DIGIT*0, H_DIGIT*1, H_DIGIT*2, H_DIGIT*3, H_DIGIT*4
    .byte H_DIGIT*5, H_DIGIT*6, H_DIGIT*7, H_DIGIT*8, H_DIGIT*9

; used to duplicate bottom row of score:
DigitOfs2Tab:
    .byte 4, 4, 3, 2, 1, 0
       
GameVariationTable
   .byte NOGRAFFITI|        NOGRAFFITI2
   .byte NOGRAFFITI|        NOGRAFFITI2|SINGLEPLAYER
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|SINGLEPLAYER
   .byte NOGRAFFITI|        NOGRAFFITI2|                              DIAGONAL
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|                              DIAGONAL
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|                        ERASE|DIAGONAL
   .byte NOGRAFFITI|        NOGRAFFITI2|             WRAPAROUND
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|             WRAPAROUND
   .byte NOGRAFFITI|        NOGRAFFITI2|             WRAPAROUND|      DIAGONAL
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|             WRAPAROUND|      DIAGONAL
   .byte NOGRAFFITI|SPEEDUP|NOGRAFFITI2|             WRAPAROUND|ERASE|DIAGONAL
   .byte                                             WRAPAROUND|ERASE
   .byte                                             WRAPAROUND|ERASE|DIAGONAL
       
   .org ROM_BASE_ADDRESS + 2048 - 6, 234 * COMPILE_VERSION ; 2K ROM
   .word Start                      ; NMI vector
   .word Start                      ; RESET vector
   .word Start                      ; BRK vector