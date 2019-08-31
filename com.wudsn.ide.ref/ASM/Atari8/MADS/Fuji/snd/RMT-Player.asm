;*
;* Raster Music Tracker, RMT Atari routine version 1.20040221
;* (c) Radek Sterba, Raster/C.P.U., 2002 - 2004
;* http://raster.atari.org
;*
;* Warnings:
;*
;* 1. RMT player routine needs 19 itself reserved bytes in zero page (no accessed
;*    from any other routines) as well as circa 1KB of memory before the "PLAYER"
;*    address for frequency tables and functionary variables. It's:
;*	  a) from PLAYER-$400 to PLAYER for stereo RMTplayer
;*    b) from PLAYER-$380 to PLAYER for mono RMTplayer
;*
;* 2. RMT player routine MUST (!!!) be compiled from the begin of the memory page.
;*    i.e. "PLAYER" address can be $..00 only!
;*
;* 3. Because of RMTplayer provides a lot of effects, it spent a lot of CPU time.
;*
;* STEREOMODE	equ 0				;0 => compile RMTplayer for 4 tracks mono
;*									;1 => compile RMTplayer for 8 tracks stereo
;*									;2 => compile RMTplayer for 4 tracks stereo L1 R2 R3 L4
;*									;3 => compile RMTplayer for 4 tracks stereo L1 L2 R3 R4
;*
;PLAYER		equ $3400
;*
	IFT STEREOMODE==1
TRACKS		equ 8
	ELS
TRACKS		equ 4
	EIF

;*
;* RMT ZeroPage addresses
;	opt f-
	org sound.zp
p_tis
p_instrstable	org *+2
p_trackslbstable	org *+2
p_trackshbstable	org *+2
p_song			org *+2
ns				org *+2
nr				org *+2
nt				org *+2
reg1			org *+1
reg2			org *+1
reg3			org *+1
tmp				org *+1
	IFT FEAT_COMMAND2
frqaddcmd2		org *+1
	EIF
	IFT TRACKS>4
	org PLAYER-$400
	ELS
	org PLAYER-$380
	EIF
track_variables
trackn_db	org *+TRACKS
trackn_hb	org *+TRACKS
trackn_idx	org *+TRACKS
trackn_pause	org *+TRACKS
trackn_note	org *+TRACKS
trackn_volume	org *+TRACKS
trackn_distor 	org *+TRACKS
trackn_shiftfrq	org *+TRACKS
	IFT FEAT_PORTAMENTO
trackn_portafrqc org *+TRACKS
trackn_portafrqa org *+TRACKS
trackn_portaspeed org *+TRACKS
trackn_portaspeeda org *+TRACKS
trackn_portadepth org *+TRACKS
	EIF
trackn_instrx2	org *+TRACKS
trackn_instrdb	org *+TRACKS
trackn_instrhb	org *+TRACKS
trackn_instridx	org *+TRACKS
trackn_instrlen	org *+TRACKS
trackn_instrlop	org *+TRACKS
trackn_instrreachend	org *+TRACKS
trackn_volumeslidedepth org *+TRACKS
trackn_volumeslidevalue org *+TRACKS
	IFT FEAT_VOLUMEMIN
trackn_volumemin		org *+TRACKS
	EIF
trackn_effdelay			org *+TRACKS
trackn_effvibratoa		org *+TRACKS
trackn_effvibratobeg	org *+TRACKS
trackn_effvibratoend	org *+TRACKS
trackn_effshift		org *+TRACKS
trackn_tabletypespeed org *+TRACKS
	IFT FEAT_TABLEMODE
trackn_tablemode	org *+TRACKS
	EIF
trackn_tablenote	org *+TRACKS
trackn_tablea		org *+TRACKS
trackn_tableend		org *+TRACKS
	IFT FEAT_TABLEGO
trackn_tablelop		org *+TRACKS
	EIF
trackn_tablespeeda	org *+TRACKS
trackn_command		org *+TRACKS
	IFT FEAT_BASS16
trackn_outnote		org *+TRACKS
	EIF
	IFT FEAT_FILTER
trackn_filter		org *+TRACKS
	EIF
