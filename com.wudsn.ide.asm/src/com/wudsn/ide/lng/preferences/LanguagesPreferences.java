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

import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.TextAttribute;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.base.common.StringUtility;
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
public final class LanguagesPreferences {

	/**
	 * The preference store to which all calls are delegated.
	 */
	private IPreferenceStore preferenceStore;

	/**
	 * Created by {@link AbstractIDEPlugin} only.
	 * 
	 * @param preferenceStore The preference store, not <code>null</code>.
	 */
	public LanguagesPreferences(IPreferenceStore preferenceStore) {
		if (preferenceStore == null) {
			throw new IllegalArgumentException("Parameter 'preferenceStore' must not be null.");
		}
		this.preferenceStore = preferenceStore;
	}



	/**
	 * Gets the preferences for a language.
	 * 
	 * @param language The language, not <code>null</code>.
	 * 
	 * @return The language preferences, not <code>null</code>.
	 */
	public LanguagePreferences getLanguagePreferences(Language language) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}

	
		return new LanguagePreferences(this, language);

	}


	/**
	 * Gets the current value of the boolean preference with the given name. Returns
	 * the default-default value <code>false</code> if there is no preference with
	 * the given name, or if the current value cannot be treated as a boolean.
	 * 
	 * @param name The name of the preference, not <code>null</code>.
	 * @return The preference value.
	 */
	boolean getBoolean(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		return preferenceStore.getBoolean(name);
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
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		String result;
		result = preferenceStore.getString(name);
		if (result == null) {
			result = "";
		} else {
			result = result.trim();
		}

		return result;
	}
	
	/**
	 * Gets the text attribute for a token type.
	 * 
	 * @param name The name of the preferences for the token type, see
	 *             {@link LanguagePreferencesConstants}.
	 * 
	 * @return The text attribute, not <code>null</code>.
	 */
	 TextAttribute getEditorTextAttribute(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		return TextAttributeConverter.fromString(preferenceStore.getString(name));
	}

}