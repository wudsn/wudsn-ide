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

package com.wudsn.ide.lng.compiler;

import java.util.List;
import java.util.Locale;

import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.Status;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.LanguageUtility;
import com.wudsn.ide.lng.Target;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerHelp.InstalledHelpDocument;
import com.wudsn.ide.lng.compiler.CompilerPaths.CompilerPath;
import com.wudsn.ide.lng.compiler.syntax.CompilerSyntax;

/**
 * Definition of a compiler. The definition contains all static meta information
 * about the compiler. It is normally defined via an extension. The id of a
 * compiler must be unique across all compilers.
 * 
 * @author Peter Dell
 */
public final class CompilerDefinition implements Comparable<CompilerDefinition> {

	public final static class HelpDocument {

		public final String path;
		public final String language;

		HelpDocument(String path, String language) {
			if (path == null) {
				throw new IllegalArgumentException("Parameter 'path' must not be null.");
			}
			if (language == null) {
				throw new IllegalArgumentException("Parameter 'language' must not be null.");
			}
			this.path = path;
			this.language = language;
		}

		public boolean isURL() {
			return path.startsWith("http://") || path.startsWith("https://");
		}
	}

	// Language
	private Language language;

	// Id
	private String id;
	private String name;
	private String className;

	// Installation and use.
	private List<HelpDocument> helpDocuments;
	private String homePageURL;

	// Editing and source parsing.
	private List<Target> supportedTargets;
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
	 * Gets the key that uniquely identifies a compiler. They key has the format
	 * "<language>/<id>".
	 * 
	 * @return The key that uniquely identifies the compiler, not <code>null</code>.
	 */
	public static String getKey(Language language, String id) {
		if (language == null) {
			throw new IllegalStateException("Field 'language' must not be null for this or for argument.");
		}
		if (id == null) {
			throw new IllegalStateException("Field 'id' must not be null for this or for argument.");

		}
		return language.name() + "/" + id;
	}

	/**
	 * Gets the key that uniquely identifies the compiler. They key has the format
	 * "<language>/<id>".
	 * 
	 * @return The key that uniquely identifies the compiler, not <code>null</code>.
	 */
	public String getKey() {
		return getKey(language, id);
	}

