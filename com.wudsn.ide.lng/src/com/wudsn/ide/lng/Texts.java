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

import org.eclipse.osgi.util.NLS;

/**
 * Class which holds the localized text constants.
 * 
 * @author Peter Dell
 */
public final class Texts extends NLS {

	/**
	 * Languages,
	 */
	public static String LANGUAGES_TITLE_CASE;
	public static String LANGUAGE_ASSEMBLER_TEXT_TITLE_CASE;
	public static String LANGUAGE_ASSEMBLER_TEXT;
	public static String LANGUAGE_COMPILER_TEXT_TITLE_CASE;
	public static String LANGUAGE_COMPILER_TEXT;

	/**
	 * Compiler console.
	 */
	public static String COMPILER_CONSOLE_TITLE;

	/**
	 * Compiler source parser tree.
	 */
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_DEFAULT;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_DEFINITION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_IMPLEMENTATION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_EQUATE_DEFINITION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_LABEL_DEFINITION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_ENUM_DEFINITION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_STRUCTURE_DEFINITION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_LOCAL_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_MACRO_DEFINITION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_PAGES_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_PROCEDURE_DEFINITION_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_REPEAT_SECTION;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_SOURCE_INCLUDE;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_BINARY_INCLUDE;
	public static String COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_BINARY_OUTPUT;

	/**
	 * Compiler syntax.
	 */
	public static String COMPILER_SYNTAX_INSTRUCTION_DIRECTIVE;
	public static String COMPILER_SYNTAX_LEGAL_OPCODE;
	public static String COMPILER_SYNTAX_ILLEGAL_OPCODE;
	public static String COMPILER_SYNTAX_PSEUDO_OPCODE;
	public static String COMPILER_SYNTAX_W65816_ONLY;

	/**
	 * Compiler toolbar and menu.
	 * 
	 */
	public static String COMPILER_TOOLBAR_RUN_WITH_DEFAULT_LABEL;

	/**
	 * Compiler content outline.
	 */
	public static String COMPILER_CONTENT_OUTLINE_SORT_BUTTON_TOOL_TIP;
	public static String COMPILER_CONTENT_OUTLINE_TREE_TYPE_DEFAULT;
	public static String COMPILER_CONTENT_OUTLINE_TREE_TYPE_DEFINITION_SECTION;
	public static String COMPILER_CONTENT_OUTLINE_TREE_TYPE_IMPLEMENTATION_SECTION;

	/**
	 * Compiler hyperlink detector.
	 */
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_SOURCE_WITH_LANGUAGE_EDITOR;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_BINARY_WITH_HEX_EDITOR;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_BINARY_WITH_GRAPHICS_EDITOR;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_BINARY_WITH_DEFAULT_EDITOR;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_BINARY_WITH_SYSTEM_EDITOR;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_IDENTIFIER;
	public static String COMPILER_HYPERLINK_DETECTOR_OPEN_IDENTIFIER_IN_INCLUDE;
	public static String COMPILER_HYPERLINK_FILE_NOT_EXISTS;

	/**
	 * Language breakpoints.
	 */
	public static String LANGUAGE_BREAKPOINT_MARKER_MESSAGE;
	public static String LANGUAGE_BREAKPOINT_TOGGLE_TYPE_MENU_TEXT;

	/**
	 * Compiler symbols
	 */
	public static String COMPILER_SYMBOLS_VIEW_FILTER_TOOLTIP;
	public static String COMPILER_SYMBOLS_VIEW_SOURCE_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_SOURCE_NONE;
	public static String COMPILER_SYMBOLS_VIEW_SOURCE_TOTAL_COUNT;
	public static String COMPILER_SYMBOLS_VIEW_SOURCE_FILTERED_COUNT;
	public static String COMPILER_SYMBOLS_VIEW_TYPE_COLUMN_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_BANK_COLUMN_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_NAME_COLUMN_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_HEX_VALUE_COLUMN_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_DECIMAL_VALUE_COLUMN_LABEL;
	public static String COMPILER_SYMBOLS_VIEW_STRING_VALUE_COLUMN_LABEL;

	/**
	 * Preferences: syntax highlighting.
	 */
	public static String PREFERENCES_SYNTAX_HIGHLIGHTING_GROUP_TITLE;

