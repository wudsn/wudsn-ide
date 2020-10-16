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

package com.wudsn.ide.asm.compiler.test;

import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IMarker;

import com.wudsn.ide.asm.compiler.CompilerProcessLogParser;
import com.wudsn.ide.asm.compiler.CompilerSymbol;

/**
 * Process log parser for {@link TestCompiler}.
 * 
 * 
 * Sample error message:
 * 
 * "Pass 1: In Abbuc99-NetBalls-Init.asm, line 24-- Warning: Resizing
 * 'BALLSCOLORTAB1', forcing another pass"
 * 
 * "Pass 2: In Abbuc99-NetBalls-Init.asm, line 25-- Warning: Resizing
 * 'BALLSCOLORTAB2', forcing another pass"
 * 
 * @author Peter Dell
 */
final class TestCompilerProcessLogParser extends CompilerProcessLogParser {

    private Pattern pattern;
    private String sourceFilePattern;

    @Override
    protected void initialize() {
	pattern = Pattern.compile("In .* line ");
	sourceFilePattern = "In " + mainSourceFilePath + ", line ";
    }

    @Override
    protected void findNextMarker() {

	int index;
	String line;
	boolean include;
	String includeFile;
	Matcher matcher = pattern.matcher(errorLog);

	if (matcher.find()) {
	    index = matcher.start();
	    line = errorLog.substring(index);
	    if (line.startsWith(sourceFilePattern)) {
		include = false;
		includeFile = "";
	    } else {
		include = true;
		includeFile = line.substring(3, matcher.end() - matcher.start() - 7);
	    }
	    index = matcher.end();
	    String lineNumberLine = errorLog.substring(index);
	    errorLog = lineNumberLine;
	    int numberEndIndex = lineNumberLine.indexOf("--");
	    if (numberEndIndex > 0) {
		String lineNumberString;
		lineNumberString = lineNumberLine.substring(0, numberEndIndex);

		try {
		    lineNumber = Integer.parseInt(lineNumberString);
		    int nextIndex = lineNumberLine.indexOf('\n');
		    if (index > 0) {
			message = lineNumberLine.substring(nextIndex + 1);
			int nextIndex2 = message.indexOf('\n');
			if (nextIndex > 0) {
			    message = message.substring(0, nextIndex2 - 1);
			}
			message = message.trim();
		    }
		} catch (NumberFormatException ex) {
		    lineNumber = -1;
		    severity = IMarker.SEVERITY_ERROR;
		    message = ex.getMessage();
		}
	    }

	    if (message.startsWith("Error:")) {
		severity = IMarker.SEVERITY_ERROR;
		message = message.substring(6);
	    } else if (message.startsWith("Warning:")) {
		severity = IMarker.SEVERITY_WARNING;
		message = message.substring(8);
	    }

	    if (include) {
		if (lineNumber >= 0) {
		    message = includeFile + " line " + lineNumber + ": " + message;
		} else {
		    message = includeFile + ": " + message;
		}
		lineNumber = -1;
	    }
	    message = message.trim();

	    // Message mapping.
	    if (severity == IMarker.SEVERITY_WARNING && message.startsWith("Using bank")) {
		severity = IMarker.SEVERITY_INFO;
	    }
	    markerAvailable = true;
	}
    }

    @Override
    public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) {
	final String EQUATES = "Equates:";
	final String SYMBOL = "Symbol";
	final String TABLE = "table:";

	String log;
	int index;

	log = outputLog;
	index = log.indexOf(EQUATES);
	if (index >= 0) {
	    log = log.substring(index + EQUATES.length());

	    StringTokenizer st = new StringTokenizer(log);
	    String token;
	    String name;
	    String hexValue;
	    while (st.hasMoreTokens()) {
		token = st.nextToken();
		if (token.equals(SYMBOL)) {
		    break;
		}
		name = token.substring(0, token.length() - 1);
		hexValue = st.nextToken(); // Must be there
		compilerSymbols.add(CompilerSymbol.createNumberHexSymbol(name, hexValue));
	    }

	    if (st.hasMoreTokens()) {
		token = st.nextToken();
		if (token.equals(TABLE)) {
		    while (st.hasMoreTokens()) {
			token = st.nextToken();
			if (!token.endsWith(":")) {
			    break;
			}
			name = token.substring(0, token.length() - 1);
			hexValue = st.nextToken(); // Must be there
			compilerSymbols.add(CompilerSymbol.createNumberHexSymbol(name, hexValue));
		    }
		}
	    }
	}

    }

}