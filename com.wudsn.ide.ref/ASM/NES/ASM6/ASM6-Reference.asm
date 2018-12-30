;	Reference source file for ASM6

;	Single line comment


;	6502 Opcodes
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
	BASE
	BIN
	BYTE
	DB
	DC.B
	DC.W
	DH
	DL
	DS.B
	DS.W
	DSB
	DSW
	DW
	ELSE
	ELSEIF
	ENDE
	ENDIF
	ENDM
	ENDR
	ENUM
	EQU
	ERROR
	FILLVALUE
	HEX
	IF
	IFDEF
	IFNDEF
	INCBIN
	INCLUDE
	INCSRC
	MACRO
	ORG
	PAD
	REPT
	WORD

;	Pseudo Opcodes
	
	
;	Hyperlink relevant directives and pseudo opcodes
	INCLUDE "include/ASM6-Reference-Source-Include.asm"
	INCSRC "include/ASM6-Reference-Source-Include.asm"
	INCBIN "include/ASM6-Reference-Binary-Include.bin"
	BIN  "include/ASM6-Reference-Binary-Include.bin"

