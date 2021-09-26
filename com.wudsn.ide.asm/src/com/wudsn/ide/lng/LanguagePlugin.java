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

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.eclipse.core.runtime.ListenerList;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.preference.JFacePreferences;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.osgi.framework.BundleContext;

import com.wudsn.ide.base.common.AbstractIDEPlugin;
import com.wudsn.ide.lng.compiler.CompilerConsole;
import com.wudsn.ide.lng.compiler.CompilerRegistry;
import com.wudsn.ide.lng.preferences.LanguagePreferences;
import com.wudsn.ide.lng.preferences.LanguagePreferencesChangeListener;
import com.wudsn.ide.lng.preferences.LanguagePreferencesConstants;
import com.wudsn.ide.lng.runner.RunnerRegistry;

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
	private LanguagePreferences preferences;
	private ListenerList<LanguagePreferencesChangeListener> preferencesChangeListeners;

	/**
	 * The compiler registry.
	 */
	private CompilerRegistry compilerRegistry;

	/**
	 * The compiler console.
	 */
	private CompilerConsole compilerConsole;

	/**
	 * The runner registry.
	 */
	private RunnerRegistry runnerRegistry;

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
		compilerConsole = null;
		runnerRegistry = new RunnerRegistry();
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
		preferences = new LanguagePreferences(getPreferenceStore());
		plugin = this;
		try {
			compilerRegistry.init();
		} catch (Exception ex) {
			logError("Cannot initialize compiler registry", null, ex);
			throw ex;
		}
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
					firePreferencesChangeEvent(LanguagePreferencesConstants.EDITOR_TEXT_ATTRIBUTES);
				}

			}
		});

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
	 * Gets the preferences for this plugin.
	 * 
	 * @return The preferences, not <code>null</code>.
	 */
	public LanguagePreferences getPreferences() {
		if (preferences == null) {
			throw new IllegalStateException("Field 'preferences' must not be null.");
		}
		return preferences;
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
	 * @param changedPropertyNames The set of property changed property names, not
	 *                             <code>null</code>.
	 * 
	 * @since 1.6.3
	 */
	public void firePreferencesChangeEvent(Set<String> changedPropertyNames) {
		if (changedPropertyNames == null) {
			throw new IllegalArgumentException("Parameter 'changedPropertyNames' must not be null.");
		}
		if (!changedPropertyNames.isEmpty()) {

			for (Object listener : preferencesChangeListeners.getListeners()) {
				((LanguagePreferencesChangeListener) listener).preferencesChanged(preferences, changedPropertyNames);
			}
		}
	}

	/**
	 * Gets a UI property.
	 * 
	 * @param key The property key, not <code>null</code>.
	 * 
	 * @return The UI property, may be empty, not <code>null</code>.
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
	 * Set a UI property.
	 * 
	 * @param key   The property key, not <code>null</code>.
	 * 
	 * @param value The UI property, may be empty, not <code>null</code>.
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
