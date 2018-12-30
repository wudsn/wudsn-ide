;	Reference source file for ATASM

;	Single line comment

;	Opcodes
	ADC
	AND
	ASL
	BCC
	BCS
	BEQ
	BIT
	BMI
	BNE
	BPL
	BRK
	BVC
	BVS
	CLC
	CLD
	CLI
	CLV
	CMP
	CPX
	CPY
	DEC
	DEX
	DEY
	EOR
	INC
	INX
	INY
	JMP
	JSR
	LDA
	LDX
	LDY
	LSR
	NOP
	ORA
	PHA
	PHP
	PLA
	PLP
	ROL
	ROR
	RTI
	RTS
	SBC
	SEC
	SED
	SEI
	STA
	STX
	STY
	TAX
	TAY
	TSX
	TXA
	TXS

;	65816 opcodes
	COP
	XCE

;	Illegal opcodes
	ANC
	ARR
	ATX
	AXS
	AX7
	AXE
	DCP
	ISB
	JAM
	LAS
	LAX
	RLA
	RRA
	SAX
	SLO
	SRE
	SXA
	SYA
	XAS
	
;	Directives
	.AND
	.BANK
	.BANKNUM
	.BYTE
	.CBYTE
	.DBYTE
	.DEF
	.DC
	.DS
	.ELSE
	.END
	.ENDIF
	.ENDM
	.ENDR
	.ERROR
	.FLOAT
	.IF
	.INCBIN
	.INCLUDE
	.LOCAL
	.MACRO
	.NOT
	.OPT
	.OR
	.PAGE
	.REF
	.REPT
	.SBYTE
	.SET
	.TAB
	.TITLE
	.WARN
	.WORD

;	Pseudo Opcodes
	BGE
	BLT

;	Hyperlink relevant directives and pseudo opcodes
	.INCLUDE "include/ATASM-Reference-Source-Include.asm"
	.INCBIN "include/ATASM-Reference-Binary-Include.bin"
