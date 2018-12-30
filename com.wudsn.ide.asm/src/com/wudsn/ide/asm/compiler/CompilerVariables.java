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

package com.wudsn.ide.asm.compiler;

/**
 * Utility class to handle dynamic variables.
 * 
 * @author Peter Dell
 */
public final class CompilerVariables {

    /**
     * Creation is private.
     */
    private CompilerVariables() {
    }

    public static final String SOURCE_FOLDER_PATH = "${sourceFolderPath}";
    public static final String SOURCE_FILE_PATH = "${sourceFilePath}";
    public static final String OUTPUT_FOLDER_PATH = "${outputFolderPath}";
    public static final String OUTPUT_FILE_PATH = "${outputFilePath}";
    public static final String OUTPUT_FILE_PATH_WITHOUT_EXTENSION = "${outputFilePathWithoutExtension}";
    public static final String OUTPUT_FILE_NAME = "${outputFileName}";
    public static final String OUTPUT_FILE_NAME_WITHOUT_EXTENSION = "${outputFileNameWithoutExtension}";
    public static final String OUTPUT_FILE_NAME_SHORT_WITHOUT_EXTENSION = "${outputFileNameShortWithoutExtension}";

    public static String replaceVariables(String parameter,
	    CompilerFiles files) {
	if (parameter == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'parameter' must not be null.");
	}
	if (files == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'files' must not be null.");
	}

	// When referring to the source file and folder at compiler time,
	// this always means the main source file.
	parameter = parameter.replace(SOURCE_FOLDER_PATH,
		files.mainSourceFile.folderPath);
	parameter = parameter.replace(SOURCE_FILE_PATH,
		files.mainSourceFile.filePath);
	parameter = parameter.replace(OUTPUT_FOLDER_PATH,
		files.outputFolderPath);
	parameter = parameter.replace(OUTPUT_FILE_PATH, files.outputFilePath);
	parameter = parameter.replace(OUTPUT_FILE_PATH_WITHOUT_EXTENSION,
		files.outputFilePathWithoutExtension);
	parameter = parameter.replace(OUTPUT_FILE_NAME, files.outputFileName);
	parameter = parameter.replace(OUTPUT_FILE_NAME_WITHOUT_EXTENSION,
		files.outputFileNameWithoutExtension);
	parameter = parameter.replace(OUTPUT_FILE_NAME_SHORT_WITHOUT_EXTENSION,
		files.outputFileNameShortWithoutExtension);

	return parameter;
    }

}