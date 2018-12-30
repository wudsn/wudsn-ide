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

package com.wudsn.ide.asm.compiler;

public class CompilerFileWriter {
    /**
     * Creates or updates a disk image file with the output file.
     * 
     * @param files The compiler files, not <code>null</code>.
     * 
     * @return <code>true</code> if no disk image is required or it is required and has been updated.
     * 
     * @since 1.6.3
     */
    public boolean createOrUpdateDiskImage(CompilerFiles files) {
	if (files == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'outputFile' must not be null.");
	}
	return true;
    }
}
