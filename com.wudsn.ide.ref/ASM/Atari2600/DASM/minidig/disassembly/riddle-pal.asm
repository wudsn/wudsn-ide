; 4/30     NTSC
; 5/6      PAL
; 5/25/83  SECAM
; *****************************************
; *                                       *
; *        RIDDLE OF THE SPHINX           *
; *                AKA                    *
; *             DANK TOWER                *
; *                                       *
; *****************************************
;  DANK TOWER      FEBRUARY 11, 1982
;
;  Transcribed by T. Mathys, December 2003
;
;  Tabulators should be set to 8.
;
;  You need dasm and vcs.h to assemble the
;  program. Get them from
;
;    http://www.atari2600.org/dasm
;
;  How to assemble:
;
;    dasm riddle-pal.asm -f3 -oriddle-pal.bin
;
		processor 6502
		include	"vcs.h"
	
	
	
; set ORIGIN to $1000 to get the original rom
;ORIGIN		equ	$f000
ORIGIN		equ	$1000



;
; GAME EQUATES
;
PAL		equ	1
SECAM		equ	0
; *****************************************
; *	PAL                               *
; *****************************************
NULIST		equ	7
SECOND		equ	50
TOP		equ	$a0		; d0
BOTTOM		equ	$f0
DEAD		equ	$d0		; dead object
PHLOCK		equ	$38
ISLOCK		equ	$58
ANLOCK		equ	$98
SXLOCK		equ	$d8
ENDLOCK		equ	$fe
SANDCLR		equ	$0e		; c2
CURCOLOR	equ	$00
SCORECLR	equ	$28
SCBAKCLR	equ	SANDCLR
ENDCLR		equ	$46
MAXWOUND	equ	9		; max. wounds before you die
MAXTHROW	equ	$6a		; max. throw distance
MAXHIT		equ	10		; max. # of hits the shield blocks



;
; data segment
;
		seg.u	data
		org	$80
version		ds	1		; 0 = no locks, lives
					; 1 = no locks, wounds
					; 2 = locks, wounds
sand		ds	1		; sand color
status		ds	1		; d7 = 0  no logo
					; d6 = 0  select depressed
					; d2 = 0  allow p1 collision
					; d1 = 0  stop game motion
					; d0 = 0  do version number
attrmask	ds	1		; ff = full lume, f3 = low lume
randl		ds	1		; random number
randh		ds	1
frame		ds	2		; 16 bit frame counter
code		ds	2		; indirect pointer to code
index		ds	1
indexsh		ds	1
indexlo		ds	1
lastix		ds	1		; last index for collision debounce
lastdig		ds	1		; debounce dig
;
p0grx		ds	2		; pointers to player graphics data
p1grx		ds	2
colorp0		ds	2		; pointers to player color data
colorp1		ds	2
;
zerost
;
; projectile positions and deltas
;
m0x		ds	1
m1x		ds	1
m0y		ds	1
m1y		ds	1
m1dx		ds	1
;
curpos		ds	1		; cursor position, 0-11
wounds		ds	1		; 0 = not wounded
thirst		ds	1		; 0 = not thirsty
throw		ds	1		; distance of throw
;
clockl		ds	1		; time one second
clocks		ds	1		; seconds
clockm		ds	1		; minutes
;
scoreh		ds	1		; hi score byte
scorem		ds	1		; mid score
scorel		ds	1		; lo score
;
v0point		ds	1		; sound id
v1point		ds	1		; sound id
shcount		ds	1		; shield duration counters
;
zeroend
v1time		ds	1
;
lockix		ds	1		; territory lock
riddle		ds	1		; tablet choice (sphinx)
;
my		ds	1		; projectile ypos
p1y		ds	1
p1point		ds	1
;
playerx		ds	1		; player xpos
;
posses		ds	12		; list of possessions
;
stepp1		ds	NULIST+1
hmovep1		ds	NULIST
indirp1		ds	NULIST
p1ys		ds	NULIST
p1dx		ds	NULIST		; p1 deltas
;
t0		ds	1
t1		ds	1
t2		ds	1
p1step
t3		ds	1
count
t4		ds	1
;
countsh					; zeroed byte
t5		ds	1
;
char0		ds	2		; graphics data pointers
char1		ds	2		; for 6 digit kernel
char2		ds	2
char3		ds	2
char4		ds	2
char5		ds	2



;
; main program
;
		seg	code
		org	ORIGIN
start		sei
		cld			; no decimal
		ldx	#$00
		txa			; clear stella and ram
clp		sta	$0,x
		txs			; set stack pointer to end of ram
		inx
		bne	clp
;
; initializations
;
		ldx	#>ra
		stx	p0grx+1		; init high bytes of player
		stx	p1grx+1		; graphics data pointers
		stx	randh		; init random number generator
		inx			; move to next page (contains color data)
		stx	randl
		stx	colorp0+1	; init high bytes of player
		stx	colorp1+1	; color data pointers
		lda	#$12		; init high byte of code pointer
		sta	code+1
;
		jsr	clear		; clear posses, p1 list
		lda	#$80		; status = $80 -> show logo
		sta	status
;
; synch for new frame
;
scrntop		lda	#2
		sta	WSYNC		; and synch for 3 lines
		sta	VSYNC
; init digit pointers
		ldx	#11		; x = index/loop counter
		lda	#>numbers	; a = page of number graphics
		bit	status		; bit 7 of status set ?
		bpl	hiordlp		; no -> ok
		lda	#>logo		; yes -> a = page of logo graphics
hiordlp:	sta	char0,x		; set high bytes of digit pointers
		dex
		dex
		bpl	hiordlp
;
; colors
;
		lda	sand		; get sand color
		and	attrmask	; adjust brightness
		sta	COLUBK		; set
;       
		inc	frame		; low frame inc
		sta	WSYNC
		bne	noinc		; branch if no high inc
		inc	frame+1		; high frame inc
		bne	noattr		; no overflow -> ok
		lda	#$f3		; set attrmask to low lume
		sta	attrmask
noattr
		lda	status
		and	#%11111011	; reset d2 for p1 collisions
		sta	status
		and	#2		; mask out d1 (stop game motion flag)
		lsr			; do every other roll
		and	frame+1
		lsr
		bcc	noinc		; skip if d0 of frame+1 clear (or game stopped)
		dec	wounds		; heal 1 point
		bpl	skip64		; no underflow -> ok
		inc	wounds		; underflow -> wounds = 0
skip64
		sed
		lda	thirst
		adc	#0		; increment thirst if carry was set
		bcs	skip120		; carry set -> max. thirst reached
		sta	thirst		; set thirst
skip120		cld
noinc
		inx			; force x = 0
		sta	WSYNC
		stx	VSYNC		; vsync off
		lda	#$3d		; PAL timer value
		sta	TIM64T
;
; p1 intelligence
; scan list of p1s
;
		lda	status		; stop game motion ?
		and	#2
		beq	out14		; yes -> do nothing
		ldx	#NULIST-1
		lda	frame		; get lowest 3 bits of frame counter
		bit	SWCHB		; check p0 difficulty
		and	#7
		bvc	skip90		; amateur -> continue
		lsr			; pro -> speed up by 2
skip90
		bne	out14		; p1s are updated when d2,d1 (and d0 in
					; amateur mode) are zero
homelp
		lda	p1ys,x		; check for dead
		cmp	#DEAD
		beq	next00		; object is dead -> do next one
		lda	indirp1,x	; load identity
		cmp	#<bldgs		; is this a building ?
		bcc	next00		; yes -> don't move
		cmp	#<p1s		; other immovable object (obelisk, palm etc)
		bcs	next00		; yes -> don't move neither
; fire missile
		cmp	#<thief		; is it a thief ?
		bne	skip43		; no -> don't fire missile
		lda	frame		; limit fire rate:
		and	#$3f		; fire only if d0-d5 of frame are 0
		ora	m1x		; and m1x is 0 (m1x=0 means no p1 missile)
		bne	skip43
		lda	p1ys,x		; don't fire if off screen
		cmp	#$f0
		bcs	skip43
		sta	m1y		; missile y = object y
		lda	hmovep1,x	; missile x = object x
		sta	m1x
		ldy	#0		; aim
		sty	t1
		jsr	aim
		sty	m1dx		; save dx
skip43
		jsr	home		; home on player
		lda	frame		; don't do every frame
		and	#$f
		bne	skip16
		lda	p1dx,x
		sta	t1
		jsr	aim
		lda	indirp1,x	; clones don't move in x direction:
		sec
		sbc	#<clone		; is it a clone ?
		bne	skip130		; no -> skip
		tay			; yes -> set dx to zero
