function convertToFileData(data) {
	var bpsl = (data.getImageDataWidth() + 3) / 4;
	var bytes = [];
	var offset = 0;
	for (var y = 0; y < data.getImageDataHeight(); y++) {
	    for (var x = 0; x < data.getImageDataWidth(); x = x + 4) {
			var c1,c2,c3,c4;
			c1 = data.getPixel(x, y) & 0x3;
			c2 = data.getPixel(x+1, y) & 0x3;
			c3 = data.getPixel(x+2, y) & 0x3;
			c4 = data.getPixel(x+3, y) & 0x3;
			bytes[offset++] = c1 << 6 | c2 << 4 | c3 << 2 | c4; 
	    }
	}
	data.setTargetFileObject(0, bytes);
}