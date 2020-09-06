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

package com.wudsn.ide.hex.parser;

import org.eclipse.jface.viewers.StyledString;

import com.wudsn.ide.hex.Texts;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.hex.HexEditorContentOutlineTreeObject;
import com.wudsn.ide.hex.HexEditorParser;

/**
 * All parsing in here is based on the format description in the MADS online
 * documentation.
 * 
 * @author Peter Dell
 */
public class AtariMADSParser extends HexEditorParser {

    public static final int COM_HEADER = 0xffff;
    public static final int RELOC_HEADER = 0x524d;
    public static final int UPDATE_RELOC_HEADER = 0xffef;
    public static final int UPDATE_SYMBOLS_HEADER = 0xffee;
    public static final int DEFINE_SYMBOLS_HEADER = 0xffed;

    @Override
    public boolean parse(StyledString contentBuilder) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}

	boolean error;
	long offset = 0;

	// Skip offset bytes in lookup array.
	skipByteTextIndex(offset);

	HexEditorContentOutlineTreeObject treeObject;
	int fileContentLength = fileContent.getLength();

	error = (fileContentLength - offset) < 17;
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
		    int header = fileContent.getWord(offset);
		    if (header == COM_HEADER && fileContent.getWord(offset + 6) == RELOC_HEADER) {
			int startAddress = fileContent.getWord(offset + 2);
			int endAddress = fileContent.getWord(offset + 4);
			int config = fileContent.getByte(offset + 9);

			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_MADS_RELOC_BLOCK_HEADER,
				HexUtility.getLongValueHexString(startAddress, 4),
				HexUtility.getLongValueHexString(endAddress, 4),
				HexUtility.getByteValueHexString(config));

			treeObject = printHeader(contentBuilder, offset, headerText);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 15, true, 0);

			long blockEnd = offset + endAddress - startAddress;

			offset = printBytes(treeObject, contentBuilder, offset, blockEnd, true, startAddress);

		    } else if (header == UPDATE_RELOC_HEADER) {

			int type = fileContent.getByte(offset + 2);
			int dataLength = fileContent.getWord(offset + 3);

			treeObject = printTypedHeader(contentBuilder, offset,
				Texts.HEX_EDITOR_ATARI_MADS_UPDATE_RELOC_BLOCK_HEADER, type, dataLength);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 4, false, 0);

			// The exception is an update block for address high
			// bytes ">", where for such a block an extra BYTE is
			// stored for each address (low byte of address being
			// modified).
			int dataSize = (type == '>' ? 3 : 2);
			long blockEnd = offset + (dataLength * dataSize) - 1;

			offset = printBytes(treeObject, contentBuilder, offset, blockEnd, false, 0);

		    } else if (header == UPDATE_SYMBOLS_HEADER) {
			/**
			 * <pre>
			 * HEADER        WORD ($FFEE)
			 * TYPE          CHAR (B-YTE, W-ORD, L-ONG, D-WORD, <, >)
			 * DATA_LENGTH   WORD
			 * LABEL_LENGTH  WORD
			 * LABEL_NAME    ATASCII
			 * DATA          WORD .. .. .. (DATA_LENGTH words)
			 * </pre>
			 */
			int type = fileContent.getByte(offset + 2);
			int dataLength = fileContent.getWord(offset + 3);
			int labelLength = fileContent.getWord(offset + 5);

			treeObject = printTypedHeader(contentBuilder, offset,
				Texts.HEX_EDITOR_ATARI_MADS_UPDATE_SYMBOLS_BLOCK_HEADER, type, dataLength);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 6, false, 0);
			offset = printBytes(treeObject, contentBuilder, offset, offset + labelLength - 1, false, 0);
			offset = printBytes(treeObject, contentBuilder, offset, offset + dataLength * 2 - 1, false, 0);

		    } else if (header == DEFINE_SYMBOLS_HEADER) {

			int length = fileContent.getWord(offset + 2);
			String headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_MADS_DEFINE_SYMBOLS_BLOCK_HEADER,
				HexUtility.getLongValueHexString(length, 4));
			StyledString headerStyledString = new StyledString(headerText, offsetStyler);
			contentBuilder.append(headerStyledString).append("\n\n");
			treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);

			offset += 4;
			for (int i = 0; i < length; i++) {
			    int type = fileContent.getByte(offset);
			    int labelType = fileContent.getByte(offset + 1);
			    int labelLength = fileContent.getWord(offset + 2);
			    String labelName = getLabelName(offset + 4, labelLength);
			    int address = fileContent.getWord(offset + 4 + labelLength);
			    long headerEnd = offset + 6 + labelLength - 1;
			    switch (labelType) {
			    case 'P':
				int procType = fileContent.getByte(headerEnd + 1);
				int paramCount = fileContent.getWord(headerEnd + 2);
				headerEnd += 4;
				for (int j = 0; j < paramCount; j++) {
				    switch (procType) {
				    case 'D':
					break;
				    case 'R':
					headerEnd += 1;
					break;
				    case 'V':
					headerEnd += 1;
					int paramLenght = fileContent.getWord(headerEnd);
					headerEnd += 2 + paramLenght;
					break;
				    }
				}
				break;
			    case 'A':
				break;
			    case 'S':
				break;
			    }

			    headerText = TextUtility.format(Texts.HEX_EDITOR_ATARI_MADS_DEFINE_SYMBOL_HEADER,
				    String.valueOf((char) type), String.valueOf((char) labelType), labelName,
				    HexUtility.getLongValueHexString(address, 4));
			    headerStyledString = new StyledString(headerText, offsetStyler);
			    contentBuilder.append(headerStyledString).append("\n");
			    treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
			    offset = printBytes(treeObject, contentBuilder, offset, headerEnd, false, 0);

			}

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
	    printBlockWithError(contentBuilder, Texts.HEX_EDITOR_ATARI_MADS_BLOCK_ERROR, fileContentLength, offset);
	}
	return error;
    }

    private HexEditorContentOutlineTreeObject printHeader(StyledString contentBuilder, long offset, String headerText) {
	HexEditorContentOutlineTreeObject treeObject;
	StyledString headerStyledString = new StyledString(headerText, offsetStyler);
	contentBuilder.append(headerStyledString).append("\n");
	treeObject = printBlockHeader(contentBuilder, headerStyledString, offset);
	return treeObject;
    }

    private HexEditorContentOutlineTreeObject printTypedHeader(StyledString contentBuilder, long offset, String text,
	    int type, int dataLength) {
	HexEditorContentOutlineTreeObject treeObject;
	String headerText = TextUtility.format(text, String.valueOf((char) type),
		HexUtility.getLongValueHexString(dataLength, 4));
	treeObject = printHeader(contentBuilder, offset, headerText);
	return treeObject;
    }

    private String getLabelName(long offset, int length) {
	StringBuffer buffer = new StringBuffer(8);
	for (int i = 0; i < length; i++) {
	    buffer.append((char) fileContent.getByte(offset + i));
	}
	return buffer.toString();
    }

}
