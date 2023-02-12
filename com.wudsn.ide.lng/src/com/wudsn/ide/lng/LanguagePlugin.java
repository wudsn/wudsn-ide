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

package com.wudsn.ide.lng;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.eclipse.core.runtime.ListenerList;
import org.eclipse.core.runtime.Platform;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.preference.JFacePreferences;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.lng.compiler.CompilerConsole;
import com.wudsn.ide.lng.compiler.CompilerPaths;
import com.wudsn.ide.lng.compiler.CompilerPathsTest;
import com.wudsn.ide.lng.compiler.CompilerRegistry;
import com.wudsn.ide.lng.preferences.LanguagePreferences;
import com.wudsn.ide.lng.preferences.LanguagePreferencesChangeListener;
import com.wudsn.ide.lng.preferences.LanguagesPreferences;
import com.wudsn.ide.lng.preferences.TextAttributeDefinition;
import com.wudsn.ide.lng.runner.RunnerPaths;
import com.wudsn.ide.lng.runner.RunnerPathsTest;
import com.wudsn.ide.lng.runner.RunnerRegistry;
import com.wudsn.ide.lng.preferences.LanguagePreferencesConstants.EditorConstants;
/**
 * The main plugin class to be used in the desktop.
 * 
 * @author Peter Dell
 */
public final class LanguagePlugin extends AbstractIDEPlugin {

	/**
	 * The plugin id.
	 */
	public static final String ID = "com.wudsn.ide.lng";

	/**
	 * The shared instance.
	 */
	private static LanguagePlugin plugin;

	private List<Language> languages;

	/**
	 * The preferences.
	 */
	private LanguagesPreferences preferences;
	private ListenerList<LanguagePreferencesChangeListener> preferencesChangeListeners;

	/**
	 * The compiler registry.
	 */
	private CompilerRegistry compilerRegistry;

	/**
	 * The compiler paths.
	 */
	private CompilerPaths compilerPaths;
	
	/**
	 * The compiler console.
	 */
	private CompilerConsole compilerConsole;

	/**
	 * The runner registry.
	 */
	private RunnerRegistry runnerRegistry;
	
	/**
	 * The runner paths.
	 */
	private RunnerPaths runnerPaths;

	/**
	 * The UI properties.
	 */
	private Map<QualifiedName, String> properties;

