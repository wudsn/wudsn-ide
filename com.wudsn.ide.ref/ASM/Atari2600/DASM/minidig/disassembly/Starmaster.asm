; Disassembly of STARMAST.BIN
; Disassembled Fri Dec 03 23:47:31 1999
; Using DiStella v2.0
;
; Command Line: C:\USR\ATARI\DEV\DISTELLA\DISTELLA.EXE -cstarmast.cfg STARMAST.BIN
;
; starmast.cfg contents:
;
;      GFX fc39 fffc
;
; Analyzing, naming and commenting done
;  by Thomas Jentzsch in 2000/2001 (v0.9)

    processor 6502
    include vcs.h

;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

OPTIMIZE = 0                            ; enable some possible optimizations


;===============================================================================
; C O N S T A N T S
;===============================================================================

ID_NONE         = 0                     ; empy sector (1..3 for enemies)
ID_BASE         = 4
ID_SHIP         = 5                     ; why didn't he use 8 here? would have made a lot of things easier...
MAP_WIDTH       = 6
NUM_SECTORS     = 6*6
NUM_BASES       = 4
NUM_STARS       = 8
WARP_TIME       = 200
LASER_TIME      = 23
NUM_LINES       = 144                   ; lines of space display
FIRE_DISTANCE   = 176                   ; maximum distance for enemy fire
SCREEN_WIDTH    = 160
MIN_DIST_Y      = 6                     ; minimum y-distance between stars

MASK_NONE       = %1111
MOVE_RIGHT      = %1000
MASK_RIGHT      = ~MOVE_RIGHT & MASK_NONE
MOVE_LEFT       = %0100
MASK_LEFT       = ~MOVE_LEFT  & MASK_NONE
MOVE_DOWN       = %0010
MASK_DOWN       = ~MOVE_DOWN  & MASK_NONE
MOVE_UP         = %0001

BLACK           = $00
WHITE           = $0f
BLUE            = $84
RED             = $44
ORANGE          = $28
GREEN           = $d4
BRIGHT_ORANGE   = ORANGE+4              ; $2c
BRIGHT_BLUE     = BLUE+8                ; $8c


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

Level           = $80           ;               0..3
SS_XOR          = $81           ;               screensaver xor-value ($00/$00, $02,.., $fe)
SS_Mask         = $82           ;               screensaver mask ($ff/$f7)
FrameCnt        = $83           ;               frame counter
Random          = $84           ;               current random number
;               = $85                           ???
NoGameScroll    = $86           ;               0 = game is running
SS_Delay        = $87           ;               delay for screensaver (bit7 = 1 -> enabled)
Temp            = $88
Temp2           = $89
WarpTime        = $8a           ;               when warping, decreased every 4th frame (200..0)
SectorList      = $8b           ; -$9c          18 bytes to store the states of 36 sectors
MeteorEnabled   = $9d           ;               0 = disabled
CursorDelay     = $9e
DockCount       = $9f           ;               number of dockings
IsDocked        = $a0           ;               $00 / $99
;---------------------------------------
MoveLst         = $a1
EnemyMoveY      = MoveLst+0     ; $a1
MeteorMoveY     = MoveLst+1     ; $a2
EnemyMoveX      = MoveLst+2     ; $a3
MeteorMoveX     = MoveLst+3     ; $a4
EnemyMoveZ      = MoveLst+4     ; $a5
MeteorMoveZ     = MoveLst+5     ; $a6

SecondPosY = MeteorMoveX
;---------------------------------------
MeteorSound     = $a7
EnemySound      = $a8
BaseSound       = $a9
;---------------------------------------
LaserState      = $aa           ;               current state of laser (0 = off, 23..1 = on)
AttackedBase    = $ab           ;               id of the current attacked starbase (0..3)
LaserTop        = $ac           ;               top y-pos of laser-fire
LaserBottom     = $ad           ;               bottom y-pos of laser-fire
;---------------------------------------
; the next 6 variables contain the y-x-z-positions:
ShapePosYLst    = $ae           ; -$af/b1
ShapePosX       = $b0
StarCount       = $b1           ;               only one x-position (free for temporary use)
ShapePosZLst    = $b2           ; -$b3
;---------------------------------------
AudF0Val        = $b4
StarMoveDelay   = $b5           ;               determines the starfield speed
TuneIndex       = $b6
TuneDelay       = $b7
LevelDelay      = $b8           ;               delay when SELECt is pressed
;---------------------------------------
DigitLst        = $b9           ; -$c2
Damage          = DigitLst      ; $b9/$ba
EnergyHi        = DigitLst+2    ; $bb           decreased every 64th frame (~1 sec)
EnergyLo        = DigitLst+3    ; $bc
StarDateHi      = DigitLst+4    ; $bd           increased every 256th frame (~4 sec)
StarDateLo      = DigitLst+5    ; $be
WarpEnergy      = DigitLst+6    ; $bf/$c0       subtracted from energy every 8th frame while warping
ScoreHi         = $c1
ScoreLo         = $c2
;---------------------------------------
ShipSectorIdx   = $c3           ;               current ship sector
WarpSectorIdx   = $c4           ;               target sector for warp
BaseShield      = $c5           ; -$c8          shield state of the four starbases (255..0)
NumBases        = $c9           ;               number of alive starbases
StarPosY        = $ca           ; -$d1          y-position of the eight stars
StarPosX        = $d2           ; -$d9          x-position of the eight stars
;               = $da           ;               ???
ThreatedBase    = $db           ;               uses when damaging base shields (3..0)
BaseSector      = $dc           ;               0..7,  offset for sectors arround base
WalkDelay       = $dd
WalkSectorIdx   = $de           ;               next sector to walk at attacked starbase
;               = $df                           ???
;---------------------------------------
StarMoveXLst    = $e0           ; -$e7          values for positioning the stars (fine/coarse)
BaseDir         = $e1           ;               direction of attacked base
SectorId        = $e2           ;               only used for enemy walk
NewSectorIdx    = $e3           ;               walk to sector
HelpMap         = $e4           ;               help variable, used for bounds checking etc.
;---------------------------------------
MACCRows        = $e8           ;               used when displaying the MACC
ShapeHeightLst  = $e9           ; -$ea
ShapePtrLst     = $eb           ; -$ec          max. two different objects/frame
ShapePtr        = $ed           ; -$f6          lo/hi
SwitchState     = $f9           ;               MRS00000 (map, reset, select)
Enemies         = $fa           ;               number of remaining enemies
LevelPtrLo      = $fb           ;               lo-pointer to level character data (ELWS)

ShapeHeight     = Temp2


;===============================================================================
; R O M - C O D E
;===============================================================================

       ORG $F000

START:
       SEI                      ;2
       CLD                      ;2
       LDX    #$FF              ;2
       TXS                      ;2
       INX                      ;2
       JSR    GameInit          ;6
       LDA    #64               ;2
       STA    WarpTime          ;3      maximum star speed at start of game
       STA    NoGameScroll      ;3      no game, scroll copyright
       LDA    #18               ;2
       STA    TuneIndex         ;3

MainLoop:
; set color of stars and background:
; (flashes while explosion is heard)
       LDX    #$01              ;2
       LDY    #$01              ;2
       LDA    FrameCnt          ;3
       AND    #$04              ;2
       BEQ    .setPFBKColor     ;2
       TAX                      ;2      x = 4
.loopCheckSound:
       LDA    MeteorSound-2,X   ;4      x = 4..2
       BNE    .setPFBKColor     ;2
       DEX                      ;2
       CPX    #$01              ;2
       BNE    .loopCheckSound   ;2

.setPFBKColor:
       LDA    PFBKColTab,X      ;4
       EOR    SS_XOR            ;3
       AND    SS_Mask           ;3
       STA    COLUPF,Y          ;5
       DEX                      ;2
       DEY                      ;2
       BPL    .setPFBKColor     ;2

; set hi data pointer:
       LDA    WarpTime          ;3
       BNE    .doDey            ;2
       JSR    GetShipSectorId   ;6
       TAX                      ;2
       CMP    #ID_BASE+ID_SHIP  ;2      starbase sector?
       BNE    .doDey            ;2       no, skip dey (y = $ff)
       LDA    ShapePosZLst      ;3
       CMP    #$50              ;2      starbase near?
       BCC    .skipDey          ;2       no, skip
.doDey:
       DEY                      ;2       yes, use other data bank (y = $fe)
.skipDey:
       STY    ShapePtr+1        ;3

; determine player (meteor, starbase, enemy) color:
       LDA    #BRIGHT_ORANGE    ;2
       LDY    WarpTime          ;3
       BNE    .setColor         ;2
       LDA    #BRIGHT_BLUE      ;2
       CPX    #ID_BASE+ID_SHIP  ;2
       BEQ    .setColor         ;2
       CPX    #ID_SHIP          ;2
       BEQ    .setColor         ;2
       LDA    FrameCnt          ;3
.setColor:
       EOR    SS_XOR            ;3
       AND    SS_Mask           ;3
       STA    COLUP0            ;3
       STA    COLUP1            ;3

; read map switches:
       LDA    NoGameScroll      ;3      game running?
       BNE    .checkSwitches    ;2       no, check swithces
       LDA    WarpTime          ;3      warping?
       BNE    .skipSwitches     ;2       yes, skip switches
.checkSwitches:
       LDA    SWCHB             ;4      read switches
       LSR                      ;2
       AND    #%01100100        ;2      mask B/W and both difficulty switches
       STA    Temp              ;3
       EOR    SwitchState       ;3
       AND    #%01100100        ;2
       BEQ    .skipSwitches     ;2
       LDA    SwitchState       ;3
       EOR    #$80              ;2
       AND    #$80              ;2
       ORA    Temp              ;3
       STA    SwitchState       ;3
       LDA    WarpSectorIdx     ;3      move ship
       TAY                      ;2       from
       JSR    SetSectorIdNoShip ;6       current to
       LDA    ShipSectorIdx     ;3       target-
       STA    WarpSectorIdx     ;3       sector
.skipSwitches:
       LDA    SwitchState       ;3
       BPL    .spaceKernel      ;2
       JMP    .waitTim1         ;3      goto map kernel

; *** space kernel: ***
.spaceKernel:
       LDX    #NUM_LINES-1      ;2      number of kernel-lines
       STX    REFP1             ;3      enable reflection of player 1
       TXS                      ;2       save x into stack-pointer

; calc 3d effect for fighter (move y-pos[0] based on z-pos[0]) :
       LDX    #$00              ;2
       LDA    ShapePosZLst      ;3      distance / 32
       LSR                      ;2
       LSR                      ;2
       LSR                      ;2
       LSR                      ;2
       LSR                      ;2
       ORA    #%11111000        ;2
       SEC                      ;2
       ADC    ShapePosYLst      ;3
       CMP    #NUM_LINES-2      ;2      y-pos[0] out of bounds?
       BCS    .draw1            ;2³      yes, draw second (or none)
       CMP    ShapePosYLst+1    ;3      y-pos[0] > y-pos[1]?
       BCS    .draw0            ;2³      yes, draw first
       LDA    ShapePosYLst+1    ;3
       CMP    #NUM_LINES-2      ;2      y-pos[1] out of bounds?
       BCS    .draw0            ;2³      yes, draw first (-> none!)
.draw1:
       INX                      ;2
.draw0:
       LDA    ShapePtrLst,X     ;4
       STA    ShapePtr          ;3
       LDY    ShapeHeightLst,X  ;4
       STY    ShapeHeight       ;3

; check, if y-pos[x] in bounds:
       LDY    #-NUM_LINES       ;2      disable drawing
       SEC                      ;2
       LDA    ShapePosYLst,X    ;4
       SBC    #NUM_LINES+1      ;2      in y-bounds?
       BCS    .noShapeY         ;2³      no, don't draw any object
       TAY                      ;2       yes, wait for first object
.noShapeY:

; store variables of second object:
       TXA                      ;2      switch to other object
       EOR    #$01              ;2
       TAX                      ;2
       LDA    ShapePosYLst,X    ;4
       STA    SecondPosY        ;3
       LDA    ShapePtrLst,X     ;4
       STA    ShapePtrLst       ;3
       LDA    ShapeHeightLst,X  ;4
       STA    ShapeHeightLst    ;3

; check x-bounds (same for both objects):
       LDA    ShapePosX         ;3
       CMP    #9                ;2      in left x-bound?
       BCC    .noShapeX         ;2³      no, don't draw any object
       CMP    #162              ;2      in right x-bounds?
       BCC    .withShapeX       ;2³      yes, draw object(s)
.noShapeX:
       LDY    #-NUM_LINES       ;2      disable drawing
.withShapeX:

       LDX    #NUM_STARS-1      ;2
       STX    StarCount         ;3
.waitTim0:
       LDA    INTIM             ;4
       BPL    .waitTim0         ;2³
       LDA    #$00              ;2
       STA    WSYNC             ;3
;---------------------------------------
       STA    HMOVE             ;3
       STA    VBLANK            ;3
       BEQ    EnterKernel       ;3 =  9

;*************************************************
; top of space kernel-loop:
; 5 lines/loop
.loopDrawStar:                  ;6
       BCS    .loopDrawStar2    ;2³
       LDA    (ShapePtr),Y      ;5
       STA    GRP0              ;3
       STA    GRP1              ;3
.loopDrawStar2:
       LDA    #%10              ;2
       STA    ENABL             ;3
       TSX                      ;2              restore x
       DEX                      ;2 = 18/25/28

; en-/disable laser-missiles:
       LDA    #%00              ;2
       CPX    LaserBottom       ;3
       BCC    .disableM_0       ;2³
       CPX    LaserTop          ;3
       BCS    .skipM_0          ;2³
       LDA    #%10              ;2
