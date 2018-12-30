;	MADS Example for for C64 
;	@com.wudsn.ide.asm.hardware=C64
;

	opt h-f+	;Disable ATARI headers, enable fill mode (no memory gaps)

	org $0801-2
	.word load	;BASIC load address

load	.word nextline	;BASIC Tokens for "10 SYS2061"
	.word 10
	.byte $9e, '2061', 0
nextline
	.word 0

start	inc $d021	;start = $080d = 2061
	dec $d020
	jmp start
