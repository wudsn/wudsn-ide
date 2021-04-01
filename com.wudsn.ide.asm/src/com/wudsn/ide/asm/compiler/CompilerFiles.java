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

package com.wudsn.ide.asm.compiler;

import java.io.File;

import org.eclipse.core.resources.IFile;

import com.wudsn.ide.asm.AssemblerProperties;
import com.wudsn.ide.asm.AssemblerProperties.AssemblerProperty;
import com.wudsn.ide.asm.preferences.CompilerPreferences;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;

/**
 * Container class for the folder, file names and paths of the source file, the
 * output file and the symbols file.
 * 
 * @author Peter Dell
 * 
 */
public final class CompilerFiles {

    public final class SourceFile {

	public final IFile iFile;

	public final File folder;
	public final String folderPath;

	public final File file;
	public final String filePath;
	public final String fileName;
	public final String fileNameWithoutExtension;

	public final AssemblerProperties assemblerProperties;

	SourceFile(IFile iFile, AssemblerProperties assemblerProperties) {

	    if (iFile == null) {
		throw new IllegalArgumentException("Parameter 'iFile' must not be null.");
	    }
	    if (assemblerProperties == null) {
		throw new IllegalArgumentException("Parameter 'assemblerProperties' must not be null.");
	    }

	    this.iFile = iFile;
	    this.assemblerProperties = assemblerProperties;

	    // Source file.
	    filePath = iFile.getLocation().toOSString();
	    file = FileUtility.getCanonicalFile(new File(filePath));
	    fileName = file.getName();

	    String extension = iFile.getFileExtension();
	    if (extension == null) {
		extension = "";
	    }
	    fileNameWithoutExtension = fileName.substring(0, fileName.length() - extension.length() - 1);

	    // Source folder.
	    folder = file.getParentFile();
	    folderPath = folder.getPath();
	}
    }

    /**
     * The actual source file which is currently open.
     */
    public final SourceFile sourceFile;

    /**
     * The main source file which is either the current file or the file
     * indicated by the property "@com.wudsn.ide.asm.editor.MainSourceFile".
     */
    public final SourceFile mainSourceFile;

    public final AssemblerProperty outputFolderModeProperty;
    public final String outputFolderMode;

    public final AssemblerProperty outputFolderProperty;
    public final File outputFolder;
    public final String outputFolderPath;

    public final File outputFile;
    public final String outputFilePath;
    public final String outputFilePathWithoutExtension;

    public final AssemblerProperty outputFileProperty;
    public final String outputFileName;
    public final String outputFileNameWithoutExtension;
    public final AssemblerProperty outputFileExtensionProperty;
    public final String outputFileExtension;
    public final String outputFileNameShortWithoutExtension;

    public final File symbolsFile;
    public final String symbolsFilePath;
    public final String symbolsFileName;