.disableM_0:
       STA    ENAM0             ;3
       STA    ENAM1             ;3
.skipM_0:
       STA    WSYNC             ;3 = 17/16/23   (total: 34..51)
;---------------------------------------
       STA    HMOVE             ;3
       DEX                      ;2
       INY                      ;2
       CPY    #$3C              ;2
       BCS    .skipShape1       ;2³
       LDA    (ShapePtr),Y      ;5
       STA    GRP0              ;3
       STA    GRP1              ;3
.skipShape1:                    ;  = 12/22
       DEX                      ;2
       LDA    #$00              ;2
       INY                      ;2
       CPY    #$3C              ;2
       BCS    .skipShape2       ;2³
       LDA    (ShapePtr),Y      ;5
.skipShape2:                    ;
       STA    WSYNC             ;3 = 14/18      (total: 26..40)
;---------------------------------------
       STA    HMOVE             ;3
       STA    GRP0              ;3
       STA    GRP1              ;3 =  9

; en-/disable laser-missiles:
       LDA    #%00              ;2
       STA    ENABL             ;3
       CPX    LaserBottom       ;3
       BCC    .disableM_1       ;2³
       CPX    LaserTop          ;3
       BCS    .skipM_1          ;2³
       LDA    #%10              ;2
.disableM_1:
       STA    ENAM0             ;3
       STA    ENAM1             ;3
.skipM_1:                       ;  = 16/17/23

       DEX                      ;2
       TXS                      ;2
; prepare next star (part 1/2):
       DEC    StarCount         ;5
       LDX    StarCount         ;3 = 12
EnterKernel:
       LDA    StarMoveXLst,X    ;4
       STA    HMBL              ;3
       AND    #$0F              ;2
       STA    Temp              ;3

       INY                      ;2
       LDA    (ShapePtr),Y      ;5
       CPY    #$3C              ;2
       STA    WSYNC             ;3 = 24         (total: 52..59)
;---------------------------------------
       STA    HMOVE             ;3
       BCS    .skipShape3       ;2³
       STA    GRP0              ;3
       STA    GRP1              ;3
       BCC    .contShape3       ;3

.skipShape3:
       NOP                      ;2
       NOP                      ;2
       NOP                      ;2
       NOP                      ;2
.contShape3:                    ;
; prepare next star (part 2/2):
       NOP                      ;2
       LDA    $0                ;3              just to wait 3 clocks
       LDX    Temp              ;3 = 22
.waitBall:
       DEX                      ;2
       BPL    .waitBall         ;2³
       STA    RESBL             ;3 =  7..42
.loopNoStar:
       TSX                      ;2              restore x
       DEX                      ;2
       INY                      ;2
       CPY    #$3C              ;2
       STA    WSYNC             ;3 = 11         (total: 40..75/46..71)
;---------------------------------------
       STA    HMOVE             ;3
       BCS    .skipShape4       ;2³
       LDA    (ShapePtr),Y      ;5
       STA    GRP0              ;3
       STA    GRP1              ;3
.skipShape4:                    ;  =  6/16/17
       TXA                      ;2
       AND    #$01              ;2
       BEQ    .evenFrame        ;2³

; en-/disable laser-missiles:
       CPX    LaserBottom       ;3              a = %01
       BCC    .disableM_2       ;2³
       CPX    LaserTop          ;3
       BCS    .disableM_2       ;2³
       ASL                      ;2              a = %10
.disableM_2:
       STA    ENAM0             ;3
       STA    ENAM1             ;3
       JMP    .contFrame        ;3

.evenFrame:                     ;7
       CPY    #$3C              ;2
       BCS    .contFrame        ;2³
       CPY    ShapeHeight       ;3
       BCS    .checkSecond      ;2³
.contFrame:                     ;  = 12..27
       TXS                      ;2
       TXA                      ;2
       LDX    StarCount         ;3
       STX    HMBL              ;3
       CMP    StarPosY,X        ;4
       BCS    .loopNoStar       ;2³= 16/17

       CMP    #MIN_DIST_Y       ;2              more stars possible?
       BCC    .exitKernel2      ;2³              no, exit kernel
       INY                      ;2
       CPY    #$3C              ;2
       STA    WSYNC             ;3 = 11         (total: 45..72)
;---------------------------------------
       STA    HMOVE             ;3
       JMP    .loopDrawStar     ;3 =  6

.checkSecond:                   ;  = 23/33
       LDY    ShapeHeightLst    ;3
       STY    ShapeHeight       ;3
       LDY    #-NUM_LINES       ;2              disable drawing object
       SEC                      ;2
       LDA    SecondPosY        ;3
       STX    Temp              ;3
       SBC    Temp              ;3              second object in y-bounds?
       BPL    .drawSecond       ;2³              yes, draw second
       TAY                      ;2               no, disable second
.drawSecond:                    ;  = 22/23

       LDA    ShapePtrLst       ;3
       STA    ShapePtr          ;3
       TXS                      ;2
       TXA                      ;2
       LDX    StarCount         ;3
       STX    HMBL              ;3
       STA    WSYNC             ;3 = 19         (total: 64..75)
;---------------------------------------
       STA    HMOVE             ;3
       CMP    StarPosY,X        ;4
       BCS    .noStar           ;2³
       CMP    #MIN_DIST_Y       ;2              more stars possible?
       BCC    .exitKernel       ;2³              no, exit kernel
       JMP    .loopDrawStar2    ;3 = 16

.noStar:                        ;10
       TSX                      ;2
       DEX                      ;2
       BNE    .skipShape4       ;2³= 16/17

.exitKernel:
       SBC    #0                ;2
.exitKernel2:
       TAX                      ;2
.loopExit:
       STA    WSYNC             ;3
;---------------------------------------
       STA    HMOVE             ;3
       LDA    #$00              ;2      clear player graphics
       STA    GRP0              ;3
       STA    GRP1              ;3
       DEX                      ;2
       BPL    .loopExit         ;2³

       TXS                      ;2      stack-pointer = $ff
       JSR    SetupScore        ;6
       LDX    #$01              ;2      draw only partial MACC display
       STX    REFP1             ;3      disable player 1 reflection
       BNE    .drawMACC         ;3      jump to MACC

;*************************************************
; *** map kernel: ***
.waitTim1:
       LDA    INTIM             ;4
       BPL    .waitTim1         ;2³

       LDX    #$04              ;2
.loopBlack:
       STA    WSYNC             ;3
;---------------------------------------
       DEX                      ;2
       BNE    .loopBlack        ;2³

       STX    VBLANK            ;3
       LDA    #46               ;2      y-pos of left three sectors
       JSR    SetPosX           ;6
       INX                      ;2
       LDA    #94               ;2      y-pos of right three sectors (+48)
       JSR    SetPosX           ;6
       LDY    #%011             ;2      3 copies close
       STY    NUSIZ0            ;3
       STY    NUSIZ1            ;3
       STA    WSYNC             ;3
;---------------------------------------
       STA    HMOVE             ;3

       LDX    #12-2             ;2
       LDA    #$FF              ;2
.loopSetHi:
       STA    ShapePtr+1,X      ;4      set hi shape pointer
       DEX                      ;2
       DEX                      ;2
       BPL    .loopSetHi        ;2³

       LDA    #BRIGHT_ORANGE    ;2
       EOR    SS_XOR            ;3
       AND    SS_Mask           ;3
       STA    COLUP0            ;3
       STA    COLUP1            ;3
       STA    HMCLR             ;3
       STA    WSYNC             ;3
;---------------------------------------
       LDX    #NUM_SECTORS-1    ;2
       STX    MACCRows          ;3
.loopMapRows:
       LDY    #12-2             ;2
.loopSetLo:
       LDA    MACCRows          ;3
       JSR    GetSectorId       ;6
       TAX                      ;2
       LDA    Damage+1          ;3
       AND    #$0F              ;2
       CMP    #OFS_R            ;2      radar damaged?
       BNE    .radarOk          ;2³      no, skip
       LDA    NoRadarTab,X      ;4       yes, show bases and ship only
       TAX                      ;2
.radarOk:
       LDA    MapShapePtrTab,X
       STA    ShapePtr,Y
       DEC    MACCRows
       DEY
       DEY
       BPL    .loopSetLo        ;2³

       JSR    DisplayMapRow
       LDA    MACCRows
       BPL    .loopMapRows      ;2³

; draw 25 empty lines:
       LDX    #24
.loopBlank:
       STA    WSYNC
       LDA    $0                ;3      just to waste 3 clocks
       NOP                      ;2      adjust timing before SetupScore
       NOP                      ;2
       NOP                      ;2
       NOP                      ;2
       DEX                      ;2
       BPL    .loopBlank        ;2³
       NOP                      ;2      wait 13 extra clocks in total
       JSR    SetupScore        ;
       LDX    #$04              ;       draw complete MACC display

; *** draw state-display: ***
.drawMACC:
       STX    MACCRows
       LDA    #BRIGHT_ORANGE
       EOR    SS_XOR
       AND    SS_Mask
       STA    COLUP0
       STA    COLUP1

       LDA    #<DoublePoint
       STA    ShapePtr+2

.loopRows:
       LDA    LevelPtrLo
       CPX    #$04              ;       first display row?
       BEQ    .drawLevel
       LDA    StatePtrTab,X
.drawLevel:
       STA    ShapePtr
       TXA
       ASL
       TAX
       INX
       TXS
       LDY    #$04
.loopDigits:
;  hi-nibble:
       LDA    DigitLst,X
       LSR
       LSR
       LSR
       LSR
       TAX
       LDA    CharPtrTab,X
       STA    ShapePtr+4,Y
;  lo-nibble:
       TSX
       LDA    DigitLst,X
       AND    #$0F
       TAX
       LDA    CharPtrTab,X
       STA    ShapePtr+6,Y
       TSX
       DEX
       TXS
       DEY
       DEY
       DEY
       DEY
       BPL    .loopDigits

       LDX    #$FF              ;       restore stack-pointer
       TXS
       JSR    DisplayMACC
       DEC    MACCRows
       LDX    MACCRows
       BPL    .loopRows

       STA    WSYNC
       LDA    #$00
       STA    PF2

       LDX    #12-1
.loopCopyright:
       LDA    CopyrightPtrTab,X
       STA    ShapePtr,X
       DEX
       BPL    .loopCopyright
       JSR    DisplayCopyright
       LDA    NoGameScroll      ;       game running?
       BEQ    .setTimer         ;        yes, no more scrolling
       DEC    NoGameScroll
       BNE    .setTimer
       DEC    NoGameScroll      ;       avoid #0

.setTimer:
       LDY    #$19              ;       setup timer for uni-coloured
       STY    TIM64T            ;        lower part of screen
       LDA    SWCHB             ;       read switches (reset/select)
       LSR
       BCS    .checkSelect
; RESET is pressed:
       LDX    #$85              ;       clear $85..$b7
.gameInit:
       JSR    GameInit
       JMP    .waitTim

.checkSelect:
       LSR
       BCS    .noSelect
; SELECT is pressed:
       LDA    LevelDelay
       BEQ    .doSelect
       DEC    LevelDelay
       BPL    .noSelect2

.doSelect:
       LDA    Level             ;       increase level
       CLC
       ADC    #$01
       AND    #$03
       STA    Level
       LDX    #SS_Delay         ;       clear $87..$b7
       STX    $85               ;       never used anywhere???
       INC    NoGameScroll      ;       stop running game
       BNE    .gameInit

.noSelect:
       STX    LevelDelay        ;       =135/-1
.noSelect2:
       JSR    NextRandom
       LDA    NoGameScroll      ;       game running?
       BEQ    .doUpdate0        ;        yes, update
       JMP    .skipUpdate0      ;        no, skip update

.doUpdate0:
       LDA    FrameCnt
       BNE    .skipStarDate
       SED
       CLC
       LDA    StarDateLo        ;       increase stardate every 256th frame (~4 sec)
       ADC    #$01
       STA    StarDateLo
       LDA    StarDateHi
       ADC    #$00
       STA    StarDateHi
       CLD
.skipStarDate:
       DEC    WalkDelay
       BEQ    .doMove
       JMP    .skipMoveAttack

;*** enemies walk to target-starbase: ***
.doMove:
       LDA    #96               ;       move every 96th frame (~1.5 sec)
       STA    WalkDelay

; calc enemy target base:
       LDX    AttackedBase      ;       current enemy target-base
       LDA    BasePositionTab,X
       JSR    GetSectorId
       CMP    #ID_BASE          ;       base still alive?
       BEQ    .keepTarget
       CMP    #ID_BASE+ID_SHIP  ;       base (with player) still alive?
       BEQ    .keepTarget
       LDX    AttackedBase      ;        no, starbase destroyed!
       CPX    #NUM_BASES-1
       BEQ    .skipNextBase
       INX                      ;       move to next starbase
.skipNextBase:
       STX    AttackedBase      ;       enemy target-base
.keepTarget:

; got next checked sector:
       DEC    WalkSectorIdx     ;       calc sector movement direction
       BPL    .skipResetSector
       LDA    #NUM_SECTORS-1
       STA    WalkSectorIdx
.skipResetSector:

; calculate the direction to the attacked starbase:
       LDX    AttackedBase
; check x-bounds:
       LDA    BaseDirTab,X
       LDX    #$05
.loopBoundsX:
       LDY    Mult6Tab,X
       CPY    WalkSectorIdx
       BNE    .skipMaskLeft
       AND    #MASK_LEFT        ;       current sector at left border
.skipMaskLeft:
       LDY    Mult6_1Tab,X
       CPY    WalkSectorIdx
       BNE    .skipMaskRight
       AND    #MASK_RIGHT       ;       current sector at right border
.skipMaskRight:
       DEX
       BPL    .loopBoundsX
       STA    BaseDir
