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

import com.wudsn.ide.lng.Texts;

/**
 * Utility class for compiler syntax and instructions.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class CompilerSyntaxUtility {

	/**
	 * Creation private.
	 */
	private CompilerSyntaxUtility() {

	}

	/**
	 * Gets the image path for an instruction type image.
	 * 
	 * @param instruction The instruction, not <code>null</code>.
	 * @return The image path for the instruction type image, not empty and not
	 *         <code>null</code>.
	 */
	public static String getTypeImagePath(Instruction instruction) {
		if (instruction == null) {
			throw new IllegalArgumentException("Parameter 'instruction' must not be null.");
		}
		String path;

		if (instruction instanceof Directive) {
			path = "instruction-type-directive-16x16.gif";
		} else {
			Opcode opcode = (Opcode) instruction;
			switch (opcode.getType()) {
			case InstructionType.LEGAL_OPCODE:
				path = "instruction-type-legal-opcode-16x16.gif";
				break;
			case InstructionType.ILLEGAL_OPCODE:
				path = "instruction-type-illegal-opcode-16x16.gif";
				break;
			case InstructionType.PSEUDO_OPCODE:
				path = "instruction-type-pseudo-opcode-16x16.gif";
				break;
			default:
				throw new IllegalStateException("Unknown opcode type " + opcode.getType() + ".");
			}

		}
		return path;
	}

	/**
	 * Gets the text for an instruction type.
	 * 
	 * @param instruction The instruction, not <code>null</code>.
	 * @return The text for the instruction type image, may be empty, not
	 *         <code>null</code>.
	 */
	public static String getTypeText(Instruction instruction) {
		String text;

		if (instruction instanceof Directive) {
			text = Texts.COMPILER_SYNTAX_INSTRUCTION_DIRECTIVE;
		} else {
			Opcode opcode = (Opcode) instruction;
			switch (opcode.getType()) {
			case InstructionType.LEGAL_OPCODE:
				text = Texts.COMPILER_SYNTAX_LEGAL_OPCODE;
				break;
			case InstructionType.ILLEGAL_OPCODE:
				text = Texts.COMPILER_SYNTAX_ILLEGAL_OPCODE;
				break;
			case InstructionType.PSEUDO_OPCODE:
				text = Texts.COMPILER_SYNTAX_PSEUDO_OPCODE;
				break;
			default:
				throw new IllegalStateException("Unknown opcode type " + opcode.getType() + ".");
			}

		}
		return text;
	}
}
