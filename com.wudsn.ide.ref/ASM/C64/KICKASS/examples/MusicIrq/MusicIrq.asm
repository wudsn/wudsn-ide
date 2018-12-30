.pc =$0801 "Basic Upstart Program"
:BasicUpstart($4000)

//----------------------------------------------------------
//----------------------------------------------------------
//					Simple IRQ
//----------------------------------------------------------
//----------------------------------------------------------
.pc = $4000 "Main Program"

			lda #$00
			sta $d020
			sta $d021
			lda #$00
			jsr $1000	// init music
			sei
			lda #<irq1
			sta $0314
			lda #>irq1
			sta $0315
			asl $d019
			lda #$7b
			sta $dc0d
			lda #$81
			sta $d01a
			lda #$1b
			sta $d011
			lda #$80
			sta $d012
			cli
this:	jmp this
//----------------------------------------------------------
irq1:  	
			asl $d019
			:SetBorderColor(2)
			jsr $1003 // play music
			:SetBorderColor(0)
			pla
			tay
			pla
			tax
			pla
			rti
			
//----------------------------------------------------------
.pc=$1000 "Music"
.import binary "ode to 64.bin"

//----------------------------------------------------------
// A little macro
	.macro SetBorderColor(color) {
		lda #color
		sta $d020
	}