; check y-bounds:
       TAX
       LDA    #MASK_NONE
       STA    HelpMap
       LDA    WalkSectorIdx
       CLC
       ADC    MoveTab,X         ;       check, if out of vertical bounds
       BPL    .checkUpperBound
       LDA    #MASK_DOWN        ;       current sector at bottom
       STA    HelpMap
       BNE    .exitBoundY

.checkUpperBound:
       CMP    #NUM_SECTORS
       BCC    .exitBoundY
       DEC    HelpMap           ;       current sector at top
.exitBoundY:

; combine both bounds:
       LDA    BaseDir
       AND    HelpMap
       STA    BaseDir
       LDA    WalkSectorIdx
       JSR    GetSectorId
       CMP    #ID_BASE          ;       base, player or cursor sector?
       BCS    .skipMoveToBase   ;        yes, skip
       STA    SectorId
       LDA    WalkSectorIdx     ;       calc destination sector
       CLC
       LDX    BaseDir
       ADC    MoveTab,X
       STA    NewSectorIdx
       JSR    GetSectorId       ;       get destination sector
       BNE    .skipMoveToBase   ;        not empty, skip
       LDA    WalkSectorIdx
       LDY    #ID_NONE
       JSR    SetSectorId       ;       clear current sector
       LDA    NewSectorIdx
       LDY    SectorId
       JSR    SetSectorId       ;       move to destination sector
.skipMoveToBase:

;*** one starbase is attacked by one surrounding sector every 96th frame: ***
; (-> ~51 seconds/complete round with 4 bases)
       LDX    ThreatedBase
       LDA    BasePositionTab,X ;       10, 25,  1, 29
       JSR    GetSectorId
       STA    HelpMap
       CMP    #ID_BASE          ;       base still alive?
       BEQ    .baseAlive
       CMP    #ID_BASE+ID_SHIP  ;       base (with ship) still alive?
       BNE    .skipBaseAttack   ;        no, don't attack
.baseAlive:
       LDA    ThreatedBase      ;       number of base
       ASL
       ASL
       ASL                      ;       *8
  IF OPTIMIZE
       NOP
  ELSE
       CLC
  ENDIF
       ADC    BaseSector        ;       offset of sector around base
       TAX
       LDA    BaseSectorsTab,X
       JSR    GetSectorId       ;       get number of enemies in sector
       TAY
       LDX    ThreatedBase
       LDA    BaseShield,X
       SEC
       SBC    BaseThreatTab,Y
       STA    BaseShield,X
       BCS    .skipBaseDestroyed

; destroy the attacked starbase:
       DEC    NumBases
       LDA    HelpMap
       SEC
       SBC    #ID_BASE          ;       remove base in attacked sector
       TAY
       LDA    BasePositionTab,X
       JSR    SetSectorId
       LDA    #$B0              ;       start base
       STA    BaseSound         ;        explosion sound
.skipBaseDestroyed:
       DEC    BaseSector
       BPL    .skipBaseReset
       LDA    #8-1              ;       number of sectors around starbase
       STA    BaseSector
.skipBaseAttack:

; attack previous base:
       DEC    ThreatedBase
       BPL    .skipBaseReset
       LDA    #NUM_BASES-1
       STA    ThreatedBase
.skipBaseReset:

.skipMoveAttack:
;*** countdown warp counter (every 4th frame): ***
       LDA    FrameCnt
       AND    #$03
       BNE    .skipCountdownWarp
       LDA    WarpTime
       BEQ    .skipCountdownWarp
       DEC    WarpTime
.skipCountdownWarp:

;*** countdown laser state: ***
       LDA    LaserState
       BEQ    .noLaserFire
       DEC    LaserState
       BNE    .contFireLaser
.noLaserFire:

; set position of gunsight:
       LDA    #NUM_LINES/2+6    ;       gunsight-position (= 78)
       STA    LaserTop
       LDA    #NUM_LINES/2-3    ;       (= 69)
       STA    LaserBottom

; check fire laser
       LDA    Damage            ;       laser damaged or
       ORA    IsDocked          ;        docked at starbase?
       CMP    #HI_DAMAGE
       BCS    .skipLaser
       LDA    WarpTime          ;       don't fire laser
       CMP    #WARP_TIME-8      ;        soon after start of warp
       BCS    .skipLaser
       LDA    INPT4-$30         ;       button pressed and..
       ORA    SwitchState       ;       ..not pressed before?
       BMI    .skipLaser        ;        no, skip!
       LDA    #32               ;        yes, fire laser, set start position of laser
       STA    LaserTop
       LDA    #6
       STA    LaserBottom
       STX    CXCLR             ;       clear collison registers
       LDX    #LASER_TIME       ;
       STX    LaserState        ;       enable laser
.contFireLaser:
       LDA    LaserBottom
       CLC
       ADC    #$03
       STA    LaserBottom
       LDA    LaserTop
       CLC
       ADC    #$02
       CMP    #NUM_LINES/2+4    ;       (=76)
       BCS    .limitLaserTop
       STA    LaserTop          ;       (34..74)
.limitLaserTop:
.skipLaser:

.skipUpdate0:
; set laser size:
       LDA    LaserState
       LSR
       LSR
       LSR
       TAX
       LDA    LaserSizeTab,X
       STA    NUSIZ0            ;       missile size only
       STA    NUSIZ1

; *** starfield anímation: ***
       LDA    SWCHA             ;       read joystick
       LSR
       LSR
       LSR
       LSR
       EOR    #$0F
       TAY
       BEQ    .noDirection
       STA    SS_Delay          ;       reset screensaver when joystick is moved (0..15)
.noDirection:

       LDA    NoGameScroll      ;       game just started or
       ORA    IsDocked          ;        ship docked at starbase?
       BEQ    .useJoystick      ;        no, use joystick direction
       LDY    #$00              ;        yes, ignore joystick
.useJoystick:
       STY    Temp
       LDA    IsDocked          ;        ship docked at starbase?
       BNE    .skipMoveStars    ;         yes, don't move stars
       DEC    StarMoveDelay
       BPL    .skipMoveStars

; calculate star speed:
       LDA    WarpTime
       BMI    .minSpeed
  IF OPTIMIZE
       NOP
       NOP
       NOP
       NOP
       NOP
  ELSE
       EOR    #$FF              ;       superfluos code,
       SEC                      ;        because this always results
       SBC    #$68              ;        in negative StarMoveDelay!
  ENDIF
.minSpeed:
       LSR
       LSR
       LSR
       SEC
       SBC    #16
       STA    StarMoveDelay     ;       9..0/-x

; move the starfield:
       LDX    #NUM_STARS-1
.loopMoveStars:
; move y-pos:
       LDA    StarPosY,X
       LSR
       LSR
       LSR                      ;       a = y-pos/8
       LDY    Temp              ;       y = joystick direction
       CLC
       ADC    StarDirYTab,Y     ;       = 0/2/4
       TAY
       LDA    StarMoveYTab,Y    ;       -6..+8
       CLC
       ADC    StarPosY,X
       STA    StarPosY,X
; move x-pos:
       LDA    StarPosX,X
       LSR
       LSR
       LSR
       LSR                      ;       a = x-pos/16
       TAY
       LDA    StarMoveXTab,Y    ;       -5..+5
       LDY    Temp              ;       y = joystick direction
       CLC
       ADC    StarDirXTab,Y
       CLC
       ADC    StarPosX,X
       STA    StarPosX,X
       DEX
       BPL    .loopMoveStars
.skipMoveStars:

; move visible objects (meteor, starbase, enemy, explosion; max. 2)
; move y-pos:
       LDX    #1
       LDY    Temp              ;       y = joystick direction
.loopMoveShapesY:
       LDA    ShapePosYLst,X
       CLC
       ADC    ShapeDirYTab,Y
       STA    ShapePosYLst,X
       DEX
       BPL    .loopMoveShapesY

; move x-pos: (there is only one x-pos for both possible shapes!)
       LDA    ShapePosX
       CLC
       ADC    ShapeDirXTab,Y
       STA    ShapePosX

.waitTim:
       LDY    INTIM
       BPL    .waitTim

       INC    FrameCnt
; screensaver routine (part 1/2):
       BNE    .exitSS_Delay
       INC    SS_Delay          ;       increase every 256th frame (~4 sec)
       BNE    .exitSS_Delay     ;       screensaver-mode enabled?
       SEC                      ;        yes, keep bit7 set
       ROR    SS_Delay
.exitSS_Delay:

       LDX    #$03
       STX    WSYNC
       STX    VSYNC             ;       enable VSYNC
       STX    VBLANK            ;       enabel VBLANK
;--------------- end of display kernel ---------------

; screensaver routine (part 2/2):
       LDY    #$FF
       LDA    #$00
       BIT    SS_Delay          ;       screensaver-mode enabled?
       BPL    .noScreenSaver    ;        no, use neutral values for SS_registers
       LDY    #$F7              ;        yes, mask highest intensity bit (dark colors only)..
       LDA    SS_Delay          ;        ..and slowly change colors
       ASL
.noScreenSaver:
       STY    SS_Mask
       STA    SS_XOR

       STA    WSYNC
       LDY    #$40
       STY    VSYNC
       STY    TIM64T
       LDA    LaserState
       CMP    #LASER_TIME-1
       BNE    .skipDecreaseHi
       LDA    #$01
       JSR    DecEnergyHi
.skipDecreaseHi:

; *** calculate starfield: ***
       LDX    #NUM_STARS-1
.loopStars:
       LDA    StarPosX,X
       CMP    #20               ;       SCREEN_WIDTH
       BCC    .replaceStar
       CMP    #136              ;       SCREEN_WIDTH
       BCS    .replaceStar
       LDA    StarPosY,X
       CMP    #NUM_LINES-MIN_DIST_Y;    >= 138?
       BCS    .replaceStar
       CMP    #MIN_DIST_Y+1     ;       <= 6?
       BCC    .replaceStar
.nextStar:
       DEX
       BPL    .loopStars
       JMP    .exitReplaceStar  ;       OPTIMIZE: replace with two BMI-branches

; replace out-of-bounds star:
.replaceStar:
       STX    Temp              ;       save replaced star index
       LDX    #NUM_STARS-1
.findLowerStar:
       LDA    StarPosY,X
       CMP    #NUM_LINES/2      ;       lower star?
       BCC    .lowerStarFound   ;        yes, goto found
       DEX
       BPL    .findLowerStar

.lowerStarFound:
       INX
       STX    Temp2             ;       save index of middle star + 1 (0..7/8?)
       LDX    Temp              ;
       CPX    Temp2             ;       replaced < middle+1
       BCC    .lowerHalfStar    ;        yes, lower

; for (x = replace-1; x >= middle+1; x--)
;   star[x+1] = star[x];
.loopMoveStarsNext:
       DEX
       BMI    .posNewStarY      ;       exit, if < 0 (needed if middle-id+1 = 0)
       CPX    Temp2
       BCC    .posNewStarY      ;       exit, if x < middle-id+1
       LDA    StarPosY,X
       STA    StarPosY+1,X
       LDA    StarPosX,X
       STA    StarPosX+1,X
       BCS    .loopMoveStarsNext;3      always taken jump

.posNewStarY:
       LDX    Temp2
       LDA    #NUM_LINES/2+11   ;
       STA    StarPosY,X
       CPX    #NUM_STARS/2      ;
       BCS    .loopUp_dY
       LDA    #NUM_LINES/2-9    ;
       STA    StarPosY,X
       DEX
  IF OPTIMIZE
       BCC    .loopDown_dY
       NOP
  ELSE
       JMP    .loopDown_dY
  ENDIF

.loopUp_dY:
; make sure, that y-distance >= 6 (kernel-limitation!):
       CLC
       ADC    #MIN_DIST_Y       ;       new y-pos[new] + 6 ..
       CMP    StarPosY+1,X      ;       .. < y-pos[new+1]?
       BCC    .setRandomStarX   ;        yes, ok
       LDA    StarPosX+1,X      ;        no, swap index
       STA    StarPosX,X
       LDA    StarPosY+1,X
       STA    StarPosY,X
       CLC
       ADC    #MIN_DIST_Y       ;       change y-pos[new] to..
       STA    StarPosY+1,X      ;       ..y-pos[new+1] + 6
       INX
       CPX    #NUM_STARS-1
       BCC    .loopUp_dY

; x-pos = middle of scrren +/- 32 pixel:
.setRandomStarX:
       JSR    NextRandom
       LDA    Random
       AND    #$3F              ;       a = 0..63
       CLC
       ADC    #[SCREEN_WIDTH-$3f]/2;    +48
       STA    StarPosX,X
       LDX    Temp
  IF OPTIMIZE
       BCC    .nextStar
       NOP
  ELSE
       JMP    .nextStar
  ENDIF

.lowerHalfStar:
       DEX                      ;       x = replace-1
       DEC    Temp2             ;       Temp2 = middle
; for (x = replace; x < middle; x++)
;   star[x] = star[x+1];
.loopMoveStarsPrev:
       INX
       CPX    Temp2
       BCS    .posNewStarY
       LDA    StarPosY+1,X
       STA    StarPosY,X
       LDA    StarPosX+1,X
       STA    StarPosX,X
       BCC    .loopMoveStarsPrev;3      always taken jump

.loopDown_dY: ; a = NUM_LINES/2-9
; make sure, that y-distance >= 6 (kernel-limitation!):
       SEC
       SBC    #MIN_DIST_Y       ;       new y-pos[new] - 6 ..
       CMP    StarPosY,X        ;       .. >= y-pos[new+1]?
       BCS    .gotoRandomStarX  ;        yes, ok
       LDA    StarPosX,X        ;        no, swap index
       STA    StarPosX+1,X
       LDA    StarPosY,X
       STA    StarPosY+1,X
       SEC
       SBC    #MIN_DIST_Y       ;       change y-pos[new] to..
       STA    StarPosY,X        ;       ..y-pos[new+1] - 6
       DEX
       BPL    .loopDown_dY
