;;
;;
;;	New test, not using TigerVision mega bank shennanigans, much as a I like it though ;)
;;
;;	This is the simpler sound code, pretty much emulating Pitfall2 sound system.
;;	Fixed oscillator scheme, no more massive macros, and huge label problems with DASM.
;;	3 fixed voices, chucking out square wave with duty cycle control only..
;;
;;

;;	Enable this if we want to assemble debug string outputs for SoundSim..
USE_DEBUGSTRINGS = 1

        processor 6502
		include "VCS3F.H"

BANK		= $3F       ; write address to switch banks
BANKPAGE	= $F000     ; base address of bank blocks


;;
;;	Patch parameters.. Must be padded to 16bytes or else..
;;
		SEG.U structs
		ORG 0
pt_PW	ds.b 1		;	PulseWidth value..	$FF is don't reset..
pt_TR	ds.b 1		;	Patch Transpose..
pt_ARP	ds.b 1		;	Arpeggio index to use..
pt_ATK	ds.b 1		;	Attack Rate			4.4 IF
pt_ATKL	ds.b 1		;	Attack Level		4.4 IF
pt_DCY	ds.b 1		;	Release rate		4.4 IF
pt_SUS	ds.b 1		;	Sustain Level		4.4	IF
pt_RLS	ds.b 1		;	Release rate		4.4 IF
		.byte 0,0,0,0,0,0,0,0		;	Padding..

;;
;;	Zeropage stuff.. Not a lot here for the sound stuff..
;;
		SEG.U variables
		ORG $80

#if USE_DEBUGSTRINGS
		MAC DEBUGSTRING
		.byte $FF
		.word .02
		jmp .01
.02		.byte {1}
		.byte 0
.01
		ENDM
#endif

;;
;;	Main ROM bank stuff now..
;;
		SEG
		ORG $F000
		RORG $F000
