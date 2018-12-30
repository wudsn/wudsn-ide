//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// 				Bitmap Fractal Example for Kick Assembler 
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
	.const imCenter = 0
	.const reCenter = 0
	.const zoom = 2        // lower = more zoom

//----------------------------------------------------------------------------
// 				Display the fractal 
//----------------------------------------------------------------------------
	.pc = $0801 "Basic Upstart Program"
	:BasicUpstart($0810)

	.pc = $0810 "Display Program"
	lda #$18
	sta $d018
	lda #$d8
	sta $d016
	lda #$3b
	sta $d011
	
	lda #BLACK
	sta $d021
	sta $d020
	ldx #0
loop:
	.for (var i=0; i<4; i++) {
		lda #GRAY | LIGHT_GRAY<<4 
		sta $0400+$100*i,x
		lda #DARK_GRAY
		sta $d800+$100*i,x
	}
	inx
	bne loop
	jmp *




//----------------------------------------------------------------------------
// 				Calculate the fractal 
//----------------------------------------------------------------------------
	.pc = $2000 "Fractal Image"
	.const colors = List().add(%11,%01,%10,%00)
	.function mandelbrot(re,im) {
		.var zr = 0
		.var zi = 0 
		.var iter=0
		.for(;[zr*zr+zi*zi]<4 && iter<18;iter++) {
			.var newZr = zr*zr-zi*zi + re
			.var newZi = 2*zr*zi + im
			.eval zr = newZr
			.eval zi = newZi
		}
		.return colors.get(iter&3) 
	}
	
	.function map(x, width, targetCenter, targetWidth) {
		.return [targetCenter-targetWidth/2] + targetWidth *[x/[width-1]] 
	}


// Alternative 1: Do it in asm mode - takes lots of memory and lots of time 
/*
.for (var screenY=0; screenY<32; screenY++)
	.for (var screenX=0; screenX<40; screenX++)
		.for (var charY=0; charY<8; charY++) {
			.var byteValue = $00
			.for (var charX=0; charX<4; charX++){
				.var x = charX+screenX*4
				.var y = charY+screenY*8
				.var re = map(x,160,reCenter,zoom)
				.var im = map(y,200,imCenter,zoom)
				.eval byteValue = byteValue | [mandelbrot(re,im)<<[6-charX*2]]			
			}
			.byte byteValue
		}
*/


// Alternative 2: Do it in function mode (using define) - faster and uses less memory
	.define fractalData {
		.var fractalData = List()
		.for (var screenY=0; screenY<25; screenY++)
			.for (var screenX=0; screenX<40; screenX++)
				.for (var charY=0; charY<8; charY++) {
					.var byteValue = $00
					.for (var charX=0; charX<4; charX++){
						.var x = charX+screenX*4
						.var y = charY+screenY*8
						.var re = map(x,160,reCenter,zoom)
						.var im = map(y,200,imCenter,zoom)
						.eval byteValue = byteValue | [mandelbrot(re,im)<<[6-charX*2]]			
					}
					.eval fractalData.add(byteValue)
				}
	}
	.fill 8*25*40,fractalData.get(i)




/*
// Alternative 3: Another way of doing it in function mode
.function calculateFillByte(i) {
	.var charY = i&7
	.var screenX = mod(i>>3,40) 
	.var screenY = floor([i>>3]/40)
	.var y = charY+screenY*8
	.var im = map(y,200,imCenter,zoom)
	.var byteValue = 0
	.for (var charX=0 ; charX<4; charX++ ) {
		.var x = charX+screenX*4
		.var re = map(x,160,reCenter,zoom) 
		.eval byteValue = byteValue | [mandelbrot(re,im)<<[6-charX*2]]		
	}	
	.return byteValue	
}	
.fill 8*25*40,calculateFillByte(i)

*/



