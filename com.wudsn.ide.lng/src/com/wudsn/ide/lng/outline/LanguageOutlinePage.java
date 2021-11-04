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

package com.wudsn.ide.lng.outline;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.QualifiedName;
import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.text.Position;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.jface.viewers.ContentViewer;
import org.eclipse.jface.viewers.IBaseLabelProvider;
import org.eclipse.jface.viewers.ILabelProvider;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.SelectionChangedEvent;
import org.eclipse.jface.viewers.TreePath;
import org.eclipse.jface.viewers.TreeSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.jface.viewers.ViewerComparator;
import org.eclipse.swt.custom.BusyIndicator;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.plugin.AbstractUIPlugin;
import org.eclipse.ui.views.contentoutline.ContentOutlinePage;

import com.wudsn.ide.base.common.Profiler;
import com.wudsn.ide.base.common.RunnableWithLogging;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceFile;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObjectLabelProvider;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParserTreeObjectType;
import com.wudsn.ide.lng.editor.LanguageEditor;

/**
 * Outline page for the language editor.
 * 
 * @author Peter Dell.
 * @author Andy Reek
 */
public final class LanguageOutlinePage extends ContentOutlinePage {

	/*
	 * Toggle action to toggle the sorting in the outline tree. The state of the
	 * action will be persisted along with the file in the editor. If there is no
	 * state store yet along with in the file, the default is taken from the last
	 * file which was opened.
	 */
	private static final class OutlineViewerSortAction extends Action {
		private static final QualifiedName CHECKED = new QualifiedName("OutlineViewerSortAction", "Checked");

		final LanguageEditor editor;
		final TreeViewer treeViewer;

		/**
		 * Creates a new sort action.
		 * 
		 * @param editor     The editor which holds the respective file, not
		 *                   <code>null</code>.
		 * @param treeViewer The tree viewer which displays the outline.
		 */
		public OutlineViewerSortAction(LanguageEditor editor, TreeViewer treeViewer) {
			super("", AS_CHECK_BOX);
			if (editor == null) {
				throw new IllegalArgumentException("Parameter 'editor' must not be null.");
			}
			if (treeViewer == null) {
				throw new IllegalArgumentException("Parameter 'treeViewer' must not be null.");
			}
			setToolTipText(Texts.COMPILER_CONTENT_OUTLINE_SORT_BUTTON_TOOL_TIP);
			ImageDescriptor imageDescriptor = AbstractUIPlugin.imageDescriptorFromPlugin(LanguagePlugin.ID,
					"icons/outline-sort.gif");
			setImageDescriptor(imageDescriptor);
			this.editor = editor;
			this.treeViewer = treeViewer;

			String checkedProperty;
			try {
				IFile iFile = editor.getCurrentIFile();
				if (iFile != null) {
					checkedProperty = iFile.getPersistentProperty(CHECKED);
				} else {
					checkedProperty = "";
				}
			} catch (CoreException ignore) {
				checkedProperty = null;
			}
			if (checkedProperty == null) {
				checkedProperty = editor.getPlugin().getProperty(CHECKED);
			}

			boolean checked = Boolean.parseBoolean(checkedProperty);
			setChecked(checked);

		}

		@Override
		public void run() {

			// Get current state and update the UI.
			boolean checked = isChecked();
			setChecked(checked);

			// Store the property.
			String checkedProperty = Boolean.toString(checked);
			try {
				IFile iFile = editor.getCurrentIFile();
				if (iFile != null) {
					iFile.setPersistentProperty(CHECKED, checkedProperty);
				}
			} catch (CoreException ex) {
				editor.getPlugin().logError("Cannot set property {0}", new Object[] { CHECKED }, ex);
			}
			editor.getPlugin().setProperty(CHECKED, checkedProperty);

			// Refresh the tree viewer.
			BusyIndicator.showWhile(treeViewer.getControl().getDisplay(), new RunnableWithLogging() {
				@Override
				protected void runWithLogging() {
					treeViewer.refresh(false);
				}
			});
		}
	}

	private static final class OutlineViewerComparator extends ViewerComparator {
		private final OutlineViewerSortAction sortAction;
		private final boolean identifiersCaseSensitive;

