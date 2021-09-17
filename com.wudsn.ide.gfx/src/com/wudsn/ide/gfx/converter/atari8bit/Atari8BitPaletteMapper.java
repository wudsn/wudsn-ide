package com.wudsn.ide.gfx.converter.atari8bit;

import com.wudsn.ide.gfx.converter.PaletteMapper;

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
 * Palette mapper for mapping Atari color values to RGB and back.
 * 
 * @since 1.6.4
 */
public final class Atari8BitPaletteMapper extends PaletteMapper {

	public Atari8BitPaletteMapper() {
		super(256);
		// loadPalette("default.act");
		loadPalette("laoo.act");
		// loadPalette("real.act");

	}

}