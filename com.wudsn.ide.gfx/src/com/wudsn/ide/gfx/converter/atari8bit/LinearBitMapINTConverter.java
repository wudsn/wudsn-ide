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

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.RBGUtility;

/**
 * The valid bit pattern combinations from the two images are: (0,0)=0, (0,1)=1,
 * (1,1)=2, (1,2)=3, (2,2)=4, (2,3)=5, (3,3)=6
 */

public class LinearBitMapINTConverter extends LinearBitMapConverter {

    public LinearBitMapINTConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	if (bytes.length < 10) {
	    return false;
	}
	if (bytes[0] != (byte) 'I'
		|| bytes[1] != (byte) 'N'
		|| bytes[2] != (byte) 'T'
		|| bytes[3] != (byte) '9'
		|| bytes[4] != (byte) '5'
		|| bytes[5] != (byte) 'a'
		|| bytes[6] == (byte) 0
		|| (bytes[6] & 0xff) > 40
		|| bytes[7] == (byte) 0
		|| (bytes[7] & 0xff) > 239
		|| bytes[8] != (byte) 0x0f
		|| bytes[9] != (byte) 0x2b
		|| 18 + (bytes[6] & 0xff) * (bytes[7] & 0xff) * 2 != bytes.length) {
	    return false;
	}
	return true;
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data,
	    byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	int rows;
	int columns;
	rows = bytes[7] & 0xff;
	columns = bytes[6] & 0xff;

	PaletteMapper paletteMapper = new Atari8BitPaletteMapper();
	RGB[] paletteColors = new RGB[16];
	RGB[] palette1Colors = new RGB[4];
	RGB[] palette2Colors = new RGB[4];
	palette1Colors[0] = paletteMapper.getRGB(bytes[10] & 0xfe);
	palette1Colors[1] = paletteMapper.getRGB(bytes[11] & 0xfe);
	palette1Colors[2] = paletteMapper.getRGB(bytes[12] & 0xfe);
	palette1Colors[3] = paletteMapper.getRGB(bytes[13] & 0xfe);
	palette2Colors[0] = paletteMapper.getRGB(bytes[14] & 0xfe);
	palette2Colors[1] = paletteMapper.getRGB(bytes[15] & 0xfe);
	palette2Colors[2] = paletteMapper.getRGB(bytes[16] & 0xfe);
	palette2Colors[3] = paletteMapper.getRGB(bytes[17] & 0xfe);

	// Compute mixed interlace colors.
	for (int x1 = 0; x1 < 4; x1++) {
	    for (int x2 = 0; x2 < 4; x2++) {
		paletteColors[x1 * 4 + x2] = RBGUtility.combineRGB(
			palette1Colors[x1], palette2Colors[x2]);
	    }

	}
	setImageSizeAndPalette(data, columns, rows, Palette.MULTI_MANUAL,
		paletteColors);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * 4);
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}

	int offset1 = 18;
	int offset2 = offset1 + data.getParameters().getRows()
		* data.getParameters().getColumns();
	int xpixels = 4;

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		int b1 = data.getSourceFileByte(BIT_MAP_FILE, offset1++);
		int b2 = data.getSourceFileByte(BIT_MAP_FILE, offset2++);
		if (b1 < 0 || b2 < 0) {
		    return true;
		}
		for (int x2 = 0; x2 < 4; x2++) {
		    int x = x1 * xpixels + x2;

		    int color1 = (b1 & mask_2bit[x2]) >>> shift_2bit[x2];
		    int color2 = (b2 & mask_2bit[x2]) >>> shift_2bit[x2];
		    int color = 4 * color1 + color2;
		    data.setPalettePixel(x, y1, color);
		}

	    }
	}
	return true;
    }
}
