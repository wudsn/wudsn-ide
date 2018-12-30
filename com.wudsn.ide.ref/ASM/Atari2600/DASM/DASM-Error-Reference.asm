;	Error reference source file for DASM

;	@com.wudsn.ide.asm.hardware=ATARI2600
	processor 6502

	seg 
	org $2000
	
	include "include/DASM-Reference-Source-Include.asm"
	
	jmp unknownLabel

