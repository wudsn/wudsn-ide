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

package com.wudsn.ide.lng.runner;

import com.wudsn.ide.base.hardware.Hardware;

/**
 * Definition of a runner. The definition contains all static meta information
 * about the runner. It is normally defined via an extension.
 * 
 * 
 * For launching application under MacOS see
 * https://bugs.eclipse.org/bugs/show_bug.cgi?id=82155 and
 * http://www.coderanch.com/t/111494/Mac-OS/launching-Safari-from-Java-App.
 * 
 * @author Peter Dell
 */
public final class RunnerDefinition implements Comparable<RunnerDefinition> {

	public static final String RUNNER_EXECUTABLE_PATH = "${runnerExecutablePath}";
	public static final String OUTPUT_FILE_PATH = "${outputFilePath}";

	// Id
	private Hardware hardware;
	private String id;
	private String name;

	// Installation and use.
	private String homePageURL;

	// Compiling.
	private String defaultCommandLine;

	/**
	 * Creation is package local. Called by {@link RunnerRegistry} only.
	 */
	RunnerDefinition() {

	}

	/**
	 * Sets the hardware of the runner. Called by {@link RunnerRegistry} only.
	 * 
	 * @param hardware The hardware, not <code>null</code>.
	 */
	final void setHardware(Hardware hardware) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		this.hardware = hardware;
	}

	/**
	 * Gets the hardware of the runner.
	 * 
	 * @return The hardware of the runner, not empty and not <code>null</code>.
	 */
	public final Hardware getHardware() {
		if (hardware == null) {
			throw new IllegalStateException("Field 'hardware' must not be null.");
		}
		return hardware;
	}

	/**
	 * Sets the id of the runner. Called by {@link RunnerRegistry} only. The id is
	 * only unique together with the hardware returned by {@link #getHardware()}.
	 * 
	 * @param id The id of the runner, not empty and not <code>null</code>.
	 */
	final void setId(String id) {
		if (id == null) {
			throw new IllegalArgumentException("Parameter 'id' must not be null.");
		}
		this.id = id;
	}

	/**
	 * Gets the id of the runner.
	 * 
	 * @return The id of the runner, not empty and not <code>null</code>.
	 */
	public final String getId() {
		if (id == null) {
			throw new IllegalStateException("Field 'id' must not be null.");
		}
		return id;
	}

	/**
	 * Sets the name of the runner. Called by {@link RunnerRegistry} only.
	 * 
	 * @param name The name of the runner, not empty and not <code>null</code>.
	 */
	final void setName(String name) {
		if (name == null) {
			throw new IllegalArgumentException("Parameter 'name' must not be null.");
		}
		this.name = name;
	}

	/**
	 * Gets the name of the runner.
	 * 
	 * @return The name of the runner, not empty and not <code>null</code>.
	 */
	public final String getName() {
		if (name == null) {
			throw new IllegalStateException("Field 'name' must not be null.");
		}
		return name;
	}

	/**
	 * Determines if the runner allows a runner executable path to be configured.
	 * 
	 * @return <code>true</code> if the runner allows a runner executable path to be
	 *         configured, <code>false</code> otherwise.
	 */
	public final boolean isRunnerExecutablePathPossible() {
		boolean result;

		result = id.equals(RunnerId.USER_DEFINED_APPLICATION) || defaultCommandLine.contains(RUNNER_EXECUTABLE_PATH);
		return result;
	}

	/**
	 * Sets the absolute URL of the home page where the runner can be downloaded.
	 * Called by {@link RunnerRegistry} only.
	 * 
	 * @param homePageURL The absolute URL of the home page where the runner can be
	 *                    downloaded. May be empty or <code>null</code>.
	 */
	final void setHomePageURL(String homePageURL) {
		if (homePageURL == null) {
			homePageURL = "";
		}
		this.homePageURL = homePageURL;
	}

	/**
	 * Gets the absolute URL of the home page where the runner can be downloaded.
	 * 
	 * @return The absolute URL of the home page where the runner can be downloaded.
	 *         The result may be empty, not <code>null</code>.
	 */
	public final String getHomePageURL() {
		if (homePageURL == null) {
			throw new IllegalStateException("Field 'homePageURL' must not be null.");
		}
		return homePageURL;
	}

	/**
	 * Sets the runner default command line. Called by {@link RunnerRegistry} only.
	 * 
	 * @param defaultCommandLine The runner default parameters, may be empty or
	 *                           <code>null</code>.
	 */
	final void setDefaultCommandLine(String defaultCommandLine) {
		if (defaultCommandLine == null) {
			defaultCommandLine = "";
		}
		this.defaultCommandLine = defaultCommandLine;
	}

	/**
	 * Gets the runner default command line.
	 * 
	 * @return The runner default parameters, not <code>null</code>.
	 */
	public final String getDefaultCommandLine() {
		if (defaultCommandLine == null) {
			throw new IllegalStateException("Field 'defaultCommandLine' must not be null.");
		}
		return defaultCommandLine;
	}

	/**
	 * Compare instances of this class based on their name.
	 * 
	 * @param o The object to compare this one with, not <code>null</code>.
	 */
	@Override
	public final int compareTo(RunnerDefinition o) {
		if (o == null) {
			throw new IllegalArgumentException("Parameter 'o' must not be null.");
		}
		if (name == null || o.name == null) {
			throw new IllegalStateException("Field 'name' must not be null for this or for argument.");

		}
		int result = id.compareTo(o.id);
		if (result == 0) {
			return 0;
		}
		if (id.equals(RunnerId.DEFAULT_APPLICATION)) {
			return -1;
		} else if (id.equals(RunnerId.USER_DEFINED_APPLICATION)) {
			return +1;
		}
		return name.compareTo(o.name);
	}

	@Override
	public final String toString() {
		return hardware.toString().toLowerCase() + "." + id;
	}
}