		OutlineViewerComparator(OutlineViewerSortAction sortAction) {
			if (sortAction == null) {
				throw new IllegalArgumentException("Parameter 'sortAction' must not be null.");
			}
			this.sortAction = sortAction;
			identifiersCaseSensitive = sortAction.editor.getCompilerDefinition().getSyntax()
					.areIdentifiersCaseSensitive();

		}

		@Override
		public int category(Object element) {
			int result;
			CompilerSourceParserTreeObject object = (CompilerSourceParserTreeObject) element;

			// Treat equate definition and label definition as equal.
			result = object.getType();

			switch (object.getType()) {
			case CompilerSourceParserTreeObjectType.DEFAULT:
			case CompilerSourceParserTreeObjectType.DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.IMPLEMENTATION_SECTION:
				break;

			case CompilerSourceParserTreeObjectType.EQUATE_DEFINITION:
				result = CompilerSourceParserTreeObjectType.EQUATE_DEFINITION;
				break;
			case CompilerSourceParserTreeObjectType.LABEL_DEFINITION:
				result = CompilerSourceParserTreeObjectType.EQUATE_DEFINITION;
				break;

			case CompilerSourceParserTreeObjectType.ENUM_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.STRUCTURE_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.LOCAL_SECTION:
			case CompilerSourceParserTreeObjectType.MACRO_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.PAGES_SECTION:
			case CompilerSourceParserTreeObjectType.PROCEDURE_DEFINITION_SECTION:
			case CompilerSourceParserTreeObjectType.REPEAT_SECTION:
				break;

			case CompilerSourceParserTreeObjectType.SOURCE_INCLUDE:
			case CompilerSourceParserTreeObjectType.BINARY_INCLUDE:
				break;

			default:
				throw new RuntimeException(
						"Element '" + object.getName() + "' has unknown type " + object.getType() + ".");

			}
			return result;
		}

		@Override
		public int compare(Viewer viewer, Object e1, Object e2) {

			if (!sortAction.isChecked()) {
				return 0;
			}

			int cat1 = category(e1);
			int cat2 = category(e2);

			// Never sort definition or implementation sections.
			if (cat1 == CompilerSourceParserTreeObjectType.DEFINITION_SECTION
					&& cat2 == CompilerSourceParserTreeObjectType.DEFINITION_SECTION) {
				return 0;
			}

			if (cat1 != cat2) {
				return cat1 - cat2;
			}

			String name1;
			String name2;

			if (viewer == null || !(viewer instanceof ContentViewer)) {
				name1 = e1.toString();
				name2 = e2.toString();
			} else {
				IBaseLabelProvider prov = ((ContentViewer) viewer).getLabelProvider();
				if (prov instanceof ILabelProvider) {
					ILabelProvider lprov = (ILabelProvider) prov;
					name1 = lprov.getText(e1);
					name2 = lprov.getText(e2);
				} else {
					name1 = e1.toString();
					name2 = e2.toString();
				}
			}
			if (name1 == null) {
				name1 = "";//$NON-NLS-1$
			}
			if (name2 == null) {
				name2 = "";//$NON-NLS-1$
			}

			// Use direct comparison as identifier are ASCII only.
			if (identifiersCaseSensitive) {
				return name1.compareTo(name2);
			} else {
				return name1.compareToIgnoreCase(name2);
			}

		}
	}

	/**
	 * Editor updater for selection changes in the content outline page.
	 */
	private final static class EditorUpdater extends RunnableWithLogging {
		private final Profiler profiler;

		private final LanguageEditor editor;
		private final LanguageOutlinePage outlinePage;
		private final TreeViewer viewer;
		private final LanguageOutlineTreeContentProvider contentProvider;

		EditorUpdater(LanguageEditor editor, LanguageOutlinePage outlinePage, TreeViewer viewer) {
			if (editor == null) {
				throw new IllegalArgumentException("Parameter 'editor' must not be null.");
			}
			if (outlinePage == null) {
				throw new IllegalArgumentException("Parameter 'outlinePage' must not be null.");
			}
			if (viewer == null) {
				throw new IllegalArgumentException("Parameter 'viewer' must not be null.");
			}
			this.editor = editor;
			this.outlinePage = outlinePage;
			this.viewer = viewer;
			this.contentProvider = (LanguageOutlineTreeContentProvider) viewer.getContentProvider();
			profiler = new Profiler(this);

		}

