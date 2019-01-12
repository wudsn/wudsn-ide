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

package com.wudsn.ide.base.editor.hex.parser;

import org.eclipse.jface.viewers.StyledString;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.editor.hex.HexEditorContentOutlineTreeObject;
import com.wudsn.ide.base.editor.hex.HexEditorParser;

public abstract class AtariParser extends HexEditorParser {

    public final static int COM_HEADER = 0xffff;

    protected final boolean parseAtariCOMFile(StyledString contentBuilder, int offset, int fileContentLength) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}
	boolean error;
	int startAddress;
	int endAddress;

	int blockCount;
	int blockEnd;

	// Skip offset bytes in lookup array.
	skipByteTextIndex(offset);

	HexEditorContentOutlineTreeObject treeObject;

	error = (fileContentLength - offset) < 7;
	if (!error) {
	    startAddress = getFileContentWord(offset + 2);
	    endAddress = getFileContentWord(offset + 4);

	    blockCount = 1;
	    blockEnd = offset + endAddress - startAddress + 6;
	    treeObject = printBlockHeader(contentBuilder, Texts.HEX_EDITOR_ATARI_COM_BLOCK_HEADER, blockCount,
		    Texts.HEX_EDITOR_ATARI_COM_BLOCK_HEADER_PARAMETERS, offset, startAddress, endAddress);
	    offset = printBytes(treeObject, contentBuilder, offset, offset + 5, true, 0);

	    boolean blockMode;
	    blockMode = true;
	    error = blockEnd >= fileContentLength;
	    try {
		while (blockMode && !error) {
		    offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, startAddress);

		    int headerLength = -1;
		    // No more bytes left?
		    if (offset == fileContentLength ) {
			blockMode = false;
		    } else
		    // At least 5 bytes available? (4 header bytes and 1 data
		    // byte)
		    if (fileContentLength - offset < 5) {
			error = true;
		    } else {
			boolean comHeader;
			comHeader = getFileContentWord(offset) == COM_HEADER;
			if (comHeader) {
			    // At least 7 bytes available? (6 header bytes and 1
			    // data byte)
			    if (fileContentLength - offset < 7) {
				error = true;
			    } else {
				// Inner COM header found
				headerLength = 6;
				startAddress = getFileContentByte(offset + 2) + 256 * getFileContentByte(offset + 3);
				endAddress = getFileContentByte(offset + 4) + 256 * getFileContentByte(offset + 5);
			    }
			} else {
			    // No inner COM header found
			    headerLength = 4;
			    startAddress = getFileContentByte(offset + 0) + 256 * getFileContentByte(offset + 1);
			    endAddress = getFileContentByte(offset + 2) + 256 * getFileContentByte(offset + 3);
			}
			error = endAddress < startAddress;
		    }

		    if (blockMode) {
			contentBuilder.append("\n");
		    }

		    if (blockMode && !error) {
			blockCount++;
			blockEnd = offset + endAddress - startAddress + headerLength;
			if (blockEnd < fileContentLength) {

			    treeObject = printBlockHeader(contentBuilder, Texts.HEX_EDITOR_ATARI_COM_BLOCK_HEADER,
				    blockCount, Texts.HEX_EDITOR_ATARI_COM_BLOCK_HEADER_PARAMETERS, offset,
				    startAddress, endAddress);
			    offset = printBytes(treeObject, contentBuilder, offset, offset + headerLength - 1, true, 0);
			} else {
			    error = true;
			}
		    }
		}
	    } catch (RuntimeException ex) {
		contentBuilder.append(ex.toString());
		error = true;
	    }
	}
	if (error) {
	    printBlockWithError(contentBuilder, Texts.HEX_EDITOR_ATARI_COM_BLOCK_ERROR, fileContentLength, offset);
	}
	return error;
    }

}
