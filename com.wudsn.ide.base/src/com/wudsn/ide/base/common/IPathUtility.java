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

package com.wudsn.ide.base.common;

import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;

public final class IPathUtility {

    /**
     * Creation is private.
     */
    private IPathUtility() {
    }

    public static IPath createEmptyPath() {
	return new Path("");
    }

    public static IPath makeRelative(IPath filePath, IPath filePathPrefix) {
	if (filePath == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'filePath' must not be null.");
	}
	if (filePathPrefix == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'filePathPrefix' must not be null.");
	}
	if (filePath.isAbsolute() && !filePathPrefix.isEmpty()) {
	    if (filePathPrefix.isPrefixOf(filePath)) {
		filePath = filePath.removeFirstSegments(filePathPrefix
			.segmentCount());
	    }
	}
	return filePath;
    }

    public static IPath makeAbsolute(IPath filePath, IPath filePathPrefix,
	    boolean forcePrefix) {
	if (filePath == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'filePath' must not be null.");
	}
	if (filePathPrefix == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'filePathPrefix' must not be null.");
	}
	
	// If the file path is empty, the prefix is omitted by default.
	// Only if forcePrefix is true, it is added.
	if (!filePath.isEmpty() || forcePrefix) {
	    if (!filePath.isAbsolute() && !filePathPrefix.isEmpty()) {
		if (!filePathPrefix.isPrefixOf(filePath)) {
		    filePath = filePathPrefix.append(filePath);
		}
	    }
	}
	return filePath;
    }
}
