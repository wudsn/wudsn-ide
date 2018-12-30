/*---------------------------------------------------------------
  					KOALA SHOWER

This code displays the Koala picture in the file picture.prg
---------------------------------------------------------------*/


	.var picture = LoadBinary("picture.prg", BF_KOALA)

	:BasicUpstart2(start)

start:
	lda #$38
	sta $d018
	lda #$d8
	sta $d016
	lda #$3b
	sta $d011
	lda #0
	sta $d020
	lda #picture.getBackgroundColor()
	sta $d021
	ldx #0
!loop:
	.for (var i=0; i<4; i++) {
		lda colorRam+i*$100,x
		sta $d800+i*$100,x
	}
	inx
	bne !loop-
	jmp *

	.pc = $0c00	"ScreenRam" 			.fill picture.getScreenRamSize(), picture.getScreenRam(i)
	.pc = $1c00	"ColorRam:" colorRam: 	.fill picture.getColorRamSize(), picture.getColorRam(i)
	.pc = $2000	"Bitmap"				.fill picture.getBitmapSize(), picture.getBitmap(i)




