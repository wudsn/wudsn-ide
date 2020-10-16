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

public class LinearBitMapINPConverter extends LinearBitMapConverter {

    public LinearBitMapINPConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 16004 || bytes.length == 16052;
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}

	PaletteMapper paletteMapper = new Atari8BitPaletteMapper();
	RGB[] paletteColors = new RGB[7];
	paletteColors[0] = paletteMapper.getRGB(bytes[16000] & 0xfe);
	paletteColors[2] = paletteMapper.getRGB(bytes[16001] & 0xfe);
	paletteColors[4] = paletteMapper.getRGB(bytes[16002] & 0xfe);
	paletteColors[6] = paletteMapper.getRGB(bytes[16003] & 0xfe);

	// Compute mixed interlace colors.
	paletteColors[1] = RBGUtility.combineRGB(paletteColors[0], paletteColors[2]);
	paletteColors[3] = RBGUtility.combineRGB(paletteColors[2], paletteColors[4]);
	paletteColors[5] = RBGUtility.combineRGB(paletteColors[4], paletteColors[6]);

	setImageSizeAndPalette(data, 40, 200, Palette.MULTI_MANUAL, paletteColors);
    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns() * 4);
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	int offset = 0;
	int xpixels = 4;

	for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
	    for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
		int b1 = data.getSourceFileByte(BIT_MAP_FILE, offset + 8000);
		int b2 = data.getSourceFileByte(BIT_MAP_FILE, offset++);
		if (b1 < 0 || b2 < 0) {
		    return true;
		}
		for (int x2 = 0; x2 < 4; x2++) {
		    int x = x1 * xpixels + x2;

		    int color1 = (b1 & mask_2bit[x2]) >>> shift_2bit[x2];
		    int color2 = (b2 & mask_2bit[x2]) >>> shift_2bit[x2];
		    data.setPalettePixel(x, y1, color1 + color2);
		}

	    }
	}
	return true;
    }

}
