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

package com.wudsn.ide.gfx.model;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.base.common.HexUtility;

public final class PaletteUtility {

    public static final RGB BLACK = new RGB(0, 0, 0);
    public static final RGB GREY1 = new RGB(85, 85, 85);
    public static final RGB GREY2 = new RGB(170, 170, 170);
    public static final RGB WHITE = new RGB(255, 255, 255);

    /**
     * Creation is private.
     */
    private PaletteUtility() {
    }

    public static RGB[] getPaletteColors(PaletteType paletteType, Palette palette, RGB[] manualPaletteColors) {
	if (paletteType == null) {
	    throw new IllegalArgumentException("Parameter 'paletteType' must not be null.");
	}
	if (palette == null) {
	    throw new IllegalArgumentException("Parameter 'palette' must not be null.");
	}

	RGB[] result;

	switch (palette) {
	case TRUE_COLOR:
	    result = new RGB[0];
	    break;

	case HIRES_1:
	    result = new RGB[] { BLACK, WHITE };
	    break;
	case HIRES_2:
	    result = new RGB[] { WHITE, BLACK };
	    break;

	case HIRES_MANUAL:
	    result = getPaletteColorsCopy(manualPaletteColors, 2);
	    break;

	case MULTI_1:
	    result = new RGB[] { BLACK, GREY1, GREY2, WHITE };
	    break;
	case MULTI_2:
	    result = new RGB[] { BLACK, GREY1, WHITE, GREY2 };
	    break;
	case MULTI_3:
	    result = new RGB[] { BLACK, GREY2, GREY1, WHITE };
	    break;
	case MULTI_4:
	    result = new RGB[] { BLACK, GREY2, WHITE, GREY1 };
	    break;
	case MULTI_5:
	    result = new RGB[] { BLACK, WHITE, GREY1, GREY2 };
	    break;
	case MULTI_6:
	    result = new RGB[] { BLACK, WHITE, GREY2, GREY1 };
	    break;
	case MULTI_MANUAL:
	    result = getPaletteColorsCopy(manualPaletteColors, manualPaletteColors.length);
	    break;

	case GTIA_GREY_1:
	    result = new RGB[16];
	    for (int i = 0; i < 16; i++) {
		int c = 0x11 * i;
		result[i] = new RGB(c, c, c);
	    }
	    break;
	case GTIA_GREY_2:
	    result = new RGB[16];
	    for (int i = 0; i < 16; i++) {
		int c = 255 - 0x11 * i;
		result[i] = new RGB(c, c, c);
	    }
	    break;
	case GTIA_GREY_MANUAL:
	    result = getPaletteColorsCopy(manualPaletteColors, 16);
	    break;

	default:
	    throw new IllegalStateException("Unknown palette '" + palette + "'.");
	}
	return result;
    }

    /**
     * Gets an array of colors with the given size based on the current palette
     * colors.
     * 
     * @param paletteColors
     *            The original palette colors or <code>null</code>.
     * @param size
     *            The size of the palette, a positive integer.
     * @return The new array with palette colors of the given size.
     * 
     */
    private static RGB[] getPaletteColorsCopy(RGB[] paletteColors, int size) {

	if (size < 1) {
	    throw new IllegalArgumentException("Parameter 'size' must be positive. Specified value is " + size + ".");
	}

	RGB[] result;
	result = new RGB[size];
	for (int i = 0; i < size; i++) {
	    if (paletteColors != null && i < paletteColors.length) {
		result[i] = paletteColors[i];
	    } else {
		result[i] = new RGB(0, 0, 0);
	    }
	}
	return result;
    }

    public static String getPaletteColorText(RGB rgb) {
	if (rgb == null) {
	    throw new IllegalArgumentException("Parameter 'rgb' must not be null.");
	}
	return HexUtility.getByteValueHexString(rgb.red) + HexUtility.getByteValueHexString(rgb.green)
		+ HexUtility.getByteValueHexString(rgb.blue);
    }
}
