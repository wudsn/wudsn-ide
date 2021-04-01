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
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IConfigurationElement;
import org.eclipse.core.runtime.IExtension;
import org.eclipse.core.runtime.IExtensionPoint;
import org.eclipse.core.runtime.IExtensionRegistry;
import org.eclipse.core.runtime.Platform;

import com.wudsn.ide.gfx.model.AspectUtility;
import com.wudsn.ide.gfx.model.ConverterDirection;

/**
 * Registry for converters, based on the extension points
 * {@value ConverterRegistry#CONVERTERS}.
 * 
 * @author Peter Dell
 * 
 */
public final class ConverterRegistry {

    /**
     * The id of the extension point which provides the converters.
     */
    private static final String CONVERTERS = "com.wudsn.ide.gfx.converters";

    /**
     * Maximum number of source files.
     */
    public static final int MAX_SOURCE_FILES = 10;

    /**
     * Maximum number of target files.
     */
    public static final int MAX_TARGET_FILES = 10;

    /**
     * The registered converter definitions.
     */
    private List<ConverterDefinition> filesToImageConverterDefinitionList;
    private List<ConverterDefinition> imageToFilesConverterDefinitionList;

    /**
     * The cached map of converter instances.
     */
    private Map<String, Converter> converterMap;

    /**
     * Creation is public.
     */
    public ConverterRegistry() {
	filesToImageConverterDefinitionList = Collections.emptyList();
	imageToFilesConverterDefinitionList = Collections.emptyList();
	converterMap = Collections.emptyMap();

    }

    /**
     * Initializes the list of available converters.
     */
    public void init() {

	filesToImageConverterDefinitionList = new ArrayList<ConverterDefinition>();
	imageToFilesConverterDefinitionList = new ArrayList<ConverterDefinition>();
	converterMap = new TreeMap<String, Converter>();

	IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
	IExtensionPoint extensionPoint = extensionRegistry.getExtensionPoint(CONVERTERS);
	if (extensionPoint == null) {
	    throw new IllegalStateException("Extension point '" + CONVERTERS + "' is not defined.");
	}

	IExtension[] extensions = extensionPoint.getExtensions();

	for (IExtension extension : extensions) {
	    IConfigurationElement[] converterGroupElements = extension.getConfigurationElements();
	    for (IConfigurationElement converterGroupElement : converterGroupElements) {
		IConfigurationElement[] converterElements = converterGroupElement.getChildren("converter");
		for (IConfigurationElement converterElement : converterElements) {

		    ConverterDefinition converterDefinition;
		    converterDefinition = new ConverterDefinition();
		    converterDefinition.setId(converterElement.getAttribute("id"));
		    converterDefinition.setName(converterElement.getAttribute("name"));
		    converterDefinition.setSourceFileExtensions(converterElement.getAttribute("sourceFileExtensions"));
		    converterDefinition.setTargetImagePaletteSize(Integer.parseInt(converterElement
			    .getAttribute("targetImagePaletteSize")));
		    converterDefinition.setTargetImageDisplayAspect(AspectUtility.fromString(converterElement
			    .getAttribute("targetImageDisplayAspect")));
		    IConfigurationElement[] sourceFileElements = converterElement.getChildren("sourceFile");
		    int i = 0;
		    for (IConfigurationElement sourceFileElement : sourceFileElements) {
			ConverterSourceFileDefinition sourceFileDefinition;
			sourceFileDefinition = new ConverterSourceFileDefinition();
			sourceFileDefinition.setSourceFileId(i);
			sourceFileDefinition.setLabel(sourceFileElement.getAttribute("label"));
			converterDefinition.addSourceFileDefinition(sourceFileDefinition);
			i++;
		    }

		    IConfigurationElement[] targetFileElements = converterElement.getChildren("targetFile");
		    i = 0;
		    for (IConfigurationElement targetFileElement : targetFileElements) {
			ConverterTargetFileDefinition targetFileDefinition;
			targetFileDefinition = new ConverterTargetFileDefinition();
			targetFileDefinition.setSourceFileId(i);
			targetFileDefinition.setLabel(targetFileElement.getAttribute("label"));
			converterDefinition.addTargetFileDefinition(targetFileDefinition);
			i++;
		    }

		    // If there is a source file, it is a files to image
		    // converter.
		    if (!converterDefinition.getSourceFileDefinitions().isEmpty()) {
			filesToImageConverterDefinitionList.add(converterDefinition);

		    }
		    // If there is a target file, it is a files to image
		    // converter.
		    if (!converterDefinition.getTargetFileDefinitions().isEmpty()) {
			imageToFilesConverterDefinitionList.add(converterDefinition);

		    }
		    addConverter(converterElement, converterDefinition);
		}
	    }
	}

	// Create a sorted, unmodifiable copy.
	filesToImageConverterDefinitionList = new ArrayList<ConverterDefinition>(filesToImageConverterDefinitionList);
	Collections.sort(filesToImageConverterDefinitionList);
	filesToImageConverterDefinitionList = Collections.unmodifiableList(filesToImageConverterDefinitionList);

	// Create a sorted, unmodifiable copy.
	imageToFilesConverterDefinitionList = new ArrayList<ConverterDefinition>(imageToFilesConverterDefinitionList);
	Collections.sort(imageToFilesConverterDefinitionList);
	imageToFilesConverterDefinitionList = Collections.unmodifiableList(imageToFilesConverterDefinitionList);

	// Create an unmodifiable copy.
	converterMap = Collections.unmodifiableMap(converterMap);
    }

