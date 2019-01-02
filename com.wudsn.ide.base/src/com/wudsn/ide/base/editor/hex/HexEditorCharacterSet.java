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

package com.wudsn.ide.base.editor.hex;

import java.io.File;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Display;

import com.wudsn.ide.base.BasePlugin;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.ResourceUtility;

/**
 * Logical character set with physical font and character mapping.
 * 
 * @since 1.7.0
 */
enum HexEditorCharacterSet {
    ASCII, ATARI_ATASCII, ATARI_ATASCII_SCREEN_CODE, ATARI_INTERNATIONAL, ATARI_INTERNATIONAL_SCREEN_CODE, C64_PETSCII_UPPER_CASE, C64_PETSCII_LOWER_CASE;

    /**
     * Data class to encapsulate lazy loading and reuse of SWT fonts.
     */
    private final static class Data {

	// Atari and C64 font by Mark Simonson, marksim@bitstream.net,
	// http://www2.bitstream.net/~marksim/atarimac
	private final static String ATARI_FONT_PATH = "fonts/atari8/AtariClassic-Regular.ttf";
	private final static String ATARI_FONT_NAME = "Atari Classic";
	private final static int ATARI_FONT_SIZE = 6;
	private final static int ATARI_FONT_BASE = 0xe000;
	private final static int ATARI_INT_FONT_BASE = 0xe100;

	private final static String C64_FONT_PATH = "fonts/c64/C64Classic-Regular.ttf";
	private final static String C64_FONT_NAME = "C64 Classic";
	private final static int C64_FONT_SIZE = 6;
	private final static int C64_UPPER_FONT_BASE = 0x0100;
	private final static int C64_LOWER_FONT_BASE = 0x0200;

	private static Map<HexEditorCharacterSet, Data> instanceMap;
	private static Map<String, Font> fontMap;

	Font font;
	char[] characterMapping;

	static {
	    instanceMap = new TreeMap<HexEditorCharacterSet, Data>();
	    fontMap = new TreeMap<String, Font>();
	}

