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

package com.wudsn.ide.asm.compiler;

import java.io.File;
import java.util.List;
import java.util.Locale;
import java.util.StringTokenizer;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.Hardware;
import com.wudsn.ide.asm.Texts;
import com.wudsn.ide.asm.compiler.syntax.CompilerSyntax;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;

/**
 * Definition of a compiler. The definition contains all static meta information
 * about the compiler. It is normally defined via an extension. The id of a
 * compiler must be unique across all compilers.
 * 
 * @author Peter Dell
 */
public final class CompilerDefinition implements Comparable<CompilerDefinition> {

    // Id
    private String id;
    private String name;
    private String className;

    // Installation and use.
    private String helpFilePaths;
    private String homePageURL;

    // Editing and source parsing.
    private List<CPU> supportedCPUs;
    private CompilerSyntax syntax;

    // Compiling.
    private String defaultParameters;

    // Assignment to default hardware type.
    private Hardware defaultHardware;

    /**
     * Creation is package local. Called by {@link CompilerRegistry} only.
     */
    CompilerDefinition() {

    }

    /**
     * Sets the id of the compiler. Called by {@link CompilerRegistry} only.
     * 
     * @param id
     *            The id of the compiler, not empty and not <code>null</code>.
     */
    final void setId(String id) {
	if (id == null) {
	    throw new IllegalArgumentException("Parameter 'id' must not be null.");
	}
	if (StringUtility.isEmpty(id)) {
	    throw new IllegalArgumentException("Parameter 'id' must not be empty.");
	}
	this.id = id;
    }

    /**
     * Gets the id of the compiler.
     * 
     * @return The id of the compiler, not empty and not <code>null</code>.
     */
    public final String getId() {
	if (id == null) {
	    throw new IllegalStateException("Field 'id' must not be null.");
	}
	return id;
    }

    /**
     * Sets the localized name of the compiler. Called by
     * {@link CompilerRegistry} only.
     * 
     * @param name
     *            The localized name of the compiler, not empty and not
     *            <code>null</code>.
     */
    final void setName(String name) {
	if (name == null) {
	    throw new IllegalArgumentException("Parameter 'name' must not be null.");
	}
	if (StringUtility.isEmpty(id)) {
	    throw new IllegalArgumentException("Parameter 'name' must not be empty.");
	}
	this.name = name;
    }

    /**
     * Gets the localized name of the compiler.
     * 
     * @return The localized name of the compiler, not empty and not
     *         <code>null</code>.
     */
    public final String getName() {
	if (name == null) {
	    throw new IllegalStateException("Field 'name' must not be null.");
	}
	return name;
    }

    /**
     * Sets the class name of the compiler. Called by {@link CompilerRegistry}
     * only.
     * 
     * @param className
     *            The class name of the compiler, not empty and not
     *            <code>null</code>.
     */
    final void setClassName(String className) {
	if (className == null) {
	    throw new IllegalArgumentException("Parameter 'className' must not be null.");
	}
	this.className = className;
    }

    /**
     * Gets the class name of the compiler.
     * 
     * @return The class name of the compiler, not empty and not
     *         <code>null</code>.
     */
    public final String getClassName() {
	if (className == null) {
	    throw new IllegalStateException("Field 'className' must not be null.");
	}
	return className;
    }

    /**
     * Sets the absolute URL of the home page where the compiler can be
     * downloaded. Called by {@link CompilerRegistry} only.
     * 
     * @param homePageURL
     *            The absolute URL of the home page where the compiler can be
     *            downloaded. May be empty or <code>null</code>.
     */
    final void setHomePageURL(String homePageURL) {
	if (homePageURL == null) {
	    homePageURL = "";
	}
	this.homePageURL = homePageURL;
    }

    /**
     * Gets the absolute URL of the home page where the compiler can be
     * downloaded.
     * 
     * @return The absolute URL of the home page where the compiler can be
     *         downloaded. The result may be empty or <code>null</code>.
     */
    public final String getHomePageURL() {
	if (homePageURL == null) {
	    homePageURL = "";
	}
	return homePageURL;
    }

