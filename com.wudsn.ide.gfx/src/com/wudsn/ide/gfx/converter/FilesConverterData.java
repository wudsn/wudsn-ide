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

package com.wudsn.ide.gfx.converter;

import java.util.ArrayList;
import java.util.List;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.ConverterMode;

public final class FilesConverterData extends ConverterCommonData {

    // Persistent attributes.
    private FilesConverterParameters parameters;

    // Transient attributes.
    private List<byte[]> sourceFilesBytes;
    private boolean imageDataValid;

    FilesConverterData(ConverterData converterData) {
	super(converterData);

	this.parameters = converterData.getParameters().getFilesConverterParameters();
	sourceFilesBytes = new ArrayList<byte[]>(0);
    }

    public FilesConverterParameters getParameters() {
	return parameters;
    }

    /**
     * Gets the converter for a converter id specified in the parameters.
     * Instances of {@link Converter} are stateless singletons within the
     * plugin.
     * 
     * @return The converter or <code>null</code>.
     */
    public Converter getConverter() {
	ConverterRegistry converterRegistry;
	Converter converter;
	converterRegistry = GraphicsPlugin.getInstance().getConverterRegistry();
	converter = converterRegistry.getConverter(parameters.getConverterId());
	return converter;
    }

    public int getTargetImagePaletteSize() {
	ConverterRegistry converterRegistry;
	ConverterDefinition converterDefinition;
	int result;

	converterRegistry = GraphicsPlugin.getInstance().getConverterRegistry();
	converterDefinition = converterRegistry.getDefinition(parameters.getConverterId(),
		ConverterDirection.FILES_TO_IMAGE);
	if (converterDefinition != null) {
	    result = converterDefinition.getTargetImagePaletteSize();
	} else {
	    result = 0;
	}
	return result;
    }

    @Override
    public boolean isCreateConversionEnabled() {
	return converterData.isValid() && converterData.getConverterMode() == ConverterMode.RAW_FILE;
    }

    @Override
    public boolean isValid() {
	return converterData.isValidFile();
    }

    @Override
    public boolean isRefreshEnabled() {
	return converterData.isValidFile();
    }

    @Override
    public void clear() {
	super.clear();
	sourceFilesBytes.clear();
    }

    public void setSourceFileBytes(int sourceFileId, byte[] bytes) {
	if (sourceFileId < 0) {
	    throw new IllegalArgumentException("Parameter 'sourceFileId' must not be negative. Specified value is "
		    + sourceFileId + ".");
	}
	while (sourceFilesBytes.size() <= sourceFileId) {
	    sourceFilesBytes.add(null);
	}
	sourceFilesBytes.set(sourceFileId, bytes);
    }

    public byte[] getSourceFileBytes(int sourceFileId) {
	if (sourceFileId < 0) {
	    throw new IllegalArgumentException("Parameter 'sourceFileId' must not be negative. Specified value is "
		    + sourceFileId + ".");
	}
	byte[] bytes;
	if (sourceFileId < sourceFilesBytes.size()) {
	    bytes = sourceFilesBytes.get(sourceFileId);
	} else {
	    bytes = null;
	}
	return bytes;
    }
    
    public void setImageDataValid(boolean imageDataValid) {
	this.imageDataValid = imageDataValid;
    }

    public boolean isImageDataValid() {
	return imageDataValid;
    }

    public boolean isSaveImageEnabled() {
	return converterData.isValidFile() && isImageDataValid();
    }

    /**
     * Gets a byte from the source file, taking it offset from the parameter
     * into account plus the relative offset of the conversion routine.
     * 
     * @param sourceFileId
     *            The id of the source file, a non-negative integer.
     * @param offset
     *            The relative object of the conversion routine, a non-negative
     *            integer.
     * @return The byte as integer or <code>-1</code> to indicate that the
     *         offset is outside of the file.
     */
    public int getSourceFileByte(int sourceFileId, int offset) {
	if (sourceFileId >= sourceFilesBytes.size()) {
	    return -1;
	}

	byte[] sourceFileBytes = sourceFilesBytes.get(sourceFileId);
	if (sourceFileBytes == null) {
	    return -1;
	}

	offset = offset + parameters.getSourceFile(sourceFileId).getOffset();
	if (offset < 0 || offset >= sourceFileBytes.length) {
	    return -1;
	}
	int value = sourceFileBytes[offset] & 0xff;
	return value;
    }

    public void setPalettePixel(int x, int y, int color) {
	try {
	    imageData.setPixel(x, y, color);
	} catch (RuntimeException ex) {
	    GraphicsPlugin.getInstance().logError(
		    "Error setting palette pixel at ({0}, {1}) to color {2}. Image size is {3},{4}",
		    new String[] { NumberUtility.getLongValueDecimalString(x),
			    NumberUtility.getLongValueDecimalString(y), HexUtility.getLongValueHexString(color),
			    NumberUtility.getLongValueDecimalString(imageData.width),
			    NumberUtility.getLongValueDecimalString(imageData.height) }, ex);
	}
    }

    public void setDirectPixel(int x, int y, int color) {
	try {
	    imageData.setPixel(x, y, color);
	} catch (RuntimeException ex) {
	    GraphicsPlugin.getInstance().logError(
		    "Error setting direct pixel at ({0}, {1}) to color {2}. Image size is {3},{4}",
		    new String[] { NumberUtility.getLongValueDecimalString(x),
			    NumberUtility.getLongValueDecimalString(y), HexUtility.getLongValueHexString(color),
			    NumberUtility.getLongValueDecimalString(imageData.width),
			    NumberUtility.getLongValueDecimalString(imageData.height) }, ex);
	}
    }
}