    /**
     * Adds a new converter.
     * 
     * @param configurationElement
     *            The configuration element used as class instance factory, not
     *            <code>null</code>.
     * 
     * @param converterDefinition
     *            The converter definition, not <code>null</code>.
     */
    private void addConverter(IConfigurationElement configurationElement, ConverterDefinition converterDefinition) {
	if (configurationElement == null) {
	    throw new IllegalArgumentException("Parameter 'configurationElement' must not be null.");
	}
	if (converterDefinition == null) {
	    throw new IllegalArgumentException("Parameter 'converterDefinition' must not be null.");
	}

	String id = converterDefinition.getId();
	Converter converter;
	try {
	    converter = (Converter) configurationElement.createExecutableExtension("id");
	} catch (CoreException ex) {
	    throw new RuntimeException("Cannot instantiate converter '" + id + "'.", ex);
	}
	converter.setDefinition(converterDefinition);
	converter = converterMap.put(id, converter);
	if (converter != null) {
	    throw new RuntimeException("Converter id '" + id + "' is already registered to class '"
		    + converter.getClass().getName() + "'.");
	}

    }

    /**
     * Gets the unmodifiable list of converter definitions, sorted by their id.
     * 
     * @param converterDirection
     *            The converter direction, not <code>null</code>.
     * 
     * @return The unmodifiable list of converter definitions, sorted by their
     *         id, not empty and not <code>null</code>.
     */
    public List<ConverterDefinition> getDefinitions(ConverterDirection converterDirection) {
	if (converterDirection == null) {
	    throw new IllegalArgumentException("Parameter 'converterDirection' must not be null.");
	}
	switch (converterDirection) {
	case FILES_TO_IMAGE:
	    return filesToImageConverterDefinitionList;
	case IMAGE_TO_FILES:
	    return imageToFilesConverterDefinitionList;
	default:
	    throw new IllegalArgumentException("Unknown converter directtion " + converterDirection + ".");
	}
    }

    /**
     * Gets the converter definition for an id.
     * 
     * @param converterId
     *            The converter id, may be empty, not <code>null</code>.
     * @param converterDirection
     *            The direction of the converter, not <code>null</code>.
     * 
     * @return The converter definition or <code>null</code>.
     */
    public ConverterDefinition getDefinition(String converterId, ConverterDirection converterDirection) {
	if (converterId == null) {
	    throw new IllegalArgumentException("Parameter 'converterId' must not be null.");
	}
	List<ConverterDefinition> converterDefinitionList = getDefinitions(converterDirection);
	for (ConverterDefinition converterDefinition : converterDefinitionList) {
	    if (converterDefinition.getId().equals(converterId)) {
		return converterDefinition;
	    }
	}
	return null;
    }

    /**
     * Gets the converter for a given id. Instances of {@link Converter} are
     * stateless singletons within the plugin.
     * 
     * @param converterId
     *            The converter id, not <code>null</code>.
     * 
     * @return The converter or <code>null</code>.
     */
    public Converter getConverter(String converterId) {
	if (converterId == null) {
	    throw new IllegalArgumentException("Parameter 'converterId' must not be null.");
	}
	Converter result;
	synchronized (converterMap) {

	    result = converterMap.get(converterId);
	}

	return result;
    }
}