    /**
     * Sets the help file paths to locate the help file for the compiler. Called
     * by {@link CompilerRegistry} only.
     * 
     * @param helpFilePaths
     *            The relative file path to locate the help file for the
     *            compiler based on the folder of the executable. ".", ".." and
     *            "/" may be used to specify the path. A path may end with a
     *            language in the form "(en)". Multiple paths are separated by
     *            ",". May be empty or <code>null</code>.
     */
    final void setHelpFilePaths(String helpFilePaths) {
	if (helpFilePaths == null) {
	    helpFilePaths = "";
	}
	this.helpFilePaths = helpFilePaths;
    }

    /**
     * Gets the help file paths to locate the help file for the compiler.
     * 
     * @return The relative file path to locate the help file for the compiler
     *         based on the folder of the executable. ".", ".." and "/" may be
     *         used to specify the path. A path may end with a language in the
     *         form "(en)".Multiple paths are separated by ",". The result may
     *         be empty, not <code>null</code>.
     */
    public final String getHelpFilePaths() {
	if (helpFilePaths == null) {
	    throw new IllegalStateException("Field 'helpFilePaths' must not be null.");
	}
	return helpFilePaths;
    }

    /**
     * Determines if this compiler offers a help file at all.
     * 
     * @return <code>true</code> if this compiler offers a help file,
     *         <code>false</code> otherwise.
     */
    public final boolean hasHelpFile() {
	return StringUtility.isSpecified(helpFilePaths);
    }

    /**
     * Gets the help file for the compiler. This includes locating the most
     * appropriate file in the file system based on the current locale.
     * 
     * @param compilerExecutablePath
     *            the compiler executable path, may be empty, not
     *            <code>null</code>.
     * @return The help file, or <code>null</code> not help file could be found.
     * 
     * @throws CoreException
     *             if the compilerExecutablePath is empty, the compiler does not
     *             specify a help path or no help file can be found.
     */
    public final File getHelpFile(String compilerExecutablePath) throws CoreException {
	if (compilerExecutablePath == null) {
	    throw new IllegalArgumentException("Parameter 'compilerExecutablePath' must not be null.");
	}
	if (StringUtility.isEmpty(compilerExecutablePath)) {
	    // ERROR: Help for the '{0}' compiler cannot be
	    // displayed because the path to the compiler executable
	    // is not set in the preferences.
	    throw new CoreException(new Status(IStatus.ERROR, AssemblerPlugin.ID, TextUtility.format(
		    Texts.MESSAGE_E130, name)));
	}
	if (!hasHelpFile()) {
	    // ERROR: The compiler '{0}' does not specify a help file path.
	    throw new CoreException(new Status(IStatus.ERROR, AssemblerPlugin.ID, TextUtility.format(
		    Texts.MESSAGE_E102, name)));
	}

	String localeLanguage = Locale.getDefault().getLanguage();
	File firstFile = null;
	File firstLanguageFile = null;
	StringTokenizer tokenizer = new StringTokenizer(helpFilePaths, ",");
	while (tokenizer.hasMoreTokens()) {
	    String helpFilePath = tokenizer.nextToken().trim();
	    String helpFileLanguage = "";
	    int index = helpFilePath.lastIndexOf("(");
	    if (index > 0) {
		helpFileLanguage = helpFilePath.substring(index + 1, index + 3);
		helpFilePath = helpFilePath.substring(0, index - 1).trim();
	    }
	    File file = FileUtility.getCanonicalFile(new File(new File(compilerExecutablePath).getParent(),
		    helpFilePath));
	    if (file.exists()) {
		if (firstFile == null) {
		    firstFile = file;
		}
		if (firstLanguageFile == null && helpFileLanguage.equals(localeLanguage)) {
		    firstLanguageFile = file;
		}
	    }
	}
	// Use language specific file if present, use first file otherwise.
	File result = firstLanguageFile;
	if (result == null) {
	    result = firstFile;
	}
	if (result == null) {
	    // ERROR: Help for the '{0}' compiler cannot be displayed because no
	    // help file was found in the paths '{1}' for the compiler
	    // executable path '{0}'.
	    throw new CoreException(new Status(IStatus.ERROR, AssemblerPlugin.ID, TextUtility.format(
		    Texts.MESSAGE_E131, name, helpFilePaths, compilerExecutablePath)));
	}
	return result;

    }

