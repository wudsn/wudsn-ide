;	WUDSN IDE example MADS source file

	org $2000	;Start of code block

start	lda #0		;Disable screen DMA
	sta 559

loop	lda $d40b	;Load VCOUNT
	sta $d40a
	sta $d01a	;Change background color
	jmp loop
        
a        .macro 
	.endm
        
	run start	;Define run address

b	.macro
	.endm
	
	
	org $1000	;Start of code block