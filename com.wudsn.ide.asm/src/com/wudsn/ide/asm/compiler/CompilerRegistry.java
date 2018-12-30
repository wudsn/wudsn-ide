/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

package com.wudsn.ide.asm.compiler;

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

import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.Hardware;
import com.wudsn.ide.asm.compiler.syntax.CompilerSyntax;

/**
 * Registry for compilers, based on the extension points
 * {@value CompilerRegistry#COMPILERS}.
 * 
 * @author Peter Dell
 * 
 */
public final class CompilerRegistry {

    /**
     * The id of the extension point which provides the compilers.
     */
    private static final String COMPILERS = "com.wudsn.ide.asm.compilers";

    /**
     * The registered compiler definition.
     */
    private List<CompilerDefinition> compilerDefinitionList;

    /**
     * The cached map of compiler instances.
     */
    private Map<String, Compiler> compilerMap;

    /**
     * Creation is public.
     */
    public CompilerRegistry() {
	compilerDefinitionList = Collections.emptyList();
	compilerMap = Collections.emptyMap();

    }

    /**
     * Initializes the list of available compilers.
     */
    public void init() {

	compilerDefinitionList = new ArrayList<CompilerDefinition>();
	compilerMap = new TreeMap<String, Compiler>();

	IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
	IExtensionPoint extensionPoint = extensionRegistry
		.getExtensionPoint(COMPILERS);
	if (extensionPoint == null) {
	    throw new IllegalStateException("Extension point '" + COMPILERS
		    + "' is not defined.");
	}

	IExtension[] extensions = extensionPoint.getExtensions();

	for (IExtension extension : extensions) {
	    IConfigurationElement[] configurationElements = extension
		    .getConfigurationElements();
	    for (IConfigurationElement configurationElement : configurationElements) {

		try {
		    CompilerDefinition compilerDefinition;
		    compilerDefinition = new CompilerDefinition();
		    compilerDefinition.setId(configurationElement
			    .getAttribute("id"));
		    compilerDefinition.setName(configurationElement
			    .getAttribute("name"));
		    compilerDefinition.setClassName(configurationElement
			    .getAttribute("class"));
		    compilerDefinition.setHelpFilePaths(configurationElement
			    .getAttribute("helpFilePaths"));
		    compilerDefinition.setHomePageURL(configurationElement
			    .getAttribute("homePageURL"));
		    compilerDefinition
			    .setDefaultParameters(configurationElement
				    .getAttribute("defaultParameters"));

		    configurationElement.getChildren("supportedCPU");
		    IConfigurationElement[] supportedCPUArray;
		    supportedCPUArray = configurationElement
			    .getChildren("supportedCPU");
		    List<CPU> supportedCPUs = new ArrayList<CPU>(
			    supportedCPUArray.length);
		    for (IConfigurationElement supportedCPU : supportedCPUArray) {
			supportedCPUs.add(CPU.valueOf(supportedCPU
				.getAttribute("cpu")));
		    }
		    supportedCPUs = Collections.unmodifiableList(supportedCPUs);
		    compilerDefinition.setSupportedCPUs(supportedCPUs);
		    compilerDefinition.setDefaultHardware(Hardware
			    .valueOf(configurationElement
				    .getAttribute("defaultHardware")));

		    compilerDefinitionList.add(compilerDefinition);

		    addCompiler(configurationElement, compilerDefinition);
		} catch (RuntimeException ex) {
		    throw new RuntimeException(
			    "Error during registration of compiler '"
				    + configurationElement.getAttribute("id")
				    + "'.", ex);
		}
	    }
	}

	compilerDefinitionList = new ArrayList<CompilerDefinition>(
		compilerDefinitionList);
	Collections.sort(compilerDefinitionList);
	compilerDefinitionList = Collections
		.unmodifiableList(compilerDefinitionList);
	compilerMap = Collections.unmodifiableMap(compilerMap);
    }

    /**
     * Adds a new compiler.
     * 
     * @param configurationElement
     *            The configuration element used as class instance factory, not
     *            <code>null</code>.
     * 
     * @param compilerDefinition
     *            The compiler definition, not <code>null</code>.
     */
    private void addCompiler(IConfigurationElement configurationElement,
	    CompilerDefinition compilerDefinition) {
	if (configurationElement == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'configurationElement' must not be null.");
	}
	if (compilerDefinition == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'compilerDefinition' must not be null.");
	}

	String id = compilerDefinition.getId();
	Compiler compiler;
	try {
	    // The class loading must be delegated to the framework.
	    compiler = (Compiler) configurationElement
		    .createExecutableExtension("class");
	} catch (CoreException ex) {
	    throw new RuntimeException(
		    "Cannot create compiler instance for id '" + id + "'.", ex);
	}

	// Build the list of common and specific syntax definition files.
	List<Class<?>> compilerClasses = new ArrayList<Class<?>>(2);
	compilerClasses.add(compiler.getClass());
	compilerClasses.add(Compiler.class);

	CompilerSyntax syntax;
	syntax = new CompilerSyntax(id);

	syntax.loadXMLData(compilerClasses);

	compilerDefinition.setSyntax(syntax);

	compiler.setDefinition(compilerDefinition);

	compiler = compilerMap.put(id, compiler);
	if (compiler != null) {
	    throw new RuntimeException("Compiler id '" + id
		    + "' is already registered to class '"
		    + compiler.getClass().getName() + "'.");
	}

    }

    /**
     * Gets the unmodifiable list of compiler definitions, sorted by their id.
     * 
     * 
     * @return The unmodifiable list of compiler definitions, sorted by their
     *         id, may be empty, not <code>null</code>
     * 
     * @since 1.6.1
     */
    public List<CompilerDefinition> getCompilerDefinitions() {
	return compilerDefinitionList;
    }

    /**
     * Gets the compiler for a given id. Instances of compiler are stateless
     * singletons within the plugin.
     * 
     * @param compilerId
     *            The compiler id, not <code>null</code>.
     * 
     * @return The compiler, not <code>null</code>.
     */
    public Compiler getCompiler(String compilerId) {
	if (compilerId == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'compilerId' must not be null.");
	}
	Compiler result;
	synchronized (compilerMap) {

	    result = compilerMap.get(compilerId);
	}
	if (result == null) {

	    throw new IllegalArgumentException("Unknown compiler id '"
		    + compilerId + "'.");
	}

	return result;
    }

}
