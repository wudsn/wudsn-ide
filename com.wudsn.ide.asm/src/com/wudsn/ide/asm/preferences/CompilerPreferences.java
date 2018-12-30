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

package com.wudsn.ide.asm.preferences;

import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.Hardware;
import com.wudsn.ide.asm.compiler.CompilerOutputFolderMode;
import com.wudsn.ide.asm.runner.RunnerId;
import com.wudsn.ide.base.common.StringUtility;

/**
 * Facade class for typed access to the global compiler preferences for a given
 * hardware.
 * 
 * @author Peter Dell
 */
public final class CompilerPreferences {

    private AssemblerPreferences assemblerPreferences;
    private Hardware hardware;
    private String compilerId;

    CompilerPreferences(AssemblerPreferences assemblerPreferences,
	    String compilerId, Hardware hardware) {
	if (assemblerPreferences == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'assemblerPreferences' must not be null.");
	}

	if (compilerId == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'compilerId' must not be null.");
	}
	if (StringUtility.isEmpty(compilerId)) {
	    throw new IllegalArgumentException(
		    "Parameter 'compilerId' must not be empty.");
	}
	if (hardware == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'hardware' must not be null.");
	}
	this.assemblerPreferences = assemblerPreferences;
	this.compilerId = compilerId;
	this.hardware = hardware;
    }

    /**
     * Gets the compiler id of the compiler.
     * 
     * @return The compiler id of the compiler, not empty and not
     *         <code>null</code>.
     */
    public String getCompilerId() {
	return compilerId;
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
     * Gets the CPU for which the instructions shall be active.
     * 
     * @return The CPU, not <code>null</code>.
     * 
     * @since 1.6.1
     */
    public CPU getCPU() {
	CPU result;
	String cpuString = assemblerPreferences
		.getString(AssemblerPreferencesConstants.getCompilerCPUName(
			compilerId, hardware));

	if (StringUtility.isEmpty(cpuString)) {
	    result = CPU.MOS6502;
	} else {
	    result = CPU.valueOf(cpuString);
	}
	return result;
    }

    /**
     * Determines if illegal opcodes shall be highlighted and proposed.
     * 
     * @return <code>true</code> if yet, <code>false</code> otherwise.
     */
    @Deprecated
    public boolean isIllegalOpcodesVisible() {
	return getCPU() == CPU.MOS6502_ILLEGAL;
    }

    /**
     * Determines if W65816 opcodes shall be highlighted and proposed.
     * 
     * @return <code>true</code> if yet, <code>false</code> otherwise.
     */
    @Deprecated
    public boolean isW65816OpcodesVisible() {
	return getCPU() == CPU.MOS65816;
    }

    /**
     * Gets the parameters for the compiler.
     * 
     * @return The parameters path for the compiler, may be empty, not
     *         <code>null</code>.
     */
    public String getParameters() {
	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerParametersName(compilerId, hardware));
    }

    /**
     * Gets the output folder mode for the compiler.
     * 
     * @return The output folder mode for the compiler, see
     *         {@link CompilerOutputFolderMode}, may be empty, not
     *         <code>null</code>.
     */
    public String getOutputFolderMode() {

	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerOutputFolderModeName(compilerId, hardware));
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

	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerOutputFolderPathName(compilerId, hardware));
    }

    /**
     * Gets the output file extension for the compiler.
     * 
     * @return The output file extension may be empty, not <code>null</code>.
     */
    public String getOutputFileExtension() {

	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerOutputFileExtensionName(compilerId, hardware));
    }

    /**
     * Gets the id of the default runner to run the output file.
     * 
     * @return The id of the runner to run the output file, not empty and not
     *         <code>null</code>.
     */
    public String getRunnerId() {
	String result = assemblerPreferences
		.getString(AssemblerPreferencesConstants
			.getCompilerRunnerIdName(compilerId, hardware));
	if (StringUtility.isEmpty(result)) {
	    result = RunnerId.DEFAULT_APPLICATION;
	}
	return result;
    }

    /**
     * Gets the executable path for the runner.
     * 
     * @param runnerId
     *            The runner id, not empty and not <code>null</code>.
     * 
     * @return The executable path for the runner, may be empty, not
     *         <code>null</code>.
     */
    public String getRunnerExecutablePath(String runnerId) {
	if (runnerId == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be null.");
	}
	if (StringUtility.isEmpty(runnerId)) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be empty.");
	}
	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerRunnerExecutablePathName(compilerId, hardware,
			runnerId));
    }

    /**
     * Gets the parameters for the runner.
     * 
     * @param runnerId
     *            The runner id, not empty and not <code>null</code>.
     * 
     * @return The parameters for the runner, may be empty, not
     *         <code>null</code>.
     */
    public String getRunnerCommandLine(String runnerId) {
	if (runnerId == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be null.");
	}
	if (StringUtility.isEmpty(runnerId)) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be empty.");
	}
	return assemblerPreferences.getString(AssemblerPreferencesConstants
		.getCompilerRunnerCommandLineName(compilerId, hardware,
			runnerId));
    }

    /**
     * Gets the wait for completion indicator for the runner.
     * 
     * @param runnerId
     *            The runner id, not empty and not <code>null</code>.
     * 
     * @return <code>true</code>if waiting for completion is requested,
     *         <code>false</code> otherwise.
     * 
     * @since 1.6.1
     */
    public boolean isRunnerWaitForCompletion(String runnerId) {
	if (runnerId == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be null.");
	}
	if (StringUtility.isEmpty(runnerId)) {
	    throw new IllegalArgumentException(
		    "Parameter 'runnerId' must not be empty.");
	}
	return assemblerPreferences.getBoolean(AssemblerPreferencesConstants
		.getCompilerRunnerWaitForCompletionName(compilerId, hardware,
			runnerId));
    }

}