	public static String PREFERENCES_TEXT_ATTRIBUTE_COMMENT_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_STRING_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_NUMBER_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_DIRECTIVE;
	public static String PREFERENCES_TEXT_ATTRIBUTE_OPCODE_LEGAL_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_OPCODE_ILLEGAL_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_OPCODE_PSEUDO_NAME;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_EQUATE;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LABEL;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_ENUM_DEFINITION_SECTION;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_STRUCTURE_DEFINITION_SECTION;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_LOCAL_SECTION;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_MACRO_DEFINITION_SECTION;
	public static String PREFERENCES_TEXT_ATTRIBUTE_IDENTIFIER_PROCEDURE_DEFINITION_SECTION;

	public static String PREFERENCES_FOREGROUND_COLOR_LABEL;
	public static String PREFERENCES_BOLD_LABEL;
	public static String PREFERENCES_ITALIC_LABEL;

	/**
	 * Preferences: editor content assist and parsing.
	 */
	public static String PREFERENCES_EDITOR_GROUP_TITLE;

	public static String PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_LABEL;
	public static String PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_UPPER_CASE_TEXT;
	public static String PREFERENCES_CONTENT_ASSIST_PROCESSOR_DEFAULT_CASE_LOWER_CASE_TEXT;

	public static String PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_LABEL;
	public static String PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_FIRST_ERROR_OR_WARNING_TEXT;
	public static String PREFERENCES_COMPILE_COMMAND_POSITIONING_MODE_FIRST_ERROR_TEXT;

	/**
	 * Preferences: compiler and runner
	 */
	public static String PREFERENCES_DOWNLOAD_LINK;
	public static String PREFERENCES_DOWNLOAD_LINK_TOOL_TIP;

	/**
	 * Preferences: compiler.
	 */
	public static String PREFERENCES_COMPILER_TARGET_LABEL;

	public static String PREFERENCES_COMPILER_EXECUTABLE_PATH_LABEL;
	public static String PREFERENCES_COMPILER_HARDWARE_ACTIVE_LABEL;
	public static String PREFERENCES_COMPILER_DEFAULT_PARAMETERS_LABEL;
	public static String PREFERENCES_COMPILER_PARAMETERS_LABEL;
	public static String PREFERENCES_COMPILER_PARAMETERS_HELP;
	public static String PREFERENCES_COMPILER_PARAMETERS_VARIABLES;

	public static String PREFERENCES_COMPILER_OUTPUT_FOLDER_MODE_LABEL;
	public static String PREFERENCES_COMPILER_OUTPUT_FOLDER_MODE_SOURCE_FOLDER_TEXT;
	public static String PREFERENCES_COMPILER_OUTPUT_FOLDER_MODE_TEMP_FOLDER_TEXT;
	public static String PREFERENCES_COMPILER_OUTPUT_FOLDER_MODE_FIXED_FOLDER_TEXT;
	public static String PREFERENCES_COMPILER_OUTPUT_FOLDER_PATH_LABEL;
	public static String PREFERENCES_COMPILER_OUTPUT_FILE_EXTENSION_LABEL;

	public static String PREFERENCES_COMPILER_RUNNER_ID_LABEL;
	public static String PREFERENCES_COMPILER_RUNNER_EXECUTABLE_PATH_LABEL;
	public static String PREFERENCES_COMPILER_RUNNER_DEFAULT_COMMAND_LINE_LABEL;
	public static String PREFERENCES_COMPILER_RUNNER_COMMAND_LINE_LABEL;
	public static String PREFERENCES_COMPILER_RUNNER_COMMAND_LINE_HELP;
	public static String PREFERENCES_COMPILER_RUNNER_COMMAND_LINE_VARIABLES;
	public static String PREFERENCES_COMPILER_RUNNER_WAIT_FOR_COMPLETION_LABEL;

	/**
	 * Help table of contents
	 */
	public static String TOC_WUDSN_IDE_LABEL;

	public static String TOC_IDE_TOPIC_LABEL;

	public static String TOC_LANGUAGES_TOPIC_LABEL;

	public static String TOC_COMPILERS_TOPIC_LABEL;
	public static String TOC_COMPILER_GENERAL_TOPIC_LABEL;
	public static String TOC_COMPILER_NAME_LABEL;
	public static String TOC_COMPILER_HOME_PAGE_LABEL;
	public static String TOC_COMPILER_HELP_DOCUMENTS_LABEL;
	public static String TOC_COMPILER_DEFAULT_PATHS_LABEL;
	public static String TOC_COMPILER_DEFAULT_HARDWARE_LABEL;
	public static String TOC_COMPILER_SUPPORTED_TARGETS_LABEL;
	public static String TOC_COMPILER_DEFAULT_PARAMETERS_LABEL;
	public static String TOC_COMPILER_INSTRUCTIONS_TOPIC_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_DIRECTIVES_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_LEGAL_OPCODES_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_PSEUDO_OPCODES_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_ILLEGAL_OPCODES_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_W65816_OPCODES_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_TYPE_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_NAME_LABEL;
	public static String TOC_COMPILER_INSTRUCTION_DESCRIPTION_LABEL;
	public static String TOC_COMPILER_MANUAL_TOPIC_LABEL;

