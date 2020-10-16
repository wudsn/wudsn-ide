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

package com.wudsn.ide.asm.compiler;

import com.wudsn.ide.base.common.StringUtility;

/**
 * The target directory mode controls which folder is use to create the binary
 * file in.
 * 
 * @author Peter Dell
 */
public final class CompilerOutputFolderMode {

    /**
     * Creation is private.
     */
    private CompilerOutputFolderMode() {
    }

    public final static String SOURCE_FOLDER = "SOURCE_FOLDER";
    public final static String TEMP_FOLDER = "TEMP_FOLDER";
    public final static String FIXED_FOLDER = "FIXED_FOLDER";

    /**
     * Determines if the output folder mode is defined.
     * 
     * @param outputFolderMode
     *            The output folder mode, not <code>null</code>.
     * @return <code>true</code> if the output folder mode is not specified or
     *         defined.
     */
    public static boolean isDefined(String outputFolderMode) {
	if (outputFolderMode == null) {
	    throw new IllegalArgumentException("Parameter 'outputFolderMode' must not be null.");
	}
	if (StringUtility.isEmpty(outputFolderMode)) {
	    return true;
	}
	if (outputFolderMode.equals(SOURCE_FOLDER) || outputFolderMode.equals(TEMP_FOLDER)
		|| outputFolderMode.equals(FIXED_FOLDER)) {
	    return true;
	}
	return false;
    }

    /**
     * Gets the comma separated list of allowed values.
     * 
     * @return The comma separated list of allowed values, not <code>null</code>
     *         .
     */
    public static String getAllowedValues() {
	return SOURCE_FOLDER + ", " + TEMP_FOLDER + ", " + FIXED_FOLDER;
    }
}
