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
import java.util.Collections;
import java.util.List;
import java.util.StringTokenizer;

import com.wudsn.ide.gfx.model.Aspect;

/**
 * Definition of a converter. The definition contains all static meta
 * information about the converter. It is normally defined via an extension.
 * 
 * 
 * For launching application under MacOS see
 * https://bugs.eclipse.org/bugs/show_bug.cgi?id=82155 and
 * http://www.coderanch.com/t/111494/Mac-OS/launching-Safari-from-Java-App.
 * 
 * @author Peter Dell
 */
public final class ConverterDefinition implements Comparable<ConverterDefinition> {

	// Id
	private String id;
	private String name;
	private List<String> sourceFileExtensions;
	private int targetImagePaletteSize;
	private Aspect targetImageDisplayAspect;

	private List<ConverterSourceFileDefinition> sourceFileDefinitions;
	private List<ConverterTargetFileDefinition> targetFileDefinitions;

	/**
	 * Creates an instance. Called by {@link ConverterRegistry} only.
	 */
	ConverterDefinition() {
		sourceFileExtensions = new ArrayList<String>(1);
		sourceFileDefinitions = new ArrayList<ConverterSourceFileDefinition>();
		targetFileDefinitions = new ArrayList<ConverterTargetFileDefinition>();

	}

	/**
	 * Sets the id of the converter. Called by {@link ConverterRegistry} only.
	 * 
	 * @param id The id of the converter, not empty and not <code>null</code>.
	 */
	final void setId(String id) {
		if (id == null) {
			throw new IllegalArgumentException("Parameter 'id' must not be null.");
		}
		this.id = id;
	}

	/**
	 * Gets the id of the converter.
	 * 
	 * @return The id of the converter, not empty and not <code>null</code>.
	 */
	public final String getId() {
		if (id == null) {
			throw new IllegalStateException("Field 'id' must not be null.");
		}
		return id;
	}

	/**
	 * Sets the name of the converter. Called by {@link ConverterRegistry} only.
	 * 
	 * @param name The name of the converter, not empty and not <code>null</code> .
	 */
	final void setName(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		this.name = name;
	}

	/**
	 * Gets the name of the converter.
	 * 
	 * @return The name of the converter, not empty and not <code>null</code>.
	 */
	public final String getName() {
		if (name == null) {
			throw new IllegalStateException("Field 'name' must not be null.");
		}
		return name;
	}

	/**
	 * Sets the supported source file extensions the converter. Called by
	 * {@link ConverterRegistry} only.
	 * 
	 * @param sourceFileExtensions The comma separated list of source file
	 *                             extensions in lower case characters, may be empty
	 *                             or <code>null</code>.
	 * 
	 * @since 1.6.0
	 */
	final void setSourceFileExtensions(String sourceFileExtensions) {
		if (sourceFileExtensions == null) {
			sourceFileExtensions = "";
		}
		StringTokenizer st = new StringTokenizer(sourceFileExtensions, ",");
		while (st.hasMoreTokens()) {
			this.sourceFileExtensions.add(st.nextToken().trim());
		}
	}

	/**
	 * Determines if a given file extension is supported.
	 * 
	 * @param fileExtension The file extension in lower case letters, may be empty,
	 *                      not <code>null</code>.
	 * @return <code>true</code> if the file extension is supported,
	 *         <code>false</code> otherwise.
	 * 
	 * @since V1.6.0
	 */
	public final boolean isSourceFileExtensionSupported(String fileExtension) {
		if (fileExtension == null) {
			throw new IllegalArgumentException("Parameter 'fileExtension' must not be null.");
		}

		return sourceFileExtensions.contains(fileExtension);
	}

