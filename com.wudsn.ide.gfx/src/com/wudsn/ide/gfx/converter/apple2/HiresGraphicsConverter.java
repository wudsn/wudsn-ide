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

package com.wudsn.ide.gfx.converter.apple2;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.FilesConverterParameters.SourceFile;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

public class HiresGraphicsConverter extends LinearBitMapConverter {

	static final int CELL_HEIGHT = 8;
	static final int CELL_WIDTH = 7;

	public HiresGraphicsConverter() {
	}

	@Override
	public boolean canConvertToImage(byte[] bytes) {
		if (bytes == null) {
			throw new IllegalArgumentException(
					"Parameter 'bytes' must not be null.");
		}
		return bytes.length == 8184; // $1ff8
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
		int rows = 24;
		RGB[] paletteColors;
		paletteColors = PaletteUtility.getPaletteColors(
				PaletteType.ATARI_DEFAULT, Palette.HIRES_1, null);
		setImageSizeAndPalette(data, columns, rows, Palette.HIRES_1,
				paletteColors);
	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException(
					"Parameter 'data' must not be null.");
		}
		data.setImageDataWidth(data.getParameters().getColumns() * CELL_WIDTH);
		data.setImageDataHeight(data.getParameters().getRows() * CELL_HEIGHT);
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException(
					"Parameter 'data' must not be null.");
		}

		byte[] bytes = data.getSourceFileBytes(BIT_MAP_FILE);
		if (bytes == null) {
			return false;
		}

		SourceFile sourceFile = data.getParameters()
				.getSourceFile(BIT_MAP_FILE);
		int offset = sourceFile.getOffset();

		for (int y1 = 0; y1 < data.getParameters().getRows() * CELL_HEIGHT; y1++) {
			int y = y1;
			int page = y & 0x7;
			int block = ((y >> 3) & 0x7);
			int leaf = y >> 6;
			int yindex = offset + (page * 1024) + (block * 128) + (leaf * 40);

			int x = 0;
			for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
				int xindex = yindex + x1;
				if (xindex < bytes.length) {
					int b = bytes[xindex];
					for (int i = 0; i < CELL_WIDTH; i++) {
						if ((b & (1 << i)) != 0) {
							data.setPalettePixel(x, y1, 1);
						}
						x++;
					}
				}

			}
		}
		return true;

	}
}