trackn_audf	org *+TRACKS
trackn_audc	org *+TRACKS
	IFT FEAT_AUDCTLMANUALSET
trackn_audctl	org *+TRACKS
	EIF
v_audctl		org *+1
v_audctl2		org *+1
v_speed			org *+1
v_aspeed		org *+1
v_bspeed		org *+1
v_instrspeed	org *+1
v_ainstrspeed	org *+1
v_maxtracklen	org *+1
v_abeat			org *+1
track_endvariables
		org PLAYER-$100-$140-$30
INSTRPAR	equ 12
tabbeganddistor
 dta frqtabpure-frqtab,$00
 dta frqtabpure-frqtab,$20
 dta frqtabpure-frqtab,$40
 dta frqtabbass1-frqtab,$c0
 dta frqtabpure-frqtab,$80
 dta frqtabpure-frqtab,$a0
 dta frqtabbass1-frqtab,$c0
 dta frqtabbass2-frqtab,$c0
vibtabbeg dta 0,vib1-vib0,vib2-vib0,vib3-vib0,vibx-vib0
vib0	dta 0
vib1	dta 1,-1,-1,1
vib2	dta 1,0,-1,-1,0,1
vib3	dta 1,1,0,-1,-1,-1,-1,0,1,1
vibx
;	opt f+

		org PLAYER-$100-$140
	IFT FEAT_BASS16
frqtabbasslo
	dta $F2,$33,$96,$E2,$38,$8C,$00,$6A,$E8,$6A,$EF,$80,$08,$AE,$46,$E6
	dta $95,$41,$F6,$B0,$6E,$30,$F6,$BB,$84,$52,$22,$F4,$C8,$A0,$7A,$55
	dta $34,$14,$F5,$D8,$BD,$A4,$8D,$77,$60,$4E,$38,$27,$15,$06,$F7,$E8
	dta $DB,$CF,$C3,$B8,$AC,$A2,$9A,$90,$88,$7F,$78,$70,$6A,$64,$5E,$00
	EIF
		org PLAYER-$100-$100
frqtab
	ERT [<frqtab]!=0	;* frqtab must begin at the memory page bound! (i.e. $..00 address)
frqtabbass1
	dta $BF,$B6,$AA,$A1,$98,$8F,$89,$80,$F2,$E6,$DA,$CE,$BF,$B6,$AA,$A1
	dta $98,$8F,$89,$80,$7A,$71,$6B,$65,$5F,$5C,$56,$50,$4D,$47,$44,$3E
	dta $3C,$38,$35,$32,$2F,$2D,$2A,$28,$25,$23,$21,$1F,$1D,$1C,$1A,$18
	dta $17,$16,$14,$13,$12,$11,$10,$0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07
frqtabbass2
	dta $FF,$F1,$E4,$D8,$CA,$C0,$B5,$AB,$A2,$99,$8E,$87,$7F,$79,$73,$70
	dta $66,$61,$5A,$55,$52,$4B,$48,$43,$3F,$3C,$39,$37,$33,$30,$2D,$2A
	dta $28,$25,$24,$21,$1F,$1E,$1C,$1B,$19,$17,$16,$15,$13,$12,$11,$10
	dta $0F,$0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00
frqtabpure
	dta $F3,$E6,$D9,$CC,$C1,$B5,$AD,$A2,$99,$90,$88,$80,$79,$72,$6C,$66
	dta $60,$5B,$55,$51,$4C,$48,$44,$40,$3C,$39,$35,$32,$2F,$2D,$2A,$28
	dta $25,$23,$21,$1F,$1D,$1C,$1A,$18,$17,$16,$14,$13,$12,$11,$10,$0F
	dta $0E,$0D,$0C,$0B,$0A,$09,$08,$07,$06,$05,$04,$03,$02,$01,$00,$00
	IFT FEAT_BASS16
frqtabbasshi
	dta $0D,$0D,$0C,$0B,$0B,$0A,$0A,$09,$08,$08,$07,$07,$07,$06,$06,$05
	dta $05,$05,$04,$04,$04,$04,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02
	dta $02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	EIF
		org PLAYER-$0100
