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

package com.wudsn.ide.gfx.converter.c64;

import com.wudsn.ide.gfx.converter.FilesConverterData;

public class SpriteMultiColorConverter extends SpriteConverter {

    public SpriteMultiColorConverter() {
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns()
		* (3 * 4 + data.getParameters().getSpacingWidth()));
	data.setImageDataHeight(data.getParameters().getRows()
		* (21 + data.getParameters().getSpacingWidth()));
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}

	int offset = 0;
	int xpixels = 3 * 4 + data.getParameters().getSpacingWidth();
	int ypixels = 21 + data.getParameters().getSpacingWidth();

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < (data.getParameters().getColumns()); x1++) {
		for (int y2 = 0; y2 < 21; y2++) {
		    for (int x2 = 0; x2 < 3; x2++) {
			int b = data.getSourceFileByte(SPRITE_FILE, offset++);
			if (b < 0) {
			    return true;
			}

			int y = y1 * ypixels + y2;
			for (int x3 = 0; x3 < 4; x3++) {
			    int x = x1 * xpixels + x2 * 4 + x3;

			    int color = (b & mask_2bit[x3]) >>> shift_2bit[x3];
			    data.setPalettePixel(x, y, color);
			}
		    }
		}
		offset++; // 64th byte
	    }
	}
	return true;
    }

}
