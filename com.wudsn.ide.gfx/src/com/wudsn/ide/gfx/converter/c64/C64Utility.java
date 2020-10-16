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

package com.wudsn.ide.gfx.converter.c64;

import com.wudsn.ide.base.common.NumberFactory;

/**
 * C64Utility color codes as defined by VIC II.
 * 
 * @author Peter Dell
 * 
 */
public final class C64Utility {

    public static final Integer BLACK = NumberFactory.getInteger(0);
    public static final Integer WHITE = NumberFactory.getInteger(1);
    public static final Integer RED = NumberFactory.getInteger(2);
    public static final Integer CYAN = NumberFactory.getInteger(3);
    public static final Integer PINK = NumberFactory.getInteger(4);
    public static final Integer GREEN = NumberFactory.getInteger(5);
    public static final Integer BLUE = NumberFactory.getInteger(6);
    public static final Integer YELLOW = NumberFactory.getInteger(7);
    public static final Integer ORANGE = NumberFactory.getInteger(8);
    public static final Integer BROWN = NumberFactory.getInteger(9);
    public static final Integer LIGHT_RED = NumberFactory.getInteger(10);
    public static final Integer DARK_GRAY = NumberFactory.getInteger(11);
    public static final Integer MEDIUM_GRAY = NumberFactory.getInteger(12);
    public static final Integer LIGHT_GREEN = NumberFactory.getInteger(13);
    public static final Integer LIGHT_BLUE = NumberFactory.getInteger(14);
    public static final Integer LIGHT_GRAY = NumberFactory.getInteger(15);

    /**
     * Determines if a byte array represents a valid C64 charset.
     * 
     * @param bytes
     *            The byte array, may be empty, not <code>null</code>.
     * @return <code>true</code> if the byte array represents a valid C64
     *         charset, <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public static boolean isC64Charset(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 2048 || bytes.length % 0x100 == 2
		|| (bytes.length > 2 && bytes[0] == 0x00 && bytes[1] == 0x38);
    }

    /**
     * Determines if a byte array represents a valid C64 sprite (or many).
     * 
     * @param bytes
     *            The byte array, may be empty, not <code>null</code>.
     * @return <code>true</code> if the byte array represents a valid C64 sprite
     *         (or many), <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public static boolean isC64Sprite(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	return bytes.length == 64 || (bytes.length > 2 + 64 && bytes[0] == 0x00);
    }
}