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

package com.wudsn.ide.base.editor.text;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.Command;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.texteditor.ITextEditor;
import org.eclipse.ui.texteditor.ITextEditorExtension2;

/**
 * Base class for text editor actions operating on the selected lines. Inspired
 * by http://www.stateofflow.com/projects/2/sortit.
 * 
 * @author Peter Dell
 */
abstract class TextEditorLinesCommandHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		IEditorPart editor;
		editor = HandlerUtil.getActiveEditorChecked(event);

		if (!(editor instanceof ITextEditor)) {
			return null;
		}

		// Find editor, document, selection, start and end line.
		ITextEditor textEditor;
		IDocument document;
		ITextSelection selection;
		int endLineIndex;
		int startLineIndex;

		textEditor = (ITextEditor) editor;

		document = textEditor.getDocumentProvider().getDocument(textEditor.getEditorInput());
		selection = (ITextSelection) textEditor.getSelectionProvider().getSelection();
		endLineIndex = selection.getEndLine();
		startLineIndex = selection.getStartLine();
		if (startLineIndex == endLineIndex) {
			startLineIndex = 0;
			endLineIndex = document.getNumberOfLines() - 1;
		}

		try {
			// Collect lines.
			int startOffset;
			int length;

			startOffset = document.getLineOffset(startLineIndex);
			length = 0;

			List<String> lines;
			lines = new ArrayList<String>();
			for (int line = startLineIndex; line <= endLineIndex; line++) {
				int delimiterLength = document.getLineDelimiter(line) == null ? 0
						: document.getLineDelimiter(line).length();
				String lineText = document.get(document.getLineOffset(line),
						document.getLineLength(line) - delimiterLength);
				lines.add(lineText);
				length = length + lineText.length() + delimiterLength;
			}

			process(event.getCommand(), lines);

			int lineCount = lines.size();
			String lineDelimiter = document.getLineDelimiter(startLineIndex);
			StringBuilder replacementText = new StringBuilder();
			for (int i = 0; i < lineCount; i++) {
				replacementText.append(lines.get(i));
				if ((i < lineCount - 1) || (i == lineCount - 1) && (document.getLineDelimiter(endLineIndex) != null)) {
					replacementText.append(lineDelimiter);
				}
			}

			if (editor instanceof ITextEditorExtension2) {
				ITextEditorExtension2 extension = (ITextEditorExtension2) editor;
				if (!extension.validateEditorInputState()) {
					return null;
				}
			}

			ReplaceEdit replaceEdit = new ReplaceEdit(startOffset, length, replacementText.toString());
			replaceEdit.apply(document);
			// re-select the lines that have been processed
			textEditor.getSelectionProvider().setSelection(selection);
		} catch (BadLocationException ex) {
			throw new ExecutionException("Error during handler execution.", ex);
		}
		return null;
	}

	/**
	 * Subclasses must process the lines given in the list. The processed list will
	 * be used to rebuild the lines in the editor.
	 * 
	 * @param command The command which is currently executed, not <code>null</code>
	 *                .
	 * 
	 * @param lines   The modifiable list of lines, may be empty, not
	 *                <code>null</code>.
	 */
	protected abstract void process(Command command, List<String> lines);

}
