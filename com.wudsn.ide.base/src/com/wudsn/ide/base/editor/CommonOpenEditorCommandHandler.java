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

package com.wudsn.ide.base.editor;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IFile;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.part.FileEditorInput;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.StringUtility;

/**
 * The action to open an editor from the context menu. The editor will become
 * the new default editor for the resources on which the action is executed
 * successfully.
 * 
 * @author Peter Dell
 */
public abstract class CommonOpenEditorCommandHandler extends AbstractHandler {

	private final String editorId;

	/**
	 * Creation is protected, is only call by sub-classes.
	 * 
	 * @param editorId The editor id, not empty and not <code>null</code>.
	 */
	protected CommonOpenEditorCommandHandler(String editorId) {
		if (editorId == null) {
			throw new IllegalArgumentException("Parameter 'editorId' must not be null.");
		}
		if (StringUtility.isEmpty(editorId)) {
			throw new IllegalArgumentException("Parameter 'editorId' must not be empty.");
		}
		this.editorId = editorId;
	}

	@Override
	public final Object execute(ExecutionEvent event) throws ExecutionException {
		List<IFile> files = new ArrayList<IFile>(3);
		ISelection menuSelection;
		menuSelection = HandlerUtil.getActiveMenuSelection(event);
		ISelection menuEditorInputSelection;
		menuEditorInputSelection = HandlerUtil.getActiveMenuEditorInput(event);

		if (menuSelection instanceof IStructuredSelection) {
			Iterator<?> i = ((IStructuredSelection) menuSelection).iterator();
			while (i.hasNext()) {
				Object object = i.next();
				openFile(files, object);

			}
		} else if (menuEditorInputSelection instanceof IStructuredSelection) {
			Iterator<?> i = ((IStructuredSelection) menuEditorInputSelection).iterator();
			while (i.hasNext()) {
				Object object = i.next();
				if (object instanceof IFileEditorInput) {
					IFileEditorInput fileEditorInput = (IFileEditorInput) object;
					openFile(files, fileEditorInput.getFile());
				}
			}
		}

		return null;
	}

	/**
	 * Opens the specified file on the editor.
	 * 
	 * @param files  The modifiable list of files already opened, not
	 *               <code>null</code>.
	 * @param object The IFile object or <code>null</code>.
	 */
	private void openFile(List<IFile> files, Object object) {

		if (files == null) {
			throw new IllegalArgumentException("Parameter 'files' must not be null.");
		}
		if (object instanceof IFile) {

			IFile file = (IFile) object;
			if (!files.contains(file)) {
				files.add(file);

				IWorkbenchWindow workbenchWindow = PlatformUI.getWorkbench().getActiveWorkbenchWindow();
				IWorkbenchPage page = workbenchWindow.getActivePage();

				// Open an editor on the new file.
				try {
					FileEditorInput editorInput = new FileEditorInput(file);
					IEditorPart editor = page.findEditor(editorInput);
					if (editor != null) {
						String id = editor.getEditorSite().getId();
						if (!id.equals(editorId)) {
							if (!page.closeEditor(editor, true)) {
								return;
							}
						}
					}
					IDE.setDefaultEditor(file, editorId);
					IDE.openEditor(page, editorInput, editorId);
				} catch (PartInitException exception) {
					MessageDialog.openError(workbenchWindow.getShell(), Texts.DIALOG_TITLE, exception.getMessage());
				}
			}
		}
	}
}
