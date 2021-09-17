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
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;

public class LinearBitMapAPCConverter extends LinearBitMapConverter {

	public LinearBitMapAPCConverter() {

	}

	@Override
	public boolean canConvertToImage(byte[] bytes) {
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}
		// 7680 bytes of bitmap, optionally 40 bytes of text in ATASCII screen
		// code
		return bytes.length == 7680 || bytes.length == 7680 + 40;
	}

	@Override
	public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}
		setImageSizeAndPalette(data, 40, 96, Palette.TRUE_COLOR, null);

	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		data.setImageDataWidth(data.getParameters().getColumns() * 2);
		data.setImageDataHeight(data.getParameters().getRows());
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}

		int columns = data.getParameters().getColumns();

		int offset1 = 0;
		int offset2 = columns;
		int xpixels = 2;
		PaletteMapper paletteMapper = new Atari8BitPaletteMapper();

		for (int y1 = 0; y1 < data.getParameters().getRows(); y1 = y1 + 1) {
			for (int x1 = 0; x1 < columns; x1++) {
				int c = data.getSourceFileByte(BIT_MAP_FILE, offset1++);
				if (c < 0) {
					return true;
				}
				int b = data.getSourceFileByte(BIT_MAP_FILE, offset2++);
				if (b < 0) {
					return true;
				}
				for (int x2 = 0; x2 < 2; x2++) {
					int x = x1 * xpixels + x2;

					int color = (c & mask_4bit[x2]) >>> shift_4bit[x2];
					int brightness = (b & mask_4bit[x2]) >>> shift_4bit[x2];
					int atariColor = color << 4 | brightness;
					int directColor = paletteMapper.getRGBColor(atariColor);
					data.setDirectPixel(x, y1, directColor);
				}

			}
			offset1 = offset1 + columns;
			offset2 = offset2 + columns;
		}
		return true;
	}
}
