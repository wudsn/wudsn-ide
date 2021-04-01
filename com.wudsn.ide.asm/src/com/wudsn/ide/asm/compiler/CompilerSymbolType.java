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
package com.wudsn.ide.asm.compiler;

import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObjectType;

/**
 * Constant values for symbol types. Symbol types are a subset of the source
 * tree object types.
 * 
 * @author Peter Dell
 */
public final class CompilerSymbolType {

    /**
     * Creation is private.
     */
    private CompilerSymbolType() {
    }

    /**
     * Default-type
     */
    public static final int DEFAULT = CompilerSourceParserTreeObjectType.DEFAULT;

    public static final int EQUATE_DEFINITION = CompilerSourceParserTreeObjectType.EQUATE_DEFINITION;
    public static final int LABEL_DEFINITION = CompilerSourceParserTreeObjectType.LABEL_DEFINITION;

    public static final int ENUM_DEFINITION_SECTION = CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION;
    public static final int STRUCTURE_DEFINITION_SECTION = CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION;
    public static final int MACRO_DEFINITION_SECTION = CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION;
    public static final int LOCAL_SECTION = CompilerSourceParserTreeObjectType.LOCAL_SECTION;
    public static final int PROCEDURE_DEFINITION_SECTION = CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION;

    /**
     * Gets the localized text for a compiler symbol type.
     * 
     * @param type
     *            The type, see constants of this class.
     * @return The localized text, may be empty but not <code>null</code>.
     */
    public static String getText(int type) {
	String result;
	switch (type) {
	case DEFAULT:
	case EQUATE_DEFINITION:
	case LABEL_DEFINITION:
	case ENUM_DEFINITION_SECTION:
	case STRUCTURE_DEFINITION_SECTION:
	case MACRO_DEFINITION_SECTION:
	case LOCAL_SECTION:
	case PROCEDURE_DEFINITION_SECTION:
	    result = CompilerSourceParserTreeObjectType.getText(type);
	    break;
	default:
	    throw new IllegalArgumentException("Unknown type " + type + ".");
	}
	return result;

    }
}