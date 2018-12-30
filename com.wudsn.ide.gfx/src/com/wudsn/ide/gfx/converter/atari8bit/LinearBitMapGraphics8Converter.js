function convertToFileData(data) {
	var bpsl = (data.getImageDataWidth() + 7) / 8;
	var bytes = [];
	var offset = 0;
	for (var y = 0; y < data.getImageDataHeight(); y++) {
	    for (var x = 0; x < data.getImageDataWidth(); x = x + 8) {
			var b = 0;
			for (var p = 0; p < 8; p++) {
			    var color;
			    color = data.getPixel(x + p, y);
			    if (color != 0) {
					b = b | 1 << 7 - p;
			    }
			}
			bytes[offset++] = b;
	    }
	}
	data.setTargetFileObject(0, bytes);
}