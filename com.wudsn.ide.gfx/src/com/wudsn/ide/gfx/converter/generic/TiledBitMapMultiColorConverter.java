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

package com.wudsn.ide.gfx.converter.generic;

import com.wudsn.ide.gfx.converter.FilesConverterData;

public class TiledBitMapMultiColorConverter extends TiledBitMapConverter {

	public TiledBitMapMultiColorConverter() {

	}

	@Override
	public void convertToImageDataSize(FilesConverterData data) {
		data.setImageDataWidth(data.getParameters().getColumns() * (4 + data.getParameters().getSpacingWidth()));
		data.setImageDataHeight(data.getParameters().getRows() * (8 + data.getParameters().getSpacingWidth()));
	}

	@Override
	public boolean convertToImageData(FilesConverterData data) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}

		int offset = 0;
		int xpixels = 4 + data.getParameters().getSpacingWidth();
		int ypixels = 8 + data.getParameters().getSpacingWidth();

		for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
			for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
				for (int y2 = 0; y2 < 8; y2++) {
					int b = data.getSourceFileByte(BIT_MAP_FILE, offset++);
					if (b < 0) {
						return true;
					}
					int y = y1 * ypixels + y2;
					for (int x2 = 0; x2 < 4; x2++) {
						int x = x1 * xpixels + x2;

						int color = (b & mask_2bit[x2]) >>> shift_2bit[x2];
						data.setPalettePixel(x, y, color);
					}
				}
			}
		}
		return true;
	}
}