.gotoRandomStarX:
       INX
       BNE    .setRandomStarX
.exitReplaceStar:

; calculate StarMoveXLst:
       LDY    #$FF              ;       disable HMBx
       STY    Temp2             ;        in CalcPos1

       LDX    #NUM_STARS-1
.loopStars2:
       LDA    StarPosX,X
       CMP    #136
       BCC    .xPosOk
       LDA    #135
.xPosOk:
       JSR    CalcPos1
       STA    StarMoveXLst,X
       TYA
       ORA    StarMoveXLst,X
       STA    StarMoveXLst,X
       DEX
       BPL    .loopStars2

;*** check for map-mode: ***
       LDA    SwitchState
       BMI    .isMapMode
.skipMapJmp:
       JMP    .skipMoveMap

; *** bookkeeping for mad mode: ***
.isMapMode:
       LDA    NoGameScroll      ;       game running?
       BNE    .skipMapJmp       ;        no, skip

;*** move ship on map: ***
       LDA    SWCHA
       LSR
       LSR
       LSR
       LSR
       EOR    #$0F
       LDX    #MAP_WIDTH-1
.loopCheckBordersX:
       LDY    Mult6Tab,X
       CPY    WarpSectorIdx
       BNE    .notAtLeft
       AND    #MASK_LEFT
.notAtLeft:
       LDY    Mult6_1Tab,X
       CPY    WarpSectorIdx
       BNE    .notAtRight
       AND    #MASK_RIGHT
.notAtRight:
       DEX
       BPL    .loopCheckBordersX
       TAX
       BNE    .contMoveCursor
       STA    CursorDelay
       BEQ    .skipMoveCursor   ;3

.contMoveCursor:
       LDA    CursorDelay
       BEQ    .resetCursorDelay
       DEC    CursorDelay
       BPL    .skipMoveCursor
.resetCursorDelay:
       LDA    #16               ;       ~1/4 sec delay
       STA    CursorDelay
       LDA    WarpSectorIdx
       TAY
       CLC
       ADC    MoveTab,X
       BMI    .skipMoveCursor
       CMP    #NUM_SECTORS      ;       out of y borders?
       BCS    .skipMoveCursor   ;2³      yes ,don't move cursor

; move the cursor:
       STA    WarpSectorIdx
       TYA
       JSR    SetSectorIdNoShip
       LDA    WarpSectorIdx     ;       warp sector =
       CMP    ShipSectorIdx     ;        current sector?
       BEQ    .skipMoveCursor   ;        yes, don't move
       JSR    GetSectorId
       CLC
       ADC    #ID_SHIP
       TAY
       LDA    WarpSectorIdx
       JSR    SetSectorId

;*** calculate distance between current and target sector: ***
.skipMoveCursor:
; calculate y-pos of both sectors:
       LDY    #$01
.currentSector:
       STX    Temp
       STA    Temp2
       LDA    ShipSectorIdx,Y
       LDX    #$00
.loopDiv6:
       CMP    #MAP_WIDTH
       BCC    .exitDiv6
       INX
       SEC
       SBC    #MAP_WIDTH
       BPL    .loopDiv6
.exitDiv6:
       DEY
       BPL    .currentSector
; calculate y-distance of sectors:
       SEC
       SBC    Temp2
       BPL    .noNegY           ;       negative y-distance?
       EOR    #$FF
       CLC
       ADC    #$01
.noNegY:
       STA    Temp2

; calculate x-distance of sectors:
       TXA
       SEC
       SBC    Temp
       BPL    .noNegX           ;       negative x-distance?
       EOR    #$FF
       CLC
       ADC    #$01
.noNegX:
       SED
       CLC
       ADC    Temp2
       STA    WarpEnergy        ;       save total distance
       LDY    Damage+1          ;       warp damaged?
       CPY    #HI_DAMAGE
       BCC    .warpOk           ;        no, skip
       CLC                      ;        yes,
       ADC    WarpEnergy        ;        double energy use
.warpOk:
       CLD
       STA    WarpEnergy
       LDY    INPT4-$30         ;       fire button pressed?
       BMI    .skipMoveMap      ;        no, skip warp
       LDY    WarpSectorIdx
       CPY    ShipSectorIdx
       BEQ    .skipMoveMap
       JSR    GetShipSectorId   ;       remove
       SEC                      ;        ship
       SBC    #ID_SHIP          ;        from
       TAY                      ;        current
       JSR    SetShipSectorId   ;        sector
       LDA    WarpSectorIdx     ;        and to
       STA    ShipSectorIdx     ;        target sector
       LDA    SwitchState       ;       switch from
       EOR    #$80              ;        map-mode to
       STA    SwitchState       ;        cockpit-mode
       LDA    #$FE              ;       set enemy at
       STA    ShapePosZLst      ;        maximum distance-1
       LDA    #WARP_TIME        ;       start warping
       STA    WarpTime          ;        to target sector
       LDA    #$00
       STA    MeteorEnabled
       STA    IsDocked
.skipMoveMap:

;*** create new enemy: ***
       LDA    EnemySound        ;       enemy explision finished?
       CMP    #$01
       BNE    .skipNewEnemy     ;        no, skip new enemy
; calculate random positions:
       LDA    Random
       AND    #$7F
       STA    ShapePosYLst
       JSR    NextRandom
       LDA    MeteorEnabled     ;       if enemy fire is still enabled..
       BNE    .keepPosX         ;       ..keep x-pos (hack!)
       LDA    Random
       AND    #$7F
       STA    ShapePosX
.keepPosX:
       LDA    #$FC              ;       set enemy at
       STA    ShapePosZLst      ;        maximum distance-3
.skipNewEnemy:

;*** move objects: ***
       LDA    FrameCnt          ;       even frame
       AND    #$01              ;       and
       ORA    NoGameScroll      ;       game running?
       BNE    .skipMoveObjects  ;        no, skip move shapes
       LDX    #$05
.loopMoveObjects:
       LDA    MoveLst,X
       CLC
       ADC    ShapePosYLst,X
       STA    ShapePosYLst,X
       DEX
       BPL    .loopMoveObjects
.skipMoveObjects:

       LDX    #$01
.loopSetShapePtr:
       LDA    ShapePosZLst,X
       CMP    #FIRE_DISTANCE
       BCC    .limitDistance
       LDA    #FIRE_DISTANCE
.limitDistance:
       LSR
       LSR
       LSR
       LSR
       TAY
       STX    Temp
       LDX    WarpTime
       BNE    .noBase
       JSR    GetShipSectorId
       CMP    #ID_BASE+ID_SHIP
       BNE    .noBase
       TYA
  IF OPTIMIZE
       ADC    #OFS_BASE-1
       NOP
  ELSE
       CLC
       ADC    #OFS_BASE
  ENDIF
       TAY
.noBase:
       LDX    Temp
  IF OPTIMIZE
       BEQ    .noMeteor
       NOP
       NOP
  ELSE
       CPX    #$01
       BNE    .noMeteor
  ENDIF
       TYA
       CLC
       ADC    #OFS_METEOR
       TAY
.noMeteor:
       LDA    ShapeHeightTab,Y
       STA    ShapeHeightLst,X
       LDA    ShapePtrTab,Y
       STA    ShapePtrLst,X
       DEX
       BPL    .loopSetShapePtr

;*** update all variables: ***
       LDA    NoGameScroll      ;       game running?
       BEQ    .doUpdate1        ;        yes, update
       JMP    skipUpdate1       ;        no, skip update

.doUpdate1:
; decrease energy:
       LDA    FrameCnt
       AND    #$3F
       BNE    .skipDecreaseLo
       LDA    #$01              ;       decrease energie every 64th frame
       JSR    DecEnergyLo
.skipDecreaseLo:

       LDA    MeteorEnabled
       BNE    .noMeteorEnabled
       STA    ShapePosYLst+1
.noMeteorEnabled:
       JSR    GetShipSectorId
       STA    Temp2
       LDA    WarpTime
       BEQ    .noWarp
       LDA    FrameCnt
       AND    #$07
       BNE    .skipDecWarp
       LDA    WarpEnergy        ;       decrease energie every 8th frame when warping
       JSR    DecEnergyLo
.skipDecWarp:
       LDA    #$FF              ;       set enemy (-> meteor) at
       STA    ShapePosZLst      ;        maximum distance
       STA    EnemyMoveZ        ;        and hi shape pointer = $ff
       BNE    .contWarp         ;3

.noWarp:
       LDA    Temp2
       CMP    #ID_BASE+ID_SHIP
       BEQ    .atBaseSector     ;       makes no sense to me! (.skipNewFire?)
       CMP    #ID_SHIP
       BNE    .contWarp
       LDA    #$00              ;       if ship only,
       STA    ShapePosYLst      ;        set y-pos = 0 (-> no hit)
.contWarp:
       LDA    EnemySound
       ORA    MeteorSound
       ORA    MeteorEnabled
       BNE    .skipNewFire
       LDA    FrameCnt          ;       fire only
       AND    #$7F              ;        every 128th frame (~2 sec)
       BNE    .skipNewFire
       JSR    CalcRandomMove
.atBaseSector:
       LDA    WarpTime
       CMP    #80               ;       warp soon over?
       BCS    .newFire          ;        no, new meteor
       LDA    Temp2
       CMP    #ID_BASE+ID_SHIP
       BEQ    .skipNewFire
       CMP    #ID_SHIP
       BEQ    .skipNewFire
       LDA    ShapePosZLst      ;       enemy to..
       CMP    #FIRE_DISTANCE+1  ;       ..far away?
       BCS    .skipNewFire      ;        yes, skip fire
.newFire:
       LDA    #0                ;       enemy fires or new meteor
       STA    MeteorMoveY       ;       no y-movement
       LDX    Level
       LDA    LevelDiffTab,X
       STA    MeteorMoveZ
       STA    MeteorEnabled     ;       <> 0
       LDA    ShapePosZLst      ;       copy enemy distance
       STA    ShapePosZLst+1    ;        to enemy fire/meteor distance
       LDY    ShapePosYLst
       INY                      ;       copy enemy y-pos
       STY    ShapePosYLst+1    ;        to enemy fire/meteor y-pos
.skipNewFire:

; check, if the meteor/enemy fire is inside the hitting bounds:
       LDY    #$02
       LDX    MeteorEnabled
.loop:
       LDA    ShapePosYLst+1    ;       load y-pos[1]
       CPY    #$02              ;       check y-bounds?
       BNE    .skipLoadX        ;        yes, skip
       LDA    ShapePosX         ;        no, load x-pos
.skipLoadX:
       CMP    BoundsXYTab,Y
       BCS    .inLowerBound1
       LDX    #$00
.inLowerBound1:
       CMP    BoundsXYTab+1,Y
       BCC    .inUpperBound1
       LDX    #$00
.inUpperBound1:
       DEY
       DEY
       BPL    .loop
       STX    MeteorEnabled     ;       0/-5..-2
  IF OPTIMIZE
       TXA
       NOP
  ELSE
       LDA    MeteorEnabled
  ENDIF
       BEQ    .notHitXY
       LDA    ShapePosZLst+1
       CMP    #6                ;       distance < 6 ?
       BCS    .notHitZ          ;        no, not hit
       LDY    #$7F
       STY    BaseSound
       JSR    DecEnergyHi       ;       -500
       LDA    #$00              ;       disable
       STA    MeteorEnabled     ;         enemy fire/meteor
       LDA    Damage            ;       shield damaged?
       AND    #$0F
       CMP    #OFS_S
       BNE    .randomDamage     ;        no, continue
       JMP    GameOver          ;        yes, game over!

.randomDamage:
       LDA    Random
       CMP    #$40              ;       25% chance
       BCS    .skipDamage
       AND    #$03
       TAX                      ;       x = 0..3
       LSR
       TAY                      ;       y = 0..1
       LDA    DamageTab,X
       AND    DamageMask+1,X
       STA    Temp
       EOR    Damage,Y
       AND    DamageMask+1,X
       BEQ    .skipDamage       ;       item was already damaged
       LDA    Damage,Y
       AND    DamageMask,X
       ORA    Temp
       STA    Damage,Y
       LDA    #$60
       STA    AudF0Val
.skipDamage:

; meteor/enemy fire hit or is out of bounds, set maximum distance:
.notHitXY:
       LDA    #$FC              ;       set meteor/enemy fire
       STA    ShapePosZLst+1    ;        at maximum distance-3
.notHitZ:

; invert enemy movement, if out of bounds: (->EnemyMoveY, EnemyMoveX, EnemyMoveZ)
       LDY    #$04
.loopCorrect:
       LDA    ShapePosYLst,Y    ;       ShapePosYLst, ShapePosX, ShapePosZLst
       CMP    BoundsXYTab,Y
       BCS    .inLowerBound0
; below lower bound:
       LDX    BoundsMoveTab,Y   ;       always -1 !?
       STX    MoveLst,Y
       BNE    .inUpperBound0

.inLowerBound0:
       CMP    BoundsXYTab+1,Y
       BCC    .inUpperBound0
; above upper bound:
       LDX    BoundsMoveTab+1,Y ;       always 1 !?
       STX    MoveLst,Y
.inUpperBound0:
       DEY
       DEY
       BPL    .loopCorrect

; check collisons (enemy, meteor or starbase)
       LDA    CXM0P-$30
       ORA    CXM1P-$30
       AND    #$C0
       BNE    .doCollisions
.skipCollisionsJmp:
       JMP    .skipCollisions

