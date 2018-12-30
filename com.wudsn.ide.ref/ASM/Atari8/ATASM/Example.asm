;	WUDSN IDE example ATASM source file
;
;	Support for hyperlink navigation to source includes.
;	Absolute and relative file paths are supported.
	.include "..\Macros.inc"
;
sound	= $5000		;Sound module
*	= sound		;Start of data block
 
 
;	Support for hyperlink navigation to binary includes.
;	Absolute and relative file paths are supported.
label	.incbin "C:\jac\system\Atari800\Programming\IDE\REF\ATASM\Example.bin"

*	= $2000		;Start of code block
	.opt ILL	;Enable use of illegal opcodes


start	lda #0		;Disable screen DMA
	sta 559

loop	lda $d40b	;Load VCOUNT
	anc #12		;Illegal opcode
	sta $d40a
	sta $d01a	;Change background color
	jmp loop1

*	= $2e0		;Define run address
	.word start