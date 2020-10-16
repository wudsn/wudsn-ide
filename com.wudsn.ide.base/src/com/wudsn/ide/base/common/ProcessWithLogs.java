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

package com.wudsn.ide.base.common;

import java.io.File;
import java.io.IOException;
import java.io.PrintStream;

import org.eclipse.core.runtime.Platform;

import com.wudsn.ide.base.BasePlugin;

/**
 * The process with logs is the inter-process interface to the executables. The
 * {@link System#out} and the {@link System#err} streams are captured into
 * strings.
 * 
 * @author Peter Dell
 */
public final class ProcessWithLogs {

    private final String[] commandArray;
    private final File workingDirectory;
    private int exitValue;
    private String outputLog;
    private String errorLog;

    public static final String[] getExecutableExtensions() {

	String[] extensions;
	String os = Platform.getOS();
	if (os.equals(Platform.OS_WIN32)) {
	    // Default to ".exe" for Windows
	    extensions = new String[] { "*.exe", "*.jar", "*.*" };
	} else if (os.equals(Platform.OS_MACOSX)) {
	    // No restrictions for MacOS X since "*.app" is not always a good
	    // choice.
	    extensions = new String[0];
	} else {
	    // No restrictions for all other operating systems.
	    extensions = new String[0];
	}
	return extensions;
    }

    /**
     * Creates a new process.
     * 
     * @param commandArray
     *            The command array, not empty and not <code>null</code>.
     * @param workingDirectory
     *            The working directory, not <code>null</code>.
     */
    public ProcessWithLogs(String[] commandArray, File workingDirectory) {
	if (commandArray == null) {
	    throw new IllegalArgumentException("Parameter 'fullCommandArray' must not be null.");
	}
	if (commandArray.length == 0) {
	    throw new IllegalArgumentException("Parameter 'fullCommandArray.length' must not be empty.");
	}
	for (int i = 0; i < commandArray.length; i++) {
	    if (commandArray[i] == null) {
		throw new IllegalArgumentException("Parameter 'commandArray' must contain null at positition " + i
			+ ".");
	    }
	}

	if (workingDirectory == null) {
	    throw new IllegalArgumentException("Parameter 'workingDirectory' must not be null.");
	}

	this.commandArray = commandArray;
	this.workingDirectory = FileUtility.getCanonicalFile(workingDirectory);
	exitValue = 0;
	outputLog = "";
	errorLog = "";
    }

    /**
     * Executes the compiler.
     * 
     * @param out
     *            The print stream for the output output, see {@link System#out}
     *            .
     * @param err
     *            The print stream for the error output, see {@link System#err}.
     * @param wait
     *            <code>true</code> to wait for the process to terminate and
     *            collect the output.
     * 
     * @throws IOException
     *             The the creation of the process fails.
     */
    public void exec(PrintStream out, PrintStream err, boolean wait) throws IOException {

	if (out == null) {
	    throw new IllegalArgumentException("Parameter 'out' must not be null.");
	}
	if (err == null) {
	    throw new IllegalArgumentException("Parameter 'err' must not be null.");
	}
	Process process = null;
	exitValue = 0;
	outputLog = "";
	errorLog = "";
	Profiler profiler = new Profiler(this);
	profiler.begin("exec");
	try {
	    BasePlugin.getInstance().log("Executing process '{0}' in working directory '{1}'.",
		    new Object[] { getCommandArrayString(), workingDirectory.getPath() });

	    process = Runtime.getRuntime().exec(commandArray, null, workingDirectory);
	} catch (IOException ex) {
	    BasePlugin.getInstance().logError("Cannot execute process '{0}' in working directory '{1}'.",
		    new Object[] { getCommandArrayString(), workingDirectory.getPath() }, ex);
	    throw ex;
	} finally {
	    profiler.end("exec");
	}
	if (wait) {
	    String encoding = null;
	    StreamsProxy streamsProxy = new StreamsProxy(process, encoding, out, err);
	    try {
		profiler.begin("waitFor");
		process.waitFor();
	    } catch (InterruptedException ex) {
		BasePlugin.getInstance().logError("Process interrupted", null, ex);
		throw new IOException(ex.getMessage());
	    } finally {
		profiler.end("waitFor");
		process.destroy();
	    }

	    streamsProxy.close();
	    exitValue = process.exitValue();
	    outputLog = streamsProxy.getOutputStreamMonitor().getContents();
	    errorLog = streamsProxy.getErrorStreamMonitor().getContents();
	}

    }

    /**
     * Gets the command array to be as string.
     * 
     * @return The command array as string, may be empty, not <code>null</code>
     *         ..
     */
    public String getCommandArrayString() {
	StringBuilder result;
	result = new StringBuilder();
	for (int i = 0; i < commandArray.length; i++) {
	    result.append(commandArray[i]);
	    if (i < commandArray.length - 1) {
		result.append(" ");
	    }
	}
	return result.toString();
    }

    /**
     * Gets the working directory.
     * 
     * @return The working directory, not <code>null</code>.
     */
    public File getWorkingDirectory() {
	return workingDirectory;
    }

    /**
     * Gets the exit value of the process.
     * 
     * @return The exit value of the process.
     */
    public int getExitValue() {
	return exitValue;
    }

    /**
     * Gets the output log captured from {@link System#out}.
     * 
     * @return The output log, maybe empty, not <code>null</code>.
     */
    public String getOutputLog() {
	return outputLog;
    }

    /**
     * Gets the error log captured from {@link System#out}.
     * 
     * @return The output log, maybe empty, not <code>null</code>.
     */
    public String getErrorLog() {
	return errorLog;
    }

}
