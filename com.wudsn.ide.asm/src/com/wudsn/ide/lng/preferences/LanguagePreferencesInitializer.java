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

import java.util.List;

import org.eclipse.core.runtime.preferences.AbstractPreferenceInitializer;
import org.eclipse.jface.preference.IPreferenceStore;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.widgets.Display;

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.base.hardware.HardwareUtility;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerOutputFolderMode;
import com.wudsn.ide.lng.compiler.CompilerRegistry;
import com.wudsn.ide.lng.editor.AssemblerContentAssistProcessorDefaultCase;
import com.wudsn.ide.lng.editor.AssemblerEditorCompileCommandPositioningMode;
import com.wudsn.ide.lng.runner.RunnerId;

/**
 * Initializer for setting defaults values in the preferences.
 * 
 * @author Peter Dell
 */
public final class LanguagePreferencesInitializer extends AbstractPreferenceInitializer {

	/**
	 * Creation must be public default.
	 */
	public LanguagePreferencesInitializer() {
	}

	@Override
	public void initializeDefaultPreferences() {
		IPreferenceStore store = LanguagePlugin.getInstance().getPreferenceStore();

		initializeEditorPreferences(store);

		initializeCompilerPreferences(store);

		LanguagePlugin.getInstance().savePreferences();
	}

	private void initializeEditorPreferences(IPreferenceStore store) {
		if (store == null) {
			throw new IllegalArgumentException("Parameter 'store' must not be null.");
		}
		// Editor.
		Display display = Display.getCurrent();

		TextAttribute textAttribute = new TextAttribute(new Color(display, 0, 128, 0), null, SWT.ITALIC);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_COMMENT,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 0, 0, 255), null, SWT.NORMAL);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_STRING,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 0, 0, 255), null, SWT.BOLD);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_NUMBER,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 128, 64, 0), null, SWT.BOLD);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_DIRECTVE,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 0, 0, 128), null, SWT.BOLD);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 255, 32, 32), null, SWT.BOLD);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL,
				TextAttributeConverter.toString(textAttribute));

		textAttribute = new TextAttribute(new Color(display, 32, 128, 32), null, SWT.BOLD);
		store.setDefault(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO,
				TextAttributeConverter.toString(textAttribute));

		// Content assist.
		store.setDefault(LanguagePreferencesConstants.EDITOR_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE,
				AssemblerContentAssistProcessorDefaultCase.LOWER_CASE);

		// Compiling.
		store.setDefault(LanguagePreferencesConstants.EDITOR_COMPILE_COMMAND_POSITIONING_MODE,
				AssemblerEditorCompileCommandPositioningMode.FIRST_ERROR_OR_WARNING);
	}

	private void initializeCompilerPreferences(IPreferenceStore store) {
		if (store == null) {
			throw new IllegalArgumentException("Parameter 'store' must not be null.");
		}

		CompilerRegistry compilerRegistry = LanguagePlugin.getInstance().getCompilerRegistry();

		List<CompilerDefinition> compilerDefinitions = compilerRegistry.getCompilerDefinitions();
		for (CompilerDefinition compilerDefinition : compilerDefinitions) {
			String compilerId;
			String name;
			compilerId = compilerDefinition.getId();

			for (Hardware hardware : Hardware.values()) {
				if (hardware.equals(Hardware.GENERIC)) {
					continue;
				}
				store.setDefault(LanguagePreferencesConstants.getCompilerTargetName(compilerId, hardware),
						compilerDefinition.getSupportedTargets().get(0).toString());

				name = LanguagePreferencesConstants.getCompilerParametersName(compilerId, hardware);
				store.setDefault(name, compilerDefinition.getDefaultParameters());
				name = LanguagePreferencesConstants.getCompilerOutputFolderModeName(compilerId, hardware);
				store.setDefault(name, CompilerOutputFolderMode.TEMP_FOLDER);
				name = LanguagePreferencesConstants.getCompilerOutputFileExtensionName(compilerId, hardware);
				store.setDefault(name, HardwareUtility.getDefaultFileExtension(hardware));
				name = LanguagePreferencesConstants.getCompilerRunnerIdName(compilerId, hardware);
				store.setDefault(name, RunnerId.DEFAULT_APPLICATION);
			}

		}
	}
}
