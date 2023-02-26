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

import java.io.File;

import org.eclipse.jface.text.TextAttribute;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerPaths;
import com.wudsn.ide.lng.compiler.CompilerPaths.CompilerPath;
import com.wudsn.ide.lng.editor.LanguageContentAssistProcessorDefaultCase;
import com.wudsn.ide.lng.editor.LanguageEditorCompileCommandPositioningMode;
import com.wudsn.ide.lng.preferences.LanguagePreferencesConstants.EditorConstants;

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
	}

	public LanguagesPreferences getLanguagesPreferences() {
		return languagesPreferences;
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
		return getString(EditorConstants.getEditorContentProcessorDefaultCaseKey(language));
	}

	/**
	 * Gets the compile command positioning mode.
	 * 
	 * @return The positioning mode, may be empty, not <code>null</code>. See
	 *         {@link LanguageEditorCompileCommandPositioningMode}.
	 * @since 1.6.1
	 */
	public String getEditorCompileCommandPositioningMode() {
		return getString(EditorConstants.getEditorCompileCommandPositioningModeKey(language));
	}

	/**
	 * Gets the executable path for the compiler.
	 * 
	 * @param compilerDefinition The compiler definition, not <code>null</code>.
	 * 
	 * @return The executable path for the runner, may be empty, not
	 *         <code>null</code>.
	 */
	public String getCompilerExecutablePath(CompilerDefinition compilerDefinition) {
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getString(LanguagePreferencesConstants.getCompilerExecutablePathKey(language, compilerDefinition));
	}

	/**
	 * Gets the executable path for the compiler or the default from the
	 * {@linkplain CompilerPaths}.
	 * 
	 * @param compilerDefinition The compiler definition, not <code>null</code>.
	 * 
	 * @return The executable path for the runner, may be empty, not
	 *         <code>null</code>.
	 */
	public String getCompilerExecutablePathOrDefault(CompilerDefinition compilerDefinition) {
		String compilerExecutablePath = getCompilerExecutablePath(compilerDefinition);

		CompilerPaths compilerPaths = LanguagePlugin.getInstance().getCompilerPaths();
		if (StringUtility.isEmpty(compilerExecutablePath)) {
			CompilerPath compilerPath = compilerPaths.getDefaultCompilerPath(language, compilerDefinition);
			if (compilerPath != null) {
				File compilerFile = compilerPath.getAbsoluteFile();
				if (compilerFile != null) {
					if (compilerFile.exists() && compilerFile.isFile() && compilerFile.canExecute()) {
						compilerExecutablePath = compilerFile.getAbsolutePath();
					}
				}
			}

		}
		return compilerExecutablePath;
	}

	/**
	 * Gets the preferences for a compiler.
	 * 
	 * @param hardware           The preferences or <code>null</code> if the
	 *                           compiler is not active for that hardware.
	 * @param compilerDefinition The compiler definition, not empty and not
	 *                           <code>null</code>.
	 * 
	 * @return The compiler preferences, not <code>null</code>.
	 */
	public LanguageHardwareCompilerDefinitionPreferences getLanguageHardwareCompilerDefinitionPreferences(
			Hardware hardware, CompilerDefinition compilerDefinition) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}

		return new LanguageHardwareCompilerDefinitionPreferences(this, hardware, compilerDefinition);

	}

	/**
	 * Create the preferences key for a value of a given language.
	 * 
	 * @param language             The language, not <code>null</code>
	 * @param preferencesKeySuffix The suffix as defined by the constants of this
	 *                             class, not empty, not <code>null</code>
	 * @return
	 */
	public static String getLanguagePreferencesKey(Language language, String preferencesKeySuffix) {
		return language.name().toLowerCase() + "." + preferencesKeySuffix;
	}

	/**
	 * Gets the current value of the boolean preference with the given name. Returns
	 * the default value <code>false</code> if there is no preference with the given
	 * name, or if the current value cannot be treated as a boolean.
	 * 
	 * @param preferencesKey The key of the preference, not empty and not
	 *                       <code>null</code>.
	 * @return The preference value.
	 */
	boolean getBoolean(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		return languagesPreferences.getBoolean(preferencesKey);
	}

	/**
	 * Gets the current value of the string-valued preference with the given name.
	 * Returns the default-default value (the empty string <code>""</code> ) if
	 * there is no preference with the given name, or if the current value cannot be
	 * treated as a string.
	 * 
	 * @param preferencesKey The key of the preference, not empty and not
	 *                       <code>null</code>.
	 * 
	 * @return The preference value, may be empty, not <code>null</code>.
	 */
	String getString(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		return languagesPreferences.getString(preferencesKey);
	}

	/**
	 * Gets the text attribute for a token type.
	 * 
	 * @param preferencesKey The key of the preference, not empty and not
	 *                       <code>null</code>.
	 * 
	 * @return The text attribute, not <code>null</code>.
	 */
	public TextAttribute getTextAttribute(String preferencesKey) {
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		return languagesPreferences.getEditorTextAttribute(preferencesKey);

	}

}