skip130		sty	p1dx,x
skip16
next00		dex
		bpl	homelp
out14
;
; read right joystick and move cursor
;
		lda	frame		; get frame counter
		and	#$f		; do only every 16th frame
		bne	out11
		ldx	curpos		; load cursor position
		lda	SWCHA		; load joystick state
		lsr			; get left
		lsr
		lsr
		bcs	noleft
		dex			; move cursor to the left
		bpl	noleft
		ldx	#11		; catch underflow
noleft
		lsr			; get right
		bcs	noright
		inx			; move cursor to the right
		cpx	#12
		bcc	noright
		ldx	#0		; catch overflow
noright
		stx	curpos		; save new cursor position
out11
;
; game select
;
		lda	SWCHB		; load select switch
		lsr			; carry = reset switch state
		php			; save for later
		lsr			; carry = game select switch state
		bcc	pushed
; not depressed
		lda	#$40		; mark select as pressed
		ora	status
		sta	status
		bne	out28		; always taken
; depressed
pushed
		bit	status		; check last select switch state
		bvc	out28		; already pressed -> do nothing
		ldx	version		; get game variant
		inx			; change to next variant
		cpx	#3		; overflow ?
		bne	skip61		; no -> ok
		ldx	#0		; yes -> wrap around
skip61
		stx	version		; save new game variant
		lda	#0
		sta	status		; reset game
		jsr	clear		; clear possession list
		ldx	version		; get game version
		inx			; bring it into range [1,3]
		txa			; a = x * 8:
		asl			; this is the lower byte
		asl			; of the number graphic,
		asl			; which is stored in the possession list,
		sta	posses		; so that the game version is displayed
out28
;
; game reset
;
		plp			; get reset switch state
		bcs	nonew		; not pressed -> skip
; init game
		jsr	clear
		ldy	#<shield	; assume version 0: start with shield
		ldx	#ENDLOCK
		lda	version		; get version
		lsr			; d0 set ?
		bcc	skip114		; no, so it's not version 1
		ldx	#SXLOCK
skip114
		lsr			; d1 set ?
		bcc	skip115		; no, so it's not version 2
		ldx	#PHLOCK
		ldy	#<spade		; version 2: start with spade
skip115
		stx	lockix		; save lock
		sty	posses		; initialize first object
		lda	#3		; set d0 (don't do version number)
		sta	status		; and d1 (do game motion)
		jsr	random
		tax
		lda	frame
		bne	skip63
		txa
skip63
		sta	randl
; select tablets
		and	#3		; random number between 0 and 3
		cmp	#3		; 3 doesn't exist...
		bne	skip67
		lda	#2		; ... use tablet #2 instead
skip67
		sta	riddle		; save tablet number
nonew
;
out29
;
; check for end of game
		lda	wounds		; max. amount of wounds reached ?
		cmp	#MAXWOUND
		bcc	out30		; no -> continue
;
; end game !!!
;
 		cmp	#9
 		bcc	end0
 		lda	#9
end0
		sta	wounds
		lda	#%11111101	; clear d1 (stop game motion)
		and	status
		sta	status
		lda	#ENDCLR		; change sand color
		sta	sand
out30
;
; check for stopped game
;
		lda	status		; d1 zero ?
		and	#2
		beq	out24		; yes -> game stopped, do nothing
;
; clock
;
		ldx	clockl		; low clock (actually a frame counter)
		inx
		cpx	#SECOND		; did a second pass ?
		bcc	wrlow		; nope -> skip
		ldx	#0		; reset counter
;
		sed
		lda	clocks		; seconds
		adc	#0		; one second more
		sta	clocks
		cmp	#$60
		bcc	wrlow		; skip if no wrap
		stx	clocks		; zero seconds
		lda	clockm		; load minutes
		adc	#0		; one minute more
		sta	clockm
wrlow
		stx	clockl		; write low clock back
		cld
;
; handle right button
;
		bit	INPT5		; right button pressed ?
		bmi	out51		; nope -> skip
		ldx	curpos		; x = cursor position
; right fire and right down pressed -> drop selected item
		lda	SWCHA
		lsr			; down ?
		lsr
		bcs	skip55		; no -> skip
		lda	#<blank		; load blank object
		sta	posses,x	; delete item from possession list
		bne	out51		; leave (always taken)
skip55
; only right fire pressed -> use selected item
		lda	posses,x	; get item number
		sec			; make zero based (ignore digits)
		sbc	#objects - numbers
		lsr			; divide by 8, since posses stores
		lsr			; lower bytes of object graphics data
		lsr			; addresses (each object is 8 bytes).
		tay
		lda	objservs,y	; get low byte of object service address
		sta	t0		; save
		lda	#>oservice	; get hi byte of object service address
		sta	t1		; save
		lda	#<blank
		jmp	(t0)		; jump to object service handler
return2					; object service handler returns here
out51
;
; left button (throw stone)
;
		bit	INPT4		; left button pressed ?
		bmi	out24		; no -> skip
		ldy	m0x		; see if missile 0 dead
		bne	out24		; no -> can't fire another one yet
; calculate throw distance
		lda	wounds
		asl			; weight wounds
		asl
		asl
		adc	thirst		; add thirst
		bcs	wrap00		; overflow -> wrap00
		cmp	#MAXTHROW-2	; a < MAXTHROW-2 -> wrap01
		bcc	wrap01
wrap00
		lda	#MAXTHROW-2	; load max. value
wrap01
		sta	t1		; save
		lda	#MAXTHROW	; throw = MAXTHROW - t1
		sbc	t1
		sta	throw
		ldy	#0		; missile y = 0
		sty	m0y
		ldy	playerx		; missile x = player x
		sty	m0x
out24
;
; delta missiles
;
		lda	frame		; alter delta
		lsr
		php			; save carry
		rol
		and	#3
		bne	out19
dloop		lda	m1x		; zero = dead
		beq	next01
		lda	m1dx		; load delta
		beq	next01
		sta	t0
		asl
		lda	m1x		; reload xpos
		jsr	domove		; move missile
		bcc	skip70
		lda	#1		; kill if attempted wrap
		sta	t0
		lda	#0
skip70
		sta	m1x		; write new xpos
		ror	t0
		bcs	next01		; delta only once
		pha			; save xpos
		lda	m1dx
		asl
		pla			; get xpos
		jsr	domove
		sta	m1x
next01
out19
; delta y - kill if offscreen
		ldx	m0y		; missile 0
		inx
		plp
		php
		bcs	skip77
		inx
skip77
		dec	throw		; decrement throw distance
		beq	killrock	; zero reached -> kill rock
		cpx	#TOP		; top of screen reached ?
		bcc	donext		; nope -> ok
killrock
		ldx	#0		; kill
		stx	m0x
donext
		stx	m0y		; write new y position
		ldx	m1y		; missile 1
		dex
		plp
		bcc	skip103
		dex
skip103
		cpx	#BOTTOM-6	; bottom of screen reached ?
		bcc	ok03
		cpx	#BOTTOM
		bcs	ok03
		ldx	#0		; yes -> kill
		stx	m1x
ok03
		stx	m1y		; write new y position
;
; remove one empty slot in list of p1's
;
		ldx	#0
		stx	t0
loop2		ldy	p1ys,x
		cpy	#DEAD
		bne	skip18
		inc	t0
loop3		inx			; bump loop count
		cpx	#NULIST
		bne	loop2
		beq	out06
skip18
		lda	t0
		beq	loop3
; reading valid entry
loop4
		lda	indirp1,x
		pha
		lda	hmovep1,x
		pha
		lda	p1dx,x
		dex
		sta	p1dx,x
		pla
		sta	hmovep1,x
		pla
		sta	indirp1,x
		sty	p1ys,x
		inx			; point to old entry
		inx			; point over
		cpx	#NULIST		; check for max
		beq	out06
		ldy	p1ys,x
		bcc	loop4		; always taken
out06
;
; set up step values
;
		ldx	#0
loop5		ldy	p1ys,x
		beq	zero00
		cpy	#BOTTOM		; below screen ?
		bcs	zero00		; yes
		cpy	#DEAD		; blank slot
		bne	skip19
zero00		ldy	#1
skip19		inx
		cpx	#NULIST
		beq	out07
		dey
		sty	stepp1,x
		bcc	loop5
out07
;
; set up ball
; the ball is used to draw both the prince's and the thief's
; stones:
;
; -	during even frames, the prince's stone is drawn
; -	during odd frames, the thief's stone is drawn
;
		ldx	#0		; default ball size
		stx	COLUPF
		lda	frame
		lsr
		bcs	oddfr		; go if odd frame
