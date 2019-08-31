;
;	>>> Fuji Demo by JAC! <<<
;
;	Sound routines.
;
;	@com.wudsn.ide.asm.mainsourcefile=..\Fuji.asm


	.proc sound
STEREOMODE = 0			;0 => compile RMTplayer for mono 4 tracks
;				;1 => compile RMTplayer for stereo 8 tracks
;				;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;				;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;
;
	
zp	= 203			;13 bytes of zero pages
player	= $2400			;Must be at page boundary, 1k before are used as scratch pad
init	= player		;<A>=song number 0...255, <X>=lo byte of module, <Y>=hi byte of module
play	= player+3		;Play 1 step
stop	= player+9	        ;All sounds off
module	= $3000			;Target address of RMT module

	icl "snd/RMT-Relocator.mac"	;Include relocator

	org sound.player
	icl "snd/RMT-Player.asm"	;Include RMT player routine

;	.if buffer_mode = 1
;	.proc buffer			;Buffer for multi speed replay
;	STEPS = 3 
;
;	.proc copy_to_buffer		;Copy replay result to buffer
;count = *+1
;	ldx #0
;	mva v_audctl data.v_audctl,x
;	.rept TRACKS
;	mva trackn_audf+# data.trackn_audf+#*STEPS,x
;	mva trackn_audc+# data.trackn_audc+#*STEPS,x
;	.endr
;
;	inx
;	cpx #STEPS
;	sne
;	ldx #0
;	stx count
;	rts
;	.endp
;
;	.proc copy_from_buffer		;Copy buffer to replay result
;count = *+1
;	ldx #0
;	.rept TRACKS
;	lda data.trackn_audf+#*STEPS,x
;	ldy data.trackn_audc+#*STEPS,x
;	sta $d200+#*2
;	sty $d201+#*2
;	.endr
;	mva data.v_audctl,x $d208
;
;	inx
;	cpx #STEPS
;	sne
;	ldx #0
;	stx count
;	rts
;	.endp
;
;	.local data
;	.local v_audctl
;:STEPS	.byte 0
;	.endl
;
;	.local trackn_audf
;:STEPS*TRACKS	.byte 0
;	.endl
;
;	.local trackn_audc
;:STEPS*TRACKS	.byte 0
;	.endl
;	.endl
;	
;	.endp
;	
;	.endif

	org sound.module		;Inxlude stripped RMT
;	RMT feature definitions file
;	For optimizations of RMT player routine to concrete RMT module only!
	icl "snd/Sound-Features.asm"
	rmt_relocator 'snd/Sound.rmt' sound.module
	.endp
	

