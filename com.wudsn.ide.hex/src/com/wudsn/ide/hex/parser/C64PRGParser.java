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

import com.wudsn.ide.hex.Texts;
import com.wudsn.ide.hex.HexEditorContentOutlineTreeObject;
import com.wudsn.ide.hex.HexEditorParser;

public class C64PRGParser extends HexEditorParser {

	@Override
	public boolean parse(StyledString contentBuilder) {
		if (contentBuilder == null) {
			throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
		}
		boolean error;
		int startAddress;
		int endAddress;

		int length = fileContent.getLength();
		long offset = 0;

		error = (length < 2);
		if (!error) {
			startAddress = fileContent.getByte(offset + 0) + 256 * fileContent.getByte(offset + 1);
			endAddress = startAddress + length - 3;

			HexEditorContentOutlineTreeObject treeObject;
			treeObject = printBlockHeader(contentBuilder, Texts.HEX_EDITOR_C64_PRG_HEADER, -1,
					Texts.HEX_EDITOR_C64_PRG_HEADER_PARAMETERS, offset, startAddress, endAddress);
			offset = printBytes(treeObject, contentBuilder, offset, offset + 1, true, 0);

			error = endAddress > 0xffff;
			if (!error) {
				printBytes(treeObject, contentBuilder, offset, length - 1, true, startAddress);
			}
		}
		if (error) {
			printBlockWithError(contentBuilder, Texts.HEX_EDITOR_C64_PRG_ERROR, length, offset);
		}
		return error;
	}

}
