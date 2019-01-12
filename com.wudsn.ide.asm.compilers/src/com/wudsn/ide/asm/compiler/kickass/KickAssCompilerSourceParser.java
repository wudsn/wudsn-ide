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

package com.wudsn.ide.asm.compiler.kickass;

import com.wudsn.ide.asm.compiler.parser.CompilerSourceParser;

/**
 * Source parser for {@link KickAssCompiler}.
 * 
 * @author Peter Dell
 */
final class KickAssCompilerSourceParser extends CompilerSourceParser {

    @Override
    protected void parseLine(int startOffset, String symbol, int symbolOffset, String instruction,
	    int instructionOffset, String operand, String comment) {

	int symbolLength = symbol.length();
	if (symbolLength > 0) {

	    if (symbol.charAt(symbolLength - 1) == ':') {
		symbol = symbol.substring(0, symbolLength - 1);
	    }
	    if (instruction.equals("=")) {
		createEquateDefinitionChild(startOffset, startOffset + symbolOffset, symbol, operand, comment);
	    } else {
		createLabelDefinitionChild(startOffset, startOffset + symbolOffset, symbol, comment);

	    }

	} // Symbol not empty

	// TODO Make .VAR an own type of instruction. Same code as in
	// MadsCompilerSourceParser!
	if (instruction.equals(".var")) {
	    operand = operand.trim();
	    int index = operand.indexOf('=');
	    String variable;
	    String value;
	    if (index < 0) {
		variable = operand;
		value = "";
	    } else {
		variable = operand.substring(0, index).trim();
		value = operand.substring(index).trim();
		if (value.startsWith("=")) {
		    value = value.substring(1).trim();
		}
	    }
	    if (value.length() > 0) {
		createEquateDefinitionChild(startOffset, startOffset + instructionOffset, variable, value, comment);
	    } else {
		createLabelDefinitionChild(startOffset, startOffset + instructionOffset, variable, comment);
	    }
	}
    }
}
