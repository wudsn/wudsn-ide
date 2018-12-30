;	Reference source file for MADS

;	Single line comment
//	Single line comment
*	Single line comment

/*
	Multiple lines comment
*/

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
	BRA
	BRL
	COP
	DEA
	INA
	JML
	JSL
	MVN
	MVP
	PEA
	PEI
	PHB
	PHD
	PHK
	PHX
	PHY
	PLB 
	PLD
	PLX   
	PLY
	REP
	RTL
	SEP
	STP
	STZ
	TCD
	TCS
	TDC 
	TRB
	TSB
	TSC
	TXY
	TYX
	WAI
	WDM
	XBA
	XCE


;	Illegal opcodes

;	XASM Directives also supported by MADS
	DTA
	EIF
	ELI
	ELS
	END
	EQU
	ERT 
	ICL 
	IFT
	INI
	INS 
	OPT
	ORG
	RUN

;	XASM Pseudo Opcodes also supported by MADS
	ADD
	INW
	JCC
	JCS
	JEQ
	JMI
	JNE
	JPL
	JVC
	JVS
	MVA
	MVX
	MVY
	MWA
	MWX
	MWY
	RCC
	RCS 
	REQ
	RMI
	RNE
	RPL
	RVC
	RVS
	SCC
	SCS
	SEQ
	SMI
	SNE
	SPL
	SUB
	SVC
	SVS	

;	MADS Directives, XASM style
	BLK
	EXT
	LMB
	NMB
	RMB
	RND
	SIN
	SMB

;	MADS Directives, starting with "."
	.ADR
	.AEND
	.ALIGN
	.AND
	.ARRAY
	.BY
	.BYTE
	.DB
	.DEF
	.DS
	.DW
	.DWORD
	.ECHO
	.EEND
	.ELIF
	.ELSE
	.ELSEIF
	.EN
	.END
	.ENDA
	.ENDE
	.ENDIF
	.ENDL
	.ENDM
	.ENDP
	.ENDPG
	.ENDR
	.ENDS
	.ENDT
	.ENDW
	.ENDW
	.ENUM
	.ERROR
	.EXIT
	.EXTRN
	.FL
	.GET
	.GLOBAL
	.GLOBL
	.HE
	.HI
	.IF
	.IFDEF 
	.IFNDEF
	.LEN
	.LEND
	.LINK
	.LO
	.LOCAL
	.LONG
	.MACRO
	.MEND
	.NOT
	.OR
	.PAGES
	.PEND
	.PGEND
	.PRINT
	.PROC
	.PUBLIC
	.PUT
	.REG
	.RELOC
	.REND
	.REPT
	.SAV
	.SB
	.SEND
	.STRUCT
	.SYMBOL
	.TEND
	.TEST
	.USE
	.USING
	.VAR
	.WEND
	.WHILE
	.WO
	.WORD
	.XOR
	.ZPVAR

;	MADS Pseudo Opcodes, XASM style 
	ADB
	ADW
	CPB
	CPD
	CPL
	CPW
	DED
	DEL
	DEW
	IND
	INL
	PHR
	PLR
	SBB
	SBW

;	MADS Pseudo Opcodes, starting with "#"
	#ELSE
	#END
	#IF
	#WHILE

 
;	Hyperlink relevant directives and pseudo opcodes
	ICL "include/MADS-Reference-Source-Include"		;Suffix ".asm" appended automatically
	ICL "include/MADS-Reference-Source-Include.asm"
	INS "include/MADS-Reference-Binary-Include.bin"
	.SAV "MADS-Reference-Binary-Output.bin"
	
