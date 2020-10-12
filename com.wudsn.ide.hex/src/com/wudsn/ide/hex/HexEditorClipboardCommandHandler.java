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

package com.wudsn.ide.hex;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.swt.dnd.Clipboard;
import org.eclipse.swt.dnd.TextTransfer;
import org.eclipse.swt.dnd.Transfer;
import org.eclipse.ui.IWorkbenchSite;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;

/**
 * The handler for the commands to copy the selection to the clipboard.
 * 
 * @author Peter Dell
 */
public final class HexEditorClipboardCommandHandler extends HexEditorSelectionCommandHandler {

    public static final class CommandIds {

	private CommandIds() {
	}

	public static final String COPY = "com.wudsn.ide.hex.HexEditorCopyToClipboardCommand";
	public static final String COPY_AS_HEX_VALUES = "com.wudsn.ide.hex.HexEditorCopyToClipboardAsHexValuesCommand";
	public static final String COPY_AS_DECIMAL_VALUES = "com.wudsn.ide.hex.HexEditorCopyToClipboardAsDecimalValuesCommand";
	public static final String COPY_AS_DECIMAL_VALUES_BLOCK = "com.wudsn.ide.hex.HexEditorCopyToClipboardAsDecimalValuesBlockCommand";
	public static final String COPY_AS_ASCII_STRING = "com.wudsn.ide.hex.HexEditorCopyToClipboardAsASCIIStringCommand";
	public static final String PASTE = "com.wudsn.ide.hex.HexEditorPasteFromClipboardCommand";
    }

    /**
     * Creation is public. Called by extension point "org.eclipse.ui.handlers".
     */
    public HexEditorClipboardCommandHandler() {
	super();
    }

    @Override
    protected void performAction() throws ExecutionException {

	byte[] bytes;
	bytes = hexEditorSelection.getBytes();
	StringBuilder builder = new StringBuilder(5 * bytes.length);
	String lineSeparator = System.getProperty("line.separator");

	Object[] data;
	Transfer[] transfers;

	int bytesPerRow = hexEditor.getBytesPerRow();
	if (commandId.equals(CommandIds.COPY) && !hexEditorSelection.isEmpty()) {
	    data = new Object[] { hexEditorSelection };
	    transfers = new Transfer[] { HexEditorSelectionTransfer.getInstance() };
	    copyToClipboard(bytes, data, transfers);

	} else if ((commandId.equals(CommandIds.COPY_AS_HEX_VALUES)
		|| commandId.equals(CommandIds.COPY_AS_DECIMAL_VALUES)
		|| commandId.equals(CommandIds.COPY_AS_DECIMAL_VALUES_BLOCK)
		|| commandId.equals(CommandIds.COPY_AS_ASCII_STRING)) && !hexEditorSelection.isEmpty()) {
	    if (commandId.equals(CommandIds.COPY_AS_HEX_VALUES)) {
		builder.append(".byte ");
		for (int i = 0; i < bytes.length; i++) {
		    builder.append("$");
		    builder.append(HexUtility.getByteValueHexString(bytes[i] & 0xff));
		    if ((i + 1) % bytesPerRow == 0) {
			builder.append(lineSeparator);
			if (i < bytes.length - 1) {
			    builder.append(".byte ");
			}
		    } else {
			if (i < bytes.length - 1) {
			    builder.append(',');
			}
		    }
		}
	    } else if (commandId.equals(CommandIds.COPY_AS_DECIMAL_VALUES)
		    || commandId.equals(CommandIds.COPY_AS_DECIMAL_VALUES_BLOCK)) {
		// In block mode, decimals are aligned to 3 digits.
		boolean block = commandId.equals(CommandIds.COPY_AS_DECIMAL_VALUES_BLOCK);
		builder.append(".byte ");
		for (int i = 0; i < bytes.length; i++) {
		    int b = bytes[i] & 0xff;
		    if (block) {
			if (b < 10) {
			    builder.append("  ");
			} else if (b < 100) {
			    builder.append(' ');
			}
		    }
		    builder.append(Integer.toString(b));
		    if ((i + 1) % bytesPerRow == 0) {
			builder.append(lineSeparator);
			if (i < bytes.length - 1) {
			    builder.append(".byte ");
			}
		    } else {
			if (i < bytes.length - 1) {
			    builder.append(',');
			}
		    }
		}
	    } else if (commandId.equals(CommandIds.COPY_AS_ASCII_STRING)) {
		for (int i = 0; i < bytes.length; i++) {
		    char c = (char) (bytes[i] & 0xff);
		    builder.append(c);
		}
	    } else {
		throw new IllegalArgumentException("Unknown command '" + commandId + "'.");
	    }
	    data = new Object[] { builder.toString(), hexEditorSelection };
	    transfers = new Transfer[] { TextTransfer.getInstance(), HexEditorSelectionTransfer.getInstance() };
	    copyToClipboard(bytes, data, transfers);

	} else if (commandId.equals(CommandIds.PASTE)) {
	    pasteFromClipboard();
	}

    }

    private void copyToClipboard(byte[] bytes, Object[] data, Transfer[] transfers) throws ExecutionException {
	if (bytes == null) {
	    throw new IllegalArgumentException("Parameter 'bytes' must not be null.");
	}
	if (data == null) {
	    throw new IllegalArgumentException("Parameter 'data' must not be null.");
	}
	if (transfers == null) {
	    throw new IllegalArgumentException("Parameter 'transfers' must not be null.");
	}
	IWorkbenchSite site = HandlerUtil.getActiveSiteChecked(event);
	Clipboard clipboard = new Clipboard(site.getShell().getDisplay());
	try {

	    clipboard.setContents(data, transfers);

	} finally {
	    clipboard.dispose();
	}

	// INFO: ${0} ({1}) bytes copied to clipboard.
	messageManager.sendMessage(0, IStatus.OK, Texts.MESSAGE_I302, HexUtility.getLongValueHexString(bytes.length),
		NumberUtility.getLongValueDecimalString(bytes.length));
    }

    private void pasteFromClipboard() throws ExecutionException {

	IWorkbenchSite site = HandlerUtil.getActiveSiteChecked(event);
	Clipboard clipboard = new Clipboard(site.getShell().getDisplay());
	try {

	    Object data = clipboard.getContents(HexEditorSelectionTransfer.getInstance());
	    if (data != null) {
		byte[] bytes = ((HexEditorSelection) data).getBytes();
		hexEditor.pasteFromClipboard(bytes);

	    }
	} finally {
	    clipboard.dispose();
	}

    }
}
