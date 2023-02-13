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
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.debug.core.DebugPlugin;
import org.eclipse.debug.core.IBreakpointManager;
import org.eclipse.debug.core.model.IBreakpoint;
import org.eclipse.swt.program.Program;
import org.eclipse.ui.IPageLayout;
import org.eclipse.ui.IViewReference;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchPart;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.console.IConsoleConstants;
import org.eclipse.ui.console.IConsoleView;
import org.eclipse.ui.ide.IDE;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.MarkerUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.ProcessWithLogs;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.HardwareUtility;
import com.wudsn.ide.lng.LanguageAnnotation;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.LanguageUtility;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.breakpoint.LanguageBreakpoint;
import com.wudsn.ide.lng.compiler.Compiler;
import com.wudsn.ide.lng.compiler.CompilerConsole;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.CompilerFileWriter;
import com.wudsn.ide.lng.compiler.CompilerFiles;
import com.wudsn.ide.lng.compiler.CompilerFiles.SourceFile;
import com.wudsn.ide.lng.compiler.CompilerProcessLogParser;
import com.wudsn.ide.lng.compiler.CompilerProcessLogParser.Marker;
import com.wudsn.ide.lng.compiler.CompilerSymbol;
import com.wudsn.ide.lng.compiler.CompilerVariables;
import com.wudsn.ide.lng.preferences.CompilerRunPreferences;
import com.wudsn.ide.lng.runner.Runner;
import com.wudsn.ide.lng.runner.RunnerDefinition;
import com.wudsn.ide.lng.runner.RunnerId;
import com.wudsn.ide.lng.symbol.CompilerSymbolsView;

/**
 * Implementation of the "Compile" command.
 * 
 * @author Peter Dell
 */
final class LanguageEditorCompileCommand {

	/**
	 * Commands.
	 */
	public static final String COMPILE = "com.wudsn.ide.lng.editor.LanguageEditorCompileCommand";
	public static final String COMPILE_AND_RUN = "com.wudsn.ide.lng.editor.LanguageEditorCompileAndRunCommand";
	public static final String COMPILE_AND_RUN_WITH = "com.wudsn.ide.lng.editor.LanguageEditorCompileAndRunWithCommand";

	/**
	 * The owning plugin.
	 */
	private LanguagePlugin plugin;

	/**
	 * Creation is private.
	 */
	private LanguageEditorCompileCommand() {
		plugin = LanguagePlugin.getInstance();
	}

	/**
	 * Creates a message associated with the main source file of an
	 * {@link CompilerFiles} instance. The message is not bound to a line number.
	 * 
	 * @param files      The {@link CompilerFiles} not <code>null</code>.
	 * @param severity   The message severity, see {@link IMarker#SEVERITY}
	 * @param message    The message, may contain parameter "{0}" to "{9}". May be
	 *                   empty, not <code>null</code>.
	 * @param parameters The format parameters for the message, may be empty, not
	 *                   <code>null</code>.
	 */
	private void createMainSourceFileMessage(CompilerFiles files, int severity, String message, String... parameters) {
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		MarkerUtility.createMarker(files.mainSourceFile.iFile, 0, severity, message, parameters);
	}

	/**
	 * Executes a compile command.
	 * 
	 * @param languageEditor The language editor, not <code>null</code>.
	 * @param files          The compiler files, not <code>null</code>.
	 * @param commandId      The command id, see {@link #COMPILE},
	 *                       {@link #COMPILE_AND_RUN} ,
	 *                       {@link #COMPILE_AND_RUN_WITH}.
	 * @param runnerId       The runner id, may be empty or <code>null</code>.
	 * 
	 * @throws RuntimeException
	 */
	public static void execute(LanguageEditor languageEditor, CompilerFiles files, String commandId, String runnerId)
			throws RuntimeException {

		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (commandId == null) {
			throw new IllegalArgumentException("Parameter 'commandId' must not be null.");
		}

		// Ensure all current changes in all open editors are saved.
		if (!IDE.saveAllEditors(new IResource[] { ResourcesPlugin.getWorkspace().getRoot() }, false)) {
			return;
		}

		languageEditor.doSave(null);

		IWorkbenchPage page = languageEditor.getSite().getPage();

		LanguageEditorCompileCommand instance;
		instance = new LanguageEditorCompileCommand();

		try {
			instance.executeInternal(languageEditor, files, commandId, runnerId);
		} catch (RuntimeException ex) {
			throw ex;
		}

		try {
			// Remember active editor.
			IWorkbenchPart activePart = page.getActivePart();

			// Show console.
			CompilerConsole compilerConsole = instance.plugin.getCompilerConsole();
			IConsoleView consoleView = (IConsoleView) page.showView(IConsoleConstants.ID_CONSOLE_VIEW);
			compilerConsole.display(consoleView);

			// Show problems view.
			page.showView(IPageLayout.ID_PROBLEM_VIEW);

			// Reactivate previously active editor.
			page.activate(activePart);

		} catch (PartInitException ex) {
			throw new RuntimeException("Cannot show view.", ex);
		}
	}

