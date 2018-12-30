;	@com.wudsn.ide.asm.mainsourcefile=MyNESGame-Header.asm

;;;;;;;;;;;;;;;

Sprite1YPos			EQU		$0200
Sprite1Tile			EQU		$0201
Sprite1Atributes	EQU		$0202
Sprite1XPos			EQU		$0203


;;;;;;;;;;;;;;;
		
	
	;bank 0
	org $C000 
RESET:
	SEI          ; disable IRQs
	CLD          ; disable decimal mode
	LDX #$40
	STX $4017    ; disable APU frame IRQ
	LDX #$FF
	TXS          ; Set up stack
	INX          ; now X = 0
	STX $2000    ; disable NMI
	STX $2001    ; disable rendering
	STX $4010    ; disable DMC IRQs

vblankwait1:       ; First wait for vblank to make sure PPU is ready
	BIT $2002
	BPL vblankwait1

clrmem:
	LDA #$00
	STA $0000, x
	STA $0100, x
	STA $0300, x
	STA $0400, x
	STA $0500, x
	STA $0600, x
	STA $0700, x
	LDA #$FE
	STA $0200, x
	INX
	BNE clrmem
	 
vblankwait2:      ; Second wait for vblank, PPU is ready after this
	BIT $2002
	BPL vblankwait2


LoadPalettes:
	LDA $2002             ; read PPU status to reset the high/low latch
	LDA #$3F
	STA $2006             ; write the high byte of $3F00 address
	LDA #$00
	STA $2006             ; write the low byte of $3F00 address
	LDX #$00              ; start out at 0
LoadPalettesLoop:
	LDA palette, x        ; load data from address (palette + the value in x)
													; 1st time through loop it will load palette+0
													; 2nd time through loop it will load palette+1
													; 3rd time through loop it will load palette+2
													; etc
	STA $2007             ; write to PPU
	INX                   ; X = X + 1
	CPX #$20              ; Compare X to hex $10, decimal 16 - copying 16 bytes = 4 sprites
	BNE LoadPalettesLoop  ; Branch to LoadPalettesLoop if compare was Not Equal to zero
												; if compare was equal to 32, keep going down



LoadSprites:
	LDX #$00              ; start at 0
LoadSpritesLoop:
	LDA sprites, x        ; load data from address (sprites +  x)
	STA $0200, x          ; store into RAM address ($0200 + x)
	INX                   ; X = X + 1
	CPX #$10              ; Compare X to hex $10, decimal 16
	BNE LoadSpritesLoop   ; Branch to LoadSpritesLoop if compare was Not Equal to zero
												; if compare was equal to 16, keep going down
							
							

LoadBackground:
	LDA $2002             ; read PPU status to reset the high/low latch
	LDA #$20
	STA $2006             ; write the high byte of $2000 address
	LDA #$00
	STA $2006             ; write the low byte of $2000 address

	LDA #$00
	STA pointerLo       ; put the low byte of the address of background into pointer
	LDA #>background
	STA pointerHi       ; put the high byte of the address into pointer
	
	LDX #$00            ; start at pointer + 0
	LDY #$00
OutsideLoop:
	
InsideLoop:
	LDA (pointerLo), y  ; copy one background byte from address in pointer plus Y
	STA $2007           ; this runs 256 * 4 times
	
	INY                 ; inside loop counter
	CPY #$00
	BNE InsideLoop      ; run the inside loop 256 times before continuing down
	
	INC pointerHi       ; low byte went 0 to 256, so high byte needs to be changed now
	
	INX
	CPX #$04
	BNE OutsideLoop     ; run the outside loop 256 times before continuing down

							
							
							
	LDA #%10010000   ; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
	STA $2000

	LDA #%00011110   ; enable sprites, enable background, no clipping on left side
	STA $2001

;----------------------------------------------------------------------
;------------------------START MAIN LOOP-------------------------------
;----------------------------------------------------------------------