	public static String TOC_COMPILER_SYNTAX_YES;
	public static String TOC_COMPILER_SYNTAX_NO;
	public static String TOC_COMPILER_SYNTAX_BLOCK_DEFINITION_CHARACTERS;
	public static String TOC_COMPILER_SYNTAX_COMPLETION_PROPOSAL_AUTO_ACTIVATION_CHARACTERS;
	public static String TOC_COMPILER_SYNTAX_IDENTIFIER_PART_CHARACTERS;
	public static String TOC_COMPILER_SYNTAX_IDENTIFIER_SEPARATOR_CHARACTER;
	public static String TOC_COMPILER_SYNTAX_IDENTIFIER_START_CHARACTERS;
	public static String TOC_COMPILER_SYNTAX_IDENTIFIERS_CASE_SENSITIVE;
	public static String TOC_COMPILER_SYNTAX_INSTRUCTIONS_CASE_SENSITIVE;
	public static String TOC_COMPILER_SYNTAX_LABEL_DEFINITION_SUFFIX_CHARACTER;
	public static String TOC_COMPILER_SYNTAX_MACRO_USAGE_PREFIX_CHARACTER;
	public static String TOC_COMPILER_SYNTAX_MULTIPLE_LINES_COMMENT_DELIMITERS;
	public static String TOC_COMPILER_SYNTAX_SINGLE_LINE_COMMENT_DELIMITERS;
	public static String TOC_COMPILER_SYNTAX_SOURCE_INCLUDE_DEFAULT_EXTENSION;
	public static String TOC_COMPILER_SYNTAX_STRING_DELIMITERS;
	
	public static String TOC_HARDWARES_TOPIC_LABEL;
	public static String TOC_HARDWARE_NAME_LABEL;
	public static String TOC_HARDWARE_ID_LABEL;
	public static String TOC_HARDWARE_ICON_LABEL;
	public static String TOC_HARDWARE_DEFAULT_FILE_EXTENSION_LABEL;
	public static String TOC_HARDWARE_EMULATOR_LABEL;
	public static String TOC_HARDWARE_HOME_PAGE_LABEL;
	public static String TOC_HARDWARE_DEFAULT_PARAMETERS_LABEL;

	public static String TOC_TARGETS_TOPIC_LABEL;
	public static String TOC_TARGET_NAME_LABEL;
	public static String TOC_TARGET_LANGUAGE_LABEL;

	public static String TOC_TARGET_OPCODE_LABEL;

	/**
	 * Messages for the language plugin.
	 */
	public static String MESSAGE_E100;
	public static String MESSAGE_E101;
	public static String MESSAGE_E102;
	public static String MESSAGE_E103;
	public static String MESSAGE_E104;
	public static String MESSAGE_E105;
	public static String MESSAGE_E106;
	public static String MESSAGE_E107;
	public static String MESSAGE_E108;
	public static String MESSAGE_I109;
	public static String MESSAGE_I110;
	public static String MESSAGE_E111;
	public static String MESSAGE_E112;
	public static String MESSAGE_E113;
	public static String MESSAGE_E114;
	public static String MESSAGE_E115;
	public static String MESSAGE_E116;
	public static String MESSAGE_E117;
	public static String MESSAGE_I118;
	public static String MESSAGE_E119;
	public static String MESSAGE_W120;
	public static String MESSAGE_I121;
	public static String MESSAGE_E122;
	public static String MESSAGE_E123;
	public static String MESSAGE_E124;
	public static String MESSAGE_E125;
	public static String MESSAGE_E126;
	public static String MESSAGE_E127;
	public static String MESSAGE_E128;
	public static String MESSAGE_E129;
	public static String MESSAGE_E130;
	public static String MESSAGE_E131;
	public static String MESSAGE_E132;
	public static String MESSAGE_E133;
	public static String MESSAGE_E134;
	public static String MESSAGE_E135;
	public static String MESSAGE_E136;
	public static String MESSAGE_E137;
	public static String MESSAGE_E138;
	public static String MESSAGE_E139;
	public static String MESSAGE_E140;
	public static String MESSAGE_E141;
	public static String MESSAGE_E142;
	public static String MESSAGE_S143;
	/**
	 * Initializes the constants.
	 */
	static {
		NLS.initializeMessages(Texts.class.getName(), Texts.class);
	}
}
