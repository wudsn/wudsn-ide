package com.wudsn.ide.gfx.converter;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.base.common.NumberFactory;

/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter
 * Dell</a>
 * 
 * This file is part of WUDSN IDE.
 * 
 * WUDSN IDE is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 2 of the License, or (at your option) any later
 * version.
 * 
 * WUDSN IDE is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with
 * WUDSN IDE. If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * Palette mapper for mapping palette indices to RGB and back. The palette data
 * is stored in files in the folder for the sub-package "/palettes", relative to
 * the location if the palette mapper implementation class. The file content is
 * loaded from the class path using the class loader.
 * 
 * 
 * @since 1.6.4
 */
public abstract class PaletteMapper {
    private int palette_size;
    private int[] palette_r;
    private int[] palette_g;
    private int[] palette_b;
    private Map<Integer, Integer> map;

    protected PaletteMapper(int palette_size) {
	if (palette_size < 1) {
	    throw new IllegalArgumentException("Parameter 'palette_size' must be positive. Specified value is "
		    + palette_size + ".");
	}
	this.palette_size = palette_size;
	map = new HashMap<Integer, Integer>();
	palette_r = new int[palette_size];
	palette_g = new int[palette_size];
	palette_b = new int[palette_size];
    }

    public final void loadPalette(String fileName) {
	if (fileName == null) {
	    throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
	}
	InputStream inputStream;
	Class<? extends PaletteMapper> clazz = getClass();
	inputStream = clazz.getClassLoader().getResourceAsStream(
		clazz.getPackage().getName().replace('.', '/') + "/palettes/" + fileName);
	if (inputStream == null) {
	    try {

		inputStream = new FileInputStream(fileName);
	    } catch (FileNotFoundException ex) {
		throw new RuntimeException("File '" + fileName + "' not found or not readable", ex);
	    }
	}

	byte[] buffer = new byte[palette_size * 3];
	int count;
	do {
	    try {
		count = inputStream.read(buffer);
	    } catch (IOException ex) {
		throw new RuntimeException("Cannot read palette '" + fileName + "'", ex);
	    }
	    if (count > 0) {
		int j = 0;
		for (int i = 0; i < count; i = i + 3, j++) {
		    palette_r[j] = buffer[i] & 0xff;
		    palette_g[j] = buffer[i + 1] & 0xff;
		    palette_b[j] = buffer[i + 2] & 0xff;
		}
	    }
	} while (count > -1);

	map.clear();
    }

    /**
     * Gets the index of an RGB value in the palette.
     * 
     * @param rgb
     *            The 24-bit RGB value
     * @return The palette index, or <code>-1</code> is there is not
     *         corresponding palette index.
     */
    public final int getPaletteIndex(int rgb) {
	return getPaletteIndex(rgb >>> 16 & 0xff, rgb >>> 8 & 0xff, rgb & 0xff);
    }

    /**
     * Gets the index of an RGB value in the palette.
     * 
     * @param r
     *            The 8-bit red value
     * @param g
     *            The 8-bit green value
     * @param b
     *            The 8-bit blue value
     * 
     * @return The palette index, or <code>-1</code> is there is not
     *         corresponding palette index.
     */
    public final int getPaletteIndex(int r, int g, int b) {
	int color = r << 16 | g << 8 | b;
	Integer colorKey = NumberFactory.getInteger(color);

	Integer colorValue = map.get(colorKey);

	if (colorValue == null) {

	    int diff = 0x7fffffff;
	    int n = 0;
	    for (int m = 0; m < 256; m++) {
		int e = (palette_r[m] - r);
		int d = e * e;
		e = (palette_g[m] - g);
		d += e * e;
		e = (palette_b[m] - b);
		d += e * e;
		if (d < diff) {
		    diff = d;
		    n = m;
		}
	    }
	    colorValue = Integer.valueOf(n);
	    map.put(colorKey, colorValue);
	}
	return colorValue.intValue();

    }

    /**
     * Gets an Atari color with a given color code as RGB value.
     * 
     * @param paletteIndex
     *            The palette index, a non-negative integer.
     * @return The RGB value, not <code>null</code>.
     */
    public final RGB getRGB(int paletteIndex) {
	RGB result;
	result = new RGB(palette_r[paletteIndex], palette_g[paletteIndex], palette_b[paletteIndex]);
	return result;
    }

    /**
     * Gets an Atari color with a given color code as RGB int value.
     * 
     * @param paletteIndex
     *            The palette index, a non-negative integer.
     * @return The RGB color, not <code>null</code>.
     */
    public final int getRGBColor(int paletteIndex) {
	int result = palette_r[paletteIndex] << 16 | palette_g[paletteIndex] << 8 | palette_b[paletteIndex];
	return result;
    }
}