	/**
	 * Gets a data instance base on the font type.
	 * 
	 * @param type
	 *            The font type, not <code>null</code>.
	 * 
	 * @return The instance, not <code>null</code>.
	 */
	public static Data getInstance(HexEditorCharacterSet type) {
	    if (type == null) {
		throw new IllegalArgumentException("Parameter 'type' must not be null.");
	    }
	    Data result;
	    synchronized (instanceMap) {
		result = instanceMap.get(type);
		// Add "|| true" below to disable caching for debugging
		// purposes.
		if (result == null) {
		    result = new Data();
		    result.font = null;
		    result.characterMapping = new char[256];
		    String fontPath = null;
		    String fontName = "";
		    int fontSize = -1;
		    switch (type) {
		    case ASCII:
			for (int i = 0; i < 256; i++) {
			    // 7-bit ASCII
			    int charValue = i & 0x7f;
			    // Convert control characters to "."
			    if (charValue < 0x20) {
				charValue = '.';
			    }
			    result.characterMapping[i] = (char) charValue;
			}
			break;
		    case ATARI_ATASCII:
			fontPath = ATARI_FONT_PATH;
			fontName = ATARI_FONT_NAME;
			fontSize = ATARI_FONT_SIZE;
			result.setIdentityMapping(ATARI_FONT_BASE);
			break;
		    case ATARI_ATASCII_SCREEN_CODE:
			fontPath = ATARI_FONT_PATH;
			fontName = ATARI_FONT_NAME;
			fontSize = ATARI_FONT_SIZE;
			result.setAtariScreenCodeMapping(ATARI_FONT_BASE);
			break;
		    case ATARI_INTERNATIONAL:
			fontPath = ATARI_FONT_PATH;
			fontName = ATARI_FONT_NAME;
			fontSize = ATARI_FONT_SIZE;
			result.setIdentityMapping(ATARI_INT_FONT_BASE);
			break;
		    case ATARI_INTERNATIONAL_SCREEN_CODE:
			fontPath = ATARI_FONT_PATH;
			fontName = ATARI_FONT_NAME;
			fontSize = ATARI_FONT_SIZE;
			result.setAtariScreenCodeMapping(ATARI_INT_FONT_BASE);
			break;
		    case C64_PETSCII_UPPER_CASE:
			fontPath = C64_FONT_PATH;
			fontName = C64_FONT_NAME;
			fontSize = C64_FONT_SIZE;
			result.setIdentityMapping(C64_UPPER_FONT_BASE);
			break;
		    case C64_PETSCII_LOWER_CASE:
			fontPath = C64_FONT_PATH;
			fontName = C64_FONT_NAME;
			fontSize = C64_FONT_SIZE;
			result.setIdentityMapping(C64_LOWER_FONT_BASE);
			break;
		    default:
			throw new IllegalArgumentException("Unsupported font type " + type + ".");
		    }

		    if (fontPath != null) {
			// Check if temp file is already cached?
			result.font = fontMap.get(fontPath);
			if (result.font == null) {
			    File file = null;
			    try {
				file = File.createTempFile("Data", null);
				byte[] content = ResourceUtility.loadResourceAsByteArray(fontPath);
				FileUtility.writeBytes(file, content);
			    } catch (Exception ex) {
				BasePlugin.getInstance().logError(
					"Error while copying font data of font '{0}' to temporary file.",
					new Object[] { fontPath }, ex);
				if (file != null) {
				    file.delete();
				}
				file = null;
			    }

			    // If temp file is present,
			    if (file != null) {
				Device device = Display.getDefault();
				String absolutePath = file.getAbsolutePath();
				if (device.loadFont(absolutePath)) {
				    result.font = new Font(device, fontName, fontSize, SWT.NORMAL);
				    // Make sure the file is kept until the
				    // process
				    // ends.
				    file.deleteOnExit();
				    fontMap.put(fontPath, result.font);

				} else {
				    // Loading failed, so no need to keep the
				    // file.
				    file.delete();
				}
			    }
			}
		    }

		    if (result.font == null) {
			result.font = JFaceResources.getTextFont();
		    }
		    instanceMap.put(type, result);
		}
	    }
	    return result;
	}

	private void setIdentityMapping(int base) {
	    for (int i = 0; i < 256; i++) {
		characterMapping[i] = (char) (base + i);
	    }
	}

	private void setAtariScreenCodeMapping(int base) {
	    for (int i = 0; i < 256; i++) {
		int charValue = i & 0x7f;
		if (charValue < 0x40) {
		    charValue = charValue + 0x20;
		} else if (charValue < 0x60) {
		    charValue = charValue - 0x40;
		}
		if (i >= 0x80) {
		    charValue |= 0x80;
		}
		characterMapping[i] = (char) (base + charValue);
	    }
	}

	/**
	 * Creation is private.
	 */
	private Data() {
	}

    }

    /**
     * Determines the default character set for a given file content mode.
     * 
     * @param fileContentMode
     *            The file content mode, not <code>null</code>.
     * @return The default character set, not <code>null</code>.
     */
    public static HexEditorCharacterSet getDefaultCharacterSet(HexEditorFileContentMode fileContentMode) {
	if (fileContentMode == null) {
	    throw new IllegalArgumentException("Parameter 'fileContentMode' must not be null.");
	}
	switch (fileContentMode.getHardware()) {
	case GENERIC:
	    return ASCII;
	case ATARI8BIT:
	    return ATARI_ATASCII;
	case C64:
	    return C64_PETSCII_UPPER_CASE;
	}
	throw new IllegalArgumentException("File content mode " + fileContentMode + " has an unknown hardware "
		+ fileContentMode.getHardware());
    }

    /**
     * Gets the SWT font.
     * 
     * @return The SWT font, not <code>null</code>.
     */
    public Font getFont() {
	return Data.getInstance(this).font;
    }

    /**
     * Gets the character mapping.
     * 
     * @return The character mapping as an array of 256 char values, not
     *         <code>null</code>.
     */
    public char[] getCharacterMapping() {
	return Data.getInstance(this).characterMapping;
    }

}
