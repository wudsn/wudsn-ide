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

package com.wudsn.ide.base.editor.hex.parser;

import org.eclipse.jface.viewers.StyledString;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.editor.hex.HexEditorContentOutlineTreeObject;
import com.wudsn.ide.base.editor.hex.HexEditorParser;

public class AtariSDXParser extends HexEditorParser {

    public static final int NON_RELOC_HEADER = 0xfffa;
    public static final int RELOC_HEADER = 0xfffe;
    public static final int UPDATE_RELOC_HEADER = 0xfffd;
    public static final int UPDATE_SYMBOLS_HEADER = 0xfffb;
    public static final int DEFINE_SYMBOLS_HEADER = 0xfffc;

    @Override
    public boolean parse(StyledString contentBuilder) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}

	boolean error;
	int offset = 0;

	// Skip offset bytes in lookup array.
	skipByteTextIndex(offset);

	HexEditorContentOutlineTreeObject treeObject;
	int fileContentLength = getFileContentLength();

	error = (fileContentLength - offset) < 7;
	boolean first = true;
	boolean more = true;
	try {
	    while (more && !error) {
		if (!first) {
		    contentBuilder.append("\n");
		}
		first = false;
		if (offset == fileContentLength) {
		    more = false;
		} else {
		    int header = getFileContentWord(offset);
		    if (header == NON_RELOC_HEADER) {
			int startAddress = getFileContentWord(offset + 2);
			int endAddress = getFileContentWord(offset + 4);

			treeObject = printBlockHeader(contentBuilder,
				Texts.HEX_EDITOR_ATARI_SDX_NON_RELOC_BLOCK_HEADER, -1,
				Texts.HEX_EDITOR_ATARI_SDX_NON_RELOC_BLOCK_HEADER_PARAMETERS, offset, startAddress,
				endAddress);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 5, true, 0);

			int blockEnd = offset + endAddress - startAddress;

			offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, startAddress);

		    } else if (header == RELOC_HEADER) {
			int blockNumber = getFileContentByte(offset + 2);
			int blockId = getFileContentByte(offset + 3);
			int blockOffset = getFileContentWord(offset + 4);
			int blockLength = getFileContentWord(offset + 6);

			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_SDX_RELOC_BLOCK_HEADER,
				NumberUtility.getLongValueDecimalString(blockNumber),
				HexUtility.getByteValueHexString(blockId),
				HexUtility.getLongValueHexString(blockOffset, 4),
				HexUtility.getLongValueHexString(blockLength, 4));
			StyledString headerStyledString = new StyledString(headerText, offsetStyler);
			contentBuilder.append(headerStyledString).append("\n");
			treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 7, true, 0);

			int blockEnd = offset + blockLength - 1;

			// Print bytes only of the block is not marked as EMPTY
			if ((blockId & 0x80) != 0x80) {
			    offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, blockOffset);
			}
		    } else if (header == UPDATE_RELOC_HEADER) {
			int blockNumber = getFileContentByte(offset + 2);
			int blockLength = getFileContentWord(offset + 3);

			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_SDX_UPDATE_RELOC_BLOCK_HEADER,
				NumberUtility.getLongValueDecimalString(blockNumber),
				HexUtility.getLongValueHexString(blockLength, 4));
			StyledString headerStyledString = new StyledString(headerText, offsetStyler);
			contentBuilder.append(headerStyledString).append("\n");
			treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 4, true, 0);
			int blockEnd = getBlockEnd(offset);
			offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, 0);
		    } else if (header == UPDATE_SYMBOLS_HEADER) {
			String symbolName=getSymbolName(offset+2);
			int blockLength = getFileContentWord(offset + 10);

			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_SDX_UPDATE_SYMBOLS_BLOCK_HEADER,
				symbolName, HexUtility.getLongValueHexString(blockLength, 4));
			StyledString headerStyledString = new StyledString(headerText, offsetStyler);
			contentBuilder.append(headerStyledString).append("\n");
			treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 11, true, 0);
			int blockEnd = getBlockEnd(offset);
			offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, 0);
		    } else if (header == DEFINE_SYMBOLS_HEADER) {
			int blockNumber = getFileContentByte(offset + 2);
			int blockOffset = getFileContentWord(offset + 3);
			String  symbolName=getSymbolName(offset+5);

			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_SDX_DEFINE_SYMBOLS_BLOCK_HEADER,
				NumberUtility.getLongValueDecimalString(blockNumber),
				HexUtility.getLongValueHexString(blockOffset), symbolName);
			StyledString headerStyledString = new StyledString(headerText, offsetStyler);
			contentBuilder.append(headerStyledString).append("\n");
			treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 12, true, 0);
		    } else {
			error = true;
		    }
		}
	    }
	} catch (RuntimeException ex) {
	    contentBuilder.append(ex.toString());
	    error = true;
	}

	if (error) {
	    printBlockWithError(contentBuilder, Texts.HEX_EDITOR_ATARI_SDX_BLOCK_ERROR, fileContentLength, offset);
	}
	return error;
    }

    /**
     * Gets end offset for UPDATE_RELOC_HEADER and UPDATE_SYMBOLS_HEADER.
     * 
     * @param offset
     *            The start offset, a non-negative integer.
     * @return The end offset, a non-negative integer.
     */
    private int getBlockEnd(int offset) {
	int fileContentLength = getFileContentLength();
	int i = offset;
	int blockEnd = -1;
	while (blockEnd < 0 && i < fileContentLength) {
	    int location = getFileContentByte(i);
	    switch (location) {
	    case 0xfc:
		blockEnd = i;
		break;
	    case 0xfd:
		i += 3;
		break;
	    case 0xfe:
		i += 3;
		break;
	    default:
		i++;
		break;
	    }
	}
	return blockEnd;
    }
    
    private String getSymbolName(int offset) {
	StringBuffer buffer = new StringBuffer(8);
	for (int i = 0; i < 8; i++) {
	    buffer.append((char) getFileContentByte(offset + i));
	}
	return buffer.toString();
    }

}
