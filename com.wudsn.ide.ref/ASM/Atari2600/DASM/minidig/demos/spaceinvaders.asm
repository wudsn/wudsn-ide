    processor 6502
    include vcs.h


;===============================================================================
; A S S E M B L E R - S W I T C H E S
;===============================================================================

NTSC            = 1
KOOL_AID_OK     = 1     ; disable if console has problems with Kool Aid Man
STATIC          = 1     ; currently doesn't work!


;===============================================================================
; C O N S T A N T S
;===============================================================================

INVADER_H       = 9
MISSILE_H       = 6

ROW_H           = INVADER_H+6

NUM_POSITIONS   = 11
NUM_ROWS        = 5

RAND_EOR_8      = $b2

DX              = 0


  IF NTSC
RED             = $40
BLUE            = $80
  ELSE
RED             = $60
BLUE            = $b0
  ENDIF

op_nop_imm      = $80
op_nop_zp       = $04
op_nop_abs      = $0c
op_nop          = $ea

op_bit          = $24
op_sta          = $85
op_lda_zpx      = $b5
op_sta_zpx      = $95

DUMMY           = $2d


;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

    SEG.U   variables
    ORG     $80

RAMKernel   ds $30  ; KernelCodeEnd - KernelCode (48 bytes reserved for RAM kernel)

ctrlSC      = $80

frameCnt    .byte
random      .byte
reload      .byte
tmpVar      .byte
jmpVec      .word
position    .byte
walkDir     .byte
row         .byte
tmpColumn   .byte

yMsl0       .byte
yTmpMsl     .byte

invPat0     .ds NUM_ROWS
invPat1     .ds NUM_ROWS



;===============================================================================
; M A C R O S
;===============================================================================

  MAC BIT_B
    .byte   $24
  ENDM

  MAC BIT_W
    .byte   $2c
  ENDM

  MAC SLEEP
    IF {1} = 1
      ECHO "ERROR: SLEEP 1 not allowed !"
      END
    ENDIF
    IF {1} & 1
      nop $00
      REPEAT ({1}-3)/2
        nop
      REPEND
    ELSE
      REPEAT ({1})/2
        nop
      REPEND
    ENDIF
  ENDM


;===============================================================================
; M A C R O S
;===============================================================================

  MAC DEBUG_BRK
    IF DEBUG
      brk                         ;
    ENDIF
  ENDM

  MAC BIT_B
    .byte   $24
  ENDM

  MAC BIT_W
    .byte   $2c     ; 4 cylces
  ENDM


;===============================================================================
; R O M - C O D E
;===============================================================================

    SEG     Bank0
    ORG     $f000

;---------------------------------------------------------------
KernelCode SUBROUTINE       ;               patched into
.loop:                      ;       @61..71
PatchInv:
    lda     InvaderTbl-1,y  ; 4
PatchHM:
    sta     HMOVE           ; 3     @68..   bit DUMMY           early HMOVEs!
Patch0:
    sta     RESP0           ; 3     @71..   bit DUMMY           1st invader A
Patch1:
    sta     RESP1           ; 3     @74..   bit DUMMY           2nd invader A
PatchGRP0:
    sta     GRP0            ; 3             lda GRP0
PatchGRP1:
    sta     GRP1            ; 3             lda GRP1
PatchMsl:
    lda     ENABLTbl-1,y    ; 4
    sta     ENABL           ; 3
    txa                     ; 2
PatchRESP0:
Patch3:
    sta     RESP0           ; 3     @16..   bit DUMMY           1st invader B
PatchRESP1:
Patch4:
    sta     RESP1 -DX,x     ; 4     @20..   lda DUMMY -DX,x     2nd invader B
    sta     RESP0 -DX,x     ; 4     @24..   lda RESP0 -DX,x
    sta     RESP1 -DX,x     ; 4             lda RESP1 -DX,x
    sta     RESP0 -DX,x     ; 4             lda RESP0 -DX,x
    sta     RESP1 -DX,x     ; 4             lda RESP1 -DX,x
    sta     RESP0 -DX,x     ; 4             lda RESP0 -DX,x
    sta     RESP1 -DX,x     ; 4             lda RESP1 -DX,x
    sta     RESP0 -DX,x     ; 4             lda RESP0 -DX,x
    sta     RESP1 -DX,x     ; 4             lda RESP1 -DX,x
    sta     RESP0 -DX,x     ; 4     @56..   lda RESP0 -DX,x
    dey                     ; 2
    bne     .loop           ; 2³
    jmp     ContKernel
