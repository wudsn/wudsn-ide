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

package com.wudsn.ide.asm.compiler.dasm;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.CoreException;

import com.wudsn.ide.asm.compiler.CompilerProcessLogParser;
import com.wudsn.ide.asm.compiler.CompilerSymbol;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;

/**
 * Process log parser for {@link DasmCompiler}.
 * 
 * Sample error message:
 * 
 * <pre>
 * ------- FILE C:\Users\D025328\Documents\Eclipse\workspace.jac\com.wudsn.ide.ref\ASM\Atari2600\DASM\DASM-Error-Reference.asm LEVEL 1 PASS 1
 *       1  0000 ????
 * ------- FILE include/DASM-Reference-Source-Include.asm LEVEL 2 PASS 1
 *       0  0000 ????				      include	"include/DASM-Reference-Source-Include.asm"
 *       1  0000 ????						;	@com.wudsn.ide.asm.mainsourcefile=../DASM-Error-Reference.asm
 *       2  0000 ????
 *       3  0000 ????						;	Reference source include file for DASM
 *       4  0000 ????
 * include/DASM-Reference-Source-Include.asm (5): error: Unknown Mnemonic 'jmp'.
 *       5  0000 ????				      jmp	unknownTest
 * ------- FILE C:\Users\D025328\Documents\Eclipse\workspace.jac\com.wudsn.ide.ref\ASM\Atari2600\DASM\DASM-Error-Reference.asm
 *       3  0000 ????
 * C:\Users\D025328\Documents\Eclipse\workspace.jac\com.wudsn.ide.ref\ASM\Atari2600\DASM\DASM-Error-Reference.asm (4): error: Unknown Mnemonic 'jmp'.
 *       4  0000 ????				      jmp	nowhere
 *       5  0000 ????
 * </pre>
 * 
 * @author Peter Dell
 */
final class DasmCompilerProcessLogParser extends CompilerProcessLogParser {

    private Pattern pattern;

    private String listLog;
    private String listLogErrorMessage;
    private boolean fatalErrorFound;
    private boolean unresolvedSymbolsFound;

    @Override
    protected void initialize() {
	pattern = Pattern.compile(".* (.*): error:");

	File listFile = new File(files.outputFolder, files.mainSourceFile.fileNameWithoutExtension + ".lst");
	if (listFile.exists()) {
	    try {
		listLog = FileUtility.readString(listFile.getPath(), new FileInputStream(listFile),
			FileUtility.MAX_SIZE_UNLIMITED);
		listLogErrorMessage = null;
	    } catch (FileNotFoundException ex) {
		listLog = "";
		listLogErrorMessage = ex.getMessage();
	    } catch (CoreException ex) {
		listLog = "";
		listLogErrorMessage = ex.getStatus().getMessage();
	    }
	} else {
	    listLog = "";
	    listLogErrorMessage = "Expected list file '"
		    + listFile.getPath()
		    + "' does not exist. Check the compiler preferences and make sure you have set the option '-l${outputFilePathWithoutExtension}.lst'.";
	}
	fatalErrorFound = false;
	unresolvedSymbolsFound = false;
    }