volumetab
	dta $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	dta $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01
	dta $00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$02,$02,$02,$02
	dta $00,$00,$00,$01,$01,$01,$01,$01,$02,$02,$02,$02,$02,$03,$03,$03
	dta $00,$00,$01,$01,$01,$01,$02,$02,$02,$02,$03,$03,$03,$03,$04,$04
	dta $00,$00,$01,$01,$01,$02,$02,$02,$03,$03,$03,$04,$04,$04,$05,$05
	dta $00,$00,$01,$01,$02,$02,$02,$03,$03,$04,$04,$04,$05,$05,$06,$06
	dta $00,$00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07
	dta $00,$01,$01,$02,$02,$03,$03,$04,$04,$05,$05,$06,$06,$07,$07,$08
	dta $00,$01,$01,$02,$02,$03,$04,$04,$05,$05,$06,$07,$07,$08,$08,$09
	dta $00,$01,$01,$02,$03,$03,$04,$05,$05,$06,$07,$07,$08,$09,$09,$0A
	dta $00,$01,$01,$02,$03,$04,$04,$05,$06,$07,$07,$08,$09,$0A,$0A,$0B
	dta $00,$01,$02,$02,$03,$04,$05,$06,$06,$07,$08,$09,$0A,$0A,$0B,$0C
	dta $00,$01,$02,$03,$03,$04,$05,$06,$07,$08,$09,$0A,$0A,$0B,$0C,$0D
	dta $00,$01,$02,$03,$04,$05,$06,$07,$07,$08,$09,$0A,$0B,$0C,$0D,$0E
	dta $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F
	org PLAYER
;*
;* Set of RMT main vectors:
;*
RASTERMUSICTRACKER
	jmp rmt_init
	jmp rmt_play
	jmp rmt_p3
	jmp rmt_silence
;	jmp SetPokey
rmt_init
	stx ns
	sty ns+1
	pha
	IFT track_endvariables-track_variables>255
	ldy #0
	tya
ri0	sta track_variables,y
	sta track_endvariables-$100,y
	iny
	bne ri0
	ELS
	ldy #track_endvariables-track_variables
	lda #0
ri0	sta track_variables-1,y
	dey
	bne ri0
	EIF
	ldy #4
	lda (ns),y
	sta v_maxtracklen
	iny
	lda (ns),y
	sta v_speed
	iny
	lda (ns),y
	sta v_instrspeed
	sta v_ainstrspeed
	ldy #8
ri1	lda (ns),y
	sta p_tis-8,y
	iny
	cpy #8+8
	bne ri1
	pla
	pha
	IFT TRACKS>4
	asl @
	asl @
	asl @
	clc
	adc p_song
	sta p_song
	pla
	php
	and #$e0
	asl @
	rol @
	rol @
	rol @
	ELS
	asl @
	asl @
	clc
	adc p_song
	sta p_song
	pla
	php
	and #$c0
	asl @
	rol @
	rol @
	EIF
	plp
	adc p_song+1
	sta p_song+1
	jsr GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
rmt_silence
	IFT STEREOMODE>0
	lda #0
	sta $d208
	sta $d218
	ldy #3
	sty $d20f
	sty $d21f
	ldy #8
si1	sta $d200,y
	sta $d210,y
	dey
	bpl si1
	ELS
	lda #0
	sta $d208
	ldy #3
	sty $d20f
	ldy #8
si1	sta $d200,y
	dey
	bpl si1
	EIF
	lda v_instrspeed
	rts
GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
GetSongLine
	ldx #0
	stx v_abeat
nn0
nn1	txa
	tay
	lda (p_song),y
	cmp #$fe
	bcs nn2
	tay
	lda (p_trackslbstable),y
	sta trackn_db,x
	lda (p_trackshbstable),y
nn1a sta trackn_hb,x
	lda #0
	sta trackn_idx,x
	lda #1
nn1a2 sta trackn_pause,x
	lda #$80
	sta trackn_instrx2,x
	inx
xtracks01	cpx #TRACKS
	bne nn1
	lda p_song
	clc
xtracks02	adc #TRACKS
	sta p_song
	bcc GetTrackLine
	inc p_song+1
nn1b
	jmp GetTrackLine
nn2
	beq nn3
