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

package com.wudsn.ide.asm.runner;

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

import com.wudsn.ide.base.hardware.Hardware;

/**
 * Registry for runners, based on the extension points
 * {@value RunnerRegistry#RUNNERS}.
 * 
 * @author Peter Dell
 * 
 */
public final class RunnerRegistry {

	/**
	 * The id of the extension point which provides the runners.
	 */
	private static final String RUNNERS = "com.wudsn.ide.asm.runners";

	/**
	 * The registered runner definition.
	 */
	private List<RunnerDefinition> runnerDefinitionList;

	/**
	 * The cached map of runner instances.
	 */
	private Map<String, Runner> runnerMap;

	/**
	 * Creation is public.
	 */
	public RunnerRegistry() {
		runnerDefinitionList = Collections.emptyList();
		runnerMap = Collections.emptyMap();

	}

	/**
	 * Initializes the list of available runners.
	 */
	public void init() {

		runnerDefinitionList = new ArrayList<RunnerDefinition>();
		runnerMap = new TreeMap<String, Runner>();

		IExtensionRegistry extensionRegistry = Platform.getExtensionRegistry();
		IExtensionPoint extensionPoint = extensionRegistry.getExtensionPoint(RUNNERS);
		IExtension[] extensions = extensionPoint.getExtensions();

		for (IExtension extension : extensions) {
			IConfigurationElement[] configurationElements = extension.getConfigurationElements();
			for (IConfigurationElement configurationElement : configurationElements) {

				RunnerDefinition runnerDefinition;
				runnerDefinition = new RunnerDefinition();
				runnerDefinition.setId(configurationElement.getAttribute("id"));
				runnerDefinition.setHardware(Hardware.valueOf(configurationElement.getAttribute("hardware")));
				runnerDefinition.setName(configurationElement.getAttribute("name"));
				runnerDefinition.setHomePageURL(configurationElement.getAttribute("homePageURL"));
				runnerDefinition.setDefaultCommandLine(configurationElement.getAttribute("defaultCommandLine"));

				runnerDefinitionList.add(runnerDefinition);

				addRunner(configurationElement, runnerDefinition);
			}
		}

		runnerDefinitionList = new ArrayList<RunnerDefinition>(runnerDefinitionList);
		Collections.sort(runnerDefinitionList);
		runnerDefinitionList = Collections.unmodifiableList(runnerDefinitionList);
		runnerMap = Collections.unmodifiableMap(runnerMap);
	}

	/**
	 * Adds a new runner.
	 * 
	 * @param configurationElement The configuration element used as class instance
	 *                             factory, not <code>null</code>.
	 * 
	 * @param runnerDefinition     The runner definition, not <code>null</code>.
	 */
	private void addRunner(IConfigurationElement configurationElement, RunnerDefinition runnerDefinition) {
		if (configurationElement == null) {
			throw new IllegalArgumentException("Parameter 'configurationElement' must not be null.");
		}
		if (runnerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'runnerDefinition' must not be null.");
		}

		String id = runnerDefinition.getHardware().toString().toLowerCase() + "." + runnerDefinition.getId();

		// Optionally use a specific runner implementation class.
		Runner runner;
		if (configurationElement.getAttribute("class") != null) {
			try {
				// The class loading must be delegated to the framework.
				runner = (Runner) configurationElement.createExecutableExtension("class");
			} catch (CoreException ex) {
				throw new RuntimeException("Cannot create runner instance for id '" + id + "'.", ex);
			}
		} else {
			runner = new Runner();
		}

		runner.setDefinition(runnerDefinition);
		runner = runnerMap.put(id, runner);
		if (runner != null) {
			throw new RuntimeException("Runner with id '" + runnerDefinition.getId() + "' for hardware '"
					+ runnerDefinition.getHardware().toString() + "' is already registered to class '"
					+ runner.getClass().getName() + "'.");
		}

	}

	/**
	 * Gets the unmodifiable list of runner definitions, sorted by their name.
	 * 
	 * @param hardware The hardware used for filtering, not <code>null</code>.
	 * 
	 * @return The unmodifiable list of runner definitions which have the matching
	 *         hardware or {@link Hardware#GENERIC}, sorted by their id, may be
	 *         empty, not <code>null</code>.
	 */
	public List<RunnerDefinition> getDefinitions(Hardware hardware) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}

		List<RunnerDefinition> result = new ArrayList<RunnerDefinition>(runnerDefinitionList.size());
		for (RunnerDefinition runnerDefinition : runnerDefinitionList) {
			if (runnerDefinition.getHardware().equals(hardware)
					|| runnerDefinition.getHardware().equals(Hardware.GENERIC)) {
				result.add(runnerDefinition);
			}
		}
		result = Collections.unmodifiableList(result);
		return result;
	}

	/**
	 * Gets the runner for a given id. Instances of runner are stateless singletons
	 * within the plugin.
	 * 
	 * @param hardware The hardware, not <code>null</code>.
	 * @param runnerId The runner type, see {@link RunnerId}, not <code>null</code>.
	 * 
	 * @return The runner, not <code>null</code>.
	 */
	public Runner getRunner(Hardware hardware, String runnerId) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		Runner result;
		synchronized (runnerMap) {

			result = runnerMap.get(hardware.toString().toLowerCase() + "." + runnerId);
			if (result == null) {
				result = runnerMap.get(Hardware.GENERIC.toString().toLowerCase() + "." + runnerId);
			}
		}
		if (result == null) {

			throw new IllegalArgumentException(
					"Unknown runner id '" + runnerId + "' for hardware '" + hardware.toString() + "'.");
		}

		return result;
	}
}