	/**
	 * Creates a new instance. Must be public for dynamic instantiation.
	 */
	public LanguagePlugin() {
		preferences = null;
		preferencesChangeListeners = new ListenerList<LanguagePreferencesChangeListener>(ListenerList.IDENTITY);
		compilerRegistry = new CompilerRegistry();
		compilerPaths = new CompilerPaths();
		compilerConsole = null;
		runnerRegistry = new RunnerRegistry();
		runnerPaths = new RunnerPaths();
		properties = new HashMap<QualifiedName, String>(10);
		languages = new ArrayList<Language>(2);
		languages.add(Language.ASM);
		languages.add(Language.PAS);
		languages = Collections.unmodifiableList(languages);
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	protected String getPluginId() {
		return ID;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void start(BundleContext context) throws Exception {
		super.start(context);
		preferences = new LanguagesPreferences(getPreferenceStore());
		plugin = this;
		try {
			compilerRegistry.init();
		} catch (Exception ex) {
			logError("Cannot initialize compiler registry", null, ex);
			throw ex;
		}
		compilerPaths.init();
		compilerConsole = new CompilerConsole();
		try {
			runnerRegistry.init();
		} catch (Exception ex) {
			logError("Cannot initialize runner registry", null, ex);
			throw ex;
		}

		// Register for global JFace preferences that also affect the editors.
		JFacePreferences.getPreferenceStore().addPropertyChangeListener(new IPropertyChangeListener() {
			final static String BLOCK_SELECTION_MODE_FONT = "org.eclipse.ui.workbench.texteditor.blockSelectionModeFont";

			@Override
			public void propertyChange(PropertyChangeEvent event) {
				if (event.getProperty().equals(JFaceResources.TEXT_FONT)
						|| event.getProperty().equals(BLOCK_SELECTION_MODE_FONT)) {
					for (Language language : languages) {
						List<TextAttributeDefinition> textAttributeDefinitions = EditorConstants
								.getTextAttributeDefinitions(language);
						Set<String> changedPropertyNames = new TreeSet<String>();
						for (TextAttributeDefinition textAttributeDefinition : textAttributeDefinitions) {
							changedPropertyNames.add(textAttributeDefinition.getPreferencesKey());
						}
						firePreferencesChangeEvent(language, changedPropertyNames);
					}
				}

			}
		});
		
		// TODO: Call unit tests
		CompilerPathsTest.main(new String[0]);
		RunnerPathsTest.main(new String[0]);
		LanguageAnnotationValuesTest.main(new String[0]);

	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void stop(BundleContext context) throws Exception {
		super.stop(context);
		plugin = null;
	}

	/**
	 * Gets the shared plugin instance.
	 * 
	 * @return The plug-in, not <code>null</code>.
	 */
	public static LanguagePlugin getInstance() {
		if (plugin == null) {
			throw new IllegalStateException("Plugin not initialized or already stopped");
		}
		return plugin;
	}

	/**
	 * Gets the unmodifiable list of supported languages.
	 * 
	 * @return The unmodifiable list of supported languages, may be empty, not
	 *         <code>null</code>,
	 */
	public List<Language> getLanguages() {
		return languages;
	}


	public File getAbsoluteToolsFile(String relativePath) {
		if (relativePath == null) {
			return null;
		}
		URL eclipseFolderURL = Platform.getInstallLocation().getURL();
		if (eclipseFolderURL == null) {
			return null;
		}
		URI uri;
		try {

			uri = eclipseFolderURL.toURI();
		} catch (URISyntaxException ignore) {
			return null;
		}
		File eclipseVersionFolder = FileUtility.getCanonicalFile(new File(uri)); // "eclipse"
		File eclipseFolder = eclipseVersionFolder.getParentFile(); // "Eclipse"
		File ideFolder = eclipseFolder.getParentFile(); // "IDE"
		File toolsFolder = ideFolder.getParentFile(); // "Tools
		File compilerFile = new File(toolsFolder, relativePath);
		return compilerFile;
	}

	
	/**
	 * Gets the compiler registry for this plugin.
	 * 
	 * @return The compiler registry, not <code>null</code>.
	 */
	public CompilerRegistry getCompilerRegistry() {
		if (compilerRegistry == null) {
			throw new IllegalStateException("Field 'compilerRegistry' must not be null.");
		}
		return compilerRegistry;
	}

	/**
	 * Gets the compiler paths for this plugin.
	 * 
	 * @return The compiler paths, not <code>null</code>.
	 */
	public CompilerPaths getCompilerPaths() {
		if (compilerPaths == null) {
			throw new IllegalStateException("Field 'compilerPaths' must not be null.");
		}
		return compilerPaths;
	}
	
	/**
	 * Gets the compiler console for this plugin.
	 * 
	 * @return The compiler console, not <code>null</code>.
	 */
	public final CompilerConsole getCompilerConsole() {
		if (compilerConsole == null) {
			throw new IllegalStateException("Field 'compilerConsole' must not be null.");
		}
		return compilerConsole;
	}

	/**
	 * Gets the runner registry for this plugin.
	 * 
	 * @return The runner registry, not <code>null</code>.
	 */
	public RunnerRegistry getRunnerRegistry() {
		if (runnerRegistry == null) {
			throw new IllegalStateException("Field 'runnerRegistry' must not be null.");
		}
		return runnerRegistry;
	}

	/**
	 * Gets the runner paths for this plugin.
	 * 
	 * @return The compiler paths, not <code>null</code>.
	 */
	public RunnerPaths getRunnerPaths() {
		if (runnerPaths == null) {
			throw new IllegalStateException("Field 'runnerPaths' must not be null.");
		}
		return runnerPaths;
	}
	
	/**
	 * Gets the preferences for this plugin.
	 * 
	 * @return The preferences, not <code>null</code>.
	 */
	public LanguagesPreferences getPreferences() {
		if (preferences == null) {
			throw new IllegalStateException("Field 'preferences' must not be null.");
		}
		return preferences;
	}

	public LanguagePreferences getLanguagePreferences(Language language) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		return getPreferences().getLanguagePreferences(language);
	}

	/**
	 * Adds a listener for immediate preferences changes.
	 * 
	 * @param listener The listener, not <code>null</code>.
	 * @since 1.6.3
	 */
	public void addPreferencesChangeListener(LanguagePreferencesChangeListener listener) {
		if (listener == null) {
			throw new IllegalArgumentException("Parameter 'listener' must not be null.");
		}
		preferencesChangeListeners.add(listener);
	}

	/**
	 * Removes a listener for immediate preferences changes.
	 * 
	 * @param listener The listener, not <code>null</code>.
	 * @since 1.6.3
	 */
	public void removePreferencesChangeListener(LanguagePreferencesChangeListener listener) {
		if (listener == null) {
			throw new IllegalArgumentException("Parameter 'listener' must not be null.");
		}
		preferencesChangeListeners.remove(listener);
	}

	/**
	 * Fire the change events for all registered listeners.
	 * 
	 * @param language
	 * 
	 * @param changedPropertyNames The set of value changed value names, not
	 *                             <code>null</code>.
	 * 
	 * @since 1.6.3
	 */
	public void firePreferencesChangeEvent(Language language, Set<String> changedPropertyNames) {
		if (changedPropertyNames == null) {
			throw new IllegalArgumentException("Parameter 'changedPropertyNames' must not be null.");
		}
		if (!changedPropertyNames.isEmpty()) {
			LanguagePreferences languagPreferences = getLanguagePreferences(language);
			for (Object listener : preferencesChangeListeners.getListeners()) {
				((LanguagePreferencesChangeListener) listener).preferencesChanged(languagPreferences,
						changedPropertyNames);
			}
		}
	}

	/**
	 * Gets a UI value.
	 * 
	 * @param key The value key, not <code>null</code>.
	 * 
	 * @return The UI value, may be empty, not <code>null</code>.
	 */
	public String getProperty(QualifiedName key) {
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}

		String result;
		synchronized (properties) {
			result = properties.get(key);
		}
		if (result == null) {
			result = "";
		}
		return result;
	}

	/**
	 * Set a UI value.
	 * 
	 * @param key   The value key, not <code>null</code>.
	 * 
	 * @param value The UI value, may be empty, not <code>null</code>.
	 */
	public void setProperty(QualifiedName key, String value) {
		if (key == null) {
			throw new IllegalArgumentException("Parameter 'key' must not be null.");
		}
		if (value == null) {
			throw new IllegalArgumentException("Parameter 'value' must not be null.");
		}
		synchronized (properties) {
			properties.put(key, value);
		}

	}
}
