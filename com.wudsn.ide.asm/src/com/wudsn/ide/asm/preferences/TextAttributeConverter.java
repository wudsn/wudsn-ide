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

package com.wudsn.ide.asm.preferences;

import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.text.TextAttribute;
import org.eclipse.swt.SWT;
import org.eclipse.swt.graphics.Color;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.graphics.FontData;
import org.eclipse.swt.widgets.Display;

import com.wudsn.ide.base.common.StringUtility;

/**
 * Convertdf go connvert the class TextAttributes into a PreferenceStore
 * compatible form.
 * 
 * @author Peter Dell
 * @author Daniel Mitte
 */
public final class TextAttributeConverter {

	/**
	 * Converts preferences string to a color value.
	 * 
	 * @param value The color as an RGB string of the for "r, g, b", may be empty or
	 *              <code>null</code>.
	 * 
	 * @return The color, not <code>null</code>.
	 */
	public static TextAttribute fromString(String value) {

		TextAttribute result;
		Display display = Display.getCurrent();
		Color foregroundColor;
		Color backgroundColor;
		int style;
		if (value != null) {

			String[] data = value.split(",");

			try {
				int r, g, b;

				if (StringUtility.isEmpty(data[0] + data[1] + data[2])) {
					foregroundColor = null;
				} else {
					r = Integer.parseInt(data[0]);
					g = Integer.parseInt(data[1]);
					b = Integer.parseInt(data[2]);
					foregroundColor = new Color(display, r, g, b);
				}
				if (StringUtility.isEmpty(data[3] + data[4] + data[5])) {
					backgroundColor = null;
				} else {
					r = Integer.parseInt(data[3]);
					g = Integer.parseInt(data[4]);
					b = Integer.parseInt(data[5]);
					backgroundColor = new Color(display, r, g, b);
				}
				style = b = Integer.parseInt(data[6]);
			} catch (Exception ex) {
				foregroundColor = new Color(display, 0, 0, 0);
				backgroundColor = null;
				style = SWT.NORMAL;
			}
		} else {
			foregroundColor = new Color(display, 0, 0, 0);
			backgroundColor = null;
			style = SWT.NORMAL;
		}
		Font font = JFaceResources.getTextFont();
		FontData fontData = font.getFontData()[0];
		fontData = new FontData(fontData.getName(), fontData.getHeight(), style);
		font = new Font(display, fontData);
		result = new TextAttribute(foregroundColor, backgroundColor, style, font);
		return result;
	}

	/**
	 * Converts a text attribute to a string, except for the font.
	 * 
	 * @param textAttribute The text attribute, not <code>null</code>.
	 * @return The string, not <code>null</code>.
	 */
	public static String toString(TextAttribute textAttribute) {
		if (textAttribute == null) {
			throw new IllegalArgumentException("Parameter 'textAttribute' must not be null.");
		}

		String result;
		result = toString(textAttribute.getForeground()) + "," + toString(textAttribute.getBackground()) + ","
				+ Integer.toString(textAttribute.getStyle());
		return result;
	}

	/**
	 * Converts a color to a comma separated RGB string.
	 * 
	 * @param color The color, may be <code>null</code>.
	 * @return The comma separated RGB string, not <code>null</code>.
	 */
	private static String toString(Color color) {
		String result;
		if (color == null) {
			result = ",,";
		} else {
			String red = Integer.toString(color.getRed());
			String green = Integer.toString(color.getGreen());
			String blue = Integer.toString(color.getBlue());
			result = red + "," + green + "," + blue;
		}
		return result;
	}

	/**
	 * Dispose the colors and the font of the text attribute created by this class.
	 * 
	 * @param textAttribute The text attribute or <code>null</code>.
	 * 
	 * @since 1.6.0
	 */
	public static void dispose(TextAttribute textAttribute) {
		if (textAttribute != null) {
			if (textAttribute.getForeground() != null) {
				textAttribute.getForeground().dispose();
			}
			if (textAttribute.getBackground() != null) {
				textAttribute.getBackground().dispose();
			}
			if (textAttribute.getFont() != null) {
				textAttribute.getFont().dispose();
			}
		}

	}
}
