;	WUDSN IDE example ATASM source file
;	Supports hyperlink navigation includes.
	.include "..\Macros.inc"
	  
*	= $2000		;Start of code
	.opt ILL	;Enable use of illegal opcodes

	.if as 
start	sei		;Run address
loop	lda $d40b	;Load VCOUNT
	anc #12		;Illegal opcode
	sta $d40a
	sta $d01a	;Change background color
	jmp loop1
 
*	= $2e0		;Set run address
	.word start
	