.doCollisions:
       STA    CXCLR

; check, if enemy fire/meteor is hit:
       LDA    ShapePosX         ;       check if meteor is somewhere in the middle
       CMP    #70
       BCC    .skipCollisionsJmp
       CMP    #94
       BCS    .skipCollisionsJmp

       LDA    LaserState        ;       laser fired?
       BEQ    .skipMeteor       ;        no, skip
       LDA    MeteorEnabled
       BEQ    .skipMeteor
       LDA    ShapePosYLst+1
       CMP    #$45
       BCC    .skipMeteor
       SEC
       SBC    $EA
       CMP    #$4C
       BCS    .skipMeteor
       LDA    #$F0              ;       set meteor/enemy fire
       STA    ShapePosZLst+1    ;        at maximum distance-15
       LDA    #$00              ;       stop the
       STA    MeteorMoveY       ;        movement
       STA    MeteorMoveX       ;        of the
       STA    MeteorMoveZ       ;        meteor
       STA    MeteorEnabled
       LDA    #$5F
       STA    MeteorSound
       BNE    .skipCollisionsJmp
.skipMeteor:

; check, if enemy fighter is hit:
       LDA    EnemySound
       ORA    WarpTime
       BNE    .skipCollisions
       LDA    ShapePosYLst
       CMP    #69               ;       [NUM_LINES]
       BCC    .skipCollisions
       SEC
       SBC    ShapeHeightLst
       CMP    #76               ;       [NUM_LINES]
       BCS    .skipCollisions
       LDA    Temp2
       CMP    #ID_BASE+ID_SHIP
       BNE    .contEnemyHit
       LDA    ShapePosZLst      ;       base near and..
       ORA    IsDocked          ;       ..ship not docked?
       CMP    #$0F
       BCS    .skipCollisions   ;        no, skip docking
       SED
       LDA    DockCount         ;       increase docking-counter
       CLC
       ADC    #$01
       STA    DockCount
       CLD
       LDA    #$0F
       STA    AudF0Val
       STA    ShapePosZLst      ;       fix starbase distance
       LDA    #$99
       STA    IsDocked
       STA    EnergyHi          ;       refuel
       STA    EnergyLo
       LDA    #NO_DAMAGE
       STA    Damage            ;       repair
       STA    Damage+1
       BNE    .stopEnemy

.contEnemyHit:
       LDA    LaserState        ;       laser fireing?
       BEQ    .skipCollisions   ;        no, skip

; GOTCHA! (the enemy is hit):
       LDA    #$F0              ;       set enemy at
       STA    ShapePosZLst      ;        maximum distance-15
       LDA    #$7F
       STA    EnemySound
       JSR    GetShipSectorId   ;       decrease enemies in sector
       SEC
       SBC    #$01
       TAY
       JSR    SetShipSectorId
       SED
       SEC                      ;       decrease total number of enemies
       LDA    Enemies
       SBC    #$01
       STA    Enemies
       CLD
       BNE    .stopEnemy
       JMP    GameOver

.stopEnemy:
       LDA    #0
       STA    EnemyMoveY
       STA    EnemyMoveX
       STA    EnemyMoveZ
.skipCollisions:

skipUpdate1:
       LDX    #0
       LDA    ShapePosX
       JSR    SetPosX           ;       player 0
       INX
       LDA    ShapePosX
       CLC
       ADC    #8
       JSR    SetPosX           ;       player 1 (= player 0 + 8)
       INX
       LDA    #163              ;       [NUM_LINES]
       JSR    SetPosX           ;       missile 0
       INX
       LDA    #6                ;       [NUM_LINES]
       JSR    SetPosX           ;       missile 1
       STA    WSYNC
       STA    HMOVE

; *** sound routines: ***
; update sound variables:
       LDX    #2
.loopDecSound:
       LDA    MeteorSound,X
       BEQ    .skipSound
       DEC    MeteorSound,X
.skipSound:
       DEX
       BPL    .loopDecSound

; check for damage or docking sound:
       LDA    AudF0Val
       BEQ    .laserSound
       DEC    AudF0Val
       STA    AUDF0
       LDX    #$0C
       STX    AUDC0
       BNE    .setAUDV0

; generate laser sound:
.laserSound:
       LDX    #$08
       STX    AUDC0
       LDA    LaserState        ;       laser fireing?
       BEQ    .spaceSound       ;        no, skip

       LDA    Random
       AND    #$03
       STA    AUDF0
       LDA    #$0F
       STA    AUDV0
       BNE    .checkMeteorSound

; generate space sound:
.spaceSound:
       LDX    #$00
       LDA    NoGameScroll      ;       game running?
       BNE    .lowSpaceSound
       LDX    #$08
       LDA    WarpTime
       BNE    .warpSound
       LDA    #$FF
       LDX    #$03
       BNE    .lowSpaceSound

.warpSound:
       CMP    #22
       BCS    .lowSpaceSound
       EOR    #$FF
       LDX    #$06
.lowSpaceSound:
       LSR
       LSR
       LSR
       STA    AUDF0
.setAUDV0:
       STX    AUDV0

; sound for incoming enemy fire/meteor:
.checkMeteorSound:
       LDA    MeteorEnabled
       BEQ    .noMeteor1
       LDA    ShapePosZLst+1
       LSR
       LSR
       LSR
       STA    AUDF1
       LSR
       EOR    #$8F
       STA    AUDV1
       LDA    #$08
       STA    AUDC1
       BNE    .exitSound

.noMeteor1:
; generate explosion sound:
       LDA    EnemySound
       ORA    MeteorSound
       ORA    BaseSound
       BEQ    .playTunes
       LSR
       LSR
       LSR
       STA    AUDV1
       LDA    Random
       ORA    #$18
       STA    AUDF1
       LDA    #$08
       STA    AUDC1
       BNE    .exitSound

; play victory or lost tunes:
.playTunes:
       LDA    TuneIndex         ;       play tunes
       BEQ    .noTune           ;        no, skip
       LDA    FrameCnt
       AND    #$07
       BNE    .exitSound
       LDA    #$0C
       STA    AUDC1
       DEC    TuneDelay
       LDA    TuneDelay
       BEQ    .noTune
       BPL    .exitSound
       DEC    TuneIndex
       LDX    TuneIndex
       LDA    AUDF1Tab,X
       BNE    .skipStopTune
       STA    TuneIndex         ;       TuneIndex = 0
       BEQ    .noTune
.skipStopTune:
       STA    AUDF1
       LSR
       LSR
       LSR
       LSR
       LSR
       STA    TuneDelay
       LDA    #$08
.noTune:
       STA    AUDV1
.exitSound:

;*** prepare missile positioning: ***
       STA    HMCLR
       LDA    #$10              ;       -1
       STA    HMM0
       LDA    #$F0              ;       +1
       STA    HMM1
       JMP    MainLoop

DisplayMapRow SUBROUTINE
       LDY    #$07
.loopDisplay:
       STA    WSYNC
       LDA    (ShapePtr),Y
       STA    GRP0
       LDA    (ShapePtr+6),Y
       STA    GRP1
       LDA    (ShapePtr+10),Y
       STA    Temp
       LDA    (ShapePtr+4),Y
       TAX
       LDA    (ShapePtr+2),Y
       STA    GRP0
       NOP
       STX    GRP0
       LDX    Temp
       LDA    (ShapePtr+8),Y
       STA    GRP1
       NOP
       STX    GRP1
       DEY
       BNE    .loopDisplay
       STY    GRP0
       STY    GRP1
       RTS

DisplayCopyright SUBROUTINE
       LDY    #$0F
       LDA    #$07
       STA    $A4
       LDA    NoGameScroll
       LSR
       LSR
       LSR
       CMP    #$14              ;       scroll-animation
       BCS    .ok
       LDY    #$07
       CMP    #$0C
       BCC    .ok
       SBC    #$04
       TAY
.ok:
       STY    Temp2
       JMP    .contCopyright

DisplayMACC:
       LDA    #$06
       STA    Temp2
       STA    $A4
.contCopyright:
       STA    WSYNC
       LDA    #$01
       STA    VDELP0
       STA    VDELP1
       LDX    #10
.wait:
       DEX
       BPL    .wait
       LDA    $00               ;3      just wait 3 cycles
.loopDisplay:
       LDY    Temp2
       LDA    (ShapePtr+10),Y
       STA    $0188             ; = Temp
       LDA    (ShapePtr+8),Y
       TAX
       LDA    (ShapePtr),Y
       STA    GRP0
       LDA    (ShapePtr+2),Y
       STA    GRP1
       LDA    (ShapePtr+4),Y
       STA    GRP0
       LDA    (ShapePtr+6),Y
       LDY    Temp
       STA    GRP1
       STX    GRP0
       STY    GRP1
       STA    GRP0
       DEC    Temp2
       DEC    $A4
       BPL    .loopDisplay
       LDA    #$00
       STA    GRP0
       STA    GRP1
       STA    GRP0
       STA    GRP1
       STA    VDELP0
       STA    VDELP1
       RTS

SetSectorIdNoShip SUBROUTINE
; remove players-ship from SectorId:
; a = y = SectorIdx
; (this routine could be much more optimized!)
       CMP    ShipSectorIdx
       BEQ    .exit

; remove ship from ship-nibble:
  IF OPTIMIZE
       LSR
       NOP
  ELSE
       CLC
       ROR                      ;       SectorIdx/2
  ENDIF
       TAX
       LDA    SectorList,X
       BCC    .loNibble1
       LSR
       LSR
       LSR
       LSR
.loNibble1:
       AND    #$0F
       SEC
       SBC    #ID_SHIP
       STA    Temp              ;       save nibble without ship

; get other nibble:
       TYA
  IF OPTIMIZE
       LSR
       NOP
  ELSE
       CLC
       ROR                      ;       SectorIdx/2
  ENDIF
       TAX
       LDA    SectorList,X
       BCC    .loNibble2
       AND    #$0F
       ASL    Temp
       ASL    Temp
       ASL    Temp
       ASL    Temp
       ORA    Temp
  IF OPTIMIZE
       BCC    .setId
       NOP
  ELSE
       JMP    .setId
  ENDIF
.loNibble2:

; combine both nibbles
       AND    #$F0
       ORA    Temp
.setId:
       STA    SectorList,X      ;       save new SectorId
.exit:
       RTS

GameInit SUBROUTINE
       LDY    #$00
       STY    NUSIZ0
       STY    NUSIZ1
.clearLoop:
       STY    $00,X
       INX
       CPX    #$B8
       BNE    .clearLoop
       LDX    #$28
.initLoop:
       LDA    InitTab,X
       STA    $B8,X
       DEX
       BPL    .initLoop
       LDY    Level
       LDA    EnemyNumTab,Y
       STA    Enemies
       LDA    LevelPtrTab,Y
       STA    LevelPtrLo

       LDX    #NUM_SECTORS/2-1
.sectorInitLoop:
       LDA    SectorInitTab,X
       STA    SectorList,X
       DEX
       LDA    SectorInitTab,X   ;       the number of enenies
       ORA    Level             ;       is increased by ORing
       STA    SectorList,X      ;       every 4th sector with level
       DEX
       BPL    .sectorInitLoop
       LDA    SWCHB             ;       read switches
       LSR
       AND    #%01100100        ;       mask B/W and both difficulty switches
       LDY    NoGameScroll
       BEQ    .noGame
       ORA    #%10000000        ;       set bit7 to prevent repeat
.noGame:
       STA    SwitchState
       RTS

NextRandom SUBROUTINE
; quite good pseudo random generator:
       LDA    Random
       BNE    .skipInit
       LDA    #$FF
.skipInit:
       ASL
       ASL
       ASL
       EOR    Random
       ASL
       ROL    Random
       RTS

CalcPos1 SUBROUTINE
       CLC
       ADC    #$F0
       JMP    .contPos1

SetPosX:
       LDY    #$00
       CLC
       ADC    #$25
       STY    Temp2
.contPos1:
       TAY
       AND    #$0F
       STA    Temp
       TYA
       LSR
       LSR
       LSR
       LSR
       TAY
       CLC
       ADC    Temp
       CMP    #$0F
       BCC    .ok
       SBC    #$0F
       INY
.ok:
       EOR    #$07
       ASL
       ASL
       ASL
       ASL
       BIT    Temp2
       BPL    .setPos
       RTS

.setPos:
       STA    HMP0,X
       STA    WSYNC
.wait:
       DEY
       BPL    .wait
       STA    RESP0,X
       RTS

SetupScore SUBROUTINE
       NOP
       LDA    #$A0
       STA    HMP0
       LDA    #$B0
       STA    HMP1
       STA    RESP0
       STA    RESP1
       STA    WSYNC
       STA    HMOVE
; determine background color:
       JSR    GetShipSectorId
       LDY    #GREEN
       CMP    #ID_SHIP
       BEQ    .noEnemy
       LDY    #BLUE
       CMP    #ID_BASE+ID_SHIP
       BEQ    .noEnemy
       LDY    #RED
.noEnemy:
       TYA
       EOR    SS_XOR
       AND    SS_Mask
       TAX

       LDY    #$80
       STA    HMCLR
       STA    WSYNC
       STA    HMOVE

; blink background when energy is low:
       LDA    FrameCnt
       AND    #$1F
       CMP    #$0F
       BCS    .noScreenSaver
       LDA    EnergyHi
       CMP    #$10
       BCS    .noScreenSaver
       LDY    #$26
.noScreenSaver:

       TYA
       EOR    SS_XOR
       AND    SS_Mask
       STA    WSYNC
       STX    COLUBK
       STA    COLUPF
       LDX    #%1
       STX    CTRLPF            ;       reflect playfield
       DEX
       STX    GRP0
       STX    GRP1
       DEX
       STX    PF2
       LDA    #%011             ;       3 copies close
       STA    NUSIZ0
       STA    NUSIZ1

