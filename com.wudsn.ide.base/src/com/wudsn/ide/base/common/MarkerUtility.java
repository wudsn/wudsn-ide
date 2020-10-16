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

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;

/**
 * Utility class for processing markers.
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class MarkerUtility {

    /**
     * Creation is private.
     */
    private MarkerUtility() {

    }

    /**
     * Creates a marker associated with an {@link IFile} resource.
     * 
     * @param file
     *            The {@link IFile} resource to which this message shall be
     *            attached, not <code>null</code>.
     * @param lineNumber
     *            An positive integer value indicating the line number for a
     *            text marker. 0 to indicate that the line number is unknown.
     * @param severity
     *            The message severity, see {@link IMarker#SEVERITY}
     * @param message
     *            The message, may contain parameter "{0}" to "{9}". May be
     *            empty, not <code>null</code>.
     * @param parameters
     *            The format parameters for the message, may be empty, not
     *            <code>null</code>.
     * 
     * @return The marker representing the message, not <code>null</code>.
     */
    public static IMarker createMarker(IFile file, int lineNumber, int severity, String message, String... parameters) {
	if (file == null) {
	    throw new IllegalArgumentException("Parameter 'file' must not be null.");
	}
	if (message == null) {
	    throw new IllegalArgumentException("Parameter 'message' must not be null.");
	}
	if (parameters == null) {
	    throw new IllegalArgumentException("Parameter 'parameters' must not be null.");
	}

	message = TextUtility.format(message, parameters);
	try {

	    IMarker marker = file.createMarker(IMarker.PROBLEM);
	    if (lineNumber > 0) {
		marker.setAttribute(IMarker.LINE_NUMBER, lineNumber);
	    }
	    marker.setAttribute(IMarker.SEVERITY, severity);
	    marker.setAttribute(IMarker.MESSAGE, message);
	    marker.setAttribute(IMarker.TRANSIENT, true);
	    return marker;
	} catch (CoreException ex) {
	    throw new RuntimeException(ex);
	}
    }

    /**
     * Navigates to the file and line number defined by the marker.
     * 
     * @param editor
     *            The editor part to start from, not <code>null</code>. If
     *            required an additional editor will be opened in the same
     *            workbench page.
     * 
     * @param marker
     *            The marker, not <code>null</code>. The resource of the marker
     *            must be an {@link IFile}.
     */
    public static void gotoMarker(IEditorPart editor, IMarker marker) {
	if (marker == null) {
	    throw new IllegalArgumentException("Parameter 'marker' must not be null.");
	}
	try {
	    IFile iFile = (IFile) marker.getResource();
	    IWorkbenchPage page = editor.getSite().getPage();
	    IEditorPart otherEditor = IDE.openEditor(page, iFile, true);
	    if (otherEditor != null) {
		otherEditor.setFocus();
		IDE.gotoMarker(otherEditor, marker);
	    }
	} catch (PartInitException ex) {
	    throw new RuntimeException(ex);
	}
    }
}
