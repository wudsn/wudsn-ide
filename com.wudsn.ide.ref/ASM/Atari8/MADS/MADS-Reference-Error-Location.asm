;	Error reference source file for MADS
;
;	Label "unknownLabel" is undefined but used in this file.
;	Label "unknownIncludeLabel" is undefined but used in the included file.

;	@com.wudsn.ide.asm.hardware=ATARI8BIT

	org $2000
	
	ICL "include/MADS-Reference-Source-IncludE.asm"

	jmp unknownLabel

