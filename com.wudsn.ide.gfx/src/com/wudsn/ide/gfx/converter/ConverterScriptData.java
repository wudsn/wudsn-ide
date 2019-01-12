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

package com.wudsn.ide.gfx.converter;

import org.mozilla.javascript.Context;
import org.mozilla.javascript.Scriptable;

/**
 * Container for a compiled converter scripts and its context.
 * 
 * @author Peter Dell
 * @since 1.6.6
 */
public final class ConverterScriptData {
    private String compiledScript;
    private Context compiledContext;
    private Scriptable compiledScope;
    private int errorLineNumber;

    /**
     * Gets the compiled script for which the compiled context and scope are
     * cached.
     * 
     * @return The compiled script, maybe be empty, not <code>null</code>.
     */
    public String getCompiledScript() {
	return compiledScript;
    }

    /**
     * Sets the compiled script for which the compiled context and scope are
     * cached.
     * 
     * @param compiledScript
     *            The compiled script, may be empty, not <code>null</code>.
     */
    public void setCompiledScript(String compiledScript) {
	if (compiledScript == null) {
	    throw new IllegalArgumentException("Parameter 'compiledScript' must not be null.");
	}
	this.compiledScript = compiledScript;
    }

    /**
     * Gets the compiled context which was created for the compiled script.
     * 
     * @return The compiled context or <code>null</code>.
     */
    public Context getCompiledContext() {
	return compiledContext;
    }

    /**
     * Sets the compiled context which was created for the compiled script.
     * 
     * @param compiledContext
     *            The compiled context or <code>null</code>.
     */
    public void setCompiledContext(Context compiledContext) {
	this.compiledContext = compiledContext;

    }

    /**
     * Gets the compiled scope which was created for the compiled script.
     * 
     * @return The compiled context or <code>null</code>.
     */
    public Scriptable getCompiledScope() {
	return compiledScope;
    }

    /**
     * Sets the compiled scope which was created for the compiled script.
     * 
     * @param compiledScope
     *            The compiled scope or <code>null</code>.
     */
    public void setCompiledScope(Scriptable compiledScope) {
	this.compiledScope = compiledScope;
    }

    /**
     * Set the line number of the first error that occurred in the script.
     * 
     * @param errorLineNumber
     *            The line number of the first error that occurred in the
     *            script, a positive integer or <code>-1</code> if there is no
     *            error.
     */
    public void setErrorLineNumber(int errorLineNumber) {
	this.errorLineNumber = errorLineNumber;
    }

    /**
     * Gets the line number of the first error that occurred in the script.
     * 
     * @return The line number of the first error that occurred in the script,a
     *         positive integer or <code>-1</code> if there is no error.
     */
    public int geErrorLineNumber() {
	return errorLineNumber;
    }
}
