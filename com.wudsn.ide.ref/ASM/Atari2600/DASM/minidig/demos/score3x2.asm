    processor 6502
    include vcs.h

;===============================================================================
; Z P - V A R I A B L E S
;===============================================================================

    SEG.U   variables
    ORG     $80

tmpVar      .byte
frameCnt    .byte

score       = .
scoreL      .byte
scoreM      .byte
scoreR      .byte

ptrScore    ds 12


;===============================================================================
; M A C R O S
;===============================================================================

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
; R O M - C O D E
;===============================================================================
    SEG     Bank0
    ORG     $f000

Start SUBROUTINE
    cld
    ldx     #0
    txs
    pha
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
    lda     #$00
    sta     COLUP0
    sta     COLUP1
    lda     #$06
    sta     COLUPF

    lda     #%110
    sta     NUSIZ0
    sta     NUSIZ1
    lda     #%1
    sta     VDELP0
    sta     CTRLPF

    sta     WSYNC
    SLEEP   31
    sta     RESP0
    sta     RESP1
    lda     #$f0
    sta     HMP0
    lda     #$00
    sta     HMP1
    sta     WSYNC
    sta     HMOVE
    rts


VerticalBlank SUBROUTINE
    lda     #2
    sta     WSYNC
    sta     VSYNC
    sta     WSYNC
    sta     WSYNC
    inc     frameCnt
    lsr
    ldx     #44
    sta     WSYNC
    sta     VSYNC
    stx     TIM64T
    rts


GameCalc SUBROUTINE
.tmpY   = tmpVar

; increase scores:
    sed
    lda     frameCnt
    and     #$1f
    bne     .skipL
    lda     scoreL
    clc
    adc     #1
    sta     scoreL
.skipL:

    lda     frameCnt
    and     #$0f
    bne     .skipM
    lda     scoreM
    clc
    adc     #1
    sta     scoreM
.skipM:

    lda     frameCnt
    and     #$07
    bne     .skipR
    lda     scoreR
    clc
    adc     #1
    sta     scoreR
.skipR:
    cld

; setup score pointer:
    ldx     #6-1
    ldy     #3-1
.loopScore:
    lda     #>Zero              ; 2
    sta     ptrScore,x          ; 4
    sta     ptrScore+6,x        ; 4
    dex                         ; 2
    sty     .tmpY               ; 3
    lda     score,y             ; 4
    pha                         ; 3
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    lsr                         ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     ptrScore,x          ; 4
    pla                         ; 4
    and     #$0f                ; 2
    tay                         ; 2
    lda     DigitTbl,y          ; 4
    sta     ptrScore+6,x        ; 4
    ldy     .tmpY               ; 3
    dey                         ; 2
    dex                         ; 2
    bpl     .loopScore          ; 2³

    rts

    align 256

DrawScreen SUBROUTINE
    ldx     #227
.waitTim:
    lda     INTIM
    bne     .waitTim
    sta     WSYNC
    sta     VBLANK
    stx     TIM64T

; save stack pointer
    tsx
    stx     tmpVar

; enable vertical delay:
    lda     #%1
    sta     VDELP0
    sta     VDELP1

    SLEEP   33

    ldy     #8
    ldx     #$c3
    lda     #$03
    stx     PF2                 ; 3     @62
    sta     PF1                 ; 3     @65

.loopScore:
    lax     (ptrScore+10),y     ; 5
    txs                         ; 2
    lax     (ptrScore+ 4),y     ; 5
    lda     #$48                ; 2
    sta.w   COLUPF              ; 4     @07
    lda     (ptrScore+ 0),y     ; 5
    sta     GRP0                ; 3     @15
    lda     (ptrScore+ 6),y     ; 5
    sta     GRP1                ; 3     @23

    lda     (ptrScore+ 2),y     ; 5
    sta     GRP0                ; 3     @31
    lda     (ptrScore+ 8),y     ; 5
    sta     GRP1                ; 3     @39
    lda     #$8a                ; 2
    sta     COLUPF              ; 3     @44

    stx     GRP0                ; 3     @47
    tsx                         ; 2
    lda     #$dc                ; 2
    stx     GRP1                ; 3     @54
    sta     COLUPF              ; 3     @57
    sta     GRP0                ; 3     @60

    dey                         ; 2
    bpl     .loopScore          ; 2³


;---------------------------------------------------------------
    sta     WSYNC
    iny
    sty     PF1
    sty     PF2
    sty     GRP0
    sty     GRP1
    sty     GRP0

    ldx     #2
.waitScreen:
    lda     INTIM
    bne     .waitScreen
    sta     WSYNC
    stx     VBLANK

; restore stack pointer
    ldx     tmpVar
    txs
    rts


OverScan SUBROUTINE
    lda     #36
    sta     TIM64T

    lda     SWCHB
    lsr
    bcs     .waitTim
    brk

.waitTim:
    lda     INTIM
    bne     .waitTim
    rts


;===============================================================================
; R O M - T A B L E S (Bank 0)
;===============================================================================
    org     $f600


DigitTbl:
    .byte   <Zero,  <One,   <Two,   <Three, <Four
    .byte   <Five,  <Six,   <Seven, <Eight, <Nine

One:
    .byte   %11111111
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
Seven:
    .byte   %11111111
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
Four:
    .byte   %11111111
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
Zero:
    .byte   %11000011
    .byte   %10111101
    .byte   %10111101
    .byte   %10111101
    .byte   %11111111
    .byte   %10111101
    .byte   %10111101
    .byte   %10111101
Three:
    .byte   %11000011
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
Nine:
    .byte   %11000011
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
Eight:
    .byte   %11000011
    .byte   %10111101
    .byte   %10111101
    .byte   %10111101
Six:
    .byte   %11000011
    .byte   %10111101
    .byte   %10111101
    .byte   %10111101
Two:
    .byte   %11000011
    .byte   %10111111
    .byte   %10111111
    .byte   %10111111
Five:
    .byte   %11000011
    .byte   %11111101
    .byte   %11111101
    .byte   %11111101
    .byte   %11000011
    .byte   %10111111
    .byte   %10111111
    .byte   %10111111
    .byte   %11000011

    org $f7fc
    .word   Start
    .word   Start
