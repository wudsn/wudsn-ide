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
import java.net.URI;

import org.eclipse.core.filesystem.EFS;
import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.dialogs.ErrorDialog;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.hyperlink.IHyperlink;
import org.eclipse.swt.program.Program;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;

import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.Texts;

/**
 * Hyperlink implementation for opening source or binary include files.
 * 
 * @author Peter Dell
 */
final class AssemblerHyperlink implements IHyperlink {

	public static final String DEFAULT_EDITOR = "DEFAULT_EDITOR";
	public static final String SYSTEM_EDITOR = "SYSTEM_EDITOR";

	private IRegion region;
	private IWorkbenchPage workbenchPage;
	private String absoluteFilePath;
	private URI uri;
	private String editorId;
	private int lineNumber;
	private String hyperlinkText;

	/**
	 * Creates a new hyper link.
	 * 
	 * @param region           The region of the text, not <code>null</code>.
	 * 
	 * @param workbenchPage    The active workbench page used for the new editor
	 *                         instance, not <code>null</code>.
	 * 
	 * @param absoluteFilePath The absolute file path, not <code>null</code>.
	 * @param uri              The uri to be opened, not <code>null</code>.
	 * 
	 * @param editorId         The id of the editor to be opened, not empty and not
	 *                         <code>null</code>.
	 * 
	 * @param lineNumber       The liner number to position to, in case the editor
	 *                         is an {@link AssemblerEditor}. The line numbers are
	 *                         starting at 1. The value 0 indicates that no
	 *                         positioning shall take place.
	 * 
	 * @param hyperlinkText    The localized text to display in case there is more
	 *                         than one hyperlink for the same location, may be
	 *                         empty, not <code>null</code>.
	 */
	AssemblerHyperlink(IRegion region, IWorkbenchPage workbenchPage, String absoluteFilePath, URI uri, String editorId,
			int lineNumber, String hyperlinkText) {
		if (region == null) {
			throw new IllegalArgumentException("Parameter 'region' must not be null.");
		}
		if (workbenchPage == null) {
			throw new IllegalArgumentException("Parameter 'workbenchPage' must not be null.");
		}
		if (absoluteFilePath == null) {
			throw new IllegalArgumentException("Parameter 'absoluteFilePath' must not be null.");
		}
		if (uri == null) {
			throw new IllegalArgumentException("Parameter 'uri' must not be null.");
		}
		if (editorId == null) {
			throw new IllegalArgumentException("Parameter 'editorId' must not be null.");
		}
		if (StringUtility.isEmpty(editorId)) {
			throw new IllegalArgumentException("Parameter 'editorId' must not be empty.");
		}
		if (lineNumber < 0) {
			throw new IllegalArgumentException(
					"Parameter 'lineNumber' must not be negative. Specified value is " + lineNumber + ".");
		}

		if (hyperlinkText == null) {
			throw new IllegalArgumentException("Parameter 'hyperlinkText' must not be null.");
		}
		this.region = region;
		this.workbenchPage = workbenchPage;
		this.absoluteFilePath = absoluteFilePath;
		this.uri = uri;
		this.editorId = editorId;
		this.lineNumber = lineNumber;
		this.hyperlinkText = hyperlinkText;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public IRegion getHyperlinkRegion() {
		return region;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getTypeLabel() {
		return null;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public String getHyperlinkText() {
		return hyperlinkText;
	}

	/**
	 * {@inheritDoc}
	 */
	@Override
	public void open() {
		if (uri != null) {
			File fileToOpen = new File(absoluteFilePath);
			if (!fileToOpen.exists()) {
				String message = TextUtility.format(
						// ERROR: Target file '{0}' not exists. Do you
						// want to create the file now?
						Texts.COMPILER_HYPERLINK_FILE_NOT_EXISTS, absoluteFilePath);
				boolean result = MessageDialog.openQuestion(workbenchPage.getWorkbenchWindow().getShell(),
						com.wudsn.ide.base.Texts.DIALOG_TITLE, message);
				// Try to create the file, if OK was pressed.
				if (result) {
					try {
						FileUtility.writeString(fileToOpen, "");
					} catch (CoreException ex) {
						ErrorDialog.openError(workbenchPage.getWorkbenchWindow().getShell(),
								com.wudsn.ide.base.Texts.DIALOG_TITLE, null, ex.getStatus());
					}

				} else {
					return;
				}
			}
			IEditorPart editorPart;
			editorPart = null;
			if (editorId.equals(DEFAULT_EDITOR)) {

				if (fileToOpen.exists() && fileToOpen.isFile()) {
					IFileStore fileStore = EFS.getLocalFileSystem().getStore(fileToOpen.toURI());

					try {
						editorPart = IDE.openEditorOnFileStore(workbenchPage, fileStore);
					} catch (PartInitException ex) {

						LanguagePlugin.getInstance().logError("Cannot default editor editor for '{0}'.",
								new Object[] { uri }, ex);

					}
				} else {
					// Do something if the file does not exist
				}

			} else if (editorId.equals(SYSTEM_EDITOR)) {
				Program.launch(absoluteFilePath);
			} else {

				try {

					editorPart = IDE.openEditor(workbenchPage, uri, editorId, true);
				} catch (PartInitException ex) {
					LanguagePlugin.getInstance().logError("Cannot system editor editor for '{0}'.",
							new Object[] { uri }, ex);
				}
			}
			if (editorPart instanceof AssemblerEditor && lineNumber > 0) {
				AssemblerEditor assemblerEditor = (AssemblerEditor) editorPart;
				assemblerEditor.gotoLine(lineNumber);
			}

			uri = null;
		}
	}
}
