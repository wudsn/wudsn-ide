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

public class LinearBitMapHR2Converter extends LinearBitMapConverter {

    public LinearBitMapHR2Converter() {
    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	return bytes.length == 16006;
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

	PaletteMapper paletteMapper=new Atari8BitPaletteMapper();

	RGB[] paletteColors = new RGB[8];
	RGB[] palette1Colors = new RGB[2];
	RGB[] palette2Colors = new RGB[4];
	palette1Colors[0] = paletteMapper.getRGB(bytes[16000] & 0xfe);
	palette1Colors[1] = paletteMapper.getRGB(bytes[16001] & 0xfe);
	palette2Colors[0] = paletteMapper.getRGB(bytes[16002] & 0xfe);
	palette2Colors[1] = paletteMapper.getRGB(bytes[16003] & 0xfe);
	palette2Colors[2] = paletteMapper.getRGB(bytes[16004] & 0xfe);
	palette2Colors[3] = paletteMapper.getRGB(bytes[16005] & 0xfe);

	// Compute mixed interlace colors.
	for (int x1 = 0; x1 < palette1Colors.length; x1++) {
	    for (int x2 = 0; x2 < palette2Colors.length; x2++) {
		paletteColors[x1 * palette2Colors.length + x2] = RBGUtility
			.combineRGB(palette1Colors[x1], palette2Colors[x2]);
	    }
	}
	setImageSizeAndPalette(data, 40, 200, Palette.MULTI_MANUAL,
		paletteColors);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * 8);
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}

	int offset = 0;
	int xpixels = 8;

	int frameSize = 8000;
	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		int b1 = data.getSourceFileByte(BIT_MAP_FILE, offset);
		if (b1 < 0) {
		    return true;
		}
		int b2 = data.getSourceFileByte(BIT_MAP_FILE, offset
			+ frameSize);
		if (b2 < 0) {
		    return true;
		}
		offset++;

		for (int x2 = 0; x2 < 8; x2++) {
		    int x = x1 * xpixels + x2;
		    // Graphics 8
		    int color1 = (b1 & mask_1bit[x2]) >>> shift_1bit[x2];
		    // Graphics 15, half resolution
		    int color2 = (b2 & mask_2bit[x2 >>> 1]) >>> shift_2bit[x2 >>> 1];
		    data.setPalettePixel(x, y1, (color1 << 2) + color2);
		}

	    }
	}
	return true;
    }
}
