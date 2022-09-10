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

package com.wudsn.ide.lng.preferences;

import org.eclipse.jface.text.TextAttribute;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.editor.LanguageContentAssistProcessorDefaultCase;
import com.wudsn.ide.lng.editor.LanguageEditorCompileCommandPositioningMode;

/**
 * Facade class for typed access to the plugin preferences.
 * 
 * @author Peter Dell
 */
public final class LanguagePreferences {

	/**
	 * The preference store to which all calls are delegated.
	 */
	private LanguagesPreferences languagesPreferences;
	private Language language;
	private String languagePrefix;

	/**
	 * Created by {@link AbstractIDEPlugin} only.
	 * 
	 * @param languagesPreferences The languages preferences, not <code>null</code>.
	 */
	public LanguagePreferences(LanguagesPreferences languagesPreferences, Language language) {
		if (languagesPreferences == null) {
			throw new IllegalArgumentException("Parameter 'languagesPreferences' must not be null.");
		}
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		this.languagesPreferences = languagesPreferences;
		this.language = language;
		this.languagePrefix=language.name().toLowerCase()+".";
	}

	public Language getLanguage() {
		return language;
	}
	
	/**
	 * Gets the default case content assist.
	 * 
	 * @return The default case content assist, may be empty, not <code>null</code>.
	 *         See {@link LanguageContentAssistProcessorDefaultCase}.
	 */
	public String getEditorContentAssistProcessorDefaultCase() {
		return getString(LanguagePreferencesConstants.EDITOR_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE);
	}

	/**
	 * Gets the compile command positioning mode.
	 * 
	 * @return The positioning mode, may be empty, not <code>null</code>. See
	 *         {@link LanguageEditorCompileCommandPositioningMode}.
	 * @since 1.6.1
	 */
	public String getEditorCompileCommandPositioningMode() {
		return getString(LanguagePreferencesConstants.EDITOR_COMPILE_COMMAND_POSITIONING_MODE);
	}

	/**
	 * Gets the preferences for a compiler.
	 * 
	 * @param compilerDefinition The compiler definition, not empty and not
	 *                           <code>null</code>.
	 * @param hardware           The preferences or <code>null</code> if the
	 *                           compiler is not active for that hardware.
	 * 
	 * @return The compiler preferences, not <code>null</code>.
	 */
	public CompilerPreferences getCompilerPreferences(CompilerDefinition compilerDefinition, Hardware hardware) {
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}

		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		return new CompilerPreferences(this, compilerDefinition.getId(), hardware);

	}

	/**
	 * Gets the current value of the boolean preference with the given name. Returns
	 * the default value <code>false</code> if there is no preference with the given
	 * name, or if the current value cannot be treated as a boolean.
	 * 
	 * @param name The name of the preference, not <code>null</code>.
	 * @return The preference value.
	 */
	boolean getBoolean(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		return languagesPreferences.getBoolean(languagePrefix+ name);
	}

	/**
	 * Gets the current value of the string-valued preference with the given name.
	 * Returns the default-default value (the empty string <code>""</code> ) if
	 * there is no preference with the given name, or if the current value cannot be
	 * treated as a string.
	 * 
	 * @param name The name of the preference, not <code>null</code>.
	 * @return The preference value, may be empty, not <code>null</code>.
	 */
	String getString(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		return languagesPreferences.getString(languagePrefix + name);
	}

	/**
	 * Gets the text attribute for a token type.
	 * 
	 * @param name The name of the preferences for the token type, see
	 *             {@link LanguagePreferencesConstants}.
	 * 
	 * @return The text attribute, not <code>null</code>.
	 */
	public TextAttribute getEditorTextAttribute(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		return languagesPreferences.getEditorTextAttribute(languagePrefix+ name);

	}

}