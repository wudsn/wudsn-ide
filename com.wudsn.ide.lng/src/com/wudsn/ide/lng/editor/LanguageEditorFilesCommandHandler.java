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
import org.eclipse.core.commands.common.NotDefinedException;
import org.eclipse.ui.handlers.HandlerUtil;

import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.CompilerFiles;

/**
 * Base class for commands which operate on the current file of an language
 * editor, in case the file is within the work space. The base class ensures
 * that the corresponding command is disabled, if there is no active language
 * editor or the editor contains a file from outside of the work space.
 * 
 * @author Peter Dell
 */
public abstract class LanguageEditorFilesCommandHandler extends AbstractHandler {

	public LanguageEditorFilesCommandHandler() {
		super();
	}

	@Override
	public Object execute(ExecutionEvent event) throws ExecutionException {
		var editor = HandlerUtil.getActiveEditorChecked(event);
		if (!(editor instanceof ILanguageEditor)) {
			if (!LanguageEditorPropertyTester.isPascalEditor(editor)) {
				return null;

			}
//			editor=new ILanguageEditor() {
//
//			/**
//			 * Gets the compiler id for this editor.
//			 * 
//			 * @return The compiler id for this editor, not empty and not <code>null</code>.
//			 */
//
//			@Override
//			protected final void initializeEditor() {
//				super.initializeEditor();
//
//				plugin = LanguagePlugin.getInstance();
//				compiler = plugin.getCompilerRegistry().getCompilerByEditorClassName(getEditorClassName());
//
//				setSourceViewerConfiguration(new LanguageSourceViewerConfiguration(this, getPreferenceStore()));
//
//			}
//
//			// TODO
//			protected String getEditorClassName() {
//				return getClass().getName();
//			}
//
//			/**
//			 * Gets the plugin this compiler instance belongs to.
//			 * 
//			 * @return The plugin this compiler instance belongs to, not <code>null</code>.
//			 */
//			public final LanguagePlugin getPlugin() {
//				if (plugin == null) {
//					throw new IllegalStateException("Field 'plugin' must not be null.");
//				}
//				return plugin;
//			}
//
//			/**
//			 * Gets the language.
//			 * 
//			 * @return The language, not <code>null</code>.
//			 */
//			public final Language getLanguage() {
//				return getCompilerDefinition().getLanguage();
//			}
//
//			/**
//			 * Gets the language preferences.
//			 * 
//			 * @return The language preferences, not <code>null</code>.
//			 */
//			public final LanguagePreferences getLanguagePreferences() {
//				return getPlugin().getLanguagePreferences(getLanguage());
//			}
//
//			/**
//			 * Gets the compiler for this editor.
//			 * 
//			 * @return The compiler for this editor, not <code>null</code>.
//			 */
//			public final Compiler getCompiler() {
//				if (compiler == null) {
//					throw new IllegalStateException("Field 'compiler' must not be null.");
//				}
//				return compiler;
//			}
//
//			/**
//			 * Gets the compiler definition for this editor.
//			 * 
//			 * @return The compiler definition for this editor, not <code>null</code>.
//			 * 
//			 * @sine 1.6.1
//			 */
//			public final CompilerDefinition getCompilerDefinition() {
//				if (compiler == null) {
//					throw new IllegalStateException("Field 'compiler' must not be null.");
//				}
//				return compiler.getDefinition();
//			}
//
//			/**
//			 * Gets the default hardware for this editor.
//			 * 
//			 * @return The hardware for this editor, not <code>null</code>.
//			 * 
//			 * @since 1.6.1
//			 */
//			protected final Hardware getHardware() {
//				if (hardware != null) {
//					return hardware;
//				}
//				return getCompilerDefinition().getDefaultHardware();
//			}
//
//
//			/**
//			 * Gets the compiler preferences.
//			 * 
//			 * @return The compiler preferences, not <code>null</code>.
//			 */
//			public final LanguageHardwareCompilerDefinitionPreferences getLanguageHardwareCompilerPreferences() {
//				return getLanguagePreferences().getLanguageHardwareCompilerDefinitionPreferences(getHardware(),
//						getCompilerDefinition());
//			}
//
		}

		var languageEditor = (ILanguageEditor) editor;
		var files = LanguageEditorFilesLogic.createInstance(languageEditor).createCompilerFiles();

		if (files != null) {
			execute(event, languageEditor, files);
		} else {
			try {
				LanguagePlugin.getInstance().showError(languageEditor.getSite().getShell(),
						"Operation '" + event.getCommand().getName()
								+ "' is not possible because the file in the editor is not located in the workspace.",
						new Exception("Cannot resolve compiler files of " + languageEditor.getEditorInput()));
			} catch (NotDefinedException ignore) {
				// Ignore
			}

		}
		return null;

	}

	/**
	 * Perform the action on the current editor and file.
	 * 
	 * @param event          The event, not <code>null</code>.
	 * @param languageEditor The language editor, not <code>null</code> and with
	 *                       current files which are not <code>null</code>.
	 * @param files          The current compiler files of the editor, not
	 *                       <code>null</code> .
	 * @throws ExecutionException if an exception occurred during execution.
	 */
	protected abstract void execute(ExecutionEvent event, ILanguageEditor languageEditor, CompilerFiles files)
			throws ExecutionException;

}