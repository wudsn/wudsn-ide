; Test
	.proc unusedproc ;Unused procedure
	nop
	.endp

	org $2000
included
	jmp unknownIncludeLabel

	