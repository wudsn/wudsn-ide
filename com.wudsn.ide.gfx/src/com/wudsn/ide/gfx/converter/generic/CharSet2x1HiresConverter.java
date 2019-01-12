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

package com.wudsn.ide.gfx.converter.generic;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.atari8bit.Atari8BitUtility;
import com.wudsn.ide.gfx.converter.c64.C64Utility;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

public class CharSet2x1HiresConverter extends CharSetConverter {

    public CharSet2x1HiresConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	boolean atariCharset = Atari8BitUtility.isAtariCharset(bytes);
	boolean c64Charset =C64Utility.isC64Charset(bytes);
	return atariCharset || c64Charset;
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

	int columns = 16;
	int lineSize = columns * 8*2;
	int rows;
	if ((bytes.length == 1024 + 6 && Atari8BitUtility
		.getLengthFromBinaryHeader(bytes, 0) == 1024)) {
	    data.getParameters().getSourceFile(CharSetConverter.CHAR_SET_FILE)
		    .setOffset(6);

	    rows = (bytes.length - 6 + lineSize - 1) / lineSize;
	} else if (bytes.length % 0x100 == 2) {
	    data.getParameters().getSourceFile(CharSetConverter.CHAR_SET_FILE)
		    .setOffset(2);
	    rows = (bytes.length - 2 + lineSize - 1) / lineSize;

	} else {
	    rows = (bytes.length + lineSize - 1) / lineSize;
	}

	RGB[] paletteColors;
	paletteColors = PaletteUtility.getPaletteColors(
		PaletteType.ATARI_DEFAULT, Palette.HIRES_1, null);
	setImageSizeAndPalette(data, columns, rows, Palette.HIRES_1,
		paletteColors);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth((data.getParameters().getColumns())
		* (8 + data.getParameters().getSpacingWidth()));
	data.setImageDataHeight((data.getParameters().getRows())
		* (16 + data.getParameters().getSpacingWidth()));
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}

	int offset = 0;
	int xpixels = 8 + data.getParameters().getSpacingWidth();
	int ypixels = 16 + data.getParameters().getSpacingWidth();

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		for (int cy = 0; cy < 2; cy++) {
		    for (int cx = 0; cx < 1; cx++) {
			for (int y2 = 0; y2 < 8; y2++) {
			    int b = data.getSourceFileByte(CHAR_SET_FILE,
				    offset++);
			    if (b < 0) {
				return true;
			    }
			    int y = y1 * ypixels + cy * 8 + y2;
			    for (int x2 = 0; x2 < 8; x2++) {
				int x = x1 * xpixels + cx * 8 + x2;
				int color = (b & mask_1bit[x2]) >>> shift_1bit[x2];
				data.setPalettePixel(x, y, color);
			    }
			}
		    }
		}
	    }
	}
	return true;
    }
}
