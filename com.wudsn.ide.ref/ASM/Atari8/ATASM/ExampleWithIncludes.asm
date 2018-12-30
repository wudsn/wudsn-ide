;	WUDSN IDE example ATASM source file
;
;	Support for hyperlink navigation to source includes.
;	Absolute and relative file paths are supported.
	.include "..\Macros.inc"
;


;	Support for hyperlink navigation to binary includes.
;	Absolute and relative file paths are supported.
	.incbin "C:\jac\system\Atari800\Example.bin"
	
	
;	Support for hyperlink navigation to labels, equates,
;	local definitions, macro definitions and procedure definitions.
	jmp target
	
;	Support for identifiers from source includes.
	jmp set 
	
	


target
set
