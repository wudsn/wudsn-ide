

	.pc =$0801 "Basic Upstart Program"
	:BasicUpstart($0810)

//---------------------------------------------------------
//---------------------------------------------------------
//			2x2 Scroll
//---------------------------------------------------------
//---------------------------------------------------------
	.var music = LoadSid("My_Glamrous_Life.sid")
	.pc = $0810 "Main Program"
	
	ldx #0
!loop:
	.for(var i=0; i<4; i++) {
		lda #$20
		sta $0400+i*$100,x
		lda #$0f
		sta $d800+i*$100,x
	}
	inx
	bne !loop-

	lda #$00
	sta $d020
	sta $d021
	ldx #0
	ldy #0
	lda #music.startSong-1
	jsr music.init	
	sei
	lda #<irq1
	sta $0314
	lda #>irq1
	sta $0315
	asl $d019
	lda #$7b
	sta $dc0d
	lda #$81
	sta $d01a
	lda #$1b
	sta $d011
	lda #$80
	sta $d012
	cli
this:	jmp this
//---------------------------------------------------------
irq1:
	asl $d019
	inc $d020
	jsr music.play 
	inc $d020
	jsr scroll 
	
	lda #$c0
	ora scroll_xpos
	sta $d016
	lda #$1e
	sta $d018

	lda #0			
	sta $d020
	pla
	tay
	pla
	tax
	pla
	rti

//---------------------------------------------------------
	.var scroll_screen = $0400

scroll:
	lda scroll_xpos
	sec
	sbc scroll_speed
	and #$07
	sta scroll_xpos
	bcc !moveChars+
	rts
!moveChars:
	// Move the chars
	ldx #0
!loop:
	lda scroll_screen+1,x
	sta scroll_screen,x
	lda scroll_screen+1+40,x
	sta scroll_screen+40,x
	inx
	cpx #40
	bne !loop-
	
	// print the new chars
!txtPtr: lda scroll_text
	cmp #$ff
	bne !noWrap+
	lda #<scroll_text
	sta !txtPtr-+1
	lda #>scroll_text
	sta !txtPtr-+2
	jmp !txtPtr-
!noWrap:
	ora scroll_charNo
	sta scroll_screen+39
	clc
	adc #$40	
	sta scroll_screen+39+40
	
	// Advance textpointer
	lda scroll_charNo
	eor #$80
	sta scroll_charNo
	bne !over+
!incr:
	inc !txtPtr-+1
	bne !over+
	inc !txtPtr-+2
!over:
		
	rts
scroll_xpos: .byte 0
scroll_speed: .byte 2
scroll_charNo: .byte 0


scroll_text:
	.text "hello world.. here is a scroll with a converted charset. the charset was "
	.text "drawn by trifox who asked how to convert it on csdb. this is a quick example of "
	.text "how it can be done in kick assembler... .. .. .   .  . "
	.byte $ff
//---------------------------------------------------------
	.pc = music.location "Music"
	.fill music.size, music.getData(i)
//---------------------------------------------------------

	.pc = $3800
	.var charsetPic = LoadPicture("2x2char.gif", List().add($000000, $ffffff))
	.function picToCharset(byteNo, picture) {
		.var ypos = [byteNo&7] + 8*[[byteNo>>9]&1] 
		.var xpos = 2*[[byteNo>>3]&$3f] + [[byteNo>>10]&1]
		.return picture.getSinglecolorByte(xpos,ypos)		
	}
	.fill $800, picToCharset(i,charsetPic)