Main:
		LDA #$01
		STA updating_background          ;this is for when you are changing rooms or something, not really needed here
										 ;it will skip the NMI updates so as not to mess with your room loading routines

		JSR ReadJoyPads

		;JSR GameStateIndirect

		LDA GameState
		CMP GameStateOld
		BEQ @next

		;JSR GameStateUpdate

	@next:

	  	LDA #$00
		STA updating_background 
	
	
	INC bIsSleeping                     ;Wait for NMI (Main Goes To Sleep)
		@loop:
			LDA bIsSleeping
			BNE @loop                        ;Program continues when NMI clears flag

		JMP Main     ;Wake Up and Update for next frame

	
;---------Read Pads 1 & 2-------------------------------------------------- 
ReadJoyPads:
	ldx #$00			;Load x with #$00. Used to read status of joypad 1.
	stx $01				;
	jsr @ReadOnePad		;
	inx					;Load x with #$01. Used to read status of joypad 2.
	inc $01				;

@ReadOnePad:
	ldy #$01			;These lines strobe the -->       
	sty CPUJOYPAD1   	;joystick to enable the -->
	dey					;program to read the -->
	sty CPUJOYPAD1  	;buttons pressed.
		
	ldy #$08			;Do 8 buttons.
	@a:	pha					;Store A.
		lda CPUJOYPAD1,x	;Read button status. Joypad 1 or 2.
		sta $00				;Store button press at location $00.
		lsr					;Move button push to carry bit.
		ora $00				;If joystick not connected, -->
		lsr					;fills Joy1Status with all 1s.
		pla					;Restore A.
		rol					;Add button press status to A.
		dey     			;Loop 8 times to get -->
		bne @a				;status of all 8 buttons.

			ldx $01				;Joypad #(0 or 1).
			ldy Joy1Status,x	;Get joypad status of previous refresh.
			sty $00				;Store at $00.
			sta Joy1Status,x	;Store current joypad status.
			eor $00				;
			beq @b	   			;Branch if no buttons changed.
			lda $00				;			
			and #$BF			;Remove the previous status of the B button.
			sta $00				;
			eor Joy1Status,x	;
		@b:	and Joy1Status,x	;Save any button changes from the current frame-->
			sta Joy1Change,x	;and the last frame to the joy change addresses.
			;sta Joy1Retrig,x	;Store any changed buttons in JoyRetrig address.
			;ldy #$20			;
			;lda Joy1Status,x	;Checks to see if same buttons are being-->
			;cmp $00				;pressed this frame as last frame.-->
			;bne @c				;If none, branch.
			;dec RetrigDelay1,x	;Decrement RetrigDelay if same buttons pressed.
			;bne @exit				;		
			;sta Joy1Retrig,x	;Once RetrigDelay=#$00, store buttons to retrigger.
			;ldy #$08			;
		;@c	;sty RetrigDelay1,x	;Reset retrigger delay to #$20(32 frames)-->
		@exit	rts					;or #$08(8 frames) if already retriggering.

;*************************************************
; NMI
;*************************************************
NMI:
	php				;Save processor status, A, X and Y on stack.
	pha				;Save A.
	txa				;
	pha				;Save X.
	tya				;
	pha				;Save Y.
	
	lda #$00			;
	sta SPRADDRESS			;Sprite RAM address = 0.
	lda #$02			;
	sta SPRDMAREG			;Transfer page 2 ($200-$2FF) to Sprite RAM.
	lda bIsSleeping			;
	bne ++				;Skip if the frame couldn't finish in time.
	lda GameState			;
	beq +				;Branch if mode=Play.
	;jsr NMIScreenWrite		;($9A07)Write end message on screen(If appropriate).
