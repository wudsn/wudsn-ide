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

package com.wudsn.ide.lng.preferences;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.LanguageProperties;

/**
 * Facade class to mix compiler run specific preferences into the global
 * preferences.
 * 
 * @author Peter Dell
 * 
 */
public final class CompilerRunPreferences {

	private CompilerPreferences compilerPreferences;
	private LanguageProperties mainSourceFileProperties;

	public CompilerRunPreferences(CompilerPreferences compilerPreferences,
			LanguageProperties mainSourceFileProperties) {
		if (compilerPreferences == null) {
			throw new IllegalArgumentException("Parameter 'compilerPreferences' must not be null.");
		}
		if (mainSourceFileProperties == null) {
			throw new IllegalArgumentException("Parameter 'properties' must not be null.");
		}
		this.compilerPreferences = compilerPreferences;
		this.mainSourceFileProperties = mainSourceFileProperties;
	}

	/**
	 * Gets the hardware for which the compiler is invoked.
	 * 
	 * @return The hardware, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public Hardware getHardware() {
		return compilerPreferences.getHardware();
	}

	/**
	 * Gets the parameters for the compiler.
	 * 
	 * @return The parameters path for the compiler, may be empty, not
	 *         <code>null</code>.
	 */
	public String getParameters() {

		String result;

		result = compilerPreferences.getParameters();
		return result;
	}

	/**
	 * Gets the id of the runner to run the output file.
	 * 
	 * @return The id of the runner to run the output file, not empty and not
	 *         <code>null</code>.
	 */
	public String getRunnerId() {
		String result;

		result = compilerPreferences.getRunnerId();
		return result;
	}

	/**
	 * Gets the executable path for the runner.
	 * 
	 * @param runnerId The runner id, not empty and not <code>null</code>.
	 * 
	 * @return The executable path for the runner, may be empty, not
	 *         <code>null</code>.
	 */
	public String getRunnerExecutablePath(String runnerId) {
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		if (StringUtility.isEmpty(runnerId)) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be empty.");
		}

		String result;

		result = compilerPreferences.getRunnerExecutablePath(runnerId);
		return result;
	}

	/**
	 * Gets the parameters for the runner.
	 * 
	 * @param runnerId The runner id, not empty and not <code>null</code>.
	 * 
	 * @return The parameters for the runner, may be empty, not <code>null</code>.
	 */
	public String getRunnerCommandLine(String runnerId) {
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		if (StringUtility.isEmpty(runnerId)) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be empty.");
		}
		String result;
		result = compilerPreferences.getRunnerCommandLine(runnerId);
		return result;
	}

	/**
	 * Gets the wait for completion indicator for the runner.
	 * 
	 * @param runnerId The runner id, not empty and not <code>null</code>.
	 * 
	 * @return <code>true</code>if waiting for completion is requested,
	 *         <code>false</code> otherwise.
	 * 
	 * @since 1.6.1
	 */
	public boolean isRunnerWaitForCompletion(String runnerId) {
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		if (StringUtility.isEmpty(runnerId)) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be empty.");
		}
		boolean result;
		result = compilerPreferences.isRunnerWaitForCompletion(runnerId);
		return result;
	}

}
