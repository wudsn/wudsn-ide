/**
 * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.base.hardware;

import java.io.File;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

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
public enum HardwareCharacterSet {
	ASCII, ATARI_ATASCII, ATARI_ATASCII_SCREEN_CODE, ATARI_INTERNATIONAL, ATARI_INTERNATIONAL_SCREEN_CODE,
	CBM_PETSCII_UPPER_CASE, CBM_PETSCII_LOWER_CASE;

	// Atari and C64 font by Mark Simonson, marksim@bitstream.net,
	// http://www2.bitstream.net/~marksim/atarimac
	// Font names and file names are kept as they are in the original download.
	private final static String ATARI_FONT_PATH = "fonts/atari8/AtariClassic-Regular.ttf";
	private final static String ATARI_FONT_NAME = "Atari Classic";
	private final static int ATARI_FONT_BASE = 0xe000;
	private final static int ATARI_INT_FONT_BASE = 0xe100;

	private final static String CBM_FONT_PATH = "fonts/c64/C64Classic-Regular.ttf";
	private final static String CBM_FONT_NAME = "C64 Classic";
	private final static int CBM_UPPER_FONT_BASE = 0x0100;
	private final static int CBM_LOWER_FONT_BASE = 0x0200;

	private static Map<String, File> fontNameFileMap;
	private static Set<String> fontPathSet;
	private static Map<String, Font> fontNameSizeFontMap;
	private static Map<HardwareCharacterSet, CharacterMapping> characterMappingMap;

	static {
		fontNameFileMap = new TreeMap<String, File>();
		fontPathSet = new TreeSet<String>();
		fontNameSizeFontMap = new TreeMap<String, Font>();

		characterMappingMap = new TreeMap<HardwareCharacterSet, CharacterMapping>();
	}

	/**
	 * CharacterMapping class to encapsulate lazy loading and reuse of SWT fonts.
	 */
	private final static class CharacterMapping {
		char[] characterMapping;

		/**
		 * Gets a data instance base on the font type.
		 * 
		 * @param type The font type, not <code>null</code>.
		 * 
		 * @return The instance, not <code>null</code>.
		 */
		public static CharacterMapping getInstance(HardwareCharacterSet type) {
			if (type == null) {
				throw new IllegalArgumentException("Parameter 'type' must not be null.");
			}
			CharacterMapping result = null;
			synchronized (characterMappingMap) {
				result = characterMappingMap.get(type);
				// Add "|| true" below to disable caching for debugging
				// purposes.
				if (result == null) {
					result = new CharacterMapping();
					result.characterMapping = new char[256];
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
						result.setIdentityMapping(ATARI_FONT_BASE);
						break;
					case ATARI_ATASCII_SCREEN_CODE:
						result.setAtariScreenCodeMapping(ATARI_FONT_BASE);
						break;
					case ATARI_INTERNATIONAL:
						result.setIdentityMapping(ATARI_INT_FONT_BASE);
						break;
					case ATARI_INTERNATIONAL_SCREEN_CODE:
						result.setAtariScreenCodeMapping(ATARI_INT_FONT_BASE);
						break;
					case CBM_PETSCII_UPPER_CASE:
						result.setIdentityMapping(CBM_UPPER_FONT_BASE);
						break;
					case CBM_PETSCII_LOWER_CASE:
						result.setIdentityMapping(CBM_LOWER_FONT_BASE);
						break;
					default:
						throw new IllegalArgumentException("Unsupported font type " + type + ".");
					}

				}

				characterMappingMap.put(type, result);
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
		private CharacterMapping() {
		}

	}

	private static Font getFont(HardwareCharacterSet type, int fontHeightPoints) {

		String fontPath = null;
		String fontName = null;
		String fontRegistryName = null;

		switch (type) {
		case ASCII:
			return null;

		case ATARI_ATASCII:
		case ATARI_ATASCII_SCREEN_CODE:
		case ATARI_INTERNATIONAL:
		case ATARI_INTERNATIONAL_SCREEN_CODE:

			fontPath = ATARI_FONT_PATH;
			fontName = ATARI_FONT_NAME;
			fontRegistryName = "com.wudsn.ide.base.hardware.HardwareFont.ATARI8";
			break;

		case CBM_PETSCII_UPPER_CASE:
		case CBM_PETSCII_LOWER_CASE:

			fontPath = CBM_FONT_PATH;
			fontName = CBM_FONT_NAME;
			fontRegistryName = "com.wudsn.ide.base.hardware.HardwareFont.CBM";
		}

		// Get preferences based on the extension point "org.eclipse.ui.themes"
		var fontSize = JFaceResources.getFontDescriptor(fontRegistryName).getFontData()[0].getHeight();

		return getFont(fontPath, fontName, fontSize);
	}

	private static Font getFont(String fontPath, String fontName, int fontSize) {
		Font font = null;
		synchronized (fontNameFileMap) {

			File file = null;
			if (fontPath != null) {
				// Check if temporary file is already cached?
				if (!fontNameFileMap.containsKey(fontName)) {
					try {
						file = File.createTempFile("HardwareCharacterSet-" + fontName, null);
						byte[] content = ResourceUtility.loadResourceAsByteArray(fontPath);
						FileUtility.writeBytes(file, content);
						// Make sure the file is kept until the process ends.
						file.deleteOnExit();
					} catch (Exception ex) {
						BasePlugin.getInstance().logError(
								"Error while copying font data of font '{0}' to temporary file.",
								new Object[] { fontPath }, ex);
						if (file != null) {
							file.delete();
						}
						file = null;
					}
					// Remember the file, may be null
					fontNameFileMap.put(fontName, file);
				} else {
					file = fontNameFileMap.get(fontName);
				}
			}

			// If temporary file is present,try to load the font.
			if (file != null) {
				Device device = Display.getDefault();
				if (!fontPathSet.contains(fontPath)) {
					String absolutePath = file.getAbsolutePath();
					if (device.loadFont(absolutePath)) {
						fontPathSet.add(fontPath);

					} else {
						throw new RuntimeException(
								"Cannot load font '" + fontName + "' from file '" + absolutePath + "'");
					}
				}
				var fontNameSizeKey = fontName + "/" + fontSize;
				font = fontNameSizeFontMap.get(fontNameSizeKey);
				if (font == null) {
					font = new Font(device, fontName, fontSize, SWT.NORMAL);
					fontNameSizeFontMap.put(fontNameSizeKey, font);
				}

			}
		}
		return font;
	}

	/**
	 * Gets the SWT font.
	 * 
	 * @return The SWT font, not <code>null</code>.
	 */
	public Font getFont() {
		var textFont = JFaceResources.getTextFont();
		var font = getFont(this, textFont.getFontData()[0].getHeight());
		if (font == null) {
			font = textFont;
		}
		return font;
	}

	/**
	 * Gets the character mapping.
	 * 
	 * @return The character mapping as an array of 256 char values, not
	 *         <code>null</code>.
	 */
	public char[] getCharacterMapping() {
		return CharacterMapping.getInstance(this).characterMapping;
	}

}
