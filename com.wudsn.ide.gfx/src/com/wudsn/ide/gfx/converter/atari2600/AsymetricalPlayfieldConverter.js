function convertToFileData(data) {
	var lineHeight = 5; // Height of a single text line
	var lineSpacing = 1; // Space between two text lines
	var lineFullHeight = lineHeight + lineSpacing; // Full height of a text line
	var lines = java.lang.Math.floor((data.getImageDataHeight() + lineHeight) / lineFullHeight); // Number of text lines
	var scanLines = lines * lineHeight;
	var columnOffsets= [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5, 5, 5];
	var columnBits   = [0x10,0x20,0x40,0x80,0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01,0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x10,0x20,0x40,0x80,0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01,0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80];
	var bytes = [];
	var offset = 0;

	for (var l = 0; l < lines; l = l + 1) {
		var y = l * lineFullHeight;
		for (var m = 0; m < lineHeight; m++) {
			var b = [0,0,0,0,0,0];
	    		for (var x = 0; x < data.getImageDataWidth() && x < 40; x = x + 1) {
			    	var color;

				if (y+m < data.getImageDataHeight()){
			  	  	color = data.getPixel(x, y + m);
				} else {
					color = 0;
				}

			    	if (color != 0) {
					var o = columnOffsets[x];
					b[o] = b[o] | columnBits[x];
			    	}
			}
			bytes[offset+scanLines*0] = b[0];
			bytes[offset+scanLines*1] = b[1];
			bytes[offset+scanLines*2] = b[2];
			bytes[offset+scanLines*3] = b[3];
			bytes[offset+scanLines*4] = b[4];
			bytes[offset+scanLines*5] = b[5];
			offset =offset + 1;
		}
	}
	data.setTargetFileObject(0, bytes);
}