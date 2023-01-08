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
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.Target;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerOutputFolderMode;
import com.wudsn.ide.lng.runner.RunnerId;

/**
 * Facade class for typed access to the global compiler preferences for a given
 * hardware.
 * 
 * @author Peter Dell
 */
public final class LanguageHardwareCompilerDefinitionPreferences {

	private LanguagePreferences languagePreferences;
	private Language language;
	private Hardware hardware;
	private CompilerDefinition compilerDefinition;

	LanguageHardwareCompilerDefinitionPreferences(LanguagePreferences languagePreferences, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (languagePreferences == null) {
			throw new IllegalArgumentException("Parameter 'languagePreferences' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		this.languagePreferences = languagePreferences;
		this.language = this.languagePreferences.getLanguage();
		this.compilerDefinition = compilerDefinition;
		this.hardware = hardware;
	}

	/**
	 * Gets the hardware for which the compiler is invoked.
	 * 
	 * @return The hardware, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public Hardware getHardware() {
		return hardware;
	}

	/**
	 * Gets the compiler definition.
	 * 
	 * @return The compiler definition, not <code>null</code>.
	 */
	public CompilerDefinition getCompilerDefinition() {
		return compilerDefinition;
	}

	/**
	 * Gets the Target for which the instructions shall be active.
	 * 
	 * @return The Target, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	public Target getTarget() {
		Target result;
		String targetString = languagePreferences
				.getString(LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerTargetName(language, hardware, compilerDefinition));

		if (StringUtility.isEmpty(targetString)) {
			result = Target.MOS6502;
		} else {
			result = Target.valueOf(targetString);
		}
		return result;
	}

	/**
	 * Gets the parameters for the compiler.
	 * 
	 * @return The parameters path for the compiler, may be empty, not
	 *         <code>null</code>.
	 */
	public String getParameters() {
		return languagePreferences.getString(
				LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerParametersName(language, hardware, compilerDefinition));
	}

	/**
	 * Gets the output folder mode for the compiler.
	 * 
	 * @return The output folder mode for the compiler, see
	 *         {@link CompilerOutputFolderMode}, may be empty, not
	 *         <code>null</code>.
	 */
	public String getOutputFolderMode() {

		return languagePreferences.getString(
				LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerOutputFolderModeName(language, hardware, compilerDefinition));
	}

	/**
	 * Gets the output folder for the compiler in case the output folder mode is
	 * {@link CompilerOutputFolderMode#FIXED_FOLDER}.
	 * 
	 * @return The output folder mode for the compiler, see
	 *         {@link CompilerOutputFolderMode#FIXED_FOLDER}, may be empty, not
	 *         <code>null</code>.
	 */
	public String getOutputFolderPath() {

		return languagePreferences.getString(
				LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerOutputFolderPathName(language, hardware, compilerDefinition));
	}

	/**
	 * Gets the output file extension for the compiler.
	 * 
	 * @return The output file extension may be empty, not <code>null</code>.
	 */
	public String getOutputFileExtension() {

		return languagePreferences.getString(LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerOutputFileExtensionName(language,
				hardware, compilerDefinition));
	}

	/**
	 * Gets the id of the default runner to run the output file.
	 * 
	 * @return The id of the runner to run the output file, not empty and not
	 *         <code>null</code>.
	 */
	public String getRunnerId() {
		String result = languagePreferences.getString(
				LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerRunnerIdName(language, hardware, compilerDefinition));
		if (StringUtility.isEmpty(result)) {
			result = RunnerId.DEFAULT_APPLICATION;
		}
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
		return languagePreferences.getString(LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerRunnerExecutablePathName(language,
				hardware, compilerDefinition, runnerId));
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
		return languagePreferences.getString(LanguageHardwareCompilerDefinitionPreferencesConstants.getCompilerRunnerCommandLineName(language,
				hardware, compilerDefinition, runnerId));
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
		return languagePreferences.getBoolean(LanguageHardwareCompilerDefinitionPreferencesConstants
				.getCompilerRunnerWaitForCompletionName(language, hardware, compilerDefinition, runnerId));
	}

}
