/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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
import com.wudsn.ide.gfx.converter.ImageConverterData;
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.RBGUtility;

/**
 * Layout in the TIP picture is 9 bytes header, graphics 9 picture, graphics 10
 * picture, graphics 11 picture
 */
public class LinearBitMapTIPConverter extends LinearBitMapConverter {

    public LinearBitMapTIPConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	if (bytes.length < 9) {
	    return false;
	}

	int frameLength = (bytes[7] & 0xff) + ((bytes[8] & 0xff) << 8);
	if (bytes[0] != 'T' || bytes[1] != 'I' || bytes[2] != 'P' || bytes[3] != 1 || bytes[4] != 0 || bytes[5] == 0
		|| (bytes[5] & 0xff) > 160 || bytes[6] == 0 || (bytes[6] & 0xff) > 119
		|| (9 + frameLength * 3) != bytes.length) {
	    return false;
	}

	return true;
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	int columns;
	int rows;
	columns = (bytes[5] & 0xff) / 4;
	rows = (bytes[6] & 0xff);
	setImageSizeAndPalette(data, columns, rows, Palette.TRUE_COLOR, null);
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
	int offset9, offset10, offset11;

	// Assume grey scale colors by default.
	int[] graphics10Colors = { 0, 0, 2, 4, 6, 8, 10, 12, 14 };

	// Compute the offsets in the file.
	int frameSize = rows * columns;
	offset9 = 9;
	offset10 = offset9 + frameSize;
	offset11 = offset10 + frameSize;

	int[] buffer1 = new int[columns * 4 + 1];
	int[] buffer2 = new int[columns * 4 + 1];
	for (int y1 = 0; y1 < rows; y1++) {
	    for (int x1 = 0; x1 < columns; x1++) {
		int byte1 = data.getSourceFileByte(BIT_MAP_FILE, offset9++);
		if (byte1 < 0) {
		    return true;
		}
		int byte2 = data.getSourceFileByte(BIT_MAP_FILE, offset10++);
		if (byte2 < 0) {
		    return true;
		}
		int byte3 = data.getSourceFileByte(BIT_MAP_FILE, offset11++);
		if (byte3 < 0) {
		    return true;
		}
		// Byte 1 is the GTIA 9 byte, take the values as brightness
		// values
		int brightness1 = (byte1 & mask_4bit[0]) >>> shift_4bit[0];
		int brightness2 = (byte1 & mask_4bit[1]) >>> shift_4bit[1];

		// Byte 2 is the GTIA 10 byte, take the values from the GTIA 10
		// palette
		int brightness3 = (byte2 & mask_4bit[0]) >>> shift_4bit[0];
		int brightness4 = (byte2 & mask_4bit[1]) >>> shift_4bit[1];
		brightness3 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[brightness3]];
		brightness4 = graphics10Colors[Atari8BitUtility.GRAPHICS_10_REGISTERS[brightness4]];

		// Byte 3 is the GTIA 11 byte, take the values as color values
		int color1 = (byte3 & 0xf0);
		int color2 = (byte3 & 0x0f) << 4;

		// Put the color values in the row buffer, shifted by 1 pixel
		int x = x1 << 2;
		buffer1[x + 0] = color1 | brightness1;
		buffer1[x + 1] = color1 | brightness1;
		buffer1[x + 2] = color2 | brightness2;
		buffer1[x + 3] = color2 | brightness2;

		buffer2[x + 1] = color1 | brightness3;
		buffer2[x + 2] = color1 | brightness3;
		buffer2[x + 3] = color2 | brightness4;
		buffer2[x + 4] = color2 | brightness4;
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

    public static void convertToFileData(ImageConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
    }
}
