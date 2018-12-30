;	Reference source file for MADS

;	Single line comment
//	Single line comment
*	Single line comment

/*
	Multiple lines comment
*/
	
	ORG $1000
	OPT c+

;	6502 Opcodes
	ADC #1
	AND #1
	ASL
	BCC *
	BCS *
	BEQ *
	BIT 1
	BMI *
	BNE *
	BPL *
	BRK
	BVC *
	BVS *
	CLC
	CLD
	CLI
	CLV
	CMP #1
	CPX #1
	CPY #1
	DEC 1
	DEX
	DEY
	EOR #1
	INC 1
	INX
	INY
	JMP *
	JSR *
	LDA #1
	LDX #1
	LDY #1
	LSR
	NOP
	ORA #1
	PHA
	PHP
	PLA
	PLP
	ROL
	ROR
	RTI
	RTS
	SBC #1
	SEC
	SED
	SEI
	STA 1
	STX 1
	STY 1
	TAX
	TAY
	TSX
	TXA
	TXS

;	65816 opcodes
	BRA *
	BRL *
	COP #1
	DEA
	INA
	JML *
	JSL *
	MVN 1,1
	MVP 1,1
	PEA *
//	PEI *	;	?MISSING iN MADS?
	PHB
	PHD
	PHK
	PHX
	PHY
	PLB 
	PLD
	PLX   
	PLY
	REP #1
	RTL
	SEP #1
	STP
	STZ 1
	TCD
	TCS
	TDC 
	TRB 1
	TSB 1
	TSC
	TXY
	TYX
	WAI
	WDM
	XBA
	XCE


;	Illegal opcodes

;	XASM Directives also supported by MADS
	DTA 1
	IFT 1
	ELI
	ELS
	EIF
;	END

equate	EQU 1
;;	ERT "Test Error  ", 2
	ICL "include/MADS-Reference-Source-Include-Compiling.asm"
	ICL "include/MADS-Reference-Source-Include-Compiling"

	INI *
	INS  "include/MADS-Reference-Binary-Include.bin"
	OPT
	ORG *
	RUN *

;	XASM Pseudo Opcodes also supported by MADS
	ADD #1
	INW 1
	JCC *
	JCS *
	JEQ *
	JMI *
	JNE *
	JPL *
	JVC *
	JVS *
	MVA 1 1
	MVX 1 1
	MVY 1 1
	MWA 1 1
	MWX 1 1
	MWY 1 1
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
	SUB #1
	SVC
	SVS

;	MADS Directives, XASM style 
extern	EXT .BYTE
sdx	SMB "sdx"
	BLK N 1
	DTA A(SIN(0,1000,256,0,63))
	DTA b(RND(0,33,256))
	NMB
	RMB
	LMB #1

;	MADS Directives, starting with "."
	.BYTE 1
	.HE .ADR label1
	.ARRAY label2 [1] .BYTE
	.AEND
	.ALIGN
	#IF .BYTE 1 .AND 1
	.IF 1
// .ELIF ??
	.ELSEIF
	.ELSE
	.BY
	.BYTE
	.DB
	.DEF def
	.DS 1
	.DW 1
	.DWORD 1
	.ECHO 1
	
	.ENDA
	.ENDE
	.ENDIF
	
	.ENDT
	.ENUM enum
	.EEND // END ENUM 
	
	.IF 1 = 0
	.ERROR "Test"
	.ENDIF
	
	.MACRO macro1
	.EXIT
	.ENDM

	.EXTRN extern .BYTE
	.FL
	.GET "include/MADS-Reference-Binary-Include.bin"
	.GLOBAL
	.GLOBL
	.HE 1 .HI, .LEN proc, 1 .LO, 1 .NOT, 1 .OR 1

	.LINK "include/MADS-Reference-Link-Include.bin"
 
local1	.LOCAL
	.ENDL
local2	.LOCAL
	.LEND

	.LONG
	
	.MACRO macro2
	.ENDM
	.MACRO macro3
	.MEND

	.PAGES $10
	.ENDPG
	.PAGES $12
	.PGEND
	
	.PROC proc1
	.ENDP
	.PROC proc2
	.PEND
	.PRINT

	.PUBLIC
	.PUT
	.REG

repeat1	.REPT 1

	.ENDR
repeat2	.REPT 1
	.REND

	.SAV "MADS-Reference-Save.bin",1
	.SB 1
	.STRUCT struct1
	.SEND
	.STRUCT struct2
	.ENDS
	.TEST .BYTE 1>1
	.TEND
	.USE
	.USING
	.VAR var1 = 1 .BYTE
	.WHILE .byte 1>1
	.WEND
	.WHILE .byte 1>1
	.ENDW
	.WO
	.WORD 1 .XOR 1
	.ZPVAR var2 = 1 .BYTE

;	.RELOC .BYTE 1
;symbol	.SYMBOL
	

;	MADS Pseudo Opcodes, XASM style 
	DEL 1
	DED 1   
	DEW 1
	ADW 1 #1
	SBW 1 #1
	PHR
	PLR 
	ADB 1 #1
	SBB 1 #1
	INL 1
	IND 1
	CPB 1 #1
	CPW 1 #1
	CPL 1 #1
	CPD 1 #1

;	MADS Pseudo Opcodes, starting with "#"
	#IF .BYTE 1
		nop
	#ELSE
		nop
	#END
	#WHILE .BYTE 1
		nop
	#END


;	Hyperlink relevant directives and pseudo opcodes
	ICL 'include/MADS-Reference-Source-Include-Compiling.asm'
	INS 'include/MADS-Reference-Binary-Include.bin'
	.GET 'include/MADS-Reference-Binary-Include.bin'
;	.LINK 'MADS-Reference-Link-Include.bin'		;COM format
	.SAV 'MADS-Reference-Save.bin',1

	ICL "include/MADS-Reference-Source-Include-Compiling"		;Suffix ".asm" appened automatically
	ICL "include/MADS-Reference-Source-Include-Compiling.asm"
	INS "include/MADS-Reference-Binary-Include.bin"
	.GET "include/MADS-Reference-Binary-Include.bin"
;	.LINK "MADS-Reference-Link-Include.bin"		;COM format
	.SAV "include/MADS-Reference-Save.bin",1

;	End block or assembly
	.EN
	.END