	private boolean executeInternal(LanguageEditor languageEditor, CompilerFiles files, String commandId,
			String runnerId) {

		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (commandId == null) {
			throw new IllegalArgumentException("Parameter 'commandId' must not be null.");
		}

		LanguageEditorFilesLogic languageEditorFilesLogic = LanguageEditorFilesLogic.createInstance(languageEditor);

		// Remove existing problem markers from all files.
		if (!languageEditorFilesLogic.removeMarkers(files)) {
			return false;
		}

		// Check annotations
		checkAnnotations(files.mainSourceFile);
		if (!files.sourceFile.filePath.equals(files.mainSourceFile.filePath)) {
			checkAnnotations(files.sourceFile);
		}

		// Determine and check hardware.
		Hardware hardware = languageEditorFilesLogic.getHardware(files);
		if (hardware == null) {
			return false;
		}

		// Check files based on the compiler definition.
		if (!languageEditorFilesLogic.validateOutputFile(files)) {
			return false;
		}

		// Create wrapper for run properties.
		CompilerDefinition compilerDefinition = languageEditor.getCompilerDefinition();
		CompilerRunPreferences compilerRunPreferences = new CompilerRunPreferences(
				languageEditor.getLanguageHardwareCompilerPreferences(), files.mainSourceFile.languageAnnotationValues);

		// Check if output file is modifiable in case it already exists.
		long outputFileLastModified = -1;
		if (files.outputFile.exists()) {
			boolean canWrite = files.outputFile.canWrite();
			if (canWrite) {
				try {
					FileOutputStream fos = new FileOutputStream(files.outputFile, true);
					try {
						fos.close();
					} catch (IOException ex) {
						plugin.logError("Cannot close file output stream", null, ex);
					}
				} catch (FileNotFoundException ex) {
					canWrite = false;
				}

			}
			if (!canWrite) {
				// ERROR: Output file '{0}' cannot be opened for writing. End
				// all applications which may keep the file open.
				createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E106, files.outputFileName);
				return false;
			}
			outputFileLastModified = files.outputFile.lastModified();
		}

