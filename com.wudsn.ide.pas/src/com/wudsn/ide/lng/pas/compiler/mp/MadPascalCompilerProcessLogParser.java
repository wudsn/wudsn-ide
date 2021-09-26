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

package com.wudsn.ide.lng.pas.compiler.mp;

import java.io.BufferedReader;
import java.io.StringReader;
import java.util.List;

import org.eclipse.core.runtime.CoreException;

import com.wudsn.ide.lng.compiler.CompilerProcessLogParser;
import com.wudsn.ide.lng.compiler.CompilerSymbol;

/**
 * Process log parser for {@link MadsCompiler}.
 * 
 * @author Peter Dell
 */
final class MadPascalCompilerProcessLogParser extends CompilerProcessLogParser {

	private BufferedReader bufferedReader;

	@Override
	protected void initialize() {
		bufferedReader = new BufferedReader(new StringReader(outputLog));
	}

	@Override
	protected void findNextMarker() {


	}

	@Override
	public void addCompilerSymbols(List<CompilerSymbol> compilerSymbols) throws CoreException {
		if (compilerSymbols == null) {
			throw new IllegalArgumentException("Parameter 'compilerSymbols' must not be null.");
		}

	}

}