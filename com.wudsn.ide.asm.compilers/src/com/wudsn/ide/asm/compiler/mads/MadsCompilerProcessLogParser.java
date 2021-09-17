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

package com.wudsn.ide.asm.compiler.mads;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.List;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.CoreException;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.compiler.CompilerProcessLogParser;
import com.wudsn.ide.asm.compiler.CompilerSymbol;
import com.wudsn.ide.asm.compiler.CompilerSymbolType;
import com.wudsn.ide.base.common.FileUtility;

/**
 * Process log parser for {@link MadsCompiler}.
 * 
 * @author Peter Dell
 */
final class MadsCompilerProcessLogParser extends CompilerProcessLogParser {

	private BufferedReader bufferedReader;

	@Override
	protected void initialize() {
		bufferedReader = new BufferedReader(new StringReader(outputLog));
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

	/**
	 * <pre>
	 * From the MADS documentation
	 * 
	 * .LAB file format
	 * 
	 * As with XASM, the *.LAB file stores information about labels in the program. There are three columns:
	 * � The first column is the virtual bank number assigned to the label (if <>0).
	 * � The second column is the label value.
	 * � The third column is the label name.
	 * 
	 * Virtual bank numbers with values >= $FFF9 have special meanings:
	 * � $FFF9   label for parameter in procedure defined by .PROC
	 * � $FFFA   label for array defined by .ARRAY
	 * � $FFFB   label for structured data defined by the pseudo-command DTA STRUCT_LABEL
	 * � $FFFC   label for SpartaDOS X symbol defined by SMB
	 * � $FFFD   label for macro defined by .MACRO directive
	 * � $FFFE   label for structure defined by .STRUCT directive
	 * � $FFFF   label for procedure defined by .PROC directive
	 * 
	 * 
	 * Characters with special meanings in label names: 
	 * � label with two colons :: is defined in a macro
	 * � a dot ('.') separates the name of a scope (.MACRO, .PROC, .LOCAL, .STRUCT) from the field name in the scope
	 * 
	 * The numeric value after :: is the number of the macro call. This is an example file:
	 * 
	 * Mad-Assembler v1.4.2beta by TeBe/Madteam
	 * Label table:
	 * 00	0400	@STACK_ADDRESS
	 * 00	00FF	@STACK_POINTER
	 * 00	2000	MAIN
	 * 00	2019	LOOP
	 * 00	201C	LOOP::1
	 * 00	201C	LHEX
	 * 00	0080	LHEX.HLP
	 * 00	204C	LHEX.THEX
	 * 00	205C	HEX
	 * 00	205C	HEX.@GETPAR0.LOOP
	 * 00	2079	HEX.@GETPAR1.LOOP
	 * </pre>
	 */
	@Override
	// TODO Parser symbol type and add source tree object type for .DEFs
	public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) throws CoreException {
		if (compilerSymbols == null) {
			throw new IllegalArgumentException("Parameter 'compilerSymbols' must not be null.");
		}
		String labelsFilePath = files.outputFilePathWithoutExtension + ".lab";
		File labelsFile = new File(labelsFilePath);
		if (labelsFile.exists()) {

			String labelsFileContent = FileUtility.readString(labelsFile, FileUtility.MAX_SIZE_UNLIMITED);
			String[] lines = labelsFileContent.split("[\\r\\n]+");
			if (lines.length > 2 || lines[0].toLowerCase().startsWith("mads")
					|| lines[1].toLowerCase().startsWith("label table:")) {
				for (int i = 2; i < lines.length; i++) {
					String[] parts = lines[i].split("\\t");
					if (parts.length == 3) {
						int type = CompilerSymbolType.LABEL_DEFINITION;
						String bankString = parts[0];

						String name = parts[2];
						String valueString = parts[1];
						try {
							long bank = Long.parseLong(bankString, 16);
							int symbolBank;
							if (bank >= 0 && bank < 0xfff9) {
								symbolBank = (int) bank;
							} else {
								symbolBank = CompilerSymbol.UNDEFINED_BANK;
								if (bank == 0xfff9) {
									// Label for parameter in procedure defined
									// by .PROC
									// TODO: This would actually be a separate
									// type
									type = CompilerSymbolType.PROCEDURE_DEFINITION_SECTION;
								} else if (bank == 0xfffa) {
									// Label for array defined by .ARRAY
									// TODO: This would actually be a separate
									// type
									type = CompilerSymbolType.LABEL_DEFINITION;
								} else if (bank == 0xfffb) {
									// Label for structured data defined by the
									// pseudo-command DTA STRUCT_LABEL
									type = CompilerSymbolType.STRUCTURE_DEFINITION_SECTION;
								} else if (bank == 0xfffc) {
									// Label for SpartaDOS X symbol defined by
									// SMB
									// TODO: This would actually be a separate
									// type
									type = CompilerSymbolType.LABEL_DEFINITION;
								} else if (bank == 0xfffd) {
									// Label for macro defined by .MACRO
									// directive
									// TODO: This would actually be a separate
									// type
									type = CompilerSymbolType.MACRO_DEFINITION_SECTION;
								} else if (bank == 0xfffe) {
									// Label for structure defined by .STRUCT
									// directive
									type = CompilerSymbolType.STRUCTURE_DEFINITION_SECTION;
								} else if (bank == 0xffff) {
									// Label for procedure defined by .PROC
									// directive
									type = CompilerSymbolType.PROCEDURE_DEFINITION_SECTION;
								}
							}
							long value = Long.parseLong(valueString, 16);
							CompilerSymbol compilerSymbol = CompilerSymbol.createNumberSymbol(type, name, symbolBank,
									value);
							compilerSymbols.add(compilerSymbol);
						} catch (NumberFormatException ex) {
							AssemblerPlugin.getInstance().logError("Cannot parse value {1} of symbol {0}.",
									new Object[] { name, valueString }, ex);
						}

					}
				}
			}

		}
	}

}