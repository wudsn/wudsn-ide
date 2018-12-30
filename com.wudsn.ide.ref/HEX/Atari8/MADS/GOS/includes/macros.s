;	@com.wudsn.ide.asm.mainsourcefile=gui.s

; macros
;
pushb	.macro	; push byte onto stack
	lda :1
	pha
	.endm
	
pullb	.macro	; pull byte from stack
	pla
	sta :1
	.endm


pushw	.macro 	; push word onto stack
	lda :1
	pha
	lda :1+1
	pha
	.endm

pullw	.macro	; pull word from stack
	pla
	sta :1+1
	pla
	sta :1
	.endm

stax	.macro 	; store a,x pair
	sta :1
	stx :1+1
	.endm
	
	
stxy	.macro ; store x,y pair
	stx :1
	sty :1+1
	.endm


ldax	.macro	" "	; load a,x pair
	.if :1 = '#'
		lda < :2
		ldx > :2
	.else
		lda :2
		ldx :2+1
	.endif
	.endm
	
ldxy	.macro " " ; load x,y pair
	.if :1 = '#'
		ldx <:2
		ldy >:2
	.else
		ldx :2
		ldy :2+1
	.endif
	.endm


fset	.macro 	; set a flag
	sec
	ror :1
	.endm
;

sfg	.macro 	; set a flag
	sec
	ror :1
	.endm
	

clr	.macro   ; clear a flag
	lsr :1
	.endm


bfs	.macro 	; branch if flag set
	bit :1
	bmi :2
	.endm


bfc	.macro	; branch if flag clear
	bit :1
	bpl :2
	.endm


addless1	.macro
	clc
	lda :1
	adc :2
	tax
	lda :1+1
	adc :2+1
	cpx #1
	sbc #0
	sta :3+1
	dex
	stx :3
	.endm
	
	


cmps16	.macro	" "	; signed 16-bit compare
	.if :1 = "#"
		lda #< :2
		cmp :4
		lda #> :2
		sbc :4+1
	.else
		.if :3 = "#"
			lda :2
			cmp #< :4
			lda :2+1
			sbc #> :4
		.else
			lda :2
			cmp :4
			lda :2+1
			sbc :4+1
		.endif
	.endif
	svc
	eor #$80 ; bmi if :1 < :2, bpl if :1 >= :2
	.endm

	
subs16 	.macro 	" " ; signed 16-bit subtraction
	.if .not :0 = 4 .or :0 = 6
		.error 'Wrong Number of Arguments!'
	.else
		.if :0 = 4 ; two arguments
			.if :3 = '#' ; immediate mode
				lda :2
				sec
				sbc #< :4
				sta :2
				lda :2+1
				sbc #> :4
				sta :2+1
			.else
				lda :2
				sec
				sbc :4
				sta :2
				lda :2+1
				sbc :4+1
				sta :2+1
			.endif
				bvc *+4
				eor #$80
				sta :4+1
		.else ; three arguments
			.if :3 = '#' ; immediate mode
				lda :2
				sec
				sbc #< :4
				sta :6
				lda :2+1
				sbc #> :4
				sta :6+1
			.else
				lda :2
				sec
				sbc :4
				sta :6
				lda :2+1
				sbc :4+1
				sta :6+1
			.endif		
			bvc *+4
			eor #$80
			sta :4+1	
		.endif
	.endm
	


; Window Put/Get
	
WinPutB	.macro ; WinPutB Field
	ldy #:1
	sta (WindowHandle),y
	.endm
	
WinGetB	.macro ; WinGetB Field
	ldy #:1
	lda (WindowHandle),y
	.endm
	
WinPutAX	.macro ; WinPutAX Field (value in a,x)
	ldy #:1
	sta (WindowHandle),y
	iny
	txa
	sta (WindowHandle),y
	.endm
	
	
WinGetAX	.macro ; WinGetAX Field (returns value in a,x)
	ldy #:1+1
	lda (WindowHandle),y
	tax
	dey
	lda (WindowHandle),y
	.endm

; Object Put/Get
	
ObjPutB	.macro ; ObjPutB Field
	ldy #:1
	sta (WindowHandle),y
	.endm
	
ObjGetB	.macro ; ObjGetB Field
	ldy #:1
	lda (WindowHandle),y
	.endm
	
ObjPutAX	.macro ; ObjPutAX Field (value in a,x)
	ldy #:1
	sta (WindowHandle),y
	iny
	txa
	sta (WindowHandle),y
	.endm
	
	
ObjGetAX	.macro ; ObjGetAX Field (returns value in a,x)
	ldy #:1+1
	lda (WindowHandle),y
	tax
	dey
	lda (WindowHandle),y
	.endm

	

;sendmsg	.macro	; send message to object
;	lda #MESSAGE.:1
;	jsr send_message
;	.endm
	

setobj	.macro	; set object to var
	; setobj var
	lda :1
	sta object
	lda :1+1
	sta object+1
	.endm


setword 	.macro ; set word to value
	; setword var, value
	lda #< :2
	sta :1
	lda #> :2
	sta :1+1
	.endm
	
setbyte	.macro ; set byte to value
	; setbyte var, value
	lda #:2
	sta :1
	.endm
	
	
//
//	Test and set semaphore
//	Wait [sempaphore]
//

