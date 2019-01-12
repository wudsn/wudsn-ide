/**
* Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler.syntax;

import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObjectType;

/**
 * Instruction types as defined in the XML syntax definition. See also
 * {@link CompilerSourceParserTreeObjectType}.
 * 
 * @author Peter Dell
 * 
 */
public final class InstructionType {
    /**
     * Creation is private.
     */
    private InstructionType() {

    }

    // Types of directives.
    public static final int DIRECTIVE = 100;
    public static final int BEGIN_IMPLEMENTATION_SECTION_DIRECTIVE = 101;
    public static final int BEGIN_FOLDING_BLOCK_DIRECTIVE = 102;
    public static final int END_FOLDING_BLOCK_DIRECTIVE = 103;
    public static final int END_SECTION_DIRECTIVE = 104;

    public static final int BEGIN_ENUM_DEFINITION_SECTION_DIRECTIVE = 105;
    public static final int BEGIN_STRUCTURE_DEFINITION_SECTION_DIRECTIVE = 106;
    public static final int BEGIN_LOCAL_SECTION_DIRECTIVE = 107;
    public static final int BEGIN_MACRO_DEFINITION_SECTION_DIRECTIVE = 108;
    public static final int BEGIN_PROCEDURE_DEFINITION_SECTION_DIRECTIVE = 109;
    public static final int BEGIN_PAGES_SECTION_DIRECTIVE = 110;
    public static final int BEGIN_REPEAT_SECTION_DIRECTIVE = 111;

    public static final int SOURCE_INCLUDE_DIRECTIVE = 120;
    public static final int BINARY_INCLUDE_DIRECTIVE = 121;
    public static final int BINARY_OUTPUT_DIRECTIVE = 122;


    // Types of opcodes.
    public static final int LEGAL_OPCODE = 200;
    public static final int ILLEGAL_OPCODE = 201;
    public static final int PSEUDO_OPCODE = 202;
}