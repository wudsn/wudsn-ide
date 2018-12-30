/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler.xasm;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.List;

import org.eclipse.core.resources.IMarker;

import com.wudsn.ide.asm.compiler.CompilerProcessLogParser;
import com.wudsn.ide.asm.compiler.CompilerSymbol;

/**
 * Process log parser for {@link XasmCompiler}. Identical to
 * MadsCompilerProcessLogParser, except that it is based on the errorLog.
 * 
 * @author Peter Dell
 */
final class XasmCompilerProcessLogParser extends CompilerProcessLogParser {

    private BufferedReader bufferedReader;

    @Override
    protected void initialize() {
	bufferedReader = new BufferedReader(new StringReader(errorLog));
    }

    @Override
    protected void findNextMarker() {

	String line;
	line = "";

	while (line != null && !markerAvailable) {
	    try {
		line = bufferedReader.readLine();
	    } catch (IOException ex) {
		throw new RuntimeException("Cannot read line", ex);
	    }
	    if (line != null) {
		String pattern;
		int index;
		pattern = ") ERROR: ";
		severity = IMarker.SEVERITY_ERROR;
		index = line.indexOf(pattern);
		if (index < 2) {
		    pattern = ") WARNING: ";
		    severity = IMarker.SEVERITY_WARNING;
		    index = line.indexOf(pattern);
		}
		if (index > 2) {

		    int i = index - 2;
		    while (line.charAt(i) != '(' && i >= 0) {
			i--;
		    }

		    if (line.charAt(i) == '(') {
			String lineNumberString = line.substring(i + 1, index);

			try {
			    lineNumber = Integer.parseInt(lineNumberString);
			} catch (NumberFormatException ex) {
			    lineNumber = -1;
			    severity = IMarker.SEVERITY_ERROR;
			    message = ex.getMessage();
			}
		    } else {
			lineNumber = -1;
		    }
		    message = line.substring(index + pattern.length()).trim();
		    filePath = line.substring(0, i - 1);
		    markerAvailable = true;
		}

	    }
	}
    }

    @Override
    public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) {

    }

}