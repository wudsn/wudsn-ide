;	Error reference source file for ATASM
;
;	Label "unknownLabel" is undefined but used in this file.
;	Label "unknownIncludeLabel" is undefined but used in the included file.

;	@com.wudsn.ide.asm.hardware=ATARI8BIT

*	= $2000

	.include "include/ATASM-Reference-Source-Include.asm"
	
	jmp unknownLabel

