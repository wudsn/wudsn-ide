/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.net.URLConnection;
import java.net.URLStreamHandler;
import java.util.jar.JarFile;
import java.util.zip.ZipEntry;

import org.eclipse.core.runtime.CoreException;

import com.wudsn.ide.base.BasePlugin;

/**
 * Utility class to access resources in the class path.
 * 
 * @author Peter Dell
 */
public final class ResourceUtility {

    public interface ResourceModifier {
	public byte[] modifyResource(URL url, byte[] data);
    }

    private final static class ResourceURLStreamHandler extends URLStreamHandler {

	ResourceModifier resourceModifier;

	/**
	 * Creates a new handler.
	 * 
	 * @param resourceModifier
	 *            The resource modifier or <code>null</code>.
	 */
	public ResourceURLStreamHandler(ResourceModifier resourceModifier) {
	    this.resourceModifier = resourceModifier;
	}

	@Override
	protected URLConnection openConnection(URL url) throws IOException {

	    return new URLConnection(url) {

		@Override
		public void connect() throws IOException {
		}

		@Override
		public String getContentType() {
		    return "text/html";
		}

		@Override
		public InputStream getInputStream() throws IOException {
		    byte[] data;
		    data = null;

		    // Handle "jar" protocol.
		    if (url.getProtocol().equals("jar")) {

			// Extract the "file:/... " part from the
			// "jar:file:/..."
			// URL.
			String path = url.getPath();

			// Check if there's a ".jar" available.
			URI jarURI = ClassPathUtility.getJarURI();
			if (jarURI != null) {

			    // If yes, strip the path prefix to determine the
			    // relative path.
			    String jarURIString = jarURI.toString();
			    if (path.startsWith(jarURIString)) {
				path = path.substring(jarURIString.length() + 2);
			    }
			}
			data = ResourceUtility.loadResourceAsByteArray(path);
			if (data == null) {
			    throw new IOException("No resource found with path '" + path + "' found.");
			}

		    } // Handle "file:" protocol.
		    else if (url.getProtocol().equals("file")) {
			File file;
			try {
			    file = new File(url.toURI());
			    data = FileUtility.readBytes(file, FileUtility.MAX_SIZE_UNLIMITED, false);

			} catch (URISyntaxException ex) {
			    // ignore, not found
			} catch (CoreException ex) {
			    throw new IOException(ex.getMessage());
			}
		    }

		    if (data == null) {
			data = ("Invalid URL: " + url).getBytes();
		    } else {
			if (resourceModifier != null) {
			    data = resourceModifier.modifyResource(url, data);
			    if (data == null) {
				data = ("Resource modified returned null for URL: " + url).getBytes();
			    }

			}
		    }
		    return new ByteArrayInputStream(data);

		}
	    };

	}
    }

    private final static class JarEntryInputStream extends InputStream {
	private JarFile jar;
	private InputStream zipEntryInputStream;

	public JarEntryInputStream(File jarFile, String path) throws IOException {
	    if (jarFile == null) {
		throw new IllegalArgumentException("Parameter 'jarFile' must not be null.");
	    }
	    if (path == null) {
		throw new IllegalArgumentException("Parameter 'path' must not be null.");
	    }

	    jar = new JarFile(jarFile);
	    ZipEntry zipEntry = jar.getEntry(path);
	    zipEntryInputStream = jar.getInputStream(zipEntry);
	}

	@Override
	public int read() throws IOException {
	    return zipEntryInputStream.read();
	}

	@Override
	public void close() throws IOException {
	    try {
		zipEntryInputStream.close();
	    } catch (IOException ex) {
		throw (ex);
	    } finally {
		try {
		    jar.close();
		} catch (IOException ex) {
		    throw (ex);
		}
	    }
	}
    }

    /**
     * Creates a new handler.
     * 
     * @param resourceModifier
     *            The resource modifier or <code>null</code>.
     * @return The handler, not <code>null</code>.
     */
    public static URLStreamHandler createStreamHandler(ResourceModifier resourceModifier) {
	return new ResourceURLStreamHandler(resourceModifier);

    }

