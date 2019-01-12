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

package com.wudsn.ide.base.common;

/**
 * Utility class to handle decimal numbers.
 */
public final class NumberUtility {

    /**
     * Automatic length indicator for
     * {@link #getLongValueDecimalString(long, int)},
     */
    public static final int AUTOMATIC_LENGTH = 0;

    /**
     * Creation is private.
     */
    private NumberUtility() {
    }

    /**
     * Gets the minimum length of the decimal string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * 
     * @return The minimum length of the decimal string for the long value, a
     *         positive integer.
     */
    public static int getLongValueDecimalLength(int longValue) {
	return Long.toString(longValue).length();
    }

    /**
     * Gets the decimal string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * 
     * @return The string, not empty and not <code>null</code>.
     */
    public static String getLongValueDecimalString(long longValue) {
	return getLongValueDecimalString(longValue, AUTOMATIC_LENGTH);
    }

    /**
     * Gets the decimal string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * @param length
     *            The minimum number of characters to be used. If the result
     *            string is shorter, spaces will be prepended in case a length
     *            other then {@link #AUTOMATIC_LENGTH} is specified.
     * @return The string, not empty and not <code>null</code>.
     */
    public static String getLongValueDecimalString(long longValue, int length) {

	String result = Long.toString(longValue);
	if (length > AUTOMATIC_LENGTH) {
	    int difference = length - result.length();
	    if (difference > 0) {
		StringBuilder builder = new StringBuilder(length);
		builder.insert(difference, result);
		result = builder.toString();
	    }
	}
	return result;
    }

}