evenfr		ldy	m0y		; y = missile 0 ypos
		lda	m0x		; a = missile 0 xpos
		bne	out09		; if x is nonzero
doshield	lda	#SANDCLR
		and	attrmask
		sta	COLUPF
		lda	playerx
		ldx	#$20
		ldy	#1		; ypos
		bne	out09
oddfr		ldy	m1y		; y = missile 1 ypos
		lda	m1x		; a = missile 1 xpos
		beq	doshield
out09
		sta	WSYNC
		stx	CTRLPF		; 0	+3	waste 3
		nop			; 3	+2
		stx	CTRLPF		; 5	+3	ball size
		sty	my		; 8	+3	save missile ypos
		sta	HMBL		; 11	+3
		and	#$0f		; 14	+2
		tay			; 16	+2
rloop1		dey
		bpl	rloop1
		sta	RESBL
		sta	WSYNC
		sta	HMOVE
;
; sound routines
;
sound		lda	v1point
		beq	skip88
skip80		cmp	#1
		bne	skip81
; bonus sound
		jsr	random
		and	#7
		ora	#3
		tay
		lda	frame
		and	#3
		beq	skip101
		lda	#$f
skip101
		ldx	#5
		bne	skip83		; leave (always taken)
skip81
		cmp	#2
		bne	skip82
; steal sound
		ldy	v1time
		ldx	#5
		lda	#$f
skip82		cmp	#3
		bne	skip83
; raspberry
		lda	#$f
		ldx	#$c
		ldy	#$1f
; gong sound
skip83		cmp	#4
		bne	skip88
		ldx	#$d
		ldy	#4
		lda	v1time
		asl
skip88		sta	AUDV1
		stx	AUDC1
		sty	AUDF1
skip102		dec	v1time
		bpl	skip84
		lda	#0
		sta	AUDV1
		sta	v1point
skip84		ldx	v0point
		dex
		bpl	dov0
		inx
dov0		stx	v0point
		lda	knock,x
		sta	AUDV0
		jsr	random
;
vbout		lda	INTIM		; wait for vb over
		bne	vbout
		sta	WSYNC
		sta	VBLANK		; enable beam (a = 0)
;
; set up for kernels
;
		sta	count
		sta	p1point
		sta	t1		; p1 graphics
		sta	t0		; pad count
		lda	indexlo
		cmp	#16
		bcc	skip06
		sbc	#16
		tay
		sty	t0		; pad count
		lda	#16
skip06		sta	countsh
skip07		ldx	#ENABL
		txs
		sta	HMCLR
		ldx	#TOP		; line counter
		stx	p1y
		stx	stepp1
		jmp	padloop

;
; add to score
; a has delta, x and y get trashed
;
add		subroutine
		ldx	#2		; digit index / loop counter
addm		sed
.addloop	clc
		adc	scoreh,x	; add current digit
		sta	scoreh,x
		bcc	.out03		; no carry -> done
		lda	#1		; a is now the carry
		dex			; next digit
		bpl	.addloop
.out03		cld
		rts
		
;
; subtract from score
; a has delta, x and y get trashed
;
subtract	subroutine
		ldx	#2
		sta	t0
		sed
.subloop	sec
		lda	scoreh,x
		sbc	t0
		sta	scoreh,x
		bcs	.out22
		lda	#1
		sta	t0
		cpx	#2
		bne	.skip44		; not low
		lda	scorem		; if borrom from lo, check highs
		ora	scoreh
		bne	.skip44		; go if something to borrow
		sta	scorel		; zero lo score
		beq	.out22
.skip44		dex
		bpl	.subloop
.out22		cld
		ldx	#3
		stx	v1point
		ldx	#$10
		stx	v1time
		rts

;
; move player left or right
; a has xpos, if carry, move right
;
domove		subroutine
		tay
		bcs	.mright
		cmp	#0		; already at leftmost position ?
		beq	.back		; yes -> bye
		clc
		adc	#$10
		bpl	.ok00
		cmp	#$90		; time to step ?
		bcs	.ok00		; no
		sbc	#$f0		; carry clear
.ok00		clc
.skip08
.back		rts			; if carry, attempted wrap
.mright		cmp	#$88		; already at rightmost position ?
		beq	.back		; yes -> bye
		sec
		sbc	#$10
		bmi	.ok01
		cmp	#$70		; time to step ?
		bcc	.ok01
		adc	#$f0		; carry set
.ok01
		clc
.skip09
		rts

;
; six character kernel
;
sixchar		subroutine
		ldy	#8
.sckrnl
		dey			; 59	+2
		sty	t1		; 61	+3
		lda	(char5),Y	; 64	+5
		sta	GRP0		; 69	+3
		sta	WSYNC		; 72	+3	75 cycles total
		lda	(char4),y	; 0	+5	cycle count starts here
		sta	GRP1		; 5	+3
		lda	(char3),y	; 8	+5
		sta	GRP0		; 13	+3
		lda	(char2),y	; 16	+5
		sta	t2		; 21	+3
		lda	(char1),y	; 24	+5
		tax			; 29	+2
		lda	(char0),y	; 31	+5
		tay			; 36	+2
		lda	t2		; 38	+3
		sta	GRP1		; 41	+3
		stx	GRP0		; 44	+3
		sty	GRP1		; 47	+3
		sty	GRP0		; 50	+3
		ldy	t1		; 53	+3
		bne	.sckrnl		; 56	+3 (2)
		sty	GRP0
		sty	GRP1
		sty	GRP0
		sty	GRP1
		rts

servtabl
		.byte	#<sxserv	; sphinx
		.byte	#<phoeserv	; phoenix
		.byte	#<raserv	; ra
		.byte	#<oaserv	; oasis
		.byte	#<atemserv	; temple of anubis
		.byte	#<pyrserv	; great pyramid(s)
		.byte	#<itemserv	; temple of isis
		.byte	#<anuserv	; anubis
		.byte	#<isisserv	; isis
		.byte	#<thserv	; thief
		.byte	#<scorserv	; scorpion
		.byte	#<clserv	; clone
		.byte	#<return

;
; last lines before kernel
;
		align	256
padloop		sta	WSYNC
		sta	CXCLR
		nop
		ldy	index
		iny
		sty	indexsh
		cpx	my		; mc 7
		php			; mc 10
		pla			; mc 14
skip10		dex			; mc 23
		beq	toendk		; mc 25/26
		lda	t0		; mc 28  pad value
		beq	kentry		; mc 32/33
		dec	t0		; mc 37
		bpl	padloop		; mc 40  always taken

ldzero0		nop			; mc 49
		nop
		lda	t0
		lda	#0		; mc 51
		beq	skip00		; mc 54
ldzero1		lda	#0
		sta	t1
		lda	sand
		bne	skip01
toendk		jmp	endk

;
; main kernel
;
loop0		sta	COLUP1		; mc 73
		lda	t1		; mc 76
;
kernel		sta	GRP1		; mc 3
		lda	(p0grx),y	; mc 8
		sta	GRP0		; mc 11
		lda	(colorp0),y	; mc 16
		sta	COLUP0		; mc 19
;
		cpx	my		; mc 22
		php			; mc 25
		pla			; mc 29
;
		dex			; mc 31
		beq	toendk		; mc 33
;
kentry		txa			; mc 35
		sec			; mc 37
		sbc	p1y		; mc 40
		tay			; mc 42
		and	#$f0		; mc 44
		bne	ldzero0		; mc 46/47
		lda	(p1grx),y	; mc 51
		sta	t1		; mc 54
		lda	(colorp1),y	; mc 59
skip00
		dec	count		; mc 64
		ldy	count		; mc 67
		bpl	loop0		; mc 69/70
;
; line 17 - set up p0
;
		dec	indexsh		; mc 74
		sta	COLUP1		; mc 1
		lda	t1		; mc 4
		sta	GRP1		; mc 7
		cpx	my		; mc 10
		php			; mc 13
		pla			; mc 17
; do set up
		ldy	indexsh		; mc 20
		lda	(code),y	; mc 25
		and	#$7		; mc 27
		sta	t0		; mc 30	store delay
		tya			; mc 32
		and	#$f		; mc 34		
		sta	t2		; mc 37
		and	#$6		; mc 39
		sta	NUSIZ0		; mc 42
;
		dex			; mc 44
		beq	toendk		; mc 46/47
