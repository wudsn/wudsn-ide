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

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;

public final class ClassPathUtility {

    /**
     * Find the URI of the ".jar" file containing the resource files.
     * 
     * @return The URI of the ".jar" file containing the resource files or
     *         <code>null</code>.
     */
    public static URI getJarURI() {
	// Try to load simple menu from folder where the .jar file is located
	ClassLoader classLoader = ClassPathUtility.class.getClassLoader();
	String jarPath = ClassPathUtility.class.getName().replace('.', '/') + ".class";
	URL url = classLoader.getResource(jarPath);
	if (url == null) {
	    url = ClassLoader.getSystemResource(jarPath);
	}
	if (url == null) {
	    return null;
	}
	try {
	    URI uri = url.toURI();

	    // Convert "jar:file:/..." to file URI.
	    if (uri.getScheme().equals("jar")) {
		String uriString = uri.getRawSchemeSpecificPart();
		int index = uriString.lastIndexOf("!");
		if (index > 0) {
		    uriString = uriString.substring(0, index);
		    uri = new URI(uriString);
		    return uri;
		}
	    }

	} catch (URISyntaxException ex) {
	    throw new RuntimeException("Error when resolving URL '" + url + "'.");
	}
	return null;

    }

    /**
     * The ".jar" file containing the resource files.
     * 
     * @return The ".jar" file containing the resource files or
     *         <code>null</code>.
     */
    public static File getJarFile() {
	URI uri = getJarURI();

	File result = null;
	if (uri != null) {
	    result = new File(uri);
	}
	return result;
    }

    /**
     * The folder of the ".jar" file containing the resource files.
     * 
     * @return The folder of the ".jar" file containing the resource files or
     *         <code>null</code>.
     */
    public static File getJarFolder() {

	File result = getJarFile();
	if (result != null) {
	    result = result.getParentFile();
	}
	return result;
    }
}