+	;jsr CheckPalWrite		;($C1E0)Check if palette data pending.
	;jsr CheckPPUWrite		;($C2CA)check if data needs to be written to PPU.
	
	;----------------
	; PPU Cleanup
	;----------------

	;This is the PPU clean up section, so rendering the next frame starts properly.
	LDA #%10010000					; enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
	STA $2000
	LDA #%00011110					; enable sprites, enable background, no clipping on left side
	STA $2001
	LDA #$00							;tell the ppu there is no background scrolling
	STA $2005
	STA $2005
			
	;----------------
	; End PPU Cleanup
	;----------------
		
	;jsr WriteScroll			;($C29A)Update h/v scroll reg.
	;jsr ReadJoyPads			;($C215)Read both joypads.
++ 	;jsr SoundEngine			;($B3B4)Update music and SFX.
	;jsr UpdateAge			;($C97E)Update Samus' age.
	ldy #$00			; NMI = finished.
	sty bIsSleeping			;
	
	pla				;Restore Y.
	tay				;
	pla				;Restore X.
	tax				;
	pla				;restore A.
	plp				;Restore processor status flags.
	rti				;Return from NMI.
;*************************************************
; End NMI
;*************************************************
	
	
	
	
;--------------------------------[ Simple divide and multiply routines ]-----------------------------

Adiv32:
	lsr				;Divide by 32.
Adiv16:
	lsr				;Divide by 16.
Adiv8:
	lsr				;Divide by 8.
	lsr				;
	lsr				;Division falls through and returns
	rts				;

	
Amul32: 
	asl				;Multiply by 32.
Amul16: 
	asl				;Multiply by 16.
Amul8:
	asl				;Multiply by 8.
	asl				;
	asl				;Multiplication falls through and returns
	rts				;

	
;*************************************************
; Start PPU Section
;*************************************************
	pad $E000
background:
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 01 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 02 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 03 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 04 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 05 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 06 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 07 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 08 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 09 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 10 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 11 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 12 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 13 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 14 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 15 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 16 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 17 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 18 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 19 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 20 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 21 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 22 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 23 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 24 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 25 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 26 all sky
	db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 27 some brick tops
	db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 28 brick bottoms
	
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 29 all sky
	db $24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24  ;; Row 30 all sky
	;db $24,$24,$24,$24,$45,$45,$24,$24,$45,$45,$45,$45,$45,$45,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$53,$54,$24,$24  ;; Row 31 some brick tops
	;db $24,$24,$24,$24,$47,$47,$24,$24,$47,$47,$47,$47,$47,$47,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$24,$55,$56,$24,$24  ;; Row 32 brick bottoms
	

attribute:
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 01-04
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 05-08
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 09-12
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 13-16
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 17-20
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 21-24
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 25-28
	db %00000000, %00010000, %01010000, %00010000, %00000000, %00000000, %00000000, %00110000 ; Rows 29-32

 ; db $24,$24,$24,$24, $47,$47,$24,$24 
 ; db $47,$47,$47,$47, $47,$47,$24,$24 
	;db $24,$24,$24,$24 ,$24,$24,$24,$24
	;db $24,$24,$24,$24, $55,$56,$24,$24  ;;brick bottoms (What is this??)
	;db $47,$47,$47,$47, $47,$47,$24,$24 
	;db $24,$24,$24,$24 ,$24,$24,$24,$24
	;db $24,$24,$24,$24, $55,$56,$24,$24 

palette:
	db $22,$29,$1A,$0F,  $22,$36,$17,$0F,  $22,$30,$21,$0F,  $22,$27,$17,$0F   ;;background palette
	db $22,$1C,$15,$14,  $22,$02,$38,$3C,  $22,$1C,$15,$14,  $22,$02,$38,$3C   ;;sprite palette

sprites:
		 ;vert tile attr horiz
	db $80, $32, $00, $80   ;sprite 0
	db $80, $33, $00, $88   ;sprite 1
	db $88, $34, $00, $80   ;sprite 2
	db $88, $35, $00, $88   ;sprite 3
	
;*************************************************
; End PPU Section
;*************************************************