ROM_START	=	*
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Sequencer functions.. These must all reside in the same page due to the function states only
;;	using the lower 8 bits.. Potentially, we could seperate the Song processing from the event
;;	code allowing more complex code, but for now this'll do..
;;
;;	Notes about these functions..
;;		On entry to each state, X is the index to the voice specific V_???? parameters..
;;		It's expected that X be equal on exit of the function to its value on entry..
;;		Get this wrong and it all goes wrong!!
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_CORESTART	=	*
SEQ_PAGE		=	> *
;;
;;	We enter these functions with
;;		X == Voice index
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Do nothing state, effectively this is the end of any further processing for voice..
;;	SEQ_STOP must be the first function in the page since SEQ_STOP is never accessed from the Event
;;	processing, which always return to either SEQ_NEXTEVENT or SEQ_WAIT but uses the lo-byte of the
;;	state *ptr to fake a BRA to a space saver prologue funtion..
;;	Simply assert(#<SEQ_STOP==0)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_STOP:
		rts						;6		1
								;--
								;6		1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Wait until the voice timer matches the CoreTimer then
;;	fetch the next event..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_WAIT:
		lda V_WaitTime,x		;4		2
		cmp CoreTimer			;3		2
		bne .exit				;2/3	2
		lda #<SEQ_NEXTEVENT		;2		2
		sta SEQ_STATE			;3		2
.exit:							;
		rts						;6		1
								;--		--
								;22		11


#if 0

Cost example..

NEXTPATTERN	
				SEQ_NEXTPATTERN
TRANSPOSE		
				SEQ_TRANSPOSE
				SEQ_NEXTPATTERN
PATTERN		
				SEQ_STARTPATTERN
				SEQ_NEXTEVENT
PATCH
				SEQ_PATCH
				SEQ_NEXTEVENT
LENGTH		
				SEQ_LENGTH
				SEQ_NEXTEVENT
NOTEON		
				SEQ_NOTEON
				SEQ_WAIT
#endif 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Fetch the next pattern from the song
;;	Temporarily stored lo-byte of the pattern pointer, until
;;	the next state update..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_NEXTPATTERN:
		ldy	#0					;2
		lda (SEQ_SONG),y		;6		2
		sta V_TMP,x				;4
		and #$03				;2
		tay						;2
								;
		inc SEQ_SONG+0			;5
		bne .nonpc				;2/3
		inc SEQ_SONG+1			;5
.nonpc:							;
		lda PATTERN_EVENTTABLE,y;4
		sta SEQ_STATE			;3
		rts						;6
								;--
								;42

SEQ_NEWPATTERN:
		lda V_TMP,x				;2
		lsr						;2
		lsr						;2
		tay						;2
		lda Patterns_Lo,y		;4		3
		sta SEQ_PATT+0			;3		2
		lda Patterns_Hi,y		;4		3
		sta SEQ_PATT+1			;3		2
		lda #<SEQ_NEXTEVENT		;2		2
		sta SEQ_STATE			;3
		rts						;6
								;--
								;33

SEQ_TRANSPOSE:
		lda V_TMP,x				;4
		lsr						;2
		lsr						;2
		sta V_NoteTranspose,x	;4		2
		lda #<SEQ_NEXTPATTERN	;2		2
		sta SEQ_STATE			;3
		rts						;6
								;--
								;23
	
SEQ_BRANCH:
		ldy #<SEQ_NEXTPATTERN	;2
		lda V_TMP,x				;4
		lsr						;2
		lsr						;2
		cmp #$3F				;2
		bne .notstop			;2/3
		ldy #<SEQ_STOP			;2		2
.notstop:						;
		sty SEQ_STATE			;3
		rts						;6
								;--
								;32

#if 0
PATCHES
	VOLUME
		4 bits
	ARPEGGIO INDEX
		ARP Length
			ARP Notes..
	PULSE WIDTH MOD RATE,RANGE (&MASK), OFFSET
		lda CoreTimer
		and #$7F
		adc #$80
		sta V0_PW	Gives PW of -64 > +64
#endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Bump up the pattern index, and fetch the actual next event
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_NEXTEVENT:					;
		ldy	#0					;2
		lda (SEQ_PATT),y		;6		2
		sta V_TMP,x				;4
		and #$07				;2		2
		tay						;2		1

		inc SEQ_PATT+0			;5
		bne .noc				;2/3
		inc SEQ_PATT+1			;5
.noc:

		lda SEQ_EVENTTABLE,y	;4		3
		sta SEQ_STATE			;3		2
		rts						;6
								;--
								;42

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		NOTEON event.. Start a new note playing..
;;		Event = 5 Bits Note value
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_NOTEON:
;	Figure out the note to play
		lda V_TMP,x				;3		2
		lsr						;2		1
		lsr						;2		1
		lsr						;2		1
		sta V_Note,x			;3		2
;	Calculate the end of the note time
		lda V_NoteLength,x		;4		2
		clc						;2		1
		adc	CoreTimer			;3		2
		sta V_WaitTime,x		;3		2
;	Reset to Attack state
		lda #<EG_ATTACK			;2		2
		sta V_EGState,x			;4		2
;	Reset the EG output level
		lda #0					;2		2
		sta V_EG_Lo,x			;4		2
;	Reload the patch PW
;		ldy V_Patch,x
;		lda Patches+pt_PW,y
;		ldy #PULSEWIDTH
;		sta (SEQ_VOICE),y
;	And switch to wait state
		lda #<SEQ_WAIT			;2		2
		sta SEQ_STATE			;3		2
		rts						;6		1
								;--		--
								;46		17

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		NOTEOFF event.. Release the EG..
;;		Event = 5 Bits length
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_NOTEOFF:
		lda #<EG_RELEASE		;2		2
		sta V_EGState,x			;3		2
		lda #<SEQ_REST			;2		2
		sta SEQ_STATE			;3		2
		rts						;6		1
								;--		--
								;16		9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		LENGTH event.. Update the internal note length
;;		Event = 5 bit new length value
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_LENGTH:
		lda V_TMP,X				;3		2
		lsr
		lsr
		lsr
		tay
		lda NoteLengthLUT,y		;4		3
		sta V_NoteLength,x		;3		2
		lda #<SEQ_NEXTEVENT		;2		2
		sta SEQ_STATE			;3		2
		rts						;6		1
								;--		--
								;30		12

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		REST event..
;;		Event = 5 bit rest length
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_REST:
;;	Get the reset length and set wait time..
		lda V_TMP,x				;3		2
		lsr
		lsr
		lsr
		tay
		lda NoteLengthLUT,y		;4		3
		clc						;2		1
		adc	CoreTimer			;3		2
		sta V_WaitTime,x		;4		2
		lda #<SEQ_WAIT			;2		2
		sta SEQ_STATE			;3		2
		rts						;6		1
								;--		--
								;27		9

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		PATCH event..
;;		EVENT = 5bit patch #
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_PATCH:
		lda V_TMP,x				;3		2
		and #%11111000			;2		2
		asl						;2		1
		tay						;2		1
		sta V_Patch,x			;4		1
		lda #<SEQ_NEXTEVENT		;2		2
		sta SEQ_STATE			;3		2
		rts						;6		1
								;--		--
								;37		8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;		BAD event..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SEQ_BAD:
		ldx #0
		stx COLUBK
		dex
		stx COLUBK
		bne SEQ_BAD

SEQ_COREEND	=	*
SEQ_CORESIZE	=	SEQ_COREEND-SEQ_CORESTART
		ECHO "SEQ_CORESIZE",SEQ_CORESIZE

;		ds.b 64

		ALIGN 256
EG_START	=	*
EG_PAGE	=	> *

EG_ATTACK:		
		ldy V_Patch,x			;4
		lda V_EG_Lo,x			;4
		adc Patches+pt_ATK,y	;4
		sta V_EG_Lo,x			;4
		bcs .egaend				;2/3
		cmp Patches+pt_ATKL,y	;4
		bcs .egaend				;2/3
		rts						;6
								;--
								;32
.egaend:
		lda Patches+pt_ATKL,y	;4
		sta V_EG_Lo,x			;4
		lda #<EG_DECAY			;2
		sta V_EGState,x			;4
		rts						;6
								;--
								;45
EG_DECAY:
		ldy V_Patch,x			;4
		lda V_EG_Lo,x			;4
		sec						;2
		sbc Patches+pt_DCY,y	;4
		bcc .egdend				;2/3
		sta V_EG_Lo,x			;4
		cmp Patches+pt_SUS,y	;4
		bcc .egdend				;2/3
		rts						;6
								;--
								;34
.egdend:
		lda Patches+pt_SUS,y	;4
		sta V_EG_Lo,x			;4
		rts						;6
								;--
								;44

EG_RELEASE:
		ldy V_Patch,x			;4
		lda V_EG_Lo,x			;4
		sec						;2
		sbc Patches+pt_RLS,y	;4
		bcc .egrend				;2/3
		sta V_EG_Lo,x			;4
		rts						;6
								;--
								;27
.egrend:
		lda #0					;2
		sta V_EG_Lo,x			;4
		rts						;6
								;--
								;33

EG_END	=	*
EG_SIZE	=	EG_END-EG_START
		ECHO "EG_SIZE",EG_SIZE


;;
;;	Low-Bytes of song command functions..
;;
PATTERN_EVENTTABLE:
		.byte <SEQ_NEWPATTERN	;00
		.byte <SEQ_TRANSPOSE	;01
		.byte <SEQ_BAD			;02
		.byte <SEQ_BRANCH		;03
;;
;;	Low-Bytes of sequencer command functions..
;;
SEQ_EVENTTABLE:
		.byte <SEQ_NOTEON		;00
		.byte <SEQ_NOTEOFF		;01
		.byte <SEQ_LENGTH		;02
		.byte <SEQ_PATCH		;03	
		.byte <SEQ_REST			;04
		.byte <SEQ_BAD			;05
		.byte <SEQ_BAD			;06	
		.byte <SEQ_NEXTPATTERN	;07

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Helpers to the Sequencer processing, that don't abide by the event states paradigm..
;;	These are called manually and are limited by the maximum time an event state can take..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		;;
		;;	Only update the timer count when all voices have reached their wait states..
		;;
SEQ_CLOCKTIMER:
		lda V_SeqState+0		;3
		ora V_SeqState+1		;3
		ora V_SeqState+2		;3
		cmp #<SEQ_WAIT			;2
		bne .notready			;2/3
		inc CoreTimer			;5
		rts						;6
								;--
.notready:						;25
		DebugString "Had to wait!"
		rts						;6
								;--
								;25

;;
;;	Called once per frame after sequencer processing to update the internal voice frequency..
;;	3 Parts to this..
;;		1/	Arpeggio offset
;;		2/	BaseNote+NoteTranspose+PatchTranspose
;;		2/	+Arpeggio offset
;;		3/	Calculate I:F
;;
;;	These are OK to use SEQ_TMP between states, since FREQ 1,2,3 are always called uninterupted..
;;
;;	Figure out the current arpeggio offset..
SEQ_FREQ_UPDATE:
		stx FREQ_TMP+1			;3
		ldy V_Patch,x			;4		2
		ldx Patches+pt_ARP,y	;4/5	3
		lda CoreTimer			;3
		and ARP_BASE,x			;4
		adc Patches+pt_ARP,y	;4/5	3
		tay						;2
		sty FREQ_TMP+0			;3
		ldx FREQ_TMP+1			;3
		rts						;6		1
								;--		--
								;38		17

;;	Figure out the base note value, without the arpeggio..
SEQ_FREQ_UPDATE1:
		lda	V_Note,x			;4		2
		clc						;2		2
		adc V_NoteTranspose,x	;4		2
		ldy V_Patch,x			;4		2
		adc Patches+pt_TR,y		;4		3
		ldy FREQ_TMP+0			;3
		adc ARP_BASE+1,y		;4/5
		sta FREQ_TMP+0			;3		2
		rts						;6		1
								;--		--
								;35		17

;;	Now load the resultant note value into the voice rate controls..
SEQ_FREQ_UPDATE2:
		ldy FREQ_TMP+0			;3		2
		lda NoteTable_Lo,y		;4		2
		ldy #RATE_LO			;2		2
		sta (SEQ_VOICE),y		;6		2
		ldy FREQ_TMP+0			;3		2
		lda NoteTable_Hi,y		;4		2
		ldy #RATE_HI			;2		2
		sta (SEQ_VOICE),y		;6		2
		rts						;6		1
								;--		--
								;36		17

SEQ_PULSE_UPDATE:

		rts

;;
;;	Reset all channels ready for a new song..
;;	A = Song Index..
;;
;;	We don't care about the time impact of this at the moment..
;;
SEQ_RESETSONG:
		;;
		;;	Multiply song index by 6 to fetch the 3 voice *ptrs
		;;
		asl
		sta V_Song_Lo+0
		asl
		adc V_Song_Lo+0
		adc #5
		tay
		;;
		;;	Copy the voice & data block into zeropage.. This actually has most of out initialisation
		;;	parameters alredy statically stored in it..
		;;	But for now we'll still initialise it all properly..
		;;
		ldx #VOICE_CORESIZE-1
.00:	lda VOICE_CORECODE,x
		sta	$80,x
		dex
		bpl .00
		;;
		;;	Copy each voices song *ptr
		;;
		ldx #2
.load:
		lda Songs+0,y
		sta V_Song_Hi,x
		dey
		lda Songs+0,y
		sta V_Song_Lo,x
		dey
		dex
		bpl .load
		;;
		;;	These are constants for all voices..
		;;
		lda #>V0_BASE
		sta SEQ_VOICE+1
		lda #SEQ_PAGE
		sta SEQ_STATE+1
		lda #EG_PAGE
		sta EG_STATE+1
		;;
		;;	Initialisation and resets that apply to all voices..
		;;
		ldx #2
.reset:
		;;	Reset sequencer state
		lda #<SEQ_NEXTPATTERN
		sta V_SeqState,x
		;;	Reset EG to doing nothing
		lda #<EG_RELEASE
		sta V_EGState,x

		;;	Reset Song index
;		lda #-1
;		sta V_SongIndex,x

		;;	Clear transposition
		lda #0
		sta V_NoteTranspose,x

		;;	Clear EG levels
		lda #0
		sta V_EG_Lo,x

		;;	Reset Voice data, probably shouldn't be part of the sequencer ??
		lda VoiceBaseTable,x
		sta SEQ_VOICE+0
		lda #0
		ldy #RATE_LO
		sta (SEQ_VOICE),y
		ldy #RATE_HI
		sta (SEQ_VOICE),y
		ldy #COUNT_LO
		sta (SEQ_VOICE),y
		ldy #COUNT_HI
		sta (SEQ_VOICE),y
		lda #$80
		ldy #PULSEWIDTH
		sta (SEQ_VOICE),y

		dex
		bpl .reset

		rts

;
;	AUDV		VCH		ENABLE
;	----		---		--------	
;	0000	0	000		__ __ __
;	0110	6	001		__ __ V3
;	0101	5	010		__ V2 __
;	1011	11	011		__ V2 V3
;	0100	4	100		V1 __ __
;	1010	10	101		V1 __ V3
;	0101	9	110		V1 V2 __
;	1111	15	111		V1 V2 v3
;
;	Default Pitfall2 levels..
;		V1 = Volume 6
;		V2 = Volume 5
;		V3 = Volume 4
;
;	We can assume there's not carries at all, except if Johnny hacker pisses about :)
;
MakeAUDVLUT_0:
		lda V_EG_Lo+0		;3
		lsr					;2
		lsr					;2
		lsr					;2
		lsr					;2
		sta MAKEVOL_TMP+0	;3
		lda V_EG_Lo+1		;3
		lsr					;2
		lsr					;2
		lsr					;2
		lsr					;2
		sta MAKEVOL_TMP+1	;3
		lda V_EG_Lo+2		;3
		lsr					;2
		lsr					;2
		lsr					;2
		lsr					;2
		sta MAKEVOL_TMP+2	;3
		rts					;6
							;--
							;48

MakeAUDVLUT_1:
		clc					;2
;	__ __ __				;
		lda #0				;2
		sta AUDVLUT+0		;3
;	__ __ V3				;
		lda MAKEVOL_TMP+2	;3
		sta AUDVLUT+1		;3
;	__ V2 __				;
		lda MAKEVOL_TMP+1	;3
		sta AUDVLUT+2		;3
;	__ V2 V3				;
		adc MAKEVOL_TMP+2	;3
		sta AUDVLUT+3		;3
		rts					;6
							;--
							;31
MakeAUDVLUT_2:
;	V1 __ __				;
		lda MAKEVOL_TMP+0	;3
		sta AUDVLUT+4		;3
;	V1 __ V3				;
		adc MAKEVOL_TMP+2	;3
		sta AUDVLUT+5		;3
;	V1 V2 __				;
		lda MAKEVOL_TMP+0	;3
		adc MAKEVOL_TMP+1	;3
		sta AUDVLUT+6		;3
;	V1 V2 v3				;
		adc MAKEVOL_TMP+2	;3
		sta AUDVLUT+7		;3
		rts					;6
							;--
							;33

		;;
		;;	Load the more tricky params into the temps from their voice specific stores..
		;;	X is the voice to load..
		;;
SEQ_VoiceLoad:
		lda V_SeqState,x		;4		2
		sta SEQ_STATE			;3		3
		lda V_Song_Lo,x			;4		2
		sta SEQ_SONG+0			;3		2
		lda V_Song_Hi,x			;4		2
		sta SEQ_SONG+1			;3		2
		lda V_Patt_Lo,x			;4		2
		sta SEQ_PATT+0			;3		2
		lda V_Patt_Hi,x			;4		2
		sta SEQ_PATT+1			;3		2
		lda VoiceBaseTable,x	;4		3
		sta SEQ_VOICE+0			;3		2
		rts						;6		1
								;--		--
								;48		27

		;;	Table of lo-bytes to each voices base address..
VoiceBaseTable:
		.byte <V0_BASE,<V1_BASE,<V2_BASE

		;;
		;;	Save the more tricky params back into the voice specific stores..
		;;	X is the voice to unload..
		;;
SEQ_VoiceUnload:
		lda SEQ_STATE			;3		3
		sta V_SeqState,x		;4		2
		lda SEQ_SONG+0			;3		2
		sta V_Song_Lo,x			;4		2
		lda SEQ_SONG+1			;3		2
		sta V_Song_Hi,x			;4		2
		lda SEQ_PATT+0			;3		2
		sta V_Patt_Lo,x			;4		2
		lda SEQ_PATT+1			;3		2
		sta V_Patt_Hi,x			;4		2
		rts						;6		1
								;--		--
								;41		22


		;;
		;;	Master Note Table.. Generated by MakeFreq.cpp
		;;
		include "Frequencies.inc"

		;;
		;;	Pattern data and pointers to..
		;;
		include "Song.inc"
		
		;;
		;;	These are used to modify the exit function of the Core synth code..
		;;	In normal processing we just RTS back to the caller..
		;;	In Sequencer processing mode we change the RTS into a JMP abs since we store
		;;	SEQ_STATE directly after this we jmp directly to the sequence processing event
		;;
		MAC SETVOICECORE_NORMAL
		lda #$60				;2
		sta VOICECORE_EXIT		;3
		ENDM

		MAC SETVOICECORE_SEQ
		lda #$4C				;2
		sta VOICECORE_EXIT		;3
		ENDM

		MAC SETEG_JMP
		lda V_EGState,x			;4
		sta EG_STATE			;3
		ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;	Main everything..
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Reset:
		sei
		cld
		ldx	#$FF
		txs

		ldx	#0
		lda #0
zero	sta $80,X
		inx
		bpl	zero

		DebugString "GO!"

		SETVOICECORE_NORMAL
TestVoiceCode:

		lda #0
		jsr SEQ_RESETSONG

		jmp ENTRYPOINT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Start of sequencer processing..
;;
;;	Breakdown of timings of indiviual process states we go through, and in (.) the amount of time left
;;
;;
;;	Processing requirements..
;;	Per Voice
;;		1	Voice Load
;;		4	Sequence Events
;;		1	EG Update
;;		1	Voice Unload
;;		3	Frequency Updates
;;	Common
;;		1	Clock Timer
;;		3	Volume Updates
;;
;;
;;
;;	---------- DISPLAY LINE ----------
;;
;;	DISPLAY
;;		6		wsync
;;		6+83	jsr voice
;;		----
;;		95	(57)
;;
;;	---------- PER VOICE ----------
;;
;;	VOICELOAD
;;		6		wsync
;;		6+83	jsr voice
;;		2+6+	ldx #voice + jsr voiceload	
;;		----
;;		101	(49)
;;
;;	SEQ States..
;;		6		wsync
;;		6+80	jsr voice (directly jmp to sequencer state in this mode)
;;		----
;;		92	(60)
;;
;;	VOICEUNLOAD
;;		6		wsync
;;		6+83	jsr voice
;;		6+		jsr voiceunload	
;;		7		SetEGJMP
;;		----
;;		108	(44)
;;
;;	EG States
;;		6		wsync
;;		6+83	jsr voice
;;		6+3		jsr EG > jmp State
;;		----
;;		104	(48)
;;
;;	FREQ States..
;;		6		wsync
;;		6+83	jsr voice
;;		6+		jsr freq
;;		----
;;		101	(51)
;;
;;	---------- COMMON ----------
;;
;;	SEQ_CLOCKTIMER
;;		6		wsync
;;		6+83	jsr voice
;;		6+		jsr clocktimer
;;		----
;;		101	(51)
;;
;;	Make AUDV
;;		6		wsync
;;		6+83	jsr voice
;;		6+		jsr makeaudvlut_X
;;		----
;;		101	(51)
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.outer:
;***
;***	START OF NEW FRAME NOW!!
;***
; 0
		;;
		;;	EG Update
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr EG_STATE-1
; 2
		;;
		;;	Frequency update..
		;;
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE
; 4
		;;	Frequency update..
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE1
; 6
		;;	Frequency update..
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	load in process for voice 3
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 8
		sta	WSYNC
		jsr VOICE_EXECUTE
		ldx #2
		jsr SEQ_VoiceLoad
		SETVOICECORE_SEQ
; 10
		;;
		;;	execute voice 1 sequencer processing
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
; 12
		sta	WSYNC
		jsr VOICE_EXECUTE
; 14
		sta	WSYNC
		jsr VOICE_EXECUTE
; 16
		sta	WSYNC
		jsr VOICE_EXECUTE
		SETVOICECORE_NORMAL
; 18
		;;
		;;	unload parameters for voice 2
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_VoiceUnload
		SETEG_JMP
; 20
		;;
		;;	EG Update
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr EG_STATE-1
; 22
		;;
		;;	Frequency update..
		;;
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE
; 24
		;;	Frequency update..
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE1
		;;	Frequency update..
; 26
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Perform Clock, and volume table tasks
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 28
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_CLOCKTIMER
; 30
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr	MakeAUDVLUT_0
		;;	Part 2.
; 32
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr	MakeAUDVLUT_1
		;;	Part 3.
; 34
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr	MakeAUDVLUT_2
; 36
		sta	WSYNC
		jsr VOICE_EXECUTE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Main visible display..	192 lines of it
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 38
		ldx #92
.main:
		sta	WSYNC			;6
		jsr VOICE_EXECUTE	;6+82
;;	Just waste some time...
		lda #$17			;2
		sta COLUBK			;3
		lda #$2F			;2
		sta COLUBK			;3
		lda #$37			;2
		sta COLUBK			;3
		lda #$4F			;2
		sta COLUBK			;3
		lda #$57			;2
		sta COLUBK			;3
		lda #$6F			;2
		sta COLUBK			;3
		lda #$77			;2
		sta COLUBK			;3
		lda #$8F			;2
		sta COLUBK			;3
		lda #$97			;2
		sta COLUBK			;3
		lda #$AF			;2
		sta COLUBK			;3
		lda #$00			;2
		sta COLUBK			;3	(55)
		dex					;2
		bpl	.main			;2/3
							;
							;60
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	load in process Voice 0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ENTRYPOINT:
		SETVOICECORE_NORMAL
; 230
		sta	WSYNC
		jsr VOICE_EXECUTE
		ldx #0
		jsr SEQ_VoiceLoad
		SETVOICECORE_SEQ
; 232
		;;
		;;	execute voice 0 sequencer processing
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
; 234
		sta	WSYNC
		jsr VOICE_EXECUTE
; 236
		sta	WSYNC
		jsr VOICE_EXECUTE
; 238
		sta	WSYNC
		jsr VOICE_EXECUTE
		SETVOICECORE_NORMAL
; 240
		;;
		;;	unload parameters for voice 0
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_VoiceUnload
		SETEG_JMP
; 242
		;;
		;;	EG Update
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr EG_STATE-1
; 244
		;;
		;;	Frequency update..
		;;
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE
; 246
		;;	Frequency update..
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE1
; 248
		;;	Frequency update..
		sta WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_FREQ_UPDATE2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	load in process for voice 2
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 250
		sta	WSYNC
		jsr VOICE_EXECUTE
		ldx #1
		jsr SEQ_VoiceLoad
		SETVOICECORE_SEQ
; 252
		;;
		;;	execute voice 1 sequencer processing
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
; 254
		sta	WSYNC
		jsr VOICE_EXECUTE
; 256
		sta	WSYNC
		jsr VOICE_EXECUTE
; 258
		sta	WSYNC
		jsr VOICE_EXECUTE
		SETVOICECORE_NORMAL
; 260
		;;
		;;	unload parameters for voice 1
		;;
		sta	WSYNC
		jsr VOICE_EXECUTE
		jsr SEQ_VoiceUnload
		SETEG_JMP
; 262
		sta	WSYNC
		jsr VOICE_EXECUTE
		lda	#$02
		sta	VBLANK          ; Turn on VBLANK
		sta	VSYNC           ; Turn VSYNC off
; 264
		sta	WSYNC
		jsr VOICE_EXECUTE
; 266
		sta	WSYNC
		jsr VOICE_EXECUTE
		lda	#$00
		sta	VSYNC           ; Turn VSYNC off
		sta	VBLANK          ; Turn off VBLANK
		jmp	.outer



#if 0
;;
;;	Fast noise generation thoughts modifying the pitch or pulse width
;;	This'll give very Galway style drums by modulating one of the voices..
;;	Optionally the destination can changes dynamically, unfortunately I don't have time for an extra
;;	12 cycles in this core, and this really needs to run at sample-rate or close to it..
;;	Running it once per frame, makes everything sound like paradroid :)
;;
		inc V_NoiseIndex	;5
