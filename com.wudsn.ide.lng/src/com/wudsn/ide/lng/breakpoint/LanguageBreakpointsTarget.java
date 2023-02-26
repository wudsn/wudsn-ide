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
package com.wudsn.ide.lng.breakpoint;

import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.IBreakpointManager;
import org.eclipse.debug.core.model.IBreakpoint;
import org.eclipse.debug.core.model.ILineBreakpoint;
import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IWorkbenchPart;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.editor.ILanguageEditor;

/**
 * Target which creates {@link LanguageBreakpoint} instances. Used by
 * {@link LanguageBreakpointAdapterFactory}.
 */
public final class LanguageBreakpointsTarget implements IToggleBreakpointsTarget {
	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#
	 * toggleLineBreakpoints (org.eclipse.ui.IWorkbenchPart,
	 * org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public void toggleLineBreakpoints(IWorkbenchPart part, ISelection selection) throws CoreException {
		var languageEditor = getEditor(part);
		if (languageEditor != null) {
			IBreakpointManager breakPointManager = DebugPlugin.getDefault().getBreakpointManager();
			String editorId = languageEditor.getClass().getName();
			IEditorInput editorInput = languageEditor.getEditorInput();
			IResource resource = editorInput.getAdapter(IResource.class);
			ITextSelection textSelection = (ITextSelection) selection;
			int lineNumber = textSelection.getStartLine();
			IBreakpoint[] breakpoints = breakPointManager.getBreakpoints(LanguageBreakpoint.DEBUG_MODEL_ID);
			for (int i = 0; i < breakpoints.length; i++) {
				IBreakpoint breakpoint = breakpoints[i];
				if (resource.equals(breakpoint.getMarker().getResource())) {
					if (((ILineBreakpoint) breakpoint).getLineNumber() == (lineNumber + 1)) {
						// Remove existing breakpoint
						breakpoint.delete();
						return;
					}
				}
			}
			// Create line breakpoint (doc line numbers start at 0)
			String description;
			var document = languageEditor.getDocument();
			try {
				int startOffset = document.getLineOffset(lineNumber);
				int lineLength = document.getLineLength(lineNumber);
				description = document.get(startOffset, lineLength).trim();
				description = description.replace('\t', ' ');
			} catch (BadLocationException ex) {
				throw new RuntimeException(ex);
			}

			// No break points on empty lines
			if (StringUtility.isEmpty(description)) {
				return;
			}
			LanguageBreakpoint breakpoint = new LanguageBreakpoint(editorId, editorInput, resource, lineNumber + 1,
					description);
			breakPointManager.addBreakpoint(breakpoint);
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#
	 * canToggleLineBreakpoints(org.eclipse.ui.IWorkbenchPart,
	 * org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public boolean canToggleLineBreakpoints(IWorkbenchPart part, ISelection selection) {
		return getEditor(part) != null;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#
	 * toggleMethodBreakpoints (org.eclipse.ui.IWorkbenchPart,
	 * org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public void toggleMethodBreakpoints(IWorkbenchPart part, ISelection selection) throws CoreException {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#
	 * canToggleMethodBreakpoints(org.eclipse.ui.IWorkbenchPart,
	 * org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public boolean canToggleMethodBreakpoints(IWorkbenchPart part, ISelection selection) {
		return false;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#toggleWatchpoints
	 * (org.eclipse.ui.IWorkbenchPart, org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public void toggleWatchpoints(IWorkbenchPart part, ISelection selection) throws CoreException {
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see org.eclipse.debug.ui.actions.IToggleBreakpointsTarget#
	 * canToggleWatchpoints (org.eclipse.ui.IWorkbenchPart,
	 * org.eclipse.jface.viewers.ISelection)
	 */
	@Override
	public boolean canToggleWatchpoints(IWorkbenchPart part, ISelection selection) {
		return false;
	}

	/**
	 * Determines of the specified workbench part is an language editor with a
	 * valid resource.
	 * 
	 * @param part The editor part or <code>null</code>.
	 * @return The language editor or <code>null</code>.
	 */
	private ILanguageEditor getEditor(IWorkbenchPart part) {
		if (part instanceof ILanguageEditor) {
			var languageEditor = (ILanguageEditor) part;
			if (languageEditor.getCurrentFile() != null) {
				return languageEditor;
			}
		}
		return null;
	}
}
