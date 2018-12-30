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

public final class AtariDiskImageKFileParser extends AtariDiskImageParser {
    // The offset where the COM file starts in an Atari Disk Image (k-file).
    public static final int ATARI_DISK_IMAGE_K_FILE_COM_FILE_OFFSET = 16 + 3 * 128;

    @Override
    public boolean parse(StyledString contentBuilder) {

	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}

	boolean error = super.parse(contentBuilder);

	// If the disk image is a k-file image, the contained COM file is parsed
	// as well.
	if (!error) {
	    // The length of the k-file is stored in $709/$70a.
	    int length = ATARI_DISK_IMAGE_K_FILE_COM_FILE_OFFSET + getFileContentByte(0x19) + 256 * getFileContentByte(0x1a);
	    error = parseAtariCOMFile(contentBuilder, ATARI_DISK_IMAGE_K_FILE_COM_FILE_OFFSET, length);
	}
	return error;
    }

}