V_NoiseIndex		=	*+1
V_NoiseTable		=	*+2
		lda NoiseTable		;4
V_NoiseDest			=	*+1
		sta V0_RATE_HI		;3
#endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;	Voice cores, has to go at the end, otherwise we confuse DASM, well not really, but I can't
;;	be arsed to figure out why it's in a mood..
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
VOICE_CORECODE	=	*
		RORG $80
VOICE_CORESTART	=	*
CoreTimer		.byte 0
AUDVLUT			.byte 0,0,0,0,0,0,0,0


;;	Pointer to the current voice that sequencer events write to..
SEQ_VOICE			dc.w V0_BASE

;;
;;	SEQ_SONG & SEQ_PATT EG_STATE are restored and saved before the voice sequencer process..
;;	These can be used outside of the sequencer function, *AFTER* the VOICE_UNLOAD has been done..
;;
MAKEVOL_TMP			=	*
FREQ_TMP			=	*
SEQ_SONG			dc.w 0
SEQ_PATT			dc.w 0

EG_STATE			= *+1
					jmp EG_RELEASE
;;
;;	Big block of Voice specific vars.. Amazing how much you need :-o
;;
V_Song_Hi:			dc.b 0,0,0		; Song Play Order Hi-Byte of *ptr
V_Song_Lo:			dc.b 0,0,0		; Song Play Order Hi-Byte of *ptr
V_Patt_Hi:			dc.b 0,0,0		; Pattern Play Order Hi-Byte of *ptr
V_Patt_Lo:			dc.b 0,0,0		; Pattern Play Order Hi-Byte of *ptr
V_Note:				dc.b 0,0,0		; Current Note value
V_NoteTranspose:	dc.b 0,0,0		; Current Note offset
V_NoteLength:		dc.b 16,16,16	; Current event length
V_Patch:			dc.b 0,0,0		; Current patch offset (patch<<3)
V_WaitTime:			dc.b 0,0,0		; Time to sleep until
V_SeqState:			dc.b <SEQ_NEXTPATTERN,<SEQ_NEXTPATTERN,<SEQ_NEXTPATTERN
V_EG_Lo:			dc.b 0,0,0		; Envelope Generator Lo-Byte
V_EGState:			dc.b <EG_RELEASE,<EG_RELEASE,<EG_RELEASE		; Envelope Generator state *ptr lo-byte only
V_TMP:				dc.b 0,0,0		; Voice temp, maintained between states..

