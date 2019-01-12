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

package com.wudsn.ide.asm.runner;

import java.io.File;

import com.wudsn.ide.asm.compiler.CompilerFiles;
import com.wudsn.ide.asm.editor.AssemblerBreakpoint;

/**
 * Base class for runner implementations.
 * 
 * @author Peter Dell
 */
public class Runner {

    private RunnerDefinition definition;

    /**
     * Creation is protected.
     */
    protected Runner() {

    }

    /**
     * Sets the definition of the Runner. Called by {@link RunnerRegistry} only.
     * 
     * @param definition
     *            The definition if the Runner, not <code>null</code>.
     */
    final void setDefinition(RunnerDefinition definition) {
	if (definition == null) {
	    throw new IllegalArgumentException("Parameter 'type' must not be null.");
	}
	this.definition = definition;
    }

    /**
     * Gets the definition of the Runner.
     * 
     * @return The definition of the Runner, not <code>null</code>.
     */
    public final RunnerDefinition getDefinition() {
	if (definition == null) {
	    throw new IllegalStateException("Field 'definition' must not be null.");
	}
	return definition;
    }


    /**
     * Creates the {@link File} object for the breakpoints file.
     * 
     * @param files
     *            The assembler editor file containing the path to the output
     *            folder and file, not <code>null</code>.
     * 
     * @return The file to created (if there are breakpoints) or deleted (if
     *         there are not), or <code>null</code> to indicate that the runner
     *         does no support breakpoints.
     * 
     * @since 1.6.1
     */
    public File createBreakpointsFile(CompilerFiles files) {
	if (files == null) {
	    throw new IllegalArgumentException("Parameter 'files' must not be null.");
	}
	return null;
    }

    /**
     * Creates the content for the breakpoints file.
     * 
     * @param breakpoints
     *            The array of defined (possibly disabled) breakpoints, may be
     *            empty, not <code>null</code>.
     * @param breakpointBuilder
     *            The sting builder for create the actual file content. @
     * 
     * @return The number of active breakpoints or <code>0</code> if no
     *         breakpoints are active.
     * @since 1.6.1
     */
    public int createBreakpointsFileContent(AssemblerBreakpoint[] breakpoints, StringBuilder breakpointBuilder) {
	if (breakpoints == null) {
	    throw new IllegalArgumentException("Parameter 'breakpoints' must not be null.");
	}
	if (breakpointBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'breakpointBuilder' must not be null.");
	}
	return 0;
    }
}
