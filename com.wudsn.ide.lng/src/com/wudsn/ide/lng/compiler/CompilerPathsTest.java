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
import java.util.List;

import com.wudsn.ide.base.common.Test;
import com.wudsn.ide.base.common.TestMethod;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerPaths.CompilerPath;

/**
 * Computation of default paths for compilers.
 * 
 * @author Peter Dell
 * 
 * @since 1.7.2
 *
 */
public final class CompilerPathsTest {

	@TestMethod
	public static void main(String[] args) {
		CompilerPaths compilerPaths = LanguagePlugin.getInstance().getCompilerPaths();
		List<CompilerPath> compilerPathList = compilerPaths.getCompilerPaths();
		for (CompilerPath compilerPath : compilerPathList) {
			File file = compilerPath.getAbsoluteFile();
			String filePath = "";
			String result = "NOT defined";
			if (file != null) {
				filePath = file.getAbsolutePath();
				result = file.exists() ? "found" : "NOT found";
			}
			Test.log("Language " + compilerPath.language + ", compiler " + compilerPath.compilerId + ", OS "
					+ compilerPath.os + ", OS architecture " + compilerPath.osArch + ": File " + filePath + " "
					+ result);
		}
	}

}