		/**
		 * Triggers a new {@link LanguageOutlineTreeContentProvider#parse} run and
		 * updates the display.
		 */
		@Override
		protected void runWithLogging() {
			synchronized (outlinePage) {
				try {
					outlinePage.inputUpdateCounter++;
					runSynchronized();
				} finally {
					outlinePage.inputUpdateCounter--;
				}
			}
		}

		private void runSynchronized() {
			// Stop drawing the control.
			Control control = viewer.getControl();

			// Check if this call is caused by closing the editor.
			if (control.isDisposed()) {
				return;
			}

			profiler.begin("runSynchronized");

			profiler.begin("updateOutline");
			control.setRedraw(false);

			// Remember the currently selected tree object in the content
			// outline tree viewer.
			ISelection selection = viewer.getSelection();
			Object[] expandedElements = viewer.getExpandedElements();

			// Trigger the the new parse run.
			viewer.setInput(outlinePage.input);
			// viewer.refresh(); Not required?

			profiler.begin("expandElements");
			if (expandedElements.length > 0) {
				viewer.setExpandedElements(expandedElements);
			} else {
				viewer.expandToLevel(2);
			}
			profiler.end("expandElements");

			restoreSelection(selection);
			// Now that all changes are done, draw the control again.
			control.setRedraw(true);
			profiler.end("updateOutline");

			// // Reselect the previous text selection in the editor.
			// editor.getSelectionProvider().setSelection(textSelection);

			CompilerSourceFile compilerSourceFile;
			compilerSourceFile = contentProvider.getCompilerSourceFile();

			// Update the identifiers to be highlighted
			profiler.begin("updateIdentifiers");
			editor.updateIdentifiers(compilerSourceFile);
			profiler.end("updateIdentifiers");

			// Update the folding structure.
			profiler.begin("updateFoldingStructure");
			List<Position> foldingPositions;
			if (compilerSourceFile != null) {
				foldingPositions = compilerSourceFile.getFoldingPositions();
			} else {
				foldingPositions = Collections.emptyList();
			}
			editor.updateFoldingStructure(foldingPositions);

			profiler.end("updateFoldingStructure");

			profiler.end("runSynchronized");

		}

		private void restoreSelection(ISelection selection) {
			if (selection instanceof TreeSelection) {
				TreeSelection treeSelection = (TreeSelection) selection;
				TreePath[] selectedTreePaths = treeSelection.getPaths();
				List<TreePath> reselectedTreePaths = new ArrayList<TreePath>(selectedTreePaths.length);
				for (int i = 0; i < selectedTreePaths.length; i++) {
					TreePath treePath = selectedTreePaths[i];
					List<CompilerSourceParserTreeObject> treeObjects = contentProvider.getCompilerSourceFile()
							.getSections();

					List<Object> segments = new ArrayList<Object>(treePath.getSegmentCount());

					for (int j = 0; j < treePath.getSegmentCount(); j++) {
						CompilerSourceParserTreeObject oldTreeObject;
						CompilerSourceParserTreeObject newTreeObject;
						oldTreeObject = (CompilerSourceParserTreeObject) treePath.getSegment(j);
						newTreeObject = null;

						for (int k = 0; newTreeObject == null && k < treeObjects.size(); k++) {
							if (treeObjects.get(k).getTreePath().equals(oldTreeObject.getTreePath())) {
								newTreeObject = treeObjects.get(k);
								segments.add(newTreeObject);
								treeObjects = newTreeObject.getChildren();
							}
						}

					}
					if (!segments.isEmpty()) {
						reselectedTreePaths.add(new TreePath(segments.toArray()));
					}

				}

				TreePath[] reselectedTreePathsArray = new TreePath[reselectedTreePaths.size()];
				reselectedTreePaths.toArray(reselectedTreePathsArray);
				selection = new TreeSelection(reselectedTreePathsArray);

				// Reselect the previously selected tree object in the
				// content outline tree viewer.
				viewer.setSelection(selection);
			}
		}
	}

	/**
	 * The owning editor.
	 */
	final LanguageEditor editor;