;
		txa			; mc 48
		sec			; mc 50
		sbc	p1y		; mc 53
		tay			; mc 55
		and	#$f0		; mc 57
		bne	ldzero1		; mc 59/60
		lda	(p1grx),y	; mc 64
		sta	t1		; mc 67
		lda	(colorp1),y	; mc 72
;
skip01
;
; line 18 - set up p0
;
		sta	COLUP1		; mc 75
		lda	t1		; mc 2
		sta	GRP1		; mc 5
		cpx	my		; mc 8
		php			; mc 11
		pla			; mc 15
;
		lda	t2		; mc 18
		beq	dobldg		; mc 20/21
doobj		ldy	indexsh		; mc 24
		lda	(code),y	; mc 29
		lsr			; mc 31
		and	#$7		; mc 33
		tay			; mc 35
		lda	p0ind,y		; mc 39
		sta	colorp0		; mc 42
		sta	p0grx		; mc 45
; mc 43/45
cont00		dex			; mc 47
		bne	skip15		; mc 49/50
toendk2		jmp	endk
;
;
ldzero2		lda	#0
		ldy	#0
		beq	skip02
ldzero4		lda	#0
		beq	skip03
;
; building
dobldg		lda	indexsh
		lsr
		lsr
		lsr
		lsr			; mc 28
		tay			; mc 30
		lda	bldgind,y	; mc 34
		sta	colorp0		; mc 37
		sta	p0grx		; mc 40
		dex			; mc 42
		beq	toendk2		; mc 44/45
;
skip15		txa			; mc 52
		sec			; mc 54
		sbc	p1y		; mc 57
		tay			; mc 59
		and	#$f0		; mc 61
		bne	ldzero2		; mc 63/64
		lda	(p1grx),y	; mc 68
		sta	GRP1
skip02
;
; line 19 - reset p0 kernel
;
		cpx	my
		sta	WSYNC
		php
		nop
		lda	(colorp1),y	; mc 8
		sta	COLUP1		; mc 11
		ldy	t0		; mc 14	delay
		dex			; mc 16
		beq	toendk1		; mc 18/19
resetlp		dey			; mc 20
		bpl	resetlp		; mc 22/23
		sta	RESP0		; mc 25/?
;
		pla
		sec			; mc 68
		txa			; mc 70
		sbc	p1y		; mc 73
		sta	WSYNC		; mc 76
;
; line 20 - check for p1 reset
;
		tay			; mc 2
		and	#$f0		; mc 4
		bne	ldzero4		; mc 6/7
		lda	(colorp1),y	; mc 11
		sta	COLUP1		; mc 14
		lda	(p1grx),y	; mc 19
		sta	GRP1		; mc 22
skip03		sta	t1		; mc 25 (15 if no p1)
		cpx	my		; mc 28
		php			; mc 31
		pla			; mc 35
		dex			; mc 37
		beq	toendk1		; mc 39/40
;
		ldy	p1point		; mc 42
		txa			; mc 44
		cmp	stepp1,y	; mc 48
		bcs	noreset		; mc 50/51
; if this path is taken, no p1, so max count is 39 !!
		lda	indirp1,y	; mc 43
		sta	p1grx		; mc 46
		sta	colorp1		; mc 49
		lda	p1ys,y		; mc 53
		sta	p1y		; mc 56
		lda	countsh		; mc 59
		sta	count		; mc 62
		lda	hmovep1,y	; mc 66
		iny			; mc 68
		sty	p1point		; mc 71
		sta	WSYNC		; mc 74
;
; line 21 - reset p1
		sta	HMP1		; mc 3
		and	#$0f		; mc 5
		tay			; mc 7
;
		cpx	my		; mc 10
		php			; mc 13
		dex			; mc 15
		beq	endk		; mc 17/18
rp1lp		dey			; mc 19
		bpl	rp1lp		; mc 21/22
		sta	RESP1		; mc 24/?
;
; line 22 - set up to return to main kernel
;
		sta	WSYNC
		sta	HMOVE		; mc 3
		pla			; mc 7
		cpx	my		; mc 10
		php			; mc 13
		pla			; mc 17
		dex			; mc 19
		beq	endk		; mc 21/22
		lda	#16		; mc 23
		sta	countsh		; mc 26
		nop			; mc 28
		nop			; mc 30
		jmp	kentry		; mc 33
;
toendk1		jmp	endk
;
; line 20 - no p1 reset, run instead of p1 reset
;
noreset
		txa			; mc 53
		sec			; mc 55
		sbc	p1y		; mc 58
		tay			; mc 60
		and	#$f0		; mc 61
		bne	skip04
		lda	(p1grx),y	; mc 68
		sta	t1		; mc 71
skip04
;
; line 21 - maps to p1 reset line
		sta	WSYNC		; mc 74 max
		lda	t1		; mc 3
		sta	GRP1		; mc 6
		lda	(colorp1),y	; mc 11
		sta	COLUP1		; mc 14
		cpx	my		; mc 17
		php			; mc 20
		pla			; mc 24
		dex			; mc 26
		beq	endk		; mc 28/29
		txa			; mc 30
		sec			; mc 32
		sbc	p1y		; mc 35
		tay			; mc 37
		and	#$f0		; mc 39
		bne	ldzero03	; mc 41/42
		lda	(p1grx),y	; mc 46
		sta	t1		; mc 49
skip05
		lda	countsh		; mc 55
		sta	count		; mc 58
		lda	#16		; mc 60
		sta	countsh		; mc 63
		lda	(colorp1),y	; mc 8
		sta	WSYNC
;
; line 22 - maps to p0 set up line
;
		nop
		sta	COLUP1		; mc 11
		lda	t1		; mc 52
		sta	GRP1		; mc 3
		cpx	my		; mc 14
		php			; mc 17
		pla				; mc 21
		dex			; mc 23
		beq	endk		; mc 25/26
		lda	#16		; mc 27
		sta	countsh		; mc 30
		jmp	kentry		; mc 33
;       
ldzero03	ldy	#0
		beq	skip05
;
endk
		lda	playerx
		sta	HMP0
		ldy	#<clone
		sty	colorp0
		ldy	#<thief
		sty	p0grx		; indir
		sta	WSYNC
		stx	GRP0
		stx	GRP1
		stx	ENABL
		and	#$0f
		tay
		nop
		nop
;
; set up player
;
rloop2		dey
		bpl	rloop2
		sta	RESP0
		sta	WSYNC
		sta	HMOVE
		lda	CXP0FB		; p0 collisions
		sta	t3
		lda	CXP1FB
		sta	t4
		sta	CXCLR		; clear collisions
		stx	NUSIZ0
		ldx	#ENABL
		txs
		ldx	#$fd		; point to correct line count
		ldy	#15
playerlp	lda	(p0grx),y
		sta	WSYNC
		cpx	my		; ball
		php
		sta	GRP0
		lda	(colorp0),y
		and	attrmask
		sta	COLUP0
		dex			; point to correct line count
		pla
		dey
		bpl	playerlp
;
; set up ball for use as cursor
;
		lda	#$30
		sta	CTRLPF		; make ball 8 clocks wide
		sta	WSYNC
		lda	#CURCOLOR
		and	attrmask
		sta	COLUPF
		ldx	curpos
		lda	cursors,x	; hmov/delay
		sta	HMBL
		and	#$0f
		tax
		lda	#$40
rloop3		dex
		bpl	rloop3
		sta	RESBL
		sta	REFP1
		sta	WSYNC
		sta	HMP1
		lda	#SCORECLR
		and	attrmask
		sta	COLUP0
		sta	COLUP1
;
		lda	#$33		; do score reset
		sta	NUSIZ0		; triple copies close
		sta	NUSIZ1
		sta	HMP0
		txs
		stx	VDELP0
		stx	VDELP1
		ldx	#$20
		lda	CXP0FB		; save ball p0/p1 collisions
		sta	RESP0
		sta	RESP1
		sta	t5
		sta	WSYNC		; for hmove
		sta	HMOVE
		stx	TIM8T		; set timer
;
; set up logo ?
;
		bit	status
		bmi	dologo
;
; set up wounds ?
;
		lda	SWCHB
		asl
		and	#$10
		beq	dowound
;
; set up score or clock
;
		bcc	doscore		; right difficulty
;
; set up clock indirection
;
		lda	#<blank		; leftmost char blank
		sta	char5
;
		lda	#<colon		; 4th char is the colon
		sta	char2
;
		ldx	#1
		ldy	#6
clocklp		lda	clocks,x
		lsr
		and	#%01111000
		sta	char1,y		; high minutes
		lda	clocks,x
		and	#$f
		asl
		asl
		asl
		sta	char0,y
		ldy	#0
		dex
		bpl	clocklp
		bmi	cont01		; always taken
