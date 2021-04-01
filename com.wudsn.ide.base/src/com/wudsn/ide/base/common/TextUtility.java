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
 * Utility class for processing text.
 * 
 * @author Peter Dell
 */
public final class TextUtility {

    /**
     * Parameter variable tokens.
     */
    private static final String[] PARAMETERS = { "{0}", "{1}", "{2}", "{3}", "{4}", "{5}", "{6}", "{7}", "{8}", "{9}" };

    /**
     * Creation is private.
     */
    private TextUtility() {

    }

    /**
     * Formats a text with parameters "{0}" to "{9}".
     * 
     * @param text
     *            The text with the parameters "{0}" to "{9}", may be empty, not
     *            <code>null</code>.
     * @param parameters
     *            The parameters, may be empty or <code>null</code>.
     * 
     * @return The formatted text, may be empty, not <code>null</code>.
     */
    public static String format(String text, String... parameters) {
	if (text == null) {
	    throw new IllegalArgumentException("Parameter 'text' must not be null.");
	}
	if (parameters == null) {
	    parameters = new String[0];
	}
	for (int i = 0; i < parameters.length; i++) {
	    String parameter = parameters[i];
	    if (parameter == null) {
		parameter = "";
	    }
	    text = text.replace(PARAMETERS[i], parameter);
	}
	return text;
    }
}
