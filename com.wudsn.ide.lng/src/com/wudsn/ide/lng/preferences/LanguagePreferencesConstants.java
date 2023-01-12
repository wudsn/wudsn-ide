/**
R * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.util.ArrayList;
import java.util.List;

import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerDefinition;

/**
 * Constants for preferences.
 * 
 * @author Peter Dell
 */
public final class LanguagePreferencesConstants {

	public static final class EditorConstants {
		/**
		 * Preference key for comment text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_COMMENT = "editor.text.attribute.comment"; //$NON-NLS-1$

		/**
		 * Preferences key for string text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_STRING = "editor.text.attribute.string"; //$NON-NLS-1$

		/**
		 * Preferences key for number text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_NUMBER = "editor.text.attribute.number"; //$NON-NLS-1$

		/**
		 * Preference key for directive text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_DIRECTVE = "editor.text.attribute.directive"; //$NON-NLS-1$

		/**
		 * Preference key for legal opcode text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL = "editor.text.attribute.opcode.legal"; //$NON-NLS-1$

		/**
		 * Preference key for illegal opcode text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL = "editor.text.attribute.opcode.illegal"; //$NON-NLS-1$

		/**
		 * Preference key for pseudo opcode text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO = "editor.text.attribute.opcode.pseudo"; //$NON-NLS-1$

		/**
		 * Preference key for equate identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE = "editor.text.attribute.identifier.equate"; //$NON-NLS-1$

		/**
		 * Preference key for label identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LABEL = "editor.text.attribute.identifier.label"; //$NON-NLS-1$

		/**
		 * Preference key for enum identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION = "editor.text.attribute.identifier.enum"; //$NON-NLS-1$

		/**
		 * Preference key for structure identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION = "editor.text.attribute.identifier.structure"; //$NON-NLS-1$

		/**
		 * Preference key for local identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION = "editor.text.attribute.identifier.local"; //$NON-NLS-1$

		/**
		 * Preference key for macro identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION = "editor.text.attribute.identifier.macro"; //$NON-NLS-1$

		/**
		 * Preference key for default case for content assist.
		 */
		static final String EDITOR_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE = "editor.content.assist.processor.default.case"; //$NON-NLS-1$

		/**
		 * Preference key for procedure identifier text style.
		 */
		public static final String EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION = "editor.text.attribute.identifier.procedure"; //$NON-NLS-1$


		/**
		 * Preference key for positioning for for compiling.
		 * 
		 * @since 1.6.1
		 */
		static final String EDITOR_COMPILE_COMMAND_POSITIONING_MODE = "editor.compile.command.positioning.mode"; //$NON-NLS-1$

		/**
		 * Gets preference key name for a editor attribute.
		 * 
		 * @param language The language <code>null</code>.
		 * 
		 * @return The preference key name for the compiler executable path, not empty
		 *         and not <code>null</code>.
		 */
		public static String getEditorAttributeKey(Language language, String textAttributeName) {
			if (language == null) {
				throw new IllegalArgumentException("Parameter 'language' must not be null.");
			}
			String preferencesKey = getLanguagePreferencesKey(language, textAttributeName);
			return preferencesKey;
		}

		static String getEditorContentProcessorDefaultCaseKey(Language language) {
			if (language == null) {
				throw new IllegalArgumentException("Parameter 'language' must not be null.");
			}

			return getEditorAttributeKey(language, EditorConstants.EDITOR_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE);
		}

		static String getEditorCompileCommandPositioningModeKey(Language language) {
			if (language == null) {
				throw new IllegalArgumentException("Parameter 'language' must not be null.");
			}

			return getEditorAttributeKey(language, EditorConstants.EDITOR_COMPILE_COMMAND_POSITIONING_MODE);
		}
		
