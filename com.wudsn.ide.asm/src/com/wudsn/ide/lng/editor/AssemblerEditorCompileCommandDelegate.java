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

import java.util.List;

import org.eclipse.jface.action.Action;
import org.eclipse.jface.action.ActionContributionItem;
import org.eclipse.jface.action.IAction;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.ui.IActionDelegate2;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.IWorkbenchWindowPulldownDelegate2;

import com.wudsn.ide.base.common.StringUtility;
import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.base.hardware.HardwareUtility;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.preferences.CompilerPreferences;
import com.wudsn.ide.lng.runner.RunnerDefinition;
import com.wudsn.ide.lng.runner.RunnerId;
import com.wudsn.ide.lng.runner.RunnerRegistry;

/**
 * Delegate class to provide a dynamic drop-down menu for the toolbar based on
 * the configured runners for the currently active compiler's hardware.
 * 
 * @author Peter Dell
 * 
 */
public final class AssemblerEditorCompileCommandDelegate
		implements IActionDelegate2, IWorkbenchWindowPulldownDelegate2 {

	private IWorkbenchWindow window;
	private Menu menu;

	/**
	 * Private action class.
	 * 
	 * @author Peter Dell
	 */
	private final class CompileAndRunAction extends Action {
		private String runnerId;

		public CompileAndRunAction(String runnerId) {
			if (runnerId == null) {
				throw new IllegalArgumentException("Parameter 'runnerId' must not be null.");
			}
			this.runnerId = runnerId;
		}

		/**
		 * @see org.eclipse.jface.action.IAction#run()
		 */
		@Override
		public void run() {

		}

		@Override
		public void runWithEvent(Event event) {
			compileAndRun(runnerId);
		}
	}

	/**
	 * Creation is public.
	 */
	public AssemblerEditorCompileCommandDelegate() {
	}

	@Override
	public void init(IWorkbenchWindow window) {
		this.window = window;
	}

	@Override
	public Menu getMenu(Control parent) {

		AssemblerEditor assemblerEditor = getAssemblerEditor();
		if (assemblerEditor == null) {
			return null;
		}

		LanguagePlugin languagePlugin = assemblerEditor.getPlugin();
		RunnerRegistry runnerRegistry = languagePlugin.getRunnerRegistry();
		Hardware hardware = assemblerEditor.getHardware();
		List<RunnerDefinition> runnerDefinitions = runnerRegistry.getDefinitions(hardware);
		CompilerPreferences compilerPreferences = assemblerEditor.getCompilerPreferences();

		Menu menu = new Menu(parent);
		setMenu(menu);

		// Collect all runner definition for which the executable path is
		// maintained correctly.
		ImageDescriptor imageDescriptor = HardwareUtility.getImageDescriptor(hardware);
		for (RunnerDefinition runnerDefinition : runnerDefinitions) {
			String runnerId = runnerDefinition.getId();
			String runnerName = runnerDefinition.getName();
			// The system default application does not need an executable path.
			if (!runnerId.equals(RunnerId.DEFAULT_APPLICATION)) {
				if (StringUtility.isEmpty(compilerPreferences.getRunnerExecutablePath(runnerId))) {
					continue;
				}
			}

			Action action = new CompileAndRunAction(runnerId);
			action.setActionDefinitionId(AssemblerEditorCompileCommand.COMPILE_AND_RUN_WITH);
			action.setImageDescriptor(imageDescriptor);
			if (runnerId.equals(compilerPreferences.getRunnerId())) {
				runnerName = runnerName + " " + Texts.ASSEMBLER_TOOLBAR_RUN_WITH_DEFAULT_LABEL;
			}
			action.setText(runnerName);
			ActionContributionItem item = new ActionContributionItem(action);
			item.fill(menu, -1);
		}

		return menu;
	}

	@Override
	public Menu getMenu(Menu parent) {
		return null;
	}

	@Override
	public void dispose() {
		setMenu(null);
	}

	@Override
	public void init(IAction action) {
		AssemblerEditor assemblerEditor = getAssemblerEditor();
		boolean enabled = assemblerEditor != null && assemblerEditor.getCurrentIFile() != null;
		action.setEnabled(enabled);

		Hardware hardware;
		if (assemblerEditor != null) {
			hardware = assemblerEditor.getHardware();

		} else {
			hardware = Hardware.GENERIC;
		}
		ImageDescriptor imageDescriptor = HardwareUtility.getImageDescriptor(hardware);
		action.setImageDescriptor(imageDescriptor);
	}

	@Override
	public void run(IAction action) {
		// Not invoked
	}

	@Override
	public void runWithEvent(IAction action, Event event) {
		try {
			compileAndRun(null);
		} catch (RuntimeException ex) {
			LanguagePlugin.getInstance().showError(window.getShell(), "Error in compileAndRun()", ex);
		}
	}

	@Override
	public void selectionChanged(IAction action, ISelection selection) {
		init(action);
		// TODO: Check disabling of action based on current selection.
		// System.out.println(action.getActionDefinitionId());
		// System.out.println(selection);
	}

	/**
	 * Helper method to correctly retain and dispose menu instances.
	 * 
	 * @param menu The menu to be retained or <code>null</code>.
	 */
	private void setMenu(Menu menu) {
		if (this.menu != null) {
			this.menu.dispose();
		}
		this.menu = menu;
	}

	/**
	 * Gets the currently active assembler editor.
	 * 
	 * @return The currently active assembler editor or <code>null</code>.
	 */
	private AssemblerEditor getAssemblerEditor() {
		if (window == null) {
			return null;
		}

		IWorkbenchPage workbenchPage = window.getActivePage();
		if (workbenchPage == null) {
			return null;
		}
		IEditorPart editorPart = workbenchPage.getActiveEditor();
		if (!(editorPart instanceof AssemblerEditor)) {
			return null;
		}
		return (AssemblerEditor) editorPart;
	}

	/**
	 * Call the compiler and run command with the specified runner id.
	 * 
	 * @param runnerId The runner id or <code>null</code> to use the default.
	 */
	final void compileAndRun(String runnerId) {
		AssemblerEditor assemblerEditor = getAssemblerEditor();
		if (assemblerEditor == null) {
			throw new IllegalStateException("Action is active but no assembler editor is active.");
		}
		AssemblerEditorCompileCommand.execute(assemblerEditor,
				AssemblerEditorFilesLogic.createInstance(assemblerEditor).createCompilerFiles(),
				AssemblerEditorCompileCommand.COMPILE_AND_RUN, runnerId);
	}

}
