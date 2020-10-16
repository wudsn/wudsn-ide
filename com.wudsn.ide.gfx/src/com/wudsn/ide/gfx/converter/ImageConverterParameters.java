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

import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.GraphicsPropertiesSerializer;

public final class ImageConverterParameters extends ConverterCommonParameters {

    public static final class Attributes {

	/**
	 * Creation is private.
	 */
	private Attributes() {
	}

	public static final String IMAGE_FILE_PATH = "imageFilePath";

	public static final String TARGET_FILES = "targetFiles";
	public static final String TARGET_FILE_PATH = "path";

	public static final String USE_DEFAULT_SCRIPT = "useDefaultScript";
	public static final String SCRIPT = "script";

    }

    private static final class Defaults {

	/**
	 * Creation is private.
	 */
	private Defaults() {
	}

	public static final String IMAGE_FILE_PATH = "";
	public static final String TARGET_FILE_PATH = "";

	public static final boolean USE_DEFAULT_SCRIPT = true;
	public static final String SCRIPT = "";
    }

    public static final class MessageIds {

	/**
	 * Creation is private.
	 */
	private MessageIds() {
	}

	public static final int IMAGE_FILE_PATH = 2010;
	public static final int TARGET_FILE_PATH = 2020;
	public static final int TARGET_FILE_OFFSET = 2030;
	public static final int USE_DEFAULT_SCRIPT = 2040;
	public static final int SCRIPT = 2041;
    }

    public static final class TargetFile {
	private int id;
	private String path;
	private int offset;

	public TargetFile(int id) {
	    this.id = id;
	    path = Defaults.TARGET_FILE_PATH;
	}

	public int getId() {
	    return id;
	}

	public int getPathMessageId() {
	    return MessageIds.TARGET_FILE_PATH + id;
	}

	public String getPath() {
	    return path;
	}

	public void setPath(String path) {
	    if (path == null) {
		throw new IllegalArgumentException("Parameter 'path' must not be null.");
	    }
	    this.path = path;
	}

	public int getOffsetMessageId() {
	    return MessageIds.TARGET_FILE_OFFSET + id;
	}

	public int getOffset() {
	    return offset;
	}

	public void setOffset(int offset) {
	    this.offset = offset;
	}

	@Override
	public boolean equals(Object obj) {
	    if (obj == null) {
		throw new IllegalArgumentException("Parameter 'obj' must not be null.");
	    }
	    TargetFile other = (TargetFile) obj;
	    return other.id == this.id && other.path.equals(this.path) && other.offset == this.offset;
	}

	@Override
	public int hashCode() {
	    return id + 7 * path.hashCode() + 17 * offset;
	}

    }

    private String imageFilePath;
    private int targetFilesSize;
    private List<TargetFile> targetFiles;
    private boolean useDefaultScript;
    private String script;

    ImageConverterParameters() {

	int size = ConverterRegistry.MAX_SOURCE_FILES;
	this.targetFiles = new ArrayList<TargetFile>(size);
	for (int i = 0; i < size; i++) {
	    this.targetFiles.add(new TargetFile(i));
	}
	setDefaults();
    }

    @Override
    public void setDefaults() {
	super.setDefaults();
	imageFilePath = Defaults.IMAGE_FILE_PATH;
	for (TargetFile targetFile : targetFiles) {
	    targetFile.setPath(Defaults.TARGET_FILE_PATH);
	}
	useDefaultScript = Defaults.USE_DEFAULT_SCRIPT;
	script = Defaults.SCRIPT;
    }

    @Override
    public void setConverterId(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}

	if (!value.equals(this.converterId))
	    this.converterId = value;

