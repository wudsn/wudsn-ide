function convertToFileData(data) {
	var bpsl = (data.getImageDataWidth() + 1) / 2;
	var bytes = [];
	var offset = 0;
	for (var y = 0; y < data.getImageDataHeight(); y++) {
	    for (var x = 0; x < data.getImageDataWidth(); x = x + 2) {
		    var c1 = data.getPixel(x, y);
			var c2 = data.getPixel(x + 1, y);
			var b = c1 << 4 | c2;
			bytes[offset++] = b;
	    }
	}
	data.setTargetFileObject(0, bytes);
}