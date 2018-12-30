function convertToFileData(data) {
	var columns = data.getImageDataWidth()  / 8;
	var rows    = data.getImageDataHeight() / 8;
	var chars   = 256;

	var char = 0;
	var bytes = [];
	var offset = 0;
	for (var r = 0; r < rows; r++) {
		for (var c = 0; c < columns; c++) {
			if (char < chars) {
				for (var l=0;l<8;l++) {
					var b;
					var x,y,c1,c2,c3,c4;
					x = c*4;
					y = r*8 + l;
					c1 = data.getPixel(x, y) & 0x3;
					c2 = data.getPixel(x+1, y) & 0x3;
					c3 = data.getPixel(x+2, y) & 0x3;
					c4 = data.getPixel(x+3, y) & 0x3;
					b = c1 << 6 | c2 << 4 | c3 << 2 | c4; 
					bytes[offset++] = b;
    			}
			char++;
			}
		}
	}
	data.setTargetFileObject(0, bytes);
}