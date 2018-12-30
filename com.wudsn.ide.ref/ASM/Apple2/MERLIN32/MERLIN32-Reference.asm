;	Reference source file for MERLIN32.
;	Based on MERLIN32-Mnemonics.txt.

;	Single line comment
*	Single line comment

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

;	6502 Pseudo Opcodes
	BLT
	BGE

;	65C02 Opcodes
	BRA
	PHX
	PHY
	PLX   
	PLY
	STP
	STZ
	TRB
	TSB
	WAI

;	65816 Opcodes
	BRL
	COP
	JML
	JSL
	MVN
	MVP
	PEA
	PEI
	PER
	PHB
	PHD
	PHK
	PLB 
	PLD
	REP
	RTL
	SEP
	TCD
	TCS
	TDC 
	TSC
	TXY
	TYX
	WDM
	XBA
	XCE

;	65816 long variants of accumulator and jump opcodes
	ADCL
	ANDL
	CMPL
	EORL
	JMPL
	LDAL
	ORAL
	SBCL
	STAL

;	Directives: a65816_Code.c, a65816_Cond.c, a65816_Data.c, a65816_File.c, a65816_Line.c, a65816_Link.c, a65816_Lup.c, a65816_Macro.c, Dc_Library.c
	ADR
	ADRL
	ALI
	ASC 'ASCII'
	ASM
	AUX
	CHK
	DA
	DAT
	DB
	DCI 
	DDB $1234
	DEND
	DFB
	DO
	DS
	DSK 'include/MERLIN32-Reference-Binary-Output.bin'
	DUM $8000
	DW
	ELSE
	END
	ENT
	ERR
	EQU
	EXT
	FIN
	FLS 'ASCII'
	HEX
	IF
	INV 'ASCII'
	KND
	LNA
	LNK
	LUP
	MX
	ORG
	PMC
	PUT
	PUTBIN
	REL
	REV 'ASCII'
	SAV
	SNA 'SEGMENT1'
	STR 'ASCII'
	STRL 'ASCII'
	TYP $06
	USE
	XPL

;	Hyperlink relevant directives and pseudo opcodes
	ASM 'include/MERLIN32-Reference-Source-Include-Compiling'	;Suffix ".s" appened automatically
	ASM 'include/MERLIN32-Reference-Source-Include-Compiling.s'
	USE 'include/MERLIN32-Reference-Source-Include-Compiling'	;Suffix ".s" appened automatically
	USE 'include/MERLIN32-Reference-Source-Include-Compiling.s'
	PUT 'include/MERLIN32-Reference-Source-Include-Compiling'	;Suffix ".s" appened automatically
	PUT 'include/MERLIN32-Reference-Source-Include-Compiling.s'
	PUTBIN 'include/MERLIN32-Reference-Binary-Include.bin'
	DSK 'include/MERLIN32-Reference-Binary-Output.bin'
	LNK 'include/MERLIN32-Reference-Binary-Output.bin'
	SAV 'include/MERLIN32-Reference-Binary-Output.bin'
