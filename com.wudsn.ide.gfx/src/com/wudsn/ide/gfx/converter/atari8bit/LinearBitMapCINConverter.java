/**
 * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
 *
 * This file is part of WUDSN IDE.
 * 
 * WUDSN IDE is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 * 
 * WUDSN IDE is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with WUDSN IDE.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.wudsn.ide.gfx.converter.atari8bit;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.FilesConverterParameters.SourceFile;
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;

/**
 * Converter for CCI and CIN files.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.0
 */
public class LinearBitMapCINConverter extends LinearBitMapConverter {

    public LinearBitMapCINConverter() {

    }

    private boolean isCIN(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 16384;
    }

    private boolean isCCI(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length > 7 && bytes[0] == 'C' && bytes[1] == 'I' && bytes[2] == 'N' && bytes[3] == ' '
		&& bytes[4] == '1' && bytes[5] == '.' && bytes[6] == '2' && bytes[7] == ' ';
    }

    private boolean unpackCCI(byte[] bytes, int offset, byte[] unpackedImage) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	if (offset < 0) {
	    throw new IllegalArgumentException("Parameter 'offset' must not be negative. Specified value is " + offset
		    + ".");
	}
	if (unpackedImage == null) {
	    throw new IllegalArgumentException("Parameter 'unpackedImage' must not be null.");
	}
	// Compressed even lines of graphics 15 frame
	int dataOffset = offset + 8;
	int dataLength = Atari8BitUtility.getWord(bytes, dataOffset);
	if (!Atari8BitUtility.unpackCCI(bytes, dataOffset + 2, dataLength, 80, 96, unpackedImage, 0)) {
	    return false;
	}

	// Compressed odd lines of graphics 15 frame
	dataOffset += 2 + dataLength;
	dataLength = Atari8BitUtility.getWord(bytes, dataOffset);
	if (!Atari8BitUtility.unpackCCI(bytes, dataOffset + 2, dataLength, 80, 96, unpackedImage, 40)) {
	    return false;
	}

	// Compressed graphics 11
	dataOffset += 2 + dataLength;
	dataLength = Atari8BitUtility.getWord(bytes, dataOffset);
	if (!Atari8BitUtility.unpackCCI(bytes, dataOffset + 2, dataLength, 40, 192, unpackedImage, 7680)) {
	    return false;
	}

	/* compressed color values for gr15 */
	dataOffset += 2 + dataLength;
	dataLength = Atari8BitUtility.getWord(bytes, dataOffset);
	if (!Atari8BitUtility.unpackCCI(bytes, dataOffset + 2, dataLength, 1, 0x400, unpackedImage, 0x3C00)) {
	    return false;
	}

	dataOffset += 2 + dataLength;
	return dataOffset == bytes.length;
    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return isCIN(bytes) || isCCI(bytes);
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}

	setImageSizeAndPalette(data, 40, 192, Palette.TRUE_COLOR, null);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * 4);
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	byte[] bytes = data.getSourceFileBytes(BIT_MAP_FILE);
	if (bytes == null) {
	    return false;
	}

	byte[] unpackedImage;
	SourceFile sourceFile = data.getParameters().getSourceFile(BIT_MAP_FILE);
	int offset = sourceFile.getOffset();

	if (isCCI(bytes)) {
	    unpackedImage = new byte[16384];
	    if (!unpackCCI(bytes, offset, unpackedImage)) {
		return false;
	    }
	} else {
	    unpackedImage = bytes;
	}
	int xpixels = 4;
	PaletteMapper paletteMapper = new Atari8BitPaletteMapper();

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		if (offset + 7680 >= unpackedImage.length) {
		    return true;
		}
		int b1 = unpackedImage[offset + 7680] & 0xff;
		int b2 = unpackedImage[offset++] & 0xff;

		for (int x2 = 0; x2 < 4; x2++) {
		    int x = x1 * xpixels + x2;
		    int x3 = x2 >>> 1;
		    int hue = (b1 & mask_4bit[x3]) >>> shift_4bit[x3];
		    int lumaRegister = (b2 & mask_2bit[x2]) >>> shift_2bit[x2];
		    int lumaOffset = 0x3c00 + lumaRegister * 0x100 + y1;
		    int luma = 0;
		    if (lumaOffset < unpackedImage.length) {
			luma = unpackedImage[lumaOffset] & 0xe;
		    }

		    int color = paletteMapper.getRGBColor(hue << 4 | luma);
		    data.setDirectPixel(x, y1, color);
		}
	    }
	}
	return true;
    }

}
