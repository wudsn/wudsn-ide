/**
* Copyright (C) 2009 - 2019 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.util.List;
import java.util.ResourceBundle;

import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextOperationTarget;
import org.eclipse.jface.text.TextSelection;
import org.eclipse.jface.text.source.SourceViewer;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.texteditor.TextEditorAction;

import com.wudsn.ide.asm.AssemblerPlugin;

/**
 * Action to toggle a comment.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
final class AssemblerEditorToggleCommentAction extends TextEditorAction {

    /**
     * The owning editor.
     */
    private final AssemblerEditor editor;

    /**
     * The editor's source viewer.
     */
    private final SourceViewer sourceViewer;

    /**
     * Creates a new instance.
     * 
     * @param bundle
     *            The resource bundle, not <code>null</code>.
     * @param prefix
     *            The resource bundle key prefix, not <code>null</code>.
     * 
     * @param editor
     *            The assembler editor, not <code>null</code>.
     * @param sourceViewer
     *            The assembler editor's source viewer.
     * 
     */
    AssemblerEditorToggleCommentAction(ResourceBundle bundle, String prefix,
	    AssemblerEditor editor, SourceViewer sourceViewer) {
	super(bundle, prefix, editor);
	if (editor == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'editor' must not be null.");
	}
	if (sourceViewer == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'sourceViewer' must not be null.");
	}
	this.editor = editor;
	this.sourceViewer = sourceViewer;
    }

    @Override
    public void update() {
	setEnabled(canModifyEditor());
    }

    @Override
    public void run() {
	IDocument document = sourceViewer.getDocument();
	ISelection selection = sourceViewer.getSelection();
	TextSelection textSelection;
	if (selection instanceof TextSelection) {
	    textSelection = (TextSelection) selection;
	    boolean isCommented = isCommented(document, textSelection);
	    if (isCommented) {
		sourceViewer.doOperation(ITextOperationTarget.STRIP_PREFIX);
	    } else {
		sourceViewer.doOperation(ITextOperationTarget.PREFIX);
	    }
	}
    }

    /**
     * Checks, if the selection in the given document is commented fully using
     * one of the single line comment delimiters.
     * 
     * @param document
     *            The document, not <code>null</code>.
     * @param selection
     *            The selection, not <code>null</code>.
     * 
     * @return <code>true</code>, if commented.
     */
    private boolean isCommented(IDocument document, TextSelection selection) {
	if (document == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'document' must not be null.");
	}
	if (selection == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'selection' must not be null.");
	}
	try {
	    int startLine = selection.getStartLine();
	    int endLine = selection.getEndLine();
	    for (int line = startLine; line <= endLine; line++) {
		int lineOffset = document.getLineOffset(line);
		int lineLength = document.getLineLength(line);
		String lineText = document.get(lineOffset, lineLength);

		if (!isCommented(lineText)) {
		    return false;
		}
	    }
	} catch (BadLocationException ex) {
	    AssemblerPlugin.getInstance().logError("Cannot find location", null, ex);
	}

	return true;
    }

    /**
     * Checks, if the line is commented using one of the single line comment
     * delimiters.
     * 
     * @param lineText
     *            The line text, may be empty, not <code>null</code>.
     * 
     * @return <code>true</code>, if commented.
     */
    private boolean isCommented(String lineText) {

	if (lineText == null) {
	    throw new IllegalArgumentException(
		    "Parameter 'lineText' must not be null.");
	}

	List<String> singleLineCommentDeliminters;
	singleLineCommentDeliminters = editor.getCompilerDefinition()
		.getSyntax().getSingleLineCommentDelimiters();
	for (String delimiter : singleLineCommentDeliminters) {
	    if (lineText.startsWith(delimiter)) {
		return true;
	    }
	}
	return false;
    }
}
