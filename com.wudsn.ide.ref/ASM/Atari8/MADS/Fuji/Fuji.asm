	
	org $2000
	
	buffer_mode=0
	icl "snd/Sound.asm"

	org $4000

	.proc main
	mwa #dl 560
	mva #>charset 756

;	jsr sound.stop
	ldx #<sound.module
	ldy #>sound.module
	lda #0
	jsr sound.init
	
loop	lda #15

@	cmp $d40b
	bne @-

	jsr sound.play

@	lda $d40b
	sta $d01a
	cmp #112
	bne @-
	lda #0
	sta $d01a
	jmp loop
	
	jsr sound.stop
	jmp $e474
	.endp
	
	org $5000

	.local charset
	ins 'gfx/Charset.chr'
	.endl

	.local dl
:3	.byte $70
	.byte $42, a(text)
	
	.byte $4f, a(picture)
:95	.byte $0f
	.byte $4f, a(picture+96*40)
:95	.byte $0f
	.byte $41, a(dl)
	.endl

	.local text
	.byte "Hello Fuji!"
	.endl

	org $6100
	.local picture
	ins 'gfx/Image.pic'
	.endl

	run main

