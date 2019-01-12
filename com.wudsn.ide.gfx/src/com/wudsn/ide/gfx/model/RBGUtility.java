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

public final class RBGUtility {

    /**
     * Creation is private.
     */
    private RBGUtility() {
    }

    /**
     * Combines to RBG color values to a mixed color value.
     * 
     * @param color1
     *            The first color, not <code>null</code>.
     * @param color2
     *            The second color, not <code>null</code>.
     * @return The mixed color, not <code>null</code>.
     */
    public static RGB combineRGB(RGB color1, RGB color2) {
	return new RGB((color1.red + color2.red) >>> 1, (color1.green + color2.green) >>> 1,
		(color1.blue + color2.blue) >>> 1);
    }

    /**
     * Combines to RBG color values to a mixed color value.
     * 
     * @param color1
     *            The first color.
     * @param color2
     *            The second color.
     * @return The mixed color.
     */
    public static int combineRGBColor(int color1, int color2) {
	int r = (((color1 >>> 16) & 0xff) + ((color2 >>> 16) & 0xff)) >>> 1;
	int g = (((color1 >>> 8) & 0xff) + ((color2 >>> 8) & 0xff)) >>> 1;
	int b = (((color1 >>> 0) & 0xff) + ((color2 >>> 0) & 0xff)) >>> 1;
	return r << 16 | g << 8 | b;

    }

}
