; ***  C O S M I C   A R K  ***
; Copyright 1982 Imagic
; Designer: Rob Fulop

; Analyzed, labeled and commented
;  by Thomas Jentzsch (JTZ)
; Last Update: 23.04.2002 (v0.9)

; PAL conversion notes:
; Cosmic Ark is the first game I disassembled, where the PAL conversion has
; adjusted game speeds. This was possible, because the game uses fractional
; addition techniques (see Stella Programmer's Guide, page 16). Nearly all
; speeds have been adjusted, so that the game should have the same speeds for
; NTSC and PAL. Due to the rather complex meteror speeds and a little flaw in
; the code, this doesn't work 100% perfect there.

; Misc:
; - The code is not very heavily optimized and there are a few a bit weird code
;   sequences. However, this is probably just the case because optimization was
;   not necessary. The general code looks very straightforward and readable.
; - It looks like the game was planned to have a *non*-cooperative 2 player
;   mode. The duplicated score variables and the code for changing both scores
;   (AddScore) are still there.
; - The game uses a *lot* of status flags. Therefore I'm not always sure, that
;   I recognized them correctly.


TIMINT = $285

    processor 6502
    include vcs.h


;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

NTSC            = 1             ; compiling for NTSC of PAL mode

OPTIMIZE        = 0             ; enable some possible size optimizations
FILL_OPT        = 1             ; fill the optimized space with NOPs


;===============================================================================
; C O N S T A N T S
;===============================================================================

;general constants:
SCREEN_WIDTH    = 160
NUM_DIGITS      = 6             ; number of score digits (48 pixel routine)

;values for missiles and ball:
DISABLE         = %00
ENABLE          = %10

;values for joystick:
NO_DIR          = %1111
UP_DIR          = %1110
DOWN_DIR        = %1101
LEFT_DIR        = %1011
RIGHT_DIR       = %0111

;values for NUSIZx:
ONE_COPY        = %000
TWO_COPIES      = %001
TWO_COPIES_WIDE = %010
THREE_COPIES    = %011
DOUBLE_SIZE     = %101
THREE_COPIES_MED = %110
QUAD_SIZE       = %111
MS_SIZE1        = %000000
MS_SIZE2        = %010000
MS_SIZE4        = %100000
MS_SIZE8        = %110000

;color values:
BLACK           = $00
WHITE           = $0e
  IF NTSC
BROWN           = $28
ORANGE          = $38
RED             = $48
MAGENTA         = $58
MAGENTA2        = $68
BLUE            = $88
BLUE2           = $98
CYAN            = $a8
GREEN           = $c8
GREEN2          = $d8
ORANGE_GREEN    = $e8
OCHRE           = $f8
  ELSE
BROWN           = $48
ORANGE          = $48
RED             = $68
MAGENTA         = $88
MAGENTA2        = $c8
BLUE            = $b8
BLUE2           = $d8
CYAN            = $98
GREEN           = $58
GREEN2          = $38
ORANGE_GREEN    = $28
OCHRE           = $48
  ENDIF
RED_BROWN       = $44           ; NTSC = PAL!

;various constants:
NUM_STARCOLUMS  = 18            ; number of star columns
NUM_GAMES       = 6             ; number of game variations (1..6)
ADVANCED_GAME   = 4             ; advanced games start here (4..6)
NUM_BEASTIES    = 7             ; number of different beasties
MAX_FUEL        = 48            ; maximum fuel units

ARK_HEIGHT      = 19
MAX_SCROLL      = 10            ; number of lines the planet surface scrolls
DIGIT_HEIGHT    = 10
KERNEL_HEIGHT   = 184

ID_P0           = 0
ID_SHUTTLE      = ID_P0+1
ID_STARS        = ID_SHUTTLE+1

;values for shotDir:
NO_SHOT         = 0
SHOT_LEFT       = 1
SHOT_RIGHT      = 2
SHOT_UP         = 3
SHOT_DOWN       = 4

;values for meteorDir (identical to shotDir):
NO_METEOR       = 0
METEOR_LEFT     = 1
METEOR_RIGHT    = 2
METEOR_UP       = 3
METEOR_DOWN     = 4

;flags for status:
SHUTTLE_MODE    = %10000000
ON_PLANET       = %01000000
ARK_UPDOWN      = %00100000
NO_METEORS      = %00010000
GAME_OVER       = %00001000     ; this flag is set, while the last Ark is destroyed

;values for gameStatus:
RUNNING         = %10000000
START_MODE      = %01000000
SHOW_GAMENUM    = %00100000

;flags for gameFlags:
ONE_PLAYER      = %00000000
TWO_PLAYERS     = %01000000
METEOR_GAME     = %10000000

;values for defenseStatus:
FIREING         = %10000000
DIR_UP          = %01000000
ACTIVE          = %00100000

;values for beamStatus:
BEAM_BEASTIE    = %10000000
DROP_BEASTIE    = %01000000

;values beastie?Status:
BEASTIE_LEFT    = %10000000
BEASTIE_FREE    = %01000000

;values for channel0Sound:
ARK_SOUND       = %10000000     ; played while the Ark moves up and down
SHOT_SOUND      = %01000000
CAPTURED_SOUND  = %00100000     ; the short "blip" when a beastie is captured

;values for channel1Sound:
METEOR_SOUND    = %10000000
SHUTTLE_SOUND   = %01000000
BEAM_SOUND      = %00100000


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

xPosLst         = $80       ; ..$84
xPosP0          = xPosLst   ;               x-position of rescure shuttle (P0)
xPosMeteor      = xPosLst+1 ;               x-position of meteor and escape shuttle (P1)
xPosStars       = xPosLst+2 ;               starting x-position of stars (M0)
xPosShotBeam    = xPosLst+3 ;               x-position of players shot and beastie in tractor beam (M1)
xPosBeam        = xPosLst+4 ;               x-position of tractor beam (BL)
starColumn      = $85       ;               current star effect column counter
unused1         = $86
arkPatLst       = $87       ; ..$99         pattern of the Ark (19 lines)
yPosShot        = $9a       ;               y-position of players shot
unused2         = $9b
shotDir         = $9c       ;               direction of players shot (0=disabled, 1..4)
yPosMeteor      = $9d       ;               y-position of meteor
meteorDir       = $9e       ;               direction of meteor (0=disabled, 1..4)
meteorPtr       = $9f       ; ..$a0         kernel pointer to meteor graphics (and escape shuttle)
level           = $a1       ;               increased after each successful planet
arkHitCnt       = $a2       ;               counter for disappearing Ark
yPosShuttle     = $a3       ;               y-position of rescue shuttle
;---------------------------------------
;sound variables:
channel0Sound   = $a4       ;               flags for sounds of channel 0
channel1Sound   = $a5       ;               flags for sounds of channel 1
channel0Time    = $a6       ;               delay time for channel 0 (used to modify sounds)
channel1Time    = $a7       ;               the same for for channel 1
;---------------------------------------
beastie0Status  = $a8       ;               status of the beastie 0 (free/captured and running direction)
beastie1Status  = $a9       ;               the same for beastie 1
numBeasties     = $aa       ;               number of captured beasties
explosionCnt    = $ab       ;               counter for shuttle explosion (0 = no explosion)
gameOver        = $ac       ;               != 0 -> game over
fuel            = $ad       ;               fuel units (0..48)
;---------------------------------------
;score variables:
scoreHi         = $ae       ; ..$af         one variable was planed for each player, but only the first is used
scoreMid        = $b0       ; ..$b1
scoreLow        = $b2       ; ..$b3
;---------------------------------------
frameCnt        = $b4       ; ..$b5         high value only used for screen saver delay
tempVar         = $b6       ;               temporary multi purpose variable
tempVar2        = $b7       ;               another one
status          = $b8       ;               some status flags
surfaceScroll   = $b9       ;               used for scrolling up the planet surface
numMeteors      = $ba       ;               number of remaining non wavering meteors in wave
selectDelay     = $bb       ;               delay for SELECT switch
gameNum         = $bc       ;               current game variation (1..6)
digitPtr        = $bd       ; ..$c8         12 pointers for displaying score, fuel and copyright
yPosArk         = $c9       ;               y-position of Cosmic Ark
arkAppearCnt    = $ca       ;               used to make Ark appear on top of screen
joyDir          = $cb       ;               last joystick direction
random          = $cc       ;               random number generator (used for meteors, beastie "AI" and hit Ark)
shuttlePtr      = $cd       ; ..$ce         kernel pointer to shuttle graphics
xPosShuttle     = $cf       ;               x-position of rescue shuttle
saveHMStars     = $d0       ;               remember HMOVE value of stars
;---------------------------------------
;fractional addition variables:
meteorPosLo     = $d1       ;               some low variables for fractional addition
yPosShuttleLo   = $d2       ;                (see Stella Programmer's Guide, page 16)
xPosShuttleLo   = $d3
;---------------------------------------
xPosBeastie0    = $d4       ;               x-position of beastie 0
xPosBeastie1    = $d5       ;               x-position of beastie 1
yPosBeam        = $d6       ;               top position of tractor beam (0 or yPosShuttle)
speedHi         = $d7       ;               current meteor speed
;---------------------------------------
;another fractional addition variable:
speedLo         = $d8
;---------------------------------------
yPosDefense     = $d9       ;               y-position of planet defense system
defenseStatus   = $da       ;               %FDAxxxxx: Fireing, Direction, Active
yBeamedBeastie  = $db       ;               y-position of beamed beastie
beamStatus      = $dc       ;               status of tractor beam (enabled, dropping a beastie)
gameStatus      = $dd       ;               some more status flags
beastiePtr      = $de       ; ..$df         kernel pointer to beastie graphics
planetTime      = $e0       ;               time on planet
defenseDelay    = $e1       ;               delay until next defense fire
;---------------------------------------
;difficulty variables:
initSpeedHi     = $e2       ;               initial high meteor speed
initSpeedLo     = $e3       ;               initial low meteor speed
shutteSpeedLo   = $e4       ;               shuttle speed
alertTime       = $e5       ;               delay time until bombardment alert
defenseFreq     = $e6       ;               frequency of defense fire
levelMeteors    = $e7       ;               meteors per wave
;---------------------------------------
alertCnt        = $e8       ;               countdown for bombardment alert
beastieId       = $e9       ;               beastie on current planet
shuttleColor    = $ea       ;               shuttle color, changes every 4th planet
oldNumBeasties  = $eb       ;               number of beasties at start of planet
gameFlags       = $ec       ;               again some more status flags
fireButton      = $ed       ;               remembers fire button bit
waveringFlag    = $ee       ;               used for wavering meteors
waveringCnt     = $ef       ;               used for wavering meteors
P1SpaceCol      = $f0       ;               color for meteors and escape shuttle
numWaverings    = $f1       ;               maximum number of wavering meteors in wave
colorMask       = $f2       ;               used to darken the score display after ~18 minutes


;===============================================================================
; M A C R O S
;===============================================================================

  MAC FILL_NOP
    IF FILL_OPT
      REPEAT {1}
         NOP
      REPEND
    ENDIF
  ENDM


;===============================================================================
; R O M - C O D E
;===============================================================================

    ORG $1000

StartKernel SUBROUTINE
;*** start of the display kernel ***
    ldx    #$04             ; 2             position all five objects
.loopSetPos:
    lda    xPosLst,x        ; 4
    jsr    SetPosX          ; 6
    dex                     ; 2
    bpl    .loopSetPos      ; 2³
    lda    status           ; 3
    and    #GAME_OVER       ; 2             game over?
    beq    .skip            ; 2³             no, skip
                            ;               JTZ: I don't know what this code is useful for. It only causes
                            ;                    some distortions at the top of the screen when the game is over.
    lda    frameCnt         ; 3              yes, do something
    and    #$07             ; 2
    tay                     ; 2
    lda    NuSiz0Tab,y      ; 4
.skip:
    sta    NUSIZ0           ; 3
.waitTim:
    bit    TIMINT           ; 4
    bpl    .waitTim         ; 2³
    sta    WSYNC            ; 3
;------------------------------
    ldx    #ID_STARS        ; 2             position stars
    lda    xPosLst,x        ; 4
    jsr    SetPosX          ; 6
    sta    saveHMStars      ; 3
    sta    WSYNC            ; 3
;------------------------------
    sta    HMOVE            ; 3
    jsr    TimeStarTrick    ;18             a = $60 = -6
    sta    HMM0             ; 3 @24         to early! (Cosmic Ark stars trick)
    lda    #BLACK           ; 2             space background
    bit    status           ; 3             space or planet?
    bvc    .inSpace         ; 2³             space, skip
    lda    #CYAN-8          ; 2             planet background
.inSpace:
    sta    COLUBK           ; 3
    sta    WSYNC            ; 3
;------------------------------
    sta    VBLANK           ; 3
    sta    HMCLR            ; 3
    sta    REFP0            ; 3             disable reflection
    sta    REFP1            ; 3
    sta    CXCLR            ; 3
  IF NTSC
    lda    #ENABLE          ; 2
  ELSE
    lda    SWCHB            ; 4             disable stars with B/W switch (PAL only!)
    lsr                     ; 2
    lsr                     ; 2
  ENDIF
    sta    ENAM0            ; 3             enable missile 0
    lda    P1SpaceCol       ; 3
    sta    COLUP1           ; 3
    lda    #%10101          ; 2
    sta    CTRLPF           ; 3             PF reflection & priority, BL size = 2
    sta    REFP1            ; 3             disable P1 reflection (again?)
  IF NTSC
    ldx    #KERNEL_HEIGHT   ; 2             number of kernel lines
  ELSE
    ldx    #KERNEL_HEIGHT+5 ; 2             5 more lines in PAL kernel -> Ark appears a bit below top
  ENDIF
.loopTopKernel:
    stx    WSYNC            ; 3
;------------------------------
    txa                     ; 2             check meteor
    sec                     ; 2
    sbc    yPosMeteor       ; 3
    tay                     ; 2
    and    #$f8             ; 2             at meteor position?
    bne    .noMeteor0       ; 2³             no, draw blank
    lda    (meteorPtr),y    ; 5              yes, draw meteor
    jmp    .contMeteor0     ; 3

.noMeteor0:
    lda    #0               ; 2
.contMeteor0:
    sta    GRP1             ; 3
    txa                     ; 2             change star color
    eor    frameCnt         ; 3
    sta    COLUP0           ; 3
    ldy    #ENABLE-1        ; 2             -> disable shot
    txa                     ; 2             check shot
    sec                     ; 2
    sbc    yPosShot         ; 3
    and    #$f8             ; 2
    bne    .disableShot     ; 2³
    iny                     ; 2             -> enable shot
.disableShot:
    sty    ENAM1            ; 3
    dex                     ; 2
    cpx    yPosArk          ; 3             at Ark position?
    bne    .loopTopKernel   ; 2³             no, loop

    lda    #ARK_HEIGHT-1    ; 2             19 lines with Ark
    sta    tempVar          ; 3
.loopArkKernel:
    sta    WSYNC            ; 3
;------------------------------
    ldy    tempVar          ; 3             draw Ark
    lda    arkPatLst,y      ; 4
    sta    PF2              ; 3
    lda    ArkColTab,y      ; 4
    sta    COLUPF           ; 3
    txa                     ; 2             change star color
    eor    frameCnt         ; 3
    sta    COLUP0           ; 3
;draw meteor:
    txa                     ; 2             check meteor
    sec                     ; 2
    sbc    yPosMeteor       ; 3
    tay                     ; 2
    and    #$f8             ; 2
    bne    .noMeteor1       ; 2³
    lda    (meteorPtr),y    ; 5
    jmp    .contMeteor1     ; 3

.noMeteor1:
    lda    #0               ; 2
.contMeteor1:
    sta    GRP1             ; 3
    ldy    #ENABLE-1        ; 2             -> disable shot
    cpx    yPosShot         ; 3             check shot
    bne    .disableShot1    ; 2³
    iny                     ; 2             -> enable shot
.disableShot1:
    sty    ENAM1            ; 3
    dex                     ; 2
    dec    tempVar          ; 5             Ark completely drawn?
    bpl    .loopArkKernel   ; 2³             no, loop

    sta    WSYNC            ; 3
;------------------------------
    lda    CXP1FB-$30       ; 3             check for meteor collisons
    pha                     ; 3             save on stack
    bit    status           ; 3             on planet?
    bvs    .onPlanet        ; 2³             yes, draw rescue shuttle
    jmp    LowerKernel      ; 3              no, draw meteor

.onPlanet:
    lda    saveHMStars      ; 3             move stars
    sta    HMM0             ; 3
    lda    xPosShuttle      ; 3             position rescue shuttle
    stx    tempVar2         ; 3
    ldx    #ID_SHUTTLE      ; 2
    jsr    SetPosX          ; 6             this causes the lower line of the Ark
    sta    WSYNC            ; 3              to be displayed some extra lines
;------------------------------
    sta    HMOVE            ; 3
    jsr    TimeStarTrick    ;18             a = $60 = -6
    sta    HMM0             ; 3 @24         to early! (Cosmic Ark stars trick)
    lda    #MS_SIZE2        ; 2
    sta    NUSIZ1           ; 3
    lda    tempVar2         ; 3
    sec                     ; 2
    sbc    #$03             ; 2
    tax                     ; 2
    lda    shuttleColor     ; 3             color shuttle
    sta    COLUP1           ; 3
    lda    #0               ; 2
    sta    WSYNC            ; 3
;------------------------------
    sta    PF2              ; 3
    beq    .enterPlanetKernel;3+1

.loopPlanetKernel:
    sta    WSYNC            ; 3
;------------------------------
    sta    GRP1             ; 3
    cpx    yPosDefense      ; 3
    beq    .checkDefense    ; 2³
    bcc    .drawMast        ; 2³+1
    bcs    .endDefense      ; 3+1

.checkDefense:
    lda    #$30             ; 2
    bit    defenseStatus    ; 3             defense fireing?
    bpl    .drawTop         ; 2³             no, draw top of mast
    lda    #$ff             ; 2              yes, draw whole line
    sta    PF0              ; 3
    sta    PF1              ; 3
    sta    PF2              ; 3
    bne    .endDefense      ; 3

.drawMast:
    lda    #$10             ; 2             draw top of mast
.drawTop:
    sta    PF0              ; 3
    lda    #$00             ; 2
    sta    PF1              ; 3
    sta    PF2              ; 3
.endDefense:

    ldy    #ENABLE          ; 2             check tractor beam
    cpx    yPosBeam         ; 3
    bcc    .enableBeam      ; 2³
    dey                     ; 2
.enableBeam:
    sty    ENABL            ; 3
.enterPlanetKernel:
;draw shuttle:
    txa                     ; 2             check shuttle
    sec                     ; 2
    sbc    yPosShuttle      ; 3
    tay                     ; 2
    and    #$f8             ; 2
    bne    .disableShuttle0 ; 2³
    lda    (shuttlePtr),y   ; 5
    jmp    .contShuttle0    ; 3

.disableShuttle0:
    lda    #0               ; 2
.contShuttle0:
    dex                     ; 2
    cpx    #19              ; 2
    beq    .bottomKernel    ; 2³
    sta    WSYNC            ; 3
;------------------------------
    sta    GRP1             ; 3
    txa                     ; 2             change star color
    eor    frameCnt         ; 3
    sta    COLUP0           ; 3
    ldy    #ENABLE-1        ; 2             check beastie in tractor beam
    txa                     ; 2
    sec                     ; 2
    sbc    yBeamedBeastie   ; 3
    and    #$f8             ; 2
    bne    .disableBeam     ; 2³
    iny                     ; 2             enable beastie in tractor beam
.disableBeam:
    sty    ENAM1            ; 3
    txa                     ; 2             check shuttle
    sec                     ; 2
    sbc    yPosShuttle      ; 3
    tay                     ; 2
    and    #$f8             ; 2
    bne    .disableShuttle1 ; 2³
    lda    (shuttlePtr),y   ; 5
    jmp    .contShuttle1    ; 3

.disableShuttle1:
    lda    #0               ; 2
.contShuttle1:
    dex                     ; 2
    cpx    #19              ; 2
    bne    .loopPlanetKernel; 2³+1
    beq    .bottomKernel    ; 3

LowerKernel:
    lda    #0               ; 2
    sta    WSYNC            ; 3
;------------------------------
    sta    PF2              ; 3
.loopLowerKernel:
    sta    WSYNC            ; 3
;------------------------------
    txa                     ; 2             check meteor
    sec                     ; 2
    sbc    yPosMeteor       ; 3
    tay                     ; 2
    and    #$f8             ; 2
    bne    .noMeteor        ; 2³
    lda    (meteorPtr),y    ; 5
    jmp    .contMeteor      ; 3

.noMeteor:
    lda    #$00             ; 2
.contMeteor:
    sta    GRP1             ; 3
    txa                     ; 2             change star color
    eor    frameCnt         ; 3
    sta    COLUP0           ; 3
    ldy    #ENABLE-1        ; 2             -> disable shot
    txa                     ; 2             check shot
    sec                     ; 2
    sbc    yPosShot         ; 3
    and    #$f8             ; 2
    bne    .disableShot2    ; 2³
    iny                     ; 2             -> enable shot
.disableShot2:
    sty    ENAM1            ; 3
    dex                     ; 2
    cpx    #21              ; 2
    bne    .loopLowerKernel ; 2³

.bottomKernel:
    lda    #0               ; 2             disable stars
    sta    ENAM0            ; 3
    sta    GRP1             ; 3
    bit    status           ; 3
    bvs    .onPlanet1       ; 2³            on planet
    sta    ENAM1            ; 3
    sta    WSYNC            ; 3
    jmp    .drawScore       ; 3

.onPlanet1:
    ldx    #ID_P0           ; 2             position beastie 0
    lda    xPosBeastie0     ; 3
    jsr    SetPosX          ; 6
    sta    WSYNC            ; 3
;------------------------------
    inx                     ; 2             position beastie 1
    lda    xPosBeastie1     ; 3
    jsr    SetPosX          ; 6
    sta    WSYNC            ; 3
;------------------------------
    sta    HMOVE            ; 3
    lda    #MS_SIZE2        ; 2
    sta    NUSIZ0           ; 3
    sta    NUSIZ1           ; 3
    lda    #BROWN+6         ; 2             set beastie color
    sta    COLUP0           ; 3
    sta    COLUP1           ; 3
    ldy    #%10001          ; 2             PF reflection, BL size = 2
    sty    CTRLPF           ; 3
    ldy    #$08             ; 2
    bit    beastie0Status   ; 3             beastie 0 moving right?
    bmi    .reflect0        ; 2³             yes, reflect graphics
    dey                     ; 2
.reflect0:
    sty    REFP0            ; 3
    ldy    #$08             ; 2
    bit    beastie1Status   ; 3             beastie 1 moving right?
    bmi    .reflect1        ; 2³             yes, reflect graphics
    dey                     ; 2
.reflect1:
    sty    REFP1            ; 3

;scroll surface up/down:
    ldx    #MAX_SCROLL      ; 2
    ldy    level            ; 3
    lda    PlanetColTab,y   ; 4
    sta    tempVar          ; 3
    ldy    surfaceScroll    ; 3
.loopWait:
    dey                     ; 2             wait for planet surface
    bmi    .drawSurface     ; 2³
    sta    WSYNC            ; 3
;------------------------------
    dex                     ; 2
    bne    .loopWait        ; 2³
    beq    .endSurface      ; 3+1

.drawSurface:
    ldy    #DISABLE         ; 2
    sty    ENAM1            ; 3
.loopSurface:
    sta    WSYNC            ; 3
;------------------------------
    lda    tempVar          ; 3             draw surface of planet
    ora    LumTab,y         ; 4
    sta    COLUPF           ; 3
    lda    PlanetPF0Tab,y   ; 4
    sta    PF0              ; 3
    lda    PlanetPF1Tab,y   ; 4
    sta    PF1              ; 3
    lda    PlanetPF2Tab,y   ; 4
    sta    PF2              ; 3
    lda    (beastiePtr),y   ; 5
    bit    beastie0Status   ; 3             beastie 0 captured?
    bvc    .captured0       ; 2³             yes, skip draw
    sta    GRP0             ; 3
.captured0:
    bit    beastie1Status   ; 3             beastie 1 captured?
    bvc    .captured1       ; 2³             yes, skip draw
    sta    GRP1             ; 3
.captured1:
    iny                     ; 2
    dex                     ; 2
    bne    .loopSurface     ; 2³+1
.endSurface:
    lda    tempVar          ; 3
    sta    COLUBK           ; 3
    jmp    .exitKernel      ; 3

.drawScore:
    lda    #BROWN+4         ; 2             set score color
    and    colorMask        ; 3
    sta    COLUP1           ; 3
    sta    COLUP0           ; 3
    lda    #BLUE+4          ; 2             set frame color
    and    colorMask        ; 3
    sta    COLUPF           ; 3
    lda    #%01             ; 2             enable PF reflection
    sta    CTRLPF           ; 3
    lda    #THREE_COPIES    ; 2
    sta    NUSIZ0           ; 3
    sta    NUSIZ1           ; 3
    ldy    #5               ; 2
    sta    WSYNC            ; 3
;------------------------------
    lda    #$ff             ; 2             draw top of frame around digits
    sta    PF2              ; 3

;position score sprites:
.delayPos:
    dey                     ; 2
    bpl    .delayPos        ; 2³
    nop                     ; 2
    sta    RESP0            ; 3
    sta    RESP1            ; 3
    lda    #$f0             ; 2
    sta    HMP0             ; 3
    ldx    #$00             ; 2
    stx    HMP1             ; 3
    inx                     ; 2
    stx    VDELP0           ; 3
    stx    VDELP1           ; 3
    sta    WSYNC            ; 3
    sta    HMOVE            ; 3
    stx    PF2              ; 3
    sta    WSYNC            ; 3
;------------------------------
;draw score:
    lda    #DIGIT_HEIGHT-1  ; 2             48 pixel routine
    sta    tempVar2         ; 3
.digitLoop:
    ldy    tempVar2         ; 3
    lda    (digitPtr),y     ; 5
    sta    GRP0             ; 3
    sta    WSYNC            ; 3
;------------------------------
    lda    (digitPtr+2),y   ; 5
    sta    GRP1             ; 3
    lda    (digitPtr+4),y   ; 5
    sta    GRP0             ; 3
    lda    (digitPtr+6),y   ; 5
    sta    tempVar          ; 3
    lda    (digitPtr+8),y   ; 5
    tax                     ; 2
    lda    (digitPtr+10),y  ; 5
    tay                     ; 2
    lda    tempVar          ; 3
    sta    GRP1             ; 3
    stx    GRP0             ; 3
    sty    GRP1             ; 3
    sty    GRP0             ; 3
    dec    tempVar2         ; 5
    bpl    .digitLoop       ; 2³
    ldx    #$00             ; 2
    sta    WSYNC            ; 3
;------------------------------
    stx    GRP0             ; 3
    stx    GRP1             ; 3

;fuel bar:
    lda    fuel             ; 3             convert fuel into bar
    and    #$07             ; 2
    sta    tempVar          ; 3
    lda    fuel             ; 3
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    tay                     ; 2
    beq    .skipFull        ; 2³
    lda    #<FuelBarTab+8   ; 2             full bar
.loopFullBar:
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    dey                     ; 2
    bne    .loopFullBar     ; 2³
.skipFull:
    lda    #<FuelBarTab     ; 2             empty bar
    clc                     ; 2
    adc    tempVar          ; 3
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    lda    #<FuelBarTab     ; 2
.loopEmptyBar:
    cpx    #NUM_DIGITS*2    ; 2
    beq    .exitEmptyLoop   ; 2³
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    bne    .loopEmptyBar    ; 3
.exitEmptyLoop:

;draw fuel bar:
    lda    #RED_BROWN       ; 2
    sta    COLUP0           ; 3
    sta    COLUP1           ; 3
    lda    #2               ; 2
    sta    tempVar2         ; 3
.fuelBarLoop:
    ldy    #$00             ; 2
    lda    (digitPtr),y     ; 5
    sta    GRP0             ; 3
    sta    WSYNC            ; 3
;------------------------------
    lda    (digitPtr+2),y   ; 5
    sta    GRP1             ; 3
    lda    (digitPtr+4),y   ; 5
    sta    GRP0             ; 3
    lda    (digitPtr+6),y   ; 5
    sta    tempVar          ; 3
    lda    (digitPtr+8),y   ; 5
    tax                     ; 2
    lda    (digitPtr+10),y  ; 5
    tay                     ; 2
    lda    tempVar          ; 3
    sta    GRP1             ; 3
    stx    GRP0             ; 3
    sty    GRP1             ; 3
    sty    GRP0             ; 3
    dec    tempVar2         ; 5
    bpl    .fuelBarLoop     ; 2³

.exitKernel:
    ldx    #0               ; 2
    sta    WSYNC            ; 3
;------------------------------
    stx    GRP0             ; 3
    stx    GRP1             ; 3
    stx    GRP0             ; 3
    sta    WSYNC            ; 3
;------------------------------
    stx    PF0              ; 3
    stx    PF1              ; 3
    stx    ENABL            ; 3
    stx    VDELP0           ; 3
    stx    VDELP1           ; 3
    bit    status           ; 3
    bvs    .onPlanet2       ; 2³
    lda    #$ff             ; 2             draw bottom of frame around digits
    sta    PF2              ; 3
.onPlanet2:
    sta    WSYNC            ; 3
;------------------------------
    stx    PF2              ; 3
    jmp    OverScan         ; 3


SetPosX SUBROUTINE
;*** position object[X] horizontaly ***
    sta    tempVar          ; 3
    inc    tempVar          ; 5
    cpx    #$02             ; 2
    bcc    .isPlayer        ; 2³
    inc    tempVar          ; 5
.isPlayer:
    lda    tempVar          ; 3
    pha                     ; 3
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    sta    tempVar          ; 3
    tay                     ; 2
    pla                     ; 4
    and    #$0f             ; 2
    clc                     ; 2
    adc    tempVar          ; 3
    cmp    #$0f             ; 2
    bcc    .ok              ; 2³
    sbc    #$0f             ; 2
    iny                     ; 2
.ok:
    sec                     ; 2
    sbc    #$08             ; 2
    eor    #$ff             ; 2
    sta    WSYNC            ; 3
;------------------------------
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    sta    HMP0,x           ; 4
.wait:
    dey                     ; 2
    bpl    .wait            ; 2³
    sta    tempVar          ; 3
    sta    RESP0,x          ; 4
    sta    WSYNC            ; 3
;------------------------------
    rts                     ; 6

START:
    sei                     ; 2
    cld                     ; 2
    ldx    #$ff             ; 2
    txs                     ; 2
    inx                     ; 2
    txa                     ; 2
.clearLoop:
    sta    $00,x            ; 4
    inx                     ; 2
    bne    .clearLoop       ; 2³
    dec    colorMask        ; 5             = $ff (disable screen saver)

;set high digit pointers:
    lda    #>Zero           ; 2
    ldx    #NUM_DIGITS*2-1  ; 2
.setHighLoop:
    sta    digitPtr,x       ; 4
    dex                     ; 2
    dex                     ; 2
    bpl    .setHighLoop     ; 2³

    lda    #1               ; 2
    sta    status           ; 3
    sta    random           ; 3             initialize random number generator
    sta    gameNum          ; 3             start with game #1
    lda    #>Shuttle0       ; 2             set high pointers
    sta    shuttlePtr+1     ; 3
    lda    #>Beastie0       ; 2
    sta    beastiePtr+1     ; 3
    lda    #2               ; 2
    sta    numMeteors       ; 3
    jsr    StartArkDown     ; 6             start Ark
    jsr    InitGameVars     ; 6
MainLoop:
    lda    #$02             ; 2             start with vertical sync
    sta    VBLANK           ; 3
    sta    WSYNC            ; 3
    sta    VSYNC            ; 3
    sta    WSYNC            ; 3
    sta    WSYNC            ; 3
    sta    WSYNC            ; 3
    lda    #$00             ; 2
    sta    VSYNC            ; 3
  IF NTSC
    lda    #44              ; 2
  ELSE
    lda    #73              ; 2
  ENDIF
    sta    TIM64T           ; 4

;increase frame counter, enable screen saver:
    inc    frameCnt         ; 5
    bne    .skip_SS         ; 2³
    inc    frameCnt+1       ; 5
    bne    .skip_SS         ; 2³
    bit    gameStatus       ; 3             status of game?
    bvs    .activate_SS     ; 2³             in start mode, activate screen saver
    bmi    .skip_SS         ; 2³             running!
.activate_SS:
    lda    #$f3             ; 2             enable screen saver
    sta    colorMask        ; 3
.skip_SS:
    lda    random           ; 3             generate next random number
    asl                     ; 2
    eor    random           ; 3
    asl                     ; 2
    asl                     ; 2
    rol    random           ; 5
    bit    gameStatus       ; 3             game status?
    bvs    .checkFire       ; 2³             start mode, check fire button
    bmi    .checkSwitches   ; 2³             game running, don't check fire!
.checkFire:
    lda    INPT4-$30        ; 3             fire pressed?
    bpl    .doReset         ; 2³             yes, reset
.checkSwitches:
    lda    SWCHB            ; 4             avoid repeating RESETs
    ror    status           ; 5             RESET presed before
    bcs    .noOldReset      ; 2³             no, skip
    lsr                     ; 2             RESET pressed?
    bcs    .doReset         ; 2³             no, skip
    rol                     ; 2
.noOldReset:
    lsr                     ; 2
    rol    status           ; 5             bit 0 = RESET
    lsr                     ; 2             SELECT pressed?
    bit    selectDelay      ; 3
    bcc    .select          ; 2³             yes, start a new game
    rol    selectDelay      ; 5              no, debounce delay (very clever)
    bne    .skipSwitches    ; 3+1

.select:
    bpl    .skipSelect      ; 2³
    lda    gameStatus       ; 3             enable "start mode" and "show game number"
    ora    #START_MODE|SHOW_GAMENUM; 2
    sta    gameStatus       ; 3
    jsr    InitGame         ; 6
.endDelay:
    lda    frameCnt         ; 3             remember framecounter of current SELECT
    and    #$1f             ; 2
    sta    selectDelay      ; 3
    inc    gameNum          ; 5             increase game number
    lda    gameNum          ; 3
    cmp    #NUM_GAMES+1     ; 2             maximum game number?
    bne    .endSwitches     ; 2³             no, skip
    lda    #1               ; 2              yes, reset game number
    sta    gameNum          ; 3
    bne    .endSwitches     ; 3

.skipSelect:
    lda    selectDelay      ; 3             32 frames since last valid SELECT?
    eor    frameCnt         ; 3
    and    #$1f             ; 2
    beq    .endDelay        ; 2³             yes, increase game number
.endSwitches:
    jmp    .endUpdateGame   ; 3

.doReset:
;start a new game:
    ldy    gameNum          ; 3
    lda    GameFlagsTab,y   ; 4
    sta    gameFlags        ; 3
    lda    #$ff             ; 2             disable screen saver
    sta    colorMask        ; 3
    ldx    #RUNNING         ; 2             game is running
    stx    gameStatus       ; 3
    jsr    InitGame         ; 6
    jsr    StartArkDown     ; 6
    jsr    InitGameVars     ; 6
    jsr    InitLevel        ; 6
    lda    #MAX_FUEL-8      ; 2             set initial fuel
    sta    fuel             ; 3
.skipSwitches:
    lda    gameStatus       ; 3             selecting a game?
    and    #SHOW_GAMENUM    ; 2
    beq    .updateGameVars  ; 2³             no,
    jmp    .endUpdateGame   ; 3              yes, the game is not running

GameFlagsTab:
    .byte  0                ;               unused
    .byte  ONE_PLAYER
    .byte  METEOR_GAME
    .byte  TWO_PLAYERS
    .byte  ONE_PLAYER
    .byte  METEOR_GAME
    .byte  TWO_PLAYERS

.updateGameVars:
;*** begin of update game variables: ***
    lda    status           ; 3
    and    #ARK_UPDOWN      ; 2             Ark moving up?
    beq    .skipBonus       ; 2³             no,
    inc    yPosArk          ; 5              yes, increase Ark's y-position
    bit    status           ; 3             in space?
    bvc    .noScroll        ; 2³             yes, don't scroll down planet
    lda    frameCnt         ; 3
    and    #$07             ; 2             scroll every 8th frame
    bne    .noScroll        ; 2³
    lda    surfaceScroll    ; 3
    cmp    #MAX_SCROLL      ; 2             scrolled up completely?
    beq    .noScroll        ; 2³             yes, skip
    inc    surfaceScroll    ; 5              no, scroll up
.noScroll:

    lda    yPosArk          ; 3
    cmp    #KERNEL_HEIGHT-1 ; 2             Ark at top of screen?
    bne    .skipBonus       ; 2³             no, continue current section
    lda    status           ; 3
    and    #$cf             ; 2             disable meteors
    bit    gameFlags        ; 3             meteor game?
    bpl    .normalGame      ; 2³             no, skip
    sta    status           ; 3              yes, meteor stage
    inc    level            ; 5
    jsr    NextLevel        ; 6
    jmp    .contSection     ; 3

.normalGame:
    eor    #ON_PLANET       ; 2             toggle section type
    sta    status           ; 3
    bit    status           ; 3             in space?
    bvc    .contSection     ; 2³             yes, with meteors
    ora    #NO_METEORS      ; 2              no, stop meteors
    sta    status           ; 3

.contSection:
    lda    #ARK_HEIGHT*2    ; 2
    sta    arkAppearCnt     ; 3
    bit    status           ; 3             now on planet?
    bvs    .skipBonus       ; 2³             yes, no bonus
    lda    numBeasties      ; 3
    cmp    #2               ; 2             all beasties captured?
    bcc    .skipNextLevel   ; 2³             no, skip
    inc    level            ; 5              yes, goto next level
    lda    #0               ; 2             reset number of captured beasties
    sta    numBeasties      ; 3
    tay                     ; 2             Y is always 0!
    ldx    #$10             ; 2             +1000 points bonus
    jsr    AddScore         ; 6
    jsr    NextLevel        ; 6
.skipNextLevel:
    jsr    InitLevel        ; 6
.skipBonus:
    lda    arkAppearCnt     ; 3             Ark appearing?
    beq    .inSpace1        ; 2³             no,
    bmi    .inSpace1        ; 2³             no,
    lsr                     ; 2
    cmp    #ARK_HEIGHT      ; 2             Ark completely on screen?
    bcs    .arkComplete     ; 2³             yes, move down
    tay                     ; 2
    ldx    ArkAppearTab,y   ; 4             copy one more Ark pattern line...
    lda    ArkPatTab,x      ; 4             ...into the RAM buffer
    sta    arkPatLst,x      ; 4
  IF OPTIMIZE
    bcc    .contAppear      ; 3
    FILL_NOP 1
  ELSE
    jmp    .contAppear      ; 3
  ENDIF

.arkComplete:
    dec    yPosArk          ; 5
    bit    status           ; 3             on planet
    bvc    .inSpace0        ; 2³             no, skip
    lda    frameCnt         ; 3              yes, scroll planet surface...
    and    #$07             ; 2             ...every 8th frame
    bne    .inSpace0        ; 2³
    lda    surfaceScroll    ; 3
    beq    .inSpace0        ; 2³
    dec    surfaceScroll    ; 5
.inSpace0:
    lda    yPosArk          ; 3
    cmp    #104             ; 2
    bne    .contAppear      ; 2³
    lda    #$80             ; 2             stop moving down Ark
    sta    arkAppearCnt     ; 3
    lda    #0               ; 2
    sta    channel0Sound    ; 3             disable all sounds in channel 0
    bit    status           ; 3
    bvc    .inSpace1        ; 2³
    lda    #SCREEN_WIDTH/2-4; 2
    sta    xPosShuttle      ; 3
    lda    #86              ; 2
    sta    yPosShuttle      ; 3
    bne    .inSpace1        ; 3

.contAppear:
    inc    arkAppearCnt     ; 5
.inSpace1:

    lda    explosionCnt     ; 3             shuttle exploding?
    beq    .noExplosion     ; 2³             no, skip
    and    #$f8             ; 2              yes, animate explosions
    clc                     ; 2
    adc    #<Explosion0     ; 2
    tay                     ; 2
    dec    explosionCnt     ; 5             explosion finished
    bne    .setShuttlePtr   ; 2³+1           no, continue
    lda    #SCREEN_WIDTH/2-4; 2              yes, position shuttle inside Ark
    sta    xPosShuttle      ; 3
    lda    #86              ; 2
    sta    yPosShuttle      ; 3
    rol    status           ; 5             disable shuttle mode
    clc                     ; 2
    ror    status           ; 5
    lda    numBeasties      ; 3             any beasties captured?
    beq    .setShuttlePtr   ; 2³+1           no, skip
    jsr    ReleaseBeastie   ; 6              yes, release one and...
    dec    numBeasties      ; 5             ...decrease number
.noExplosion:
    ldy    #<Shuttle0       ; 2             animate shuttle
    lda    frameCnt         ; 3
    and    #$02             ; 2
    beq    .setShuttlePtr   ; 2³+1
    ldy    #<Shuttle1       ; 2
.setShuttlePtr:
    sty    shuttlePtr       ; 3
    lda    arkAppearCnt     ; 3             Ark moving down?
    bpl    .skipNew         ; 2³             yes, skip new meteor
    lda    meteorDir        ; 3             meteor on screen
    bne    .skipNew         ; 2³             yes, skip
    jsr    NewMeteor        ; 6              no, create new meteor
.skipNew:

;*** move meteor ***
    ldy    meteorDir        ; 3             meteor displayed?
    beq    .endMoveMeteor   ; 2³             no ,skip moving

;calculate current meteor speed:
    ldx    speedHi          ; 3             slow down meteor
    lda    meteorPosLo      ; 3
    clc                     ; 2
    adc    speedLo          ; 3
    sta    meteorPosLo      ; 3
    bcc    .skipOverflow    ; 2³
    inx                     ; 2
.skipOverflow:
    stx    tempVar          ; 3             current result speed in pixel

;decrese meteor speed:
    lda    speedLo          ; 3
    cmp    #128             ; 2             minimum speed >= 128? (= 1/2 pixel/frame)
                            ;                (not adjusted for PAL!)
                            ;               JTZ: The code doesn't perfectly limit the minimum meteor speed to
                            ;                128 (NTSC:128-24, PAL: 128-32), therefore sometimes in the lower
                            ;                levels the meteors can be *slower* than in the previous one.
                            ;                This also causes some speed differences in the PAL conversion.                             ;
                            ;
    bcs    .decSpeed        ; 2³             yes, decrease
    lda    speedHi          ; 3
    beq    .endDecSpeed     ; 2³
.decSpeed:
    lda    speedLo          ; 3             reduce the meteor speed
    sec                     ; 2
  IF OPTIMIZE
    sbc    SpeedDecTab-1,y  ; 4             horizontal meteors slow down much faster than vertical ones
  ELSE
    sbc    SpeedDecTab,y    ; 4             horizontal meteors slow down much faster than vertical ones
  ENDIF
    sta    speedLo          ; 3
    bcs    .endDecSpeed     ; 2³
    dec    speedHi          ; 5
.endDecSpeed:

;move the meteor:
    ldx    #0               ; 2             "not wavering" value
    bit    waveringFlag     ; 3             meteor wavering
    bpl    .notWavering0    ; 2³             no, skip
    lda    waveringCnt      ; 3
    and    #$07             ; 2
    tax                     ; 2
    lda    WaveringTab,x    ; 4
    tax                     ; 2
    inc    waveringCnt      ; 5             continue wavering
.notWavering0:
    cpy    #METEOR_LEFT     ; 2             check direction of meteor
    beq    .meteorLeft      ; 2³
    cpy    #METEOR_RIGHT    ; 2
    beq    .meteorRight     ; 2³
    cpy    #METEOR_UP       ; 2
    beq    .meteorUp        ; 2³

    lda    yPosMeteor       ; 3             meteor moves down
    clc                     ; 2
    adc    tempVar          ; 3
    bne    .contMeteorDown  ; 3

.meteorUp:
    lda    yPosMeteor       ; 3             meteor moves up
    sec                     ; 2
    sbc    tempVar          ; 3
.contMeteorDown:
    sta    yPosMeteor       ; 3
    txa                     ; 2             add wavering value
    clc                     ; 2
    adc    xPosMeteor       ; 3
    sta    xPosMeteor       ; 3
    bne    .endMoveMeteor   ; 3

.meteorLeft:
    lda    xPosMeteor       ; 3             meteor moves left
    clc                     ; 2
    adc    tempVar          ; 3
    bne    .contMeteorLeft  ; 3

.meteorRight:
    lda    xPosMeteor       ; 3             meteor move right
    sec                     ; 2
    sbc    tempVar          ; 3
.contMeteorLeft:
    sta    xPosMeteor       ; 3
    txa                     ; 2             add wavering value
    clc                     ; 2
    adc    yPosMeteor       ; 3
    sta    yPosMeteor       ; 3
.endMoveMeteor:

    ldy    #0               ; 2             disable beam (might be enabled again later)
    sty    yPosBeam         ; 3
    bit    status           ; 3
    bpl    .skipBeam        ; 2³
    lda    explosionCnt     ; 3             shuttle exploding?
    bne    .skipFire        ; 2³             yes, skip fire button
    jsr    GetPlayer        ; 6             get number of current player
    lda    INPT4-$30,x      ; 4             fire button pressed?
    sta    fireButton       ; 3
    bpl    .beamFire        ; 2³             yes, check for beaming
.skipFire:
    lda    channel1Sound    ; 3             disable beam sound
    and    ~#BEAM_SOUND     ; 2
    sta    channel1Sound    ; 3
    lda    beamStatus       ; 3             currently beaming?
    bpl    .skipBeam        ; 2³             no, skip
    lda    #DROP_BEASTIE    ; 2              yes, drop beastie
    sta    beamStatus       ; 3
    bne    .skipBeam        ; 3

.beamFire:
    lda    yPosShuttle      ; 3
    cmp    #78              ; 2             shuttle in Ark?
    bcs    .skipBeam        ; 2³             yes, skip beaming
    lda    channel1Sound    ; 3
    and    ~#SHUTTLE_SOUND  ; 2             disable shuttle sound...
    ora    #BEAM_SOUND      ; 2             ...and enable beam sound
    sta    channel1Sound    ; 3
    lda    frameCnt         ; 3
    lsr                     ; 2
    bcc    .endJoyStick     ; 2³
    lda    xPosShuttle      ; 3             calc position of tractor beam
    clc                     ; 2
    adc    #$03             ; 2
    sta    xPosBeam         ; 3
    ldy    yPosShuttle      ; 3
    sty    yPosBeam         ; 3             (re)enable tractor beam
    cpy    #$00             ; 2
    bne    .endJoyStick     ; 2³
.skipBeam:
    lda    arkAppearCnt     ; 3             Ark at final position?
    bmi    .checkJoystick   ; 2³             yes, check joystick
.endJoyStick:
    jmp    .skipRight       ; 3

.checkJoystick:
    bit    gameStatus       ; 3             game running
    bpl    .endJoyStick     ; 2³             no, skip joystick direction checks
    jsr    GetPlayer        ; 6
    lda    SWCHA            ; 4
    cpx    #1               ; 2             player 1 ?
    beq    .player1         ; 2³             yes, skip shifts
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
.player1:
    and    #%1111           ; 2
    bit    status           ; 3
    bmi    .skipShot        ; 2³+1
    bvs    .onPlanet        ; 2³
    ldy    fuel             ; 3             no fuel?
    beq    .endJoyStick     ; 2³             yes, skip fire
.onPlanet:
    cmp    joyDir           ; 3             new dir = old dir?
    beq    .endJoyStick     ; 2³             yes, don't shot
    sta    joyDir           ; 3
    cmp    #LEFT_DIR        ; 2
    beq    .leftDir         ; 2³+1
    cmp    #RIGHT_DIR       ; 2
    beq    .rightDir        ; 2³+1
    cmp    #UP_DIR          ; 2
    beq    .upDir           ; 2³+1
    cmp    #DOWN_DIR        ; 2
    beq    .downDir         ; 2³+1
.endJoyStickJMP:
    bne    .endJoyStick     ; 3+1

.upDir:
    lda    #96              ; 2
    sta    yPosShot         ; 3
    lda    #SHOT_UP         ; 2
.contDown:
    sta    shotDir          ; 3
    lda    #SCREEN_WIDTH/2  ; 2
    sta    xPosShotBeam     ; 3
    bne    .endDir          ; 3

.downDir:
    bit    status           ; 3             shooting down on planet not allowed
    bvc    .inSpace4        ; 2³
    rol    status           ; 5             enable shuttle mode instead
    sec                     ; 2
    ror    status           ; 5
    bne    .skipShot        ; 3

.inSpace4:
    lda    #92              ; 2
    sta    yPosShot         ; 3
    lda    #SHOT_DOWN       ; 2
    bne    .contDown        ; 3

.leftDir:
    lda    #SCREEN_WIDTH/2-8; 2
    sta    xPosShotBeam     ; 3
    lda    #SHOT_LEFT       ; 2
.contRight:
    sta    shotDir          ; 3
    lda    #96              ; 2
    sta    yPosShot         ; 3
.endDir:

    lda    channel0Sound    ; 3             enable shot sound
    ora    #SHOT_SOUND      ; 2
    sta    channel0Sound    ; 3
    bit    status           ; 3             on planet
    bvs    .onPlanet1       ; 2³             yes, skip
    dec    fuel             ; 5              no, reduce energy
.onPlanet1:
    lda    #6               ; 2             set shot sound time
    sta    channel0Time     ; 3
    bne    .endJoyStickJMP  ; 3+1

.rightDir:
    lda    #SCREEN_WIDTH/2+8; 2
    sta    xPosShotBeam     ; 3
    lda    #SHOT_RIGHT      ; 2
    bne    .contRight       ; 3

.skipShot:
    ldx    explosionCnt     ; 3             shuttle exploding?
    beq    .noExplosion1    ; 2³             no, skip
    lda    #NO_DIR          ; 2             disable joystick
.noExplosion1:
    sta    tempVar          ; 3             remember joystick value
    tay                     ; 2
    lda    channel1Sound    ; 3
    and    ~#SHUTTLE_SOUND  ; 2             disable shuttle sound
    cpy    #NO_DIR          ; 2             joystick moved?
    beq    .notMoved        ; 2³             no, keep shuttle sound disabled
    ora    #SHUTTLE_SOUND   ; 2             enable shuttle sound again
.notMoved:
    sta    channel1Sound    ; 3
    lsr    tempVar          ; 5             joystick moved up?
    bcs    .endUpDir        ; 2³             no
    lda    yPosShuttleLo    ; 3             move shuttle up
    adc    shutteSpeedLo    ; 3
    sta    yPosShuttleLo    ; 3
    bcc    .endUpDir        ; 2³
    lda    yPosShuttle      ; 3
    cmp    #77              ; 2             shuttle right below Ark?
    bcc    .lowShuttle      ; 2³             no, lower
    lda    xPosShuttle      ; 3
    cmp    #SCREEN_WIDTH/2-5; 2             shuttle horizontally at middle of Ark?
    bcc    .endUpDir        ; 2³             no, to far left
    cmp    #SCREEN_WIDTH/2-2; 2
    bcs    .endUpDir        ; 2³             no, to far right
.lowShuttle:
    inc    yPosShuttle      ; 5
    lda    yPosShuttle      ; 3
    cmp    #86              ; 2             shuttle inside Ark?
    bne    .endUpDir        ; 2³             no, skip

;shuttle returns into Ark:
    lda    status           ; 3             disable shuttle mode
    and    ~#SHUTTLE_MODE   ; 2
    sta    status           ; 3
    lda    channel1Sound    ; 3
    and    ~#SHUTTLE_SOUND  ; 2             disable shuttle sound
    sta    channel1Sound    ; 3
    lda    numBeasties      ; 3
    cmp    #2               ; 2             both beasties captured?
    bcc    .endUpDir        ; 2³             no, skip

;both beasties rescued at once before alert gives full fuel:
    lda    alertCnt         ; 3             alert started?
    bne    .endUpDir        ; 2³             yes, don't start Ark
    lda    meteorDir        ; 3             meteor on screen?
    bne    .endUpDir        ; 2³             yes, don't start Ark
    lda    oldNumBeasties   ; 3             no beasties captured before?
    bne    .skipMaxFuel     ; 2³             no, skip max. fuel
    lda    #MAX_FUEL-1      ; 2             gain maximum fuel
    sta    fuel             ; 3
.skipMaxFuel:
    jsr    StartArkUp       ; 6
.endUpDir:

    lsr    tempVar          ; 5             joystick moved down?
    bcs    .skipDown        ; 2³             no, skip down
    lda    yPosShuttleLo    ; 3
    adc    shutteSpeedLo    ; 3
    sta    yPosShuttleLo    ; 3
    bcc    .skipDown        ; 2³
    lda    yPosShuttle      ; 3
    cmp    #22              ; 2             shuttle at lowest position?
    bcc    .skipDown        ; 2³             yes, skip
    dec    yPosShuttle      ; 5              no, move further down
.skipDown:
    lda    yPosShuttle      ; 3
    cmp    #78              ; 2             shuttle moving into Ark?
    bcs    .skipRight       ; 2³             yes, skip left and right
    lsr    tempVar          ; 5             joystick moved left?
    bcs    .skipLeft        ; 2³             no, skip left
    lda    xPosShuttle      ; 3
    cmp    #1               ; 2             shuttle at left border?
    beq    .skipLeft        ; 2³             yes, skip move left

;*** move the shuttle: ***
;the lower registers are used to allow fine speed adjustments
;they are always added, even if the player moves left or down!
    lda    xPosShuttleLo    ; 3
    adc    shutteSpeedLo    ; 3
    sta    xPosShuttleLo    ; 3
    bcc    .skipLeft        ; 2³
    dec    xPosShuttle      ; 5
.skipLeft:
    lsr    tempVar          ; 5             joystick moved right?
    bcs    .skipRight       ; 2³             no, skip right
    lda    xPosShuttle      ; 3
    cmp    #SCREEN_WIDTH-10 ; 2             shuttle at right border?
    beq    .skipRight       ; 2³             yes, skip right
    lda    xPosShuttleLo    ; 3
    adc    shutteSpeedLo    ; 3
    sta    xPosShuttleLo    ; 3
    bcc    .skipRight       ; 2³
    inc    xPosShuttle      ; 5
.skipRight:

;process shot:
    ldx    #MS_SIZE1        ; 2             small missile size
    lda    shotDir          ; 3
    beq    .contShot        ; 2³+1
    cmp    #SHOT_LEFT       ; 2
    beq    .shotLeft        ; 2³+1
    cmp    #SHOT_RIGHT      ; 2
    beq    .shotRight       ; 2³+1
    ldx    #MS_SIZE1        ; 2
    cmp    #SHOT_UP         ; 2
    beq    .shotUp          ; 2³+1
    cmp    #SHOT_DOWN       ; 2
    bne    .contShot        ; 2³
    lda    yPosShot         ; 3             move shot down
    sec                     ; 2
    sbc    #8               ; 2
    sta    yPosShot         ; 3             shot at bottom of screen?
    bmi    .disableShot     ; 2³             yes, disable
    bpl    .contShot        ; 3

.shotUp:
    lda    yPosShot         ; 3             move shot up
    clc                     ; 2
    adc    #8               ; 2
    sta    yPosShot         ; 3
    cmp    #192             ; 2             shot at top of screen?
    bcs    .disableShot     ; 2³             yes, disable
    bcc    .contShot        ; 3

.shotLeft:
    ldx    #MS_SIZE8        ; 2             wide missile size
    lda    xPosShotBeam     ; 3             move shot left
    sec                     ; 2
    sbc    #8               ; 2
    sta    xPosShotBeam     ; 3             shot at left border?
    bpl    .contShot        ; 2³             yes, disable
.disableShot:
    ldx    #0               ; 2
    stx    shotDir          ; 3
    stx    yPosShot         ; 3
    beq    .contShot        ; 3

.shotRight:
    ldx    #MS_SIZE8        ; 2             wide missile
    lda    xPosShotBeam     ; 3             move shot right
    clc                     ; 2
    adc    #8               ; 2
    sta    xPosShotBeam     ; 3
    cmp    #SCREEN_WIDTH    ; 2             shot at right border?
    bcs    .disableShot     ; 2³             yes, disable
.contShot:
    stx    NUSIZ1           ; 3

;animate center line of Ark:
    lda    arkHitCnt        ; 3             Ark hit?
    bne    .skipAnimate     ; 2³             yes, skip center animation

    lda    arkPatLst+9      ; 3
    beq    .skipAnimate     ; 2³
    lda    frameCnt         ; 3             progress animation every 8th frame
    and    #$07             ; 2
    tay                     ; 2
    lda    AnimateTab,y     ; 4
    sta    arkPatLst+9      ; 3
.skipAnimate:

    lda    arkHitCnt        ; 3
    bne    .noBottomCenter  ; 2³
    ldx    #$fe             ; 2             small Ark pattern
    lda    alertCnt         ; 3
    beq    .noAlert         ; 2³
    and    #$10             ; 2             Ark changes width during alert
    beq    .smallArk        ; 2³
    bne    .wideArk         ; 3

.noAlert:
    bit    SWCHB            ; 4             P0 difficutly
    bvc    .smallArk        ; 2³             B(eginner), skip
.wideArk:
    ldx    #$ff             ; 2             A(dvanced), make center of Ark wider
.smallArk:
    lda    arkPatLst+7      ; 3             top center
    beq    .noTopCenter     ; 2³
    stx    arkPatLst+7      ; 3
.noTopCenter:
    lda    arkPatLst+11     ; 3             bottom center
    beq    .noBottomCenter  ; 2³
    stx    arkPatLst+11     ; 3
.noBottomCenter:
    lda    status           ; 3
    and    #GAME_OVER       ; 2             game over?
    beq    .skipStartEscape ; 2³             no, skip
    lda    arkHitCnt        ; 3
    cmp    #1               ; 2             Ark disappeared completely?
    bne    .skipStartEscape ; 2³             no, skip

;game over, show escape shuttle:
    lda    #>Shuttle0       ; 2             draw shuttle instead of meteor
    sta    meteorPtr+1      ; 3
    lda    #SCREEN_WIDTH/2  ; 2             position shuttle at center of screen
    sta    xPosMeteor       ; 3
    lda    #80              ; 2
    sta    yPosMeteor       ; 3
    lda    #GREEN2+6        ; 2
    sta    P1SpaceCol       ; 3
    lda    #$30             ; 2             escape shuttle starts moving left
    sta    speedLo          ; 3
    lda    #$fb             ; 2
    sta    speedHi          ; 3
    lda    #SHUTTLE_SOUND   ; 2             enable shuttle sound
    sta    channel1Sound    ; 3
    lda    #$ff             ; 2             set game over flag
    sta    gameOver         ; 3
.skipStartEscape:
    lda    gameOver         ; 3             game over
    beq    .endMoveShuttle  ; 2³             no, skip

;move the escape shuttle:
    lda    speedLo          ; 3             change shuttle speed
    clc                     ; 2
    adc    #$30             ; 2
    sta    speedLo          ; 3
    bcc    .skipIncHi       ; 2³
    inc    speedHi          ; 5
.skipIncHi:
    lda    speedHi          ; 3             shuttle moving right?
    bmi    .skipEscapeDown  ; 2³             no, skip
    dec    yPosMeteor       ; 5              yes, move shuttle down
.skipEscapeDown:
    lda    meteorPosLo      ; 3
    clc                     ; 2
    adc    speedLo          ; 3
    sta    meteorPosLo      ; 3
    lda    xPosMeteor       ; 3
    adc    speedHi          ; 3
    cmp    #SCREEN_WIDTH-4  ; 2             shuttle at right border?
    bcs    .disableShuttle  ; 2³             yes, disable escape shuttle
    sta    xPosMeteor       ; 3              no, continue moving
  IF OPTIMIZE
    bcc    .endMoveShuttle  ; 3
    FILL_NOP 1
  ELSE
    jmp    .endMoveShuttle  ; 3
  ENDIF

.disableShuttle:
    lda    #0               ; 2             disable game over flag
    sta    gameOver         ; 3
    sta    yPosMeteor       ; 3
    sta    channel1Sound    ; 3             disable all sounds in channel 1
    lda    #RUNNING|START_MODE; 2           game status = running in start mode
    sta    gameStatus       ; 3
    lda    status           ; 3             status = no shuttle and in space
    and    ~#[SHUTTLE_MODE|ON_PLANET]; 2
    sta    status           ; 3
    lda    scoreLow         ; 3             show game number - 1 at last score digit
    and    #$f0             ; 2
    sta    tempVar          ; 3
    ldx    gameNum          ; 3
    dex                     ; 2
    txa                     ; 2
    ora    tempVar          ; 3
    sta    scoreLow         ; 3
.endMoveShuttle:
    lda    gameOver         ; 3             game over?
    beq    .setMeteorPtr    ; 2³             no, show meteors
    ldy    #<Shuttle0       ; 2              yes, show escape shuttle
    lda    frameCnt         ; 3             animate escape shuttle every 2nd frame
    and    #$02             ; 2
    bne    .show0           ; 2³
    ldy    #<Shuttle1       ; 2
.show0:
    sty    meteorPtr        ; 3
  IF OPTIMIZE
    bne    .endUpdateGame   ; 3
    FILL_NOP 1
  ELSE
    jmp    .endUpdateGame   ; 3
  ENDIF

.setMeteorPtr:
    lda    frameCnt         ; 3             animate meteor
    and    #<Meteor3        ; 2              every 8th frame
    sta    meteorPtr        ; 3
    lda    #>Meteor0        ; 2
    sta    meteorPtr+1      ; 3
.endUpdateGame:

;flicker the stars:
    ldy    starColumn       ; 3             move flickering stars
    lda    frameCnt         ; 3
    and    #$07             ; 2
    bne    .skipFlicker     ; 2³
    iny                     ; 2
    cpy    #NUM_STARCOLUMS  ; 2
    bne    .skipFlicker     ; 2³
    ldy    #0               ; 2             reset position
.skipFlicker:
    sty    starColumn       ; 3
    lda    xPosStarsTab,y   ; 4             set star columns position
    sta    xPosStars        ; 3

;show game number, copyright or scores:
    ldx    #$00             ; 2
    lda    gameStatus       ; 3
    and    #SHOW_GAMENUM    ; 2             show game number?
    beq    .setScorePtr     ; 2³             no, display score
    txa                     ; 2             show leading blanks
    jsr    SetDigitLowPtr   ; 6
    lda    gameNum          ; 3
    jsr    SetDigitLowPtr   ; 6
    lda    #$aa             ; 2             show trailing blanks (10,10)
    jsr    SetDigitLowPtr   ; 6
  IF OPTIMIZE
    bne    .endSetDigitPtr  ; 3
    FILL_NOP 1
  ELSE
    jmp    .endSetDigitPtr  ; 3
  ENDIF

.setScorePtr:
    bit    gameStatus       ; 3             game running?
    bpl    .setCopyRightPtr ; 2³             no, show copyright
    lda    scoreHi          ; 3              yes, show score
    jsr    SetDigitLowPtr   ; 6
    lda    scoreMid         ; 3
    jsr    SetDigitLowPtr   ; 6
    lda    scoreLow         ; 3
    jsr    SetDigitLowPtr   ; 6
.endSetDigitPtr:

; replace leading zeros with blanks:
    ldx    #0               ; 2
.loopBlanks:
    lda    digitPtr,x       ; 4             digit != 0?
    bne    .endDigitPtr     ; 2³             yes, exit
    lda    #<Blank          ; 2
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    cpx    #NUM_DIGITS*2-2  ; 2
    bne    .loopBlanks      ; 2³
    beq    .endDigitPtr     ; 3

.setCopyRightPtr:
    lda    #<Copyright5     ; 2
    ldx    #NUM_DIGITS*2-2  ; 2
.loopCopyright:
    sta    digitPtr,x       ; 4
    sec                     ; 2
    sbc    #DIGIT_HEIGHT    ; 2             -10
    dex                     ; 2
    dex                     ; 2
    bpl    .loopCopyright   ; 2³
.endDigitPtr:
    jmp    StartKernel      ; 3


OverScan SUBROUTINE
;*** end of display kernel, start of overscan area ***
  IF NTSC
    lda    #35              ; 2
  ELSE
    lda    #59              ; 2
  ENDIF
    sta    TIM64T           ; 4
    pla                     ; 4             save Ark/meteor collisions...
    sta    tempVar          ; 3             ...in tempVar

;check beam/beastie collisions:
    lda    beamStatus       ; 3             currently beaming a beastie?
    bmi    .skipCheckColl   ; 2³             yes, skip check collisions
    ldx    #0               ; 2
    bit    CXP0FB-$30       ; 3             beastie 0 hit by beam?
    bvs    .startBeam       ; 2³             yes, start beaming
    inx                     ; 2
    bit    CXP1FB-$30       ; 3             beastie 1 hit by beam?
    bvc    .skipStartBeam   ; 2³             yes, skip start beaming
.startBeam:
    sta    beastie0Status,x ; 4             = %0xxxxxxx
    lda    #BEAM_BEASTIE    ; 2
    sta    beamStatus       ; 3
    lda    #6               ; 2
    sta    yBeamedBeastie   ; 3             start beaming up beastie
    lda    xPosShuttle      ; 3
    clc                     ; 2
    adc    #3               ; 2
    sta    xPosShotBeam     ; 3
.skipStartBeam:

    bit    CXM1P-$30        ; 3             meteor hit by shot?
    bvs    .meteorHit       ; 2³             yes, disable meteor
.skipCheckColl:
    lda    tempVar          ; 3             Ark / meteor collision?
    bpl    .noCollision     ; 2³             no, skip

;Ark was hit by meteor:
    lda    #0               ; 2
    sta    arkAppearCnt     ; 3
    sta    yPosShuttle      ; 3
    sta    channel0Sound    ; 3             disable all sounds
    sta    channel1Sound    ; 3
    sta    yBeamedBeastie   ; 3             clear beastie beam position
    sta    beamStatus       ; 3
    lda    status           ; 3             disable shuttle mode
    and    ~#SHUTTLE_MODE   ; 2
    sta    status           ; 3
    lda    #$c0             ; 2
    sta    arkHitCnt        ; 3
    bit    gameStatus       ; 3             game running?
    bpl    .disableMeteor   ; 2³+1           no,
    lda    fuel             ; 3              yes, decrease fuel
    sec                     ; 2
    sbc    #10              ; 2
    sta    fuel             ; 3
    bcs    .disableMeteor   ; 2³+1
    lda    #0               ; 2             out of energy
    sta    fuel             ; 3
    lda    status           ; 3             game is over
    ora    #GAME_OVER       ; 2
    sta    status           ; 3
    bne    .disableMeteor   ; 3+1

.noCollision:
    lda    status           ; 3             shuttle mode and...
    and    defenseStatus    ; 3             ...defense fireing?
    bpl    .dropBeastie     ; 2³+1           no, skip
    lda    yPosShuttle      ; 3              yes, check for defense hit at shuttle
    cmp    yPosDefense      ; 3
    bcs    .dropBeastie     ; 2³+1           no, shuttle to high
    adc    #5               ; 2
    cmp    yPosDefense      ; 3
    bcc    .dropBeastie     ; 2³+1           no, shuttle to low
    lda    explosionCnt     ; 3             shuttle already exploding?
    bne    .dropBeastie     ; 2³+1           no, skip
    lda    #23              ; 2              yes, start shuttle explosion
    sta    explosionCnt     ; 3
    bne    .dropBeastie     ; 3+1

.meteorHit:
    ldy    #0               ; 2             disable meteor
    sty    yPosShot         ; 3
    sty    shotDir          ; 3
    sty    channel1Time     ; 3
    ldx    #0               ; 2
    lda    #$10             ; 2             +10 points
    bit    waveringFlag     ; 3             wavering meteor?
    bpl    .notWavering1    ; 2³             no, skip
    lda    #$30             ; 2             +30 points
.notWavering1:
    jsr    AddScore         ; 6
    lda    fuel             ; 3             get fuel back
    cmp    #MAX_FUEL-1      ; 2
    beq    .skipRefuel      ; 2³
    inc    fuel             ; 5
.skipRefuel:
    bit    gameFlags        ; 3             meteor game?
    bpl    .skipRefuel2     ; 2³             no, skip
    lda    fuel             ; 3              yes, get fuel back twice
    cmp    #MAX_FUEL-1      ; 2
    beq    .skipRefuel2     ; 2³
    inc    fuel             ; 5
.skipRefuel2:
    lda    channel0Sound    ; 3             disable shot sound
    and    ~#SHOT_SOUND     ; 2
    sta    channel0Sound    ; 3
.disableMeteor:
    lda    #0               ; 2             disable meteor
    sta    meteorDir        ; 3
    sta    yPosMeteor       ; 3

.dropBeastie:
;drop beamed beastie:
    bit    beamStatus       ; 3             beastie dropped?
    bvc    .skipDrop        ; 2³             no, skip

    lda    yBeamedBeastie   ; 3             beastie falls down
    sec                     ; 2
    sbc    #4               ; 2
    sta    yBeamedBeastie   ; 3
    cmp    #6               ; 2             beam position back at bottom?
    bcs    .endBeaming      ; 2³             no, skip
    jsr    ReleaseBeastie   ; 6              yes, release beastie
    lda    #0               ; 2
    sta    beamStatus       ; 3
    sta    yBeamedBeastie   ; 3             disable beam position
.skipDrop:
    bit    beamStatus       ; 3             beaming a beastie?
    bpl    .endBeaming      ; 2³             no, skip
    lda    frameCnt         ; 3              yes, beam up the beastie
    lsr                     ; 2
    bcc    .endBeaming      ; 2³
    inc    yBeamedBeastie   ; 5
    lda    yBeamedBeastie   ; 3
    cmp    yPosShuttle      ; 3             beastie beam at shuttle?
    bne    .endBeaming      ; 2³             no, skip
    lda    #0               ; 2              yes, captured!
    sta    beamStatus       ; 3
    sta    yBeamedBeastie   ; 3
    lda    #15              ; 2             set captured sound time
    sta    channel0Time     ; 3
    lda    channel0Sound    ; 3             enable beastie captured sound
    ora    #CAPTURED_SOUND  ; 2
    sta    channel0Sound    ; 3
    inc    numBeasties      ; 5             increase number of captured beasties
.endBeaming:

    lda    arkHitCnt        ; 3
  IF OPTIMIZE
    beq    .contNormal      ; 3
    FILL_NOP 3
  ELSE
    bne    .disappearArk    ; 2³
    jmp    .contNormal      ; 3
  ENDIF

.disappearArk:
    cmp    #151             ; 2             Ark completely disappeared?
    bcs    .disappeared     ; 2³             yes, skip
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    tay                     ; 2
    ldx    ArkAppearTab,y   ; 4
    lda    #0               ; 2             clear one whole line of Ark
    sta    arkPatLst,x      ; 4
.disappeared:

;randomly flicker remaining Ark lines:
    lda    frameCnt         ; 3
    and    #$03             ; 2             every 4th frame
    bne    .skipClear       ; 2³
    ldx    #ARK_HEIGHT-1    ; 2
    ldy    random           ; 3
.loopClear:
    lda    arkPatLst,x      ; 4             line already cleared?
    beq    .skipLine        ; 2³             yes, skip line
    lda    StartKernel,y    ; 4             use random ROM-code to make Ark disappear
    bne    .notZero         ; 2³
    tya                     ; 2
.notZero:
    and    ArkPatTab,x      ; 4             clear random bits in all lines
    sta    arkPatLst,x      ; 4
    iny                     ; 2             next byte of code
.skipLine:
    dex                     ; 2             next line
    bpl    .loopClear       ; 2³
.skipClear:
    dec    arkHitCnt        ; 5             Ark completely disappeared?
    bne    .contNormal      ; 2³             no, continue
    lda    status           ; 3
    and    #GAME_OVER       ; 2             game over?
    beq    .contGame        ; 2³             no, continue
    lda    status           ; 3              yes, new status: in space and shuttle mode disabled
    and    ~#[SHUTTLE_MODE|ON_PLANET]; 2
    sta    status           ; 3
    lda    #0               ; 2             disable all sounds of channel 0
    sta    channel0Sound    ; 3
    sta    frameCnt+1       ; 3             reset screen saver counter
    beq    .contGameOver    ; 3

.contGame:
    bit    gameStatus       ; 3             game running?
    bpl    .skipRepeatLevel ; 2³             no, toggle section in demo mode
    bit    status           ; 3
    bvc    .inSpace         ; 2³
    lda    #0               ; 2             reset number of captured beasties
    sta    numBeasties      ; 3
    lda    levelMeteors     ; 3             init number of normal meteors
    sta    numMeteors       ; 3
    bne    .contArkHit      ; 3

.inSpace:
    lda    numMeteors       ; 3             add two more normal meteors to current wave
    clc                     ; 2              (the missed plus a penalty)
    adc    #2               ; 2
    sta    numMeteors       ; 3
.contArkHit:
    lda    status           ; 3             new status: in space and shuttle mode disabled
    and    ~#[SHUTTLE_MODE|ON_PLANET]; 2
    sta    status           ; 3
    jsr    InitLevel2       ; 6             init without reseting number of meteors
  IF OPTIMIZE
    bne    .skipToggle      ; 3
    FILL_NOP 1
  ELSE
    jmp    .skipToggle      ; 3
  ENDIF

.skipRepeatLevel:
    lda    status           ; 3             toggle section (planet <-> space)
    eor    #ON_PLANET       ; 2
    sta    status           ; 3
    jsr    InitLevel        ; 6             (re)init the current level
.skipToggle:
    jsr    StartArkDown     ; 6
.contGameOver:
    lda    status           ; 3             disable GAME_OVER flag
    and    ~#GAME_OVER      ; 2
    sta    status           ; 3
.contNormal:
    bit    status           ; 3             on planet?
    bvs    .doPlanet        ; 2³             yes, process planet
    jmp    .skipDefense     ; 3

.doPlanet:
    lda    frameCnt         ; 3
    and    #$07             ; 2
    bne    .endActivate     ; 2³+1
    inc    planetTime       ; 5
    lda    planetTime       ; 3
    cmp    alertTime        ; 3             alert time reached?
    bne    .skipAlertStart  ; 2³             no, skip
    lda    status           ; 3              yes, enable alert
    and    #ARK_UPDOWN       ; 2            Ark already moving up?
    bne    .skipAlertStart  ; 2³             yes, skip start countdown
    lda    #$ff             ; 2              no, start alert countdown
    sta    alertCnt         ; 3
.skipAlertStart:
    lda    defenseStatus    ; 3
    and    #ACTIVE          ; 2
    bne    .endActivate     ; 2³+1
    lda    level            ; 3
    cmp    #1               ; 2             first level?
    bcc    .endActivate     ; 2³+1           yes, no defense system
    lda    #16              ; 2              no, activate defense system...
    cmp    planetTime       ; 3              ...after 8*16 frames (~2 sec.)
    bne    .endActivate     ; 2³
    lda    #ACTIVE|DIR_UP   ; 2             activate and move up
    sta    defenseStatus    ; 3
.endActivate:

;set beastie pattern pointer:
    lda    beastieId        ; 3
    asl                     ; 2
    tay                     ; 2
    lda    frameCnt         ; 3
    and    #$04             ; 2             change beastie pattern every 4th frame
    bne    .firstAnimation  ; 2³
    iny                     ; 2
.firstAnimation:
    tya                     ; 2
    jsr    Mult10           ; 6
    clc                     ; 2
    adc    #<Beastie0       ; 2
    sta    beastiePtr       ; 3

    lda    frameCnt         ; 3             move only one beastie / frame
    and    #$01             ; 2
    tax                     ; 2
    lda    beastie0Status,x ; 4             beastie runs left?
    bpl    .runLeft         ; 2³             yes, move left
    lda    xPosBeastie0,x   ; 4
    beq    .negDir          ; 2³
    dec    xPosBeastie0,x   ; 6

;beastie "AI" (they stay away from enabled tractor beam):
    lda    fireButton       ; 3             beam enabled?
    bmi    .noBeam          ; 2³             no, skip
    lda    xPosBeam         ; 3              yes, let beastie stay away from beam
    clc                     ; 2
    adc    #$03             ; 2
    cmp    xPosBeastie0,x   ; 4             beastie close to beam?
    beq    .negDir          ; 2³             yes, run away!
    bne    .noBeam          ; 3              no, change direction randomly

.runLeft:
    lda    xPosBeastie0,x   ; 4
    cmp    #SCREEN_WIDTH-5  ; 2
    beq    .negDir          ; 2³
    inc    xPosBeastie0,x   ; 6

;beastie "AI" repeated:
    lda    INPT4-$30        ; 3             beam enabled?
    bmi    .noBeam          ; 2³             no, skip
    lda    xPosBeastie0,x   ; 4              yes, let beastie stay away from beam
    clc                     ; 2
    adc    #$07             ; 2
    cmp    xPosBeam         ; 3             beastie close to beam?
    beq    .negDir          ; 2³             yes, run away!
.noBeam:
    lda    random           ; 3              no, change direction randomly
    and    #$07             ; 2             change direction?
    bne    .skipNegDir      ; 2³             no skip
.negDir:
    lda    beastie0Status,x ; 4             reverse beastie direction
    eor    #BEASTIE_LEFT    ; 2
    sta    beastie0Status,x ; 4
.skipNegDir:
    lda    defenseStatus    ; 3
    and    #ACTIVE          ; 2             defense system activated?
    beq    .skipDefense     ; 2³             no, skip
    lda    frameCnt         ; 3
    and    #$03             ; 2
    bne    .endMove         ; 2³
    bit    defenseStatus    ; 3             defense moves up or down
    bvc    .moveDown        ; 2³             down
    inc    yPosDefense      ; 5
    inc    yPosDefense      ; 5
    lda    yPosDefense      ; 3
    cmp    #80              ; 2             defense at top position
    bne    .endMove         ; 2³             no, skip
.reverseDir:
    lda    defenseStatus    ; 3             reverse defense system direction
    eor    #DIR_UP          ; 2
    sta    defenseStatus    ; 3
    jmp    .endMove         ; 3

.moveDown:
    dec    yPosDefense      ; 5
    dec    yPosDefense      ; 5
    lda    yPosDefense      ; 3
    cmp    #22              ; 2             defense at bottom position?
    beq    .reverseDir      ; 2³             yes, reverse direction
.endMove:

    inc    defenseDelay     ; 5
    rol    defenseStatus    ; 5
    ldx    yPosDefense      ; 3
    cpx    #22              ; 2             defense system at bottom position?
    bcc    .atBottom        ; 2³             yes, reset delay (don't fire)
    lda    defenseDelay     ; 3
    cmp    defenseFreq      ; 3             next defense fire?
    clc                     ; 2             flag disable fire
    bne    .noFire          ; 2³             no, disable
    sec                     ; 2             flag enable fire
.atBottom:
    lda    #0               ; 2             reset fire delay
    sta    defenseDelay     ; 3
.noFire:
    ror    defenseStatus    ; 5             set defense fire status
.skipDefense:

;*** play sounds of channel 0: ***
    ldy    #$00             ; 2
    bit    gameStatus       ; 3             game running?
    bmi    .useChannel1     ; 2³             yes, make some noise
    jmp    .setAudio1       ; 3              no, silence

.alertSound:
    ldy    #$08             ; 2             enable alert sound
    and    #$10             ; 2
    bne    .soundOn         ; 2³
    ldy    #$00             ; 2             disable alert sound
.soundOn:
    ldx    #$18             ; 2
    dec    alertCnt         ; 5             alert over?
    bne    .contAlert       ; 2³             no, skip
    lda    status           ; 3              yes, start bombardment
    and    ~#NO_METEORS     ; 2
    sta    status           ; 3
    lda    #1               ; 2             only one meteor
    sta    numMeteors       ; 3
.contAlert:
    lda    #1               ; 2
    bne    .setAudio0JMP    ; 3

.useChannel1:
    lda    arkHitCnt        ; 3             Ark hit?
    bne    .arkHitSound     ; 2³+1           yes, play hit sound
    lda    alertCnt         ; 3             alert enabled?
    bne    .alertSound      ; 2³             yes, play alert sound
    lda    channel0Sound    ; 3
    asl                     ; 2             Ark sound enabled?
    bcs    .arkSound        ; 2³+1           yes, play Ark sound
    asl                     ; 2             shot enabled?
    bcs    .shotSound       ; 2³+1           yes, play shot sound
    asl                     ; 2             captured sound enabed
    bcs    .capturedSound   ; 2³             yes, play captured sound
    lda    explosionCnt     ; 3             shuttle explosion?
    bne    .explosionSound  ; 2³             yes, play explosion sound
    bit    defenseStatus    ; 3             defense fireing?
    bpl    .setAudio0JMP    ; 2³             no, no sound
;defense fire sound:
    ldy    #$0e             ; 2
    lda    #$08             ; 2
    ldx    #$01             ; 2
.setAudio0JMP:
    jmp    .setAudio0       ; 3

.explosionSound:
    tax                     ; 2
    lsr                     ; 2
    tay                     ; 2
    lda    #$0c             ; 2
    bne    .setAudio0JMP    ; 3

.capturedSound:
    ldy    channel0Time     ; 3
    ldx    channel0Time     ; 3
    dec    channel0Time     ; 5
    bpl    .contCaptSound   ; 2³
    lda    channel0Sound    ; 3             disable beastie captured sound
    and    ~#CAPTURED_SOUND ; 2
    sta    channel0Sound    ; 3
.contCaptSound:
    lda    #$04             ; 2
    bne    .setAudio0JMP    ; 3+1

.arkHitSound:
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    tay                     ; 2
    ldx    #$03             ; 2
    lda    frameCnt         ; 3
    lsr                     ; 2
    bcc    .highFreq        ; 2³
    ldx    #$08             ; 2             lower frequency
.highFreq:
    lda    #$01             ; 2
    bne    .setAudio0JMP    ; 3+1

.shotSound:
    lda    #8               ; 2             set frequency of shot
    sec                     ; 2
    sbc    channel0Time     ; 3
    tax                     ; 2
    ldy    channel0Time     ; 3
    lda    ShotVolTab,y     ; 4             set volume of shot
    tay                     ; 2
    lda    #$01             ; 2
    dec    channel0Time     ; 5
    bpl    .contShotSound   ; 2³
    lda    channel0Sound    ; 3             disable shot sound
    and    ~#SHOT_SOUND     ; 2
    sta    channel0Sound    ; 3
.contShotSound:
    jmp    .setAudio0       ; 3

ShotVolTab:
    .byte $00, $04, $08, $0c, $08, $04, $02

.arkSound:
    lda    arkAppearCnt     ; 3             Ark appearing?
    beq    .skipAppearSound ; 2³             no, skip
    lsr                     ; 2
    cmp    #ARK_HEIGHT      ; 2
    bcs    .skipAppearSound ; 2³
    lsr                     ; 2             increase volume
    tay                     ; 2
    ldx    #$10             ; 2             change frequency every 2nd frame
    lda    frameCnt         ; 3
    lsr                     ; 2
    bcc    .skipLowFreq     ; 2³
    ldx    #$18             ; 2
.skipLowFreq:
    lda    #$04             ; 2
    bne    .setAudio0       ; 3

.skipAppearSound:
    ldx    #$08             ; 2             change frequency every 4th frame
    lda    frameCnt         ; 3
    lsr                     ; 2
    lsr                     ; 2
    bcc    .skipMedFreq     ; 2³
    ldx    #$10             ; 2
.skipMedFreq:
    lda    #$0c             ; 2
    ldy    #$08             ; 2
  IF OPTIMIZE
    FILL_NOP 2
  ELSE
    bne    .setAudio0       ; 3             really weird and superfluos code! :-)
  ENDIF

.setAudio0:
    sty    AUDV0            ; 3
    stx    AUDF0            ; 3
    sta    AUDC0            ; 3

;*** play sounds of channel 1: ***
    ldy    #$00             ; 2
    lda    channel1Sound    ; 3
    asl                     ; 2
    bcs    .meteorSound     ; 2³
    asl                     ; 2
    bcs    .shuttleSound    ; 2³
    asl                     ; 2
  IF OPTIMIZE
    bcc    .setAudio1       ; 2³
    FILL_NOP 3
  ELSE
    bcs    .beamSound       ; 2³
    jmp    .setAudio1       ; 3
  ENDIF

.beamSound:
    ldy    #$08             ; 2
    ldx    #$10             ; 2
    bit    beamStatus       ; 3             beaming a beastie
    bpl    .lowBeamFreq     ; 2³             no, skip
    ldx    #$04             ; 2              yes, higher frequency
.lowBeamFreq:
    lda    frameCnt         ; 3
    and    #$01             ; 2
    bne    .skipLowerFreq   ; 2³
    inx                     ; 2
.skipLowerFreq:
    lda    #$04             ; 2
    bne    .setAudio1       ; 3

.shuttleSound:
    ldy    #$00             ; 2             silence
    lda    frameCnt         ; 3
    and    #$02             ; 2
    beq    .noShuttleSound  ; 2³
    ldy    #$08             ; 2
.noShuttleSound:
    ldx    #$08             ; 2
    lda    #$04             ; 2
    bne    .setAudio1       ; 3

.meteorSound:
    lda    #16              ; 2             increase meteor sound volume
    sec                     ; 2
    sbc    channel1Time     ; 3
    tay                     ; 2
    ldx    numMeteors       ; 3             link frequency to number of remaining meteors
    dec    channel1Time     ; 5
    bpl    .contMeteor      ; 2³
    lda    channel1Sound    ; 3             disable general meteor sound
    and    ~#METEOR_SOUND   ; 2
    sta    channel1Sound    ; 3
.contMeteor:
    lda    #$08             ; 2             enable wavering sound
    bit    waveringFlag     ; 3
    bpl    .notWavering2    ; 2³
    lda    frameCnt         ; 3
    and    #$02             ; 2
    bne    .noSilence       ; 2³
    ldy    #$00             ; 2             disable wavering sound
.noSilence:
    lda    #$0c             ; 2
.notWavering2:
    cpx    #$00             ; 2             any more meteors or...
    bne    .setAudio1       ; 2³             yes, skip
    ldx    numWaverings     ; 3             ...any more wavering meteors?
  IF OPTIMIZE
    FILL_NOP 2
  ELSE
    cpx    #0               ; 2             very weird!
  ENDIF
    bne    .setAudio1       ; 2³             yes, skip
    ldy    channel1Time     ; 3             no, ping at the end of wave
    iny                     ; 2
    ldx    #$02             ; 2
    lda    #$0c             ; 2
.setAudio1:
    sty    AUDV1            ; 3
    stx    AUDF1            ; 3
    sta    AUDC1            ; 3

;*** wait until end of overscan: ***
.waitTim:
    bit    TIMINT           ; 4
    bpl    .waitTim         ; 2³
    jmp    MainLoop         ; 3


TimeStarTrick SUBROUTINE
;*** waits some time and loads HMM0 value ***
    nop                     ; 2
    nop                     ; 2
    lda    #$60             ; 2
    rts                     ; 6


InitGame SUBROUTINE
;*** clears a lot of variables ***
    lda    #$01             ; 2
    sta    status           ; 3
    ldx    #$80             ; 2
    lda    #$00             ; 2
.loopClear:
    sta    $00,x            ; 4
    inx                     ; 2
    cpx    #<frameCnt       ; 2
    bne    .loopClear       ; 2³
    rts                     ; 6


GetPlayer SUBROUTINE
;*** returns the current player ***
    ldx    #0               ; 2             player 0
    bit    gameFlags        ; 3             2-player game?
    bvc    .player0         ; 2³             no, skip
    lda    status           ; 3             planet or space?
    asl                     ; 2
    eor    SWCHB            ; 4
    bpl    .player0         ; 2³
    inx                     ; 2             player 1
.player0:
    rts                     ; 6


InitLevel SUBROUTINE
;*** initialize the current level ***
    lda    levelMeteors     ; 3
    sta    numMeteors       ; 3
InitLevel2:
    lda    #DIR_UP          ; 2             defense system starts with moving up
    sta    defenseStatus    ; 3
    sta    beastie0Status   ; 3             enable first beastie, moves right
    lda    #BEASTIE_LEFT|BEASTIE_FREE; 2
    sta    beastie1Status   ; 3             enable second beastie, moves left
    lda    level            ; 3             set number of wavering meteors
    lsr                     ; 2
    sta    numWaverings     ; 3
.limitId:
    cmp    #NUM_BEASTIES    ; 2             limit beastie id to 0..6
    bcc    .setId           ; 2³
    sbc    #NUM_BEASTIES    ; 2
    bcs    .limitId         ; 3

.setId:
    sta    beastieId        ; 3
    lda    #0               ; 2
    sta    xPosBeastie0     ; 3
    sta    planetTime       ; 3
    sta    defenseDelay     ; 3
    sta    yPosDefense      ; 3
    sta    yPosShuttle      ; 3
    sta    channel1Sound    ; 3
    ldx    numBeasties      ; 3             no breastie already captured?
    stx    oldNumBeasties   ; 3
    beq    .bothBeasties    ; 2³             yes, show both
    sta    beastie1Status   ; 3              no, disable second beastie
.bothBeasties:
    lda    #SCREEN_WIDTH-5  ; 2
    sta    xPosBeastie1     ; 3
    rts                     ; 6


ReleaseBeastie SUBROUTINE
    ldx    #0               ; 2
    bit    beastie0Status   ; 3             beastie 0 captured?
    bvc    .release0        ; 2³             yes, release
    inx                     ; 2             release beastie 1
.release0:
    lda    beastie0Status,x ; 4
    ora    #BEASTIE_FREE    ; 2             reset captured flag
    sta    beastie0Status,x ; 4
    lda    xPosShotBeam     ; 3             release at old beam position
    sta    xPosBeastie0,x   ; 4
    rts                     ; 6


NewMeteor SUBROUTINE
;*** randomly create new meteors ***
    ldy    #NO_METEOR       ; 2
    lda    status           ; 3
    and    #NO_METEORS      ; 2             meteors disabled?
  IF OPTIMIZE
    bne    .skipNew         ; 2³             yes, skip new
    FILL_NOP 3
  ELSE
    beq    .makeNew         ; 2³             no, create new meteor
    jmp    .skipNew         ; 3              yes, skip new
  ENDIF

.makeNew:
    lda    random           ; 3             randomly decide for wavering meteors
    and    #%00001100       ; 2             wavering? (~25% chance)
    bne    .noWavering      ; 2³             no, skip
    lda    numWaverings     ; 3             any more wavering meteors?
    beq    .noWavering      ; 2³             no, skip
.createWavering:
    dec    numWaverings     ; 5
    lda    #2               ; 2
    sta    waveringCnt      ; 3
    lda    #RED+6           ; 2
    sta    P1SpaceCol       ; 3
    lda    waveringFlag     ; 3
    ora    #$80             ; 2             wavering meteor
    bne    .setWavering     ; 3

.noWavering:
    lda    numMeteors       ; 3             any more meteors?
    bne    .createNormal    ; 2³             yes, create normal meteor
    lda    numWaverings     ; 3             any more wavering meteors?
    bne    .createWavering  ; 2³             yes, create wavering meteor
    ldy    #0               ; 2              no, disable meteors
    sty    yPosMeteor       ; 3
    sty    meteorDir        ; 3
  IF OPTIMIZE
    beq    StartArkUp       ; 3
    FILL_NOP 1
  ELSE
    jmp    StartArkUp       ; 3
  ENDIF

.createNormal:
    dec    numMeteors       ; 5
    lda    #BLUE+6          ; 2
    sta    P1SpaceCol       ; 3
    lda    waveringFlag     ; 3
    and    #$7f             ; 2             normal meteor
.setWavering:
    sta    waveringFlag     ; 3
    lda    random           ; 3             random new meteor direction
    and    #$03             ; 2
    tay                     ; 2
    bit    status           ; 3
    bvc    .inSpace         ; 2³
    cpy    #METEOR_DOWN-1   ; 2             meteor from down?
    bne    .inSpace         ; 2³
    dey                     ; 2             change to up
.inSpace:
    lda    YPosMeteorTab,y  ; 4             set meteor position
    sta    yPosMeteor       ; 3
    lda    XPosMeteorTab,y  ; 4
    sta    xPosMeteor       ; 3
    lda    initSpeedHi      ; 3             inititialize meteor speed
    sta    speedHi          ; 3
    lda    initSpeedLo      ; 3
    sta    speedLo          ; 3
    rol    channel1Sound    ; 5             enable meteor sound
    sec                     ; 2
    ror    channel1Sound    ; 5
    lda    #16              ; 2             set meteor sound time
    sta    channel1Time     ; 3
    iny                     ; 2
.skipNew:
    sty    meteorDir        ; 3
    rts                     ; 6


StartArkUp SUBROUTINE
;*** Ark starts moving up ***
    lda    status           ; 3             set status: Ark is moving up
    ora    #ARK_UPDOWN      ; 2
    sta    status           ; 3
    lda    channel0Sound    ; 3             enable Ark sound
    ora    #ARK_SOUND       ; 2
    sta    channel0Sound    ; 3

;gain 10 fuel units for each new captured beastie:
    lda    numBeasties      ; 3             subtract old number of captured
    sec                     ; 2              beasties from current
    sbc    oldNumBeasties   ; 3
    tax                     ; 2
    lda    #0               ; 2
    sta    arkAppearCnt     ; 3
    sta    yPosShuttle      ; 3             disable shuttle
    sta    defenseStatus    ; 3             disable defense
    sta    yPosDefense      ; 3
.loopRefuel:
    dex                     ; 2
    bmi    .refuel          ; 2³
    clc                     ; 2
    adc    #10              ; 2
    bne    .loopRefuel      ; 3

.refuel:
    clc                     ; 2
    adc    fuel             ; 3
    cmp    #MAX_FUEL        ; 2             limit fuel to 48 units
    bcc    .skipMaxFuel     ; 2³
    lda    #MAX_FUEL-1      ; 2
.skipMaxFuel:
    sta    fuel             ; 3
    rts                     ; 6


AddScore SUBROUTINE
;*** adds A/X (lo/hi) to score of player in Y ***
; JTZ: Actually Y is allways zero, but they might originally have
; had planed a non cooperative 2 player game too.
    sed                     ; 2
    clc                     ; 2
    adc    scoreLow,y       ; 4
    sta    scoreLow,y       ; 5
    txa                     ; 2
  IF OPTIMIZE
    FILL_NOP 2
    adc    #$00             ; 2
  ELSE
    bcc    .skipMidC        ; 2³            very weird!
    adc    #$00             ; 2
  ENDIF
.skipMidC:
    clc                     ; 2
    adc    scoreMid,y       ; 4
    sta    scoreMid,y       ; 5
    lda    #$00             ; 2
  IF OPTIMIZE
    FILL_NOP 4
  ELSE
    bcc    .skipHiC         ; 2³            very weird!
    adc    #$00             ; 2
  ENDIF
.skipHiC:
    adc    scoreHi,y        ; 4
    sta    scoreHi,y        ; 5
    cld                     ; 2
    rts                     ; 6


StartArkDown SUBROUTINE
;*** Ark starts moving down ***
    lda    #KERNEL_HEIGHT-1 ; 2             start Ark at top of screen
    sta    yPosArk          ; 3
    lda    #64              ; 2
    sta    xPosBeam         ; 3
    lda    #MAX_SCROLL      ; 2             make surface invisible (scrolls up)
    sta    surfaceScroll    ; 3
    lda    #1               ; 2             start appearance of Ark
    sta    arkAppearCnt     ; 3
    lda    channel0Sound    ; 3             enable Ark sound
    ora    #ARK_SOUND       ; 2
    sta    channel0Sound    ; 3
    rts                     ; 6


SetDigitLowPtr SUBROUTINE
;*** sets low pointers for the 48 pixel routine ***
    sta    tempVar2         ; 3
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    lsr                     ; 2
    jsr    Mult10           ; 6
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    lda    tempVar2         ; 3
    and    #$0f             ; 2
    jsr    Mult10           ; 6
    sta    digitPtr,x       ; 4
    inx                     ; 2
    inx                     ; 2
    rts                     ; 6

Mult10 SUBROUTINE
;*** multiply A with 10 ***
    asl                     ; 2
    sta    tempVar          ; 3
    asl                     ; 2
    asl                     ; 2
    clc                     ; 2
    adc    tempVar          ; 3
    rts                     ; 6


InitGameVars SUBROUTINE
;*** init game speed variables ***
;The most important game speed parameters are adjusted here (and at some other
; places in code), so that NTSC and PAL games have about the same speed

;BTW: Simulating the speed through several levels showed some *significant*
; differences in the necessary reaction times in some lower levels. That's
; because not all values could be perfectly adjusted!

    lda    gameNum          ; 3
    cmp    #ADVANCED_GAME   ; 2             advanced game?

;set initial meteor speed:
; normal  : 624 (PAL: 624*6/5 = 748)
; advanced: 752 (PAL: 752*6/5 =~902)
    lda    #2               ; 2
    sta    initSpeedHi      ; 3
  IF NTSC
    lda    #112             ; 2             normal speed
  ELSE
    lda    #236             ; 2
  ENDIF
    bcc    .normalGame1     ; 2³            skip, if normal game
  IF NTSC
    lda    #240             ; 2             fast NTSC speed (~level 9)
  ELSE
    inc    initSpeedHi      ; 5             fast PAL speed (~level 9)
    lda    #134             ; 2
  ENDIF
.normalGame1:
    sta    initSpeedLo      ; 3

;set initial shuttle speed:
; normal  : 128 (PAL: 128*6/5 =~152)
; advanced: 224 (PAL: 232)
  IF NTSC
    lda    #128             ; 2
  ELSE
    lda    #152             ; 2
  ENDIF
    bcc    .normalGame2     ; 2³            skip, if normal game
  IF NTSC
    lda    #224             ; 2             high speed (~level 13)
  ELSE
    lda    #232             ; 2             high speed (~level 11)
  ENDIF
.normalGame2:
    sta    shutteSpeedLo    ; 3

;set initial defense fireing frequency:
; normal  : 112 (PAL: 112*5/6 =~96)
; advanded:  16 (PAL too!)
  IF NTSC
    lda    #112             ; 2             about every 2 seconds
  ELSE
    lda    #96              ; 2
  ENDIF
    bcc    .normalGame3     ; 2³            skip, if normal game
    lda    #16              ; 2             about every 0.3 seconds (not PAL adjusted)
.normalGame3:
    sta    defenseFreq      ; 3

;set initial time until alert starts:
; normal  : 112 (PAL: 112*5/6 =~93)
; advanced:  64 (PAL:  64*5/6 =~53)
  IF NTSC
    lda    #112             ; 2             ~15 seconds
  ELSE
    lda    #93              ; 2
  ENDIF
    bcc    .normalGame4     ; 2³            skip, if normal game
  IF NTSC
    lda    #64              ; 2             ~8.5 seconds (~level 13)
  ELSE
    lda    #53              ; 2             PAL (~level 11)
  ENDIF
.normalGame4:
    sta    alertTime        ; 3

;set initial meteors / wave:
    lda    #8               ; 2
    bcc    .normalGame5     ; 2³            skip, if normal game
    lda    #20              ; 2
.normalGame5:
    sta    levelMeteors     ; 3

;set shuttle color:
    lda    shuttleColorTab  ; 4
    sta    shuttleColor     ; 3
    rts                     ; 6


NextLevel SUBROUTINE
;*** increase the game speeds ***
    lda    level            ; 3
    and    #$03             ; 2             time to change color and shuttle speed?
    bne    .skipSpeedUp     ; 2³             no, skip

;change shuttle color:
    lda    level            ; 3             every 4th planet
    lsr                     ; 2
    lsr                     ; 2
    and    #$03             ; 2
    tay                     ; 2
    lda    shuttleColorTab,y; 4
    sta    shuttleColor     ; 3

;increase speed of rescue shuttle:
    lda    shutteSpeedLo    ; 3             every 4th planet (= 2nd planet)
    clc                     ; 2
    adc    #8               ; 2             not PAL adjusted (8*50/60 = ~6.7)
    bcs    .skipSpeedUp     ; 2³
    sta    shutteSpeedLo    ; 3
.skipSpeedUp:

;increase defense fireing frequency:
    lda    defenseFreq      ; 3             every planet
    sec                     ; 2
    sbc    #8               ; 2             not PAL adjusted (8*50/60 = ~6.7)
    beq    .skipInc         ; 2³
    sta    defenseFreq      ; 3
.skipInc:

;increase number of meteors for next level:
    lda    levelMeteors     ; 3
    cmp    #30              ; 2             maximum number (30)?
    beq    .skipIncNum      ; 2³             no, skip increase
    inc    levelMeteors     ; 5              yes, one more meteorid
.skipIncNum:

;increase speed of meteors for next level:
    lda    initSpeedLo      ; 3
    clc                     ; 2
  IF NTSC
    adc    #16              ; 2
  ELSE
    adc    #19              ; 2             PAL adjusted value
  ENDIF
    sta    initSpeedLo      ; 3
    bcc    .skipIncHi       ; 2³
    inc    initSpeedHi      ; 5
.skipIncHi:

;decrease time until bombardment alert:
    lda    alertTime        ; 3
  IF NTSC
    cmp    #48              ; 2             0.8 seconds minimum alert time
    beq    .skipDecTime     ; 2³
  ELSE
    cmp    #39              ; 2             PAL adjusted value
    bcc    .skipDecTime     ; 2³
  ENDIF
    sec                     ; 2
    sbc    #4               ; 2             not PAL adjusted (4*50/60 = ~3.3)
    sta    alertTime        ; 3
.skipDecTime:
    rts                     ; 6


;===============================================================================
; R O M - T A B L E S
;===============================================================================

shuttleColorTab:             ; rescue shuttle colors
    .byte GREEN2+6
    .byte BLUE+6
    .byte RED+6
    .byte BROWN+6

WaveringTab:
    .byte   -1, -1, -1, -1
    .byte    1,  1,  1,  1
  IF OPTIMIZE
    FILL_NOP 1
   IF NTSC
    FILL_NOP 5
   ENDIF
  ELSE
    .byte   -1                      ;unused
   IF NTSC
    .byte   -1, -1, -1, -1, -1      ;unused
   ENDIF
  ENDIF

AnimateTab:
    .byte %11111100 ; |XXXXXX  |
    .byte %11111000 ; |XXXXX   |
    .byte %11110100 ; |XXXX X  |
    .byte %11101100 ; |XXX XX  |
    .byte %11011100 ; |XX XXX  |
    .byte %10111100 ; |X XXXX  |
    .byte %01111100 ; | XXXXX  |
    .byte %11111100 ; |XXXXXX  |

Shuttle0:
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %11111111 ; |XXXXXXXX|
    .byte %01110000 ; | XXX    |
    .byte %11111111 ; |XXXXXXXX|
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
Shuttle1:
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %11111111 ; |XXXXXXXX|
    .byte %00001110 ; |    XXX |
    .byte %11111111 ; |XXXXXXXX|
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
Explosion0:
    .byte %00000000 ; |        |
    .byte %00100000 ; |  X     |
    .byte %00000100 ; |     X  |
    .byte %10000001 ; |X      X|
    .byte %00000000 ; |        |
    .byte %00100000 ; |  X     |
    .byte %00001000 ; |    X   |
    .byte %10000001 ; |X      X|
Explosion1:
    .byte %01000010 ; | X    X |
    .byte %00000000 ; |        |
    .byte %00010000 ; |   X    |
    .byte %01001010 ; | X  X X |
    .byte %00010000 ; |   X    |
    .byte %00001000 ; |    X   |
    .byte %01000010 ; | X    X |
    .byte %00100100 ; |  X  X  |
Explosion2:
    .byte %00011000 ; |   XX   |
    .byte %10100101 ; |X X  X X|
    .byte %00000000 ; |        |
    .byte %10100101 ; |X X  X X|
    .byte %00000000 ; |        |
    .byte %10100101 ; |X X  X X|
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |

    align   256

Meteor0:
    .byte %00000000 ; |        |
    .byte %00111100 ; |  XXXX  |
    .byte %01111110 ; | XXXXXX |
    .byte %01101111 ; | XX XXXX|
    .byte %01011111 ; | X XXXXX|
    .byte %00111010 ; |  XXX X |
    .byte %00011110 ; |   XXXX |
    .byte %00001100 ; |    XX  |
Meteor1:
    .byte %00000000 ; |        |
    .byte %00011100 ; |   XXX  |
    .byte %00101110 ; |  X XXX |
    .byte %01110110 ; | XXX XX |
    .byte %11111110 ; |XXXXXXX |
    .byte %11011110 ; |XX XXXX |
    .byte %01111100 ; | XXXXX  |
    .byte %00011000 ; |   XX   |
Meteor2:
    .byte %00110000 ; |  XX    |
    .byte %01111000 ; | XXXX   |
    .byte %01011100 ; | X XXX  |
    .byte %11111010 ; |XXXXX X |
    .byte %11110110 ; |XXXX XX |
    .byte %01111110 ; | XXXXXX |
    .byte %00111100 ; |  XXXX  |
    .byte %00000000 ; |        |
Meteor3:
    .byte %00011000 ; |   XX   |
    .byte %00111110 ; |  XXXXX |
    .byte %01111000 ; | XXXX   |
    .byte %01111111 ; | XXXXXXX|
    .byte %01101110 ; | XX XXX |
    .byte %01110100 ; | XXX X  |
    .byte %00111000 ; |  XXX   |
    .byte %00000000 ; |        |

    .byte %00010001 ; |   X   X| $1e20  unused
    .byte %00100001 ; |  X    X|
    .byte %00100010 ; |  X   X |
    .byte %00110011 ; |  XX  XX|

LumTab:
;luminance of planet surface lines:
    .byte $0c
    .byte $0c
    .byte $0c
    .byte $0c
    .byte $0c
    .byte $0a
    .byte $08
    .byte $06
    .byte $04
    .byte $02

ArkAppearTab:
;row order in which the Ark appears on top of screen:
    .byte  9, 8,10, 7,11, 6,12, 5,13, 4,14, 3,15, 2,16, 1,17, 0,18

YPosMeteorTab:
;y-starting position of a meteor:
    .byte  91, 91,192,  0
XPosMeteorTab:
;x-starting position of a meteor:
    .byte   0,152, 76, 76

PlanetColTab:
;colors of the planet surfaces:
    .byte GREEN-8
    .byte BROWN-8
    .byte MAGENTA-8
    .byte BLUE-8
    .byte OCHRE-8
    .byte CYAN-8
    .byte GREEN
    .byte ORANGE_GREEN-4
    .byte OCHRE-8
    .byte RED_BROWN
    .byte BLUE
    .byte MAGENTA2-4
    .byte ORANGE-8
    .byte MAGENTA-8
    .byte BLUE2-8
    .byte BLACK

xPosStarsTab:
    .byte  13, 28, 43, 58, 73, 88,103,118,133
    .byte 148,133,118,103, 88, 73, 58, 43, 28

NuSiz0Tab:
    .byte MS_SIZE1|ONE_COPY
    .byte MS_SIZE1|TWO_COPIES_WIDE
    .byte MS_SIZE1|THREE_COPIES
    .byte MS_SIZE2|TWO_COPIES_WIDE
    .byte MS_SIZE2|THREE_COPIES
    .byte MS_SIZE4|THREE_COPIES
    .byte MS_SIZE8|TWO_COPIES_WIDE
    .byte MS_SIZE8|THREE_COPIES

;two patterns for each beastie:
Beastie0:
    .byte %00000000 ; |        |
    .byte %00111000 ; |  XXX   |
    .byte %00101000 ; |  X X   |
    .byte %00101000 ; |  X X   |
    .byte %00111000 ; |  XXX   |
    .byte %00001000 ; |    X   |
    .byte %00111000 ; |  XXX   |
    .byte %00100000 ; |  X     |
    .byte %00111000 ; |  XXX   |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00111000 ; |  XXX   |
    .byte %00101000 ; |  X X   |
    .byte %00111000 ; |  XXX   |
    .byte %00101000 ; |  X X   |
    .byte %00111000 ; |  XXX   |
    .byte %00111000 ; |  XXX   |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00111000 ; |  XXX   |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00111000 ; |  XXX   |
    .byte %00101000 ; |  X X   |
    .byte %00001000 ; |    X   |
    .byte %00001000 ; |    X   |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00111000 ; |  XXX   |
    .byte %00010000 ; |   X    |
    .byte %00111000 ; |  XXX   |
    .byte %00101000 ; |  X X   |
    .byte %00100000 ; |  X     |
    .byte %00100000 ; |  X     |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00001000 ; |    X   |
    .byte %01001100 ; | X  XX  |
    .byte %00111000 ; |  XXX   |
    .byte %01000100 ; | X   X  |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00001000 ; |    X   |
    .byte %00001100 ; |    XX  |
    .byte %01111000 ; | XXXX   |
    .byte %00101000 ; |  X X   |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00001000 ; |    X   |
    .byte %00010100 ; |   X X  |
    .byte %00011000 ; |   XX   |
    .byte %00011100 ; |   XXX  |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00100000 ; |  X     |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00001000 ; |    X   |
    .byte %00010100 ; |   X X  |
    .byte %00011000 ; |   XX   |
    .byte %00011100 ; |   XXX  |
    .byte %00010000 ; |   X    |
    .byte %00001000 ; |    X   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |

    .byte %00100100 ; |  X  X  |
    .byte %00100100 ; |  X  X  |
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00100100 ; |  X  X  |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00111100 ; |  XXXX  |
    .byte %00011000 ; |   XX   |
    .byte %00111100 ; |  XXXX  |
    .byte %00111100 ; |  XXXX  |
    .byte %00001100 ; |    XX  |
    .byte %00000100 ; |     X  |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00111100 ; |  XXXX  |
    .byte %00100100 ; |  X  X  |
    .byte %00111100 ; |  XXXX  |
    .byte %00111100 ; |  XXXX  |
    .byte %00110000 ; |  XX    |
    .byte %00100000 ; |  X     |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00110000 ; |  XX    |
    .byte %00100000 ; |  X     |
    .byte %00110000 ; |  XX    |
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |

    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00111100 ; |  XXXX  |
    .byte %00100000 ; |  X     |
    .byte %00111100 ; |  XXXX  |
    .byte %00011000 ; |   XX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |


     align 256, 0

Zero:
    .byte %00000000 ; |        |
    .byte %00111110 ; |  XXXXX |
    .byte %00100110 ; |  X  XX |
    .byte %00100110 ; |  X  XX |
    .byte %00100110 ; |  X  XX |
    .byte %00100110 ; |  X  XX |
    .byte %00100110 ; |  X  XX |
    .byte %00100010 ; |  X   X |
    .byte %00100010 ; |  X   X |
    .byte %00111110 ; |  XXXXX |
One:
    .byte %00000000 ; |        |
    .byte %00011000 ; |   XX   |
    .byte %00011000 ; |   XX   |
    .byte %00011000 ; |   XX   |
    .byte %00011000 ; |   XX   |
    .byte %00011000 ; |   XX   |
    .byte %00001000 ; |    X   |
    .byte %00001000 ; |    X   |
    .byte %00001000 ; |    X   |
    .byte %00001000 ; |    X   |
Two:
    .byte %00000000 ; |        |
    .byte %01111110 ; | XXXXXX |
    .byte %01100000 ; | XX     |
    .byte %01100000 ; | XX     |
    .byte %01100000 ; | XX     |
    .byte %01111110 ; | XXXXXX |
    .byte %00000010 ; |      X |
    .byte %00000010 ; |      X |
    .byte %01000010 ; | X    X |
    .byte %01111110 ; | XXXXXX |
Three:
    .byte %00000000 ; |        |
    .byte %01111110 ; | XXXXXX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00111100 ; |  XXXX  |
    .byte %00000100 ; |     X  |
    .byte %01000100 ; | X   X  |
    .byte %01111100 ; | XXXXX  |
Four:
    .byte %00000000 ; |        |
    .byte %00001100 ; |    XX  |
    .byte %00001100 ; |    XX  |
    .byte %00001100 ; |    XX  |
    .byte %01111110 ; | XXXXXX |
    .byte %01000100 ; | X   X  |
    .byte %01000100 ; | X   X  |
    .byte %01000100 ; | X   X  |
    .byte %01000100 ; | X   X  |
    .byte %01000100 ; | X   X  |
Five:
    .byte %00000000 ; |        |
    .byte %01111110 ; | XXXXXX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %01111110 ; | XXXXXX |
    .byte %01000000 ; | X      |
    .byte %01000000 ; | X      |
    .byte %01111110 ; | XXXXXX |
Six:
    .byte %00000000 ; |        |
    .byte %01111110 ; | XXXXXX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %01111110 ; | XXXXXX |
    .byte %01000000 ; | X      |
    .byte %01000000 ; | X      |
    .byte %01000010 ; | X    X |
    .byte %01111110 ; | XXXXXX |
Seven:
    .byte %00000000 ; |        |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000010 ; |      X |
    .byte %00111110 ; |  XXXXX |
Eight:
    .byte %00000000 ; |        |
    .byte %01111110 ; | XXXXXX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %01000110 ; | X   XX |
    .byte %01100110 ; | XX  XX |
    .byte %00111100 ; |  XXXX  |
    .byte %00100100 ; |  X  X  |
    .byte %00100100 ; |  X  X  |
    .byte %00111100 ; |  XXXX  |
Nine:
    .byte %00000000 ; |        |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00000110 ; |     XX |
    .byte %00111110 ; |  XXXXX |
    .byte %00100010 ; |  X   X |
    .byte %00100010 ; |  X   X |
    .byte %00100010 ; |  X   X |
    .byte %00111110 ; |  XXXXX |
Blank:
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |

Copyright0:
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %10001011 ; |X   X XX|
    .byte %10001010 ; |X   X X |
    .byte %10001010 ; |X   X X |
    .byte %10111011 ; |X XXX XX|
    .byte %10101010 ; |X X X X |
    .byte %10111011 ; |X XXX XX|
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
Copyright1:
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %10111000 ; |X XXX   |
    .byte %10100001 ; |X X    X|
    .byte %10100001 ; |X X    X|
    .byte %10111001 ; |X XXX  X|
    .byte %10001001 ; |X   X  X|
    .byte %10111000 ; |X XXX   |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
Copyright2:
    .byte %01110000 ; | XXX    |
    .byte %10001000 ; |X   X   |
    .byte %10001000 ; |X   X   |
    .byte %00100100 ; |  X  X  |
    .byte %01000100 ; | X   X  |
    .byte %01000100 ; | X   X  |
    .byte %00100100 ; |  X  X  |
    .byte %10001000 ; |X   X   |
    .byte %10001000 ; |X   X   |
    .byte %01110000 ; | XXX    |
Copyright3:
    .byte %00000000 ; |        |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10101010 ; |X X X X |
    .byte %10010100 ; |X  X X  |
    .byte %00000000 ; |        |
Copyright4:
    .byte %00000000 ; |        |
    .byte %10010011 ; |X  X  XX|
    .byte %10010100 ; |X  X X  |
    .byte %10010100 ; |X  X X  |
    .byte %11110101 ; |XXXX X X|
    .byte %10010100 ; |X  X X  |
    .byte %10010100 ; |X  X X  |
    .byte %10010100 ; |X  X X  |
    .byte %01100011 ; | XX   XX|
    .byte %00000000 ; |        |
Copyright5:
    .byte %00000000 ; |        |
    .byte %00100110 ; |  X  XX |
    .byte %10101001 ; |X X X  X|
    .byte %10101000 ; |X X X   |
    .byte %10101000 ; |X X X   |
    .byte %00101000 ; |  X X   |
    .byte %00101000 ; |  X X   |
    .byte %10101001 ; |X X X  X|
    .byte %00100110 ; |  X  XX |
    .byte %00000000 ; |        |

FuelBarTab:
    .byte %00000000 ; |        |
    .byte %10000000 ; |X       |
    .byte %11000000 ; |XX      |
    .byte %11100000 ; |XXX     |
    .byte %11110000 ; |XXXX    |
    .byte %11111000 ; |XXXXX   |
    .byte %11111100 ; |XXXXXX  |
    .byte %11111110 ; |XXXXXXX |
    .byte %11111111 ; |XXXXXXXX|

ArkPatTab:
    .byte %10000000 ; |X       |
    .byte %11000000 ; |XX      |
    .byte %11100000 ; |XXX     |
    .byte %11110000 ; |XXXX    |
    .byte %11111000 ; |XXXXX   |
    .byte %11111100 ; |XXXXXX  |
    .byte %11111110 ; |XXXXXXX |
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111110 ; |XXXXXXX |
    .byte %11111100 ; |XXXXXX  |
    .byte %11111110 ; |XXXXXXX |
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111110 ; |XXXXXXX |
    .byte %11111100 ; |XXXXXX  |
    .byte %11111000 ; |XXXXX   |
    .byte %11110000 ; |XXXX    |
    .byte %11100000 ; |XXX     |
    .byte %11000000 ; |XX      |
    .byte %10000000 ; |X       |

ArkColTab:
    .byte RED+6
    .byte RED+4
    .byte RED+2
    .byte RED
    .byte RED_BROWN+2
    .byte RED_BROWN
    .byte RED_BROWN-2
    .byte RED+6
    .byte RED_BROWN-2
    .byte WHITE
    .byte RED_BROWN-2
    .byte RED+6
    .byte RED_BROWN-2
    .byte RED_BROWN
    .byte RED_BROWN+2
    .byte RED
    .byte RED+2
    .byte RED+4
    .byte RED+6

;pattern for the palnet surface:
PlanetPF0Tab:
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00010000 ; |   X    |
    .byte %00110000 ; |  XX    |
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|
PlanetPF1Tab:
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00110000 ; |  XX    |
    .byte %01111001 ; | XXXX  X|
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|
PlanetPF2Tab:
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %00000000 ; |        |
    .byte %10000000 ; |X       |
    .byte %11000000 ; |XX      |
    .byte %11110011 ; |XXXX  XX|
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|
    .byte %11111111 ; |XXXXXXXX|

SpeedDecTab:
;meteor slowdown values, one for each direction:
   IF OPTIMIZE
     FILL_NOP 1
   ELSE
    .byte    0                      ; unsued
   ENDIF
  IF NTSC
    .byte   24, 24,  8,  8
  ELSE
    .byte   32, 32, 14, 14          ; PAL adjusted speed difference
  ENDIF

    ORG $1ffc
    .word   START, START
