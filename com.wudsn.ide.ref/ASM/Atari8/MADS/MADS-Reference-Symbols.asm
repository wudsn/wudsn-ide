;	Reference source file for MADS symbols

	org $2000

	.macro m_macro
m_label1
	lda #1
	.endm

equate1 = 1	
equate2 = equate1+1

label1	lda #1
label2	sta $80


//	$FFF9   label for parameter in procedure defined by .PROC
//	TODO: Missing in .lab file
	.proc parameter_procedure( .byte byte1 .word word1  ) .var
	.var inner_var .byte
	.endp

//	$FFFA   label for array defined by .ARRAY
//	TODO: Actually results in $FFF8 instead in .lab file
array1	.array
	.enda

// 	$FFFB   label for structured data defined by the pseudo-command DTA STRUCT_LABEL	
structure_data	dta inner_structure [12]

//	$FFFC   label for SpartaDOS X symbol defined by SMB
//	Actually results in $FFFB instead in .lab file
smb_symbol	smb
	jmp SMB_symbol
	
//	$FFFD   label for macro defined by .MACRO directive
	m_macro

//	$FFFE   label for structure defined by .STRUCT directive
	.struct inner_structure
	x .word
	y .word
	.ends
	
	.struct outer_structure
	structure inner_structure
	.ends


//	$FFFF   label for procedure defined by .PROC directive
	.local outer_local
	.local inner_local
	.byte 0
	.endl
	.byte 0
	.endl

	.proc outer_procedure	
	.proc inner_procedure
	rts
	.endp
	rts
	.endp
	