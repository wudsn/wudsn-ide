/**
 * Copyright (C) 2009 - 2014 <a href="http://www.wudsn.com" target="_top">Peter Dell</a>
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

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.common.NotDefinedException;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.compiler.CompilerFiles;

/**
 * Base class for commands which operate on the current file of an assembler
 * editor, in case the file is within the work space. The base class ensures
 * that the corresponding command is disabled, if there is no active assembler
 * editor or the editor contains a file from outside of the work space.
 * 
 * @author Peter Dell
 */
public abstract class AssemblerEditorFilesCommandHandler extends
	AbstractHandler {

    public AssemblerEditorFilesCommandHandler() {
	super();
    }

    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
	IEditorPart editor;
	editor = HandlerUtil.getActiveEditorChecked(event);
	if (!(editor instanceof AssemblerEditor)) {
	    return null;
	}

	AssemblerEditor assemblerEditor;
	assemblerEditor = (AssemblerEditor) editor;

	CompilerFiles files;
	files = AssemblerEditorFilesLogic.createInstance(assemblerEditor).createCompilerFiles();

	if (files != null) {
	    execute(event, assemblerEditor, files);
	} else {
	    try {
		AssemblerPlugin
			.getInstance()
			.showError(
				assemblerEditor.getSite().getShell(),
				"Operation '"
					+ event.getCommand().getName()
					+ "' is not possible because the file in the editor is not located in the worksapce.",
				new Exception());
	    } catch (NotDefinedException ignore) {
		// Ignore
	    }
	}
	return null;
    }

    /**
     * Perform the action on the current editor and file.
     * 
     * @param event
     *            The event, not <code>null</code>.
     * @param assemblerEditor
     *            The assembler editor, not <code>null</code> and with current
     *            files which are not <code>null</code>.
     * @param files
     *            The current compiler files of the editor, not <code>null</code>
     *            .
     * @throws ExecutionException
     *             if an exception occurred during execution.
     */
    protected abstract void execute(ExecutionEvent event,
	    AssemblerEditor assemblerEditor, CompilerFiles files)
	    throws ExecutionException;

}