nn2a
	lda #0
	beq nn1a2
nn3
	ldy #2
	lda (p_song),y
	tax
	iny
	lda (p_song),y
	sta p_song+1
	stx p_song
	ldx #0
	beq nn0
GetTrackLine
oo0
oo0a
	lda v_speed
	sta v_bspeed
	ldx #-1
oo1
	inx
	dec trackn_pause,x
	bne oo1x
	inc trackn_pause,x
oo1b
	lda trackn_db,x
	sta ns
	lda trackn_hb,x
	sta ns+1
oo1i
	ldy trackn_idx,x
	lda (ns),y
	sta reg1
	iny
	lda (ns),y
	sta reg2
	iny
	tya
	sta trackn_idx,x
	lda reg1
	and #$3f
	cmp #61
	beq oo1a
	bcs oo2
	sta trackn_note,x
	IFT FEAT_BASS16
	sta trackn_outnote,x
	EIF
	lda reg2
	lsr @
	and #$3f*2
	sta trackn_instrx2,x
oo1a lda reg2
	lsr @
	ror reg1
	lsr @
	ror reg1
	lda reg1
	and #$f0
	sta trackn_volume,x
oo1x
xtracks03sub1	cpx #TRACKS-1
	bne oo1
	lda v_bspeed
	sta v_speed
	sta v_aspeed
	jmp InitOfNewSetInstrumentsOnly
oo2
	cmp #63
	beq oo63
	lda reg1
	and #$c0
	beq oo62_b
	asl @
	rol @
	rol @
	sta trackn_pause,x
	dec trackn_idx,x
	jmp oo1x
oo62_b
	lda reg2
	sta trackn_pause,x
	jmp oo1x
oo63
	lda reg1
	bmi oo63_1X
	lda reg2
	sta v_bspeed
	jmp oo1i
oo63_1X
	cmp #255
	beq oo63_11
	lda reg2
	sta trackn_idx,x
	jmp oo1i
oo63_11
	jmp GetSongLine
p2xrmtp3	jmp rmt_p3
p2x0 dex
	 bmi p2xrmtp3
InitOfNewSetInstrumentsOnly
p2x1 ldy trackn_instrx2,x
	bmi p2x0
SetUpInstrumentY2
	lda (p_instrstable),y
	sta trackn_instrdb,x
	sta nt
	iny
	lda (p_instrstable),y
	sta trackn_instrhb,x
	sta nt+1
	IFT FEAT_FILTER
	lda #1
	sta trackn_filter,x
	EIF
	IFT FEAT_TABLEGO
	IFT FEAT_FILTER
	tay
	ELS
	ldy #1
	EIF
	lda (nt),y
	sta trackn_tablelop,x
	iny
	ELS
	ldy #2
	EIF
	lda (nt),y
	sta trackn_instrlen,x
	iny
	lda (nt),y
	sta trackn_instrlop,x
	iny
	lda (nt),y
	sta trackn_tabletypespeed,x
	IFT FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
	sta trackn_tablespeeda,x
	IFT FEAT_TABLEMODE
	lda (nt),y
	and #$40
	sta trackn_tablemode,x
	EIF
	IFT FEAT_AUDCTLMANUALSET
	iny
	lda (nt),y
	sta trackn_audctl,x
	iny
	ELS
	ldy #6
	EIF
	lda (nt),y
	sta trackn_volumeslidedepth,x
	IFT FEAT_VOLUMEMIN
	iny
	lda (nt),y
	sta trackn_volumemin,x
	iny
	ELS
	ldy #8
	EIF
	lda (nt),y
	sta trackn_effdelay,x
	iny
	lda (nt),y
	tay
	lda vibtabbeg,y
	sta trackn_effvibratoa,x
	sta trackn_effvibratobeg,x
	lda vibtabbeg+1,y
	sta trackn_effvibratoend,x
	ldy #10
	lda (nt),y
	sta trackn_effshift,x
	lda #128
	sta trackn_volumeslidevalue,x
	sta trackn_instrx2,x
	asl @
	sta trackn_instrreachend,x
	sta trackn_shiftfrq,x
	tay
	lda (nt),y
	sta trackn_tableend,x
	adc #0
	sta trackn_instridx,x
	lda #INSTRPAR
	sta trackn_tablea,x
	tay
	lda (nt),y
	sta trackn_tablenote,x
