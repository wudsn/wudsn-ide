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

package com.wudsn.ide.lng.editor;

import java.io.File;
import java.util.Map;
import java.util.TreeMap;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.text.Document;
import org.eclipse.jface.text.IDocument;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.MarkerUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.LanguageAnnotation;
import com.wudsn.ide.lng.LanguageAnnotationValues;
import com.wudsn.ide.lng.LanguageAnnotationValues.InvalidLanguageAnnotationException;
import com.wudsn.ide.lng.LanguageAnnotationValues.LanguageAnnotationValue;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerFiles;
import com.wudsn.ide.lng.compiler.CompilerOutputFolderMode;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;

/**
 * Logic to handle the {@link CompilerFiles} of an {@link LanguageEditor}
 * 
 * @author Peter Dell
 * 
 * @since 1.7.0
 */
public final class LanguageEditorFilesLogic {

	private LanguageEditor languageEditor;

	/**
	 * Create a new instance of the logic.
	 * 
	 * @param languageEditor The language editor, not <code>null</code>.
	 * 
	 * @return The new instance, not <code>null</code>.
	 */
	static LanguageEditorFilesLogic createInstance(LanguageEditor languageEditor) {
		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}

		LanguageEditorFilesLogic result = new LanguageEditorFilesLogic();
		result.languageEditor = languageEditor;
		return result;
	}

	/**
	 * Gets the container with all files related to the current files.
	 * 
	 * @return The container with all files related to the current files or
	 *         <code>null</code>.
	 */
	CompilerFiles createCompilerFiles() {
		IFile sourceIFile;
		CompilerFiles result;
		sourceIFile = languageEditor.getCurrentIFile();
		if (sourceIFile != null) {

			IDocument document = languageEditor.getDocumentProvider().getDocument(languageEditor.getEditorInput());
			LanguageAnnotationValues sourceFileProperties = CompilerSourceParser.getDocumentProperties(document);

			IFile mainSourceIFile;
			LanguageAnnotationValues mainSourceFileProperties;

			mainSourceIFile = sourceIFile;
			mainSourceFileProperties = sourceFileProperties;

			LanguageAnnotationValue property = sourceFileProperties.get(LanguageAnnotation.MAIN_SOURCE_FILE);
			if (property != null) {
				if (StringUtility.isSpecified(property.value)) {
					IPath mainSourceFileIPath;
					mainSourceFileIPath = sourceIFile.getFullPath().removeLastSegments(1).append(property.value);
					mainSourceIFile = ResourcesPlugin.getWorkspace().getRoot().getFile(mainSourceFileIPath);
					File mainSourceFile = new File(mainSourceIFile.getLocation().toOSString());

					try {
						String mainSource;

						mainSource = FileUtility.readString(mainSourceFile, FileUtility.MAX_SIZE_UNLIMITED);
						document = new Document(mainSource);
						mainSourceFileProperties = CompilerSourceParser.getDocumentProperties(document);
					} catch (CoreException ex) {
						LanguagePlugin plugin = LanguagePlugin.getInstance();

						plugin.logError("Cannot read main source file '{0'}", new Object[] { mainSourceFile.getPath() },
								ex);
						mainSourceFileProperties = new LanguageAnnotationValues();
					}

				}
			}
			result = new CompilerFiles(mainSourceIFile, mainSourceFileProperties, sourceIFile, sourceFileProperties,
					languageEditor.getLanguageHardwareCompilerPreferences());
		} else {
			result = null;
		}
		return result;
	}

	public boolean removeMarkers(CompilerFiles files) {
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}

		// Remove markers from the current file.
		try {
			files.sourceFile.iFile.deleteMarkers(IMarker.PROBLEM, true, IResource.DEPTH_INFINITE);
		} catch (CoreException ex) {
			languageEditor.getPlugin().logError("Cannot remove markers", null, ex);
		}

		// If the main source file is not there, the error shall be related to
		// the include source file. In all other cases, the main source file
		// exists and is the main message target.
		if (!files.mainSourceFile.iFile.exists()) {
			int lineNumber = files.sourceFile.languageAnnotationValues.get(LanguageAnnotation.MAIN_SOURCE_FILE).lineNumber;

			// ERROR: Main source file '{0}' does not exist.
			IMarker marker = MarkerUtility.createMarker(files.sourceFile.iFile, lineNumber, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E125, files.mainSourceFile.filePath);
			MarkerUtility.gotoMarker(languageEditor, marker);
			return false;
		}

		// Remove markers from the other relevant files.
		// TODO Use (only) include files parsed from main source file
		try {
			files.mainSourceFile.iFile.getParent().deleteMarkers(IMarker.PROBLEM, true, IResource.DEPTH_INFINITE);
		} catch (CoreException ex) {
			languageEditor.getPlugin().logError("Cannot remove markers", null, ex);
		}
		return true;
	}

	/**
	 * Determine the hardware defined by the value
	 * {@link LanguageAnnotationValues#HARDWARE}.
	 * 
	 * @param iFile      The IFile to which error message will be associated, not
	 *                   <code>null</code>.
	 * @param properties The language properties, not <code>null</code>.
	 * 
	 * @return The hardware or <code>null</code> if is the not defined in the
	 *         properties.
	 * @throws InvalidLanguageAnnotationException If the hardware is specified but
	 *                                          invalid. Error message will be
	 *                                          assigned to the iFile in this case.
	 * 
	 * @since 1.6.1
	 */
	Hardware getHardware(IFile iFile, LanguageAnnotationValues properties) throws InvalidLanguageAnnotationException {
		if (iFile == null) {
			throw new IllegalArgumentException("Parameter 'iFile' must not be null.");
		}
		Hardware hardware = null;
		LanguageAnnotationValue hardwareProperty = properties.get(LanguageAnnotation.HARDWARE);
		if (hardwareProperty != null) {
			Map<String, Hardware> allowedValues = new TreeMap<String, Hardware>();
			StringBuilder allowedValuesBuilder = new StringBuilder();
			for (Hardware value : Hardware.values()) {

				if (value != Hardware.GENERIC) {
					if (allowedValuesBuilder.length() > 0) {
						allowedValuesBuilder.append(",");
					}
					allowedValues.put(value.name(), value);
					allowedValuesBuilder.append(value.name());
				}
			}

			String hardwarePropertyValue = hardwareProperty.value.toUpperCase();
			if (StringUtility.isEmpty(hardwarePropertyValue)) {
				try {
					iFile.deleteMarkers(IMarker.PROBLEM, true, IResource.DEPTH_ZERO);
				} catch (CoreException ex) {
					LanguagePlugin.getInstance().logError("Cannot remove markers", null, ex);
				}
				// ERROR: Hardware not specified. Specify one of the
				// following valid values '{0}'.
				IMarker marker = MarkerUtility.createMarker(iFile, hardwareProperty.lineNumber, IMarker.SEVERITY_ERROR,
						Texts.MESSAGE_E128, new String[] { allowedValuesBuilder.toString() });
				throw new InvalidLanguageAnnotationException(hardwareProperty, marker);
			}
			hardware = allowedValues.get(hardwarePropertyValue);

			if (hardware == null) {
				try {
					iFile.deleteMarkers(IMarker.PROBLEM, true, IResource.DEPTH_ZERO);
				} catch (CoreException ex) {
					languageEditor.getPlugin().logError("Cannot remove markers", null, ex);
				}
				// ERROR: Unknown hardware {0}. Specify one of the
				// following valid values '{1}'.
				IMarker marker = MarkerUtility.createMarker(iFile, hardwareProperty.lineNumber, IMarker.SEVERITY_ERROR,
						Texts.MESSAGE_E124, new String[] { hardwarePropertyValue, allowedValuesBuilder.toString() });
				throw new InvalidLanguageAnnotationException(hardwareProperty, marker);
			}

		}
		return hardware;
	}

	/**
	 * Determine the hardware of the main source file and makes sure that the
	 * include file uses the same hardware.
	 * 
	 * @param files The compiler files, not <code>null</code>.
	 * @return The hardware to be used, or <code>null</code> if errors have
	 *         occurred.
	 * 
	 * @since 1.6.1
	 */
	public Hardware getHardware(CompilerFiles files) {
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		Hardware mainSourceFileHardware;
		Hardware sourceFileHardware;
		try {
			sourceFileHardware = getHardware(files.sourceFile.iFile, files.sourceFile.languageAnnotationValues);
		} catch (InvalidLanguageAnnotationException ex) {
			MarkerUtility.gotoMarker(languageEditor, ex.marker);
			return null;
		}
		try {
			mainSourceFileHardware = getHardware(files.mainSourceFile.iFile, files.mainSourceFile.languageAnnotationValues);
		} catch (InvalidLanguageAnnotationException ex) {
			MarkerUtility.gotoMarker(languageEditor, ex.marker);
			return null;
		}
		Hardware defaultHardware = languageEditor.getCompilerDefinition().getDefaultHardware();
		int sourceFileLineNumber;
		int mainSourceFileLineNumber;
		if (sourceFileHardware == null) {
			sourceFileHardware = defaultHardware;
			sourceFileLineNumber = 0;
		} else {
			sourceFileLineNumber = files.sourceFile.languageAnnotationValues.get(LanguageAnnotation.HARDWARE).lineNumber;
		}
		if (mainSourceFileHardware == null) {
			mainSourceFileHardware = defaultHardware;
			mainSourceFileLineNumber = 0;
		} else {
			mainSourceFileLineNumber = files.mainSourceFile.languageAnnotationValues
					.get(LanguageAnnotation.HARDWARE).lineNumber;
		}

		if (!sourceFileHardware.equals(mainSourceFileHardware)) {
			// ERROR: Main source file specifies or defaults to hardware {0}
			// while include file specifies or defaults to hardware '{1}'.
			MarkerUtility.createMarker(files.mainSourceFile.iFile, mainSourceFileLineNumber, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E129, new String[] { mainSourceFileHardware.name(), sourceFileHardware.name() });
			MarkerUtility.createMarker(files.sourceFile.iFile, sourceFileLineNumber, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E129, new String[] { mainSourceFileHardware.name(), sourceFileHardware.name() });
			return null;
		}
		return mainSourceFileHardware;
	}

	/**
	 * Validates the output file related settings of the compiler files.
	 * 
	 * @param files The compiler files, not <code>null</code>.
	 * @return <code>true</code> if all settings are correct, <code>false</code>
	 *         otherwise.
	 */
	public boolean validateOutputFile(CompilerFiles files) {
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		CompilerDefinition compilerDefinition = languageEditor.getCompilerDefinition();
		if (StringUtility.isEmpty(files.outputFileExtension)) {
			// ERROR: Output file extension must be set in the preferences of {0} '{1}' or
			// via the annotation '{2}'.
			createMainSourceFileMessage(files, files.outputFileExtensionProperty, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E104, compilerDefinition.getText(), compilerDefinition.getName(),
					LanguageAnnotation.OUTPUT_FILE_EXTENSION);

			return false;
		}
		if (!files.outputFileExtension.startsWith(".")) {
			// ERROR: Output file extension {0} must start with ".".
			createMainSourceFileMessage(files, files.outputFileExtensionProperty, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E139, files.outputFileExtension);
			return false;
		}

		if (StringUtility.isEmpty(files.outputFolderMode)) {
			// ERROR: Output folder mode be set in the preferences of
			// compiler '{0}' or via the annotation '{1}'.
			createMainSourceFileMessage(files, files.outputFolderModeProperty, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E140, compilerDefinition.getName(), LanguageAnnotation.OUTPUT_FOLDER_MODE);

			return false;
		}
		if (!CompilerOutputFolderMode.isDefined(files.outputFolderMode)) {
			// ERROR: Unknown output folder mode {0}. Specify one of the
			// following valid values '{1}'.
			createMainSourceFileMessage(files, files.outputFolderModeProperty, IMarker.SEVERITY_ERROR,
					Texts.MESSAGE_E141, files.outputFolderMode, CompilerOutputFolderMode.getAllowedValues());
			return false;

		}

		return true;
	}

	/**
	 * Creates a message associated with the main source file of an
	 * {@link LanguageEditorFilesLogic} instance. The message is is bound to the
	 * line number number of the value (if available). Also the editor is
	 * position to the marker.
	 * 
	 * @param files      The {@link CompilerFiles} not <code>null</code>.
	 * @param value   The language value to which the message belongs or
	 *                   <code>null</code>.
	 * @param severity   The message severity, see {@link IMarker#SEVERITY}
	 * @param message    The message, may contain parameter "{0}" to "{9}". May be
	 *                   empty, not <code>null</code>.
	 * @param parameters The format parameters for the message, may be empty, not
	 *                   <code>null</code>.
	 */
	private void createMainSourceFileMessage(CompilerFiles files, LanguageAnnotationValue property, int severity,
			String message, String... parameters) {
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		IMarker marker = MarkerUtility.createMarker(files.mainSourceFile.iFile,
				(property == null ? 0 : property.lineNumber), severity, message, parameters);
		MarkerUtility.gotoMarker(languageEditor, marker);

	}

}