; setup hi shape pointer:
       LDX    #12-2
       LDA    #$FF
.loop:
       STA    ShapePtr+1,X
       DEX
       DEX
       BPL    .loop
       RTS

GetShipSectorId:
       LDA    ShipSectorIdx
GetSectorId SUBROUTINE
; returns state of sector a in a:
       CLC
       ROR
       TAX
       LDA    SectorList,X
       BCC    .lowNibble
       LSR
       LSR
       LSR
       LSR
.lowNibble:
       AND    #$0F
       RTS

SetShipSectorId:
       LDA    ShipSectorIdx
SetSectorId SUBROUTINE
       STY    Temp
       CLC
       ROR
       TAX
       LDA    SectorList,X
       BCC    .lowNibble
       AND    #$0F
       ASL    Temp
       ASL    Temp
       ASL    Temp
       ASL    Temp
       ORA    Temp
       JMP    .set

.lowNibble:
       AND    #$F0
       ORA    Temp
.set:
       STA    SectorList,X
       RTS

CalcRandomMove SUBROUTINE
       LDY    #$04
.loop  JSR    NextRandom
       LDA    Random
       AND    #$07
       TAX
       LDA    RandomMoveTab,X
       STA    MoveLst,Y
       DEY
       BPL    .loop
       RTS

DecEnergyLo SUBROUTINE
       STA    Temp
       SED
       SEC
       LDA    EnergyLo
       SBC    Temp
       STA    EnergyLo
       LDA    EnergyHi
       SBC    #$00
       JMP    .checkEmpty

DecEnergyHi:
       STA    Temp
       LDA    EnergyHi
       SEC
       SED
       SBC    Temp
       CLD
.checkEmpty:
       BCS    .notEmpty
       LDA    #$00
       STA    EnergyLo
       STA    EnergyHi
       PLA
       PLA
       JMP    GameOver

.notEmpty:
       STA    EnergyHi
       CLD
       RTS

GameOver SUBROUTINE
       LDY    #12               ; tune index for lost
       SED
       SEC
       LDX    Level
       LDA    EnemyNumTab,X     ; number of enemies in level $31
       SBC    Enemies           ; number of remaining enemies
       CMP    EnemyNumTab,X
       BNE    .gameLost
       LDY    #18               ; tune index for victory
       CLC
       ADC    LevelScoreTab,X   ; = $80     level-score $49
.gameLost:
       STY    TuneIndex         ; save tune index
       CLC
       ADC    NumBases          ; = $86     + 5 * number of remaining bases+2
       ADC    NumBases          ; = $92
       ADC    NumBases          ; = $98
       ADC    NumBases          ; = $04
       ADC    NumBases          ; = $11     C=1!
       SEC
       SBC    #$10              ; = $01
       SEC
       SBC    DockCount         ; = $00
       BCS    .posScore1
       LDA    #$00
.posScore1:
       STA    ScoreHi
       LDA    #$00
       SEC
       SBC    StarDateLo
       STA    ScoreLo
       DEC    NoGameScroll
       LDA    ScoreHi
       SBC    StarDateHi
       BCS    .posScore2
       LDA    #0
.posScore2:
       STA    ScoreHi           ;       Score = Enemies + BaseScore-$20 + 5*Bases - $10 - Docking - StarDate
       LDA    #0
       STA    MeteorEnabled
       STA    LaserTop
       STA    LaserBottom
       STA    ShapePosYLst
       STA    ShapePosYLst+1
       STA    LaserState
       CLD
       JMP    skipUpdate1


;===============================================================================
; R O M - T A B L E S
;===============================================================================

BaseDirTab:                             ; LFC39
       .byte MOVE_RIGHT|MOVE_DOWN
       .byte MOVE_LEFT |MOVE_UP
       .byte MOVE_DOWN                  ; the next byte ($09 = %1001 = MOVE_RIGHT|MOVE_UP) us used too!
EnemyNumTab:
       .byte $09, $17, $23, $31         ; bcd-numbers of enemies/level

BaseThreatTab:                          ; damage of base-shields/round
       .byte 0, 5, 10, 15               ;  without player in sector
       .byte 0                          ;  (dummy)
       .byte 0, 5, 10, 15               ;  with player in sector

AUDF1Tab:
       .byte $00, $FE, $3F, $7E, $3E, $7A, $3A, $79, $FE, $3E, $7E, $FE     ; lost-tune
       .byte $00, $EC, $2B, $EE, $73, $FD                                   ; victory-tune
       .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; map organisation:
; 30 31 32 33 34 35
; 24(25)26 27 28(29)
; 18 19 20 21 22 23
; 12 13 14 15 16 17
; 06 07 08 09(10)11
; 00(01)02 03 04 05

BasePositionTab:
       .byte MAP_WIDTH*1 + 4    ; 10, lower right
       .byte MAP_WIDTH*4 + 1    ; 25, upper left
       .byte MAP_WIDTH*0 + 1    ; 01, lower left
       .byte MAP_WIDTH*4 + 5    ; 29, upper right

BaseSectorsTab:         ; numbers of sectors arround the starbase
       .byte   3,  4,  5,  9, 11, 15, 16, 17
       .byte  18, 25, 20, 24, 26, 30, 31, 32    ; BUG! (25=$19 should be 19=$13! wrong '$' ?)
       .byte   1,  1,  1,  0,  2,  6,  7,  8
       .byte  22, 23, 29, 29, 28, 34, 35, 29

StarDirYTab:    ; joystick causes additional y-move: (index-change of StarMoveYTab)
       .byte 2, 4, 0, 2, 2, 4, 0, 2, 2, 4       ; $FC8B

Mult6Tab:       ; MAP_WIDTH*n   (n = 0..MAP_WIDTH-1)
       .byte  0, 6,12,18,24,30
Mult6_1Tab:     ; MAP_WIDTH*n-1 (n = 0..MAP_WIDTH-1)
       .byte  5,11,17,23,29,35

PFBKColTab:
       .byte WHITE                      ; normal
       .byte BLACK                      ; meteor hit
       .byte BLUE                       ; enemy hit
       .byte RED                        ; own hit
       .byte ORANGE

StatePtrTab:
       .byte <LetterD                   ; offset D(amage)
       .byte <LetterE                   ; offset E(nergy)
       .byte <LetterS                   ; offset S(hield)
       .byte <LetterW                   ; offset W(arp)
LevelPtrTab:
       .byte <LetterE                   ; offset E(nsign)
       .byte <LetterL                   ; offset L(eader)
       .byte <LetterW                   ; offset W(ing Commander)
       .byte <LetterS                   ; offset S(tarmaster)

LevelDiffTab:                           ; $FCAE
       .byte -2, -3, -4, -5
LevelScoreTab:                          ; bcd-level-score - $20
       .byte $11, $23, $37, $49

StarMoveXTab:
       .byte -5,-4,-3,-2,-1, 1, 2, 3, 4, 5

BoundsXYTab:
       .byte 10, 134                    ; bounds x-pos
       .byte 11, 158                    ; bounds y-pos
       .byte  4, 176

BoundsMoveTab:
       .byte  1,-1, 1,-1, 1,-1

MapShapePtrTab:
       .byte <Map0-1,       <Map1-1,       <Map2-1,       <Map3-1,       <MapBase-1             ; $FF00 + x
       .byte <Map0Cursor-1, <Map1Cursor-1, <Map2Cursor-1, <Map3Cursor-1, <MapBaseCursor-1
CopyrightPtrTab:                        ; $FCD6
       .word Copyright0
       .word Copyright1
       .word Copyright2
       .word Copyright3
       .word Copyright4
       .word Copyright5

