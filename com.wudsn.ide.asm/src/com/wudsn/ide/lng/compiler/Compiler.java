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

package com.wudsn.ide.lng.compiler;

import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;

/**
 * Base class for compiler implementations. Sub classes have to be stateless.
 * 
 * @author Peter Dell
 */
public abstract class Compiler {

	// See {@link CompilerId} for predefined ids.
	private CompilerDefinition definition;

	/**
	 * Creation is protected.
	 */
	protected Compiler() {

	}

	/**
	 * Sets the definition of the compiler. Called by {@link CompilerRegistry} only.
	 * 
	 * @param definition The definition if the compiler, not <code>null</code>.
	 */
	final void setDefinition(CompilerDefinition definition) {
		if (definition == null) {
			throw new IllegalArgumentException("Parameter 'type' must not be null.");
		}
		this.definition = definition;
	}

	/**
	 * Gets the definition of the compiler.
	 * 
	 * @return The definition of the compiler, not <code>null</code>.
	 */
	public final CompilerDefinition getDefinition() {
		if (definition == null) {
			throw new IllegalStateException("Field 'definition' must not be null.");
		}
		return definition;
	}

	/**
	 * Creates a compiler source parser.
	 * 
	 * @return The compiler source parser, not <code>null</code>.
	 */
	public abstract CompilerSourceParser createSourceParser();

	/**
	 * Checks if the exit code of the compiler process represents success. By
	 * default <code>0</code> is interpreted as success, but a compiler may override
	 * this.
	 * 
	 * @param exitValue The exit code of the compiler process.
	 * @return <code>true</code> if the exit code represents success (only
	 *         information and warning messages) or a failure (at least one error
	 *         message).
	 * 
	 * @since 1.7.0
	 */
	public boolean isSuccessExitValue(int exitValue) {
		return exitValue == 0;
	}

	/**
	 * Creates the parser to for the compiler output.
	 * 
	 * @return The parser to for the compiler output, not <code>null</code>.
	 */
	public abstract CompilerProcessLogParser createLogParser();

}
