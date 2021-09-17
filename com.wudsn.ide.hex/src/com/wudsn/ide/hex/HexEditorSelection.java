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

package com.wudsn.ide.hex;

import org.eclipse.jface.viewers.ISelection;

/**
 * Container class for selections in the hex editor.
 * 
 * @author Peter Dell
 * 
 */
final class HexEditorSelection implements ISelection {

	private long startOffset;
	private long endOffset;
	private byte[] bytes;

	/**
	 * Creates a new selection.
	 * 
	 * @param startOffset The start offset in the original array, a non-negative
	 *                    number.
	 * @param endOffset   The end offset in the original array, a non-negative
	 *                    number greater or equal to the start offset.
	 * @param bytes       The content of the selection, may be empty, not
	 *                    <code>null</code>.
	 */
	public HexEditorSelection(long startOffset, long endOffset, byte[] bytes) {

		if (startOffset < 0) {
			throw new IllegalArgumentException(
					"Parameter 'startOffset' must not be negative, specified value is " + startOffset + ".");
		}
		if (endOffset < startOffset) {
			throw new IllegalArgumentException("Parameter 'endOffset' must not be smaller than startOffset "
					+ startOffset + ", specified value is " + endOffset + ".");
		}
		if (bytes == null) {
			throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
		}
		this.startOffset = startOffset;
		this.endOffset = endOffset;
		this.bytes = bytes;
	}

	@Override
	public boolean isEmpty() {
		return bytes.length == 0;
	}

	/**
	 * Gets the start offset of the selection in the original array.
	 * 
	 * @return The start offset in the original array, a non-negative number.
	 * 
	 */
	public long getStartOffset() {
		return startOffset;
	}

	/**
	 * Gets the end offset in the original array.
	 * 
	 * @return The end offset in the original array, a non-negative number greater
	 *         or equal to the start offset.
	 */
	public long getEndOffset() {
		return endOffset;
	}

	/**
	 * Gets the content of the selection.
	 * 
	 * @return The content of the selection, may be empty, not <code>null</code> .
	 */
	public byte[] getBytes() {
		return bytes;
	}

	@Override
	public String toString() {
		return "HexEditorSelection from " + startOffset + " to " + endOffset + ": " + bytes.length + " bytes";
	}

}