;
; set up wounds
;
dowound		lda	#<blank
		sta	char5
		sta	char3
		sta	char2
		lda	wounds
		asl
		asl
		asl
		sta	char4
		lda	thirst
		and	#$f
		asl
		asl
		asl
		sta	char0
		lda	thirst
		lsr
		and	#%01111000
		sta	char1
		bpl	cont01		; always taken
;
; set up logo
;
dologo		ldy	#5
		ldx	#10
logoloop	lda	logotabl,y
		sta	char0,x
		dex
		dex
		dey
		bpl	logoloop
		lda	#SCBAKCLR
		and	attrmask
		sta	COLUPF
		bne	cont01		; always taken
;
; set up score
;
doscore		ldy	#10
		ldx	#0
		clc
setloop		lda	scoreh,x
		and	#$f0
		bne	skip49
		bcs	skip49
		lda	#<blank
		bne	store1		; always taken
skip49
		lsr
		sec
store1		sta	char0,y
		dey
		dey
		lda	scoreh,x
		and	#$f
		bne	skip48
		bcs	skip48
		lda	#<blank
		bne	store0		; always taken
skip48
		asl
		asl
		asl			; *8
		sec
store0		sta	char0,y
		dey
		inx
		txa
		and	#2		; lo byte, force sec
		beq	skip50
		sec
skip50		dey
		bpl	setloop
;
;		
cont01
		bit	TIMINT
		bpl	cont01
		jsr	sixchar
;
; load list of holdings
;
		ldx	#10		; y=0
templp1		lda	posses,y
		sta	char0,x
		iny
		dex
		dex
		bpl	templp1
;
		ldx	#0		; make x=0
		sta	WSYNC
		lda	curpos		; load cursor position
		cmp	#6
		bcs	skip30
		ldx	#2
skip30		stx	ENABL
		stx	t0		; hold
		jsr	sixchar
		sty	ENABL		; turn off ball
;
; load list of holdings (temporary)
;
		ldy	#6
		ldx	#10
templp2		lda	posses,y
		sta	char0,x
		iny
		dex
		dex
		bpl	templp2
;
		lda	t0
		eor	#$ff
		sta	WSYNC
		sta	ENABL
		jsr	sixchar
		sty	ENABL		; turn off ball
		sty	NUSIZ0
		sty	NUSIZ1
		sty	VDELP0
		sty	VDELP1
		dey
		sty	REFP1
		sty	HMCLR
		sta	WSYNC
;
; overscan
;
ovscan		lda	#$32		; pal timer value
		sta	TIM64T
		lda	#2
		sta	VBLANK
;
; stop cx's during attract
;
		lda	attrmask
		cmp	#$f3
		bne	out25
		iny			; y=0
		sty	t3
		sty	t4
		sty	t5
out25
;
; stop rock if hit player zeros
;
		lda	frame
		lsr
		bcc	out100
		lda	m1x
		beq	out100
		bit	t3		; player 0 cx
		bvc	out100
		lda	#BOTTOM-3
		sta	m1y
out100
;
; hit player with rock
;
		bit	t5		; p0 ball cx
		bvc	out27
; rock hit
		ldx	curpos
		lda	posses,x
		cmp	#<shield	; are we wearing the shield ?
		bne	skip132		; nope -> go on
		ldy	shcount		; yeah -> damage shield
		iny
		cpy	#MAXHIT		; max. # of hits reached ?
		bcc	skip133		; nope -> go on
		jsr	steal		; yeah -> remove shield
		ldy	#0
skip133		sty	shcount
		jmp	skip89
skip132		cmp	#<necklace	; are we wearing the necklace ?
		beq	out27		; yeah -> no damage
;
		inc	wounds
		bit	SWCHB		; difficulty ?
		bvc	skip89		; amateur -> done
		inc	wounds		; pro -> hurt a bit more
skip89
		lda	#BOTTOM-3
		sta	m1y
		lda	#$1f
		sta	AUDF0
		lda	#1
		sta	frame
		sta	AUDC0
		lda	#knocke-knock
		sta	v0point
out27
;
; players rock collision
;
		lda	frame
		lsr
		bcs	out101
		lda	m0x
		beq	out101
		bit	t4		; p1 collision
		bvc	out20
;
		ldx	#NULIST-1
hitloop		lda	my		; ball ypos
		sec
		sbc	p1ys,x
		and	#$f0
		beq	hit
		dex
		bpl	hitloop
		bmi	out20		; always taken
; scan list for hit
hit		ldy	#1		; kill rock
		sty	throw
		lda	indirp1,x	; load identity
		cmp	#<bldgs
		bcc	out20
		cmp	#<palm
		beq	out20
		cmp	#<super
		ldy	#$77		; minus score for god hit
		bcc	sub00		; indestructable
		ldy	#DEAD
		sty	p1ys,x		; kill
		cmp	#<clone		; nomad hit ?
		bne	scorepl		; no -> score
		ldy	#$80		; yes -> minus score
sub00		tya
		jsr	subtract
		jmp	out20
scorepl		lda	#$60
		jsr	add
contcx		lda	#$17
		sta	AUDF0
		lda	#1
		sta	AUDC0
		lda	#knocke-knock
		sta	v0point
out20
		bit	t3		; player 0 cx
		bvc	out101
		ldy	#1
		sty	throw
out101
;
; p1 collision detect
;
		lda	status		; p1 cx timer and game stop
		and	#6
		eor	#2
		bne	out21		; d2 set, leave (no p1 collisions)
		lda	index
		cmp	lastix
		beq	out21
		lda	frame
		lsr
		bcs	ckp1
		lda	m0x
		bne	out21
		beq	docx		; always taken
ckp1		lda	m1x
		bne	out21
docx		bit	t4		; p1/ball cx
		bvc	out21
; collision, but which ?
		lda	index
		sta	lastix
		lda	status
		ora	#4
		sta	status
		lda	#$80
		sta	frame		; cx timer
		ldx	#NULIST-1
scanloop	lda	p1ys,x
		beq	yup
		cmp	#$f6
		bcs	yup
		dex
		bpl	scanloop
		bmi	out21		; none !!
yup		lda	indirp1,x
		pha
		cmp	#<bldgs
		bcs	skip72
		lda	#0
		sta	lastix		; for bldgs, timer only
skip72		lda	index		; find staff ?
		cmp	#7
		bne	skip100
		lda	#<staff
		jsr	givest		; give staff
skip100		pla
		lsr
		lsr
		lsr
		lsr
		tay
		lda	servtabl,y	; load 1 of 16 services
		sta	t0
		lda	#>services
		sta	t1
		stx	t2		; save for isis
		ldx	curpos
		lda	posses,x
		jmp	(t0)
indiret
out21
;
; move playfield if attract
;
		lda	attrmask
		cmp	#$f8
		bcs	out31
		ldx	#1
		jmp	moveix		; always move
out31
		lda	status		; skip if game stopped
		and	#2
		bne	doinput
		jmp	out01
doinput
;
; read joystick and scroll screen
;
; speed depends on health
;
; check for chariot or sceptre first
;
		ldx	curpos
		lda	posses,x	; holding sceptre ?
		cmp	#<sceptre
		beq	skip52		; yes -> move at full speed
		lda	thirst		; calculate index speed mask to use,
		lsr			; depending on thirst and health
		lsr
		lsr
		lsr
		adc	wounds
		cmp	#8
		bcc	wrap02
		lda	#7
wrap02		tax
		lda	frame
		and	speedmsk,x	; (frame & speedmsk) == 0 ?
		beq	skip52		; yes -> move
		jmp	out01		; no -> do nothing
skip52		ldx	#0
		lda	SWCHA
		asl
		asl
		bmi	skip14
		dex
skip14		asl
		bmi	skip11
		inx
;
; x has delta, disallow motion when in contact with terrain
;
skip11		bit	t3		; ball/p0 collision
		bvs	skip39		; cx
		bit	t4		; ball/p1
		bvc	out08
skip39
		lda	indexlo		; hit top or bottom
		cmp	#7
		bcs	hitbott
		txa			; get delta
		bmi	out08
zerox0		ldx	#0
		beq	out08		; always taken
hitbott		txa
		bmi	zerox0
out08
		txa
		bmi	ndelt		; minus delta
		lda	index
		cmp	lockix		; locked ?
		bne	moveix
		ldx	#$10
		stx	v1time
		ldx	#3
		stx	v1point
		ldx	#0		; stop motion
ndelt		lda	index
		bne	moveix
		tax