    @Override
    protected void findNextMarker() {

	if (listLogErrorMessage != null) {
	    filePath = mainSourceFilePath;
	    lineNumber = 0;
	    severity = IMarker.SEVERITY_ERROR;
	    message = listLogErrorMessage;
	    markerAvailable = true;
	    listLogErrorMessage = null;
	    return;
	}

	int index;
	String line;
	Matcher matcher = pattern.matcher(listLog);

	if (matcher.find()) {
	    index = matcher.start();
	    line = listLog.substring(index);
	    listLog = listLog.substring(matcher.end());
	    int numberIndex = line.indexOf(" (");

	    if (numberIndex > 0) {

		filePath = line.substring(0, numberIndex);

		String lineNumberString;
		int numberEndIndex = line.indexOf(')');
		if (numberEndIndex > 0) {
		    lineNumberString = line.substring(numberIndex + 2, numberEndIndex);
		} else {
		    lineNumberString = "-1";
		}

		try {
		    lineNumber = Integer.parseInt(lineNumberString);

		    int nextIndex = line.indexOf("\n");
		    if (nextIndex > 0) {
			message = line.substring(numberEndIndex + 10, nextIndex - 1);
		    }
		} catch (NumberFormatException ex) {
		    lineNumber = -1;
		    message = ex.getMessage();
		}

		severity = IMarker.SEVERITY_ERROR;
		message = message.trim();
		markerAvailable = true;
		return;
	    }
	} else {
	    index = outputLog.indexOf("Fatal assembly error: ");
	    if (index > 0 && !fatalErrorFound) {
		int nextIndex = outputLog.indexOf("\n", index);
		if (nextIndex > 0) {
		    message = outputLog.substring(index, nextIndex - 1);
		} else {
		    message = outputLog.substring(index);
		}
		fatalErrorFound = true;

		severity = IMarker.SEVERITY_ERROR;
		message = message.trim();
		markerAvailable = true;
		return;
	    }

	    if (fatalErrorFound) {
		final String UNRESOLVED = "--- Unresolved Symbol List";
		index = outputLog.lastIndexOf(UNRESOLVED);
		if (index > 0) {
		    unresolvedSymbolsFound = true;
		    outputLog = outputLog.substring(index + UNRESOLVED.length()).trim();
		}
	    }
	    if (unresolvedSymbolsFound) {
		index = outputLog.indexOf('\n');
		if (index > 0) {
		    line = outputLog.substring(0, index - 1);
		    if (!line.startsWith("--")) {
			outputLog = outputLog.substring(index + 1);
			severity = IMarker.SEVERITY_ERROR;
			index = line.indexOf(" ");
			if (index > 0) {
			    line = line.substring(0, index);
			}
			message = "Unresolved symbol " + line + ".";
			markerAvailable = true;
			return;
		    }
		}
	    }
	}

	return;
    }

    /**
     * Type tokens in labels file:<br/>
     * 
     * ???? = unknown value<br/>
     * str = symbol is a string<br/>
     * eqm = symbol is an eqm macro<br/>
     * (r) = symbol has been referenced <br/>
     * (s) = symbol created with SET or EQM pseudo-op<br/>
     */
    @Override
    public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) {
	final String SYMBOLS = "--- Symbol List (sorted by symbol)";

	String log;
	int index;

	log = outputLog;
	index = log.indexOf(SYMBOLS);
	if (index >= 0) {
	    log = log.substring(index + SYMBOLS.length()).trim();

	    index = log.indexOf('\n');
	    while (index > 0) {
		String line = log.substring(0, index - 1);
		if (line.startsWith("--- End of Symbol List.")) {
		    break;
		}
		StringTokenizer st = new StringTokenizer(line);
		String name = st.nextToken();
		String hexValue = "";
		if (st.hasMoreTokens()) {
		    hexValue = st.nextToken();
		}

		String token = "";
		int valueType = CompilerSymbol.NUMBER;
		String stringValue = "";
		while (st.hasMoreTokens()) {
		    token = st.nextToken();
		    // "str" indicates that the symbol is a string value
		    if (token.equals("str")) {
			valueType = CompilerSymbol.STRING;
		    }

		    // String values are enclosed in double quotes.
		    if (valueType == CompilerSymbol.STRING && token.startsWith("\"") && token.length() >= 2
			    && token.endsWith("\"")) {
			stringValue = token.substring(1, token.length() - 1);
		    }
		}

		switch (valueType) {
		case CompilerSymbol.NUMBER:
		    // Ignore unnamed symbol with value "0000"
		    if (StringUtility.isSpecified(hexValue)) {
			compilerSymbols.add(CompilerSymbol.createNumberHexSymbol(name, hexValue));
		    }
		    break;
		case CompilerSymbol.STRING:
		    compilerSymbols.add(CompilerSymbol.createStringSymbol(name, stringValue));
		    break;
		default:
		    throw new IllegalStateException("Unsupported value type '" + valueType + "'.");
		}

		log = log.substring(index).trim();
		index = log.indexOf('\n');

	    }
	}

    }
}