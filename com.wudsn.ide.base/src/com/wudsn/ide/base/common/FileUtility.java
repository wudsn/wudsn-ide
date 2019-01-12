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

package com.wudsn.ide.base.common;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.Texts;

/**
 * Utility class to access files and their content.
 * 
 * @author Peter Dell
 */
public final class FileUtility {

    /**
     * Intentionally read an unlimited amount of bytes.
     */
    public static final int MAX_SIZE_UNLIMITED = -1;

    /**
     * Intentionally read at most 1MB of bytes or chars.
     */
    public static final int MAX_SIZE_1MB = 1024 * 1024;

    /**
     * Buffer size for the bytes or chars.
     */
    private static final int BUFFER_SIZE = 8192;

    /**
     * Creation is private,
     */
    private FileUtility() {
    }

    /**
     * Reads the content of a file as byte array.
     * 
     * @param ioFile
     *            The file, not <code>null</code>.
     * @param maxSize
     *            The maximum number of character to read or
     *            {@link #MAX_SIZE_UNLIMITED}.
     * @param errorOnMaxSizeExceeded
     *            If <code>true</code>, an error will be thrown in case the
     *            specified maximum number of bytes is exceeded. If
     *            <code>false</code>, the content will be truncated to the
     *            specified maximum size (plus the internal buffer size).
     * 
     * @return The content of the file, may be empty, not <code>null</code>.
     * 
     * @throws CoreException
     *             If the file does not exist or cannot be read.
     */
    public static byte[] readBytes(File ioFile, long maxSize, boolean errorOnMaxSizeExceeded) throws CoreException {
	InputStream inputStream;
	String filePath;

	if (ioFile == null) {
	    throw new IllegalArgumentException("Parameter 'ioFile' must not be null.");
	}

	filePath = ioFile.getAbsolutePath();
	try {
	    inputStream = new FileInputStream(ioFile);
	} catch (FileNotFoundException ex) {
	    // ERROR: Cannot open file '{0}' for reading.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E205,
		    filePath, ex.getMessage()), ex));
	}
	return readBytes(filePath, inputStream, maxSize, errorOnMaxSizeExceeded);

    }

    /**
     * Reads the content of a file as byte array.
     * 
     * @param iFile
     *            The file, not <code>null</code>.
     * @param maxSize
     *            The maximum number of character to read or
     *            {@link #MAX_SIZE_UNLIMITED}.
     * @param errorOnMaxSizeExceeded
     *            If <code>true</code>, an error will be thrown in case the
     *            specified maximum number of bytes is exceeded. If
     *            <code>false</code>, the content will be truncated to the
     *            specified maximum size (plus the internal buffer size).
     * 
     * @return The content of the file, may be empty, not <code>null</code>.
     * 
     * @throws CoreException
     *             If the file does not exist or cannot be read.
     */
    public static byte[] readBytes(IFile iFile, long maxSize, boolean errorOnMaxSizeExceeded) throws CoreException {
	InputStream inputStream;
	String filePath;

	if (iFile == null) {
	    throw new IllegalArgumentException("Parameter 'iFile' must not be null.");
	}

	filePath = iFile.getFullPath().toString();
	try {
	    inputStream = iFile.getContents();
	} catch (CoreException ex) {
	    // ERROR: Cannot open file '{0}' for reading. {1}
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E205,
		    filePath, ex.getMessage()), ex));
	}

	return readBytes(filePath, inputStream, maxSize, errorOnMaxSizeExceeded);

    }

    private static byte[] readBytes(String filePath, InputStream inputStream, long maxSize,
	    boolean errrorOnMaxSizeExceeded) throws CoreException {

	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (inputStream == null) {
	    throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
	}
	if (maxSize < MAX_SIZE_UNLIMITED) {
	    throw new IllegalArgumentException("Parameter 'maxSize' must not be less than " + MAX_SIZE_UNLIMITED + ".");
	}

	byte[] result;
	try {
	    ByteArrayOutputStream bos = new ByteArrayOutputStream();

	    int size = 0;
	    byte[] buffer = new byte[BUFFER_SIZE];
	    int count = 0;

	    do {
		count = inputStream.read(buffer);

		if (count > 0) {
		    bos.write(buffer, 0, count);

		    size += count;
		}
	    } while ((count > -1) && (maxSize == MAX_SIZE_UNLIMITED || size <= maxSize));

	    // Specified maximum size exceeded?
	    if (maxSize != MAX_SIZE_UNLIMITED && size > maxSize && errrorOnMaxSizeExceeded) {
		// ERROR: Content of file '{0}' exceeds the specified maximum
		// size of {1} bytes.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E207,
			filePath, String.valueOf(maxSize))));
	    }
	    bos.close();

	    result = bos.toByteArray();

	} catch (IOException ex) {
	    // ERROR: Cannot read content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E206,
		    filePath), ex));

	} finally {
	    try {
		inputStream.close();
	    } catch (IOException ex) {
		// ERROR: Cannot close input stream of file'{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E209,
			filePath), ex));
	    }
	}
	return result;
    }

    /**
     * Write a byte array to a file.
     * 
     * @param ioFile
     *            The file, not <code>null</code>.
     * @param content
     *            The content of the file, may be empty, not <code>null</code>.
     * @throws CoreException
     *             If the file does not exist or cannot be read.
     */
    public static void writeBytes(File ioFile, byte[] content) throws CoreException {
	OutputStream outputStream;
	String filePath;

	if (ioFile == null) {
	    throw new IllegalArgumentException("Parameter 'ioFile' must not be null.");
	}
	if (content == null) {
	    throw new IllegalArgumentException("Parameter 'content' must not be null.");
	}

	filePath = ioFile.getAbsolutePath();

	if (!ioFile.exists()) {
	    boolean result;
	    try {
		result = ioFile.createNewFile();

	    } catch (IOException ex) {
		// ERROR: Cannot create file '{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E210,
			filePath), ex));
	    }
	    if (!result) {
		// ERROR: Cannot create file '{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E210,
			filePath)));
	    }
	}

	if (!ioFile.isFile()) {
	    // ERROR: '{0}' is no file but a folder.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E204,
		    filePath)));
	}
	try {
	    outputStream = new FileOutputStream(ioFile);
	} catch (FileNotFoundException ex) {
	    // ERROR: Cannot open file '{0}' for writing.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E211,
		    filePath), ex));
	}
	writeBytes(filePath, outputStream, content);

    }

    private static void writeBytes(String filePath, OutputStream outputStream, byte[] content) throws CoreException {

	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (outputStream == null) {
	    throw new IllegalArgumentException("Parameter 'outputStream' must not be null.");
	}
	if (content == null) {
	    throw new IllegalArgumentException("Parameter 'content' must not be null.");
	}

	try {
	    outputStream.write(content);
	} catch (IOException ex) {
	    // ERROR: Cannot write content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E212,
		    filePath), ex));
	} finally {
	    try {
		outputStream.close();
	    } catch (IOException ex) {
		// ERROR: Cannot close output stream of file'{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E213,
			filePath), ex));
	    }
	}
	return;
    }

    /**
     * Reads the content of a file as string.
     * 
     * @param ioFile
     *            The file, not <code>null</code>.
     * @param maxSize
     *            The maximum number of character to read or
     *            {@link #MAX_SIZE_UNLIMITED}.
     * @return The content of the file, may be empty, not <code>null</code>.
     * @throws CoreException
     *             If the file does not exist or cannot be read.
     */
    public static String readString(File ioFile, long maxSize) throws CoreException {
	InputStream inputStream;
	String filePath;

	if (ioFile == null) {
	    throw new IllegalArgumentException("Parameter 'ioFile' must not be null.");
	}

	filePath = ioFile.getAbsolutePath();

	if (!ioFile.exists()) {
	    // ERROR: File '{0}' does not exist.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E203,
		    filePath)));
	}
	if (!ioFile.isFile()) {
	    // ERROR: '{0}' is no file but a folder.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E204,
		    filePath)));
	}
	try {
	    inputStream = new FileInputStream(ioFile);
	} catch (FileNotFoundException ex) {
	    // ERROR: Cannot open file '{0}' for reading.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E205,
		    filePath), ex));
	}
	return readString(filePath, inputStream, maxSize);

    }

    /**
     * Reads a string from an input stream.
     * 
     * @param filePath
     *            The file path to be used in error messages.
     * @param inputStream
     *            The input stream, not <code>null</code>.
     * @param maxSize
     *            The maximum number of bytes to read, a non-negative integer or @link
     *            #MAX_SIZE_UNLIMITED}, see also {@link #MAX_SIZE_1MB}.
     * @return The string, may be empty, not <code>null</code>.
     * @throws CoreException
     *             in case the file cannot be read. the iNput stream has been
     *             closed in this case.
     */
    public static String readString(String filePath, InputStream inputStream, long maxSize) throws CoreException {

	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (inputStream == null) {
	    throw new IllegalArgumentException("Parameter 'inputStream' must not be null.");
	}
	if (maxSize < MAX_SIZE_UNLIMITED) {
	    throw new IllegalArgumentException("Parameter 'maxSize' must not be less than " + MAX_SIZE_UNLIMITED + ".");
	}

	StringBuilder result;
	result = new StringBuilder();
	try {
	    InputStreamReader reader = new InputStreamReader(inputStream);

	    int size = 0;
	    char[] buffer = new char[BUFFER_SIZE];
	    int count = 0;

	    do {
		count = reader.read(buffer);

		if (count > 0) {
		    result.append(buffer, 0, count);

		    size += count;
		}
	    } while ((count > -1) && (maxSize == MAX_SIZE_UNLIMITED || size <= maxSize));

	    // Specified maximum size exceeded?
	    if (maxSize != MAX_SIZE_UNLIMITED && size > maxSize) {
		// ERROR: Content of file '{0}' exceeds the specified maximum
		// size of {1} characters.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E208,
			filePath, String.valueOf(maxSize))));
	    }

	    reader.close();

	} catch (IOException ex) {
	    // ERROR: Cannot read content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E206,
		    filePath), ex));
	} finally {
	    try {
		inputStream.close();
	    } catch (IOException ex) {
		// ERROR: Cannot close input stream of file'{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E209,
			filePath), ex));
	    }
	}
	return result.toString();
    }

    /**
     * Write a string to a file.
     * 
     * @param ioFile
     *            The file, not <code>null</code>.
     * @param content
     *            The content of the file, may be empty, not <code>null</code>.
     * @throws CoreException
     *             If the file does not exist or cannot be read.
     */
    public static void writeString(File ioFile, String content) throws CoreException {
	OutputStream outputStream;
	String filePath;

	if (ioFile == null) {
	    throw new IllegalArgumentException("Parameter 'ioFile' must not be null.");
	}
	if (content == null) {
	    throw new IllegalArgumentException("Parameter 'content' must not be null.");
	}

	filePath = ioFile.getAbsolutePath();

	if (!ioFile.exists()) {
	    boolean result;
	    try {
		result = ioFile.createNewFile();

	    } catch (IOException ex) {
		// ERROR: Cannot create file '{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E210,
			filePath), ex));
	    }
	    if (!result) {
		// ERROR: Cannot create file '{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E210,
			filePath)));
	    }
	}

	if (!ioFile.isFile()) {
	    // ERROR: '{0}' is no file but a folder.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E204,
		    filePath)));
	}
	try {
	    outputStream = new FileOutputStream(ioFile);
	} catch (FileNotFoundException ex) {
	    // ERROR: Cannot open file '{0}' for writing.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E211,
		    filePath), ex));
	}
	writeString(filePath, outputStream, content);

    }

    private static void writeString(String filePath, OutputStream outputStream, String content) throws CoreException {

	if (filePath == null) {
	    throw new IllegalArgumentException("Parameter 'filePath' must not be null.");
	}
	if (outputStream == null) {
	    throw new IllegalArgumentException("Parameter 'outputStream' must not be null.");
	}
	if (content == null) {
	    throw new IllegalArgumentException("Parameter 'content' must not be null.");
	}

	try {
	    OutputStreamWriter writer = new OutputStreamWriter(outputStream);
	    writer.write(content);

	    writer.close();

	} catch (IOException ex) {
	    // ERROR: Cannot write content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E212,
		    filePath), ex));
	} finally {
	    try {
		outputStream.close();
	    } catch (IOException ex) {
		// ERROR: Cannot close output stream of file'{0}'.
		throw new CoreException(new Status(IStatus.ERROR, BasePlugin.ID, TextUtility.format(Texts.MESSAGE_E213,
			filePath), ex));
	    }
	}

	return;
    }

    /**
     * Gets the canonical file of a file. If the canonical path cannot be
     * determined, the absolute path is returned.
     * 
     * @param file
     *            The file, not <code>null</code>.
     * @return The canonical file of the file,not <code>null</code>.
     * 
     * @since 1.7.0
     */
    public static File getCanonicalFile(File file) {
	if (file == null) {
	    throw new IllegalArgumentException("Parameter 'result' must not be null.");
	}
	File result;
	try {
	    result = file.getCanonicalFile();
	} catch (IOException ex) {
	    result = file.getAbsoluteFile();
	}
	return result;

    }

    /**
     * Gets the file extension from a file path.
     * 
     * @param path
     *            The file path, may be empty, not <code>null</code>.
     * @return The file extension, may be empty, not <code>null</code>.
     * 
     * @since 1.7.0
     */
    public static final String getFileExtension(String path) {
	if (path == null) {
	    throw new IllegalArgumentException("Parameter 'path' must not be null.");
	}
	String extension = "";
	int index = path.lastIndexOf('.');
	if (index >= 0) {
	    extension = path.substring(index);
	}
	return extension;
    }

}
