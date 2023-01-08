/**
R * Copyright (C) 2009 - 2021 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.compiler.CompilerDefinition;

/**
 * Constants for preferences.
 * 
 * @author Peter Dell
 */
public final class LanguageHardwareCompilerDefinitionPreferencesConstants {

	/**
	 * Gets preference key name prefix for a given hardware and compiler.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * 
	 * 
	 * @return The preference key name prefix without trailing dot, not empty and
	 *         not <code>null</code>.
	 */
	private static String getLanguageHardwareCompilerDefinitionPrefix(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return LanguagePreferencesConstants.getLanguagePreferencesKey(language,
				"hardware." + hardware.name().toLowerCase() + ".compiler." + compilerDefinition.getId());
	}

	/**
	 * Gets preference key name for the compiler output file extension.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler output file extension, not
	 *         empty and not <code>null</code>.
	 */
	static String getCompilerOutputFileExtensionName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition)
				+ ".output.file.extension"; //$NON-NLS-1$

	}

	/**
	 * Gets preference key name for the compiler output folder mode.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler output folder mode, not
	 *         empty and not <code>null</code>.
	 */
	static String getCompilerOutputFolderModeName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition)
				+ ".output.folder.mode"; //$NON-NLS-1$

	}

	/**
	 * Gets preference key name for the compiler output folder path.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler output folder path, not
	 *         empty and not <code>null</code>.
	 */
	static String getCompilerOutputFolderPathName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition)
				+ ".output.folder.path"; //$NON-NLS-1$

	}

	/**
	 * Gets preference key name for the compiler parameters.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler parameters, not empty and
	 *         not <code>null</code>.
	 */
	static String getCompilerParametersName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition)
				+ ".default.parameters"; //$NON-NLS-1$
	}

	/**
	 * Gets preference key name for the runner command line.
	 * 
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * @param runnerId           The runner id, not <code>null</code>.
	 * 
	 * @return The preference key name for the runner command line, not empty and
	 *         not <code>null</code>.
	 */
	static String getCompilerRunnerCommandLineName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition, String runnerId) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition) + ".runner." //$NON-NLS-1$
				+ runnerId + ".parameters";

	}

	/**
	 * Gets preference key name for the runner executable path.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * @param runnerId           The runner id, not <code>null</code>.
	 * 
	 * @return The preference key name for the runner executable path, not empty and
	 *         not <code>null</code>.
	 */
	static String getCompilerRunnerExecutablePathName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition, String runnerId) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition) + ".runner." //$NON-NLS-1$
				+ runnerId + ".executable.path";

	}

	/**
	 * Gets preference key name for the runner to run the output file.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the for the runner to run the output
	 *         file, not empty and not <code>null</code>.
	 */
	static String getCompilerRunnerIdName(Language language, Hardware hardware, CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition) + ".runner.id"; //$NON-NLS-1$

	}

	/**
	 * Gets preference key name for the runner wait for completion flag.
	 * 
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * @param runnerId           The runner id, not <code>null</code>.
	 * 
	 * @return The preference key name for the runner command line, not empty and
	 *         not <code>null</code>.
	 * @since 1.6.1
	 */
	static String getCompilerRunnerWaitForCompletionName(Language language, Hardware hardware,
			CompilerDefinition compilerDefinition, String runnerId) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		if (runnerId == null) {
			throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition) + ".runner." //$NON-NLS-1$
				+ runnerId + ".waitForCompletion";

	}

	/**
	 * Gets preference key name for the compiler Target visibility.
	 * 
	 * @param language           The language, not <code>null</code>.
	 * @param compilerDefinition The compiler id, not <code>null</code>.
	 * @param hardware           The hardware, not <code>null</code>.
	 * 
	 * @return The preference key name for the compiler Target, not empty and not
	 *         <code>null</code>.
	 */
	public static String getCompilerTargetName(Language language, Hardware hardware, CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		return getLanguageHardwareCompilerDefinitionPrefix(language, hardware, compilerDefinition) + ".target"; //$NON-NLS-1$
	}

}