KernelCodeEnd:

PD = KernelCode - RAMKernel


Start SUBROUTINE
    sei                         ;           Disable interrupts, if there are any.
    cld                         ;           Clear BCD math bit.
    ldx     #0
    txs
    pha                         ;           Set stack to beginning.
    txa
.clearLoop:
    pha
    dex
    bne     .clearLoop

    jsr     GameInit

.mainLoop:
    jsr     VerticalBlank
    jsr     GameCalc
    jsr     DrawScreen
    jsr     OverScan
    jmp     .mainLoop


GameInit SUBROUTINE
    inc     random

    ldx     #$2f
.loopCopy:
    lda     KernelCode,x
    sta     RAMKernel,x
    dex
    bpl     .loopCopy
    lda     #>Delays
    sta     jmpVec+1

    lda     #1
    sta     CTRLPF

    lda     #%111111
    sta     invPat0
    lda     #%11111
    sta     invPat1

    sta     WSYNC
    SLEEP   45
    sta     RESBL
    lda     #$80
    sta     HMBL
    rts


VerticalBlank SUBROUTINE
    lda     #2
    sta     WSYNC
    sta     VSYNC
    sta     WSYNC
    sta     WSYNC
    lsr
  IF NTSC
    ldx     #44-12
  ELSE
    ldx     #44+18
  ENDIF
    sta     WSYNC
    sta     VSYNC
    stx     TIM64T
    rts


GameCalc SUBROUTINE
    inc     frameCnt

    lda     frameCnt
    and     #$1f
    bne     .skipMove
    ldx     position
    bit     walkDir
    bmi     .negDir

    inx
    cpx     #NUM_POSITIONS
    bne     .setPos
    dex
    dex
    bne     .invDir

.negDir:
    dex
    bpl     .setPos
    inx
    inx
.invDir:
    lda     walkDir
    eor     #$80
    sta     walkDir
.setPos
    stx     position

.skipMove:
    lda     #BLUE|$6
    sta     COLUPF
    ldy     #$0c
    ldx     #$0c
    lda     #0
    bit     SWCHB
    bmi     .skipDemo
    lda     #$02
    sta     COLUPF
    ldy     #RED|$a
    ldx     #BLUE|$a
    lda     #$55
.skipDemo:
    sty     COLUP0
    stx     COLUP1
    sta     PF0
    sta     PF2
    asl
    sta     PF1

    rts

    align   256

DrawScreen SUBROUTINE
.idxPat     = Patch0+1 - PD

  IF NTSC
    ldx     #227+22
  ELSE
    ldx     #227+27
  ENDIF
.waitTim:
    lda     INTIM
    bne     .waitTim
    sta     WSYNC
    sta     VBLANK
    stx     TIM64T

;  IF NTSC
;    ldx     #10
;  ELSE
;    ldx     #20
;  ENDIF
;.wait:
;    sta     WSYNC
;    dex
;    bne     .wait

;---------------------------------------------------------------
;    lda     #%01            ; 2
;    sta     NUSIZ0          ; 3
;    sta     NUSIZ1          ; 3

    lda     yMsl0
    sta     yTmpMsl

  IF STATIC
    ldx     #0
;    ldx     #10
  ELSE
    ldx     #NUM_ROWS-1
  ENDIF
.loopColumns:
    stx     row

;***** patch kernel positioning: *****
  IF STATIC
    ldy     row
  ELSE
    ldy     position
  ENDIF
    lda     HMP0Tbl,y               ; 4
    sta     HMP0                    ; 3
    lda     HMP1Tbl,y               ; 4
    sta     HMP1                    ; 3

    lda     yTmpMsl
    sec
    sbc     #ROW_H
    sta     yTmpMsl
    sec
    sbc     #INVADER_H+MISSILE_H
    bcs     .noMissile
    adc     #<ENABLTbl+INVADER_H+MISSILE_H+2
    BIT_W
.noMissile:
    lda     #<ENABLTbl+INVADER_H+MISSILE_H
    sta     PatchMsl+1 - PD

; ***** patch kernel for GRP0: *****
    ldy     #op_bit
    lda     invPat0
    beq     .hide0
    ldy     #op_sta
.hide0:
    sta     WSYNC
    sty     PatchGRP0 - PD

