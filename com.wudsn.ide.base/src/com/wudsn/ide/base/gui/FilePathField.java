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

package com.wudsn.ide.base.gui;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.IWorkspaceRoot;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.window.Window;
import org.eclipse.swt.SWT;
import org.eclipse.swt.events.DisposeEvent;
import org.eclipse.swt.events.DisposeListener;
import org.eclipse.swt.events.ModifyEvent;
import org.eclipse.swt.events.ModifyListener;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Text;
import org.eclipse.ui.dialogs.ElementTreeSelectionDialog;
import org.eclipse.ui.model.BaseWorkbenchContentProvider;
import org.eclipse.ui.model.WorkbenchLabelProvider;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.IPathUtility;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Text field with a build in file browser button.
 * 
 * @author Peter Dell
 * 
 */
public final class FilePathField extends Field {

    /**
     * Inner class to handle the file selection dialog.
     */
    private final class BrowseButtonSelectionAdapter extends SelectionAdapter {

	public BrowseButtonSelectionAdapter() {
	}

	@Override
	public void widgetSelected(SelectionEvent evt) {

	    IPath newValue = getResourcePath();
	    if (newValue != null) {
		newValue = IPathUtility.makeRelative(newValue, filePathPrefix);
		// Set field content and notify change listeners.
		filePathField.setText(newValue.toPortableString());
	    }
	}

	/**
	 * Helper to open the resource selection dialog.
	 * 
	 * @return The file name the user selected or <code>null</code> if not.
	 */
	private IPath getResourcePath() {

	    IWorkspaceRoot workspaceRoot = ResourcesPlugin.getWorkspace().getRoot();

	    ElementTreeSelectionDialog dialog = new ElementTreeSelectionDialog(browseButton.getShell(),
		    new WorkbenchLabelProvider(), new BaseWorkbenchContentProvider());

	    dialog.setTitle(TextUtility.format(Texts.FILE_PATH_FIELD_DIALOG_MESSAGE, label.getText()));
	    dialog.setInput(workspaceRoot);
	    IPath filePath = new Path(filePathField.getText());
	    filePath = IPathUtility.makeAbsolute(filePath, filePathPrefix, true);
	    IFile ifile = workspaceRoot.getFile(filePath);
	    // If file is not there, default to its parent (folder).
	    Object selection;
	    if (ifile != null && ifile.exists()) {
		selection = ifile;
	    } else {
		int size = filePath.segmentCount();
		List<IResource> resources = new ArrayList<IResource>(size);
		IResource resource = ifile;
		while (resource != null) {
		    resource = resource.getParent();
		    if (resource != null) {
			resources.add(resource);
		    }
		}
		selection = new TreePath(resources.toArray(new IResource[resources.size()]));
	    }
	    dialog.setInitialSelection(selection);

	    if (dialog.open() == Window.OK) {
		Object[] result = dialog.getResult();
		if (result != null && result.length > 0) {
		    ifile = (IFile) result[0];
		    return ifile.getFullPath();
		}

	    }
	    return null;
	}
    }

    /**
     * Constructor fields.
     */
    final int dialogMode;
    final Text filePathField;
    final ModifyListener filePathFieldModifyListener;

    /**
     * State fields.
     */
    private boolean enabled;
    private boolean editable;

    /**
     * Runtime fields.
     */
    Button browseButton;
    IPath filePathPrefix;

    /**
     * Creates a new file path field.
     * 
     * @param parent
     *            The parent composite, not <code>null</code>.
     * @param labelText
     *            The label text, not <code>null</code>.
     * @param dialogMode
     *            {@link SWT#OPEN} or e {@link SWT#SAVE}.
     */
    public FilePathField(Composite parent, String labelText, int dialogMode) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (dialogMode != SWT.OPEN && dialogMode != SWT.SAVE) {
	    throw new IllegalArgumentException(
		    "Parameter 'dialogMode' must be 'SWT.OPEN' or 'SWT.SAVE'. Specified value is " + dialogMode + ".");
	}
	this.dialogMode = dialogMode;

	label = new Label(parent, SWT.NONE);
	label.setText(labelText);

	filePathField = new Text(parent, SWT.SINGLE | SWT.BORDER);
	filePathField.setLayoutData(new GridData(GridData.FILL_HORIZONTAL));
	filePathFieldModifyListener = new ModifyListener() {

	    @Override
	    public void modifyText(ModifyEvent e) {
		FilePathField.this.notifyChangeListenner();

	    }
	};
	enabled = true;
	editable = true;

	browseButton = new Button(parent, SWT.PUSH);
	browseButton.setText(Texts.FILE_PATH_FIELD_BROWSE_BUTTON_LABEL);

	browseButton.addSelectionListener(new BrowseButtonSelectionAdapter());
	browseButton.addDisposeListener(new DisposeListener() {
	    @Override
	    public void widgetDisposed(DisposeEvent event) {
		browseButton = null;
	    }
	});

	filePathPrefix = new Path("");
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Control getControl() {
	return filePathField;
    }

    public void setLabelText(String labelText) {
	label.setText(labelText);

    }

    public void setVisible(boolean visible) {
	label.setVisible(visible);
	filePathField.setVisible(visible);
	browseButton.setVisible(visible);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEnabled(boolean enabled) {
	this.enabled = enabled;
	label.setEnabled(enabled);
	filePathField.setEnabled(enabled);
	filePathField.setEditable(enabled & editable);
	browseButton.setEnabled(enabled);
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setEditable(boolean editable) {
	this.editable = editable;
	filePathField.setEditable(enabled & editable);
    }

    /**
     * Sets the path prefix which will be stripped automatically if it is the
     * prefix of the user input.
     * 
     * @param filePathPrefix
     *            The path prefix, may be empty, not <code>null</code>.
     */
    public void setFilePathPrefix(IPath filePathPrefix) {
	if (filePathPrefix == null) {
	    throw new IllegalArgumentException("Parameter 'filePathPrefix' must not be null.");
	}
	this.filePathPrefix = filePathPrefix;
    }

    /**
     * Sets the value.
     * 
     * @param value
     *            The value, not <code>null</code>.
     */
    public void setValue(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	filePathField.removeModifyListener(filePathFieldModifyListener);
	filePathField.setText(value);
	filePathField.addModifyListener(filePathFieldModifyListener);
    }

    /**
     * Gets the value.
     * 
     * @return The value, not <code>null</code>.
     */
    public String getValue() {
	String result = filePathField.getText();
	result = result.trim();
	return result;

    }
}