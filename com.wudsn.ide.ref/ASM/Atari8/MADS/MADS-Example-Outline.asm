;	Example source file for MADS

newlabel = 1
colbak	= $d01a		;Background color
mode	= 1+2*3		;Test mode

	ORG $1000	;First implementation section

;	Support for hyperlink navigation to source includes, optionally without default extension
;	Absolute and relative file paths are supported.
	ICL "include/MADS-Reference-Source-Include.asm"	;Source include
	ICL "include/MADS-Reference-Source-Include"	;Source include without default extension


;	Support for hyperlink navigation to binary includes.
;	Absolute and relative file paths are supported.
	INS "include/MADS-Reference-Binary-Include.bin"	;Binary include
	.GET "include/MADS-Reference-Binary-Include.bin";Binary get
	.SAV "include/MADS-Reference-Binary-Output.bin",100	;Binary save

;---------------------------------------------------------------
	.ENUM portb	;Enum definition
rom	= $ff	;Activate ROM
ram	= $fe	;Activate RAM
	.ENDE

;---------------------------------------------------------------
	.STRUCT element	;Structure definition
index	.byte	;Index of element
address	.word	;Address of element
	.ENDS

;---------------------------------------------------------------
	.MACRO macro	;Macro definition
inmacro		; Label in macro definition
	.ENDM

;---------------------------------------------------------------
	.IF SWITCH=1
	
local	.LOCAL		;Local section
inlocal	;Local in local section
	.ENDL
	
pages	.PAGES		;Pages section
	.ENDPG	

	.PROC proc	;Procedure definition

	.PROC inproc
	
	.MACRO innermacro
	.ENDM
	
	.ENDP

	.ENDP
	
repeat	.REPT 1		;Repeat section
	.ENDR
	
	.ENDIF

;---------------------------------------------------------------

;	Support for hyperlink navigation to labels, equates,
;	local definitions, macro definitions and procedure definitions.

	ORG $2000	;Second implementation section
code	jmp main	;Code label

main	jsr proc	;Label
	lda #0
	sta colbak	;Equate
	macro		;Macro definition
	jsr innerproc	;Prodcure definition from include file
	jsr jac		;Ambigous intifier

	
	