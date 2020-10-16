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
package com.wudsn.ide.gfx.model;

import com.wudsn.ide.base.common.StringUtility;

public final class AspectUtility {

    /**
     * Creation is private.
     */
    private AspectUtility() {
    }

    /**
     * Gets the language independent string representation of an aspect.
     * 
     * @param value
     *            The aspect or <code>null</code.
     * @return The language independent string representation of the aspect, may
     *         be empty, not <code>null</code>.
     */
    public static String toString(Aspect value) {
	String result;
	if (value == null) {
	    result = "";
	} else {
	    result = value.getFactorX() + "x" + value.getFactorY();
	}
	return result;
    }

    /**
     * Gets the aspect for a language independent string representation.
     * 
     * @param value
     *            The language independent string representation, may be empty,
     *            not <code>null</code>.
     * @return The XYFactor or <code>null</code> in case the value was empty.
     */
    public static Aspect fromString(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}

	Aspect result;
	int factorX;
	int factorY;

	if (StringUtility.isEmpty(value)) {
	    result = null;
	} else {
	    int index = value.indexOf('x');
	    if (index > 0) {
		String intValue = value.substring(0, index);
		try {
		    factorX = Integer.parseInt(intValue);
		} catch (NumberFormatException ex) {
		    factorX = -1;
		}
		intValue = value.substring(index + 1, value.length());
		try {
		    factorY = Integer.parseInt(intValue);
		} catch (NumberFormatException ex) {
		    factorY = -1;
		}
	    } else {
		factorX = -1;
		factorY = -1;
	    }
	    result = new Aspect(factorX, factorY);
	}
	return result;
    }

}
