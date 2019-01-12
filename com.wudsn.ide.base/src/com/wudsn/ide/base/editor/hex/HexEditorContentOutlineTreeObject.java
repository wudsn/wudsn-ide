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

package com.wudsn.ide.base.editor.hex;

import org.eclipse.jface.viewers.StyledString;

/**
 * The object representing a node in the hex editor content outline tree.
 * 
 * @author Peter Dell
 */
public final class HexEditorContentOutlineTreeObject {

    private final StyledString styledString;
    private int fileStartOffset;
    private int textStartOffset;
    private int fileEndOffset;
    private int textEndOffset;

    /**
     * Create a new instance.
     * 
     * @param styledString
     *            The styled string of the instance, may be empty not
     *            <code>null</code>.
     */
    public HexEditorContentOutlineTreeObject(StyledString styledString) {
	if (styledString == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'styledString' must not be null.");
	}
	this.styledString = new StyledString().append(styledString);
    }

    /**
     * Gets the styled string of the object.
     * 
     * @return The styled string, not <code>null</code>.
     */
    public StyledString getStyledString() {
	return styledString;
    }

    /**
     * Gets the start offset of the tree object in the file.
     * 
     * @return The start offset, a non-negative integer.
     */
    public int getFileStartOffset() {
	return fileStartOffset;
    }

    /**
     * Sets the start offset of the tree object in the file.
     * 
     * @param fileOffset
     *            The start offset, a non-negative integer or <code>-1</code> if the offset is not defined.
     */
    public void setFileStartOffset(int fileOffset) {

	this.fileStartOffset = fileOffset;
    }

    /**
     * Gets the end offset of the tree object in the file.
     * 
     * @return The end offset, a non-negative integer or <code>-1</code> if the offset is not defined.
     */
    public int getFileEndOffset() {
	return fileEndOffset;
    }

    /**
     * Sets the end offset of the tree object in the file or <code>-1</code> if the offset is not defined.
     * 
     * @param fileOffset
     *            The end offset, a non-negative integer  or <code>-1</code> if the offset is not defined.
     */
    public void setFileEndOffset(int fileOffset) {

	this.fileEndOffset = fileOffset;
    }

    /**
     * Gets the start offset of the tree object in the text.
     * 
     * @return The offset, a non-negative integer.
     */
    public int getTextStartOffset() {
	return textStartOffset;
    }

    /**
     * Sets text start offset of the tree object in the text
     * 
     * @param textOffset
     *            The offset, a non-negative integer.
     */
    public void setTextStartOffset(int textOffset) {
	if (textOffset < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'textOffset' must not be negative. Specified value is "
			    + textOffset + ".");
	}
	this.textStartOffset = textOffset;
    }

    /**
     * Gets the end offset of the tree object in the text.
     * 
     * @return The offset, a non-negative integer.
     */
    public int getTextEndOffset() {
	return textEndOffset;
    }

    /**
     * Sets text end offset of the tree object in the text
     * 
     * @param textOffset
     *            The offset, a non-negative integer.
     */
    public void setTextEndOffset(int textOffset) {
	if (textOffset < 0) {
	    throw new IllegalArgumentException(
		    "Parameter 'textOffset' must not be negative. Specified value is "
			    + textOffset + ".");
	}
	this.textEndOffset = textOffset;
    }
}
