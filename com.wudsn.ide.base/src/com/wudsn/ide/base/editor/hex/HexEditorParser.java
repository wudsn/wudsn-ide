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
import org.eclipse.jface.viewers.StyledString.Styler;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;

public abstract class HexEditorParser {

    private HexEditorParserComponent owner;
    protected Styler offsetStyler;
    protected Styler addressStyler;

    /**
     * Creation is protected.
     */
    protected HexEditorParser() {

    }

    /**
     * Initialized by owner.
     * 
     * @param owner
     *            The owner, not <code>null</code>.
     * @param offsetStyler
     *            The offset styler, not <code>null</code>.
     * @param addressStyler
     *            The address styler, not <code>null</code>.
     */
    void init(HexEditorParserComponent owner, Styler offsetStyler, Styler addressStyler) {
	if (owner == null) {
	    throw new IllegalArgumentException("Parameter 'owner' must not be null.");
	}
	if (offsetStyler == null) {
	    throw new IllegalArgumentException("Parameter 'offsetStyler' must not be null.");
	}
	if (addressStyler == null) {
	    throw new IllegalArgumentException("Parameter 'offsetStyler' must not be null.");
	}
	this.owner = owner;
	this.offsetStyler = offsetStyler;
	this.addressStyler = addressStyler;
    }

    /**
     * Public API for parsing.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @return <code>true</code> if parsing was OK, <code>false</code>otherwise.
     */
    public abstract boolean parse(StyledString contentBuilder);

    /**
     * Gets the length of the file content.
     * 
     * @return The length of the file content, a non-negative integer.
     */
    protected final int getFileContentLength() {
	return owner.getFileContent().length;
    }

    /**
     * Gets a byte from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The byte from the file content.
     */
    protected final int getFileContentByte(int offset) {
	return owner.getFileContentByte(offset);
    }

    /**
     * Gets a word from the file content.
     * 
     * @param offset
     *            The offset, a non-negative integer.
     * @return The word from the file content.
     */
    protected final int getFileContentWord(int offset) {
	return owner.getFileContentWord(offset);
    }

    /**
     * Prints a block header in the context area and adds a block to the
     * outline.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @param blockHeaderText
     *            The header text for the block, may be empty, not
     *            <code>null</code>.
     * @param blockHeaderNumber
     *            The block count or <code>-1</code> if count shall not be
     *            displayed.
     * @param blockHeaderParameterText
     *            The pattern text of the form "{0}-{1} ({2})"
     * @param offset
     *            The start offset, a non-negative integer.
     * @param startAddress
     *            The start address, a non-negative integer.
     * @param endAddress
     *            The end address, a non-negative integer.
     * 
     * @return The tree object representing the block.
     */
    protected final HexEditorContentOutlineTreeObject printBlockHeader(StyledString contentBuilder,
	    String blockHeaderText, int blockHeaderNumber, String blockHeaderParameterText, int offset,
	    int startAddress, int endAddress) {

	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}
	int blockLength = endAddress - startAddress + 1;
	String blockHeaderNumberText;
	if (blockHeaderNumber >= 0) {
	    blockHeaderNumberText = NumberUtility.getLongValueDecimalString(blockHeaderNumber);
	} else {
	    blockHeaderNumberText = "";
	}
	int length = Math.max(4, HexUtility.getLongValueHexLength(endAddress));
	String hexText = TextUtility.format(blockHeaderParameterText,
		HexUtility.getLongValueHexString(startAddress, length),
		HexUtility.getLongValueHexString(endAddress, length),
		HexUtility.getLongValueHexString(blockLength, length));

	String decimalText = TextUtility.format(blockHeaderParameterText,
		NumberUtility.getLongValueDecimalString(startAddress),
		NumberUtility.getLongValueDecimalString(endAddress),
		NumberUtility.getLongValueDecimalString(blockLength));

	StyledString styledString;
	styledString = new StyledString();
	styledString.append(blockHeaderText, offsetStyler);
	if (blockHeaderNumber >= 0) {
	    styledString.append(" ");
	    styledString.append(blockHeaderNumberText, offsetStyler);

	}
	if (StringUtility.isSpecified(blockHeaderParameterText)) {
	    styledString.append(" : ");
	    styledString.append(hexText, addressStyler);
	    styledString.append(" : ");
	    styledString.append(decimalText);
	}

	contentBuilder.append(blockHeaderText, offsetStyler);
	if (blockHeaderNumber >= 0) {
	    contentBuilder.append(" ");
	    contentBuilder.append(blockHeaderNumberText, offsetStyler);
	}
	contentBuilder.append("\n");
	return owner.printBlockHeader( contentBuilder, styledString,offset);
    }

    /**
     * Prints a block header in the context area and adds a block to the
     * outline.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @param headerStyledString
     *            The style string for the block header in the outline, not
     *            <code>null</code>.
     * @param offset
     *            The start offset, a non-negative integer.
     * 
     * @return The tree object representing the block.
     */
    protected final HexEditorContentOutlineTreeObject printBlockHeader(StyledString contentBuilder,
	    StyledString headerStyledString, int offset) {
	return owner.printBlockHeader(contentBuilder, headerStyledString, offset);
    }

    /**
     * Prints the last block in case if contains an error like the wrong number
     * of bytes.
     * 
     * @param contentBuilder
     *            The content builder, not <code>null</code>.
     * @param errorText
     *            The error text, not empty and not <code>null</code>.
     * @param length
     *            The length of the last block, a non-negative integer.
     * @param offset
     *            The offset of the last block, a non-negative integer.
     */
    protected final void printBlockWithError(StyledString contentBuilder, String errorText, int length, int offset) {
	owner.printBlockWithError(contentBuilder, errorText, length, offset);
    }

    protected final void skipByteTextIndex(int offset) {
	owner.skipByteTextIndex(offset);

    }

    protected final int printBytes(HexEditorContentOutlineTreeObject treeObject, StyledString contentBuilder,
	    int offset, int maxOffset, boolean withStartAddress, int startAddress) {
	return owner.printBytes(treeObject, contentBuilder, offset, maxOffset, withStartAddress, startAddress);

    }

}