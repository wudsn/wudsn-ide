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

package com.wudsn.ide.asm.editor;

import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRunnable;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.debug.core.model.IBreakpoint;
import org.eclipse.debug.core.model.LineBreakpoint;
import org.eclipse.ui.IEditorInput;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Implementation class for assembler breakpoints. See
 * http://eclipse.org/articles/Article-Debugger/how-to.html for details.
 * 
 * @author Peter Dell
 * @since 1.6.1
 * 
 */

public final class AssemblerBreakpoint extends LineBreakpoint {

    /**
     * Attributes stored with the marker.
     */
    public static final String EDITOR_ID = "editorId";

    /**
     * Grouping ID for all breakpoint of this type.
     */
    public static final String DEBUG_MODEL_ID = AssemblerPlugin.ID;

    /**
     * Marker type as defined by the extension
     * "org.eclipse.core.resources.markers"
     */
    public static final String MARKER_TYPE = "org.eclipse.debug.core.lineBreakpointMarker";

    private IEditorInput editorInput;

    /**
     * Default constructor is required for the breakpoint manager to re-create
     * persisted breakpoints. After instantiating a breakpoint, the
     * <code>setMarker(...)</code> method is called to restore this breakpoint's
     * attributes.
     */
    public AssemblerBreakpoint() {
    }

    @Override
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public Object getAdapter(Class adapter) {
	if (adapter.isAssignableFrom(IMarker.class)) {
	    return getMarker();
	}
	if (adapter.isAssignableFrom(IResource.class)) {
	    // IResource result = getMarker().getResource();
	    // System.out.println(adapter.getName() + ":" + result);
	    // return result;
	}
	return super.getAdapter(adapter);
    }

    /**
     * Constructs a line breakpoint on the given resource at the given line
     * number. The line number is 1-based (i.e. the first line of a file is line
     * number 1).
     * 
     * @param editorId
     *            The editor id, not <code>null</code>.
     * 
     * @param editorInput
     *            The editor input, not <code>null</code>.
     * @param resource
     *            The file on which to set the breakpoint, not <code>null</code>
     *            .
     * @param lineNumber
     *            The line number of the breakpoint, a positive integer.
     * @param description
     *            The description of the break point, may be empty not
     *            <code>null</code>.
     * @throws CoreException
     *             if unable to create the breakpoint
     */
    public AssemblerBreakpoint(final String editorId, IEditorInput editorInput, final IResource resource,
	    final int lineNumber, final String description) throws CoreException {
	if (editorId == null) {
	    throw new IllegalArgumentException("Parameter 'editorId' must not be null.");
	}
	if (editorInput == null) {
	    throw new IllegalArgumentException("Parameter 'editorInput' must not be null.");
	}
	if (resource == null) {
	    throw new IllegalArgumentException("Parameter 'resource' must not be null.");
	}
	if (lineNumber < 1) {
	    throw new IllegalArgumentException("Parameter 'lineNumber' must be positive. Specified value is "
		    + lineNumber + ".");
	}
	if (description == null) {
	    throw new IllegalArgumentException("Parameter 'description' must not be null.");
	}
	this.editorInput = editorInput;
	IWorkspaceRunnable runnable = new IWorkspaceRunnable() {
	    @Override
	    public void run(IProgressMonitor monitor) throws CoreException {
		IMarker marker = resource.createMarker(MARKER_TYPE);
		// This must be the first operation before setting marker
		// attributes.
		setMarker(marker);

		marker.setAttribute(EDITOR_ID, editorId);
		marker.setAttribute(IBreakpoint.ENABLED, Boolean.TRUE);
		marker.setAttribute(IMarker.LINE_NUMBER, lineNumber);
		marker.setAttribute(IBreakpoint.ID, getModelIdentifier());
		marker.setAttribute(
			IMarker.MESSAGE,
			TextUtility.format(Texts.ASSEMBLER_BREAKPOINT_MARKER_MESSAGE, resource.getName(),
				NumberUtility.getLongValueDecimalString(lineNumber), description));

	    }
	};
	run(getMarkerRule(resource), runnable);
    }

    /*
     * (non-Javadoc)
     * 
     * @see org.eclipse.debug.core.model.IBreakpoint#getModelIdentifier()
     */
    @Override
    public String getModelIdentifier() {
	return DEBUG_MODEL_ID;
    }

    final String getEditorId() {
	return getMarker().getAttribute(EDITOR_ID, null);
    }

    final void setEditorInput(IEditorInput editorInput) {
	this.editorInput = editorInput;
    }

    final IEditorInput getEditorInput() {
	return editorInput;
    }

}