;---------------------------------------
    beq     .empty0

    ldy     #1
    ldx     #5
    lsr
.loopSingle0:
    bcc     .emptyBit0
    dey
    bmi     .notSingle0
    stx     .idxPat
.emptyBit0:
    lsr
    dex
    bpl     .loopSingle0

    sta     HMBL
    sta     NUSIZ0          ; 3
    lda     row
    asl
    adc     row
    ldy     .idxPat         ; 3
    adc     Mult24Tbl,y     ; 4
    sta     WSYNC
---------------------------------------
    sec                     ; 2
.wait0:
    sbc     #15             ; 2
    bcs     .wait0          ; 2³
    eor     #$07            ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    sta     HMP0            ; 3
    sta.w   RESP0           ; 4     @23!
;---------------------------------------
    sta     WSYNC
    sta     HMOVE

    ldy     #op_bit
    sty     Patch0 - PD
    sty     PatchRESP0    - PD
    ldy     #op_lda_zpx
    sty     PatchRESP0+4  - PD
    sty     PatchRESP0+8  - PD
    sty     PatchRESP0+12 - PD
    sty     PatchRESP0+16 - PD
    sty     PatchRESP0+20 - PD
    lda     #$80
    sta     HMP0
    bne     .endSingle0
;=======================================

.empty0:
    sta     WSYNC
;---------------------------------------
.notSingle0:
    lda     invPat0
    ldx     #5*4+1
.loopPat0:
    lsr
    dex
    bne     .notFirst0
    sta     WSYNC
    ldy     #op_bit
    bcc     .patch0_1st
    ldy     #op_sta
.patch0_1st:
    sty     Patch0 - PD
    bne     .patch0

.notFirst0:
    ldy     #op_lda_zpx
    bcc     .patch0
    ldy     #op_sta_zpx
.patch0:
    sty     PatchRESP0 - PD,x
    dex
    dex
    dex
    bpl     .loopPat0

    lda     #$80|%01            ; 2
    sta     NUSIZ0
    sta     HMBL

.endSingle0:
;---------------------------------------

; ***** patch kernel for GRP1: *****
    ldy     #op_bit
    lda     invPat1
    beq     .hide1
    ldy     #op_sta
.hide1:
    sty     PatchGRP1 - PD
    sta     WSYNC
;---------------------------------------
    beq     .empty1

    ldy     #1
    ldx     #4
    lsr
.loopSingle1:
    bcc     .emptyBit1
    dey
    bmi     .notSingle1
    stx     .idxPat
.emptyBit1:
    lsr
    dex
    bpl     .loopSingle1

    sta     HMBL
    sta     NUSIZ1          ; 3
    lda     row
    asl
    adc     row
    ldy     .idxPat         ; 3
    adc     Mult24Tbl,y     ; 4
    adc     #12
    sta     WSYNC
;---------------------------------------
    sec                     ; 2
.wait1:
    sbc     #15             ; 2
    bcs     .wait1          ; 2³
    eor     #$07            ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    asl                     ; 2
    sta     HMP1            ; 3
    sta.w   RESP1           ; 4     @23!
;---------------------------------------
    sta     WSYNC
    sta     HMOVE

    ldy     #op_bit
    sty     Patch1 - PD
    ldy     #op_lda_zpx
    sty     PatchRESP1    - PD
    sty     PatchRESP1+4  - PD
    sty     PatchRESP1+8  - PD
    sty     PatchRESP1+12 - PD
    sty     PatchRESP1+16 - PD
    lda     #$80
    sta     HMP1
    bne     .endSingle1
;=======================================

.empty1:
    sta     WSYNC
;---------------------------------------
.notSingle1:
    lda     invPat1
    ldx     #4*4+1
.loopPat1:
    lsr
    dex
    bne     .notFirst1
    ldy     #op_bit
    bcc     .patch1_1st
    ldy     #op_sta
.patch1_1st:
    sty     Patch1 - PD

.notFirst1:
    ldy     #op_lda_zpx
    bcc     .patch1
    ldy     #op_sta_zpx
.patch1:
    sty     PatchRESP1 - PD,x
    dex
    dex
    dex
    bpl     .loopPat1

    lda     #%01            ; 2
    sta     NUSIZ1
    sta     WSYNC
.endSingle1:
    lda     #$80                ; 2
    sta     HMBL


  IF STATIC
    ldy     row
  ELSE
    ldy     position
  ENDIF

