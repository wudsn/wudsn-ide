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

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.expressions.PropertyTester;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.ITextSelection;
import org.eclipse.text.edits.ReplaceEdit;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;
import org.eclipse.ui.texteditor.ITextEditor;
import org.eclipse.ui.texteditor.ITextEditorExtension2;

/**
 * Command handler for converting number within a text selection.<br/>
 * TODO Check block selection mode and read-only mode for multi line conversion,
 * see https://bugs.eclipse.org/bugs/show_bug.cgi?id=382707<br/>
 * 
 * @author Peter Dell
 * 
 * @since 1.6.3
 */
public final class TextEditorConvertNumbersCommand {

    public static final class Id {
	public static final String TO_DECIMAL = "com.wudsn.ide.base.editor.text.TextEditorConvertNumbersToDecimalCommand";
	public static final String TO_HEXA_DECIMAL = "com.wudsn.ide.base.editor.text.TextEditorConvertNumbersToHexaDecimalCommand";
	public static final String TO_BINARY = "com.wudsn.ide.base.editor.text.TextEditorConvertNumbersToBinaryCommand";
    }

    private static final class Mode {
	public final static int DECIMAL = 1;
	public final static int HEXA_DECIMAL = 2;
	public final static int BINARY = 3;
    }

    /**
     * In the productive code, this field must be <code>false</code>, to enable
     * the property checks when the menu is created. To debug the conversion,
     * this field must be set to <code>true</code>, to disable the property
     * checks when the menu is created.
     */

    private static final boolean DEBUG = false;

    public static final class EnabledPropertyTester extends PropertyTester {

	public EnabledPropertyTester() {
	}

	@Override
	public boolean test(final Object receiver, final String property, final Object[] args,
		final Object expectedValue) {

	    if (property.equals("isEnabled") && receiver instanceof ITextSelection && expectedValue instanceof String) {
		ITextSelection selection = (ITextSelection) receiver;
		String commandId = (String) expectedValue;
		int length = selection.getLength();
		boolean enabled;
		// For performance reasons, the test is skipped of the selected
		// block is large and we simply assume there are numbers in.
		if (length <= 0) {
		    enabled = false;
		} else if (length > 1024 || DEBUG) {
		    enabled = true;
		} else {
		    StringBuilder result = new StringBuilder(selection.getLength());
		    enabled = convertNumberValues(selection, commandId, result);
		}
		return enabled;

	    }
	    return false;
	}
    }

    public static final class Handler extends AbstractHandler {

	public Handler() {

	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
	    IEditorPart editor;
	    String commandId;

	    commandId = event.getCommand().getId();
	    editor = HandlerUtil.getActiveEditorChecked(event);

	    if (!(editor instanceof ITextEditor)) {
		return null;
	    }

	    // Find editor, document, selection, start and end line.
	    ITextEditor textEditor;
	    IDocument document;
	    ITextSelection selection;

	    textEditor = (ITextEditor) editor;

	    document = textEditor.getDocumentProvider().getDocument(textEditor.getEditorInput());
	    selection = (ITextSelection) textEditor.getSelectionProvider().getSelection();
	    StringBuilder result = new StringBuilder(selection.getLength());
	    if (convertNumberValues(selection, commandId, result)) {
		try {

		    if (editor instanceof ITextEditorExtension2) {
			ITextEditorExtension2 extension = (ITextEditorExtension2) editor;
			if (!extension.validateEditorInputState()) {
			    return null;
			}
		    }
		    // TODO: Multiple replace edits in case of block selection.
		    ReplaceEdit replaceEdit = new ReplaceEdit(selection.getOffset(), selection.getLength(),
			    result.toString());
		    replaceEdit.apply(document);

		} catch (BadLocationException ex) {
		    throw new RuntimeException(ex);
		}
	    }

	    return null;
	}

    }

