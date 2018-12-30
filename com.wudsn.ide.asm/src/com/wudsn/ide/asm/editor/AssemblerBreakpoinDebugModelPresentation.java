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

package com.wudsn.ide.asm.editor;

import org.eclipse.debug.core.model.IValue;
import org.eclipse.debug.ui.IDebugModelPresentation;
import org.eclipse.debug.ui.IValueDetailListener;
import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.swt.graphics.Image;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;

import com.wudsn.ide.asm.AssemblerPlugin;

/**
 * Implementation class for extension
 * "com.wudsn.ide.asm.editor.AssemblerBreakpoinDebugModelPresentation". This is
 * the binding logic which enables navigation from transient and persistent
 * break point markers to the corresponding editor.
 * 
 * @author Peter Dell
 */
public class AssemblerBreakpoinDebugModelPresentation implements IDebugModelPresentation {

    @Override
    public void dispose() {
    }

    @Override
    public boolean isLabelProperty(Object element, String property) {
	return false;
    }

    @Override
    public void addListener(ILabelProviderListener listener) {
    }

    @Override
    public void removeListener(ILabelProviderListener listener) {

    }

    @Override
    public IEditorInput getEditorInput(Object element) {
	AssemblerBreakpoint assemblerBreakpoint = (AssemblerBreakpoint) element;
	IEditorInput result = assemblerBreakpoint.getEditorInput();
	if (result == null) {
	    IWorkbenchWindow activeWindow = AssemblerPlugin.getInstance().getWorkbench().getActiveWorkbenchWindow();
	    if (activeWindow == null) {
		return null;
	    }
	    IWorkbenchPage activePage = activeWindow.getActivePage();
	    if (activePage == null) {
		return null;
	    }
	    IEditorPart part;
	    try {
		part = IDE.openEditor(activePage, assemblerBreakpoint.getMarker(), false);
	    } catch (PartInitException ex) {
		return null;
	    }
	    return part.getEditorInput();
	}
	return result;
    }

    @Override
    public String getEditorId(IEditorInput input, Object element) {
	AssemblerBreakpoint assemblerBreakpoint = (AssemblerBreakpoint) element;
	return assemblerBreakpoint.getEditorId();
    }

    @Override
    public void setAttribute(String attribute, Object value) {

    }

    @Override
    public Image getImage(Object element) {
	return null;
    }

    @Override
    public String getText(Object element) {
	return null;
    }

    @Override
    public void computeDetail(IValue value, IValueDetailListener listener) {

    }

}