;***** animate invaders: *****
    lda     position                ; 3
    lsr                             ; 2
    lda     InvaderPtrLo,y          ; 4
    bcc     .pat0                   ; 2³
    lda     InvaderPtrLo+NUM_ROWS,y ; 4
.pat0:
    sta     PatchInv+1 - PD         ; 4 = 13/16

    sta     WSYNC
;---------------------------------------
;***** patch kernel for positions: *****
    SLEEP   2                       ; 2
    lda     PatchHMTbl,y            ; 4
    sta     <[PatchHM+1 - PD]       ; 3
    lda     Patch0Tbl,y             ; 4
    sta     <[Patch0+1 - PD]        ; 3
    lda     Patch1Tbl,y             ; 4
    sta     <[Patch1+1 - PD]        ; 3
    lda     Patch3Tbl,y             ; 4
    sta     <[Patch3+1 - PD]        ; 3
    lda     Patch4Tbl,y             ; 4
    sta     <[Patch4+1 - PD]        ; 3 = 37

;***** delay kernel start: *****
  IF STATIC
    lda     #<Delays-1              ; 2
    sec                             ; 2
    sbc     row
;    lda     #<Delays-11             ; 2
;    clc
;    adc     row
  ELSE
    lda     #<Delays-1              ; 2
    sec                             ; 2
    sbc     position                ; 3
  ENDIF
    sta     jmpVec                  ; 3
    jmp     (jmpVec)                ; 5+2 = 17

    .byte   op_nop_imm, op_nop_imm, op_nop_imm, op_nop_imm
    .byte   op_nop_imm, op_nop_imm, op_nop_imm, op_nop_imm
    .byte   op_nop_abs, op_nop_zp,  op_nop
Delays:
    ldx     #DX                     ; 2
    ldy     #INVADER_H              ; 2
    jmp     RAMKernel               ; 3 =  7    @61..71

ContKernel:
    sty     GRP0
    sty     GRP1
    sty     ENABL

    ldx     row
  IF STATIC
    inx
    cpx     #NUM_POSITIONS
    beq     .exitKernel
  ELSE
    dex
    bmi     .exitKernel
  ENDIF
    jmp     .loopColumns

.exitKernel:
    ldx     #2
.waitScreen:
    lda     INTIM
    bne     .waitScreen
    sta     WSYNC
    stx     VBLANK
    rts


OverScan SUBROUTINE
  IF NTSC
    lda     #36-10
  ELSE
    lda     #36+15
  ENDIF
    sta     TIM64T

    ldx     yMsl0
    bne     .skipResetMsl
    ldx     #200
.skipResetMsl:
    dex
    stx     yMsl0

    lda     frameCnt
    and     #$1f
    bne     .skipSwitch
    lda     frameCnt
    and     #$20
    beq     .loopSwitch1
.loopSwitch0:
    jsr     NextRandom
    and     #$07
    cmp     #$06
    bcs     .loopSwitch0
    tay
    lda     Mask2Tbl,y
    eor     invPat0
    sta     invPat0
    bcc     .skipSwitch

.loopSwitch1:
    jsr     NextRandom
    and     #$07
    cmp     #$05
    bcs     .loopSwitch1
    tay
    lda     Mask2Tbl,y
    eor     invPat1
    sta     invPat1
.skipSwitch:

;    lda     reload
;    eor     $fff9
;    and     #$01
;    clc
;    beq     .noBit
;    eor     reload
;    adc     #$10
;.noBit:
;    sta     reload
;    cmp     #$60
;    bcs     .reload
;.skipCheck:

    lda     SWCHB
    lsr
    bcs     .skipReset
    brk
;;---------------------------------------
;ram     = $f000
;control = $fff8
;.reload:
;    lda     #$0b
;    sta     ctrlSC
;
;    cmp     ram
;    cmp     control     ; rom/r3
;    lda     #0
;    sta     $fa         ; next load
;    ldx     #100
;.0
;    ldy     #8
;.1
;    dey
;    bne     .1
;    dex
;    bne     .0
;    jmp     $f800       ; rom entry
;;---------------------------------------

.skipReset:
.waitTim:
    lda     INTIM
    bne     .waitTim
    rts


;***************************************************************
NextRandom SUBROUTINE
;***************************************************************
    lda     random              ; 3
    lsr                         ; 2
    bcc     .skipEor            ; 2³
    eor     #RAND_EOR_8         ; 2