    final static boolean convertNumberValues(ITextSelection selection, String commandId, StringBuilder result) {

	if (selection == null) {
	    throw new IllegalArgumentException("Parameter 'selection' must not be null.");
	}

	int mode;
	if (commandId.equals(Id.TO_DECIMAL)) {
	    mode = Mode.DECIMAL;
	} else if (commandId.equals(Id.TO_HEXA_DECIMAL)) {
	    mode = Mode.HEXA_DECIMAL;
	} else if (commandId.equals(Id.TO_BINARY)) {
	    mode = Mode.BINARY;
	} else {
	    throw new IllegalArgumentException("Unsupported command '" + commandId + "'.");
	}
	if (result == null) {
	    throw new IllegalArgumentException("Parameter 'result' must not be null.");
	}

	// if (selection instanceof IBlockTextSelection) {
	// return false;
	// }

	int length = selection.getLength();
	if (length == 0) {
	    return false;
	}

	String text = selection.getText();
	length = text.length(); // Because it might be a block selection
	boolean numbersFound = false;

	StringBuilder number = new StringBuilder();
	int offset = 0;
	int endOffset = length;

	try {
	    while (offset < endOffset) {
		char c1;
		char c2;
		long value;
		c1 = text.charAt(offset);

		if (offset < endOffset - 1) {
		    c2 = text.charAt(offset + 1);
		} else {
		    c2 = ' ';
		}

		if (c1 >= '0' && c1 <= '9') {
		    number.setLength(0);
		    while (offset < endOffset && c1 >= '0' && c1 <= '9') {
			number.append(c1);
			offset++;
			if (offset < endOffset) {
			    c1 = text.charAt(offset);
			}
		    }
		    value = Long.parseLong(number.toString());
		    appendNumberValue(result, mode, value);
		    numbersFound = true;

		} else if (c1 == '$'
			&& ((c2 >= '0' && c2 <= '9') || (c2 >= 'A' && c2 <= 'F') || (c2 >= 'a' && c2 <= 'f'))) {
		    number.setLength(0);
		    offset++;
		    c1 = c2;
		    while (offset < endOffset
			    && ((c1 >= '0' && c1 <= '9') || (c1 >= 'A' && c1 <= 'F') || (c1 >= 'a' && c1 <= 'f'))) {
			number.append(c1);
			offset++;
			if (offset < endOffset) {
			    c1 = text.charAt(offset);
			}
		    }

		    value = Long.parseLong(number.toString(), 16);
		    appendNumberValue(result, mode, value);
		    numbersFound = true;

		} else if (c1 == '%' && (c2 >= '0' && c2 <= '1')) {
		    number.setLength(0);
		    offset++;
		    c1 = c2;
		    while (offset < endOffset && ((c1 >= '0' && c1 <= '1'))) {
			number.append(c1);
			offset++;
			if (offset < endOffset) {
			    c1 = text.charAt(offset);
			}
		    }
		    value = Long.parseLong(number.toString(), 2);
		    appendNumberValue(result, mode, value);
		    numbersFound = true;
		} else {
		    result.append(c1);
		    offset++;
		}
	    }
	} catch (NumberFormatException ex) {
	    return false; // For example if the number becomes too large
	}

	// Do nothing if the text is already the same.
	if (result.toString().equals(selection.getText())) {
	    numbersFound = false;
	}
	return numbersFound;
    }

    private static void appendNumberValue(StringBuilder result, int mode, long value) {
	if (result == null) {
	    throw new IllegalArgumentException("Parameter 'result' must not be null.");
	}

	switch (mode) {
	case Mode.DECIMAL:
	    result.append(Long.toString(value));
	    break;
	case Mode.HEXA_DECIMAL:
	    result.append("$");
	    String hexValue = Long.toHexString(value);
	    int hexLength = hexValue.length();
	    while ((hexLength & 1) != 0) {
		result.append('0');
		hexLength++;
	    }
	    result.append(hexValue);
	    break;
	case Mode.BINARY:
	    result.append("%");
	    String binaryValue = Long.toBinaryString(value);
	    int binarLength = binaryValue.length();
	    while ((binarLength & 7) != 0) {
		result.append('0');
		binarLength++;
	    }
	    result.append(binaryValue);
	    break;

	default:
	    throw new IllegalArgumentException("Unsupported mode " + mode + ".");
	}

    }
}
