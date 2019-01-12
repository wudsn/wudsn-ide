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

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.base.gui.MessageManager;

/**
 * The handler based class for commands based on the {@link HexEditorSelection}.
 * 
 * @author Peter Dell
 */
public abstract class HexEditorSelectionCommandHandler extends AbstractHandler {

    protected ExecutionEvent event;
    protected String commandId;
    protected HexEditorSelection hexEditorSelection;
    protected HexEditor hexEditor;
    protected MessageManager messageManager;

    /**
     * Creation is protected.
     */
    protected HexEditorSelectionCommandHandler() {
	super();
    }

    @Override
    public final Object execute(ExecutionEvent event) throws ExecutionException {
	IEditorPart editorPart;
	ISelection menuEditorInputSelection;
	editorPart = HandlerUtil.getActiveEditor(event);
	menuEditorInputSelection = HandlerUtil.getActiveMenuSelection(event);

	if (editorPart instanceof HexEditor && menuEditorInputSelection instanceof HexEditorSelection) {

	    this.event = event;
	    this.commandId = event.getCommand().getId();
	    this.hexEditorSelection = (HexEditorSelection) menuEditorInputSelection;
	    this.hexEditor = ((HexEditor) editorPart);
	    this.messageManager = hexEditor.getMessageManager();
	    messageManager.clearMessages();

	    performAction();

	    messageManager.displayMessages();

	}

	return null;
    }

    protected abstract void performAction() throws ExecutionException;
}