moveix		txa
		clc
		adc	indexlo
		bmi	skip12
		cmp	#22
		bcc	skip13
		lda	#0
		inc	index
		bcs	skip13
skip12		lda	#21
		dec	index
skip13		sta	indexlo
;
; scroll p1 list
;
		txa			; get delta
		eor	#$ff
		clc
		adc	#1
		tay
		ldx	#NULIST-1
deltalp		tya
		clc
		adc	p1ys,x
		cmp	#BOTTOM		; bottom
		bcs	on1
		cmp	#TOP-2		; top
		bcc	on1
		lda	#DEAD
on1		sta	p1ys,x
		dex
		bpl	deltalp
; y has delta
		jsr	bbirth		; if moving, check for bldg birth
;
; move player left or right
;
		lda	playerx
		bit	SWCHA
		clc
		bvc	dostick		; left with no carry
		bmi	out01
		sec
dostick		jsr	domove
		lsr	frame+1
		sta	playerx
out01
		sta	WSYNC
;
;
ovout		lda	INTIM		; overscan timeout
		bne	ovout
		jmp	scrntop		; new frame !
		
;
; subroutines
;

;
; give an object
; 
; input		:	carry = 1	give magical object
;			carry = 0	give normal object
;
; output	:	carry = 0	duplicate given
;
give		subroutine
		php
		jsr	random
		plp
		and	#7		; lo 3
		bcc	.skip45
		ora	#8		; set d3
.skip45		tay
		lda	treatabl,y	; load treasure
givest		subroutine		; entry with a = #<address_of_gift
		ldx	#11
.possloop	cmp	posses,x	; see if have
		clc
		beq	.out23		; already have
		dex
		bpl	.possloop
; don't have, look for first blank
		inx
.searloop	ldy	posses,x
		cpy	#<blank		; blank slot found ?
		beq	.giveit		; yes -> give object
		inx			; check next slot
		cpx	#12
		bne	.searloop
		beq	.out23		; no free slot, can't give object
.giveit		sta	posses,x
		lda	#1
		sta	v1point
		lda	#$10
		sta	v1time
.out23		rts

;
; move horizontally to player
; x points to p1
;
home		subroutine
		lda	p1dx,x		; load delta
		beq	.out15
		sta	t0		; save
		asl			; use d7 (if carry, move right)
		lda	hmovep1,x	; load xpos
		jsr	domove
		ror	t0		; divide delta by two
		bcs	.wrxpos
		pha			; push xpos
		lda	p1dx,x		; reload delta
		asl
		pla			; get xpos
		jsr	domove
.wrxpos		sta	hmovep1,x
.out15
;
; walk down screen
;
; see if building coming
		lda	index
		and	#$f		; use lo nibble
		cmp	#9
		beq	.skip34
		cmp	#7
		beq	.skip34
		cmp	#8
		bne	.walk
; check if critical area
.skip34		lda	p1ys,x		; load ypos
		cmp	#$f0
		bcs	.out12
		cmp	#$20
		bcc	.out12		; don't walk down screen
;
.walk		lda	p1ys,x
		tay
		sec
		sbc	#1
		cmp	#TOP
		bcc	.ok02		; still on screen
		cmp	#BOTTOM
		bcs	.ok02
		lda	#DEAD		; kill p1
		bne	.out12
; check distance to next p1
.ok02		inx			; point down list
		pha			; save ypos
		lda	p1ys,x		; see if dead
		cmp	#DEAD
		beq	.out02		; pop, and leave with set carry
;		
		pla
		pha
		sec
		sbc	p1ys,x
		cmp	#$28		; safe distance
.out02		pla			; get ypos back
		bcs	.out13		; go if room
.nowalk		tya			; get old ypos
.out13		dex			; point back to desired entry
.out12		sta	p1ys,x
		rts

;
; aim toward p1
; delta x returned in y, x points to p1
;
aim		subroutine
		ldy	#0
		lda	playerx
		and	#$f
		sta	t0
		lda	hmovep1,x
		and	#$f
		sec
		sbc	t0
		bne	.skip17		; go if delays not equal
		ldy	t1		; get old delta
		jmp	.out17
;
.skip17		bcc	.dodec		; dec delta
		iny
		cmp	#2
		bcc	.out16
		iny
.out16		rts
.dodec		dey
		cmp	#$ff
		bcs	.out17
		dey
.out17		rts

;
; building birth
;
bbirth		subroutine
		lda	#0
		sta	t2
		tya			; get delta y
		beq	.out04
		bpl	.bkward
;
; moving forward, building to top slot
;
		ldy	index
		tya
		and	#$f
		bne	.nobldg		; no building
		lda	indexlo
		cmp	#0
		beq	.skip21
;
; check for p1 to top slot
;
.nobldg		inc	t2		; make t2 nonzero
		tya			; get index
		and	#$f		; use lo nibble
		cmp	#$e		; cut off for bldg
		bcs	.out04		; =F
		lda	p1ys		; check for entry
		cmp	#DEAD
		beq	.skip21
		cmp	#TOP-$30	; for vert separation
		bcs	.out04
;
; look for first blank slot
;
.skip21		ldx	#$ff
.searchlp	inx
		cpx	#NULIST
		beq	.out04
		lda	p1ys,x
		cmp	#DEAD
		bne	.searchlp
; move list down onto blank slot
.wrslot		dex
		bmi	.skip20		; top slot empty
.downlp		lda	p1ys,x
		pha
		lda	hmovep1,x
		pha
		ldy	indirp1,x
		lda	p1dx,x
		inx
		sta	p1dx,x
		sty	indirp1,x
		pla
		sta	hmovep1,x
		pla
		sta	p1ys,x
		dex
		dex
		bpl	.downlp
; choose an identity
.skip20		ldx	#0		; point to top entry
		ldy	index
		lda	t2
		beq	.skip22
		jsr	p1ident		; it's p1
		jmp	.out10
.skip22		jsr	bdident
.out10		lda	#TOP-6
		sta	p1ys		; first slot
.out04		rts
;
; moving backward, find last entry
;
.bkward		ldy	index
		tya
		and	#$f
		cmp	#7
		bne	.dop1		; no building
		lda	indexlo
		cmp	#$e
		beq	.skip23		; no building
;
; don't put p1's near buildings
;
.dop1		lda	index
		and	#$f
		cmp	#7
		beq	.out05		; rts
		cmp	#8
		beq	.out05
		cmp	#9
		beq	.out05
;
		inc	t2		; make it a p1
;
; find last entry and write below it
;
.skip23		ldx	#NULIST-2
.lasloop	lda	p1ys,x
		cmp	#DEAD
		bne	.dowrite
		dex
		bpl	.lasloop
		lda	t2
		bne	.dop111
.dowrite	lda	t2		; if nonzero, do p1
		bne	.dop11
;
; building
;
		inx
		tya			; get index
		sec
		sbc	#7		; correct for bottom of screen
		tay
		jsr	bdident		; choose building identity
		jmp	.skip24
;
; check for room
;
.dop11
		lda	p1ys,x		; last nonzero entry
		cmp	#$20
		bcc	.out05		; no room
		cmp	#$f0
		bcs	.out05		; also no room
.dop111		inx			; point to new entry
		jsr	p1ident
.skip24		lda	#$f2		; bottom
		sta	p1ys,x
.out05		rts

;
; derive p1 characteristics
;
p1ident		subroutine
		jsr	random
		tay
		and	#$f
		cmp	#9
		bcc	.ok99		; 9 is max delay count
		ldy	#$55
.ok99		cmp	#0
		bne	.ok98
		iny
.ok98		sty	hmovep1,x
		jsr	random
		and	#$f
; weight god appearances
		cmp	#2		; weight gods
		bcs	.skip56
		bit	SWCHB		; check left diff
		bvs	.skip54
		lda	#0		; make more clones
		bvc	.skip56
.skip54		lda	#1		; make more thieves
.skip56
		tay
		cpy	#$f		; weight anubis and isis
		bne	.skip131
		lsr	randh
		bcs	.skip131
		iny
.skip131
		lda	p1ind,y
		sta	indirp1,x
		lda	#0
		sta	p1dx,x
		rts

;
; derive building  graphics and ypos
;
bdident		tya
		stx	t3
		lsr
		lsr
		lsr
		lsr
		tax
		lda	bldgind,x
		ldx	t3
		sta	indirp1,x	; first slot
		lda	(code),y
		and	#7
		tay
		lda	hmovtabl,y
		sta	hmovep1,x	; first slot
		rts

