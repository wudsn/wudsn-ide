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
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.runtime.Platform;

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
		public final CompilerDefinition compilerDefinition;
		public final String os;
		public final String osArch;
		public final String executablePath;

		private CompilerPath(Language language, CompilerDefinition compilerDefinition, String os, String osArch,
				String executablePath) {
			this.language = language;
			this.compilerDefinition = compilerDefinition;
			this.os = os;
			this.osArch = osArch;
			this.executablePath = executablePath;

		}

		public static String getKey(Language language, CompilerDefinition compilerDefinition, String os,
				String osArch) {
			return language.name() + "/" + compilerDefinition.getId() + "/" + os + "/" + osArch;
		}

		public String getKey() {
			return getKey(language, compilerDefinition, os, osArch);
		}

		public String getRelativePath() {
			return language.name() + "/" + compilerDefinition.getId().toUpperCase() + "/" + executablePath;
		}

		public File getAbsoluteFile() {
			return LanguagePlugin.getInstance().getAbsoluteToolsFile(getRelativePath());
		}

	}

	private Map<String, CompilerPath> compilerPaths;

	/**
	 * Created by the {@linkplain LanguagePlugin}.
	 */
	public CompilerPaths() {
	}
	
	/**
	 * Initialize the default paths.
	 */
	public void init() {
		compilerPaths = new TreeMap<String, CompilerPath>();
		// See https://github.com/peterdell/wudsn-ide-tools
		// TODO: Add MERLIN32
		add(Language.ASM, "acme", Platform.OS_WIN32, Platform.ARCH_X86, "acme.exe");
		add(Language.ASM, "asm6", Platform.OS_WIN32, Platform.ARCH_X86, "asm6.exe");
		add(Language.ASM, "atasm", Platform.OS_LINUX, Platform.ARCH_X86, "atasm.linux-i386");
		add(Language.ASM, "atasm", Platform.OS_LINUX, Platform.ARCH_X86_64, "atasm.linux-x86-64");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_X86, "atasm.macos-i386");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_X86_64, "atasm.macos-x86-64");
		add(Language.ASM, "atasm", Platform.OS_MACOSX, Platform.ARCH_PPC, "atasm.macos-powerpc");
		add(Language.ASM, "atasm", Platform.OS_WIN32, Platform.ARCH_X86, "atasm.exe");
		add(Language.ASM, "dasm", Platform.OS_LINUX, Platform.ARCH_X86, "bin/dasm.linux-i386");
		add(Language.ASM, "dasm", Platform.OS_LINUX, Platform.ARCH_X86_64, "bin/dasm.linux-x86-64");
		add(Language.ASM, "dasm", Platform.OS_MACOSX, Platform.ARCH_X86, "bin/dasm.macos-i386");
		add(Language.ASM, "dasm", Platform.OS_MACOSX, Platform.ARCH_X86_64, "bin/dasm.macos-x86-64");
		add(Language.ASM, "dasm", Platform.OS_WIN32, Platform.ARCH_X86, "bin/dasm.exe");
		add(Language.ASM, "kickass", Platform.OS_LINUX, Platform.ARCH_X86, "KickAss.jar");
		add(Language.ASM, "kickass", Platform.OS_MACOSX, Platform.ARCH_X86, "KickAss.jar");
		add(Language.ASM, "kickass", Platform.OS_WIN32, Platform.ARCH_X86, "KickAss.jar");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_X86, "mads.macos-i386");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_X86_64, "mads.macos-x86-64");
		add(Language.ASM, "mads", Platform.OS_MACOSX, Platform.ARCH_PPC, "mads.macos-powerpc");
		add(Language.ASM, "mads", Platform.OS_WIN32, Platform.ARCH_X86_64, "mads.exe");
		add(Language.ASM, "tass", Platform.OS_WIN32, Platform.ARCH_X86, "64tass.exe");
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
		var compilerDefinition = LanguagePlugin.getInstance().getCompilerRegistry().getCompilerDefinitionById(language, compilerId);
		CompilerPath compilerPath = new CompilerPath(language, compilerDefinition, os, osArch, executablePath);
		compilerPaths.put(compilerPath.getKey(), compilerPath);
	}

	public CompilerPath getDefaultCompilerPath(Language language, CompilerDefinition compilerDefinition) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (compilerDefinition == null) {
			throw new IllegalArgumentException("Parameter 'compilerDefinition' must not be null.");
		}
		String os = Platform.getOS();
		String osArch = Platform.getOSArch();
		String key = CompilerPath.getKey(language, compilerDefinition, os, osArch);
		CompilerPath compilerPath = compilerPaths.get(key);
		// Default to 32-bit version if 64-bit version not defined?
		if (compilerPath == null) {
			if (osArch.equals(Platform.ARCH_X86_64)) {
				osArch = Platform.ARCH_X86;
				key = CompilerPath.getKey(language, compilerDefinition, os, osArch);
				compilerPath = compilerPaths.get(key);
			}
		}
		return compilerPath;
	}

	public List<CompilerPath> getCompilerPaths() {
		return Collections.unmodifiableList(new ArrayList<CompilerPath>(compilerPaths.values()));
	}

	public List<CompilerPath> getCompilerPaths(Language language, String compilerId) {
		if (language == null) {
			throw new IllegalArgumentException("Parameter 'language' must not be null.");
		}
		if (compilerId == null) {
			throw new IllegalArgumentException("Parameter 'compilerId' must not be null.");
		}
		List<CompilerPath> result = new ArrayList<>();
		for (CompilerPath compilerPath : compilerPaths.values()) {
			if (compilerPath.language.equals(language) && compilerPath.compilerDefinition.getId().equals(compilerId)) {
				result.add(compilerPath);
			}
		}
		return Collections.unmodifiableList(result);
	}

}