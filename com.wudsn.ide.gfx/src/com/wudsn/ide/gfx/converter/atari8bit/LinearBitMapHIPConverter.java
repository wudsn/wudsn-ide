/**
 * Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.RBGUtility;

public class LinearBitMapHIPConverter extends LinearBitMapConverter {

    public LinearBitMapHIPConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}

	// HIP image with binary file headers. Two concatenated COM files.
	int frame1Length = Atari8BitUtility.getLengthFromBinaryHeader(bytes, 0);
	if (frame1Length > 0 && frame1Length * 2 + 12 == bytes.length && frame1Length % 40 == 0) {

	    int frame2Length = Atari8BitUtility.getLengthFromBinaryHeader(bytes, frame1Length + 6);
	    if (frame2Length == frame1Length) {
		return true;
	    }
	}
	// HIP image with graphics 10 palette.
	else if ((bytes.length - 9) % 80 == 0) {
	    return true;
	}
	return false;
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}

	// HIP image with binary file headers. Two concatenated COM files.
	int rows;
	int frame1Length = Atari8BitUtility.getLengthFromBinaryHeader(bytes, 0);
	if (frame1Length > 0 && frame1Length * 2 + 12 == bytes.length && frame1Length % 40 == 0) {

	    int frame2Length = Atari8BitUtility.getLengthFromBinaryHeader(bytes, frame1Length + 6);
	    if (frame2Length != frame1Length) {
		throw new IllegalStateException("Inconsistent file");
	    }

	    rows = frame1Length / 40;
	}
	// hip image with gr10 palette.
	else if ((bytes.length - 9) % 80 == 0) {
	    rows = (bytes.length - 9) / 80;
	} else {
	    throw new IllegalStateException("Inconsistent file");
	}

	setImageSizeAndPalette(data, 40, rows, Palette.TRUE_COLOR, null);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * 4 + 1);
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	int rows = data.getParameters().getRows();
	int columns = data.getParameters().getColumns();
	PaletteMapper paletteMapper = new Atari8BitPaletteMapper();

	// Assume the binary is already merged in case of a 160012 bytes HIP.
	int offset9, offset10, offsetPalette;

	byte[] sourceFileBytes = data.getSourceFileBytes(BIT_MAP_FILE);
	if (sourceFileBytes == null) {
	    return false;
	}

	// Assume grey scale colors by default.
	int[] graphics10Colors = { 0, 0, 2, 4, 6, 8, 10, 12, 14 };

	// Compute the offsets in the file.
	int frameSize = rows * columns;
	int rest = sourceFileBytes.length - 2 * frameSize;
	if (rest == 0 || rest == 9) {
	    // In this case the graphics 9 picture comes first
	    offset9 = 0;
	    offset10 = offset9 + 0 + frameSize;
	    offsetPalette = offset10 + frameSize;
	    if (rest == 9) {
		for (int i = 0; i < 9; i++) {
		    graphics10Colors[i] = sourceFileBytes[offsetPalette + i];
		}
	    }
	} else if (rest == 12) {
	    // In this case the graphics 10 picture comes first
	    offset10 = 6;
	    offset9 = offset10 + 6 + frameSize;
	} else {
	    return false;
	}

	int[] buffer1 = new int[columns * 4 + 1];
	int[] buffer2 = new int[columns * 4 + 1];

	for (int y1 = 0; y1 < rows; y1++) {
	    for (int x1 = 0; x1 < columns; x1++) {
		int byte9 = data.getSourceFileByte(BIT_MAP_FILE, offset9++);
		if (byte9 < 0) {
		    return true;
		}
		int byte10 = data.getSourceFileByte(BIT_MAP_FILE, offset10++);
		if (byte10 < 0) {
		    return true;
		}

		// Byte 1 is the GTIA 9 byte, take the values as brightness
		// values
		int brightness1 = (byte9 & mask_4bit[0]) >>> shift_4bit[0];
		int brightness2 = (byte9 & mask_4bit[1]) >>> shift_4bit[1];

		// Byte 2 is the GTIA 10 byte, take the values from the GTIA 10
		// palette
		int brightness3 = (byte10 & mask_4bit[0]) >>> shift_4bit[0];
		int brightness4 = (byte10 & mask_4bit[1]) >>> shift_4bit[1];
		brightness3 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[brightness3]];
		brightness4 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[brightness4]];

		// Put the color values in the row buffer, shifted by 1 pixel
		int x = x1 << 2;
		buffer1[x + 0] = brightness1;
		buffer1[x + 1] = brightness1;
		buffer1[x + 2] = brightness2;
		buffer1[x + 3] = brightness2;

		buffer2[x + 1] = brightness3;
		buffer2[x + 2] = brightness3;
		buffer2[x + 3] = brightness4;
		buffer2[x + 4] = brightness4;
	    }

	    // Merge the two buffers into combined color values.
	    for (int x = 0; x < buffer1.length; x++) {
		int atariColor = RBGUtility.combineRGBColor(paletteMapper.getRGBColor(buffer1[x]),
			paletteMapper.getRGBColor(buffer2[x]));
		data.setDirectPixel(x, y1, atariColor);
	    }
	}
	return true;
    }
}
