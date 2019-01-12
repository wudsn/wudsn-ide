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

import java.util.ArrayList;
import java.util.List;

import org.eclipse.swt.graphics.ImageData;
import org.eclipse.swt.graphics.RGB;
import org.mozilla.javascript.NativeArray;

import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.model.ConverterMode;

public final class ImageConverterData extends ConverterCommonData {

    private ImageConverterParameters parameters;

    // Purely transient cache attributes.
    private transient ConverterScriptData converterScriptData;
    private transient ImageData targetImageData;
    private transient List<byte[]> targetFilesBytes;

    ImageConverterData(ConverterData converterData) {
	super(converterData);
	this.parameters = converterData.getParameters().getImageConverterParameters();
	converterScriptData = new ConverterScriptData();
	targetFilesBytes = new ArrayList<byte[]>(0);

    }

    public ImageConverterParameters getParameters() {
	return parameters;
    }

    public Converter getConverter() {
	ConverterRegistry converterRegistry;
	Converter converter;
	converterRegistry = GraphicsPlugin.getInstance().getConverterRegistry();
	converter = converterRegistry.getConverter(parameters.getConverterId());
	return converter;
    }

    @Override
    public boolean isCreateConversionEnabled() {
	return converterData.isValid() && converterData.getConverterMode() == ConverterMode.RAW_IMAGE;
    }

    @Override
    public boolean isValid() {
	return converterData.isValidImage();
    }

    public boolean isValidConversion() {
	return converterData.isValidConversion();
    }

    @Override
    public boolean isRefreshEnabled() {
	return converterData.isValidImage();
    }

    public boolean isSaveFilesEnabled() {
	if (converterData.isValidConversion()) {
	    for (byte[] bytes : targetFilesBytes) {
		if (bytes != null) {
		    return true;
		}
	    }
	}
	return false;
    }

    /**
     * Clears the image data.
     */
    @Override
    public void clear() {
	super.clear();
	clearTargetFileBytes();
    }

    /**
     * Gets the pixel color value for a given position. There must be an
     * instance of image data set.
     * 
     * @param x
     *            The x position, a non-negative integer.
     * @param y
     *            The y position, a non-negative integer.
     * 
     * @return The pixel color value.
     * 
     * @throws NullPointerException
     *             if there is no image data at all.
     */
    public int getPixel(int x, int y) {
	try {
	    return imageData.getPixel(x, y);
	} catch (IllegalArgumentException ex) {
	    throw new RuntimeException("Pixel (" + x + "," + y + ") is outside of the image.");
	}
    }

    /**
     * Gets the pixel RGB value for a given position. There must be an instance
     * of image data set.
     * 
     * @param x
     *            The x position, a non-negative integer.
     * @param y
     *            The y position, a non-negative integer.
     * 
     * @return The pixel color value.
     * 
     * @throws NullPointerException
     *             if there is no image data at all.
     */
    public int getPixelRGB(int x, int y) {
	int result = getPixel(x, y);
	if (!imageData.palette.isDirect) {
	    RGB rgb = imageData.palette.getRGB(result);
	    result = rgb.red << 16 | rgb.green << 8 | rgb.blue;
	}
	return result;
    }

    /**
     * Sets the target image data, i.e. the image data after converting it to
     * files and back.
     * 
     * @param targetImageData
     *            The target image data or <code>null</code>.
     */
    public void setTargetImageData(ImageData targetImageData) {
	this.targetImageData = targetImageData;
    }

    /**
     * Gets the target image data, i.e. the image data after converting is to
     * files and back.
     * 
     * @return The target image data or <code>null</code>.
     */
    public ImageData getTargetImageData() {
	return targetImageData;
    }

    /**
     * Gets the container for the converter script.
     * 
     * @return The container for the converter script, not <code>null</code>.
     */
    public ConverterScriptData getConverterScriptData() {
	return converterScriptData;
    }

    /**
     * Clears all target files bytes.
     */
    public void clearTargetFileBytes() {
	targetFilesBytes.clear();
    }

    /**
     * Sets the bytes for a target file from java script.
     * 
     * @param targetFileId
     *            The target field id, a non-negative integer.
     * @param scriptBytes
     *            The bytes, may be empty or <code>null</code>.
     */
    public void setTargetFileObject(int targetFileId, NativeArray scriptBytes) {
	byte[] bytes = null;
	if (scriptBytes != null) {
	    int length = (int) scriptBytes.getLength();
	    bytes = new byte[length];
	    for (int i = 0; i < length; i++) {
		Object o = scriptBytes.get(i, null);
		if (o instanceof Double) {
		    bytes[i] = ((Double) o).byteValue();
		} else if (o instanceof Integer) {
		    bytes[i] = ((Integer) o).byteValue();
		}
	    }
	}
	setTargetFileBytes(targetFileId, bytes);
    }

    /**
     * Sets the bytes for a target file.
     * 
     * @param targetFileId
     *            The target field id, a non-negative integer.
     * @param bytes
     *            The bytes, may be empty or <code>null</code>.
     */
    public void setTargetFileBytes(int targetFileId, byte[] bytes) {
	if (targetFileId < 0) {
	    throw new IllegalArgumentException("Parameter 'targetFileId' must not be negative. Specified value is "
		    + targetFileId + ".");
	}
	while (targetFilesBytes.size() <= targetFileId) {
	    targetFilesBytes.add(null);
	}
	targetFilesBytes.set(targetFileId, bytes);
    }

    /**
     * Gets the bytes for a target file.
     * 
     * @param targetFileId
     *            The target field id, a non-negative integer.
     * @return The bytes, may be empty or <code>null</code>.
     */
    public byte[] getTargetFileBytes(int targetFileId) {
	if (targetFileId < 0) {
	    throw new IllegalArgumentException("Parameter 'targetFileId' must not be negative. Specified value is "
		    + targetFileId + ".");
	}
	byte[] bytes;
	if (targetFileId < targetFilesBytes.size()) {
	    bytes = targetFilesBytes.get(targetFileId);
	} else {
	    bytes = null;
	}
	return bytes;
    }

}
