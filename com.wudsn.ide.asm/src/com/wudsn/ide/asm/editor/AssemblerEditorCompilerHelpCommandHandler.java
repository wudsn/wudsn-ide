/**
 * Copyright (C) 2009 - 2020 <a href="https://www.wudsn.com" target="_top">Peter Dell</a>
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

import java.io.File;

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.program.Program;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.asm.AssemblerPlugin;
import com.wudsn.ide.asm.compiler.CompilerDefinition;
import com.wudsn.ide.asm.preferences.AssemblerPreferences;

/**
 * Event handler for the "Compiler Help" command.
 * 
 * @author Peter Dell
 */
public final class AssemblerEditorCompilerHelpCommandHandler extends AbstractHandler {

    @Override
    public Object execute(ExecutionEvent event) throws ExecutionException {
	Shell shell;
	shell = HandlerUtil.getActiveShell(event);

	IEditorPart editor;
	editor = HandlerUtil.getActiveEditorChecked(event);
	if (!(editor instanceof AssemblerEditor)) {
	    return null;
	}

	AssemblerEditor assemblerEditor;
	assemblerEditor = (AssemblerEditor) editor;

	CompilerDefinition compilerDefinition = assemblerEditor.getCompilerDefinition();
	AssemblerPreferences assemblerPreferences = AssemblerPlugin.getInstance().getPreferences();
	String compilerExecutablePath = assemblerPreferences.getCompilerExecutablePath(compilerDefinition.getId());

	try {
	    File file = compilerDefinition.getHelpFile(compilerExecutablePath);
	    Program.launch(file.getPath());

	} catch (CoreException ex) {
	    // ERROR: Display text from core exception.
	    MessageDialog.openInformation(shell, com.wudsn.ide.base.Texts.DIALOG_TITLE, ex.getMessage());
	}

	return null;
    }
}
