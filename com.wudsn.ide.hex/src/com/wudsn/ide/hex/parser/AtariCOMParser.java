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

public final class AtariCOMParser extends AtariParser {

    @Override
    public boolean parse(StyledString contentBuilder) {
	if (contentBuilder == null) {
	    throw new IllegalArgumentException("Parameter 'contentBuilder' must not be null.");
	}
	int offset = 0;
	int fileContentLenght = fileContent.getLength();
	return parseAtariCOMFile(contentBuilder, offset, fileContentLenght);
    }

}