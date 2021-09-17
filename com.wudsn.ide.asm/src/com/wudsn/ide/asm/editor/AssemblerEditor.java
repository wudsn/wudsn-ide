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

package com.wudsn.ide.asm.editor;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.ResourceBundle;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.debug.ui.actions.ToggleBreakpointAction;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.source.Annotation;
import org.eclipse.jface.text.source.ISourceViewer;
import org.eclipse.jface.text.source.IVerticalRuler;
import org.eclipse.jface.text.source.SourceViewer;
import org.eclipse.jface.text.source.projection.ProjectionAnnotation;
import org.eclipse.jface.text.source.projection.ProjectionAnnotationModel;
import org.eclipse.jface.text.source.projection.ProjectionSupport;
import org.eclipse.jface.text.source.projection.ProjectionViewer;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.editors.text.TextEditor;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.part.FileEditorInput;
import org.eclipse.ui.texteditor.IDocumentProvider;
import org.eclipse.ui.texteditor.ITextEditorActionDefinitionIds;
import org.eclipse.ui.texteditor.TextOperationAction;
import org.eclipse.ui.views.contentoutline.IContentOutlinePage;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.AssemblerProperties;
import com.wudsn.ide.asm.AssemblerProperties.InvalidAssemblerPropertyException;
import com.wudsn.ide.asm.CPU;
import com.wudsn.ide.asm.Hardware;
import com.wudsn.ide.asm.compiler.Compiler;
import com.wudsn.ide.asm.compiler.CompilerDefinition;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceFile;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.asm.compiler.parser.CompilerSourcePartitionScanner;
import com.wudsn.ide.asm.preferences.CompilerPreferences;
import com.wudsn.ide.base.common.Profiler;

