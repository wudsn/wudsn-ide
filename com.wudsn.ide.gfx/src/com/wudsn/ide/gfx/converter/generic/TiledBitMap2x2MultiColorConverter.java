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

package com.wudsn.ide.gfx.converter.generic;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.c64.C64Utility;

public class TiledBitMap2x2MultiColorConverter extends TiledBitMapConverter {

    public TiledBitMap2x2MultiColorConverter() {

    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * (8 + data.getParameters().getSpacingWidth()));
	data.setImageDataHeight(data.getParameters().getRows() * (16 + data.getParameters().getSpacingWidth()));
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	int[] colors = new int[] { 0x191d19, 0xfcf9fc, 0x933a4c, 0xb6fafa, 0xd27ded, 0x6acf6f, 0x4f44d8, 0xfbfb8b,
		0xd89c5b, 0x7f5307, 0xef839f, 0x575753, 0xa3a7a7, 0xb7ffbbf, 0xa397ff, 0xefe9e7 };

	for (int i = 0; i < 16; i++) {
	    int r = (colors[i] >> 16) & 0xff;
	    int g = (colors[i] >> 8) & 0xff;
	    int b = (colors[i] >> 0) & 0xff;
	    data.getImageData().palette.colors[i] = new RGB(r, g, b);
	}

	int tile = 0;
	int bitmap_offset = 0;
	int video_ram_offset = 0;
	int color_ram_offset = 0;
	int xpixels = 8 + data.getParameters().getSpacingWidth();
	int ypixels = 16 + data.getParameters().getSpacingWidth();
	int rows = data.getParameters().getRows();
	int columns = data.getParameters().getColumns();

	int[] cell_colors = new int[] { 0, 1, 2, 3 };

	for (int y1 = 0; y1 < rows; y1++) {
	    for (int x1 = 0; x1 < columns; x1++) {
		video_ram_offset = tile * 4;
		color_ram_offset = tile * 2;
		for (int y2 = 0; y2 < 2; y2++) {
		    for (int x2 = 0; x2 < 2; x2++) {
			int v = data.getSourceFileByte(VIDEO_RAM_FILE, video_ram_offset + y2 * 2 + x2);
			int c = data.getSourceFileByte(COLOR_RAM_FILE, color_ram_offset + y2);
			if (v >= 0 && c >= 0) {
			    cell_colors[1] = (v >> 4) & 0xf;
			    cell_colors[2] = (v >> 0) & 0xf;
			    if (x2 == 0) {
				cell_colors[3] = (c >> 4) & 0xf;
			    } else {
				cell_colors[3] = (c >> 0) & 0xf;

			    }

			} else {
			    cell_colors[1] = C64Utility.RED.intValue();
			    cell_colors[2] = C64Utility.LIGHT_RED.intValue();
			    cell_colors[3] = C64Utility.WHITE.intValue();
			}

			for (int y3 = 0; y3 < 8; y3++) {
			    int b = data.getSourceFileByte(BIT_MAP_FILE, bitmap_offset++);
			    if (b < 0) {
				return true;
			    }

			    int y = y1 * ypixels + y2 * 8 + y3;
			    for (int x3 = 0; x3 < 4; x3++) {
				int x = x1 * xpixels + x2 * 4 + x3;

				int color = (b & mask_2bit[x3]) >>> shift_2bit[x3];
				data.setPalettePixel(x, y, cell_colors[color]);
			    }
			}

		    }
		}
		color_ram_offset += 4;
		video_ram_offset += 4;
		tile++;

	    }
	}
	return true;
    }
}
