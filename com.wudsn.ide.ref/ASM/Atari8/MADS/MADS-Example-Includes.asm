;	WUDSN IDE example MADS source file
;
	org $2000

;	Support for hyperlink navigation to source includes.
;	Absolute and relative file paths are supported.
	ICL "..\Macros.inc"

;	Support for hyperlink navigation to binary includes.
;	Absolute and relative file paths are supported.
	INS "C:\jac\system\Atari800\Example.bin"

;	Support for hyperlink navigation to binary output file.
;	Absolute and relative file paths are supported.
	.SAV "C:\jac\system\Atari800\Example.bin"

;	Support for hyperlink navigation to labels, equates,
;	local definitions, macro definitions and procedure definitions.
	jmp target

;	Support for identifiers from source includes.
	jmp set 
	
	


target
set