VOICE_EXECUTE:
		;;	Move this clc out of V0 code, so offsets are constant within voices..
		clc					;2		1
		;;
		;;	V0 Update..
		;;
V0_BASE		=	*
V0_COUNT_LO		=	*+1		;
		lda	#$00			;2		2
V0_RATE_LO		=	*+1		;
		adc #$00			;2		2
		sta V0_COUNT_LO		;3		2
V0_COUNT_HI		=	*+1		;
		lda	#$00			;2		2
V0_RATE_HI		=	*+1		;
		adc #$00			;2		2
		sta V0_COUNT_HI		;3		2
V0_PW			=	*+1
		cmp #$80			;2		2
		lda #0				;2		2
		rol					;2		1
		tay					;2		1
							;--		--
							;24		18
		;;
		;;	V1 Update..
		;;
V1_BASE		=	*
V1_COUNT_LO		=	*+1		;
		lda	#$00			;2		2
V1_RATE_LO		=	*+1		;
		adc #$00			;2		2
		sta V1_COUNT_LO		;3		2
V1_COUNT_HI		=	*+1		;
		lda	#$00			;2		2
V1_RATE_HI		=	*+1		;
		adc #$00			;2		2
		sta V1_COUNT_HI		;3		2
V1_PW			=	*+1
		cmp #$80			;2		2
		tya					;2		2
		rol					;2		1
		tay					;2		1
							;--		--
							;22		18
		;;
		;;	V2 Update..
		;;
