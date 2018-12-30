;	Reference source file for DASM symbols

        processor 6502

	mac m_macro
m_label1
	lda #1
	endm
  
equate1 = 1	
equate2 = equate1+1

equate3 EQU 2	
equate4 EQU equate2+1

string1 = "testString1"

eqm1	eqm 123
eqm2	eqm eqm1+1

	set 
	org $2000

label1:
	lda #1
label2:
	sta $80

	jsr SUBROUTINE1

SUBROUTINE1	SUBROUTINE 
inner1:
	lda #1
inner2:
	sta $80


	