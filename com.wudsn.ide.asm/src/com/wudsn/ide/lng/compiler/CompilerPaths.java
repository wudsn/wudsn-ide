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

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.runtime.Platform;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.lng.Language;

/**
 * Computation of default paths for compilers.
 * 
 * @author Peter Dell
 * 
 * @since 1.7.2
 *
 */
public final class CompilerPaths {

	public static final class CompilerPath {
		public final Language language;
		public final String compilerId;
		public final String os;
		public final String osArch;
		public final String executablePath;

		private CompilerPath(Language language, String compilerId, String os, String osArch, String executablePath) {
			this.language = language;
			this.compilerId = compilerId;
			this.os = os;
			this.osArch = osArch;
			this.executablePath = executablePath;

		}

		public static String getKey(Language language, String compilerId, String os, String osArch) {
			return language.name() + "/" + compilerId + "/" + os + "/" + osArch;
		}

		public String getKey() {
			return getKey(language, compilerId, os, osArch);
		}

		public String getRelativePath() {
			return language.name() + "/" + compilerId.toUpperCase() + "/" + executablePath;
		}

	}

	private Map<String, CompilerPath> compilerPaths;

	// TODO: Make provide 
	public CompilerPaths() {
		compilerPaths = new TreeMap<String, CompilerPath>();
		add(Language.ASM, "mads", Platform.OS_WIN32, Platform.ARCH_X86_64, "mads.exe");
		add(Language.PAS, "MP", Platform.OS_WIN32, Platform.ARCH_X86_64, "mp.exe"); //TODO make IDs all uppercase?

	}

	private void add(Language language, String compilerId, String os, String osArch, String executablePath) {
		CompilerPath compilerPath = new CompilerPath(language, compilerId, os, osArch, executablePath);
		compilerPaths.put(compilerPath.getKey(), compilerPath);
	}

	public String getRelativePath(Language language, String compilerId) {
		String os = Platform.getOS();
		String osArch = Platform.getOSArch();
		String key = CompilerPath.getKey(language, compilerId, os, osArch);
		CompilerPath compilerPath = compilerPaths.get(key);
		if (compilerPath != null) {
			return compilerPath.getRelativePath();
		}
		return null;
	}

	public File getAbsoluteFile(Language language, String compilerId) {
		String path = getRelativePath(language, compilerId);

		if (path == null) {
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
		File eclipseFolder = FileUtility.getCanonicalFile(new File(uri));
		File ideFolder = eclipseFolder.getParentFile();
		File toolsFolder = ideFolder.getParentFile();
		File compilerFile = new File(toolsFolder, path);
		return compilerFile;
	}

	public List<CompilerPath> getCompilerPaths(Language language, String id) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (id == null) {
			throw new IllegalArgumentException("Parameter 'id' must not be null.");
		}
		List<CompilerPath> result = new ArrayList<>();
		for (CompilerPath compilerPath : compilerPaths.values()) {
			if (compilerPath.language.equals(language) && compilerPath.compilerId.equals(id)) {
				result.add(compilerPath);
			}
		}
		return Collections.unmodifiableList(result);
	}

}