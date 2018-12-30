function convertToFileData(data) {
	var bytes = [];
	var offset = 0;
	var page = 0;
	var block = 0;
	var leaf = 0;
	
	if ( data.getImageDataWidth() !=280
	  || data.getImageDataHeight()!=192 ){
	 return;
	}
	
	for (var y = 0; y < data.getImageDataHeight(); y++) {
		page = y & 0x7;
		block = ((y >> 3) & 0x7);
		leaf = y >> 6;            
		offset = (page*1024) + (block*128) + (leaf*40);

		for (var x = 0; x < data.getImageDataWidth(); x = x + 7) {
			var b = 0;
			for (var i = 0; i < 7; i++) {
				var color;
				color = data.getPixel(x + i, y);
				if (color != 0) {
					b = b | 1 << i;
				}
			}
			bytes[offset++] = b;
		}
	}
	data.setTargetFileObject(0, bytes);
}