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
import com.wudsn.ide.lng.LanguagePlugin;

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

	/**
	 * Created by the {@linkplain LanguagePlugin}.
	 */
	public CompilerPaths() {
		compilerPaths = new TreeMap<String, CompilerPath>();
		// TODO: Complete default compiler paths for all assemblers and compilers DSAM/KickAss/TASS.
		// See https://github.com/peterdell/wudsn-ide-tools
		add(Language.ASM, "acme", Platform.OS_WIN32, Platform.ARCH_X86, "acme.exe");
		add(Language.ASM, "asm6", Platform.OS_WIN32, Platform.ARCH_X86, "asm6.exe");
		add(Language.ASM, "atasm", Platform.OS_LINUX, Platform.ARCH_X86, "atasm.linux-i386");
		add(Language.ASM, "atasm", Platform.OS_LINUX, Platform.ARCH_X86_64, "atasm.linux-x86-64");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_X86, "atasm.macos-i386");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_X86_64, "atasm.macos-x86-64");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_PPC, "atasm.macos-powerpc");
		add(Language.ASM, "atasm", Platform.OS_WIN32, Platform.ARCH_X86, "atasm.exe");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_X86, "mads.macos-i386");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_X86_64, "mads.macos-x86-64");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_PPC, "mads.macos-powerpc");
		add(Language.ASM, "mads", Platform.OS_WIN32, Platform.ARCH_X86_64, "mads.exe");
		add(Language.ASM, "xasm", Platform.OS_LINUX, Platform.ARCH_X86, "xasm.linux-i386");
		add(Language.ASM, "xasm", Platform.OS_MACOSX, Platform.ARCH_X86, "xasm.macos-i386");
		add(Language.ASM, "xasm", Platform.OS_WIN32, Platform.ARCH_X86, "xasm.exe");
		add(Language.PAS, "mp", Platform.OS_MACOSX, Platform.ARCH_X86_64, "mp.macos-x86-64");
		add(Language.PAS, "mp", Platform.OS_WIN32, Platform.ARCH_X86_64, "mp.exe");
	}

	private void add(Language language, String compilerId, String os, String osArch, String executablePath) {
		if (!compilerId.equals(compilerId.toLowerCase())) {
			throw new IllegalArgumentException("Parameter 'compilerId' value " + compilerId + " must be lower case.");
		}
		CompilerPath compilerPath = new CompilerPath(language, compilerId, os, osArch, executablePath);
		compilerPaths.put(compilerPath.getKey(), compilerPath);
	}

	private String getRelativePath(Language language, String compilerId) {
		String os = Platform.getOS();
		String osArch = Platform.getOSArch();
		String key = CompilerPath.getKey(language, compilerId, os, osArch);
		CompilerPath compilerPath = compilerPaths.get(key);
		if (compilerPath != null) {
			return compilerPath.getRelativePath();
		}
		return null;
	}

	/**
	 * Gets the absolute file path the default executable on the current OS and OS architecture.
	 * 
	 * @param language The language, not empty and not <code>null</code>.
	 * @param compilerId The compiler ID, not empty and not <code>null</code>.
	 * @return The file or <code>null</code> is no file could be determined.
	 */
	public File getAbsoluteFileForOSAndArch(Language language, String compilerId) {
		return getAbsoluteFile(getRelativePath(language, compilerId));
	}

	public File getAbsoluteFile(String relativePath) {
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
		File eclipseFolder = FileUtility.getCanonicalFile(new File(uri));
		File ideFolder = eclipseFolder.getParentFile();
		File toolsFolder = ideFolder.getParentFile();
		File compilerFile = new File(toolsFolder, relativePath);
		return compilerFile;
	}

	public List<CompilerPath> getCompilerPaths() {
		return Collections.unmodifiableList(new ArrayList<CompilerPath>(compilerPaths.values()));
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