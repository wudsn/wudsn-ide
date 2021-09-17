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

package com.wudsn.ide.gfx.converter.atarist;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

/**
 * TODO Implement Atari ST Conversion
 * 
 * @author Peter Dell
 * 
 */
public class InterleavedBitMap4Planes extends LinearBitMapConverter {

	public InterleavedBitMap4Planes() {
	}

	@Override
	public boolean canConvertToImage(byte[] bytes) {
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}
		return bytes.length > 0 && bytes.length % 80 == 0;
	}

	@Override
	public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}

		RGB[] paletteColors;
		paletteColors = PaletteUtility.getPaletteColors(PaletteType.ATARI_DEFAULT, Palette.GTIA_GREY_1, null);
		setImageSizeAndPalette(data, 40, 192, Palette.GTIA_GREY_1, paletteColors);
	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		data.setImageDataWidth(data.getParameters().getColumns() * 16);
		data.setImageDataHeight(data.getParameters().getRows());
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {

		final int[] mask_1bit = new int[] { 0x8000, 0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100, 0x80, 0x40,
				0x20, 0x10, 0x08, 0x04, 0x02, 0x01 };
		final int[] shift_1bit = new int[] { 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0 };

		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}

		int offset_line = 0;
		int xpixels = 16;

		for (int y1 = data.getParameters().getRows() - 1; y1 >= 0; y1--) {
			int offset = offset_line;
			offset_line += 27 * 8;

			for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
				int w1 = getWord(data, offset);
				if (w1 < 0) {
					return true;
				}
				offset += 2;
				int w2 = getWord(data, offset);
				if (w2 < 0) {
					return true;
				}
				offset += 2;
				int w3 = getWord(data, offset);
				if (w3 < 0) {
					return true;
				}
				offset += 2;
				int w4 = getWord(data, offset);
				if (w4 < 0) {
					return true;
				}
				offset += 2;

				for (int x2 = 0; x2 < 16; x2++) {
					int x = x1 * xpixels + 15 - x2;
					int shift = shift_1bit[x2];
					int mask = mask_1bit[x2];
					int color = ((w1 & mask) >>> shift) + (((w2 & mask) >>> shift) << 1)
							+ (((w3 & mask) >>> shift) << 2) + (((w4 & mask) >>> shift) << 3);
					data.setPalettePixel(x, y1, color);
				}

			}
		}
		return true;
	}

	private int getWord(FilesConverterData data, int offset) {
		int b2 = data.getSourceFileByte(BIT_MAP_FILE, offset + 1);
		if (b2 < 0) {
			return b2;
		}
		int b1 = data.getSourceFileByte(BIT_MAP_FILE, offset);
		if (b1 < 0) {
			return b1;
		}
		return b1 + (b2 << 8);
	}
}