		// Get and check path to compiler executable.
		String compilerPreferencesText = LanguageUtility.getCompilerPreferencesText(compilerDefinition.getLanguage());
		String compilerExecutablePath = languageEditor.getLanguagePreferences()
				.getCompilerExecutablePathOrDefault(compilerDefinition);
		if (StringUtility.isEmpty(compilerExecutablePath)) {
			// ERROR: Path to {0} '{1}' executable is not set in the '{2}' preferences.
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E100, compilerDefinition.getText(),
					compilerDefinition.getName(), compilerPreferencesText);
			return false;
		}
		File compilerExecutableFile = new File(compilerExecutablePath);
		if (!compilerExecutableFile.exists()) {
			// ERROR: Path to {0} '{1}' executable in the '{2}' preferences points to
			// non-existing file '{3}'.
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E103, compilerDefinition.getText(),
					compilerDefinition.getName(), compilerPreferencesText, compilerExecutablePath);
			return false;
		}

		// Get and check compiler executable parameters.
		String compilerParameters = compilerRunPreferences.getParameters();
		if (StringUtility.isEmpty(compilerParameters)) {
			compilerParameters = compilerDefinition.getDefaultParameters();
		}

		// The parameters are first split and then substituted.
		// This allows for parameters and file paths inner spaces to be used.
		// In some case addition quotes must be places around parameters, for
		// example for the "${sourceFilePath}". This can be used to avoid
		// problems with absolute file path under Unix starting with "/" or path
		// containing white spaces.
		compilerParameters = compilerParameters.trim();
		String compilerParameterArray[] = compilerParameters.split(" ");
		if (compilerParameterArray.length == 0) {
			// ERROR: The {0} '{1}' does not specify default parameters.
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E101, compilerDefinition.getText(),
					compilerDefinition.getName());
			return false;
		}

		// From here on, the method is linear, i.e. there is no "return" until
		// the end.

		// Special handling for direct execution of ".jar" files.
		String[] fullCommandLineArray;
		int offset;
		if (compilerExecutablePath.toLowerCase().endsWith(".jar")) {
			offset = 3;
			fullCommandLineArray = new String[offset + compilerParameterArray.length];
			fullCommandLineArray[0] = "java";
			fullCommandLineArray[1] = "-jar";
			fullCommandLineArray[2] = compilerExecutablePath;
		} else {
			offset = 1;
			fullCommandLineArray = new String[offset + compilerParameterArray.length];
			fullCommandLineArray[0] = compilerExecutablePath;
		}

		// Map parameter with variables replacement.
		for (int i = 0; i < compilerParameterArray.length; i++) {
			String parameter = compilerParameterArray[i];
			parameter = CompilerVariables.replaceVariables(parameter, files);
			fullCommandLineArray[i + offset] = parameter;
		}

		ProcessWithLogs compilerProcess = new ProcessWithLogs(fullCommandLineArray, files.mainSourceFile.folder);
		CompilerConsole compilerConsole = plugin.getCompilerConsole();
		compilerConsole.println("");
		compilerConsole.println("Compiling for hardware " + hardware.name() + " on "
				+ new SimpleDateFormat().format(new Date()) + ": " + compilerProcess.getCommandArrayString());

		try {
			compilerProcess.exec(System.out, System.err, true);
		} catch (IOException ex) {
			// ERROR: Cannot execute {0} process '{1}' in working directory '{2}'. System
			// error: {3}
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E105, compilerDefinition.getText(),
					compilerProcess.getCommandArrayString(), compilerProcess.getWorkingDirectory().getPath(),
					ex.getMessage());
		}

		// Refresh the output and the symbols file resource.
		if (files.outputFolderPath.equals(files.mainSourceFile.folderPath)
				|| files.outputFolderPath.equals(files.sourceFile.folderPath)) {
			try {
				IResource outputResource = files.mainSourceFile.iFile.getParent();
				if (outputResource != null) {
					outputResource.refreshLocal(IResource.DEPTH_ONE, null);
				}
				outputResource = files.sourceFile.iFile.getParent();
				if (outputResource != null) {
					outputResource.refreshLocal(IResource.DEPTH_ONE, null);
				}

			} catch (CoreException ex) {
				createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, ex.getMessage());
				return false;
			}
		}

		compilerConsole.println("");
		compilerConsole.println("Compiler '" + compilerDefinition.getName() + "' output:");
		compilerConsole.println(compilerProcess.getErrorLog());
		compilerConsole.println(compilerProcess.getOutputLog());

		// Compiling is over, check the result.
		Compiler compiler = languageEditor.getCompiler();
		boolean compilerSuccess = compiler.isSuccessExitValue(compilerProcess.getExitValue());
		if (compilerSuccess) {
			if (files.outputFile.exists()) {
				if (files.outputFile.length() > 0) {
					if (files.outputFile.lastModified() != outputFileLastModified) {
						// INFO: Output file '{0}' created or updated with {1}
						// (${2}) bytes.
						long fileLength = files.outputFile.length();
						createMainSourceFileMessage(files, IMarker.SEVERITY_INFO, Texts.MESSAGE_I109,
								files.outputFilePath, Long.toString(fileLength),
								HexUtility.getLongValueHexString(fileLength));

						// Handle disk images
						CompilerFileWriter compilerFileWriter = HardwareUtility
								.getCompilerFileWriter(compilerRunPreferences.getHardware());
						if (!compilerFileWriter.createOrUpdateDiskImage(files)) {
							return false;
						}

						if (commandId.equals(COMPILE_AND_RUN) || commandId.equals(COMPILE_AND_RUN_WITH)) {

							openOutputFile(languageEditor, files, compilerRunPreferences, compilerConsole, runnerId);

						}
					} else {
						// ERROR: Output file not updated. Check the error
						// messages and the console log.
						createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E108);

					}
				} else {
					// ERROR: Output file created but empty. Check the error
					// messages and the console log.
					createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E126);
				}
			} else {
				// ERROR: No output file created. Check the error messages and
				// the
				// console log.
				createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E107);
			}
		}

		// Output an additional message if the reason for the compiler's exit
		// value is not already contained in the error messages.
		boolean errorFound = parseLogs(languageEditor, files, compilerProcess);
		if (!compilerSuccess && !errorFound) {
			// ERROR: {0} process ended with return code {1}. Check the error messages and
			// the console log.
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E127, compilerDefinition.getText(),
					NumberUtility.getLongValueDecimalString(compilerProcess.getExitValue()));
		}

		return true;
	}

	/**
	 * Check the status message attached to annotation values and create markers for
	 * them.
	 * 
	 * @param sourceFile The source file, not <code>null</code>.
	 */
	private void checkAnnotations(SourceFile sourceFile) {
		if (sourceFile == null) {
			throw new IllegalArgumentException("Parameter 'sourceFile' must not be null.");
		}

		var annotationValues = sourceFile.languageAnnotationValues;
		for (String key : annotationValues.keySet()) {
			var value = annotationValues.get(key);
			int markerSeverity;
			for (var status : value.statusList) {
				switch (status.getSeverity()) {
				case IStatus.WARNING:
					markerSeverity = IMarker.SEVERITY_WARNING;
					break;
				case IStatus.ERROR:
					markerSeverity = IMarker.SEVERITY_ERROR;
					break;
				default:
					throw new IllegalStateException("Unsupported severity " + status.getSeverity());
				}
				MarkerUtility.createMarker(sourceFile.iFile, value.lineNumber, markerSeverity, "{0}",
						status.getMessage());
			}
		}

	}

	/**
	 * Creates or deletes the breakpoints file based on the runner.
	 * 
	 * @param languageEditor The language editor, not <code>null</code>.
	 * @param files          The compiler files, not <code>null</code>.
	 * @param runner         The runner, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	private void createBreakpointsFile(LanguageEditor languageEditor, CompilerFiles files, Runner runner) {
		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (runner == null) {
			throw new IllegalArgumentException("Parameter 'runner' must not be null.");
		}
		File breakpointsFile = runner.createBreakpointsFile(files);
		IBreakpointManager breakpointManager = DebugPlugin.getDefault().getBreakpointManager();
		IBreakpoint breakpoints[];
		if (breakpointManager.isEnabled()) {
			breakpoints = breakpointManager.getBreakpoints(LanguageBreakpoint.DEBUG_MODEL_ID);
		} else {
			breakpoints = new IBreakpoint[0];
		}
		if (breakpointsFile == null) {
			if (breakpoints.length > 0) {
				// WARNING: Breakpoints will be ignored because the application
				// '{0}' does not support passing source level breakpoints.
				createMainSourceFileMessage(files, IMarker.SEVERITY_WARNING, Texts.MESSAGE_W120,
						new String[] { runner.getDefinition().getName() });
			}
			return;
		}

		// If breakpoints are present, a breakpoints file is generated.
		if (breakpoints.length >= 0) {
			LanguageBreakpoint[] languageBreakpoints = new LanguageBreakpoint[breakpoints.length];
			System.arraycopy(breakpoints, 0, languageBreakpoints, 0, breakpoints.length);
			StringBuilder breakpointBuilder = new StringBuilder();
			int activeBreakpointCount = runner.createBreakpointsFileContent(languageBreakpoints, breakpointBuilder);
			try {
				FileUtility.writeString(breakpointsFile, breakpointBuilder.toString());
			} catch (CoreException ex) {
				// ERROR: Cannot open breakpoints file '{0}' for output. System
				// error: {1}
				createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E122,
						new String[] { breakpointsFile.getPath(), ex.getMessage() });
				return;
			}
			// INFO: Breakpoints file '{0}' created with {1} active breakpoints.
			createMainSourceFileMessage(files, IMarker.SEVERITY_INFO, Texts.MESSAGE_I121, new String[] {
					breakpointsFile.getPath(), NumberUtility.getLongValueDecimalString(activeBreakpointCount) });

		} else {
			// If no breakpoints are present, the breakpoints file is deleted.
			if (breakpointsFile.exists()) {
				if (!breakpointsFile.delete()) {
					// ERROR: Cannot delete empty breakpoints file '{0}'.
					createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E123,
							new String[] { breakpointsFile.getPath() });
				}
			}
		}
	}

	private void openOutputFile(LanguageEditor languageEditor, CompilerFiles files,
			CompilerRunPreferences compilerRunPreferences, CompilerConsole compilerConsole, String runnerId) {

		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (compilerRunPreferences == null) {
			throw new IllegalArgumentException("Parameter 'compilerRunPreferences' must not be null.");
		}
		if (compilerConsole == null) {
			throw new IllegalArgumentException("Parameter 'compilerConsole' must not be null.");
		}
		String[] fullCommandLineArray;
		ProcessWithLogs runnerProcess;

		fullCommandLineArray = null;

		// If the runner id was no specified explicitly, the default from the
		// preferences is used.
		if (runnerId == null || StringUtility.isEmpty(runnerId)) {
			runnerId = compilerRunPreferences.getRunnerId();
		}
		Hardware hardware = compilerRunPreferences.getHardware();
		Runner runner;
		runner = plugin.getRunnerRegistry().getRunner(hardware, runnerId);
		if (runner == null) {
			// ERROR: Definition for application '{0}' from the preferences of
			// hardware '{1}' is not registered.
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E116, runnerId,
					hardware.toString());
			return;
		}

		createBreakpointsFile(languageEditor, files, runner);

		String runnerCommandLine;
		runnerCommandLine = compilerRunPreferences.getRunnerCommandLine(runnerId);
		if (StringUtility.isEmpty(runnerCommandLine)) {
			runnerCommandLine = runner.getDefinition().getDefaultCommandLine();
		}
		runnerCommandLine = runnerCommandLine.trim();

		// The parameters are first split and then substituted.
		// This allows for parameters and file paths inner spaces to
		// be used. In some case addition quotes must be places around
		// parameters, for example for the "${outputFilePath}" for
		// MADS. Otherwise using absolute file path under Unix starting
		// "/" may cause conflicts.
		String[] commandLineArray;
		commandLineArray = runnerCommandLine.split(" ");

		// Execution type: DEFAULT_APPLICATION
		if (runnerId.equals(RunnerId.DEFAULT_APPLICATION)) {
			String extension = files.outputFileName;
			int index = extension.lastIndexOf('.');
			if (index > 0) {
				extension = extension.substring(index);
			}
			Program program = Program.findProgram(extension);
			if (program == null) {
				// ERROR: Cannot open output file '{0}' with the
				// standard application since no application is
				// registered for the file extension '{1}'.
				createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E115, files.outputFilePath,
						extension);
			} else {

				if (Program.launch(files.outputFilePath)) {
					// INFO: Opening output file '{0}' with
					// application
					// '{1}'.
					createMainSourceFileMessage(files, IMarker.SEVERITY_INFO, Texts.MESSAGE_I118, files.outputFilePath,
							program.getName());

					compilerConsole.println("Running '" + runner.getDefinition().getName() + "': " + program.getName()
							+ " " + files.outputFilePath);
				} else {
					// ERROR: Cannot open output file '{0}' with
					// application '{1}'.
					createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E119, files.outputFilePath,
							program.getName());
				}
			}
		}
		// Execution type: pre-defined or USER_DEFINED_APPLICATION
		else {
			boolean error = false;

			String runnerExecutablePath = compilerRunPreferences.getRunnerExecutablePath(runnerId);
			if (runnerCommandLine.contains(RunnerDefinition.RUNNER_EXECUTABLE_PATH)) {
				if (StringUtility.isEmpty(runnerExecutablePath)) {
					// ERROR: Path to application executable is not
					// set in the preferences of application '{0}'.
					createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E112,
							runner.getDefinition().getName());
					error = true;
				} else {
					File runnerExecutableFile = new File(runnerExecutablePath);
					if (!runnerExecutableFile.exists()) {
						// ERROR: Path to '{0}' application
						// executable in the preferences points to
						// non-existing file '{1}'.
						createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E114,
								runner.getDefinition().getName(), runnerExecutablePath);
						error = true;
					}
				}
			}
			if (!error) {

				fullCommandLineArray = new String[commandLineArray.length];
				for (int i = 0; i < commandLineArray.length; i++) {
					String parameter = commandLineArray[i];
					parameter = CompilerVariables.replaceVariables(parameter, files);
					parameter = replaceRunnerParameters(parameter, runnerExecutablePath);
					parameter = parameter.replace(RunnerDefinition.OUTPUT_FILE_PATH, files.outputFilePath);
					fullCommandLineArray[i] = parameter;
				}

				// INFO: Opening output file '{0}' with application '{1}'.
				createMainSourceFileMessage(files, IMarker.SEVERITY_INFO, Texts.MESSAGE_I118, files.outputFilePath,
						runner.getDefinition().getName());

				runnerProcess = new ProcessWithLogs(fullCommandLineArray, files.outputFolder);

				compilerConsole.println(
						"Running '" + runner.getDefinition().getName() + "': " + runnerProcess.getCommandArrayString());

				try {
					boolean wait = compilerRunPreferences.isRunnerWaitForCompletion(runnerId);
					runnerProcess.exec(compilerConsole.getPrintStream(), compilerConsole.getPrintStream(), wait);
					compilerConsole
							.println("Application returned with exit code " + runnerProcess.getExitValue() + ".");
				} catch (IOException ex) {
					// ERROR: Cannot execute application '{0}' process '{1}' in
					// working directory '{2}'. System error: {3}
					createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, Texts.MESSAGE_E113,
							runner.getDefinition().getName(), runnerProcess.getCommandArrayString(),
							runnerProcess.getWorkingDirectory().getPath(), ex.getMessage());
				}
			}
		}
	}

	private String replaceRunnerParameters(String parameter, String runnerExecutablePath) {
		if (parameter == null) {
			throw new IllegalArgumentException("Parameter 'parameter' must not be null.");
		}
		if (runnerExecutablePath == null) {
			throw new IllegalArgumentException("Parameter 'runnerExecutablePath' must not be null.");
		}
		parameter = parameter.replace(RunnerDefinition.RUNNER_EXECUTABLE_PATH, runnerExecutablePath);
		return parameter;
	}

	private boolean parseLogs(LanguageEditor languageEditor, CompilerFiles files, ProcessWithLogs compileProcess) {

		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (compileProcess == null) {
			throw new IllegalArgumentException("Parameter 'compileProcess' must not be null.");
		}
		Compiler compiler = languageEditor.getCompiler();
		CompilerProcessLogParser logParser = compiler.createLogParser();

		// Line parser with main source file and logs.
		logParser.setLogs(files, compileProcess.getOutputLog(), compileProcess.getErrorLog());

		Set<Marker> set = new HashSet<Marker>();
		List<IMarker> markers = new ArrayList<IMarker>();
		while (logParser.nextMarker()) {
			Marker markerProxy = logParser.getMarker();
			while (markerProxy != null) { // Loop to add main marker and its
				// detail markers
				if (!set.contains(markerProxy)) {
					set.add(markerProxy);
					try {
						IFile iFile = markerProxy.getIFile();
						IMarker marker = iFile.createMarker(IMarker.PROBLEM);
						marker.setAttribute(IMarker.SEVERITY, markerProxy.getSeverity());
						marker.setAttribute(IMarker.MESSAGE, markerProxy.getMessage());
						int lineNumber = markerProxy.getLineNumber();
						if (lineNumber > 0) {
							marker.setAttribute(IMarker.LINE_NUMBER, lineNumber);
						}
						marker.setAttribute(IMarker.TRANSIENT, true);
						markers.add(marker);
					} catch (CoreException ex) {
						throw new RuntimeException(ex);
					}
				}
				markerProxy = markerProxy.getDetailMarker();
			}
		}
		boolean errorOccurred = positionToFirstErrorOrWarning(languageEditor, markers);

		parseCompilerSymbols(languageEditor, files, logParser);

		return errorOccurred;
	}

	/**
	 * Positions to the first error or warning in any file for which markers have
	 * been created.
	 * 
	 * @param languageEditor The language editor, not <code>null</code>. Used as
	 *                       basis for opening another editor when required.
	 * @param markers        The modifiable list of marker, may be empty, not
	 *                       <code>null</code>.
	 * @return <code>true</code> if an error was found.
	 */
	private boolean positionToFirstErrorOrWarning(LanguageEditor languageEditor, List<IMarker> markers) {

		if (languageEditor == null) {
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		}
		if (markers == null) {
			throw new IllegalArgumentException("Parameter 'markers' must not be null.");
		}

		Collections.sort(markers, new Comparator<IMarker>() {

			@Override
			public int compare(IMarker o1, IMarker o2) {
				int result = o1.getResource().getFullPath().toString()
						.compareTo(o2.getResource().getFullPath().toString());
				if (result == 0) {
					result = o1.getAttribute(IMarker.LINE_NUMBER, 0) - o2.getAttribute(IMarker.LINE_NUMBER, 0);
				}
				return result;
			}

		});

		String positioningMode = languageEditor.getLanguagePreferences().getEditorCompileCommandPositioningMode();
		boolean ignoreWarnings = positioningMode.equals(LanguageEditorCompileCommandPositioningMode.FIRST_ERROR);
		IMarker firstWarningMarker = null;
		IMarker firstErrorMarker = null;
		for (IMarker marker : markers) {

			switch (marker.getAttribute(IMarker.SEVERITY, 0)) {
			case IMarker.SEVERITY_WARNING:
				if (!ignoreWarnings) {

					if (firstWarningMarker == null) {
						firstWarningMarker = marker;
					}

				}
				break;
			case IMarker.SEVERITY_ERROR:
				if (firstErrorMarker == null) {
					firstErrorMarker = marker;
				}
				break;
			}

		}
		IMarker firstMarker = firstErrorMarker;
		if (firstMarker == null) {
			firstMarker = firstWarningMarker;
		}

		if (firstMarker != null) {
			MarkerUtility.gotoMarker(languageEditor, firstMarker);
		}
		return firstErrorMarker != null;
	}

	private void parseCompilerSymbols(LanguageEditor languageEditor, CompilerFiles files,
			CompilerProcessLogParser logParser) {

		if (languageEditor == null)
			throw new IllegalArgumentException("Parameter 'languageEditor' must not be null.");
		if (files == null)
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		if (logParser == null)
			throw new IllegalArgumentException("Parameter 'logParser' must not be null.");

		List<CompilerSymbol> compilerSymbols;

		compilerSymbols = new ArrayList<CompilerSymbol>();
		try {
			logParser.addCompilerSymbols(compilerSymbols);
		} catch (RuntimeException ex) {
			String message = ex.getMessage();
			if (message == null) {
				message = ex.getClass().getName();
			}
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, message);
			LanguagePlugin.getInstance().logError("Error in addCompilerSymbols()", null, ex);

		} catch (CoreException ex) {
			String message = ex.getMessage();
			if (message == null) {
				message = ex.getClass().getName();
			}
			createMainSourceFileMessage(files, IMarker.SEVERITY_ERROR, message);

		}

		// Display symbols.
		IViewReference[] references = languageEditor.getSite().getPage().getViewReferences();
		for (IViewReference reference : references) {
			if (reference.getId().equals(CompilerSymbolsView.ID)) {
				CompilerSymbolsView compilerSymbolsView = (CompilerSymbolsView) reference.getView(true);
				if (compilerSymbolsView != null) {
					compilerSymbolsView.setSymbols(files, compilerSymbols);
				}
			}

		}

	}
}