/**
 * The assembler editor.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
public abstract class AssemblerEditor extends TextEditor {

	private AssemblerPlugin plugin;
	private AssemblerEditorFilesLogic filesLogic;

	private Compiler compiler;

	private AssemblerContentOutlinePage contentOutlinePage;
	private ProjectionAnnotationModel annotationModel;

	private Hardware hardware;

	/**
	 * Creates a new instance. Constructor parameters are not useful, because the
	 * super constructor inverts the flow of control, so {@link #initializeEditor}
	 * is called before the code in this constructor is executed.
	 */
	protected AssemblerEditor() {
		filesLogic = AssemblerEditorFilesLogic.createInstance(this);
	}

	/**
	 * Gets the files logic associated with this editor.
	 * 
	 * @return The files logic, not <code>null</code>.
	 */
	public AssemblerEditorFilesLogic getFilesLogic() {
		return filesLogic;
	}

	/**
	 * Gets the hardware for this editor.
	 * 
	 * @return The hardware for this editor, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	protected final Hardware getHardware() {
		if (hardware != null) {
			return hardware;
		}
		return compiler.getDefinition().getDefaultHardware();
	}

	/**
	 * Gets the compiler id for this editor.
	 * 
	 * @return The compiler id for this editor, not empty and not <code>null</code>.
	 */
	protected abstract String getCompilerId();

	@Override
	protected final void initializeEditor() {
		super.initializeEditor();

		plugin = AssemblerPlugin.getInstance();
		compiler = plugin.getCompilerRegistry().getCompiler(getCompilerId());

		setSourceViewerConfiguration(new AssemblerSourceViewerConfiguration(this, getPreferenceStore()));

	}

	/**
	 * Gets the plugin this compiler instance belongs to.
	 * 
	 * @return The plugin this compiler instance belongs to, not <code>null</code>.
	 */
	public final AssemblerPlugin getPlugin() {
		if (plugin == null) {
			throw new IllegalStateException("Field 'plugin' must not be null.");
		}
		return plugin;
	}

	/**
	 * Gets the compiler preferences.
	 * 
	 * @return The compiler preferences, not <code>null</code>.
	 */
	public final CompilerPreferences getCompilerPreferences() {
		return plugin.getPreferences().getCompilerPreferences(getCompilerId(), getHardware());
	}

	/**
	 * Gets the compiler for this editor.
	 * 
	 * @return The compiler for this editor, not <code>null</code>.
	 */
	public final Compiler getCompiler() {
		if (compiler == null) {
			throw new IllegalStateException("Field 'compiler' must not be null.");
		}
		return compiler;
	}

	/**
	 * Gets the compiler definition for this editor.
	 * 
	 * @return The compiler definition for this editor, not <code>null</code>.
	 * 
	 * @sine 1.6.1
	 */
	public final CompilerDefinition getCompilerDefinition() {
		if (compiler == null) {
			throw new IllegalStateException("Field 'compiler' must not be null.");
		}
		return compiler.getDefinition();
	}

	/**
	 * Gets the compiler source parser for this editor and the currently selected
	 * instruction set.
	 * 
	 * @return The compiler source parser for this editor, not <code>null</code> .
	 */
	public final CompilerSourceParser createCompilerSourceParser() {
		CPU cpu;
		CompilerSourceParser result;
		if (compiler == null) {
			throw new IllegalStateException("Field 'compiler' must not be null.");
		}
		cpu = getCompilerPreferences().getCPU();
		result = compiler.createSourceParser();
		result.init(compiler.getDefinition().getSyntax().getInstructionSet(cpu));
		return result;
	}

	/**
	 * This method is called whenever the input changes, i.e. after loading and
	 * after saving as new file.
	 * 
	 * @param input The new input, may be <code>null</code>
	 */
	@Override
	protected final void doSetInput(IEditorInput input) throws CoreException {
		super.doSetInput(input);

		hardware = null;
		if (input != null) {
			IDocument document = getDocumentProvider().getDocument(getEditorInput());

			CompilerSourcePartitionScanner partitionScanner = new CompilerSourcePartitionScanner(
					compiler.getDefinition().getSyntax());
			partitionScanner.createDocumentPartitioner(document);

			AssemblerProperties properties = CompilerSourceParser.getDocumentProperties(document);

			IFile iFile = getCurrentIFile();
			if (iFile != null) {
				try {
					hardware = filesLogic.getHardware(iFile, properties);
				} catch (InvalidAssemblerPropertyException ex) {
					// Do not use MarkerUtility.gotoMarker to make sure this
					// editor instance is used.
					IDE.gotoMarker(this, ex.marker);
					hardware = null;
				}
			}
		}

	}

	@Override
	protected final void createActions() {
		super.createActions();

		ResourceBundle bundle = ResourceBundle.getBundle("com.wudsn.ide.asm.Actions", Locale.getDefault(),
				AssemblerEditor.class.getClassLoader());

		String actionDefintionId;
		String actionId;
		actionDefintionId = ITextEditorActionDefinitionIds.CONTENT_ASSIST_PROPOSALS;
		actionId = "com.wudsn.ide.asm.editor.ContentAssistProposal";
		IAction action = new TextOperationAction(bundle, actionId + ".", this, ISourceViewer.CONTENTASSIST_PROPOSALS);
		action.setActionDefinitionId(actionDefintionId);
		setAction(actionId, action);
		markAsStateDependentAction(actionId, true);

		SourceViewer sourceViewer = (SourceViewer) getSourceViewer();
		actionDefintionId = "com.wudsn.ide.asm.editor.AssemblerEditorToggleCommentCommand";
		actionId = actionDefintionId;
		action = new AssemblerEditorToggleCommentAction(bundle, actionId + ".", this, sourceViewer);
		action.setActionDefinitionId(actionId);
		setAction(actionId, action);
		markAsStateDependentAction(actionId, true);

		// Register rule double click.
		ToggleBreakpointAction toggleBreakpointAction;
		actionDefintionId = "org.eclipse.debug.ui.commands.ToggleBreakpoint";
		actionId = "RulerDoubleClick";
		action.setActionDefinitionId(actionId);
		toggleBreakpointAction = new ToggleBreakpointAction(this, getDocumentProvider().getDocument(getEditorInput()),
				getVerticalRuler());
		toggleBreakpointAction.setId(actionId);
		setAction(actionId, toggleBreakpointAction);
		markAsStateDependentAction(actionId, true);
		toggleBreakpointAction.update();
	}

	final ISourceViewer getSourceViewerInternal() {
		return getSourceViewer();
	}

	/**
	 * Refreshes the editor after changes to the text attributes or the text
	 * content.
	 * 
	 * Called by {@link #updateIdentifiers(CompilerSourceFile)} and
	 * {@link AssemblerSourceViewerConfiguration#preferencesChanged(com.wudsn.ide.asm.preferences.AssemblerPreferences, java.util.Set)}
	 * .
	 */
	final void refreshSourceViewer() {
		ISourceViewer isv = getSourceViewer();
		if (isv instanceof SourceViewer) {
			((SourceViewer) getSourceViewer()).invalidateTextPresentation();
		}
	}

	@Override
	public final void dispose() {
		AssemblerSourceViewerConfiguration asvc;
		asvc = (AssemblerSourceViewerConfiguration) getSourceViewerConfiguration();
		asvc.dispose();
		super.dispose();
	}

	@SuppressWarnings("unchecked")
	@Override
	public <T> T getAdapter(Class<T> adapter) {
		if (IContentOutlinePage.class.equals(adapter)) {
			if (contentOutlinePage == null) {
				contentOutlinePage = new AssemblerContentOutlinePage(this);
				// This causes double parsing upon starting with a new file
				// currently.
				updateContentOutlinePage();
			}
			return (T) contentOutlinePage;
		}
		return super.getAdapter(adapter);
	}

	/**
	 * Updates the content in view of the outline page. Called by
	 * {@link AssemblerReconcilingStategy#parse}.
	 */
	final void updateContentOutlinePage() {
		if (contentOutlinePage != null) {
			IEditorInput input = getEditorInput();

			if (input != null) {
				contentOutlinePage.setInput(input);
			}
		}
	}

	/**
	 * Gets the compiler source file of the last parse process.
	 * 
	 * @return The compiler source file of the last parse process or
	 *         <code>null</code>.
	 */
	final CompilerSourceFile getCompilerSourceFile() {
		CompilerSourceFile result;
		if (contentOutlinePage != null) {
			result = contentOutlinePage.getCompilerSourceFile();
		} else {
			result = null;
		}
		return result;
	}

	@Override
	public final void createPartControl(Composite parent) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		super.createPartControl(parent);
		ProjectionViewer viewer = (ProjectionViewer) getSourceViewer();

		ProjectionSupport projectionSupport = new ProjectionSupport(viewer, getAnnotationAccess(), getSharedColors());
		projectionSupport.install();

		// turn projection mode on
		viewer.doOperation(ProjectionViewer.TOGGLE);

		annotationModel = viewer.getProjectionAnnotationModel();

	}

	@Override
	protected final ISourceViewer createSourceViewer(Composite parent, IVerticalRuler ruler, int styles) {
		if (parent == null) {
			throw new IllegalArgumentException("Parameter 'parent' must not be null.");
		}
		if (ruler == null) {
			throw new IllegalArgumentException("Parameter 'ruler' must not be null.");
		}
		ISourceViewer viewer = new ProjectionViewer(parent, ruler, getOverviewRuler(), isOverviewRulerVisible(),
				styles);

		// Ensure decoration support has been created and configured.
		getSourceViewerDecorationSupport(viewer);

		// The first single line comment delimiter is used as the default.
		List<String> singleLineCommentDelimiters = compiler.getDefinition().getSyntax()
				.getSingleLineCommentDelimiters();
		String[] array = singleLineCommentDelimiters.toArray(new String[singleLineCommentDelimiters.size()]);
		viewer.setDefaultPrefixes(array, IDocument.DEFAULT_CONTENT_TYPE);
		viewer.setDefaultPrefixes(array, CompilerSourcePartitionScanner.PARTITION_COMMENT_SINGLE);

		return viewer;
	}

	/**
	 * Update the identifiers to be highlighted
	 * 
	 * @param compilerSourceFile The compiler source file or <code>null</code>.
	 */
	final void updateIdentifiers(CompilerSourceFile compilerSourceFile) {
		Profiler profiler = new Profiler(this.getClass());

		AssemblerSourceViewerConfiguration asvc;
		AssemblerSourceScanner ais;
		asvc = (AssemblerSourceViewerConfiguration) getSourceViewerConfiguration();
		ais = asvc.getAssemblerInstructionScanner();

		List<CompilerSourceParserTreeObject> newIdentifiers;
		if (compilerSourceFile == null) {
			newIdentifiers = Collections.emptyList();
		} else {
			newIdentifiers = compilerSourceFile.getIdentifiers();
		}

		ais.setIdentifiers(newIdentifiers);
		profiler.begin("refreshSourceViewer");
		// refreshSourceViewer();
		profiler.end("refreshSourceViewer");
	}

	/**
	 * Update the folding structure with a given list of foldingPositions. Used by
	 * the editor updater of {@link AssemblerReconcilingStategy}.
	 * 
	 * @param foldingPositions The list of foldingPositions, may be empty, not
	 *                         <code>null</code>.
	 */
	final void updateFoldingStructure(List<Position> foldingPositions) {
		if (foldingPositions == null) {
			throw new IllegalArgumentException("Parameter 'foldingPositions' must not be null.");
		}

		// Create a working copy.
		foldingPositions = new ArrayList<Position>(foldingPositions);
		List<ProjectionAnnotation> deletions = new ArrayList<ProjectionAnnotation>();
		Object annotationObject = null;
		ProjectionAnnotation annotation = null;
		Position position = null;

		// Access to the annotationModel is intentionally not synchronized, as
		// otherwise deadlock would be the result.
		for (@SuppressWarnings("rawtypes")
		Iterator iter = annotationModel.getAnnotationIterator(); iter.hasNext();) {
			annotationObject = iter.next();

			if (annotationObject instanceof ProjectionAnnotation) {
				annotation = (ProjectionAnnotation) annotationObject;

				position = annotationModel.getPosition(annotation);

				if (foldingPositions.contains(position)) {
					foldingPositions.remove(position);
				} else {
					deletions.add(annotation);
				}
			}

		}

		Annotation[] removeAnnotations = deletions.toArray(new Annotation[deletions.size()]);

		// This will hold the new annotations along
		// with their corresponding folding positions.
		HashMap<ProjectionAnnotation, Position> newAnnotations = new HashMap<ProjectionAnnotation, Position>();

		for (int i = 0; i < foldingPositions.size(); i++) {
			annotation = new ProjectionAnnotation();
			newAnnotations.put(annotation, foldingPositions.get(i));
		}

		// Do not update anything if there is actual change to preserve the
		// current cursor positioning.
		if (removeAnnotations.length == 0 && newAnnotations.isEmpty()) {
			return;
		}

		annotationModel.modifyAnnotations(removeAnnotations, newAnnotations, new Annotation[] {});
	}

	/**
	 * Gets the directory of the current file.
	 * 
	 * @return The directory of the current file or <code>null</code>.
	 */
	public final File getCurrentDirectory() {
		File result;
		result = getCurrentFile();
		if (result != null) {
			result = result.getParentFile();
		}
		return result;
	}

	/**
	 * Gets the the current file.
	 * 
	 * @return The current file or <code>null</code>.
	 */
	public final File getCurrentFile() {
		File result;
		IEditorInput editorInput = getEditorInput();
		if (editorInput instanceof FileEditorInput) {
			FileEditorInput fileEditorInput = (FileEditorInput) editorInput;
			result = new File(fileEditorInput.getPath().toOSString());
		} else {
			result = null;
		}
		return result;
	}

	/**
	 * Gets the the current file.
	 * 
	 * @return The current file or <code>null</code>.
	 */
	public final IFile getCurrentIFile() {
		IFile result;
		IEditorInput editorInput = getEditorInput();
		if (editorInput instanceof FileEditorInput) {
			FileEditorInput fileEditorInput = (FileEditorInput) editorInput;
			result = fileEditorInput.getFile();

		} else {
			result = null;
		}
		return result;
	}

	/**
	 * Position the cursor to the specified line in the document.
	 * 
	 * @param line The line number, a positive integer.
	 * 
	 * @return <code>true</code> if the positioning was successful.
	 */
	public final boolean gotoLine(int line) {
		if (line < 1) {
			throw new IllegalArgumentException("Parameter 'line' must be positive. Specified value is " + line + ".");
		}
		IDocumentProvider provider = getDocumentProvider();
		IDocument document = provider.getDocument(getEditorInput());
		boolean result = false;
		try {
			int startOffset = document.getLineOffset(line - 1);
			int lineLength = document.getLineLength(line - 1);
			if (lineLength > 0) {
				lineLength = lineLength - 1;
			}
			selectAndReveal(startOffset, lineLength);
			result = true;
		} catch (BadLocationException ex) {
			plugin.logError("Cannot position to line {0}.", new Object[] { String.valueOf(line) }, ex);
			result = false;
		}
		return result;
	}

}
