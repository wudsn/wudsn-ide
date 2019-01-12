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

package com.wudsn.ide.gfx.converter;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.model.Palette;

public abstract class Converter {

    private ConverterDefinition definition;

    /**
     * Constants for 1 bit pixels. Constants are defined as int to ensure no
     * sign extension takes place when anding with byte values.
     */
    protected static final int[] mask_1bit = new int[] { 0x80, 0x40, 0x20,
	    0x10, 0x08, 0x04, 0x02, 0x01 };
    protected static final int[] shift_1bit = new int[] { 7, 6, 5, 4, 3, 2, 1,
	    0 };

    /**
     * Constants for 2 bit pixels.Constants are defined as int to ensure no sign
     * extension takes place when anding with byte values.
     */
    protected static final int[] mask_2bit = new int[] { 0xc0, 0x30, 0x0c, 0x03 };
    protected static final int[] shift_2bit = new int[] { 6, 4, 2, 0 };

    /**
     * Constants for 4 bit pixels.Constants are defined as int to ensure no sign
     * extension takes place when anding with byte values.
     */
    protected static final int[] mask_4bit = new int[] { 0xf0, 0x0f };
    protected static final int[] shift_4bit = new int[] { 4, 0 };

    /**
     * Creation is protected.
     */
    protected Converter() {
    }

    /**
     * Sets the definition of the Converter. Called by {@link ConverterRegistry}
     * only.
     * 
     * @param definition
     *            The definition if the Converter, not <code>null</code>.
     */
    final void setDefinition(ConverterDefinition definition) {
	if (definition == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'type' must not be null.");
	}
	this.definition = definition;
    }

    /**
     * Gets the definition of the Converter.
     * 
     * @return The definition of the Converter, not <code>null</code>.
     */
    public final ConverterDefinition getDefinition() {
	if (definition == null) {
	    throw new IllegalStateException(
		    "Field 'definition' must not be null.");
	}
	return definition;
    }

    /**
     * Determines if the given byte array can be converted to an image by this
     * converter.
     * 
     * @param bytes
     *            The byte array, not empty and not <code>null</code>.
     * 
     * @return <code>true</code> if the given byte array can be converted to an
     *         image by this converter, <code>false</code> otherwise.
     * 
     * @since 1.6.0
     */
    public boolean canConvertToImage(byte[] bytes) {
	if (bytes == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'bytes' must not be null.");
	}
	return false;
    }

    /**
     * Converts the byte array content to image size and palette. Implementation
     * shall call
     * {@link #setImageSizeAndPalette(FilesConverterData, int, int, Palette, RGB[])}
     * to set the corresponding values.
     * 
     * @param data
     *            The file converter data container to be filled, not
     *            <code>null</code>.
     * @param bytes
     *            The byte array, not empty and not <code>null</code>.
     * 
     * @since 1.6.0
     */
    public void convertToImageSizeAndPalette(FilesConverterData data,
	    byte[] bytes) {
	throw new UnsupportedOperationException();
    }

    /**
     * Sets the current converter, applies its defaults and then sets the image
     * size and palette.
     * 
     * @param data
     *            The file converter data container to be filled, not
     *            <code>null</code>.
     * @param columns
     *            The number of columns.
     * @param rows
     *            The number of rows.
     * @param palette
     *            The palette, not <code>null</code>.
     * @param paletteColors
     *            The palette colors or not <code>null</code> if palette is
     *            {@link Palette#TRUE_COLOR}.
     */
    protected final void setImageSizeAndPalette(FilesConverterData data,
	    int columns, int rows, Palette palette, RGB[] paletteColors) {
	if (data == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'data' must not be null.");
	}
	if (palette == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'palette' must not be null.");
	}
	if (paletteColors == null) {
	    if (!palette.equals(Palette.TRUE_COLOR)) {
		throw new IllegalArgumentException(
			"Parameter 'paletteColors' must not be null if palette is not TRUE_COLOR.");
	    }
	    paletteColors = new RGB[0];
	}
	FilesConverterParameters parameters;
	parameters = data.getParameters();
	parameters.setConverterId(this.getClass().getName());
	parameters.setDisplayAspect(getDefinition()
		.getTargetImageDisplayAspect());
	parameters.setColumns(columns);
	parameters.setRows(rows);
	parameters.setPalette(palette);
	parameters.setPaletteRGBs(paletteColors);
    }

    public abstract void convertToImageDataSize(FilesConverterData data);

    /**
     * Converts the files to an image.
     * 
     * @param data
     *            The data, not <code>null</code>.
     * @return <code>true</code> if an image was created and can be saved (i.e.
     *         pixels set), <code>false</code> if not.
     */
    public abstract boolean convertToImageData(FilesConverterData data);
}
