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

package com.wudsn.ide.asm.compiler.parser;

/**
 * Callback interface to react on the parsing of certain source file lines.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.0
 */
public abstract class CompilerSourceParserLineCallback {
    private String filePath;
    private int lineNumber;

    /**
     * Creation is protected.
     * 
     * @param filePath
     *            The absolute path of the source file, not empty and not
     *            <code>null</code>.
     * @param lineNumber
     *            The line number, a non-negative integer or <code>-1</code> to
     *            indicate that no line number is relevant.
     */
    protected CompilerSourceParserLineCallback(String filePath, int lineNumber) {
	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (lineNumber < 0) {
	    throw new IllegalArgumentException("Parameter 'lineNumber' must not be negative. Specified value is "
		    + lineNumber + ".");
	}
	this.filePath = filePath;
	this.lineNumber = lineNumber;
    }

    /**
     * Gets the path of the source file for which for which the callback shall
     * be triggered.
     * 
     * @return The absolute path of the source file, not empty and not
     *         <code>null</code>.
     */
    public final String getSourceFilePath() {
	return filePath;
    }

    /**
     * Gets the line number for which the callback shall be triggered.
     * 
     * @return The line number, a non-negative integer or <code>-1</code> to
     *         indicate that no line number is relevant.
     */
    public final int getLineNumber() {
	return lineNumber;
    }

    // Most of the parameters are currently not used by the consumer.
    public abstract void processLine(CompilerSourceParser compilerSourceParser, CompilerSourceFile compilerSourceFile,
	    int lineNumber, int startOffset, int symbolOffset, boolean instructionFound, int instructionOffset,
	    String instruction, int operandOffset, CompilerSourceParserTreeObject section);

}
