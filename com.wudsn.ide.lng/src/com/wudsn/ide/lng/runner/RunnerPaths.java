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

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.runtime.Platform;

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.LanguagePlugin;

/**
 * Computation of default paths for runners.
 * 
 * @author Peter Dell
 * 
 * @since 1.7.2
 *
 */
public final class RunnerPaths {

	public static final class RunnerPath {
		public final Hardware hardware;
		public final String runnerId;
		public final String os;
		public final String osArch;
		public final String executablePath;

		private RunnerPath(Hardware hardware, String runnerId, String os, String osArch, String executablePath) {
			this.hardware = hardware;
			this.runnerId = runnerId;
			this.os = os;
			this.osArch = osArch;
			this.executablePath = executablePath;

		}

		public static String getKey(Hardware hardware, String runnerId, String os, String osArch) {
			return hardware.name() + "/" + runnerId + "/" + os + "/" + osArch;
		}

		public String getKey() {
			return getKey(hardware, runnerId, os, osArch);
		}

		public String getRelativePath() {
			return "EMU/" + executablePath;
		}

		public File getAbsoluteFile() {
			return LanguagePlugin.getInstance().getAbsoluteToolsFile(getRelativePath());
		}

	}

	private Map<String, RunnerPath> runnerPaths;

	/**
	 * Created by the {@linkplain LanguagePlugin}.
	 */
	public RunnerPaths() {
		runnerPaths = new TreeMap<String, RunnerPath>();
		// See https://github.com/peterdell/wudsn-ide-tools
		add(Hardware.ATARI8BIT, "altirra", Platform.OS_LINUX, Platform.ARCH_X86_64, "Altirra/Altirra.sh");
		add(Hardware.ATARI8BIT, "altirra", Platform.OS_MACOSX, Platform.ARCH_X86_64, "Altirra/Altirra.sh");
		add(Hardware.ATARI8BIT, "altirra", Platform.OS_WIN32, Platform.ARCH_X86, "Altirra/Altirra.exe");
		add(Hardware.ATARI8BIT, "altirra", Platform.OS_WIN32, Platform.ARCH_X86_64, "Altirra/Altirra64.exe");

	}

	private void add(Hardware hardware, String runnerId, String os, String osArch, String executablePath) {
		if (!runnerId.equals(runnerId.toLowerCase())) {
			throw new IllegalArgumentException("Parameter 'runnerId' value " + runnerId + " must be lower case.");
		}
		RunnerPath runnerPath = new RunnerPath(hardware, runnerId, os, osArch, executablePath);
		runnerPaths.put(runnerPath.getKey(), runnerPath);
	}

	public RunnerPath getDefaultRunnerPath(Hardware hardware, String runnerId) {
		String os = Platform.getOS();
		String osArch = Platform.getOSArch();
		String key = RunnerPath.getKey(hardware, runnerId, os, osArch);
		RunnerPath runnerPath = runnerPaths.get(key);
		// Default to 32-bit version if 64-bit version not defined?
		if (runnerPath == null) {
			if (osArch.equals(Platform.ARCH_X86_64)) {
				osArch = Platform.ARCH_X86;
				key = RunnerPath.getKey(hardware, runnerId, os, osArch);
				runnerPath = runnerPaths.get(key);
			}
		}
		return runnerPath;
	}

	public String getDefaultRunnerAbsolutePath(Hardware hardware, String runnerId) {
		RunnerPath runnerPath = getDefaultRunnerPath(hardware, runnerId);
		if (runnerPath != null) {
			File file = runnerPath.getAbsoluteFile();
			if (file != null && file.canExecute()) {
				return file.getAbsolutePath();
			}
		}
		return "";
	}

	public List<RunnerPath> getRunnerPaths() {
		return Collections.unmodifiableList(new ArrayList<RunnerPath>(runnerPaths.values()));
	}

	public List<RunnerPath> getRunnerPaths(Hardware hardware, String id) {
		if (hardware == null) {
			throw new IllegalArgumentException("Parameter 'hardware' must not be null.");
		}
		if (id == null) {
			throw new IllegalArgumentException("Parameter 'id' must not be null.");
		}
		List<RunnerPath> result = new ArrayList<>();
		for (RunnerPath runnerPath : runnerPaths.values()) {
			if (runnerPath.hardware.equals(hardware) && runnerPath.runnerId.equals(id)) {
				result.add(runnerPath);
			}
		}
		return Collections.unmodifiableList(result);
	}

}