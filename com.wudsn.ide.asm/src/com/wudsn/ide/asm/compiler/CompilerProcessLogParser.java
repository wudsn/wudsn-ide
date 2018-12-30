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

package com.wudsn.ide.asm.compiler;

import java.io.File;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.Path;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Base class for compiler process log parsing.
 * 
 * @author Peter Dell
 */
public abstract class CompilerProcessLogParser {

    /**
     * Proxy class for creating instances of {@link IMarker}.
     * 
     * @since 1.6.1
     */
    public static final class Marker {
	private IFile iFile;
	private int lineNumber;
	private int severity;
	private String message;
	private Marker detailMarker;

	Marker(IFile iFile, int lineNumber, int severity, String message, Marker detailMarker) {
	    if (iFile == null) {
		throw new IllegalArgumentException("Parameter 'iFile' must not be null.");
	    }
	    if (message == null) {
		throw new IllegalArgumentException("Parameter 'message' must not be null.");
	    }
	    this.iFile = iFile;
	    this.lineNumber = lineNumber;
	    this.severity = severity;
	    this.message = message;
	    this.detailMarker = detailMarker;
	}

	/**
	 * Gets the iFile the marker refers to.
	 * 
	 * @return The iFile, not <code>null</code>.
	 */
	public IFile getIFile() {
	    return iFile;
	}

	/**
	 * Gets the line number.
	 * 
	 * @return The liner number or 0, if there is no known line number.
	 */
	public int getLineNumber() {
	    return lineNumber;
	}

	/**
	 * Gets the severity.
	 * 
	 * @return The severity, see {@link IMarker#SEVERITY}.
	 */
	public int getSeverity() {
	    return severity;
	}

	/**
	 * Gets the message.
	 * 
	 * @return The message, may be empty, not <code>null</code>.
	 */
	public String getMessage() {
	    return message;
	}

	/**
	 * Gets the detail marker, describing this marker in more detail.
	 * 
	 * @return The detail marker or <code>null</code>.
	 */
	public Marker getDetailMarker() {
	    return detailMarker;
	}

	@Override
	public String toString() {
	    return iFile.getFullPath() + ":" + lineNumber + ":" + severity + ":" + message;
	}

	@Override
	public boolean equals(Object o) {
	    if (o == null || !(o instanceof Marker)) {
		return false;
	    }
	    Marker other = (Marker) o;
	    return iFile.getFullPath().equals(other.iFile.getFullPath())
		    && lineNumber == other.lineNumber
		    && severity == other.severity
		    && message.equals(other.message)
		    && ((detailMarker == null && other.detailMarker == null) || detailMarker.equals(other.detailMarker));

	}

	@Override
	public int hashCode() {
	    return lineNumber;

	}
    }

    private boolean initialized;
    protected CompilerFiles files;
    protected String mainSourceFilePath;
    protected String outputLog;
    protected String errorLog;
    protected boolean markerAvailable;
    protected String filePath;
    protected int lineNumber;
    protected int severity;
    protected String message;

    protected CompilerProcessLogParser() {
    }

    public final void setLogs(CompilerFiles files, String outputLog, String errorLog) {
	if (files == null) {
	    throw new IllegalArgumentException("Parameter 'files' must not be null.");
	}
	if (outputLog == null) {
	    throw new IllegalArgumentException("Parameter 'outputLog' must not be null.");
	}
	if (errorLog == null) {
	    throw new IllegalArgumentException("Parameter 'errorLog' must not be null.");
	}
	this.files = files;
	this.mainSourceFilePath = files.mainSourceFile.filePath;
	this.outputLog = outputLog;
	this.errorLog = errorLog;
	initialize();
	initialized = true;
	markerAvailable = false;
	return;
    }

    protected void initialize() {
    }

    public final boolean nextMarker() {
	filePath = "";
	lineNumber = 0;
	severity = 0;
	message = "";
	markerAvailable = false;
	findNextMarker();
	return markerAvailable;
    }

    protected abstract void findNextMarker();

    /**
     * Adds the compiler symbols from the process output to the specified list.
     * 
     * @param list
     *            The modifiable list to which the compiler symbols shall be
     *            added, not <code>null</code>.
     * 
     * @throws CoreException
     *             if the symbols information is present, but cannot be read or
     *             parsed.
     */
    public void addCompilerSymbols(List<CompilerSymbol> list) throws CoreException {
    }

    /**
     * Creates a new marker proxy for a file.
     * 
     * @return The marker proxy, not <code>null</code>.
     * 
     * @since 1.6.1
     */
    public final Marker getMarker() {

	if (!initialized) {
	    throw new IllegalStateException("No log set.");
	}
	if (!markerAvailable) {
	    throw new IllegalStateException("No marker available.");
	}
	IFile mainSourceIFile = files.mainSourceFile.iFile;
	IFile iFile = mainSourceIFile;
	String normalizedFilePath = filePath.replace(File.separatorChar, '/');
	String normalizedMainSourceFilePath = mainSourceFilePath.replace(File.separatorChar, '/');
	Marker detailMarker = null;
	if (normalizedFilePath.length() > 0 && !normalizedFilePath.equals(normalizedMainSourceFilePath)) {
	    String folderPath = mainSourceIFile.getParent().getLocation().toOSString();
	    String normalizedFolderPath = folderPath.replace(File.separatorChar, '/');

	    String relativePath;

	    // Absolute include path, may even be a brother or parent path?
	    if (normalizedFilePath.startsWith(normalizedFolderPath)) {
		relativePath = normalizedFilePath.substring(folderPath.length() + 1);
	    } else {
		// Simple relative path.
		relativePath = normalizedFilePath;
	    }

	    // Create absolute iFile.
	    iFile = mainSourceIFile.getParent().getFile(new Path(relativePath));

	    // Check if it exists. This requires the file path to be in exactly
	    // the right case, even if the file system is case insensitive.
	    if (iFile == null || !iFile.exists()) {

		// If the file exists, but the include was specified with a
		// different case, an additional detail error message is issued.
		IFile caseInsenstiveIFile = null;
		if (iFile != null) {
		    try {
			IResource[] members = iFile.getParent().members();
			for (int i = 0; i < members.length && caseInsenstiveIFile == null; i++) {
			    if (members[i] instanceof IFile && members[i].getName().equalsIgnoreCase(iFile.getName())) {
				caseInsenstiveIFile = (IFile) members[i];
			    }
			}
		    } catch (CoreException ex) {
			AssemblerPlugin.getInstance().logError("Could not retrieve members of {0}",
				new Object[] { iFile }, ex);
		    }
		}

		// Use the case insensitive file if found and the main file
		// otherwise.
		if (iFile != null && caseInsenstiveIFile != null) {
		    // ERROR: Include statement for file '{0}' uses a file name
		    // that has a different case different from file system name
		    // {1}. Correct the file name in the include statement.
		    String caseMessage = TextUtility.format(Texts.MESSAGE_E142, iFile.getName(),
			    caseInsenstiveIFile.getName());
		    detailMarker = new Marker(mainSourceIFile, 0, IMarker.SEVERITY_ERROR, caseMessage, null);

		    iFile = caseInsenstiveIFile;
		} else {
		    iFile = mainSourceIFile;
		    // INFO: In include file '{0}', line {1}.
		    message += " "
			    + TextUtility.format(Texts.MESSAGE_S143, filePath,
				    NumberUtility.getLongValueDecimalString(lineNumber));
		    lineNumber = 0;
		}
	    }

	}

	return new Marker(iFile, lineNumber, severity, message.trim(), detailMarker);
    }
}
