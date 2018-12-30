/**
* Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

public class LinearBitMapGraphics15Converter extends LinearBitMapConverter {

    public LinearBitMapGraphics15Converter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	return bytes.length == 7680;
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

	int columns = 40;
	int rows = (bytes.length + columns - 1) / columns;
	RGB[] paletteColors;
	paletteColors = PaletteUtility.getPaletteColors(
		PaletteType.ATARI_DEFAULT, Palette.MULTI_1, null);
	setImageSizeAndPalette(data, columns, rows, Palette.MULTI_1,
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

	int offset = 0;
	int xpixels = 4;

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		int b = data.getSourceFileByte(BIT_MAP_FILE, offset++);
		if (b < 0) {
		    return true;
		}
		for (int x2 = 0; x2 < 4; x2++) {
		    int x = x1 * xpixels + x2;

		    int color = (b & mask_2bit[x2]) >>> shift_2bit[x2];
		    data.setPalettePixel(x, y1, color);
		}

	    }
	}
	return true;
    }
}
