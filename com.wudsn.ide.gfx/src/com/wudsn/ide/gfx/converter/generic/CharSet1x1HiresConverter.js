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
					var b = 0;
					for (var p = 0; p < 8; p++) {
		    			var color;
		    			color = data.getPixel(c*8+p, r*8+l);
		    			if (color != 0) {
							b = b | 1 << 7 - p;
		    			}
					}
					bytes[offset++] = b;
    			}
			char++;
			}
		}
	}
	data.setTargetFileObject(0, bytes);
}