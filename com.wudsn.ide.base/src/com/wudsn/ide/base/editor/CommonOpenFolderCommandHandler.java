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

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.IAdaptable;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.swt.program.Program;
import org.eclipse.ui.IFileEditorInput;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.base.common.FileUtility;

/**
 * Event handler for the "Open Folder" context menu command to start a given
 * editor.
 * 
 * @author Peter Dell
 */
public final class CommonOpenFolderCommandHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		List<String> folderPaths = new ArrayList<String>(3);

		ISelection menuSelection;
		menuSelection = HandlerUtil.getActiveMenuSelection(event);
		ISelection menuEditorInputSelection;
		menuEditorInputSelection = HandlerUtil.getActiveMenuEditorInput(event);

		if (menuSelection instanceof IStructuredSelection) {
			Iterator<?> i = ((IStructuredSelection) menuSelection).iterator();
			while (i.hasNext()) {
				Object object = i.next();
				openFolder(folderPaths, object);

			}
		} else if (menuEditorInputSelection instanceof IStructuredSelection) {
			Iterator<?> i = ((IStructuredSelection) menuEditorInputSelection).iterator();
			while (i.hasNext()) {
				Object object = i.next();
				if (object instanceof IFileEditorInput) {
					IFileEditorInput fileEditorInput = (IFileEditorInput) object;
					openFolder(folderPaths, fileEditorInput.getFile());
				}
			}
		}

		return null;
	}

	/**
	 * Open the folder for an object (resource).
	 * 
	 * @param folderPaths The modifiable list of folders already opened, not
	 *                    <code>null</code>.
	 * @param object      The object of which the folder shall be opened or
	 *                    <code>null</code>.
	 */
	private void openFolder(List<String> folderPaths, Object object) {
		if (folderPaths == null) {
			throw new IllegalArgumentException("Parameter 'folderPaths' must not be null.");
		}
		String folderPath;

		if (object instanceof IAdaptable && !(object instanceof IResource || object instanceof File)) {
			IAdaptable adapter = (IAdaptable) object;
			object = adapter.getAdapter(IResource.class);
			if (object == null) {
				object = adapter.getAdapter(File.class);
			}
		}

		if (object instanceof IResource) {
			IResource resource = (IResource) object;

			IPath path = resource.getRawLocation();
			if (path == null) {
				path = resource.getLocation();
			}
			folderPath = getFolderPath(path);

		} else if (object instanceof File) {
			File file = (File) object;

			if (file.isDirectory()) {
				folderPath = FileUtility.getCanonicalFile(file).getPath();
			} else {
				folderPath = FileUtility.getCanonicalFile(file.getParentFile()).getPath();
			}

		} else {
			folderPath = null;
		}

		if (folderPath != null && !folderPaths.contains(folderPath)) {
			folderPaths.add(folderPath);
			Program.launch(folderPath);
		}
	}

	/**
	 * Converts an IPath to a real OS path.
	 * 
	 * @param path The path or <code>null</code>.
	 * @return The folder path, may be empty or <code>null</code>.
	 */
	private String getFolderPath(IPath path) {
		String folderPath;
		if (path != null) {
			String resourcePath = path.toOSString();
			File file = FileUtility.getCanonicalFile(new File(resourcePath));
			if (file.isDirectory()) {
				folderPath = file.getPath();
			} else {
				folderPath = file.getParentFile().getPath();
			}
		} else {
			folderPath = null;
		}
		return folderPath;
	}

}
