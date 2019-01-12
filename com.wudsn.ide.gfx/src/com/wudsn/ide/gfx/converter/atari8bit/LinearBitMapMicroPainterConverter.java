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
import com.wudsn.ide.gfx.model.PaletteType;
import com.wudsn.ide.gfx.model.PaletteUtility;

public class LinearBitMapMicroPainterConverter extends LinearBitMapConverter {

    public LinearBitMapMicroPainterConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 7680 || bytes.length == 7684;
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
	RGB[] paletteColors;
	if (bytes.length == 7684) {
	    paletteColors = new RGB[4];
	    paletteColors[0] = paletteMapper.getRGB(bytes[7680] & 0xfe);
	    paletteColors[1] = paletteMapper.getRGB(bytes[7681] & 0xfe);
	    paletteColors[2] = paletteMapper.getRGB(bytes[7682] & 0xfe);
	    paletteColors[3] = paletteMapper.getRGB(bytes[7683] & 0xfe);
	} else {
	    paletteColors = PaletteUtility.getPaletteColors(PaletteType.ATARI_DEFAULT, Palette.MULTI_1, null);
	}

	setImageSizeAndPalette(data, 40, 192, Palette.MULTI_MANUAL, paletteColors);
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
