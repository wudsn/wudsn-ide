	.pc = $1000 "Main Program"

.var somePic = LoadPicture("KICKASS-Test-16x16.gif")

more:	lda #1
	sta $d021
	jmp *