.macro Wait
?Wait	sei	; critical section
	lda :1
	bne @+	; if not 0, set to 0 and continue
	cli
	Syscall Kernel.SoftInterrupt	; otherwise yield CPU
	jmp ?Wait
@
	dec :1
	cli
.endm



//
//	Release semaphore
//	Signal [semaphore]
//

.macro	Signal
	mva #1 :1
.endm



	

	.if 0
ljsr	.macro ; do a long JSR if target label is in different bank
This
	.if [=:1] = [=This]
		jsr :1
	.else
		sta BSaveA ; save accumulator
		stx BSaveX
;		sty BSaveY
		ldx #< [:1-1]
		lda #> [:1-1]
		ldy #= :1 ; get bank number
		jsr :LongJSR
	.endif
	.endm
	.endif
	
ljsr	.macro ; do a long JSR if target label is in a different bank
This
	.if [=:1] = [=This]
		jsr :1
	.else
		jsr :LongJSR
		.byte =:1
		.word :1
	.endif
	.endm


ljmp	.macro ; do a long JMP if a label is in a different bank
	ldx #< [:1-1]
	lda #> [:1-1]
	ldy #= :1 ; get bank number
	jmp LongJMP
	.endm


Target	.macro ; add a table entry with address and bank number
	.word :1
	.byte = :1
	.endm
	
NextDataBank	.macro ; fill remainder of 8KB ROM bank with $FF
	.align $C000,$FF
	opt f-
	org $A000 ; reset origin
	opt f+
	nmb ; bump assembler's bank counter
	.endm
	
	
LastDataBank	.macro ; fill remainder of 8KB ROM bank with $FF
	.align $BFF0,$FF
	.endm	
	
	
NextBank	.macro ; fill remainder of 8KB ROM bank with $FF and add cart header
	.align $BFF0,$FF
CartInit
	lda #$ff
	sta $D500 ; reset to bank 0
	jmp :CartStart
	.byte 0,0
	.word $A000 ; CartStart
	.byte 0
	.byte 0 ; bit 0 = disk boot, bit 2 = cart start (otherwise init only)
	.word CartInit
	opt f-
	org $A000 ; reset origin
	opt f+
	nmb ; bump assembler's bank counter
	.endm


LastBank	.macro ; fill remainder of 8KB ROM bank with $FF and add cart header
	.align $BFF0,$FF
CartInit
	lda #$ff
	sta $D500 ; reset to bank 0
	jmp :CartStart
	.byte 0,0
	.word $A000 ; CartStart
	.byte 0
	.byte 0 ; bit 0 = disk boot, bit 2 = cart start (otherwise init only)
	.word CartInit
	.endm
	
	
RAMBankIn	.macro ; cache current RAM bank and switch in specified bank
	.if InlineRAMBanking ; this needs to be done inside or outside of subroutine calls
		lda portb
		pha
		ldy :1
		lda RAMTab,y
		sta portb
	.else
		ldx :1
		jsr BankIn
	.endif
	.endm
	
	
RAMBankOut	.macro ; restore cached RAM bank (must be paired with RAMBankIn call)
	.if InlineRAMBanking
		pla
		sta portb
	.else
		jsr BankOut
	.endif
	.endm
	
SysCall	.macro ; call kernel via soft-IRQ
	jsr KernelCall
;	brk
	.byte :1
	.endm
	
	
;
;	DefSym Value,Flags,Next,'Name'
;

DefSym .macro
	.dword :1
	.byte :2
	.word :3
	.byte :4
	.byte 0
	.endm

	
DefMenuItem .macro Flags,Text,Value,Size
	.byte :Flags
	.word :Text
	.word :Value
	.word :Size
	.endm
	
DefWindowData	.macro Status,Flags,Attributes,Appearance,ProcessID,x,y,Width,Height,ClientX,ClientY,ClientWidth,ClientHeight,WorkXOffs,WorkYOffs,WorkWidth,WorkHeight,MinWidth,MinHeight,MaxWidth,MaxHeight,RectList,Title,Info,WinContent
	.byte :Status
	.byte :Flags
	.byte :Attributes
	.byte :Appearance
	.byte :ProcessID
	.word :x
	.word :y
	.word :Width
	.word :Height
	.word :ClientX
	.word :ClientY
	.word :ClientWidth
	.word :ClientHeight
	.word :WorkXOffs
	.word :WorkYOffs
	.word :WorkWidth
	.word :WorkHeight
	.word :MinWidth
	.word :MinHeight
	.word :MaxWidth
	.word :MaxHeight
	.byte :RectList
	.word :Title
	.word :Info
	.word :WinContent
	.endm



DefControlGroup	.macro Controls,ProcessID,Data,Calc,ReturnObj,EscObj,FocusObj
	.byte :Controls
	.byte :ProcessID
	.word :Data
	.word :Calc
	.byte :ReturnObj
	.byte :EscObj
	.byte :FocusObj
	.endm
	


DefControlData	.macro Value,Type,Bank,ObSpec,x,y,Width,Height
	.word :Value
	.byte :Type
	.byte :Bank
	.word :ObSpec
	.word :x
	.word :y
	.word :Width
	.word :Height
	.endm
	

DefIconControl	.macro Flags,Image,Text
	.byte :Flags
	.word :Image
	.word :Text
	.endm

	