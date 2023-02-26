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
	 * @return The text in sentence case, not empty and not <code>null</code>.
	 */
	public static String getCompilerText(Language language) {
		switch (language) {
		case ASM:
			return Texts.LANGUAGE_ASSEMBLER_TEXT;

		case PAS:
			return Texts.LANGUAGE_COMPILER_TEXT;

		}
		throw new IllegalArgumentException("Unknown language '" + language + "'.");

	}

	public static String getCompilerPreferencesText(Language language) {
		switch (language) {
		case ASM:
			return Texts.LANGUAGES_TITLE_CASE + "/" + Texts.LANGUAGE_ASSEMBLER_TEXT_TITLE_CASE;

		case PAS:
			return Texts.LANGUAGES_TITLE_CASE + "/" + Texts.LANGUAGE_COMPILER_TEXT_TITLE_CASE;

		}
		throw new IllegalArgumentException("Unknown language '" + language + "'.");

	}
}
