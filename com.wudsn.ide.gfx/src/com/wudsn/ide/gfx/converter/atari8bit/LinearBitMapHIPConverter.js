function convertToFileData(data) {
	var bpsl = (data.getImageDataWidth() + 1) / 2;
	var bptl = bpsl / 2;
	var bytes = [];
	var offset = 0;
	for (var y = 0; y < data.getImageDataHeight(); y++) {
		for (var x = 0; x < data.getImageDataWidth(); x = x + 4) {
			var c1;
			var c2;
			c1 = data.getPixel(x, y);
			if (x+2 < data.getImageDataWidth() ){
			  c2 = data.getPixel(x+2, y);
			} else {
			  c2 = 0;
			}
			bytes[offset] = (color1 << 4 | color2);
			
			c1 = data.getPixel(x+1, y);
			if (x+3 < data.getImageDataWidth() ){
			  c2 = data.getPixel(x+3, y);
			} else {
			  c2 = 0;
			}
			bytes[offset] = (color1 << 4 | color2);
		 }
		 bytes[offset++] = b;
		}
		offset += bptl;
	}
	data.setTargetFileObject(0, bytes);
}