xata_rtshere
	jmp p2x0

rmt_play
;rmt_p0
	.if buffer_mode = 0
	jsr SetPokey	;Commented out by JAC!
	.endif
;rmt_p1
	dec v_ainstrspeed
	bne rmt_p3
p1a
	lda v_instrspeed
	sta v_ainstrspeed
rmt_p2
	dec v_aspeed
	bne rmt_p3
	inc v_abeat
	lda v_abeat
	cmp v_maxtracklen
	beq p2o3
	jmp GetTrackLine
p2o3
	jmp GetSongLineTrackLineInitOfNewSetInstrumentsOnlyRmtp3
go_ppnext	jmp ppnext
rmt_p3
	lda #>frqtab
	sta nr+1
xtracks05sub1	ldx #TRACKS-1
pp1
	lda trackn_instrhb,x
	beq go_ppnext
	sta ns+1
	lda trackn_instrdb,x
	sta ns
	ldy trackn_instridx,x
	lda (ns),y
	sta reg1
	iny
	lda (ns),y
	sta reg2
	iny
	lda (ns),y
	sta reg3
	iny
	tya
	cmp trackn_instrlen,x
	bcc pp2
	beq pp2
	lda #$80
	sta trackn_instrreachend,x
pp1b
	lda trackn_instrlop,x
pp2	sta trackn_instridx,x
	lda reg1
	IFT TRACKS>4
	cpx #4
	bcc pp2s
	lsr @
	lsr @
	lsr @
	lsr @
pp2s
	EIF
	and #$0f
	ora trackn_volume,x
	tay
	lda volumetab,y
	sta tmp
	lda reg2
	and #$0e
	tay
	lda tabbeganddistor,y
	sta nr
	lda tmp
	ora tabbeganddistor+1,y
	sta trackn_audc,x
InstrumentsEffects
	lda trackn_effdelay,x
	beq ei2
	cmp #1
	bne ei1
	lda trackn_shiftfrq,x
	clc
	adc trackn_effshift,x
	clc
	ldy trackn_effvibratoa,x
	adc vib0,y
	sta trackn_shiftfrq,x
	iny
	tya
	cmp trackn_effvibratoend,x
	bne ei1a
	lda trackn_effvibratobeg,x
ei1a
	sta trackn_effvibratoa,x
	jmp ei2
ei1
	dec trackn_effdelay,x
ei2
	ldy trackn_tableend,x
	cpy #INSTRPAR
	beq ei3
	lda trackn_tablespeeda,x
	bpl ei2f
ei2c
	tya
	cmp trackn_tablea,x
	bne ei2c2
	IFT FEAT_TABLEGO
	lda trackn_tablelop,x
	ELS
	lda #INSTRPAR
	EIF
	sta trackn_tablea,x
	bne ei2a
ei2c2
	inc trackn_tablea,x
ei2a
	lda trackn_instrdb,x
	sta nt
	lda trackn_instrhb,x
	sta nt+1
	ldy trackn_tablea,x
	lda (nt),y
	IFT FEAT_TABLEMODE
	ldy trackn_tablemode,x
	beq ei2e
	clc
	adc trackn_tablenote,x
ei2e
	EIF
	sta trackn_tablenote,x
	lda trackn_tabletypespeed,x
	IFT FEAT_TABLETYPE||FEAT_TABLEMODE
	and #$3f
	EIF
ei2f
	sec
	sbc #1
	sta trackn_tablespeeda,x
ei3
	lda trackn_instrreachend,x
	bpl ei4
	lda trackn_volume,x
	beq ei4
	IFT FEAT_VOLUMEMIN
	cmp trackn_volumemin,x
	beq ei4
	bcc ei4
	EIF
	tay
	lda trackn_volumeslidevalue,x
	clc
	adc trackn_volumeslidedepth,x
	sta trackn_volumeslidevalue,x
	bcc ei4
	tya
	sbc #16
	sta trackn_volume,x
