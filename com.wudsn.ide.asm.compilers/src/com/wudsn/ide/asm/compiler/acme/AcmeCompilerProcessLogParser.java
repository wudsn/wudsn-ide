/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler.acme;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.List;

import org.eclipse.core.resources.IMarker;

import com.wudsn.ide.asm.compiler.CompilerProcessLogParser;
import com.wudsn.ide.asm.compiler.CompilerSymbol;

/**
 * Process log parser for {@link AcmeCompiler}.
 * 
 * Sample error message:
 * 
 * <pre>
 * Error - File include/ACME-Reference-Source-Include.a, line 3 (Zone <untitled>): Value not yet defined.
 * Error - File C:\Users\D025328\Documents\Eclipse\workspace.jac\com.wudsn.ide.ref\ASM\C64\ACME\ACME-Error-Reference.a, line 9 (Zone <untitled>): Value not yet defined.
 * </pre>
 * 
 * @author Peter Dell
 */
final class AcmeCompilerProcessLogParser extends CompilerProcessLogParser {
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
		pattern = "Error - File ";
		severity = IMarker.SEVERITY_ERROR;
		index = line.indexOf(pattern);
		if (index < 0) {
		    pattern = "Warning - File ";
		    severity = IMarker.SEVERITY_WARNING;
		    index = line.indexOf(pattern);
		}
		if (index >= 0) {

		    index = index + pattern.length();
		    pattern = ", line ";
		    int i = line.indexOf(pattern);
		    if (i == -1) {
			continue;
		    }
		    filePath = line.substring(index, i);

		    i = i + pattern.length();
		    int j = i;
		    while (line.charAt(j) != ' ' && j < line.length()) {
			j++;
		    }

		    String lineNumberString = line.substring(i, j);

		    try {
			lineNumber = Integer.parseInt(lineNumberString);
		    } catch (NumberFormatException ex) {
			lineNumber = -1;
			severity = IMarker.SEVERITY_ERROR;
			message = ex.getMessage();
		    }

		    pattern = "): ";
		    line = line.substring(j);
		    j = line.indexOf(pattern);
		    if (j > -1) {
			j = j + pattern.length();
			message = line.substring(j);
		    } else {
			message = line;
		    }

		    markerAvailable = true;
		}

	    }
	}
    }

    @Override
    public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) {

    }

}