InitTab:
       .byte 32                         ; LevelDelay
       .byte NO_DAMAGE, NO_DAMAGE       ; Damage
       .byte $99, $99                   ; Energy
       .byte $00, $00                   ; Stardate
       .byte $00, $00                   ; WarpEnergy
       .byte $AA, $AA                   ; Score (doesn't matter)
       .byte 11                         ; ShipSectorIdx
       .byte 11                         ; WarpSectorIdx
       .byte $FF, $FF, $FF, $FF         ; BaseShield
       .byte NUM_BASES+2                ; NumBases
       .byte  11, 25, 55, 71            ; StarPosY (lower)
       .byte   85,101,115,131           ;          (upper)
       .byte  20,130, 50,110            ; StarPosX (lower)
       .byte   75, 120, 65, 30          ;          (upper)
       .byte 0                          ; $da ???
       .byte NUM_BASES-1                ; ThreatedBase
       .byte 8-1                        ; BaseSector
       .byte 4                          ; WalkDelay
       .byte NUM_SECTORS                ; WalkSectorIdx

MoveTab:
       .byte 0, MAP_WIDTH, -MAP_WIDTH, 0, -1, MAP_WIDTH-1, -MAP_WIDTH-1, 0, 1, MAP_WIDTH+1, -MAP_WIDTH+1

SectorInitTab:  ; 0..35
       .byte $42, $00, $00              ; 2 B . . . .
       .byte $00, $01, $54              ; . . 1 . B x
       .byte $00, $00, $00              ; . . . . . .
       .byte $00, $10, $00              ; . . . 1 . .
       .byte $40, $00, $40              ; . B . . . B
       .byte $00, $32                   ; . . 2 3 . .   (the next byte is shared!)

ShapeDirYTab:
       .byte  0,  1, -1,  0,  0,  1, -1,  0,  0,  1, -1
RandomMoveTab:
       .byte -1, -1, -1, -1,  0,  1,  1,  1

ShapePtrTab:
       .byte <Fighter0, <Fighter1, <Fighter2, <Fighter3, <Fighter4
       .byte   <TwoPixel, <OnePixel, <OnePixel, <OnePixel, <OnePixel, <OnePixel, <NoPixel
BasePtrTab:
       .byte <Base0, <Base1, <Base2, <Base3, <Base4, <FourPixel, <TwoPixel
       .byte   <OnePixel, <OnePixel, <OnePixel, <OnePixel, <OnePixel
MeteorPtrTab:
       .byte <Meteor0, <Meteor1, <Meteor2, <Meteor3, <Meteor4, <Meteor5, <Meteor6
       .byte   <FourPixel, <ThreePixel, <TwoPixel, <OnePixel, <NoPixel

OFS_BASE   = BasePtrTab   - ShapePtrTab
OFS_METEOR = MeteorPtrTab - ShapePtrTab

ShapeHeightTab:
       .byte 11,  9,  7,  5, 3, 2, 1, 1, 1, 1, 1, 1     ; enemy fighter
       .byte 11,  9,  7,  5, 3, 3, 2, 1, 1, 1, 1, 1     ; starbase
       .byte 24, 20, 16, 12, 8, 6, 4, 3, 3, 2, 1, 1     ; meteor/explosion

StarMoveYTab:
       .byte -6,-6,-6,-6,-6,-4,-4,-4,-2,-2,-2           ; $FD80
       .byte  2, 2, 2, 4, 4, 4, 6, 6, 6, 8, 8, 8        ; $FD8B

DamageTab:
       .byte OFS_S, OFS_L<<4, OFS_R, OFS_W<<4
DamageMask:
       .byte $F0
       .byte $0F, $F0, $0F, $F0

; Copyright 1982 Activision:
Copyright0:
       .byte $00 ; |        | $FDA0
       .byte $00 ; |        | $FDA1
       .byte $00 ; |        | $FDA2
       .byte $00 ; |        | $FDA3
       .byte $00 ; |        | $FDA4
       .byte $00 ; |        | $FDA5
       .byte $00 ; |        | $FDA6
       .byte $00 ; |        | $FDA7
       .byte $00 ; |        | $FDA8
       .byte $00 ; |        | $FDA9
       .byte $F7 ; |XXXX XXX| $FDAA
       .byte $95 ; |X  X X X| $FDAB
       .byte $87 ; |X    XXX| $FDAC
       .byte $80 ; |X       | $FDAD
       .byte $90 ; |X  X    | $FDAE
       .byte $F0 ; |XXXX    | $FDAF
Copyright1:
       .byte $AD ; |X X XX X| $FDB0
       .byte $A9 ; |X X X  X| $FDB1
       .byte $E9 ; |XXX X  X| $FDB2
       .byte $A9 ; |X X X  X| $FDB3
       .byte $ED ; |XXX XX X| $FDB4
       .byte $41 ; | X     X| $FDB5
       .byte $0F ; |    XXXX| $FDB6
       .byte $00 ; |        | $FDB7
       .byte $47 ; | X   XXX| $FDB8
       .byte $41 ; | X     X| $FDB9
       .byte $77 ; | XXX XXX| $FDBA
       .byte $55 ; | X X X X| $FDBB
       .byte $75 ; | XXX X X| $FDBC
       .byte $00 ; |        | $FDBD
       .byte $00 ; |        | $FDBE
       .byte $00 ; |        | $FDBF
Copyright2:
       .byte $50 ; | X X    | $FDC0
       .byte $58 ; | X XX   | $FDC1
       .byte $5C ; | X XXX  | $FDC2
       .byte $56 ; | X X XX | $FDC3
       .byte $53 ; | X X  XX| $FDC4
       .byte $11 ; |   X   X| $FDC5
       .byte $F0 ; |XXXX    | $FDC6
       .byte $00 ; |        | $FDC7
       .byte $03 ; |      XX| $FDC8
       .byte $00 ; |        | $FDC9
       .byte $4B ; | X  X XX| $FDCA
       .byte $4A ; | X  X X | $FDCB
       .byte $6B ; | XX X XX| $FDCC
       .byte $00 ; |        | $FDCD
       .byte $08 ; |    X   | $FDCE
       .byte $00 ; |        | $FDCF
Copyright3:
       .byte $BA ; |X XXX X | $FDD0
       .byte $8A ; |X   X X | $FDD1
       .byte $BA ; |X XXX X | $FDD2
       .byte $A2 ; |X X   X | $FDD3
       .byte $3A ; |  XXX X | $FDD4
       .byte $80 ; |X       | $FDD5
       .byte $FE ; |XXXXXXX | $FDD6
       .byte $00 ; |        | $FDD7
       .byte $80 ; |X       | $FDD8
       .byte $80 ; |X       | $FDD9
       .byte $AA ; |X X X X | $FDDA
       .byte $AA ; |X X X X | $FDDB
       .byte $BA ; |X XXX X | $FDDC
       .byte $22 ; |  X   X | $FDDD
       .byte $27 ; |  X  XXX| $FDDE
       .byte $02 ; |      X | $FDDF
Copyright4:
       .byte $E9 ; |XXX X  X| $FDE0
       .byte $AB ; |X X X XX| $FDE1
       .byte $AF ; |X X XXXX| $FDE2
       .byte $AD ; |X X XX X| $FDE3
       .byte $E9 ; |XXX X  X| $FDE4
       .byte $00 ; |        | $FDE5
       .byte $00 ; |        | $FDE6
       .byte $00 ; |        | $FDE7
       .byte $00 ; |        | $FDE8
       .byte $00 ; |        | $FDE9
       .byte $11 ; |   X   X| $FDEA
       .byte $11 ; |   X   X| $FDEB
       .byte $17 ; |   X XXX| $FDEC
       .byte $15 ; |   X X X| $FDED
       .byte $17 ; |   X XXX| $FDEE
       .byte $00 ; |        | $FDEF
Copyright5:
       .byte $00 ; |        | $FDF0
       .byte $00 ; |        | $FDF1
       .byte $00 ; |        | $FDF2
       .byte $00 ; |        | $FDF3
       .byte $00 ; |        | $FDF4
       .byte $00 ; |        | $FDF5
       .byte $00 ; |        | $FDF6
       .byte $00 ; |        | $FDF7
       .byte $00 ; |        | $FDF8
       .byte $00 ; |        | $FDF9
       .byte $77 ; | XXX XXX| $FDFA
       .byte $54 ; | X X X  | $FDFB
       .byte $77 ; | XXX XXX| $FDFC
       .byte $51 ; | X X   X| $FDFD
       .byte $77 ; | XXX XXX| $FDFE
       .byte $00 ; |        | $FDFF

        align 256
Fighter0:
       .byte $03 ; |      XX| $FE00
       .byte $07 ; |     XXX| $FE01
       .byte $07 ; |     XXX| $FE02
       .byte $0F ; |    XXXX| $FE03
       .byte $0D ; |    XX X| $FE04
       .byte $D8 ; |XX XX   | $FE05
       .byte $F0 ; |XXXX    | $FE06
       .byte $E0 ; |XXX     | $FE07
       .byte $E0 ; |XXX     | $FE08
       .byte $60 ; | XX     | $FE09
       .byte $20 ; |  X     | $FE0A
       .byte $00 ; |        | $FE0B
       .byte $00 ; |        | $FE0C
       .byte $00 ; |        | $FE0D
       .byte $00 ; |        | $FE0E
       .byte $00 ; |        | $FE0F
       .byte $00 ; |        | $FE10
Fighter1:
       .byte $01 ; |       X| $FE11
       .byte $03 ; |      XX| $FE12
       .byte $07 ; |     XXX| $FE13
       .byte $07 ; |     XXX| $FE14
       .byte $6D ; | XX XX X| $FE15
       .byte $78 ; | XXXX   | $FE16
       .byte $70 ; | XXX    | $FE17
       .byte $30 ; |  XX    | $FE18
       .byte $10 ; |   X    | $FE19
       .byte $00 ; |        | $FE1A
       .byte $00 ; |        | $FE1B
       .byte $00 ; |        | $FE1C
       .byte $00 ; |        | $FE1D
       .byte $00 ; |        | $FE1E
       .byte $00 ; |        | $FE1F
Fighter2:
       .byte $01 ; |       X| $FE20
       .byte $03 ; |      XX| $FE21
       .byte $07 ; |     XXX| $FE22
       .byte $35 ; |  XX X X| $FE23
       .byte $38 ; |  XXX   | $FE24
       .byte $18 ; |   XX   | $FE25
       .byte $08 ; |    X   | $FE26
       .byte $00 ; |        | $FE27
       .byte $00 ; |        | $FE28
       .byte $00 ; |        | $FE29
       .byte $00 ; |        | $FE2A
       .byte $00 ; |        | $FE2B
       .byte $00 ; |        | $FE2C
Fighter3:
       .byte $01 ; |       X| $FE2D
       .byte $03 ; |      XX| $FE2E
       .byte $0D ; |    XX X| $FE2F
       .byte $0C ; |    XX  | $FE30
       .byte $04 ; |     X  | $FE31
       .byte $00 ; |        | $FE32
       .byte $00 ; |        | $FE33
       .byte $00 ; |        | $FE34
       .byte $00 ; |        | $FE35
       .byte $00 ; |        | $FE36
       .byte $00 ; |        | $FE37
Fighter4:
       .byte $01 ; |       X| $FE38
       .byte $05 ; |     X X| $FE39
       .byte $02 ; |      X | $FE3A
       .byte $00 ; |        | $FE3B
       .byte $00 ; |        | $FE3C
       .byte $00 ; |        | $FE3D
       .byte $00 ; |        | $FE3E
       .byte $00 ; |        | $FE3F
       .byte $00 ; |        | $FE40
OnePixel:
       .byte $01 ; |       X| $FE41
NoPixel:
       .byte $00 ; |        | $FE42
       .byte $00 ; |        | $FE43
       .byte $00 ; |        | $FE44
       .byte $00 ; |        | $FE45
       .byte $00 ; |        | $FE46
       .byte $00 ; |        | $FE47
       .byte $00 ; |        | $FE48
       .byte $00 ; |        | $FE49
TwoPixel:
       .byte $01 ; |       X| $FE4A
       .byte $01 ; |       X| $FE4B
       .byte $00 ; |        | $FE4C
       .byte $00 ; |        | $FE4D
       .byte $00 ; |        | $FE4E
       .byte $00 ; |        | $FE4F
       .byte $00 ; |        | $FE50
       .byte $00 ; |        | $FE51
ThreePixel:
       .byte $01 ; |       X| $FE52
       .byte $01 ; |       X| $FE53
       .byte $01 ; |       X| $FE54
       .byte $00 ; |        | $FE55
       .byte $00 ; |        | $FE56
       .byte $00 ; |        | $FE57
       .byte $00 ; |        | $FE58
       .byte $00 ; |        | $FE59
       .byte $00 ; |        | $FE5A
FourPixel:
       .byte $01 ; |       X| $FE5B
       .byte $03 ; |      XX| $FE5C
       .byte $01 ; |       X| $FE5D
       .byte $00 ; |        | $FE5E
       .byte $00 ; |        | $FE5F
       .byte $00 ; |        | $FE60
       .byte $00 ; |        | $FE61
       .byte $00 ; |        | $FE62
       .byte $00 ; |        | $FE63
Meteor6:
       .byte $01 ; |       X| $FE64
       .byte $03 ; |      XX| $FE65
       .byte $03 ; |      XX| $FE66
       .byte $01 ; |       X| $FE67
       .byte $00 ; |        | $FE68
       .byte $00 ; |        | $FE69
       .byte $00 ; |        | $FE6A
       .byte $00 ; |        | $FE6B
       .byte $00 ; |        | $FE6C
       .byte $00 ; |        | $FE6D
Meteor5:
       .byte $01 ; |       X| $FE6E
       .byte $03 ; |      XX| $FE6F
       .byte $07 ; |     XXX| $FE70
       .byte $07 ; |     XXX| $FE71
       .byte $03 ; |      XX| $FE72
       .byte $01 ; |       X| $FE73
       .byte $00 ; |        | $FE74
       .byte $00 ; |        | $FE75
       .byte $00 ; |        | $FE76
       .byte $00 ; |        | $FE77
       .byte $00 ; |        | $FE78
       .byte $00 ; |        | $FE79
Meteor4:
       .byte $01 ; |       X| $FE7A
       .byte $03 ; |      XX| $FE7B
       .byte $07 ; |     XXX| $FE7C
       .byte $0F ; |    XXXX| $FE7D
       .byte $0F ; |    XXXX| $FE7E
       .byte $07 ; |     XXX| $FE7F
       .byte $03 ; |      XX| $FE80
       .byte $01 ; |       X| $FE81
       .byte $00 ; |        | $FE82
       .byte $00 ; |        | $FE83
       .byte $00 ; |        | $FE84
       .byte $00 ; |        | $FE85
       .byte $00 ; |        | $FE86
       .byte $00 ; |        | $FE87
       .byte $00 ; |        | $FE88
Meteor0:
       .byte $03 ; |      XX| $FE89
       .byte $0F ; |    XXXX| $FE8A
       .byte $1F ; |   XXXXX| $FE8B
       .byte $3F ; |  XXXXXX| $FE8C
       .byte $3F ; |  XXXXXX| $FE8D
       .byte $3F ; |  XXXXXX| $FE8E
       .byte $7F ; | XXXXXXX| $FE8F
       .byte $7F ; | XXXXXXX| $FE90
       .byte $7F ; | XXXXXXX| $FE91
       .byte $7F ; | XXXXXXX| $FE92
       .byte $FF ; |XXXXXXXX| $FE93
       .byte $FF ; |XXXXXXXX| $FE94
       .byte $FF ; |XXXXXXXX| $FE95
       .byte $FF ; |XXXXXXXX| $FE96
       .byte $7F ; | XXXXXXX| $FE97
       .byte $7F ; | XXXXXXX| $FE98
       .byte $7F ; | XXXXXXX| $FE99
       .byte $7F ; | XXXXXXX| $FE9A
       .byte $3F ; |  XXXXXX| $FE9B
       .byte $3F ; |  XXXXXX| $FE9C
       .byte $3F ; |  XXXXXX| $FE9D
       .byte $1F ; |   XXXXX| $FE9E
       .byte $0F ; |    XXXX| $FE9F
       .byte $03 ; |      XX| $FEA0
       .byte $00 ; |        | $FEA1
       .byte $00 ; |        | $FEA2
       .byte $00 ; |        | $FEA3
       .byte $00 ; |        | $FEA4
       .byte $00 ; |        | $FEA5
       .byte $00 ; |        | $FEA6
Meteor1:
       .byte $03 ; |      XX| $FEA7
       .byte $0F ; |    XXXX| $FEA8
       .byte $1F ; |   XXXXX| $FEA9
       .byte $1F ; |   XXXXX| $FEAA
       .byte $1F ; |   XXXXX| $FEAB
       .byte $3F ; |  XXXXXX| $FEAC
       .byte $3F ; |  XXXXXX| $FEAD
       .byte $3F ; |  XXXXXX| $FEAE
       .byte $7F ; | XXXXXXX| $FEAF
       .byte $7F ; | XXXXXXX| $FEB0
       .byte $7F ; | XXXXXXX| $FEB1
       .byte $7F ; | XXXXXXX| $FEB2
       .byte $3F ; |  XXXXXX| $FEB3
       .byte $3F ; |  XXXXXX| $FEB4
       .byte $3F ; |  XXXXXX| $FEB5
       .byte $1F ; |   XXXXX| $FEB6
       .byte $1F ; |   XXXXX| $FEB7
       .byte $1F ; |   XXXXX| $FEB8
       .byte $0F ; |    XXXX| $FEB9
       .byte $03 ; |      XX| $FEBA
       .byte $00 ; |        | $FEBB
       .byte $00 ; |        | $FEBC
       .byte $00 ; |        | $FEBD
       .byte $00 ; |        | $FEBE
       .byte $00 ; |        | $FEBF
       .byte $00 ; |        | $FEC0
Meteor2:
       .byte $03 ; |      XX| $FEC1
       .byte $0F ; |    XXXX| $FEC2
       .byte $0F ; |    XXXX| $FEC3
       .byte $0F ; |    XXXX| $FEC4
       .byte $1F ; |   XXXXX| $FEC5
       .byte $1F ; |   XXXXX| $FEC6
       .byte $1F ; |   XXXXX| $FEC7
       .byte $3F ; |  XXXXXX| $FEC8
       .byte $3F ; |  XXXXXX| $FEC9
       .byte $1F ; |   XXXXX| $FECA
       .byte $1F ; |   XXXXX| $FECB
       .byte $1F ; |   XXXXX| $FECC
       .byte $0F ; |    XXXX| $FECD
       .byte $0F ; |    XXXX| $FECE
       .byte $0F ; |    XXXX| $FECF
       .byte $03 ; |      XX| $FED0
       .byte $00 ; |        | $FED1
       .byte $00 ; |        | $FED2
       .byte $00 ; |        | $FED3
       .byte $00 ; |        | $FED4
       .byte $00 ; |        | $FED5
       .byte $00 ; |        | $FED6
Meteor3:
       .byte $01 ; |       X| $FED7
       .byte $07 ; |     XXX| $FED8
       .byte $07 ; |     XXX| $FED9
       .byte $0F ; |    XXXX| $FEDA
       .byte $0F ; |    XXXX| $FEDB
       .byte $1F ; |   XXXXX| $FEDC
       .byte $1F ; |   XXXXX| $FEDD
       .byte $0F ; |    XXXX| $FEDE
       .byte $0F ; |    XXXX| $FEDF
       .byte $07 ; |     XXX| $FEE0
       .byte $07 ; |     XXX| $FEE1
       .byte $01 ; |       X| $FEE2
       .byte $00 ; |        | $FEE3
       .byte $00 ; |        | $FEE4

StarDirXTab:    ; joystick causes additional x-move:
       .byte  0, 0, 0, 0, 3, 3, 3, 0,-3,-3,-3   ; $FEE5
; the effect for x-direction is less dynamic than for
;  y-direction, which is double-indexed and more correct

CharPtrTab:
       .byte <Zero, <One, <Two, <Three, <Four, <Five, <Six, <Seven, <Eight, <Nine
SpacePtr:
       .byte <Space
LetterSPtr:
       .byte <LetterS
LetterLPtr:
       .byte <LetterL
LetterRPtr:
       .byte <LetterR
LetterWPtr:
       .byte <LetterW
LetterEPtr:
       .byte <LetterE

OFS_SPACE       = SpacePtr - CharPtrTab   ; 10 = $0a
OFS_S           = LetterSPtr-CharPtrTab   ; 11 = $0b
OFS_L           = LetterLPtr-CharPtrTab   ; 12 = $0c
OFS_R           = LetterRPtr-CharPtrTab   ; 13 = $0d
OFS_W           = LetterWPtr-CharPtrTab   ; 14 = $0e
NO_DAMAGE       = OFS_SPACE+[OFS_SPACE<<4]; $aa
HI_DAMAGE       = OFS_S << 4              ; $b0

        align 256
LaserSizeTab:
       .byte $00, $10, $20

Base0:
       .byte $01 ; |       X| $FF03
       .byte $13 ; |   X  XX| $FF04
       .byte $13 ; |   X  XX| $FF05
       .byte $17 ; |   X XXX| $FF06
       .byte $7F ; |   XXXXX| $FF07
       .byte $EB ; |XXX X XX| $FF08
       .byte $7F ; |   XXXXX| $FF09
       .byte $17 ; |   X XXX| $FF0A
       .byte $13 ; |   X  XX| $FF0B
       .byte $13 ; |   X  XX| $FF0C
       .byte $01 ; |       X| $FF0D
       .byte $00 ; |        | $FF0E
       .byte $00 ; |        | $FF0F

ShapeDirXTab:          ;LFF10
       .byte 0, 0, 0, 0, 1, 1, 1, 0,-1,-1,-1

Base1:
       .byte $01 ; |       X| $FF1B
       .byte $13 ; |   X  XX| $FF1C
       .byte $17 ; |   X XXX| $FF1D
       .byte $3F ; |  XXXXXX| $FF1E
       .byte $6B ; | XX X XX| $FF1F
       .byte $3F ; |  XXXXXX| $FF20
       .byte $17 ; |   X XXX| $FF21
       .byte $13 ; |   X  XX| $FF22
       .byte $01 ; |       X| $FF23

       .byte $00 ; |        | $FF24
       .byte $00 ; |        | $FF25

NoRadarTab:
       .byte 0, 0, 0, 0, ID_BASE, ID_SHIP, ID_SHIP, ID_SHIP, ID_SHIP, ID_SHIP+ID_BASE

Base2:
       .byte $01 ; |       X| $FF30
       .byte $0B ; |    X XX| $FF31
       .byte $1F ; |   XXXXX| $FF32
       .byte $35 ; |  XX X X| $FF33
       .byte $1F ; |   XXXXX| $FF34
       .byte $0B ; |    X XX| $FF35
       .byte $01 ; |       X| $FF36
       .byte $00 ; |        | $FF37
       .byte $00 ; |        | $FF38
       .byte $00 ; |        | $FF39
       .byte $00 ; |        | $FF3A
       .byte $00 ; |        | $FF3B
       .byte $00 ; |        | $FF3C
Base3:
       .byte $09 ; |    X  X| $FF3D
       .byte $0F ; |    XXXX| $FF3E
       .byte $1B ; |   XX XX| $FF3F
       .byte $0F ; |    XXXX| $FF40
       .byte $09 ; |    X  X| $FF41
       .byte $00 ; |        | $FF42
       .byte $00 ; |        | $FF43
       .byte $00 ; |        | $FF44
       .byte $00 ; |        | $FF45
       .byte $00 ; |        | $FF46
       .byte $00 ; |        | $FF47
Base4:
       .byte $05 ; |     X X| $FF48
       .byte $0F ; |    XXXX| $FF49
       .byte $05 ; |     X X| $FF4A
Space:
Map0:
       .byte $00 ; |        | $FF4B
       .byte $00 ; |        | $FF4C
       .byte $00 ; |        | $FF4D
       .byte $00 ; |        | $FF4E
       .byte $00 ; |        | $FF4F
Map0Cursor:
       .byte $00 ; |        | $FF50
       .byte $00 ; |        | $FF51
       .byte $08 ; |    X   | $FF52
       .byte $1C ; |   XXX  | $FF53
       .byte $08 ; |    X   | $FF54
Map1:
       .byte $00 ; |        | $FF55
       .byte $00 ; |        | $FF56
       .byte $40 ; | X      | $FF57
       .byte $40 ; | X      | $FF58
       .byte $00 ; |        | $FF59
Map1Cursor:
       .byte $00 ; |        | $FF5A
       .byte $00 ; |        | $FF5B
       .byte $48 ; | X  X   | $FF5C
       .byte $5C ; | X XXX  | $FF5D
       .byte $08 ; |    X   | $FF5E
Map2:
       .byte $00 ; |        | $FF5F
       .byte $00 ; |        | $FF60
       .byte $41 ; | X     X| $FF61
       .byte $41 ; | X     X| $FF62
       .byte $00 ; |        | $FF63
Map2Cursor:
       .byte $00 ; |        | $FF64
       .byte $00 ; |        | $FF65
       .byte $49 ; | X  X  X| $FF66
       .byte $5D ; | X XXX X| $FF67
       .byte $08 ; |    X   | $FF68
       .byte $00 ; |        | $FF69
       .byte $00 ; |        | $FF6A
Zero:
       .byte $3C ; |  XXXX  | $FF6B
       .byte $66 ; | XX  XX | $FF6C
       .byte $66 ; | XX  XX | $FF6D
       .byte $66 ; | XX  XX | $FF6E
       .byte $66 ; | XX  XX | $FF6F
       .byte $66 ; | XX  XX | $FF70
       .byte $3C ; |  XXXX  | $FF71
One:
       .byte $3C ; |  XXXX  | $FF72
       .byte $18 ; |   XX   | $FF73
       .byte $18 ; |   XX   | $FF74
       .byte $18 ; |   XX   | $FF75
       .byte $18 ; |   XX   | $FF76
       .byte $38 ; |  XXX   | $FF77
       .byte $18 ; |   XX   | $FF78
Two:
       .byte $7E ; | XXXXXX | $FF79
       .byte $60 ; | XX     | $FF7A
       .byte $60 ; | XX     | $FF7B
       .byte $3C ; |  XXXX  | $FF7C
       .byte $06 ; |     XX | $FF7D
       .byte $46 ; | X   XX | $FF7E
       .byte $3C ; |  XXXX  | $FF7F
Three:
       .byte $3C ; |  XXXX  | $FF80
       .byte $46 ; | X   XX | $FF81
       .byte $06 ; |     XX | $FF82
       .byte $0C ; |    XX  | $FF83
       .byte $06 ; |     XX | $FF84
       .byte $46 ; | X   XX | $FF85
       .byte $3C ; |  XXXX  | $FF86
Four:
       .byte $0C ; |    XX  | $FF87
       .byte $0C ; |    XX  | $FF88
       .byte $7E ; | XXXXXX | $FF89
       .byte $4C ; | X  XX  | $FF8A
       .byte $2C ; |  X XX  | $FF8B
       .byte $1C ; |   XXX  | $FF8C
       .byte $0C ; |    XX  | $FF8D
Five:
       .byte $7C ; | XXXXX  | $FF8E
       .byte $46 ; | X   XX | $FF8F
       .byte $06 ; |     XX | $FF90
       .byte $7C ; | XXXXX  | $FF91
       .byte $60 ; | XX     | $FF92
       .byte $60 ; | XX     | $FF93
       .byte $7E ; | XXXXXX | $FF94
Six:
       .byte $3C ; |  XXXX  | $FF95
       .byte $66 ; | XX  XX | $FF96
       .byte $66 ; | XX  XX | $FF97
       .byte $7C ; | XXXXX  | $FF98
       .byte $60 ; | XX     | $FF99
       .byte $62 ; | XX   X | $FF9A
       .byte $3C ; |  XXXX  | $FF9B
Seven:
       .byte $18 ; |   XX   | $FF9C
       .byte $18 ; |   XX   | $FF9D
       .byte $18 ; |   XX   | $FF9E
       .byte $0C ; |    XX  | $FF9F
       .byte $06 ; |     XX | $FFA0
       .byte $42 ; | X    X | $FFA1
       .byte $7E ; | XXXXXX | $FFA2
Eight:
       .byte $3C ; |  XXXX  | $FFA3
       .byte $66 ; | XX  XX | $FFA4
       .byte $66 ; | XX  XX | $FFA5
       .byte $3C ; |  XXXX  | $FFA6
       .byte $66 ; | XX  XX | $FFA7
       .byte $66 ; | XX  XX | $FFA8
       .byte $3C ; |  XXXX  | $FFA9
Nine:
       .byte $3C ; |  XXXX  | $FFAA
       .byte $46 ; | X   XX | $FFAB
       .byte $06 ; |     XX | $FFAC
       .byte $3E ; |  XXXXX | $FFAD
       .byte $66 ; | XX  XX | $FFAE
       .byte $66 ; | XX  XX | $FFAF
       .byte $3C ; |  XXXX  | $FFB0
DoublePoint:
       .byte $00 ; |        | $FFB1
       .byte $18 ; |   XX   | $FFB2
       .byte $00 ; |        | $FFB3
       .byte $00 ; |        | $FFB4
       .byte $00 ; |        | $FFB5
       .byte $18 ; |   XX   | $FFB6
       .byte $00 ; |        | $FFB7
LetterD:
       .byte $7C ; | XXXXX  | $FFB8
       .byte $66 ; | XX  XX | $FFB9
       .byte $66 ; | XX  XX | $FFBA
       .byte $66 ; | XX  XX | $FFBB
       .byte $66 ; | XX  XX | $FFBC
       .byte $66 ; | XX  XX | $FFBD
       .byte $7C ; | XXXXX  | $FFBE
LetterE:
       .byte $7E ; | XXXXXX | $FFBF
       .byte $60 ; | XX     | $FFC0
       .byte $60 ; | XX     | $FFC1
       .byte $78 ; | XXXX   | $FFC2
       .byte $60 ; | XX     | $FFC3
       .byte $60 ; | XX     | $FFC4
       .byte $7E ; | XXXXXX | $FFC5
LetterL:
       .byte $7E ; | XXXXXX | $FFC6
       .byte $60 ; | XX     | $FFC7
       .byte $60 ; | XX     | $FFC8
       .byte $60 ; | XX     | $FFC9
       .byte $60 ; | XX     | $FFCA
       .byte $60 ; | XX     | $FFCB
       .byte $60 ; | XX     | $FFCC
LetterR:
       .byte $66 ; | XX  XX | $FFCD
       .byte $6C ; | XX XX  | $FFCE
       .byte $68 ; | XX X   | $FFCF
       .byte $7C ; | XXXXX  | $FFD0
       .byte $66 ; | XX  XX | $FFD1
       .byte $66 ; | XX  XX | $FFD2
       .byte $7C ; | XXXXX  | $FFD3
LetterS:
       .byte $3C ; |  XXXX  | $FFD4
       .byte $46 ; | X   XX | $FFD5
       .byte $06 ; |     XX | $FFD6
       .byte $3C ; |  XXXX  | $FFD7
       .byte $60 ; | XX     | $FFD8
       .byte $62 ; | XX   X | $FFD9
       .byte $3C ; |  XXXX  | $FFDA
LetterW:
       .byte $63 ; | XX   XX| $FFDB
       .byte $77 ; | XXX XXX| $FFDC
       .byte $7F ; | XXXXXXX| $FFDD
       .byte $6B ; | XX X XX| $FFDE
       .byte $6B ; | XX X XX| $FFDF
       .byte $63 ; | XX   XX| $FFE0
       .byte $63 ; | XX   XX| $FFE1
Map3:
       .byte $41 ; | X     X| $FFE2
       .byte $41 ; | X     X| $FFE3
       .byte $00 ; |        | $FFE4
       .byte $00 ; |        | $FFE5
       .byte $00 ; |        | $FFE6
       .byte $40 ; | X      | $FFE7
       .byte $40 ; | X      | $FFE8
Map3Cursor:
       .byte $41 ; | X     X| $FFE9
       .byte $41 ; | X     X| $FFEA
       .byte $08 ; |    X   | $FFEB
       .byte $1C ; |   XXX  | $FFEC
       .byte $08 ; |    X   | $FFED
       .byte $40 ; | X      | $FFEE
       .byte $40 ; | X      | $FFEF
MapBase:
       .byte $00 ; |        | $FFF0
       .byte $08 ; |    X   | $FFF1
       .byte $5D ; | X XXX X| $FFF2
       .byte $7F ; | XXXXXXX| $FFF3
       .byte $5D ; | X XXX X| $FFF4
       .byte $08 ; |    X   | $FFF5
MapBaseCursor:
       .byte $00 ; |        | $FFF6
       .byte $08 ; |    X   | $FFF7
       .byte $55 ; | X X X X| $FFF8
       .byte $63 ; | XX   XX| $FFF9
       .byte $55 ; | X X X X| $FFFA
       .byte $08 ; |    X   | $FFFB

  ORG   $fffc
    .word START
    .word 0
