;	Error reference source file for ASM6

;	@com.wudsn.ide.asm.hardware=NES

dummy1	= dummy2

	org $2000
	
	INCLUDE "include/ASM6-Reference-Source-Include.asm"
	
	jmp unknownLabel

dummy2
