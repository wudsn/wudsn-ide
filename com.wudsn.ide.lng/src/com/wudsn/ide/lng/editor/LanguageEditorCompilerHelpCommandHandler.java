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

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.jface.dialogs.MessageDialog;
import org.eclipse.swt.program.Program;
import org.eclipse.ui.handlers.HandlerUtil;

/**
 * Event handler for the "Compiler Help" command.
 * 
 * @author Peter Dell
 */
public final class LanguageEditorCompilerHelpCommandHandler extends AbstractHandler {

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		var shell = HandlerUtil.getActiveShell(event);

		var editor = HandlerUtil.getActiveEditorChecked(event);
		if (!(editor instanceof LanguageEditor)) {
			return null;
		}

		var languageEditor = (LanguageEditor) editor;
		var compilerDefinition = languageEditor.getCompilerDefinition();
		var languagePreferences = languageEditor.getLanguagePreferences();
		var compilerExecutablePath = languagePreferences.getCompilerExecutablePathOrDefault(compilerDefinition);

		try {
			var helpDocument = compilerDefinition.getInstalledHelpForCurrentLocale(compilerExecutablePath);
			if (helpDocument.file != null) {
				Program.launch(helpDocument.file.getPath());
			} else {
				Program.launch(helpDocument.uri.toString());

			}

		} catch (CoreException ex) {
			// ERROR: Display text from core exception.
			MessageDialog.openInformation(shell, com.wudsn.ide.base.Texts.DIALOG_TITLE, ex.getMessage());
		}

		return null;
	}
}