;
; clear subroutine
;
clear		subroutine
		ldx	#zeroend-zerost
		ldy	#<blank
		lda	#0
.zloop		sta	zerost,x
		sty	posses,x
		dex
		bpl	.zloop
;
		sta	frame+1
		ldx	#NULIST-1
		lda	#DEAD
.blnklp		sta	p1ys,x
		dex
		bpl	.blnklp
		stx	attrmask	; restore luminence
		lda	#$0d
		sta	index
		lda	#SANDCLR
		sta	sand
		rts
   
;
; data
;
; graphics
;
		align	256
sphinx		.byte	$00, $AB, $AB, $F8, $67, $75, $7F, $1F
		.byte	$03, $3B, $3E, $1E, $08, $0F, $07, $01
phoenix		.byte	$00, $01, $07, $03, $01, $01, $07, $0F
		.byte	$1F, $3F, $FD, $01, $03, $02, $01, $02
ra		.byte	$00, $FF, $AA, $AA, $AA, $AA, $FD, $7E
		.byte	$03, $01, $01, $02, $05, $05, $02, $01
oasis		.byte	$00, $1F, $07, $20, $20, $20, $20, $20
		.byte	$A4, $68, $B0, $74, $38, $D0, $2C, $00
temple		.byte	$00, $FF, $BB, $BA, $BA, $BA, $BB, $BB
		.byte	$BB, $BB, $BB, $BB, $BB, $11, $FF, $FF
pyramid		.byte	$00, $03, $0F, $3F, $FE, $7F, $3F, $1F
		.byte	$0F, $07, $03, $01, $04, $01, $01, $04
tomb		.byte	$00, $FF, $C6, $EE, $EE, $EE, $EF, $EF
		.byte	$ED, $EE, $C7, $FF, $C3, $C1, $82, $06
;
bldgs
;
anubis		.byte	$00, $6C, $4A, $4A, $7A, $72, $B2, $B2
		.byte	$BE, $F2, $62, $63, $F0, $DC, $70, $40
isis		.byte	$00, $28, $7C, $38, $38, $38, $38, $10
		.byte	$D0, $3C, $12, $28, $28, $28, $38, $38
super
;
thief		.byte	$00, $D8, $50, $50, $50, $70, $37, $32
		.byte	$74, $74, $FC, $BC, $78, $10, $30, $30
scorp		.byte	$00, $66, $81, $99, $7E, $3C, $7E, $3C
		.byte	$5A, $18, $18, $1A, $09, $09, $09, $06
;
;
clone		.byte	$00, $6C, $24, $2C, $38, $38, $7C, $9A
		.byte	$7A, $FA, $FE, $7C, $10, $38, $38, $38
p1s
palm		.byte	$00, $FF, $38, $10, $10, $10, $10, $10
		.byte	$10, $11, $92, $54, $39, $9E, $68, $06
smpyr		.byte	$00, $36, $24, $36, $24, $A4, $A4, $FE
		.byte	$FF, $FF, $7E, $3A, $12, $06, $07, $06
obelisk		.byte	$00, $7F, $3E, $1C, $1C, $1C, $1C, $1C
		.byte	$1C, $1C, $1C, $1C, $1C, $1C, $1C, $08

;
; table of found items
;
treatabl	.byte	<jug
		.byte	<elixir
		.byte	<shield
		.byte	<spade
		.byte	<elixir
		.byte	<scroll
		.byte	<spade
		.byte	<jug
; magical items
		.byte	<ankh
		.byte	<crown
		.byte	<crown
		.byte	<goblet
		.byte	<necklace
		.byte	<sceptre
		.byte	<ankh
		.byte	<disk

;
; color tables
;
;
		align	256
;COLORS		equ	$
colors
sphinxc		.byte	$00, $46, $46, $46, $46, $46, $46, $46
		.byte	$46, $46, $46, $46, $46, $46, $46, $46
phoenixc	.byte	$40, $42, $48, $48, $46, $46, $44, $44
		.byte	$42, $42, $40, $00, $44, $44, $44, $44
rac		.byte	$00, $B8, $B8, $B8, $B8, $B8, $2F, $B8
		.byte	$B8, $B8, $2F, $2F, $2F, $2F, $2F, $2F
oasisc		.byte	$00, $B6, $B6, $42, $44, $42, $44, $42
		.byte	$78, $78, $78, $78, $78, $78, $78, $78
templec		.byte	$00, $40, $44, $84, $28, $28, $28, $28
		.byte	$28, $28, $28, $28, $28, $28, $00, $44
pyramidc	.byte	$00, $00, $00, $00, $0A, $0A, $0A, $0A
		.byte	$0A, $0A, $0A, $0A, $2F, $2F, $2F, $2F
tombc		.byte	$00, $B8, $BC, $BC, $BC, $BC, $BC, $BC
		.byte	$BC, $BC, $BC, $B8, $B8, $B8, $B8, $B8
anubisc		.byte	$00, $28, $28, $28, $44, $44, $28, $28
		.byte	$28, $28, $28, $00, $00, $00, $00, $00
isisc		.byte	$00, $44, $B8, $B8, $B8, $B8, $B8, $B8
		.byte	$28, $28, $28, $00, $00, $00, $BF, $00
thiefc		.byte	$00, $28, $28, $28, $28, $28, $00, $00
		.byte	$28, $28, $28, $28, $28, $28, $28, $0F
scorpc		.byte	$00, $44, $44, $44, $00, $44, $00, $44
		.byte	$00, $44, $00, $00, $00, $00, $00, $00
clonec		.byte	$00, $28, $28, $28, $28, $44, $44, $28
		.byte	$28, $28, $28, $28, $28, $28, $28, $00
palmc		.byte	$00, $42, $44, $46, $44, $46, $44, $46
		.byte	$44, $34, $34, $34, $34, $34, $34, $34
smpyrc		.byte	$00, $44, $44, $44, $44, $44, $44, $44
		.byte	$44, $44, $46, $28, $44, $44, $44, $44
obeliskc	.byte	$00, $42, $2A, $46, $46, $46, $46, $46
		.byte	$46, $46, $46, $46, $46, $28, $2A, $2C

;
;
; list of tablets and cursor hmoves
;
tabletid	.byte	<tablet
		.byte	<scarab
		.byte	<bird

cursors		.byte	$32, $B2, $23, $A3, $14, $94
		.byte	$32, $B2, $23, $A3, $14, $94

;
; number set and 8x8 characters
;
		align	256
numbers
n0		.byte	$38,$6C,$44,$C6,$C6,$44,$6C,$38
n1		.byte	$6C,$38,$10,$10,$10,$10,$30,$10
n2		.byte	$7E,$30,$18,$0C,$06,$66,$6C,$38
n3		.byte	$7C,$C6,$46,$04,$1C,$46,$C6,$7C
n4		.byte	$0A,$04,$04,$FE,$C4,$64,$30,$18
n5		.byte	$FC,$86,$06,$06,$FC,$80,$9C,$F4
n6		.byte	$18,$3C,$66,$C6,$6C,$30,$18,$0C
n7		.byte	$A0,$E0,$60,$30,$18,$8C,$E2,$FE
n8		.byte	$7C,$C6,$C6,$7C,$7C,$C6,$44,$38
n9		.byte	$30,$18,$0C,$36,$62,$66,$3C,$18
colon		.byte	$30,$10,$18,$00,$30,$10,$18,$00
objects
; objects are sorted by their value (lower values first)
blank		.byte	$00,$00,$00,$00,$00,$00,$00,$00
staff		.byte	$80,$C0,$60,$34,$14,$1A,$0E,$06
jug		.byte	$7C,$FE,$F6,$F6,$6C,$38,$38,$7C
elixir		.byte	$C0,$B0,$6C,$52,$2A,$26,$1E,$02
key		.byte	$10,$18,$18,$10,$10,$38,$44,$38
shield		.byte	$10,$38,$6C,$6C,$54,$6C,$6C,$7C
scroll		.byte	$FE,$6C,$54,$7C,$6C,$54,$6C,$FE
spade		.byte	$10,$38,$38,$10,$10,$10,$10,$10
ltreas
tablet		.byte	$FE,$92,$B6,$86,$82,$68,$F2,$7C
scarab		.byte	$FE,$BA,$C6,$D6,$D6,$C6,$AA,$7C
bird		.byte	$FE,$CE,$EC,$E2,$C6,$2E,$DE,$7C
ankh		.byte	$10,$10,$10,$7C,$10,$28,$44,$38
crown		.byte	$7C,$D6,$28,$54,$BA,$BA,$92,$44
goblet		.byte	$00,$38,$10,$10,$10,$38,$7C,$7C
necklace	.byte	$10,$38,$44,$00,$82,$00,$44,$10
disk		.byte	$00,$38,$54,$BA,$EE,$BA,$54,$38
sceptre		.byte	$00,$10,$10,$10,$10,$38,$54,$D6
htreas
speedmsk	.byte	$01,$03,$03,$07,$07,$07,$0F,$1F

