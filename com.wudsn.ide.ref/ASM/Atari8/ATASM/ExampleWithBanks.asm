; Bank 0
	.bank
	.set 6,0
*	= $8000

start	lda #0
	jmp *
 
; Bank 1
	.bank
	.set 6,0
*	= $2e0
	.word start

; Bank 2
	.bank
	.set 6,$4300-$C000
*	= $C000

	lda #1
	sta label+1
label	lda #2
	jmp *