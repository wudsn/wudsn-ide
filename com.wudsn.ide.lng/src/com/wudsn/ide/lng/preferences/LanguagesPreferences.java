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

import org.eclipse.core.runtime.preferences.InstanceScope;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.swt.widgets.Display;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.preferences.ScopedPreferenceStore;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;

/**
 * Facade class for typed access to the plugin preferences.
 * 
 * @author Peter Dell
 */
public final class LanguagesPreferences {

	/**
	 * Cached theme ID.
	 */
	static String themeID = null;

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
	 * @param preferencesKey The key of the preference, not <code>null</code>.
	 * @return The preference value.
	 */
	boolean getBoolean(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		var result = preferenceStore.getBoolean(preferencesKey);
		log(preferencesKey, result ? "true" : "false");
		return result;
	}

	/**
	 * Gets the current value of the string-valued preference with the given name.
	 * Returns the default-default value (the empty string <code>""</code> ) if
	 * there is no preference with the given name, or if the current value cannot be
	 * treated as a string.
	 * 
	 * @param preferencesKey The key of the preference, not <code>null</code>.
	 * @return The preference value, may be empty, not <code>null</code>.
	 */
	String getString(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		String result;
		result = preferenceStore.getString(preferencesKey);
		if (result == null) {
			result = "";
		} else {
			result = result.trim();
		}
		log(preferencesKey, result);
		return result;
	}

	/**
	 * Returns <code>true</code> if the current OS theme has a dark appearance, else
	 * returns <code>false</code>.
	 */
	static boolean isDarkThemeActive() {
		if (themeID == null) {
			var store = new ScopedPreferenceStore(InstanceScope.INSTANCE, "org.eclipse.e4.ui.css.swt.theme");
			themeID = store.getString("themeid");
			if (themeID == null) {
				themeID = "undefined";
			}
		}
		return themeID.equals("org.eclipse.e4.ui.css.theme.e4_dark");
	}

	/**
	 * Gets the text attribute preferences key based on the current theme. Dark
	 * themes have a separate set of color.
	 * 
	 * @param textAttributeDefinition The text attribute definition, not
	 *                                <code>null</code>.
	 * @return The theme specific key of the preference, not <code>null</code>.
	 */
	static String getThemeTextAttributePreferencesKey(TextAttributeDefinition textAttributeDefinition) {
		return getThemeTextAttributePreferencesKey(isDarkThemeActive(), textAttributeDefinition.getPreferencesKey());
	}

	static String getThemeTextAttributePreferencesKey(boolean darkTheme, String preferencesKey) {
		if (darkTheme) {
			preferencesKey += ".darkTheme";
		}
		return preferencesKey;
	}

	/**
	 * Gets the text attribute for a token type.
	 * 
	 * @param preferencesKey The key of the preference, not <code>null</code>.
	 * 
	 * @return The text attribute, not <code>null</code>.
	 * 
	 */
	TextAttribute getEditorTextAttribute(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}

		preferencesKey = getThemeTextAttributePreferencesKey(isDarkThemeActive(), preferencesKey);
		return TextAttributeConverter.fromString(getString(preferencesKey));
	}

	/**
	 * Logs the result of a read access for debugging purposes.
	 * 
	 * @param preferencesKey The preferences key, not <code>null</code>
	 * @param result         The result, not <code>null</code>.
	 */
	private void log(String preferencesKey, String result) {
		if (true) {
			if (preferencesKey.startsWith("editor")) {
				LanguagePlugin.getInstance().log("Result of language preferences key '{0}' is '{1}'",
						new Object[] { preferencesKey, result });
			}
		}

	}

}