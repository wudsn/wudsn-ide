	.pc = $0801 "Basic Upstart"
	:BasicUpstart($4000)

//----------------------------------------------------------
//----------------------------------------------------------
//	Pre Calculated Vector
//----------------------------------------------------------
//----------------------------------------------------------


	.pc = $4000 "Main Program"
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
	lda #$20
	sta $d012
	lda #$00
	sta $d020
	sta $d021
	jsr InitSprites

	cli
 	jmp *
//----------------------------------------------------------
irq1:  	
	asl $d019
	inc $d020
	
	ldx frameNr
	jsr PlaceSprites
	inc frameNr
	lda #0
	sta $d020
	
	pla
	tay
	pla
	tax
	pla
	rti
frameNr: .byte 0

InitSprites: 
	lda #$ff	// Turn on Sprites
	sta $d015

	lda #$00	// Set single color
	sta $d01c 


	lda #$00	// No x and y expansion
	sta $d017	
	sta $d01d
	
	ldx #7
!loop:
	lda #$f			// Set sprite color
	sta $d027,x	
	lda #$0fc0/$40	// Set sprite image
	sta $07f8,x
	dex
	bpl !loop-
	rts
	
PlaceSprites:

	.for (var i=0; i<8;i++) {
		lda cubeCoords+i*$200,x
		sta $d000+i*2		
		lda cubeCoords+$100+i*$200,x
		sta $d001+i*2		
	}
	rts	
	

//-----------------------------------------------------------------------------------------
// Objects 
//-----------------------------------------------------------------------------------------
	.var Cube = List().add( Vector(1,1,1), Vector(1,1,-1), Vector(1,-1,1), Vector(1,-1,-1), Vector(-1,1,1), Vector(-1,1,-1), Vector(-1,-1,1), Vector(-1,-1,-1))


//------------------------------------------------------------------------------------------
// Macro for doing the precalculation
//------------------------------------------------------------------------------------------
	.macro PrecalcObject(object, animLength, nrOfXrot, nrOfYrot, nrOfZrot) {

	// Rotate the coordinate and place the coordinates of each frams in a list
	.define frames {
		.var frames = List()
		.for (var frameNr=0; frameNr<animLength;frameNr++) {
			// Set up the transform matrix
			.var aX = toRadians(frameNr*360*nrOfXrot/animLength)
			.var aY = toRadians(frameNr*360*nrOfYrot/animLength)
			.var aZ = toRadians(frameNr*360*nrOfZrot/animLength)
			.var zp = 2.5	// z coordinate for the projection plane
			.var m = ScaleMatrix(120,120,0)*PerspectiveMatrix(zp)*MoveMatrix(0,0,zp+5)*RotationMatrix(aX,aY,aZ) 		
	
			// Transform the coordinates		
			.var coords = List()
			.for (var i=0; i<object.size(); i++) {
				.eval coords.add(m*object.get(i))				
			}
			.eval frames.add(coords)
		}
	}

	// Dump the list to the memory
	.for (var coordNr=0; coordNr<object.size(); coordNr++) {
		.for (var xy=0;xy<2; xy++) {
			.fill animLength, $80+round(frames.get(i).get(coordNr).get(xy))
		}
	}
	
	}
//-------------------------------------------------------------------------------
// The vector data
//-----------------------------------------------------------------------------------------
	.align $100
cubeCoords: :PrecalcObject(Cube,256,2,-1,1)

//-------------------------------------------------------------------------------
// Sprite bob
//-----------------------------------------------------------------------------------------
	.pc = $0fc0 "Sprite data"

	.byte %01110000, %00000000, %00000000
	.byte %11111000, %00000000, %00000000
	.byte %11111000, %00000000, %00000000
	.byte %01110000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000
	.byte %00000000, %00000000, %00000000



