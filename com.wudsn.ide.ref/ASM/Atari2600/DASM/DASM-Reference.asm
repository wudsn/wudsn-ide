;	Reference source file for DASM

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

;	Illegal opcodes
	ANC
	ANE
	ARR
	DCP
	ISB
	LAS
	LAX
	LXA
	RLA
	RRA
	SAX
	SBX
	SHA
	SHS
	SHX
	SHY
	SLO
	SRE

	
	
;	Directives
	ALIGN
	BYTE
	DC
	DC.B
	DC.L
	DC.W
	DS
	DS.B
	DS.L
	DS.W
	DV
	DV.B
	DV.L
	DV.W
	ECHO
	EIF
	ELSE
	END
	ENDIF
	ENDM
	EQM
	EQU
	ERR
	HEX
	IF
	IFCONST
	IFNCONST
	INCBIN
	INCDIR
	INCLUDE
	LIST
	LONG
	MAC
	MEXIT
	ORG
	PROCESSOR
	REND
	REPEAT
	REPEND
	RORG
	SEG
	SEG.U
	SET
	SUBROUTINE
	WORD

;	Pseudo Opcodes

;	Hyperlink relevant directives and pseudo opcodes
	INCDIR "."
	INCLUDE "include/DASM-Reference-Source-Include.asm"
	INCBIN "include/DASM-Reference-Binary-Include.bin"
	
