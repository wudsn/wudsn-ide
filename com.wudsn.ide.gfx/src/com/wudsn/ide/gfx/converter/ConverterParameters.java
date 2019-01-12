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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.SequencedProperties;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.GraphicsPropertiesSerializer;

public final class ConverterParameters {

    private static final class Attributes {

	/**
	 * Creation is private.
	 */
	private Attributes() {
	}

	public static final String CONVERTER_DIRECTION = "converterDirection";
	public static final String FILES_CONVERTER_PARAMETERS = "filesConverterParameters";
	public static final String IMAGE_CONVERTER_PARAMETERS = "imageConverterParameters";

    }

    private static final class Defaults {

	/**
	 * Creation is private.
	 */
	private Defaults() {
	}

	public static final ConverterDirection CONVERTER_DIRECTION = ConverterDirection.FILES_TO_IMAGE;
    }

    private ConverterDirection converterDirection;
    private FilesConverterParameters filesConverterParameters;
    private ImageConverterParameters imageConverterParameters;

    public ConverterParameters() {

	filesConverterParameters = new FilesConverterParameters();
	imageConverterParameters = new ImageConverterParameters();
	setDefaults();
    }

    public void setDefaults() {

	converterDirection = Defaults.CONVERTER_DIRECTION;
	filesConverterParameters.setDefaults();
	imageConverterParameters.setDefaults();
    }

    public void setConverterDirection(ConverterDirection value) {
	if (value == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'value' must not be null.");
	}
	this.converterDirection = value;
    }

    public ConverterDirection getConverterDirection() {
	return converterDirection;
    }

    public ConverterCommonParameters getConverterCommonParameters() {
	switch (getConverterDirection()) {
	case FILES_TO_IMAGE:
	    return filesConverterParameters;
	case IMAGE_TO_FILES:
	    return imageConverterParameters;
	default:
	    throw new IllegalStateException("Unknown converter direction "
		    + getConverterDirection() + ".");
	}
    }

    public FilesConverterParameters getFilesConverterParameters() {
	return filesConverterParameters;
    }

    public ImageConverterParameters getImageConverterParameters() {
	return imageConverterParameters;
    }

    public void copyTo(ConverterParameters target) {
	if (target == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'target' must not be null.");
	}
	target.setConverterDirection(converterDirection);
	filesConverterParameters.copyTo(target.getFilesConverterParameters());
	imageConverterParameters.copyTo(target.getImageConverterParameters());
    }

    public boolean equals(ConverterParameters target) {
	if (target == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'target' must not be null.");
	}
	boolean result;
	result = target.getConverterDirection().equals(converterDirection);
	result = result
		&& target.getFilesConverterParameters().equals(
			filesConverterParameters);
	result = result
		&& target.getImageConverterParameters().equals(
			imageConverterParameters);
	return result;
    }

    public InputStream getContents(String filePath) throws CoreException {
	if (filePath == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'filePath' must not be null.");
	}

	GraphicsPropertiesSerializer serializer;
	Properties properties;

	serializer = new GraphicsPropertiesSerializer();
	serialize(serializer);
	properties = serializer.getProperties();
	ByteArrayOutputStream propertiesStream = new ByteArrayOutputStream();

	try {
	    // ByteArrayOutputStream propertiesStream = new
	    // ByteArrayOutputStream();
	    properties
		    .store(propertiesStream, "WUDSN IDE Converter Parameters");
	    propertiesStream.close();

	    // Iterator<ImageWriter> iterator = ImageIO
	    // .getImageWritersBySuffix("png");
	    //
	    // if (!iterator.hasNext()) {
	    // throw new RuntimeException("No image writer for suffix 'png'");
	    // }
	    //
	    // ImageWriter imagewriter = iterator.next();
	    // imagewriter.setOutput(ImageIO
	    // .createImageOutputStream(resourceStream));
	    //
	    // // Create & populate metadata
	    // PNGMetadata metadata = new PNGMetadata();
	    // metadata.tEXt_keyword.add("WUDSN");
	    // metadata.tEXt_text.add(new
	    // String(propertiesStream.toByteArray()));//
	    //
	    // // Render the PNG to memory
	    // BufferedImage bufferedImage = new BufferedImage(imageData.width,
	    // imageData.height, BufferedImage.TYPE_INT_RGB);
	    // for (int y = 0; y < imageData.height; y++) {
	    // for (int x = 0; x < imageData.width; x++) {
	    // int pixel;
	    // RGB rgb;
	    //
	    // pixel = imageData.getPixel(x, y);
	    // rgb = imageData.palette.getRGB(pixel);
	    // bufferedImage.setRGB(x, y, rgb.red << 16 | rgb.green << 8
	    // | rgb.blue);
	    // }
	    // }
	    //
	    // // Build the image container, set the metadata and write the
	    // // container.
	    // IIOImage iioImage = new IIOImage(bufferedImage, null, null);
	    // iioImage.setMetadata(metadata); // Attach the metadata
	    // imagewriter.write(null, iioImage, null);

	} catch (IOException ex) {
	    // ERROR: Cannot write content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, GraphicsPlugin.ID,
		    TextUtility.format(Texts.MESSAGE_E212, filePath), ex));

	}

	return new ByteArrayInputStream(propertiesStream.toByteArray());
    }

    private void serialize(GraphicsPropertiesSerializer serializer) {
	if (serializer == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'serializer' must not be null.");
	}
	serializer
		.writeEnum(Attributes.CONVERTER_DIRECTION, converterDirection);
	filesConverterParameters.serialize(serializer,
		Attributes.FILES_CONVERTER_PARAMETERS);
	imageConverterParameters.serialize(serializer,
		Attributes.IMAGE_CONVERTER_PARAMETERS);
    }

    public void read(IFile file) throws CoreException {
	if (file == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'file' must not be null.");
	}

	byte[] content;
	content = FileUtility.readBytes(file, FileUtility.MAX_SIZE_UNLIMITED,
		false);
	SequencedProperties properties = new SequencedProperties();

	try {
	    properties.load(new ByteArrayInputStream(content));
	} catch (IOException ex) {
	    // ERROR: Cannot read content of file '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, GraphicsPlugin.ID,
		    TextUtility.format(Texts.MESSAGE_E206, file.getFullPath()
			    .toOSString()), ex));

	}
	GraphicsPropertiesSerializer serializer;

	serializer = new GraphicsPropertiesSerializer();
	serializer.getProperties().putAll(properties);
	deserialize(serializer);

	GraphicsPlugin.getInstance().log("ConverterParameters.read({0}):{1}",
		new Object[] { file, serializer.getProperties() });

    }

    private void deserialize(GraphicsPropertiesSerializer serializer) {
	if (serializer == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'serializer' must not be null.");
	}
	converterDirection = serializer.readEnum(
		Attributes.CONVERTER_DIRECTION, Defaults.CONVERTER_DIRECTION,
		ConverterDirection.class);
	filesConverterParameters.deserialize(serializer,
		Attributes.FILES_CONVERTER_PARAMETERS);
	imageConverterParameters.deserialize(serializer,
		Attributes.IMAGE_CONVERTER_PARAMETERS);
    }
}
