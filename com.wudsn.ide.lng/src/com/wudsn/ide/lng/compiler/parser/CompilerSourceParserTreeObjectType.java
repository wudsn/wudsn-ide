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
package com.wudsn.ide.lng.compiler.parser;

import com.wudsn.ide.lng.Texts;

/**
 * Constant values for tree object types.
 * 
 * @author Peter Dell
 */
public final class CompilerSourceParserTreeObjectType {

	/**
	 * Creation is private.
	 */
	private CompilerSourceParserTreeObjectType() {
	}

	/**
	 * Default-type
	 */
	public static final int DEFAULT = 0;

	public static final int DEFINITION_SECTION = 1;
	public static final int IMPLEMENTATION_SECTION = 2;

	public static final int EQUATE_DEFINITION = 3;
	public static final int LABEL_DEFINITION = 4;

	public static final int ENUM_DEFINITION_SECTION = 5;
	public static final int STRUCTURE_DEFINITION_SECTION = 6;
	public static final int LOCAL_SECTION = 7;
	public static final int MACRO_DEFINITION_SECTION = 8;
	public static final int PAGES_SECTION = 9;
	public static final int PROCEDURE_DEFINITION_SECTION = 10;
	public static final int REPEAT_SECTION = 11;

	public static final int SOURCE_INCLUDE = 12;
	public static final int BINARY_INCLUDE = 13;
	public static final int BINARY_OUTPUT = 14;

	/**
	 * Gets the localized text for a compiler source parser tree object type.
	 * 
	 * @param type The type, see constants of this class.
	 * @return The localized text, may be empty but not <code>null</code>.
	 */
	public static String getText(int type) {
		String result;
		switch (type) {
		case DEFAULT:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_DEFAULT;
			break;
		case DEFINITION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_DEFINITION_SECTION;
			break;
		case IMPLEMENTATION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_IMPLEMENTATION_SECTION;
			break;
		case EQUATE_DEFINITION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_EQUATE_DEFINITION;
			break;
		case LABEL_DEFINITION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_LABEL_DEFINITION;
			break;
		case ENUM_DEFINITION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_ENUM_DEFINITION_SECTION;
			break;
		case STRUCTURE_DEFINITION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_STRUCTURE_DEFINITION_SECTION;
			break;
		case LOCAL_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_LOCAL_SECTION;
			break;
		case MACRO_DEFINITION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_MACRO_DEFINITION_SECTION;
			break;
		case PAGES_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_PAGES_SECTION;
			break;
		case PROCEDURE_DEFINITION_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_PROCEDURE_DEFINITION_SECTION;
			break;
		case REPEAT_SECTION:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_REPEAT_SECTION;
			break;
		case SOURCE_INCLUDE:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_SOURCE_INCLUDE;
			break;
		case BINARY_INCLUDE:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_BINARY_INCLUDE;
			break;
		case BINARY_OUTPUT:
			result = Texts.COMPILER_SOURCE_PARSER_TREE_OBJECT_TYPE_BINARY_OUTPUT;
			break;
		default:
			throw new IllegalArgumentException("Unknown type " + type + ".");
		}
		return result;

	}

	/**
	 * Determines if instructions are allowed in the given type of section.
	 * 
	 * @param type The type of the tree object, {link
	 *             {@link CompilerSourceParserTreeObjectType}
	 * @return <code>true</code> if instructions are allowed, <code>false</code>
	 *         otherwise.
	 * 
	 * @since 1.6.0
	 */
	public static boolean areInstructionsAllowed(int type) {
		// Within ENUM_DEFINITION_SECTION everything is an equate.
		// Within STRUCTURE_DEFINITION_SECTION everything is a label.
		switch (type) {
		case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
		case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
			return false;
		default:
			return true;
		}
	}
}