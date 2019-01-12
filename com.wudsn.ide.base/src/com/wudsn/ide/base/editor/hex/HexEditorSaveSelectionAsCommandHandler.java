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

package com.wudsn.ide.base.editor.hex;

import java.io.File;

import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.swt.SWT;
import org.eclipse.swt.widgets.FileDialog;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.base.Texts;
import com.wudsn.ide.base.common.FileUtility;
import com.wudsn.ide.base.common.HexUtility;
import com.wudsn.ide.base.common.NumberUtility;
import com.wudsn.ide.base.common.TextUtility;

public final class HexEditorSaveSelectionAsCommandHandler extends HexEditorSelectionCommandHandler {

    public static final class CommandIds {

	private CommandIds() {
	}

	public static final String SAVE_SELECTION_AS = "com.wudsn.ide.base.editor.hex.HexEditorSaveSelectionAsCommand";
    }

    @Override
    protected void performAction() throws ExecutionException {
	if (commandId.equals(CommandIds.SAVE_SELECTION_AS) && !hexEditorSelection.isEmpty()) {
	    Shell shell = HandlerUtil.getActiveShell(event);
	    if (shell == null) {
		return;
	    }
	    byte[] content = hexEditorSelection.getBytes();

	    FileDialog dialog = new FileDialog(shell, SWT.SAVE);
	    int length = content.length;
	    String hexLength = HexUtility.getLongValueHexString(length);
	    String decimalLength = NumberUtility.getLongValueDecimalString(length);
	    dialog.setText(TextUtility
		    .format(Texts.HEX_EDITOR_SAVE_SELECTION_AS_DIALOG_TITLE, hexLength, decimalLength));
	    dialog.setFileName(hexEditor.getSelectionSaveFilePath());
	    String filePath = dialog.open();
	    if (filePath != null) {
		try {
		    FileUtility.writeBytes(new File(filePath), content);
		    // INFO: ${0} ({1}) bytes saved as '{2}'.
		    hexEditor.getMessageManager().sendMessage(0, IStatus.OK, Texts.MESSAGE_I303, hexLength,
			    decimalLength, filePath);
		} catch (CoreException ex) {
		    throw new ExecutionException(ex.getMessage());
		}
	    }
	}

    }

}
