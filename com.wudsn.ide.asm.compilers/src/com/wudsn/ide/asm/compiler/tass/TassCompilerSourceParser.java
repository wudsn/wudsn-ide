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

package com.wudsn.ide.asm.compiler.tass;

import com.wudsn.ide.asm.compiler.parser.CompilerSourceParser;

/**
 * Source parser for {@link TassCompiler}.
 * 
 * @author Peter Dell
 */
final class TassCompilerSourceParser extends CompilerSourceParser {

    @Override
    protected void parseLine(int startOffset, String symbol, int symbolOffset, String instruction,
	    int instructionOffset, String operand, String comment) {

	if (symbol.length() > 0) {

	    // Check for origin statement
	    if (symbol.equals("*")) {
		beginImplementationSection(startOffset, startOffset + symbolOffset, operand, comment);

	    } else {
		if (instruction.equals("=")) {
		    createEquateDefinitionChild(startOffset, startOffset + symbolOffset, symbol, operand, comment);
		} else {
		    createLabelDefinitionChild(startOffset, startOffset + symbolOffset, symbol, comment);

		}
	    }

	} // Symbol not empty
    }
}