	/**
	 * Sets the language of the compiler. Called by {@link CompilerRegistry} only.
	 * 
	 * @param language The language of the compiler, not empty and not
	 *                 <code>null</code>.
	 */
	final void setLanguage(String language) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (StringUtility.isEmpty(language)) {
			throw new IllegalArgumentException("Parameter 'language' must not be empty.");
		}
		this.language = Language.valueOf(language);
	}

	/**
	 * Gets the language of the compiler.
	 * 
	 * @return The language of the compiler, not <code>null</code>.
	 */
	public final Language getLanguage() {
		if (language == null) {
			throw new IllegalStateException("Field 'language' must not be null.");
		}
		return language;
	}

	/**
	 * Gets the text for type of compilers for a language.
	 * 
	 * @return The text in sentence case, not empty and not <code>null</code>.
	 */
	public final String getText() {
		return LanguageUtility.getCompilerText(getLanguage());
	}

	/**
	 * Sets the id of the compiler. Called by {@link CompilerRegistry} only.
	 * 
	 * @param id The id of the compiler, not empty and not <code>null</code>.
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
	 * Sets the localized name of the compiler. Called by {@link CompilerRegistry}
	 * only.
	 * 
	 * @param name The localized name of the compiler, not empty and not
	 *             <code>null</code>.
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
	 * Sets the class name of the compiler. Called by {@link CompilerRegistry} only.
	 * 
	 * @param className The class name of the compiler, not empty and not
	 *                  <code>null</code>.
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
	 * @return The class name of the compiler, not empty and not <code>null</code>.
	 */
	public final String getClassName() {
		if (className == null) {
			throw new IllegalStateException("Field 'className' must not be null.");
		}
		return className;
	}

	/**
	 * Sets the absolute URL of the home page where the compiler can be downloaded.
	 * Called by {@link CompilerRegistry} only.
	 * 
	 * @param homePageURL The absolute URL of the home page where the compiler can
	 *                    be downloaded. May be empty or <code>null</code>.
	 */
	final void setHomePageURL(String homePageURL) {
		if (homePageURL == null) {
			homePageURL = "";
		}
		this.homePageURL = homePageURL;
	}

	/**
	 * Gets the absolute URL of the home page where the compiler can be downloaded.
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

	final void setHelpDocuments(List<HelpDocument> helpDocuments) {
		if (helpDocuments == null) {
			throw new IllegalArgumentException("Parameter 'helpDocuments' must not be null.");
		}
		this.helpDocuments = helpDocuments;
	}

	public List<HelpDocument> getHelpDocuments() {
		if (helpDocuments == null) {
			throw new IllegalStateException("Field 'helpDocuments' must not be null.");
		}
		return helpDocuments;
	}

	/**
	 * Determines if this compiler offers help at all.
	 * 
	 * @return <code>true</code> if this compiler offers a help file,
	 *         <code>false</code> otherwise.
	 */
	public final boolean hasHelpDocuments() {
		return !helpDocuments.isEmpty();
	}

	/**
	 * Gets the help file for the compiler. This includes locating the most
	 * appropriate file in the file system based on the current locale.
	 * 
	 * @param compilerExecutablePath the compiler executable path, may be empty, not
	 *                               <code>null</code>.
	 * @return The help file, or <code>null</code> not help file could be found.
	 * 
	 * @throws CoreException if the compilerExecutablePath is empty, the compiler
	 *                       does not specify a help path or no help file can be
	 *                       found.
	 */
	private final List<InstalledHelpDocument> getInstalledHelpDocuments(String compilerExecutablePath)
			throws CoreException {
		if (compilerExecutablePath == null) {
			throw new IllegalArgumentException("Parameter 'compilerExecutablePath' must not be null.");
		}
		if (!hasHelpDocuments()) {
			// INFO: The {0} '{1}' does not specify help documents.
			throw new CoreException(new Status(IStatus.INFO, LanguagePlugin.ID,
					TextUtility.format(Texts.MESSAGE_E102, getText(), getName())));
		}
		String compilerPreferencesText = LanguageUtility.getCompilerPreferencesText(language);
		if (StringUtility.isEmpty(compilerExecutablePath)) {
			// ERROR: Help for the '{0}' {1} cannot be displayed because the path to the
			// compiler executable is not set in the {2} preferences.
			throw new CoreException(new Status(IStatus.ERROR, LanguagePlugin.ID,
					TextUtility.format(Texts.MESSAGE_E130, getText(), getName(), compilerPreferencesText)));
		}

		return CompilerHelp.getInstalledHelpDocuments(getHelpDocuments(), compilerExecutablePath);

	}

	public final InstalledHelpDocument getInstalledHelpForCurrentLocale(String compilerExecutablePath)
			throws CoreException {

		var helpDocuments = getInstalledHelpDocuments(compilerExecutablePath);

		var localeLanguage = Locale.getDefault().getLanguage();

		// Find the first existing local file and the first existing local file with
		// matching language.
		InstalledHelpDocument firstFile = null;
		InstalledHelpDocument firstLanguageFile = null;
		for (var helpDocument : helpDocuments) {

			if (helpDocument.file != null && helpDocument.file.exists()) {
				if (firstFile == null) {
					firstFile = helpDocument;
				}
				if (firstLanguageFile == null && helpDocument.language.equals(localeLanguage)) {
					firstLanguageFile = helpDocument;
				}
			}
		}

		// Use language specific file if present, use first file otherwise.
		var result = firstLanguageFile;
		if (result == null) {
			result = firstFile;
		}

		// No local file specified or found. Try the URIs.
		if (result == null) {
			for (InstalledHelpDocument helpDocument : helpDocuments) {
				if (helpDocument.uri != null) {
					if (firstFile == null) {
						firstFile = helpDocument;
					}
					if (firstLanguageFile == null && helpDocument.language.equals(localeLanguage)) {
						firstLanguageFile = helpDocument;
					}
				}
			}

			// Use language specific URI if present, use first URI otherwise.
			result = firstLanguageFile;
			if (result == null) {
				result = firstFile;
			}
		}

		// No local file specified or found and no URIs found.
		if (result == null) {

			// ERROR: Help for the {0} '{1}' cannot be displayed because no help file was
			// found in the paths relative to the executable path '{2}'.
			throw new CoreException(new Status(IStatus.ERROR, LanguagePlugin.ID,
					TextUtility.format(Texts.MESSAGE_E131, getText(), getName(), compilerExecutablePath)));
		}
		return result;

	}

	public List<CompilerPath> getDefaultPaths() {
		CompilerPaths compilerPaths = new CompilerPaths();
		return compilerPaths.getCompilerPaths(language, id);
	}

	/**
	 * Sets the list of supported targets. Called by {@link CompilerRegistry} only.
	 * 
	 * @param supportedTargets The unmodifiable list of supported CPUs, not empty
	 *                         and not <code>null</code>.
	 * @since 1.6.1
	 */
	final void setSupportedTargets(List<Target> supportedTargets) {
		if (supportedTargets == null) {
			throw new IllegalArgumentException("Parameter 'supportedTargets' must not be null.");
		}
		if (supportedTargets.isEmpty()) {
			throw new IllegalArgumentException("Parameter 'supportedTargets' must not be empty.");
		}
		this.supportedTargets = supportedTargets;
	}

	/**
	 * Gets the unmodifiable list of CPUs supported by this compiler. The first
	 * entry defines the default Target.
	 * 
	 * @return The unmodifiable list of CPUs supported by this compiler, not empty
	 *         and, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public final List<Target> getSupportedTargets() {
		if (supportedTargets == null) {
			throw new IllegalStateException("Field 'supportedCPUs' must not be null.");
		}
		return supportedTargets;
	}

	/**
	 * Sets the compiler syntax. Called by {@link CompilerRegistry} only.
	 * 
	 * @param syntax The compiler syntax, not <code>null</code>.
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
	 * @param defaultParameters The compiler default parameters, not
	 *                          <code>null</code>.
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
	 * @param hardware The default hardware, not <code>null</code>.
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

		return getKey().compareTo(o.getKey());
	}

	@Override
	public String toString() {
		return getKey();
	}

}