	ConverterDefinition converterDefinition;
	converterDefinition = GraphicsPlugin.getInstance().getConverterRegistry()
		.getDefinition(converterId, ConverterDirection.IMAGE_TO_FILES);
	if (converterDefinition != null) {
	    targetFilesSize = targetFiles.size();
	} else {
	    targetFilesSize = 0;
	}
    }

    public void setDefaultTargetFilePath(String targetFilePath) {
	if (targetFilePath == null) {
	    throw new IllegalArgumentException("Parameter 'targetFilePath' must not be null.");
	}
	for (int i = 0; i < targetFiles.size(); i++) {
	    TargetFile targetFile = targetFiles.get(i);
	    targetFile.setPath(targetFilePath);
	    targetFile.setOffset(0);
	}
    }

    public void setImageFilePath(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	this.imageFilePath = value;
    }

    public String getImageFilePath() {
	return imageFilePath;
    }

    public int getTargetFilesSize() {
	return targetFilesSize;
    }

    public TargetFile getTargetFile(int targetFileId) {
	return targetFiles.get(targetFileId);
    }

    /**
     * Sets the indicator to use the default script
     * 
     * @param value
     *            <code>true</code> to use the default script,
     *            <code>false</code> to use the saved script.
     */
    public void setUseDefaultScript(boolean value) {
	this.useDefaultScript = value;
    }

    /**
     * Gets the indicator to use the default script
     * 
     * @return <code>true</code> to use the default script, <code>false</code>
     *         to use the saved script.
     */
    public boolean isUseDefaultScript() {
	return useDefaultScript;
    }

    /**
     * Gets the script for the conversion logic.
     * 
     * @param value
     *            The script, may be empty, not <code>null</code>.
     */
    public void setScript(String value) {
	if (value == null) {
	    throw new IllegalArgumentException("Parameter 'value' must not be null.");
	}
	this.script = value;
    }

    /**
     * Gets the script for the conversion logic.
     * 
     * @return The script, may be empty, not <code>null</code>.
     */
    public String getScript() {
	if (script == null) {
	    throw new IllegalStateException("Field 'script' must not be null.");
	}
	return script;
    }

    protected final void copyTo(ImageConverterParameters target) {
	if (target == null) {
	    throw new IllegalArgumentException("Parameter 'target' must not be null.");
	}
	super.copyTo(target);

	target.setImageFilePath(imageFilePath);
	target.targetFiles.clear();
	for (TargetFile targetFile : targetFiles) {
	    TargetFile targetTargetFile;
	    targetTargetFile = new TargetFile(targetFile.getId());
	    targetTargetFile.setPath(targetFile.getPath());
	    targetTargetFile.setOffset(targetFile.getOffset());
	    target.targetFiles.add(targetTargetFile);
	}

	target.setUseDefaultScript(useDefaultScript);
	target.setScript(script);
    }

    protected final boolean equals(ImageConverterParameters target) {
	if (target == null) {
	    throw new IllegalArgumentException("Parameter 'target' must not be null.");
	}
	boolean result;
	result = super.equals(target);
	result = result && target.getImageFilePath().equals(imageFilePath);
	result = result && target.targetFiles.equals(targetFiles);
	result = result && target.isUseDefaultScript() == useDefaultScript;
	result = result && target.getScript().equals(script);
	return result;
    }

    @Override
    protected final void serialize(GraphicsPropertiesSerializer serializer, String key) {
	if (serializer == null) {
	    throw new IllegalArgumentException("Parameter 'serializer' must not be null.");
	}
	if (key == null) {
	    throw new IllegalArgumentException("Parameter 'key' must not be null.");
	}

	super.serialize(serializer, key);
	GraphicsPropertiesSerializer ownSerializer;

	ownSerializer = new GraphicsPropertiesSerializer();
	ownSerializer.writeString(Attributes.IMAGE_FILE_PATH, imageFilePath);
	ownSerializer.writeInteger(Attributes.TARGET_FILES, targetFilesSize);
	for (int i = 0; i < targetFilesSize; i++) {
	    TargetFile targetFile = targetFiles.get(i);
	    GraphicsPropertiesSerializer innerSeralizer;
	    innerSeralizer = new GraphicsPropertiesSerializer();
	    innerSeralizer.writeString(Attributes.TARGET_FILE_PATH, targetFile.getPath());
	    ownSerializer.writeProperties(Attributes.TARGET_FILES + "." + i, innerSeralizer);
	}

	ownSerializer.writeBoolean(Attributes.USE_DEFAULT_SCRIPT, useDefaultScript);
	ownSerializer.writeString(Attributes.SCRIPT, script);

	serializer.writeProperties(key, ownSerializer);
    }

    @Override
    protected final void deserialize(GraphicsPropertiesSerializer serializer, String key) {
	if (serializer == null) {
	    throw new IllegalArgumentException("Parameter 'serializer' must not be null.");
	}
	if (key == null) {
	    throw new IllegalArgumentException();
	}

	super.deserialize(serializer, key);
	GraphicsPropertiesSerializer ownSerializer;
	ownSerializer = new GraphicsPropertiesSerializer();
	serializer.readProperties(key, ownSerializer);

	imageFilePath = ownSerializer.readString(Attributes.IMAGE_FILE_PATH, Defaults.IMAGE_FILE_PATH);
	imageFilePath = ownSerializer.readString(Attributes.IMAGE_FILE_PATH, Defaults.IMAGE_FILE_PATH);
	targetFiles.clear();
	for (int i = 0; i < ConverterRegistry.MAX_TARGET_FILES; i++) {
	    TargetFile targetFile = new TargetFile(i);
	    GraphicsPropertiesSerializer innerSerializer;
	    innerSerializer = new GraphicsPropertiesSerializer();
	    ownSerializer.readProperties(Attributes.TARGET_FILES + "." + i, innerSerializer);
	    targetFile.setPath(innerSerializer.readString(Attributes.TARGET_FILE_PATH, Defaults.TARGET_FILE_PATH));
	    targetFiles.add(targetFile);
	}

	useDefaultScript = ownSerializer.readBoolean(Attributes.USE_DEFAULT_SCRIPT, Defaults.USE_DEFAULT_SCRIPT);
	script = ownSerializer.readString(Attributes.SCRIPT, Defaults.SCRIPT);

    }
}
