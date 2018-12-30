	org $4000

.def DIG=1
	icl "atari.asm"
start = $90
	ball_x = start-1
	ball_y = start-2
	rightpad=start-3
	leftpad=start-4
	digitleft=start-5
	digitright=start-6

	NET_PLR_POS = HPOSP0
	NET_PLR_COL = COLPM0
	NET_PLR_GRF = GRAFP0
	RIGHT_PLR_POS = HPOSP1
	RIGHT_PLR_GRF = GRAFP1
	LEFT_PLR_POS = HPOSP2
	LEFT_PLR_GRF = GRAFP2
	BALL_XPOS = HPOSP3
	BALL_COL = P3PL
	BALL_GRF = GRAFP3
	TOP_BAND = 27
	BOTTOM_BAND = 103

startc:

	sei
	mva #0 DMACTL
	mva #$a8 AUDC1

	ldy #3
	;tax
colinit:
	lda positions,y
	sta HPOSP0,y
	lda #$38
	sta COLPM0,y
	sta leftpad,y
	dey
	bpl colinit
	jsr zerografp
gloop:
digit:
.print "After init: ", *
	lda #$f
.ifdef DIG
	cmp:rne VCOUNT
.endif
.ifdef DIG
.print "Digits start: ", *
	jsr zerografp

	ldx digitleft ; digit 3
	ldy digitright
	lda digits,x
	tax
	lda digits,y
	tay
again
	jsr digline
	lda VCOUNT
	cmp #$18
	bcc again
.print "Digits stop: ", *
.else
	lda #$18
	cmp:rne VCOUNT

.endif
	jsr zerografp

	jsr HORIZ_LINE
field:
	lda VCOUNT
	cmp #BOTTOM_BAND+2
	beq lastline

	ror
	and #1
	tay
	lda graf,y
	sta WSYNC
	sta NET_PLR_GRF

	LDA VCOUNT
	ldy #$1c
	jsr drawpads
	ldy #0
	sty AUDF1
	sec
	sbc #2
	sta WSYNC
	jsr drawball
	sec
	sbc #10
	jsr drawpads


	jmp field

lastline:
	jsr HORIZ_LINE+3
	sta BALL_GRF

logic:
	lda ball_y
	cmp #TOP_BAND
	bcc chgy
	cmp #BOTTOM_BAND
	bcc skip
chgy:
		sta AUDF1
		lda skip
		eor #$20
		sta skip
skip:
	inc ball_y
chkcolission:
	lda BALL_COL ; 1 - prawy; 2  - lewy
	lsr
	beq nocollision
	lda #$E6
	bit ball_x
	svc:lda #$C6
	sta incplace
	sta AUDF1
nocollision:
	
incplace
	inc ball_x
	sne:inc digitleft

	ldx #1
	ldy PORTA
chgpads
	tya
	lsr 
	scc:inc leftpad,x
	lsr
	scc:dec leftpad,x
	lsr
	lsr
	tay
	lda leftpad,x
	sec
	sbc #28
	and #$3f
	clc
	adc #28
	sta leftpad,x
	dex
	bpl chgpads


	lda ball_x
	sta BALL_XPOS
	sta HITCLR
	
	jmp gloop
HORIZ_LINE
	jsr WAIT3LINES
	lda #$0f
	sta COLBK

	jsr WAIT3LINES
	lda #0
	sta COLBK
	rts
zerografp
	ldy #3
	lda #0
zero:
	sta GRAFP0,y
	;sta SIZEP0,y
	dey
	bpl zero
	rts
.ifdef DIG
digline:
	lda digdef,x
	sta RIGHT_PLR_GRF
	lda digdef,y
	sta LEFT_PLR_GRF
	inx
	iny
.endif
WAIT3LINES
	lda #1
	; jmp WAIT3LINES
WAITLINES
	clc
	adc VCOUNT
WAITFORLINE
	cmp:rcs VCOUNT
	; sty COLBK
	rts
drawpads:
	cmp rightpad
	sne:sty RIGHT_PLR_GRF
	cmp leftpad
	sne:sty LEFT_PLR_GRF
drawball:
	cmp ball_y
	sne:sty BALL_GRF
	rts
.print "Digits: ", *
	graf = $CC48
;; graf:
;;	.by 0, $e0
positions
	.db $80,$c4,$34,$40
.ifdef DIG
digits:
	; -------------------
	.by d0-digdef,d1-digdef,d2-digdef,d3-digdef,d4-digdef,d5-digdef,d6-digdef,d7-digdef,d8-digdef,d9-digdef
	 ;------
digdef:
d5	.BY %11111111
	.BY %11100000
d3	.BY %11111111
	.BY %00000111
d2	.BY %11111111
	.BY %00000111
d6	.BY %11111111
	.BY %11100000
d8	.BY %11111111
	.BY %11100111
d9	.BY %11111111
	.BY %11100111
	.BY %11111111
	.BY %00000111
d0	.BY %11111111
	.BY %11100111
d4	.BY %11100111
	.BY %11100111
d7	.BY %11111111
d1	.BY %00000111
	.BY %00000111
	.BY %00000111
	.BY %00000111
	.BY %00000111
.endif
.print * - startc

	RUN startc

