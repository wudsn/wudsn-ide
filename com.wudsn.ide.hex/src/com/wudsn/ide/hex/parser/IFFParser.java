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

package com.wudsn.ide.hex.parser;

import org.eclipse.jface.viewers.StyledString;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.hex.HexEditorContentOutlineTreeObject;
import com.wudsn.ide.hex.HexEditorParser;
import com.wudsn.ide.hex.Texts;

public final class IFFParser extends HexEditorParser {

	@Override
	public final boolean parse(StyledString contentBuilder) {
		if (contentBuilder == null) {
			throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
		}
		boolean error;
		long offset = 0;
		long fileContentLength = fileContent.getLength();
		error = parse(contentBuilder, offset, fileContentLength, null);
		return error;
	}

	private boolean parse(StyledString contentBuilder, long offset, long fileContentLength,
			HexEditorContentOutlineTreeObject treeObject) {
		boolean error;

		error = (fileContentLength - offset) < 8;
		if (!error) {
			while ((fileContentLength - offset) >= 8 && !error) {
				long headerLength = 8;
				String chunkName = getChunkName(offset);
				long chunkLength = fileContent.getDoubleWordBigEndian(offset + 4);
				String headerText;
				String formTypeName = "";
				boolean hasInnerChunks = false;
				if (chunkName.equals("FORM")) {
					if (chunkLength >= 4) {
						formTypeName = getChunkName(offset + 8);
						headerText = TextUtility.format(Texts.HEX_EDITOR_IFF_FORM_CHUNK, chunkName, formTypeName,
								HexUtility.getLongValueHexString(chunkLength),
								NumberUtility.getLongValueDecimalString(chunkLength));
						headerLength += 4;
						chunkLength -= 4;
						// Ignore trailing parts in the file outside of the main
						// chunk
						fileContentLength = offset + chunkLength;
						hasInnerChunks = true;
					} else {
						error = true;
						headerText = null;
					}
				} else {
					headerText = TextUtility.format(Texts.HEX_EDITOR_IFF_CHUNK, chunkName,
							HexUtility.getLongValueHexString(chunkLength),
							NumberUtility.getLongValueDecimalString(chunkLength));
				}

				if (!error) {
					StyledString styledString = new StyledString(headerText, offsetStyler);
					treeObject = printBlockHeader(contentBuilder, styledString, offset);
					contentBuilder.append(styledString);
					contentBuilder.append("\n");
					offset = printBytes(treeObject, contentBuilder, offset, offset + headerLength - 1, false, 0);

					if (hasInnerChunks) {
						contentBuilder.append("\n");

						parse(contentBuilder, offset, fileContentLength, treeObject);
						offset += chunkLength;
					} else {
						offset = printBytes(treeObject, contentBuilder, offset, offset + chunkLength - 1, false, 0);
					}
					contentBuilder.append("\n");

					// Skip padding byte
					if ((offset & 0x1) == 1) {
						offset++;
					}

				}
			}

		}
		if (error) {
			printBlockWithError(contentBuilder, Texts.HEX_EDITOR_IFF_FILE_ERROR, fileContentLength, offset);
		}
		return error;
	}

	private String getChunkName(long offset) {
		char[] id = new char[4];
		id[0] = (char) fileContent.getByte(offset);
		id[1] = (char) fileContent.getByte(offset + 1);
		id[2] = (char) fileContent.getByte(offset + 2);
		id[3] = (char) fileContent.getByte(offset + 3);
		return String.copyValueOf(id);
	}

}
