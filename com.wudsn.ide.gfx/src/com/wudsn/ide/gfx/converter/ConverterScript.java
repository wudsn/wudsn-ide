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

package com.wudsn.ide.gfx.converter;

import java.io.InputStream;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.ContextFactory;
import org.mozilla.javascript.Function;
import org.mozilla.javascript.RhinoException;
import org.mozilla.javascript.Scriptable;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.gfx.GraphicsPlugin;

/**
 * Converter script utility class.
 * 
 * @author Peter Dell
 * 
 * @since 1.6.0
 */
public final class ConverterScript {

    public static void convertToFileData(Converter converter, ImageConverterData data) throws CoreException {

	// Collect the arguments into a single string.
	String script = data.getParameters().getScript();
	ConverterScriptData converterScriptData = data.getConverterScriptData();
	ContextFactory contextFactory = ContextFactory.getGlobal();
	Context context = null;
	Scriptable scope = null;

	try {
	    if (!script.equals(converterScriptData.getCompiledScript())) {

		if (converterScriptData.getCompiledContext() != null && Context.getCurrentContext() != null) {
		    Context.exit();
		}
		// Creates and enters a new Context. The Context stores
		// information
		// about the execution environment of a script.
		context = contextFactory.enterContext();
		scope = context.initStandardObjects();
		context.setOptimizationLevel(9);
		context.evaluateString(scope, script, "Line ", 1, null);
		// Initialize the standard objects (Object, Function, etc.)
		// This must be done before scripts can be executed. Returns
		// a scope object that we use in later calls.
		converterScriptData.setCompiledScript(script);
		converterScriptData.setCompiledContext(context);
		converterScriptData.setCompiledScope(scope);
	    } else {
		// Restore the previous context.
		context = converterScriptData.getCompiledContext();
		contextFactory.enterContext(context);
		scope = converterScriptData.getCompiledScope();
	    }

	    // Set global variables.
	    ConverterConsole converterConsole = GraphicsPlugin.getInstance().getConverterConsole();
	    scope.put("Console", scope, Context.toObject(converterConsole, scope));

	    // Call function
	    converterScriptData.setErrorLineNumber(-1);
	    String functionName = "convertToFileData";
	    Object functionObject = scope.get(functionName, scope);
	    if (functionObject == null) {
		throw new CoreException(new Status(IStatus.ERROR, GraphicsPlugin.ID, "'" + functionName
			+ "' is undefined."));
	    }
	    if (!(functionObject instanceof Function)) {
		throw new CoreException(new Status(IStatus.ERROR, GraphicsPlugin.ID, "'" + functionName
			+ "' is not a function."));
	    }

	    Object functionArgs[] = { Context.toObject(data, scope) };
	    Function function = (Function) functionObject;
	    function.call(context, scope, scope, functionArgs);

	} catch (RhinoException ex) {
	    converterScriptData.setErrorLineNumber(ex.lineNumber());
	    String message = getMessageString(ex.details());
	    String lineSource = getMessageString(ex.lineSource());
	    throw new CoreException(new Status(IStatus.ERROR, GraphicsPlugin.ID, "Error in script line "
		    + ex.lineNumber() + ": " + message + " " + lineSource, ex));

	} finally {

	    // Exit from the context. Remove the context association to the
	    // current thread.
	    if (Context.getCurrentContext() != null) {
		Context.exit();
	    }
	}
    }

    /**
     * Converts a string to message format (not <code>null</code>, no tabs).
     * 
     * @param string
     *            The string, or <code>null</code>.
     * @return The message string, may be empty, not <code>null</code>.
     */
    private static String getMessageString(String string) {
	String result;
	if (string != null) {
	    result = string.replace('\t', ' ');
	} else {
	    result = "";
	}
	return result;
    }

    /**
     * Gets the script associated with a compiler class.
     * 
     * @param converterClass
     *            The of the converter, not <code>null</code>.
     * @return The script for the converter, may be empty, not <code>null</code>
     *         .
     * @throws CoreException
     *             In case there is an error while reading an existing script.
     */
    public static String getScript(Class<? extends Converter> converterClass) throws CoreException {
	if (converterClass == null) {
	    throw new IllegalArgumentException("Parameter 'converterClass' must not be null.");
	}
	String result;

	String converterScriptFileName = "/" + converterClass.getName().replace('.', '/') + ".js";
	InputStream inputStream = converterClass.getResourceAsStream(converterScriptFileName);

	if (inputStream != null) {
	    result = FileUtility.readString(converterScriptFileName, inputStream, FileUtility.MAX_SIZE_UNLIMITED);
	} else {
	    result = "";
	}

	return result;
    }
}