ei4
	IFT FEAT_COMMAND2
	lda #0
	sta frqaddcmd2
	EIF
	lda reg2
	sta trackn_command,x
	and #$70
	lsr @
	lsr @
	sta jmx+1
jmx	bcc *
	jmp cmd0
	nop
	jmp cmd1
	nop
	jmp cmd2
	nop
	jmp cmd3
	nop
	jmp cmd4
	nop
	jmp cmd5
	nop
	jmp cmd6
	nop
	jmp cmd7
cmd1
	IFT FEAT_COMMAND1
	lda reg3
	jmp cmd0c
	EIF
cmd2
	IFT FEAT_COMMAND2
	lda reg3
	sta frqaddcmd2
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd3
	IFT FEAT_COMMAND3
	lda trackn_note,x
	clc
	adc reg3
	sta trackn_note,x
	jmp cmd0a
	EIF
cmd4
	IFT FEAT_COMMAND4
	lda trackn_shiftfrq,x
	clc
	adc reg3
	sta trackn_shiftfrq,x
	lda trackn_note,x
	jmp cmd0a
	EIF
cmd5
	IFT FEAT_COMMAND5&&FEAT_PORTAMENTO
	IFT FEAT_TABLETYPE
	lda trackn_tabletypespeed,x
	bpl cmd5a1
	ldy trackn_note,x
	lda (nr),y
	clc
	adc trackn_tablenote,x
	jmp cmd5ax
	EIF
cmd5a1
	lda trackn_note,x
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd5a2
	lda #63
cmd5a2
	tay
	lda (nr),y
cmd5ax
	sta trackn_portafrqc,x
	ldy reg3
	bne cmd5a
	sta trackn_portafrqa,x
cmd5a
	tya
	lsr @
	lsr @
	lsr @
	lsr @
	sta trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda reg3
	and #$0f
	sta trackn_portadepth,x
	lda trackn_note,x
	jmp cmd0a
	ELI FEAT_COMMAND5
	jmp pp9
	EIF
cmd6
	IFT FEAT_COMMAND6&&FEAT_FILTER
	lda reg3
	clc
	adc trackn_filter,x
	sta trackn_filter,x
	lda trackn_note,x
	jmp cmd0a
	ELI FEAT_COMMAND6
	jmp pp9
	EIF
cmd7
	IFT FEAT_COMMAND7SETNOTE||FEAT_COMMAND7VOLUMEONLY
	IFT FEAT_COMMAND7SETNOTE
	lda reg3
	IFT FEAT_COMMAND7VOLUMEONLY
	cmp #$80
	beq cmd7a
	EIF
	sta trackn_note,x
	jmp cmd0a
	EIF
	IFT FEAT_COMMAND7VOLUMEONLY
cmd7a
	lda trackn_audc,x
	ora #$f0
	sta trackn_audc,x
	lda trackn_note,x
	jmp cmd0a
	EIF
	EIF
cmd0
	lda trackn_note,x
	clc
	adc reg3
cmd0a
	IFT FEAT_TABLETYPE
	ldy trackn_tabletypespeed,x
	bmi cmd0b
	EIF
	clc
	adc trackn_tablenote,x
	cmp #61
	bcc cmd0a1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0a1
	IFT FEAT_BASS16
	sta trackn_outnote,x
	EIF
	tay
	lda (nr),y
	clc
	adc trackn_shiftfrq,x
	IFT FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	IFT FEAT_TABLETYPE
	jmp cmd0c
cmd0b
	cmp #61
	bcc cmd0b1
	lda #0
	sta trackn_audc,x
	lda #63
cmd0b1
	tay
	lda trackn_shiftfrq,x
	clc
	adc trackn_tablenote,x
	clc
	adc (nr),y
	IFT FEAT_COMMAND2
	clc
	adc frqaddcmd2
	EIF
	EIF
cmd0c
	sta trackn_audf,x
pp9
	IFT FEAT_PORTAMENTO
	lda trackn_portaspeeda,x
	beq pp10
	dec trackn_portaspeeda,x
	bne pp10
	lda trackn_portaspeed,x
	sta trackn_portaspeeda,x
	lda trackn_portafrqa,x
	cmp trackn_portafrqc,x
	beq pp10
	bcs pps1
	adc trackn_portadepth,x
	bcs pps8
	cmp trackn_portafrqc,x
	bcs pps8
	jmp pps9