    /**
     * Sets the list of supported CPUs Called by {@link CompilerRegistry} only.
     * 
     * @param supportedCPUs
     *            The unmodifiable list of supported CPUs, not empty and not
     *            <code>null</code>.
     * @since 1.6.1
     */
    final void setSupportedCPUs(List<CPU> supportedCPUs) {
	if (supportedCPUs == null) {
	    throw new IllegalArgumentException("Parameter 'supportedCPUs' must not be null.");
	}
	if (supportedCPUs.isEmpty()) {
	    throw new IllegalArgumentException("Parameter 'supportedCPUs' must not be empty.");
	}
	this.supportedCPUs = supportedCPUs;
    }

    /**
     * Gets the unmodifiable list of CPUs supported by this compiler. The first
     * entry defines the default CPU.
     * 
     * @return The unmodifiable list of CPUs supported by this compiler, not
     *         empty and, not <code>null</code>.
     * 
     * @since 1.6.1
     */
    public final List<CPU> getSupportedCPUs() {
	if (supportedCPUs == null) {
	    throw new IllegalStateException("Field 'supportedCPUs' must not be null.");
	}
	return supportedCPUs;
    }

    /**
     * Sets the compiler syntax. Called by {@link CompilerRegistry} only.
     * 
     * @param syntax
     *            The compiler syntax, not <code>null</code>.
     */
    final void setSyntax(CompilerSyntax syntax) {
	if (syntax == null) {
	    throw new IllegalArgumentException("Parameter 'syntax' must not be null.");
	}
	this.syntax = syntax;
    }

    /**
     * Gets the compiler syntax.
     * 
     * @return The compiler syntax, not <code>null</code>.
     */
    public final CompilerSyntax getSyntax() {
	if (syntax == null) {
	    throw new IllegalStateException("Field 'syntax' must not be null.");
	}
	return syntax;
    }

    /**
     * Sets the compiler default parameters. Called by {@link CompilerRegistry}
     * only.
     * 
     * @param defaultParameters
     *            The compiler default parameters, not <code>null</code>.
     */
    final void setDefaultParameters(String defaultParameters) {
	if (defaultParameters == null) {
	    throw new IllegalArgumentException("Parameter 'defaultParameters' must not be null.");
	}
	this.defaultParameters = defaultParameters;
    }

    /**
     * Gets the compiler default parameters.
     * 
     * @return The compiler default parameters, not <code>null</code>.
     */
    public final String getDefaultParameters() {
	if (defaultParameters == null) {
	    throw new IllegalStateException("Field 'defaultParameters' must not be null.");
	}
	return defaultParameters;
    }

    /**
     * Sets the default hardware to be assumed for this compiler. Called by
     * {@link CompilerRegistry} only.
     * 
     * @param hardware
     *            The default hardware, not <code>null</code>.
     */
    final void setDefaultHardware(Hardware hardware) {
	if (hardware == null) {
	    throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
	}
	this.defaultHardware = hardware;
    }

    /**
     * Gets the default hardware for this compiler.
     * 
     * @return The default hardwares, not <code>null</code>.
     */
    public final Hardware getDefaultHardware() {
	if (defaultHardware == null) {
	    throw new IllegalStateException("Field 'defaultHardware' must not be null.");
	}
	return defaultHardware;
    }

    /**
     * See {@link Comparable}.
     */
    @Override
    public int compareTo(CompilerDefinition o) {
	if (o == null) {
	    throw new IllegalArgumentException("Parameter 'o' must not be null.");
	}
	if (id == null || o.id == null) {
	    if (id == null) {
		throw new IllegalStateException("Field 'id' must not be null for this or for argument.");
	    }
	}
	return id.compareTo(o.id);
    }

    @Override
    public String toString() {
	return id;
    }

}
