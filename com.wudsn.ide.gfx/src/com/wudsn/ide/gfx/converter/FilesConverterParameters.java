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

package com.wudsn.ide.gfx.converter;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.eclipse.swt.graphics.RGB;

import com.wudsn.ide.gfx.GraphicsPlugin;
import com.wudsn.ide.gfx.model.ConverterDirection;
import com.wudsn.ide.gfx.model.GraphicsPropertiesSerializer;
import com.wudsn.ide.gfx.model.Palette;
import com.wudsn.ide.gfx.model.PaletteType;

public final class FilesConverterParameters extends ConverterCommonParameters {

	/**
	 * Names of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	public static final class Attributes {

		/**
		 * Creation is private.
		 */
		private Attributes() {
		}

		public static final String SOURCE_FILES = "sourceFiles";
		public static final String SOURCE_FILE_PATH = "path";
		public static final String SOURCE_FILE_OFFSET = "offset";
		public static final String IMAGE_FILE_PATH = "imageFilePath";

		public static final String COLUMNS = "columns";
		public static final String ROWS = "rows";

		public static final String SPACING_COLOR = "spacingColor";
		public static final String SPACING_WIDTH = "spacingWidth";

		public static final String PIXEL_TYPE = "pixelType";
		public static final String PALETTE = "palette";
		public static final String PALETTE_TYPE = "paletteType";
		public static final String PALETTE_COLORS = "paletteRGBs";
	}

	/**
	 * Defaults of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	private static final class Defaults {

		/**
		 * Creation is private.
		 */
		private Defaults() {
		}

		public static final String SOURCE_FILE_PATH = "";
		public static final int SOURCE_FILE_OFFSET = 0;
		public static final String IMAGE_FILE_PATH = "";

		public static final int COLUMNS = 40;
		public static final int ROWS = 24;

		public static final RGB SPACING_COLOR = new RGB(0, 0, 128);
		public static final int SPACING_WIDTH = 0;

		public static final PaletteType PALETTE_TYPE = PaletteType.ATARI_DEFAULT;
		public static final Palette PALETTE = Palette.HIRES_1;
		public static final RGB[] PALETTE_COLORS = new RGB[0];
	}

	/**
	 * Message ids of the attributes.
	 * 
	 * @author Peter Dell
	 * 
	 */
	public static final class MessageIds {

		/**
		 * Creation is private.
		 */
		private MessageIds() {
		}

		public static final int SOURCE_FILE_PATH = 1010;
		public static final int SOURCE_FILE_OFFSET = 1020;
		public static final int IMAGE_FILE_PATH = 1030;

		public static final int SPACING_COLOR = 1100;
		public static final int SPACING_WIDTH = 1101;
		public static final int COLUMNS = 1102;
		public static final int ROWS = 1103;

	}

	/**
	 * A source file.
	 * 
	 * @author Peter Dell
	 * 
	 */
	public static final class SourceFile {
		private int id;
		private String path;
		private int offset;

		public SourceFile(int id) {
			this.id = id;
			path = Defaults.SOURCE_FILE_PATH;
			offset = Defaults.SOURCE_FILE_OFFSET;
		}

		public int getId() {
			return id;
		}

		public int getPathMessageId() {
			return MessageIds.SOURCE_FILE_PATH + id;
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
			return MessageIds.SOURCE_FILE_OFFSET + id;
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
			SourceFile other = (SourceFile) obj;
			return other.id == this.id && other.path.equals(this.path) && other.offset == this.offset;
		}

		@Override
		public int hashCode() {
			return id + 7 * path.hashCode() + 17 * offset;
		}

	}

	private int sourceFilesSize;
	private List<SourceFile> sourceFiles;
	private String imageFilePath;

	private int columns;
	private int rows;

	private RGB spacingColor;
	private int spacingWidth;

	private PaletteType paletteType;
	private Palette palette;
	private RGB[] paletteRGBs;

	FilesConverterParameters() {

		int size = ConverterRegistry.MAX_SOURCE_FILES;
		this.sourceFiles = new ArrayList<SourceFile>(size);
		for (int i = 0; i < size; i++) {
			this.sourceFiles.add(new SourceFile(i));
		}
		setDefaults();
	}

	@Override
	public void setDefaults() {
		super.setDefaults();

		for (SourceFile sourceFile : sourceFiles) {
			sourceFile.setPath(Defaults.SOURCE_FILE_PATH);
			sourceFile.setOffset(Defaults.SOURCE_FILE_OFFSET);
		}
		imageFilePath = Defaults.IMAGE_FILE_PATH;

		columns = Defaults.COLUMNS;
		rows = Defaults.ROWS;
		spacingColor = Defaults.SPACING_COLOR;
		spacingWidth = Defaults.SPACING_WIDTH;

		paletteType = Defaults.PALETTE_TYPE;
		palette = Defaults.PALETTE;
		paletteRGBs = Defaults.PALETTE_COLORS;
	}

	@Override
	public void setConverterId(String value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.converterId = value;

		ConverterDefinition converterDefinition;
		converterDefinition = GraphicsPlugin.getInstance().getConverterRegistry().getDefinition(converterId,
				ConverterDirection.FILES_TO_IMAGE);
		if (converterDefinition != null) {
			sourceFilesSize = converterDefinition.getSourceFileDefinitions().size();
		} else {
			sourceFilesSize = 0;
		}
	}

	public void setDefaultSourceFilePath(String sourceFilePath) {
		if (sourceFilePath == null) {
			throw new IllegalArgumentException("Parameter 'sourceFilePath' must not be null.");
		}
		for (int i = 0; i < sourceFiles.size(); i++) {
			SourceFile sourceFile = sourceFiles.get(i);
			sourceFile.setPath(sourceFilePath);
			sourceFile.setOffset(0);
		}
	}

	public int getSourceFilesSize() {
		return sourceFilesSize;
	}

	public SourceFile getSourceFile(int sourceFileId) {
		return sourceFiles.get(sourceFileId);
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

	public void setColumns(int value) {
		this.columns = value;
	}

	public int getColumns() {
		return columns;
	}

	public void setRows(int value) {
		this.rows = value;
	}

	public int getRows() {
		return rows;
	}

	/**
	 * Sets the spacing color.
	 * 
	 * @param value The spacing color or <code>null</code> to set the default value.
	 */
	public void setSpacingColor(RGB value) {
		if (value == null) {
			value = Defaults.SPACING_COLOR;
		}
		this.spacingColor = value;
	}

	/**
	 * Gets the spacing color.
	 * 
	 * @return The spacing color, not <code>null</code>.
	 */
	public RGB getSpacingColor() {
		if (spacingColor == null) {
			throw new IllegalStateException("Spacing color must not be null");
		}
		return spacingColor;
	}

	public void setSpacingWidth(int value) {
		this.spacingWidth = value;
	}

	public int getSpacingWidth() {
		return spacingWidth;
	}

	public void setPaletteType(PaletteType value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.paletteType = value;
	}

	public PaletteType getPaletteType() {
		return paletteType;
	}

	public void setPalette(Palette value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.palette = value;
	}

	public void setPaletteManual() {
		switch (palette) {
		case TRUE_COLOR:
			palette = Palette.TRUE_COLOR;
			break;
		case HIRES_1:
		case HIRES_2:
		case HIRES_MANUAL:
			palette = Palette.HIRES_MANUAL;
			break;
		case MULTI_1:
		case MULTI_2:
		case MULTI_3:
		case MULTI_4:
		case MULTI_5:
		case MULTI_6:
		case MULTI_MANUAL:
			palette = Palette.MULTI_MANUAL;
			break;
		case GTIA_GREY_1:
		case GTIA_GREY_2:
		case GTIA_GREY_MANUAL:
			palette = Palette.GTIA_GREY_MANUAL;
			break;
		}
	}

	public Palette getPalette() {
		return palette;
	}

	/**
	 * Sets the array of palette RGBs. Note that the values is kept as a reference.
	 * 
	 * @param value The array of palette RGBs, may be empty, not <code>null</code> .
	 */
	public void setPaletteRGBs(RGB[] value) {
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		this.paletteRGBs = value;

	}

	/**
	 * Gets the array of palette RGBs. Note that the returned values is a reference.
	 * 
	 * @return The array of palette RGBs, may be empty, not <code>null</code>.
	 */
	public RGB[] getPaletteRGBs() {
		return paletteRGBs;
	}

	protected final void copyTo(FilesConverterParameters target) {
		if (target == null) {
			throw new IllegalArgumentException("Parameter 'target' must not be null.");
		}
		super.copyTo(target);

		target.sourceFiles.clear();
		for (SourceFile sourceFile : sourceFiles) {
			SourceFile targetSourceFile;
			targetSourceFile = new SourceFile(sourceFile.getId());
			targetSourceFile.setPath(sourceFile.getPath());
			targetSourceFile.setOffset(sourceFile.getOffset());
			target.sourceFiles.add(targetSourceFile);
		}
		target.setImageFilePath(imageFilePath);

		target.setRows(rows);
		target.setColumns(columns);
		target.setSpacingColor(spacingColor);
		target.setSpacingWidth(spacingWidth);

		target.setPaletteType(paletteType);
		target.setPalette(palette);
		target.setPaletteRGBs(paletteRGBs);
	}

	protected final boolean equals(FilesConverterParameters target) {
		if (target == null) {
			throw new IllegalArgumentException("Parameter 'target' must not be null.");
		}
		boolean result;
		result = super.equals(target);
		result = result && target.sourceFiles.equals(sourceFiles);
		result = result && target.getImageFilePath().equals(imageFilePath);
		result = result && target.getRows() == rows;
		result = result && target.getColumns() == columns;
		result = result && target.getSpacingColor().equals(spacingColor);
		result = result && target.getSpacingWidth() == spacingWidth;

		result = result && target.getPaletteType().equals(paletteType);
		result = result && target.getPalette().equals(palette);
		result = result && Arrays.equals(target.getPaletteRGBs(), paletteRGBs);
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

		ownSerializer.writeInteger(Attributes.SOURCE_FILES, sourceFilesSize);
		for (int i = 0; i < sourceFilesSize; i++) {
			SourceFile sourceFile = sourceFiles.get(i);
			GraphicsPropertiesSerializer innerSeralizer;
			innerSeralizer = new GraphicsPropertiesSerializer();
			innerSeralizer.writeString(Attributes.SOURCE_FILE_PATH, sourceFile.getPath());
			innerSeralizer.writeInteger(Attributes.SOURCE_FILE_OFFSET, sourceFile.getOffset());
			ownSerializer.writeProperties(Attributes.SOURCE_FILES + "." + i, innerSeralizer);
		}

		ownSerializer.writeString(Attributes.IMAGE_FILE_PATH, imageFilePath);

		ownSerializer.writeInteger(Attributes.COLUMNS, columns);
		ownSerializer.writeInteger(Attributes.ROWS, rows);

		ownSerializer.writeRGB(Attributes.SPACING_COLOR, spacingColor);
		ownSerializer.writeInteger(Attributes.SPACING_WIDTH, spacingWidth);

		ownSerializer.writeEnum(Attributes.PALETTE, palette);
		ownSerializer.writeEnum(Attributes.PALETTE_TYPE, paletteType);
		ownSerializer.writeRGBArray(Attributes.PALETTE_COLORS, paletteRGBs);

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

		sourceFiles.clear();
		for (int i = 0; i < ConverterRegistry.MAX_SOURCE_FILES; i++) {
			SourceFile sourceFile = new SourceFile(i);
			GraphicsPropertiesSerializer innerSerializer;
			innerSerializer = new GraphicsPropertiesSerializer();
			ownSerializer.readProperties(Attributes.SOURCE_FILES + "." + i, innerSerializer);
			sourceFile.setPath(innerSerializer.readString(Attributes.SOURCE_FILE_PATH, Defaults.SOURCE_FILE_PATH));
			sourceFile
					.setOffset(innerSerializer.readInteger(Attributes.SOURCE_FILE_OFFSET, Defaults.SOURCE_FILE_OFFSET));
			sourceFiles.add(sourceFile);
		}

		imageFilePath = ownSerializer.readString(Attributes.IMAGE_FILE_PATH, Defaults.IMAGE_FILE_PATH);

		columns = ownSerializer.readInteger(Attributes.COLUMNS, Defaults.COLUMNS);
		rows = ownSerializer.readInteger(Attributes.ROWS, Defaults.ROWS);

		spacingColor = ownSerializer.readRGB(Attributes.SPACING_COLOR, Defaults.SPACING_COLOR);
		spacingWidth = ownSerializer.readInteger(Attributes.SPACING_WIDTH, Defaults.SPACING_WIDTH);

		palette = ownSerializer.readEnum(Attributes.PALETTE, Defaults.PALETTE, Palette.class);
		paletteType = ownSerializer.readEnum(Attributes.PALETTE_TYPE, Defaults.PALETTE_TYPE, PaletteType.class);
		paletteRGBs = ownSerializer.readRGBArray(Attributes.PALETTE_COLORS, Defaults.PALETTE_COLORS);
	}
}
