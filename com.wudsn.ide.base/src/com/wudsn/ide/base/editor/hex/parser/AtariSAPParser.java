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
import com.wudsn.ide.base.editor.hex.HexEditorContentOutlineTreeObject;

public final class AtariSAPParser extends AtariParser {

    @Override
    public boolean parse(StyledString contentBuilder) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}
	int offset = 0;
	int fileContentLenght = getFileContentLength();
	int maxOffset = fileContentLenght - 2;
	while (offset < maxOffset && getFileContentByte(offset) != 0xff && getFileContentByte(offset) != 0xff) {
	    offset++;
	}
	if (offset == maxOffset) {
	    return false;
	}
	HexEditorContentOutlineTreeObject treeObject = printBlockHeader(contentBuilder,
		Texts.HEX_EDITOR_ATARI_SAP_FILE_HEADER, -1, "", 0, 0, 0);
	printBytes(treeObject, contentBuilder, 0, offset - 1, false, 0);
	contentBuilder.append("\n");

	return parseAtariCOMFile(contentBuilder, offset, fileContentLenght);
    }

}