pps1
	sbc trackn_portadepth,x
	bcc pps8
	cmp trackn_portafrqc,x
	bcs pps9
pps8
	lda trackn_portafrqc,x
pps9
	sta trackn_portafrqa,x
pp10
	lda reg2
	and #$01
	beq pp11
	lda trackn_portafrqa,x
	clc
	adc trackn_shiftfrq,x
	sta trackn_audf,x
pp11
	EIF
ppnext
	dex
	bmi rmt_p4
	jmp pp1
rmt_p4
	IFT FEAT_AUDCTLMANUALSET
	lda trackn_audctl+0
	ora trackn_audctl+1
	ora trackn_audctl+2
	ora trackn_audctl+3
	tax
	ELS
	ldx #0
	EIF
qq1
	stx v_audctl
	IFT FEAT_FILTER
	IFT FEAT_FILTERG0L
	lda trackn_command+0
	bpl qq2
	lda trackn_audc+0
	and #$0f
	beq qq2
	lda trackn_audf+0
	clc
	adc trackn_filter+0
	sta trackn_audf+2
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq1a
	EIF
	lda #0
	sta trackn_audc+2
qq1a
	txa
	ora #4
	tax
	EIF
qq2
	IFT FEAT_FILTERG1L
	lda trackn_command+1
	bpl qq3
	lda trackn_audc+1
	and #$0f
	beq qq3
	lda trackn_audf+1
	clc
	adc trackn_filter+1
	sta trackn_audf+3
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3L
	lda trackn_audc+3
	and #$10
	bne qq2a
	EIF
	lda #0
	sta trackn_audc+3
qq2a
	txa
	ora #2
	tax
	EIF
qq3
	IFT FEAT_FILTERG0L||FEAT_FILTERG1L
	cpx v_audctl
	bne qq5
	EIF
	EIF
	IFT FEAT_BASS16
	IFT FEAT_BASS16G1L
	lda trackn_command+1
	and #$0e
	cmp #6
	bne qq4
	lda trackn_audc+1
	and #$0f
	beq qq4
	ldy trackn_outnote+1
	lda frqtabbasslo,y
	sta trackn_audf+0
	lda frqtabbasshi,y
	sta trackn_audf+1
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0L
	lda trackn_audc+0
	and #$10
	bne qq3a
	EIF
	lda #0
	sta trackn_audc+0
qq3a
	txa
	ora #$50
	tax
	EIF
qq4
	IFT FEAT_BASS16G3L
	lda trackn_command+3
	and #$0e
	cmp #6
	bne qq5
	lda trackn_audc+3
	and #$0f
	beq qq5
	ldy trackn_outnote+3
	lda frqtabbasslo,y
	sta trackn_audf+2
	lda frqtabbasshi,y
	sta trackn_audf+3
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2L
	lda trackn_audc+2
	and #$10
	bne qq4a
	EIF
	lda #0
	sta trackn_audc+2
qq4a
	txa
	ora #$28
	tax
	EIF
	EIF
qq5
	stx v_audctl
	IFT TRACKS>4
	IFT FEAT_AUDCTLMANUALSET
	lda trackn_audctl+4
	ora trackn_audctl+5
	ora trackn_audctl+6
	ora trackn_audctl+7
	tax
	ELS
	ldx #0
	EIF
	stx v_audctl2
	IFT FEAT_FILTER
	IFT FEAT_FILTERG0R
	lda trackn_command+0+4
	bpl qs2
	lda trackn_audc+0+4
	and #$0f
	beq qs2
	lda trackn_audf+0+4
	clc
	adc trackn_filter+0+4
	sta trackn_audf+2+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs1a
	EIF
	lda #0
	sta trackn_audc+2+4
qs1a
	txa
	ora #4
	tax
	EIF
qs2
	IFT FEAT_FILTERG1R
	lda trackn_command+1+4
	bpl qs3
	lda trackn_audc+1+4
	and #$0f
	beq qs3
	lda trackn_audf+1+4
	clc
	adc trackn_filter+1+4
	sta trackn_audf+3+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG3R
	lda trackn_audc+3+4
	and #$10
	bne qs2a
	EIF
	lda #0
	sta trackn_audc+3+4
