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

package com.wudsn.ide.hex;

import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.viewers.AbstractTreeViewer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;

/**
 * Content outline page for the hex editor.
 * 
 * @author Peter Dell
 */
final class HexEditorContentOutlinePage extends ContentOutlinePage {

    private HexEditor editor;
    private Object input;

    HexEditorContentOutlinePage(HexEditor editor) {
	if (editor == null) {
	    throw new IllegalArgumentException("Parameter 'editor' must not be null.");
	}
	this.editor = editor;

    }

    @Override
    public void createControl(Composite parent) {
	super.createControl(parent);

	TreeViewer viewer = getTreeViewer();
	viewer.getControl().setFont(JFaceResources.getTextFont());
	viewer.setContentProvider(new HexEditorContentOutlineTreeContentProvider());
	viewer.setLabelProvider(new HexEditorContentOutlineLabelProvider());
	viewer.addSelectionChangedListener(this);
	viewer.setAutoExpandLevel(AbstractTreeViewer.ALL_LEVELS);

	updateTreeView();
    }

    @Override
    public void selectionChanged(SelectionChangedEvent event) {
	super.selectionChanged(event);

	ISelection selection = event.getSelection();
	editor.setSelection(selection);
    }

    void setInput(Object input) {
	if (input == null) {
	    throw new IllegalArgumentException("Parameter 'input' must not be null.");
	}
	this.input = input;
	updateTreeView();
    }

    private void updateTreeView() {
	TreeViewer viewer = getTreeViewer();
	if (viewer != null) {
	    viewer.setInput(input);
	}
    }

}