.skipEor:                       ;
    sta     random              ; 3
    rts
; NextRandom


;===============================================================================
; R O M - T A B L E S (Bank 0)
;===============================================================================
    org     $f700, 0

    .byte   0

InvaderTbl:
Invader0Pat0:
    .byte   %01000010
    .byte   %10011001
    .byte   %01100110
    .byte   %11111111
    .byte   %11011011
    .byte   %11111111
    .byte   %01111110
    .byte   %00011000
    .byte   0
Invader0Pat1:
    .byte   %10000001
    .byte   %01011010
    .byte   %01100110
    .byte   %11111111
    .byte   %11011011
    .byte   %11111111
    .byte   %01111110
    .byte   %00011000
    .byte   0

Invader1Pat0:
    .byte   %00011000
    .byte   %10100101
    .byte   %10111101
    .byte   %11111111
    .byte   %01011010
    .byte   %00111100
    .byte   %00100100
    .byte   %01000010
    .byte   0
Invader1Pat1:
    .byte   %01000010
    .byte   %00100100
    .byte   %00111100
    .byte   %01111110
    .byte   %11011011
    .byte   %10111101
    .byte   %10100101
    .byte   %01000010
    .byte   0

Invader2Pat0:
    .byte   %00100100
    .byte   %01000010
    .byte   %00100100
    .byte   %01111110
    .byte   %01011010
    .byte   %01111110
    .byte   %00111100
    .byte   %00011000
    .byte   0
Invader2Pat1:
    .byte   %01000010
    .byte   %00100100
    .byte   %00011000
    .byte   %01111110
    .byte   %01011010
    .byte   %01111110
    .byte   %00111100
    .byte   %00011000
    .byte   0

InvaderPtrLo:
    .byte   <Invader0Pat0-1, <Invader0Pat0-1, <Invader1Pat0-1, <Invader1Pat0-1, <Invader2Pat0-1
    .byte   <Invader0Pat1-1, <Invader0Pat1-1, <Invader1Pat1-1, <Invader1Pat1-1, <Invader2Pat1-1
  IF STATIC
    .byte   <Invader0Pat0-1, <Invader0Pat0-1, <Invader1Pat0-1, <Invader1Pat0-1, <Invader2Pat0-1
    .byte   <Invader0Pat1-1
  ENDIF


ENABLTbl:
    .ds INVADER_H, 0
    .ds MISSILE_H, 2
    .ds INVADER_H, 0

HMP0Tbl:
  IF KOOL_AID_OK
    .byte   $10, $00, $00, $f0, $e0
  ELSE
    .byte   $50, $30, $20, $00, $f0
  ENDIF
    .byte   $b0, $80, $80, $80, $80, $80
HMP1Tbl:
  IF KOOL_AID_OK
    .byte   $e0, $d0
  ELSE
    .byte   $f0, $e0
  ENDIF
    .byte   $80, $80, $80, $80, $80, $80, $80, $80, $80

PatchHMTbl:
    .byte   HMOVE, HMOVE, HMOVE, HMOVE, HMOVE, HMOVE
    .byte   DUMMY, DUMMY, DUMMY, DUMMY, DUMMY
Patch0Tbl:
    .byte   RESP0, RESP0, RESP0, RESP0, RESP0, RESP0
    .byte   DUMMY, DUMMY, DUMMY, DUMMY, DUMMY
Patch1Tbl:
    .byte   RESP1, RESP1
    .byte   DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY
Patch3Tbl:
    .byte   DUMMY, DUMMY, DUMMY, DUMMY, DUMMY, DUMMY
    .byte   RESP0, RESP0, RESP0, RESP0, RESP0
Patch4Tbl:
    .byte   DUMMY-DX, DUMMY-DX
    .byte   RESP1-DX, RESP1-DX, RESP1-DX, RESP1-DX, RESP1-DX, RESP1-DX
    .byte   RESP1-DX, RESP1-DX, RESP1-DX

Mask2Tbl:
    .byte   $01, $02, $04, $08, $10, $20

Mult24Tbl:
    .byte   24*0+1, 24*1+1, 24*2+1, 24*3+1, 24*4+1, 24*5+1

    .byte   "SI-11 v0.03 - (C)2003 Thomas Jentzsch"

    org $f7fc
    .word   Start
    .word   Start