    public CompilerFiles(IFile mainSourceIFile, AssemblerProperties mainSourceFileAssemblerProperties,
	    IFile sourceIFile, AssemblerProperties sourceFileAssemblerProperties,
	    CompilerPreferences compilerPreferences) {

	if (mainSourceIFile == null) {
	    throw new IllegalArgumentException("Parameter 'mainSourceIFile' must not be null.");
	}
	if (sourceIFile == null) {
	    throw new IllegalArgumentException("Parameter 'sourceIFile' must not be null.");
	}
	if (compilerPreferences == null) {
	    throw new IllegalArgumentException("Parameter 'compilerPreferences' must not be null.");
	}
	this.mainSourceFile = new SourceFile(mainSourceIFile, mainSourceFileAssemblerProperties);
	this.sourceFile = new SourceFile(sourceIFile, sourceFileAssemblerProperties);

	// Output folder mode
	// Can be overridden via annotation property in main source file
	String localOutputFolderPath = compilerPreferences.getOutputFolderPath();
	String localOutputFolderMode = compilerPreferences.getOutputFolderMode();
	String localOutputFileExtension = compilerPreferences.getOutputFileExtension();

	// Properties which override the preferences
	outputFolderModeProperty = mainSourceFileAssemblerProperties.get(AssemblerProperties.OUTPUT_FOLDER_MODE);
	outputFolderProperty = mainSourceFileAssemblerProperties.get(AssemblerProperties.OUTPUT_FOLDER);
	outputFileExtensionProperty = mainSourceFileAssemblerProperties.get(AssemblerProperties.OUTPUT_FILE_EXTENSION);
	outputFileProperty = mainSourceFileAssemblerProperties.get(AssemblerProperties.OUTPUT_FILE);

	// The following sequence sets the instance fields "outputFolder" and
	// "outputFileNameWithoutExtension" as well as the
	// "outputFileNameWithoutExtension".
	// If the output file is specified explicitly, it overrides all output
	// properties.
	if (outputFileProperty != null) {

	    // Make the file an absolute file.
	    File file = new File(outputFileProperty.value);
	    if (!file.isAbsolute()) {
		file = new File(mainSourceFile.file.getParentFile(), file.getPath());
	    }
	    file = FileUtility.getCanonicalFile(file);

	    outputFolderMode = CompilerOutputFolderMode.FIXED_FOLDER;
	    outputFolder = file.getParentFile();

	    // Split the file name and file extension.
	    String fileName = file.getName();
	    int index = fileName.lastIndexOf('.');
	    if (index > 0) {
		outputFileNameWithoutExtension = fileName.substring(0, index);
		localOutputFileExtension = fileName.substring(index);
	    } else {
		outputFileNameWithoutExtension = fileName;
		localOutputFileExtension = "";
	    }
	} else {
	    // The output file extension is independent of the rest.
	    if (outputFileExtensionProperty != null) {
		localOutputFileExtension = outputFileExtensionProperty.value;
	    }
	    // If the output folder mode is specified explicitly, it overrides
	    // the output
	    // folder mode preferences.
	    if (outputFolderModeProperty != null) {
		localOutputFolderMode = outputFolderModeProperty.value;
	    }

	    // If the output folder is specified explicitly, it overrides the
	    // output folder mode and folder preferences.
	    if (outputFolderProperty != null) {
		localOutputFolderMode = CompilerOutputFolderMode.FIXED_FOLDER;
		localOutputFolderPath = outputFolderProperty.value;
	    }

	    if (localOutputFolderMode.equals(CompilerOutputFolderMode.SOURCE_FOLDER)) {
		localOutputFolderPath = mainSourceFile.folderPath;
	    } else if (localOutputFolderMode.equals(CompilerOutputFolderMode.FIXED_FOLDER)) {
		// Fallback
		if (StringUtility.isEmpty(localOutputFolderPath)) {
		    localOutputFolderPath = System.getProperty("java.io.tmpdir");
		}
	    } else {
		localOutputFolderPath = System.getProperty("java.io.tmpdir");
	    }

	    File file = new File(localOutputFolderPath);
	    if (!file.isAbsolute()) {
		file = new File(sourceFile.file, file.getPath());
	    }
	    file = FileUtility.getCanonicalFile(file);

	    outputFolderMode = localOutputFolderMode;
	    outputFolder = file;

	    // Output file.
	    outputFileNameWithoutExtension = mainSourceFile.fileNameWithoutExtension;
	}

	// Common output parts.
	outputFolderPath = outputFolder.getPath();
	outputFileNameShortWithoutExtension = getFileNameShort(outputFileNameWithoutExtension);
	outputFileName = outputFileNameWithoutExtension + localOutputFileExtension;
	outputFileExtension = localOutputFileExtension;
	outputFile = new File(outputFolder, outputFileName);
	outputFilePath = outputFile.getPath();
	outputFilePathWithoutExtension = new File(outputFolder, outputFileNameWithoutExtension).getPath();

	// Symbols file.
	symbolsFileName = mainSourceFile.fileNameWithoutExtension + ".lbl";
	symbolsFile = new File(outputFolder, symbolsFileName);
	symbolsFilePath = symbolsFile.getPath();

    }

    /**
     * Computes a short file consisting of at most 8 ASCII letters and digits
     * which starts with a letter.
     * 
     * @param fileName
     *            The file name, may be empty, not <code>null</code>.
     * @return The short file, name, not empty and not <code>null</code>.
     */
    private String getFileNameShort(String fileName) {
	if (fileName == null) {
	    throw new IllegalArgumentException("Parameter 'fileName' must not be null.");
	}
	StringBuilder builder = new StringBuilder(fileName);
	for (int i = 0; i < fileName.length() && builder.length() < 8; i++) {
	    char c = fileName.charAt(i);
	    c = Character.toUpperCase(c);
	    if (c >= 'A' && c <= 'Z' && (builder.length() > 0) || c >= '0' && c <= '9') {
		builder.append(c);
	    }
	}
	if (builder.length() == 0) {
	    return "UNKNOWN";
	}
	return builder.toString();
    }
}