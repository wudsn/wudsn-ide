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

import com.wudsn.ide.base.common.EnumUtility;

/**
 * Utility class for languages
 * 
 * @author Peter Dell
 * 
 * @since 1.7.2
 */
public final class LanguageUtility {

	/**
	 * Creation is private.
	 */
	private LanguageUtility() {
	}
	
	/**
	 * Gets the text for a language.
	 * 
	 * @param language The language, not <code>null</code>.
	 * @return The text, title case, not empty and not <code>null</code>.
	 */
	public static String getText(Language language) {
		return EnumUtility.getText(language);
	}

	
	/**
	 * Gets the text for type of compilers for a language.
	 * 
	 * @param language The language, not <code>null</code>.
	 * @return The text, not empty and not <code>null</code>.
	 */
	public static String getCompilerTextLower(Language language) { 
		switch (language) {
		case ASM:
			return "assembler"; // TODO: Have translation, so lower/upper is correct in German

		case PAS:
			return "compiler";

		}
		throw new IllegalArgumentException("Unknown language '" + language + "'.");

	}
	
	public static String getCompilerPreferencesText(Language language) {
		switch (language) {
		case ASM:
			return "Languages/Assemblers";

		case PAS:
			return "Languages/Compilers";

		}
		throw new IllegalArgumentException("Unknown language '" + language + "'.");

	}
}