V2_BASE		=	*
V2_COUNT_LO		=	*+1		;
		lda	#$00			;2		2
V2_RATE_LO		=	*+1		;
		adc #$00			;2		2
		sta V2_COUNT_LO		;3		2
V2_COUNT_HI		=	*+1		;
		lda	#$00			;2		2
V2_RATE_HI		=	*+1		;
		adc #$00			;2		2
		sta V2_COUNT_HI		;3		2
V2_PW			=	*+1
		cmp #$80			;2		2
		tya					;2		2
		rol					;2		1
							;--		--
							;20		17

		;;	The cmp,rol method now means the voice bits are back to front..
		;;	V0 in D2	#$04
		;;	V1 in D1	#$02
		;;	V2 in D0	#$01

		;;
		;;	Lookup the correct AUDV0 output, and set it..
		;;
		;;	The obvious optimisation of using X here instead of Y since there is no ZP,y addressing mode
		;;	doesn't hold water.. The rest of the code benefits from X being the constant voice index, leaving
		;;	Y free. The cost to use X adds up substantially.. Don't do it!!
		;;
		tay					;2		1
		lda AUDVLUT,y		;4		3
		sta AUDV0			;3		2
		;;	We patch the RTS dynamically to save the rts and jump cost of the Sequencer
VOICECORE_EXIT:				;
		rts					;6		1
