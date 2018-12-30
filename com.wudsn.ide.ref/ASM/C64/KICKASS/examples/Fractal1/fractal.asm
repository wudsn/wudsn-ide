//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
// 				Fractal Example for Kick Assembler 
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
	.pc = $0400
	.function toRe(i) .return -2+2.7*[i-floor(i/40)*40]/39
	.function toIm(i) .return -1.6+3.2*floor(i/40)/24
	.function mandelbroot(re,im) {
		.var zr = 0
		.var zi = 0 
		.var iter=0
		.for(;[zr*zr+zi*zi]<4 && iter<20;iter++) { 
			.var newZr = zr*zr-zi*zi + re
			.var newZi = 2*zr*zi + im
			.eval zr = newZr
			.eval zi = newZi
		}
		.var colors = List().add($20,$0f,$20,$08)
		.return colors.get(iter&3) 
	} 
	.fill 25*40,mandelbroot(toRe(i),toIm(i))