		/**
		 * Gets the list of all preferences keys that depend on the global JFact text
		 * font setting.
		 * 
		 * @param language The language, not <code>null</code>.
		 */
		public static List<TextAttributeDefinition> getTextAttributeDefinitions(Language language) {
			if (language == null) {
				throw new IllegalArgumentException("Parameter 'language' must not be null.");
			}

			List<TextAttributeDefinition> result = new ArrayList<TextAttributeDefinition>();

			// Comments and literals
			result.add(new TextAttributeDefinition(getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_COMMENT),
					Texts.PREFERENCES_TEXT_ATTRIBUTE_COMMENT_NAME));
			result.add(new TextAttributeDefinition(getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_NUMBER),
					Texts.PREFERENCES_TEXT_ATTRIBUTE_NUMBER_NAME));
			result.add(new TextAttributeDefinition(getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_STRING),
					Texts.PREFERENCES_TEXT_ATTRIBUTE_STRING_NAME));

			switch (language) {
			case ASM: {

				// Built-in
				result.add(new TextAttributeDefinition(getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_DIRECTVE),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_DIRECTIVE));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_OPCODE_ILLEGAL),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_ILLEGAL_NAME));
				result.add(
						new TextAttributeDefinition(getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_OPCODE_LEGAL),
								Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_LEGAL_NAME));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_OPCODE_PSEUDO),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_OPCODE_PSEUDO_NAME));

				// Identifiers
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LABEL),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LABEL));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION));
				result.add(new TextAttributeDefinition(
						getEditorAttributeKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION));
				break;

			}

			case PAS: {

				// Built-in
				result.add(
						new TextAttributeDefinition(getLanguagePreferencesKey(language, EDITOR_TEXT_ATTRIBUTE_DIRECTVE),
								Texts.PREFERENCES_TEXT_ATTRIBUTE_DIRECTIVE));

				// Identifiers
				result.add(new TextAttributeDefinition(
						getLanguagePreferencesKey(language, EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION));
				result.add(new TextAttributeDefinition(
						getLanguagePreferencesKey(language,
								EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION));
				result.add(new TextAttributeDefinition(
						getLanguagePreferencesKey(language,
								EDITOR_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION),
						Texts.PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION));
				break;

			}
			default:
				throw new IllegalArgumentException("Unsupported language " + language + ".");
			}

			return result;
		}
	}

	/**
	 * Creation is private.
	 */
	private LanguagePreferencesConstants() {
	}

	/**
	 * Determines if preference key name represents a setting for compiler targets
	 * visibility.
	 * 
	 * @param name The name of the preferences key, not <code>null</code>.
	 * @return <code>true</code> if preference key name represents a setting for
	 *         compiler opcodes visibility, <code>false</code> otherwise.
	 */
	public static boolean isCompilerTargetName(Language language, String preferencesKey) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (preferencesKey == null) {
			throw new IllegalArgumentException("Parameter 'preferencesKey' must not be null.");
		}
		var prefix = getLanguagePreferencesKey(language, "compiler.");
		boolean result = preferencesKey.startsWith(prefix) && preferencesKey.endsWith(".target");
		return result;
	}

	/**
	 * Create the preferences key for a value of a given language.
	 * 
	 * @param language             The language, not <code>null</code>
	 * @param preferencesKeySuffix The suffix as defined by the constants of this
	 *                             class, not empty, not <code>null</code>
	 * @return
	 */
	static String getLanguagePreferencesKey(Language language, String preferencesKeySuffix) {
		return language.name().toLowerCase() + "." + preferencesKeySuffix;
	}

	/**
	 * Gets preference key name for the compiler executable path. This is the only
	 * hardware independent compiler setting.
	 * 
	 * @param The                language, not <code>null</code>
	 * @param compilerDefinition The compiler definition, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler executable path, not empty
	 *         and not <code>null</code>.
	 */
	static String getCompilerExecutablePathKey(Language language, CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguagePreferencesKey(language, "compiler." + compilerDefinition.getId() + ".executable.path"); //$NON-NLS-1$
	}
}
