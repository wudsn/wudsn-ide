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

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Display;

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.base.hardware.HardwareUtility;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerOutputFolderMode;
import com.wudsn.ide.lng.editor.LanguageContentAssistProcessorDefaultCase;
import com.wudsn.ide.lng.editor.LanguageEditorCompileCommandPositioningMode;
import com.wudsn.ide.lng.preferences.LanguagePreferencesConstants.EditorConstants;
import com.wudsn.ide.lng.runner.RunnerId;

/**
 * Initializer for setting defaults values in the preferences.
 * 
 * @author Peter Dell
 */
public final class LanguagePreferencesInitializer extends AbstractPreferenceInitializer {

	private IPreferenceStore store;

	/**
	 * Creation must be public default.
	 */
	public LanguagePreferencesInitializer() {
		store = LanguagePlugin.getInstance().getPreferenceStore();

	}

	private void setDefault(String key, String value) {
		store.setDefault(key, value);
	}

	private void setLanguageTextAttributeDefault(Language language, String textAttributeName, int r, int g, int b,
			int style) {
		// Editor.
		var display = Display.getCurrent();
		var textAttribute = new TextAttribute(new Color(display, r, g, b), null, style);
		var preferencesKey = LanguagePreferencesConstants.EditorConstants.getEditorAttributeKey(language,
				textAttributeName);
		setDefault(preferencesKey, TextAttributeConverter.toString(textAttribute));
	}

	@Override
	public void initializeDefaultPreferences() {

		initializeLanguage(Language.ASM);
		initializeLanguage(Language.PAS);

		LanguagePlugin.getInstance().savePreferences();
	}

	private void initializeLanguage(Language language) {

		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		initializeEditorPreferences(language);
		initializeHardwareCompilerDefinitionPreferences(language);
	}

	private void initializeEditorPreferences(Language language) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_COMMENT, 0, 128, 0, SWT.ITALIC);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_DIRECTVE, 128, 64, 0, SWT.BOLD);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_NUMBER, 0, 0, 255, SWT.BOLD);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL, 0, 0, 128,
				SWT.BOLD);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL, 255, 32, 32,
				SWT.BOLD);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO, 32, 128, 32,
				SWT.BOLD);
		setLanguageTextAttributeDefault(language, EditorConstants.EDITOR_TEXT_ATTRIBUTE_STRING, 0, 0, 255, SWT.NORMAL);

		// Content assist.
		var preferencesKey = EditorConstants.getEditorContentProcessorDefaultCaseKey(language);
		setDefault(preferencesKey, LanguageContentAssistProcessorDefaultCase.LOWER_CASE);

		// Compiling.
		preferencesKey = EditorConstants.getEditorCompileCommandPositioningModeKey(language);
		setDefault(preferencesKey, LanguageEditorCompileCommandPositioningMode.FIRST_ERROR_OR_WARNING);
	}

	private void initializeHardwareCompilerDefinitionPreferences(Language language) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		var languagePlugin = LanguagePlugin.getInstance();
		var compilerRegistry = languagePlugin.getCompilerRegistry();
		var compilerDefinitions = compilerRegistry.getCompilerDefinitions(language);

		for (Hardware hardware : Hardware.values()) {
			if (hardware.equals(Hardware.GENERIC)) {
				continue;
			}
			for (var compilerDefinition : compilerDefinitions) {

				setDefault(LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerTargetName(language,
						hardware, compilerDefinition), compilerDefinition.getSupportedTargets().get(0).toString());

				var preferencesKey = LanguageHardwareCompilerDefinitionPreferencesConstants
						.getCompilerParametersName(language, hardware, compilerDefinition);
				setDefault(preferencesKey, compilerDefinition.getDefaultParameters());
				preferencesKey = LanguageHardwareCompilerDefinitionPreferencesConstants
						.getCompilerOutputFolderModeName(language, hardware, compilerDefinition);
				setDefault(preferencesKey, CompilerOutputFolderMode.TEMP_FOLDER);
				preferencesKey = LanguageHardwareCompilerDefinitionPreferencesConstants
						.getCompilerOutputFileExtensionName(language, hardware, compilerDefinition);
				setDefault(preferencesKey, HardwareUtility.getDefaultFileExtension(hardware));
				preferencesKey = LanguageHardwareCompilerDefinitionPreferencesConstants
						.getCompilerRunnerIdName(language, hardware, compilerDefinition);
				setDefault(preferencesKey, RunnerId.DEFAULT_APPLICATION);
			}

		}
	}
}