SEQ_STATE:					;
		dc.w SEQ_STOP
							;--		--
							;14		6
		;;	RTS above is modified into a JMP abs make the jump to SEQ_STATE processing..
							;--		--
							;83		70
		;;	Time for VOICECORE_EXECUTE is 83 Cycles with RTS..	80 Cycles when in SEQMODE and JMP ...
		;;	VOICECORE_EXECUTE also *always* returns with the Carry flag clear..

VOICE_COREEND	=	*
VOICE_CORESIZE	=	VOICE_COREEND-VOICE_CORESTART
		ECHO "VOICE_CORESIZE",VOICE_CORESIZE
		REND

;;
;;	Setup a few constant to easy register indexed access to the voice parameters..
;;
COUNT_LO	=	V0_COUNT_LO-V0_BASE
COUNT_HI	=	V0_COUNT_HI-V0_BASE
RATE_LO		=	V0_RATE_LO-V0_BASE
RATE_HI		=	V0_RATE_HI-V0_BASE
PULSEWIDTH	=	V0_PW-V0_BASE

ROM_END		=	*
ROM_SIZE	=	ROM_END-ROM_START
		ECHO "ROM_SIZE",ROM_SIZE

;;
;;	A few vectors, who knows, maybe one day we'll actually use a break ;)
;;
		ORG $FFFA
		.WORD Reset		; NMI
		.WORD Reset		; RESET
		.WORD Reset		; IRQ
