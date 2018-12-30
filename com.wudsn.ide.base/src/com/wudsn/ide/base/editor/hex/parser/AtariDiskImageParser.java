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

public class AtariDiskImageParser extends AtariParser {

    @Override
    public boolean parse(StyledString contentBuilder) {

	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}

	boolean error = false;
	int length = getFileContentLength();
	int offset = 0;

	HexEditorContentOutlineTreeObject treeObject;
	treeObject = printBlockHeader(contentBuilder, Texts.HEX_EDITOR_ATARI_DISK_IMAGE_HEADER, -1, "", offset, offset,
		offset + 15);
	offset = printBytes(treeObject, contentBuilder, offset, offset + 15, true, 0);
	contentBuilder.append("\n");

	boolean blockMode;

	blockMode = true;

	int mainSectorSize = getFileContentByte(4) + 256 * getFileContentByte(5);
	int bootSectorSize = mainSectorSize;

	if (bootSectorSize == 256 && (length % 256) == 128 + 16) {
	    bootSectorSize = 128;
	}
	int startAddress = 0;
	int sectorCount;
	int sectorSize;

	sectorCount = 1;
	sectorSize = bootSectorSize;
	try {
	    while (blockMode && !error) {
		treeObject = printBlockHeader(contentBuilder, Texts.HEX_EDITOR_ATARI_SECTOR_HEADER, sectorCount,

		Texts.HEX_EDITOR_ATARI_SECTOR_HEADER_PARAMETERS, offset, startAddress, startAddress + sectorSize - 1);
		offset = printBytes(treeObject, contentBuilder, offset, offset + sectorSize - 1, true, startAddress);
		contentBuilder.append("\n");

		if (offset >= length) {
		    blockMode = false;
		} else if (length - offset < sectorSize) {
		    error = true;
		}
		sectorCount++;
		if (sectorCount > 3) {
		    sectorSize = mainSectorSize;
		}
	    }
	} catch (RuntimeException ex) {
	    contentBuilder.append(ex.toString());
	}
	if (error) {
	    printBlockWithError(contentBuilder, Texts.HEX_EDITOR_ATARI_SECTOR_ERROR, length, offset);
	}
	return error;
    }

}
