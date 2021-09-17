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

package com.wudsn.ide.base.common;

/**
 * Utility class to handle strings.
 * 
 * @author Peter Dell
 * 
 */
public final class StringUtility {

	/**
	 * Creation is private.
	 */
	private StringUtility() {

	}

	/**
	 * Determines if a string value is empty, i.e. has zero length or is only
	 * containing white spaces.
	 * 
	 * @param value The string value, not <code>null</code>.
	 * @return <code>true</code> if the value is empty or only containing of white
	 *         spaces, <code>false</code> otherwise.
	 */
	public static boolean isEmpty(String value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		return value.trim().length() == 0;
	}

	/**
	 * Determines if a string value is specified, i.e. not empty and not only
	 * containing white spaces.
	 * 
	 * @param value The string value, not <code>null</code>.
	 * @return <code>true</code> if the value is not empty and not only containing
	 *         of white spaces, <code>false</code> otherwise.
	 */
	public static boolean isSpecified(String value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		return value.trim().length() > 0;
	}
}