;
; lo bytes of 8 p0's
;
p0ind
		.byte	<palm
		.byte	<palm
		.byte	<obelisk
		.byte	<palm
		.byte	<palm
		.byte	<smpyr
		.byte	<smpyr
		.byte	<obelisk

;
; lo bytes of 16 building graphics
;
bldgind
		.byte	<oasis
		.byte	<pyramid
		.byte	<oasis
		.byte	<phoenix
		.byte	<oasis
		.byte	<tomb
		.byte	<oasis
		.byte	<pyramid
		.byte	<palm
		.byte	<temple
		.byte	<palm
		.byte	<pyramid
		.byte	<oasis
		.byte	<sphinx
		.byte	<oasis
		.byte	<ra
		
;
; services - don't cross page boundary
;
		align	256
services
;
; building services
;
itemserv	cmp	#<jug
		bne	skip110
		lda	#ANLOCK
		bne	open		; always
skip110		cmp	#<crown
		bne	badout
;
givekey		lda	#<key
		jsr	givest
		ldx	curpos
		bpl	togdout
;
atemserv	cmp	#<shield
		bne	skip111
		lda	#SXLOCK
		bne	open
skip111		cmp	#<ankh
		bne	badout
;
togkey		beq	givekey
;
sxserv		ldy	riddle 
		cmp	tabletid,y
		bne	badout
		lda	#ENDLOCK
totogood	sta	lockix
;
togdout		lda	#<blank
		sta	posses,x
		lda	#0
		sta	thirst       
		sta	wounds
;
; exits for p1 services
;
goodout		lda	#5
		ldx	#1
		stx	v1point
		jsr	addm
		lda	#$20
		sta	v1time
		bne	return
badout		lda	#$20
		jsr	subtract
		bne	return
open		ldy	version
		cpy	#2		; version 3 ?
		bne	return
		beq	totogood
;
pyrserv
		cmp	#<key
		bne	badout
		lda	#<blank
		sta	posses,x
;
		ldy	#2
pyrloop1	lda	tabletid,y
		sty	t0
		jsr	givest
		bcs	return
		ldy	t0
		dey
		bpl	pyrloop1
;
oaserv		lda	#0
		sta	thirst
		lda	#4
		sta	v1point
		lda	#7
		sta	v1time
		bne	return
phoeserv	cmp	#<elixir
		bne	skip112
		lda	#ISLOCK
		bne	open
skip112		cmp	#<scroll
		bne	badout
		lda	#0
		sta	wounds
		beq	togkey
return		jmp	indiret		; go back
isisserv	sec
		jsr	give
		bcs	skip74
		sec
		jsr	give
skip74
		lda	#0
		sta	thirst
		sta	wounds
		ldx	t2
		lda	#DEAD
		sta	p1ys,x
		bne	return
thserv		jsr	steal
		inc	wounds
		bne	return
clserv		clc
		jsr	give
		bcs	skip57
		jsr	give		; if unsuccessful, try again
		bcs	return
		lda	randl
		lsr
		bcc	thserv		; steal if can't give
skip57
toret		jmp	return
scorserv	cmp	#<necklace
		beq	return
doscorp		inc	wounds
		inc	wounds
tobadout	jmp	badout
anuserv		inc	wounds
		bne	doscorp
raserv		ldy	version
		beq	skip66
		cmp	#<staff
		bne	tobadout 
;
skip66
noreturn	ldx	#11
raloop		lda	posses,x
		cmp	#<htreas
		bcs	next04
		cmp	#<ltreas
		bcs	rascore
next04		dex
		bpl	raloop
		lda	#ENDCLR
		sta	sand
		lda	#5
		sta	status
		ldx	curpos
		lda	#<blank
		sta	posses,x
		bne	toret
;
rascore		lda	#<blank
		sta	posses,x
		lda	#7
		ldx	#1		; mid byte
		jsr	addm
		lda	#$e0
		sta	frame
		lda	#$c
		sta	AUDC0
		lda	#4
		sta	AUDF0
		lda	#knocke-knock
		sta	v0point       
		bne	toret		; always taken
       
logotabl	.byte	<im6, <im5, <im4, <im3, <im2, <im1
;
;
hmovtabl	.byte	$E1, $E2, $E3, $E4, $E5, $E6, $E7, $E8
;
;
; knock volume envelope
knock		.byte	$00, $02, $05, $03, $08, $05, $0C
knocke		.byte	$0C
;
; imagic copyright 1982 data
; data is 8 lines high
; and is stored backwards
; im1 represents the leftmost data
;
; im2 through im5 use the first line of the
; next character for their last line.
;
logo
im1		.byte	$38, $44, $92, $A2, $A2, $92, $44, $38
im2		.byte	$00, $45, $45, $45, $5D, $55, $5D
im3		.byte	$00, $DC, $50, $50, $DC, $44, $DC
im4		.byte	$00, $AA, $AA, $AA, $AA, $AA, $94
im5		.byte	$00, $93, $94, $F5, $94, $94, $63
im6		.byte	$00, $26, $A9, $A8, $28, $A9, $26, $00

;
; object services
;
		align	16
oservice

jugserv		sta	posses,x	; remove from possession list
gobserv		lda	#0		; set thirst to zero
		sta	thirst
		beq	snd18		; always taken
		
elixserv	sta	posses,x	; remove from possession list
diskserv	lda	#0		; heal all wounds
		sta	wounds
		beq	snd18		; always taken
		
spadserv	lda	index
		cmp	lastdig		; same place as last time ?
		beq	snd18		; yes -> no success
		sta	lastdig		; save new dig position
		lda	randl
		bit	SWCHB		; give more for b difficulty
		bvs	skip58
		asl			; happen more often
skip58
		and	#3
		bne	snd18		; no success
		lda	#<blank		; remove spade from possession list
		sta	posses,x
		sec			; give magical object
		jsr	give
		bcs	snd18		; success -> ok
		lda	#<spade		; duplicate given -> put spade
		ldx	curpos		; back into possession list
		sta	posses,x
		bpl	snd19
snd18
		lda	v1point
		bne	out18
snd19
		lda	#4
		sta	v1point
		lda	#$f
		sta	v1time
out18
		jmp	return2

;
; steal most valuable item
;
steal		subroutine
		ldx	#11		; x = loop counter/index
		stx	v1time
		stx	t0		; t0 = highest value found so far
.steallp	lda	posses,x	; get item from possession list
		cmp	#<shield	; steal shield before everything else
       		beq	.takechar
       		cmp	t0		; new highest value found ?
       		bcc	.next		; nope -> continue
       		stx	t1		; yes -> save index of this object
       		sta	t0		; save new highest value
.next
		dex			; next item
		bpl	.steallp

		ldx	t1		; get index of most valuable item
.takechar
		lda	#<blank		; delete item from possession list
		sta	posses,x
		lda	#2
		sta	v1point
		lda	#0		; no shield -> set counter to 0
		sta	shcount
		rts

; lo bytes of object service handler addresses
objservs
		.byte	#<out18		; normal services
		.byte	#<out18
		.byte	#<jugserv
		.byte	#<elixserv
		.byte	#<out18
		.byte	#<out18
		.byte	#<out18
		.byte	#<spadserv
		.byte	#<out18		; magical services & tablets
		.byte	#<out18
		.byte	#<out18
		.byte	#<out18
		.byte	#<out18
		.byte	#<gobserv
		.byte	#<out18
		.byte	#<diskserv
		.byte	#<out18

;
; random number generator
;
random		subroutine
		lda	randh
		lsr
		eor	randh
		lsr
		rol	randl
		ror	randh
		lda	randl
		rts

p0hms		.byte	$60, $E0

;
; lo bytes of 17 p1's
;
p1ind
		.byte	<clone
		.byte	<thief
		.byte	<thief
		.byte	<clone
		.byte	<scorp
		.byte	<thief
		.byte	<thief
		.byte	<thief
		.byte	<thief
		.byte	<clone
		.byte	<scorp
		.byte	<thief
		.byte	<thief
		.byte	<clone
		.byte	<scorp
		.byte	<anubis
		.byte	<isis

;
; vectors
;
		org	ORIGIN + $ffc
vectors
		.word	start
		.word	start
