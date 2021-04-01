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

package com.wudsn.ide.gfx.converter.atari2600;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.generic.BitMapConverter;
import com.wudsn.ide.gfx.model.Palette;

public class AsymetricalPlayfieldConverter extends BitMapConverter {

    public AsymetricalPlayfieldConverter() {

    }

    @Override
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return false;
    }

    @Override
    public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	int columns = 5;
	int rows = (bytes.length + columns - 1) / columns;
	setImageSizeAndPalette(data, columns, rows, Palette.HIRES_1, null);

    }

    @Override
    public void convertToImageDataSize(FilesConverterData data) {
	data.setImageDataWidth(data.getParameters().getColumns());
	data.setImageDataHeight(data.getParameters().getRows());
    }

    @Override
    public boolean convertToImageData(FilesConverterData data) {
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}

	return false;
    }
}