	/**
	 * Sets the palette size of the converter. Called by {@link ConverterRegistry}
	 * only.
	 * 
	 * @param targetImagePaletteSize The palette size of the converter, a positive
	 *                               number if a palette is used, 0 for a direct
	 *                               palette.
	 */
	final void setTargetImagePaletteSize(int targetImagePaletteSize) {
		if (targetImagePaletteSize < 0) {
			throw new IllegalArgumentException(
					"Parameter 'targetImagePaletteSize' must not be negative. Specified value is "
							+ targetImagePaletteSize + ".");
		}
		this.targetImagePaletteSize = targetImagePaletteSize;
	}

	/**
	 * Gets the palette size of the target image.
	 * 
	 * @return The palette size of the target image, a positive number if a palette
	 *         is used, 0 for direct palette.
	 */
	public final int getTargetImagePaletteSize() {
		if (targetImagePaletteSize < 0) {
			throw new IllegalStateException("Field 'targetImagePaletteSize' must not be negative. Specified value is "
					+ targetImagePaletteSize + ".");
		}
		return targetImagePaletteSize;
	}

	/**
	 * Sets the zoom factor of the target image.
	 * 
	 * @param targetImageDisplayAspect The target image zoom factor, not
	 *                                 <code>null</code>.
	 */
	final void setTargetImageDisplayAspect(Aspect targetImageDisplayAspect) {
		if (targetImageDisplayAspect == null) {
			throw new IllegalArgumentException("Parameter 'targetImageDisplayAspect' must not be null.");
		}
		if (!targetImageDisplayAspect.isValid()) {
			throw new IllegalArgumentException("Parameter 'targetImageDisplayAspect' must not be invalid.");
		}
		this.targetImageDisplayAspect = targetImageDisplayAspect;
	}

	/**
	 * Gets the zoom factor of the target image.
	 * 
	 * @return The zoom factor of the target image.
	 */
	public final Aspect getTargetImageDisplayAspect() {
		if (targetImageDisplayAspect == null) {
			throw new IllegalStateException("Field 'targetImageDisplayAspect' must not be empty.");
		}
		return targetImageDisplayAspect;
	}

	/**
	 * Adds a source file definition. Called by {@link ConverterRegistry} only.
	 * 
	 * @param sourceFileDefinition The source file definition, not
	 *                             <code>null</code>.
	 */
	final void addSourceFileDefinition(ConverterSourceFileDefinition sourceFileDefinition) {
		if (sourceFileDefinition == null) {
			throw new IllegalArgumentException("Parameter 'sourceFileDefinition' must not be null.");
		}
		sourceFileDefinitions.add(sourceFileDefinition);
	}

	/**
	 * Gets the unmodifiable list of source file definitions.
	 * 
	 * @return The unmodifiable list of source file definitions, may be empty, not
	 *         <code>null</code>.
	 */
	public final List<ConverterSourceFileDefinition> getSourceFileDefinitions() {
		return Collections.unmodifiableList(sourceFileDefinitions);
	}

	/**
	 * Adds a target file definition. Called by {@link ConverterRegistry} only.
	 * 
	 * @param targetFileDefinition The target file definition, not
	 *                             <code>null</code>.
	 */
	final void addTargetFileDefinition(ConverterTargetFileDefinition targetFileDefinition) {
		if (targetFileDefinition == null) {
			throw new IllegalArgumentException("Parameter 'targetFileDefinition' must not be null.");
		}
		targetFileDefinitions.add(targetFileDefinition);
	}

	/**
	 * Gets the unmodifiable list of target file definitions.
	 * 
	 * @return The unmodifiable list of target file definitions, may be empty, not
	 *         <code>null</code>.
	 */
	public final List<ConverterTargetFileDefinition> getTargetFileDefinitions() {

		return Collections.unmodifiableList(targetFileDefinitions);
	}

	@Override
	public final int compareTo(ConverterDefinition o) {
		if (o == null) {
			throw new IllegalArgumentException("Parameter 'o' must not be null.");
		}
		if (name == null || o.name == null) {
			if (name == null) {
				throw new IllegalStateException("Field 'name' must not be null for this or for argument.");
			}
		}
		return name.compareTo(o.name);
	}

}
