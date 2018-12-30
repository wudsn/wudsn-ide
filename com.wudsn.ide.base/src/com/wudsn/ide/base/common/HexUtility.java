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
 * Utility class to handle hex numbers.
 */
public final class HexUtility {

    /**
     * Automatic length indicator for {@link #getLongValueHexString(long, int)},
     */
    public static final int AUTOMATIC_LENGTH = 0;

    /**
     * Static array of all one-byte upper case hex numbers (00...FF)
     */
    private static final String[] hexStrings;

    /**
     * Static initialization.
     */
    static {

	// Fill in the array of hex strings
	hexStrings = new String[256];
	for (int i = 0; i < 256; i++) {
	    String s = Integer.toHexString(i).toUpperCase();
	    hexStrings[i] = (s.length() < 2) ? ("0" + s) : s;
	}
    }

    /**
     * Creation is private.
     */
    private HexUtility() {

    }

    /**
     * Gets the hex string for a single byte value.
     * 
     * @param byteValue
     *            The byte value.
     * @return The string, not empty and not <code>null</code>.
     */
    public static String getByteValueHexString(int byteValue) {
	if (byteValue < 0 || byteValue > 255) {
	    throw new IllegalArgumentException("Integer value " + byteValue
		    + " is no byte value.");
	}
	return hexStrings[byteValue];
    }

    /**
     * Gets the minimum length of the hex string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * 
     * @return The minimum length of the hex string for the long value, an even
     *         positive integer.
     */
    public static int getLongValueHexLength(long longValue) {
	if (longValue < 0) {
	    throw new RuntimeException(
		    "Parameter 'longValue' must not be negative. Specified value is "
			    + longValue + ".");
	}
	int result = Long.toHexString(longValue).length();
	if ((result & 1) == 1) {
	    result++;
	}
	return result;
    }

    /**
     * Gets the hex string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * @return The string, not empty and not <code>null</code>.
     */
    public static String getLongValueHexString(long longValue) {
	return getLongValueHexString(longValue,
		getLongValueHexLength(longValue));
    }

    /**
     * Gets the hex string for a long value.
     * 
     * @param longValue
     *            The non-negative long value.
     * @param length
     *            The minimum number of characters to be used. If the result
     *            string is shorter, spaces will be prepended in case a length
     *            other then {@link #AUTOMATIC_LENGTH} is specified.
     * @return The string, not empty and not <code>null</code>.
     */
    public static String getLongValueHexString(long longValue, int length) {
	if (longValue < 0) {
	    throw new RuntimeException(
		    "Parameter 'longValue' must not be negative. Specified value is "
			    + longValue + ".");
	}
	if (length < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'length' must not be negative. Specified value is "
			    + length + ".");
	}
	String result = Long.toHexString(longValue).toUpperCase();
	if (length > AUTOMATIC_LENGTH) {
	    int difference = length - result.length();
	    if (difference > 0) {
		StringBuilder builder = new StringBuilder(length);
		for (int i = 0; i < difference; i++) {
		    builder.append('0');
		}
		builder.insert(difference, result);
		result = builder.toString();
	    }
	}
	return result;
    }

    /**
     * Gets the ASCII char for a single byte value.
     * 
     * @param byteValue
     *            The byte value.
     * @return The string, not empty and not <code>null</code>.
     */
    public static char getChar(int byteValue) {
	char result;
	if (byteValue >= 32 && byteValue <= 127) {
	    result = (char) (byteValue & 0xff);
	} else {
	    result = ' ';
	}
	return result;
    }
}
