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

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.converter.FilesConverterData;
import com.wudsn.ide.gfx.converter.PaletteMapper;
import com.wudsn.ide.gfx.converter.generic.LinearBitMapConverter;
import com.wudsn.ide.gfx.model.Palette;

public class LinearBitMapKoalaConverter extends LinearBitMapConverter {

	public LinearBitMapKoalaConverter() {

	}

	@Override
	public boolean canConvertToImage(byte[] bytes) {
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}
		if (bytes.length < 22) {
			return false;
		}

		if ((bytes[0] != (byte) 0xff || bytes[1] != (byte) 0x80 || bytes[2] != (byte) 0xc9 || bytes[3] != (byte) 0xc7
				|| bytes[4] < (byte) 0x1a || (bytes[4] & 0xff) >= bytes.length || bytes[5] != (byte) 0
				|| bytes[6] != (byte) 1 || bytes[8] != (byte) 0x0e || bytes[9] != (byte) 0 || bytes[10] != (byte) 40
				|| bytes[11] != (byte) 0 || bytes[12] != (byte) 192 || bytes[20] != (byte) 0
				|| bytes[21] != (byte) 0)) {
			return false;
		}

		byte[] unpackedImage = new byte[7684];
		boolean result = Atari8BitUtility.unpackKoala(bytes, (bytes[4] & 0xff) + 1,
				bytes.length - (bytes[4] & 0xff) - 1, bytes[7] & 0xff, unpackedImage);

		return result;
	}

	@Override
	public void convertToImageSizeAndPalette(FilesConverterData data, byte[] bytes) {
		if (data == null) {
			throw new IllegalArgumentException("Parameter 'data' must not be null.");
		}
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}

		byte[] unpackedImage = new byte[7684];
		boolean result = Atari8BitUtility.unpackKoala(bytes, (bytes[4] & 0xff) + 1,
				bytes.length - (bytes[4] & 0xff) - 1, bytes[7] & 0xff, unpackedImage);

		if (!result) {
			throw new IllegalStateException("canConverterToImage() not called");
		}

		unpackedImage[7680] = bytes[17];
		unpackedImage[7681] = bytes[13];
		unpackedImage[7682] = bytes[14];
		unpackedImage[7683] = bytes[15];

		PaletteMapper paletteMapper = new Atari8BitPaletteMapper();
		RGB[] paletteColors = new RGB[4];
		paletteColors[0] = paletteMapper.getRGB(unpackedImage[7680] & 0xfe);
		paletteColors[1] = paletteMapper.getRGB(unpackedImage[7681] & 0xfe);
		paletteColors[2] = paletteMapper.getRGB(unpackedImage[7682] & 0xfe);
		paletteColors[3] = paletteMapper.getRGB(unpackedImage[7683] & 0xfe);

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

		byte[] bytes = data.getSourceFileBytes(BIT_MAP_FILE);
		if (bytes == null || bytes.length < 8) {
			return false;
		}

		byte[] unpackedImage = new byte[7684];
		boolean result;

		result = Atari8BitUtility.unpackKoala(bytes, (bytes[4] & 0xff) + 1, bytes.length - (bytes[4] & 0xff) - 1,
				bytes[7] & 0xff, unpackedImage);
		if (!result) {
			return false;
		}

		int offset = 0;
		int xpixels = 4;

		for (int y1 = 0; y1 < data.getParameters().getRows(); y1++) {
			for (int x1 = 0; x1 < data.getParameters().getColumns(); x1++) {
				if (offset >= unpackedImage.length) {
					return true;
				}
				int b = unpackedImage[offset++] & 0xff;
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