	/**
	 * The visual components.
	 */
	private OutlineViewerSortAction treeViewerSortAction;
	private OutlineViewerComparator treeViewerComparator;

	/**
	 * The current input.
	 */
	IEditorInput input;
	int inputUpdateCounter;

	/**
	 * Creates a new instance.
	 * 
	 * @param editor The language editor, not <code>null</code>.
	 */
	public LanguageOutlinePage(LanguageEditor editor) {
		if (editor == null) {
			throw new IllegalArgumentException("Parameter 'editor' must not be null.");
		}
		this.editor = editor;
	}

	/**
	 * Sets the input for the outline page.
	 * 
	 * @param input The new input, not <code>null</code>.
	 */
	public final void setInput(IEditorInput input) {
		if (input == null) {
			throw new IllegalArgumentException("Parameter 'input' must not be null.");
		}
		this.input = input;

		runEditorUpdater();
	}

	private void runEditorUpdater() {
		final TreeViewer viewer = getTreeViewer();

		if ((viewer != null) && (viewer.getContentProvider() != null)) {
			editor.getSite().getShell().getDisplay().asyncExec(new EditorUpdater(editor, this, viewer));
		}
	}

	/**
	 * Create the control and configures it. See code of
	 * org.eclipse.jdt.internal.ui.text.JavaOutlineInformationControl for similar
	 * use case.
	 * 
	 * @param parent �The parent, not <code>null</code>.
	 */
	@Override
	public void createControl(Composite parent) {
		super.createControl(parent);

		TreeViewer treeViewer = getTreeViewer();

		// Configure the toolbar.
		treeViewerSortAction = new OutlineViewerSortAction(editor, treeViewer);
		treeViewerComparator = new OutlineViewerComparator(treeViewerSortAction);
		IToolBarManager toolBarManager = getSite().getActionBars().getToolBarManager();

		// Configure the content.
		treeViewer.setContentProvider(new LanguageOutlineTreeContentProvider(this));
		treeViewer.setLabelProvider(new CompilerSourceParserTreeObjectLabelProvider());
		treeViewer.setComparator(treeViewerComparator);
		treeViewer.addSelectionChangedListener(this);

		toolBarManager.add(treeViewerSortAction);
		toolBarManager.update(true);

		if (input != null) {
			runEditorUpdater();
		}

	}

	@Override
	public void selectionChanged(SelectionChangedEvent event) {
		super.selectionChanged(event);

		synchronized (this) {
			if (inputUpdateCounter > 0) {
				return;
			}
		}

		ISelection selection = event.getSelection();

		if (selection.isEmpty()) {
			editor.resetHighlightRange();
		} else {
			if (selection instanceof IStructuredSelection) {
				Object object = ((IStructuredSelection) selection).getFirstElement();

				if (object instanceof CompilerSourceParserTreeObject) {

					CompilerSourceParserTreeObject treeObject;
					LanguageOutlineTreeContentProvider contentProvider;
					contentProvider = (LanguageOutlineTreeContentProvider) getTreeViewer().getContentProvider();
					treeObject = (CompilerSourceParserTreeObject) object;

					// If this is the tree object from another (source
					// include) file, step off the tree to find the source
					// include statement.
					while (treeObject != null
							&& treeObject.getCompilerSourceFile() != contentProvider.getCompilerSourceFile()) {
						treeObject = treeObject.getParent();
					}
					if (treeObject != null) {
						try {
							editor.setHighlightRange(treeObject.getStartOffset(), 0, true);
							editor.getSelectionProvider()
									.setSelection(new TextSelection(treeObject.getStartOffset(), 1));
						} catch (IllegalArgumentException x) {
							editor.resetHighlightRange();
						}
					}

				}
			}
		}
	}

	/**
	 * Gets the compiler source file of the last parse process.
	 * 
	 * @return The compiler source file of the last parse process or
	 *         <code>null</code>.
	 */
	public final CompilerSourceFile getCompilerSourceFile() {
		LanguageOutlineTreeContentProvider contentProvider;
		contentProvider = (LanguageOutlineTreeContentProvider) getTreeViewer().getContentProvider();
		CompilerSourceFile compilerSourceFile = contentProvider.getCompilerSourceFile();
		return compilerSourceFile;
	}

}
