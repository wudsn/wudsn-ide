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

package com.wudsn.ide.lng.compiler.syntax;

import java.util.Set;

import com.wudsn.ide.lng.Target;

public final class Directive extends Instruction {

	Directive(Set<Target> cpus, int type, boolean caseSensitive, String name, String title, String proposal) {
		super(cpus, type, caseSensitive, name, title, proposal);

		switch (type) {
		case InstructionType.DIRECTIVE:
		case InstructionType.BEGIN_IMPLEMENTATION_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_FOLDING_BLOCK_DIRECTIVE:
		case InstructionType.END_FOLDING_BLOCK_DIRECTIVE:
		case InstructionType.END_SECTION_DIRECTIVE:

		case InstructionType.BEGIN_ENUM_DEFINITION_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_STRUCTURE_DEFINITION_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_LOCAL_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_MACRO_DEFINITION_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_PROCEDURE_DEFINITION_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_PAGES_SECTION_DIRECTIVE:
		case InstructionType.BEGIN_REPEAT_SECTION_DIRECTIVE:

		case InstructionType.SOURCE_INCLUDE_DIRECTIVE:
		case InstructionType.BINARY_INCLUDE_DIRECTIVE:
		case InstructionType.BINARY_OUTPUT_DIRECTIVE:
			break;

		default:
			throw new IllegalArgumentException("Unknown type " + type + " for directive '" + name + "'.");
		}
	}
}