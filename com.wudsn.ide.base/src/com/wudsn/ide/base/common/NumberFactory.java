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

package com.wudsn.ide.base.common;

/**
 * Factory class to obtain instances of elementary number type wrappers without
 * creating new instances.
 * 
 * @author Peter Dell
 * 
 */
public final class NumberFactory {

    private static final int MAX_INTEGERS = 2048;
    private static final Integer[] INTEGERS;

    /**
     * Static initialization.
     */
    static {
	INTEGERS = new Integer[MAX_INTEGERS];
	for (int i = 0; i < MAX_INTEGERS; i++) {
	    INTEGERS[i] = Integer.valueOf(i);
	}
    }

    /**
     * Gets the @link Integer} instance for an int value.
     * 
     * @param value
     *            The int value.
     * @return The {@link Integer} instance, not <code>null</code>.
     */
    public static final Integer getInteger(int value) {
	if (0 <= value && value <= MAX_INTEGERS) {

	}
	return Integer.valueOf(value);
    }
}
