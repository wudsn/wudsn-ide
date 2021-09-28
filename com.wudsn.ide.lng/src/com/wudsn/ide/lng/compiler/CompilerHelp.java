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
import java.util.ArrayList;
import java.util.List;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.lng.compiler.CompilerDefinition.HelpDocument;

/**
 * Compiler help access.
 * 
 * @author Peter Dell
 *
 * @since 1.7.2
 */
public final class CompilerHelp {

	public static class InstalledHelpDocument {
		public String path;
		public String language;
		public File file;
		public URI uri;
	}

	public static List<InstalledHelpDocument> getInstalledHelpDocuments(List<HelpDocument> list,
			String compilerExecutablePath) {
		var result = new ArrayList<CompilerHelp.InstalledHelpDocument>();

		for (var helpDocument : list) {

			var installeHelpDocument = new InstalledHelpDocument();
			installeHelpDocument.path = helpDocument.path;
			installeHelpDocument.language = helpDocument.language;

			// Relative paths are local files.
			if (installeHelpDocument.path.startsWith(".") && StringUtility.isSpecified(compilerExecutablePath)) {
				installeHelpDocument.file = FileUtility.getCanonicalFile(
						new File(new File(compilerExecutablePath).getParent(), installeHelpDocument.path));
			} else {
				try {
					installeHelpDocument.uri = new URI(installeHelpDocument.path);
				} catch (URISyntaxException ex) {
					throw new RuntimeException("Invalid URI for '" + helpDocument.path + "' help file path", ex);
				}
			}
			result.add(installeHelpDocument);
		}
		return result;
	}
}