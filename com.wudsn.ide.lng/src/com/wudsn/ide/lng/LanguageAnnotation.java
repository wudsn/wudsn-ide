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

package com.wudsn.ide.lng;

import java.util.ArrayList;
import java.util.List;

public final class LanguageAnnotation {

	/**
	 * Source code annotations.
	 */
	public final static String PREFIX = "@com.wudsn.ide.lng.";
	public final static String OLD_PREFIX = "@com.wudsn.ide.asm.";
	public final static String HARDWARE = "@com.wudsn.ide.lng.hardware";
	public final static String MAIN_SOURCE_FILE = "@com.wudsn.ide.lng.mainsourcefile";
	public final static String OUTPUT_FOLDER_MODE = "@com.wudsn.ide.lng.outputfoldermode";
	public final static String OUTPUT_FOLDER = "@com.wudsn.ide.lng.outputfolder";
	public final static String OUTPUT_FILE_EXTENSION = "@com.wudsn.ide.lng.outputfileextension";
	public final static String OUTPUT_FILE = "@com.wudsn.ide.lng.outputfile";

	public static List<String> getAnnotations() {
		List<String> result = new ArrayList<String>();
		result.add(HARDWARE);
		result.add(MAIN_SOURCE_FILE);
		result.add(OUTPUT_FOLDER_MODE);
		result.add(OUTPUT_FOLDER);
		result.add(OUTPUT_FILE_EXTENSION);
		result.add(OUTPUT_FILE);
		return result;
	}
}
