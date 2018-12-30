/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

import com.wudsn.ide.gfx.converter.PaletteMapper;

// TODO C64PaletteMapper is not yet used. Will be required for Koala pictures etc.
/**
 * C64 to Atari Mapping
 * 
 * <pre>
 *  0	Black		0,0	0,2
 *  1	White		0,15	0,14
 *  2	Red		3,5	3,6
 *  3	Cyan		9,11	9,12
 *  4	Purple		4,7	5,8
 *  5	Green		11,8	11,10
 *  6	Blue		7,5	7,6
 *  7	Yellow		14,14	14,14
 *  8	Orange		1,5	1,12 (Light Brown)
 *  9	Brown		14,4	1,8
 * 10	Light Red	3,10	3,12 (Pink)
 * 11	Dark Grey	0,6	0,6
 * 12	Med Grey	0,9	0,10
 * 13	Light Green	11,13	11,14
 * 14	Light Blue	6,10	7,10
 * 15	Light Grey	0,11	0,12
 * </pre>
 */
public final class C64PaletteMapper extends PaletteMapper{

    /**
     * Creation is private.
     */
    public  C64PaletteMapper() {
	super(16);
	// From http://unusedino.de/ec64/technical/misc/vic656x/colors/index.html
	loadPalette("pepto.pal");
    }
}