qs2a
	txa
	ora #2
	tax
	EIF
qs3
	IFT FEAT_FILTERG0R||FEAT_FILTERG1R
	cpx v_audctl2
	bne qs5
	EIF
	EIF
	IFT FEAT_BASS16
	IFT FEAT_BASS16G1R
	lda trackn_command+1+4
	and #$0e
	cmp #6
	bne qs4
	lda trackn_audc+1+4
	and #$0f
	beq qs4
	ldy trackn_outnote+1+4
	lda frqtabbasslo,y
	sta trackn_audf+0+4
	lda frqtabbasshi,y
	sta trackn_audf+1+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG0R
	lda trackn_audc+0+4
	and #$10
	bne qs3a
	EIF
	lda #0
	sta trackn_audc+0+4
qs3a
	txa
	ora #$50
	tax
	EIF
qs4
	IFT FEAT_BASS16G3R
	lda trackn_command+3+4
	and #$0e
	cmp #6
	bne qs5
	lda trackn_audc+3+4
	and #$0f
	beq qs5
	ldy trackn_outnote+3+4
	lda frqtabbasslo,y
	sta trackn_audf+2+4
	lda frqtabbasshi,y
	sta trackn_audf+3+4
	IFT FEAT_COMMAND7VOLUMEONLY&&FEAT_VOLUMEONLYG2R
	lda trackn_audc+2+4
	and #$10
	bne qs4a
	EIF
	lda #0
	sta trackn_audc+2+4
qs4a
	txa
	ora #$28
	tax
	EIF
	EIF
qs5
	stx v_audctl2
	EIF
rmt_p5
	lda v_ainstrspeed
	rts

	.if buffer_mode = 0
SetPokey
	ldx #31
@	lda trackn_audf,x
	sta text,x
	dex
	bpl @-

	IFT STEREOMODE==1		;* L1 L2 L3 L4 R1 R2 R3 R4
	ldy v_audctl2
	lda trackn_audf+0+4
	ldx trackn_audf+0
xstastx01	sta $d210
	stx $d200
	lda trackn_audc+0+4
	ldx trackn_audc+0
xstastx02	sta $d211
	stx $d201
	lda trackn_audf+1+4
	ldx trackn_audf+1
xstastx03	sta $d212
	stx $d202
	lda trackn_audc+1+4
	ldx trackn_audc+1
xstastx04	sta $d213
	stx $d203
	lda trackn_audf+2+4
	ldx trackn_audf+2
xstastx05	sta $d214
	stx $d204
	lda trackn_audc+2+4
	ldx trackn_audc+2
xstastx06	sta $d215
	stx $d205
	lda trackn_audf+3+4
	ldx trackn_audf+3
xstastx07	sta $d216
	stx $d206
	lda trackn_audc+3+4
	ldx trackn_audc+3
xstastx08	sta $d217
	stx $d207
	lda v_audctl
xstysta01	sty $d218
	sta $d208
	ELI STEREOMODE==0		;* L1 L2 L3 L4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d200+2
	stx $d201+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d200+4
	stx $d201+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d200+6
	stx $d201+6
	sty $d208
	ELI STEREOMODE==2		;* L1 R2 R3 L4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	sta $d210
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d210+2
	stx $d211+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d210+4
	stx $d211+4
	sta $d200+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d200+6
	stx $d201+6
	sta $d210+6
	sty $d218
	sty $d208
	ELI STEREOMODE==3		;* L1 L2 R3 R4
	ldy v_audctl
	lda trackn_audf+0
	ldx trackn_audc+0
	sta $d200
	stx $d201
	lda trackn_audf+1
	ldx trackn_audc+1
	sta $d200+2
	stx $d201+2
	lda trackn_audf+2
	ldx trackn_audc+2
	sta $d210+4
	stx $d211+4
	sta $d200+4
	lda trackn_audf+3
	ldx trackn_audc+3
	sta $d210+6
	stx $d211+6
	sta $d200+6
	sty $d218
	sty $d208
	EIF
	rts

	.endif