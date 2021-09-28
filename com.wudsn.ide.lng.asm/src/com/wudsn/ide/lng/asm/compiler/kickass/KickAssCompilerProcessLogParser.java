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

package com.wudsn.ide.lng.asm.compiler.kickass;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.StringReader;
import java.util.List;

import org.eclipse.core.resources.IMarker;

import com.wudsn.ide.lng.compiler.CompilerProcessLogParser;
import com.wudsn.ide.lng.compiler.CompilerSymbol;

/**
 * Process log parser for {@link KickAssCompiler}.
 * 
 * Sample error message:
 * 
 * <pre>
 * Error: Unknown symbol 'unknownLabel'
 * at line 9, column 6 in C:\Users\D025328\Documents\Eclipse\workspace.jac\com.wudsn.ide.ref\ASM\C64\KICKASS\KICKASS-Error-Reference.asm
 * </pre>
 * 
 * @author Peter Dell
 */
final class KickAssCompilerProcessLogParser extends CompilerProcessLogParser {

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
				pattern = "Error: ";
				severity = IMarker.SEVERITY_ERROR;
				index = line.indexOf(pattern);
				if (index < 0) {
					pattern = "Warning: ";
					severity = IMarker.SEVERITY_WARNING;
					index = line.indexOf(pattern);
				}
				if (index == 0) {

					message = line.substring(index + pattern.length()).trim();
					try {
						line = bufferedReader.readLine();
					} catch (IOException ex) {
						throw new RuntimeException("Cannot read line", ex);
					}
					if (line != null) {
						index = line.indexOf(',');
						if (index > 8) {

							String lineNumberString = line.substring(8, index);

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
						index = line.indexOf(" in ");
						if (index > 0) {
							filePath = line.substring(index + 4);
						}
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