    /**
     * Creation is private,
     */
    private ResourceUtility() {

    }

    /**
     * Self implemented logic to bypass the bug described in <a
     * href="http://bugs.sun.com/view_bug.do?bug_id=4523159">JDK-4523159 :
     * getResourceAsStream on jars in path with "!"</a>.
     * 
     * @param path
     *            The path of the resource to load, not <code>null</code>.
     * @return The input stream or <code>null</code> if the source was not
     *         found.
     */
    private static InputStream getInputStream(String path) {
	if (path == null) {
	    throw new IllegalArgumentException("Parameter 'path' must not be null.");
	}
	// If there is no loader, the program was launched using the Java
	// boot class path and the system class loader must be used.
	ClassLoader loader = ResourceUtility.class.getClassLoader();
	URL url = (loader == null) ? ClassLoader.getSystemResource(path) : loader.getResource(path);
	InputStream result = null;
	try {
	    if (url != null) {
		try {
		    result = url.openStream();
		} catch (IOException ignore) {
		}
		if (result == null) {
		    File jarFile = ClassPathUtility.getJarFile();

		    if (jarFile != null) {
			result = new JarEntryInputStream(jarFile, path);

		    }
		}
	    }
	} catch (IOException ex) {
	    BasePlugin.getInstance().logError("Cannot get input stream for path '{0}'", new Object[] { path }, ex);
	}
	return result;
    }

    /**
     * Loads a resource as byte array.
     * 
     * @param path
     *            The resource path, not empty, not <code>null</code>.
     * @return The binary resource content or <code>null</code> if the resource
     *         was not found.
     */
    public static byte[] loadResourceAsByteArray(String path) {
	if (path == null) {
	    throw new IllegalArgumentException("Parameter 'path' must not be null.");
	}
	if (StringUtility.isEmpty(path)) {
	    throw new IllegalArgumentException("Parameter 'path' must not be empty.");
	}
	InputStream inputStream = getInputStream(path);
	if (inputStream == null) {
	    return null;
	}
	ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
	try {
	    byte[] buffer = new byte[8192];
	    int actualLength;
	    while ((actualLength = inputStream.read(buffer, 0, buffer.length)) != -1) {
		outputStream.write(buffer, 0, actualLength);
	    }

	} catch (IOException ex) {
	    BasePlugin.getInstance().logError("Cannot load resource '{0}'.", new Object[] { path }, ex);
	} finally {

	    try {
		inputStream.close();
	    } catch (IOException ignore) {
	    }
	}
	return outputStream.toByteArray();
    }

    /**
     * Loads a resource as string.
     * 
     * @param path
     *            The resource path, not empty, not <code>null</code>.
     * @return The resource content or <code>null</code> if the resource was not
     *         found.
     */
    public static String loadResourceAsString(String path) {
	if (path == null) {
	    throw new IllegalArgumentException("Parameter 'path' must not be null.");
	}
	if (StringUtility.isEmpty(path)) {
	    throw new IllegalArgumentException("Parameter 'path' must not be empty.");
	}
	final InputStream inputStream = getInputStream(path);
	if (inputStream == null) {
	    return null;
	}
	StringBuilder builder = new StringBuilder();
	try {
	    InputStreamReader reader = new InputStreamReader(inputStream);
	    char[] buffer = new char[8192];
	    int actualLength;
	    while ((actualLength = reader.read(buffer, 0, buffer.length)) != -1) {
		builder.append(buffer, 0, actualLength);
	    }
	    reader.close();

	} catch (IOException ex) {
	    BasePlugin.getInstance().logError("Cannot load resource '{0}'.", new Object[] { path }, ex);
	} finally {

	    try {
		inputStream.close();
	    } catch (IOException ignore) {
	    }
	}
	return builder.toString();
    }

}
