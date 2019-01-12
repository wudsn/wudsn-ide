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

package com.wudsn.ide.gfx.gui;

import javax.swing.event.ChangeListener;

import org.eclipse.core.runtime.IPath;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Label;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.gui.FilePathField;
import com.wudsn.ide.base.gui.IntegerField;
import com.wudsn.ide.base.gui.TextField;
import com.wudsn.ide.gfx.Texts;

public final class SourceFileView {

    private static final int[] EMPTY_DEFAULT_VALUES = new int[] { 0, 65535 };

    private final FilePathField filePathField;
    private final TextField fileSizeField;
    private final IntegerField fileOffsetField;
    private final Label dummyLabel;

    public SourceFileView(Composite parent, String labelText, int dialogMode) {
	if (parent == null) {
	    throw new IllegalArgumentException("Parameter 'parent' must not be null.");
	}
	if (dialogMode != SWT.OPEN && dialogMode != SWT.SAVE) {
	    throw new IllegalArgumentException(
		    "Parameter 'dialogMode' must be 'SWT.OPEN' or 'SWT.SAVE'. Specified value is " + dialogMode + "-");
	}

	filePathField = new FilePathField(parent, labelText, dialogMode);

	fileSizeField = new TextField(parent, Texts.FILE_SECTION_FIELD_SIZE_LABEL, SWT.READ_ONLY);

	fileOffsetField = new IntegerField(parent, Texts.FILE_SECTION_FIELD_OFFSET_LABEL, EMPTY_DEFAULT_VALUES, true,
		4, SWT.NONE);

	dummyLabel = new Label(parent, SWT.NONE);
    }

    public FilePathField getFilePathField() {
	return filePathField;
    }

    public IntegerField getFileOffsetField() {
	return fileOffsetField;
    }

    /**
     * Sets the path prefix which will be stripped automatically if it is the
     * prefix of the user input.
     * 
     * @param filePathPrefix
     *            The file path prefix, may be empty, not <code>null</code>.
     */
    public void setFilePathPrefix(IPath filePathPrefix) {
	if (filePathPrefix == null) {
	    throw new IllegalArgumentException("Parameter 'filePathPrefix' must not be null.");
	}
	filePathField.setFilePathPrefix(filePathPrefix);
    }

    public void setFilePath(String filePath) {
	filePathField.setValue(filePath);
    }

    public String getFilePath() {
	return filePathField.getValue();
    }

    public void setFileBytes(byte[] bytes) {
	if (bytes == null) {
	    fileSizeField.setValue(Texts.FILE_SECTION_FIELD_SIZE_NO_DATA);
	    fileOffsetField.setDefaultValues(EMPTY_DEFAULT_VALUES);
	} else {
	    fileSizeField.setValue(HexUtility.getLongValueHexString(bytes.length));

	    int step = (bytes.length + 15) / 16;
	    int[] defaultValues = new int[16];

	    for (int i = 0; i < 16; i++) {
		defaultValues[i] = i * step;
	    }

	    fileOffsetField.setDefaultValues(defaultValues);
	}
    }

    public void setFileOffset(int fileOffset) {
	fileOffsetField.setValue(fileOffset);
    }

    public int getFileOffset() {
	return fileOffsetField.getValue();
    }

    public void setVisible(boolean visible) {
	filePathField.setVisible(visible);
	fileSizeField.setVisible(visible);
	fileOffsetField.setVisible(visible);
	dummyLabel.setVisible(visible);
    }

    public void setEnabled(boolean enabled) {
	filePathField.setEnabled(enabled);
	fileSizeField.setEnabled(enabled);
	fileOffsetField.setEnabled(enabled);
	dummyLabel.setEnabled(enabled);
    }

    /**
     * Adds a change listener.
     * 
     * @param changeListener
     *            The change listener , not <code>null</code>.
     */
    public void addChangeListener(ChangeListener changeListener) {
	if (changeListener == null) {
	    throw new IllegalArgumentException("Parameter 'changeListener' must not be null.");
	}
	filePathField.addChangeListener(changeListener);
	fileOffsetField.addChangeListener(changeListener);

    }
}