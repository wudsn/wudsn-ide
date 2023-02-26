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

import java.io.File;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.text.IDocument;
import org.eclipse.ui.IEditorPart;

import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.Compiler;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.lng.preferences.LanguageHardwareCompilerDefinitionPreferences;
import com.wudsn.ide.lng.preferences.LanguagePreferences;

/**
 * The language editor interface.
 * 
 * @author Peter Dell
 */
public interface ILanguageEditor extends IEditorPart {

	/**
	 * Gets the plugin this compiler instance belongs to.
	 * 
	 * @return The plugin this compiler instance belongs to, not <code>null</code>.
	 */
	public LanguagePlugin getPlugin();

	/**
	 * Gets the language.
	 * 
	 * @return The language, not <code>null</code>.
	 */
	public Language getLanguage();

	/**
	 * Gets the language preferences.
	 * 
	 * @return The language preferences, not <code>null</code>.
	 */
	public LanguagePreferences getLanguagePreferences();

	/**
	 * Gets the compiler preferences.
	 * 
	 * @return The compiler preferences, not <code>null</code>.
	 */
	public LanguageHardwareCompilerDefinitionPreferences getLanguageHardwareCompilerPreferences();

	/**
	 * Gets the compiler for this editor.
	 * 
	 * @return The compiler for this editor, not <code>null</code>.
	 */
	public Compiler getCompiler();

	/**
	 * Gets the compiler definition for this editor.
	 * 
	 * @return The compiler definition for this editor, not <code>null</code>.
	 * 
	 * @sine 1.6.1
	 */
	public CompilerDefinition getCompilerDefinition();

	/**
	 * Gets the the current file.
	 * 
	 * @return The current file or <code>null</code>.
	 */
	public IFile getCurrentIFile();

	/**
	 * Gets the the current file.
	 * 
	 * @return The current file or <code>null</code>.
	 */
	public File getCurrentFile();

	/**
	 * Gets the directory of the current file.
	 * 
	 * @return The directory of the current file or <code>null</code>.
	 */
	public File getCurrentDirectory();

	/**
	 * Returns this text editor's document.
	 *
	 * @return the document or <code>null</code> if none, e.g. after closing the
	 *         editor
	 */
	IDocument getDocument();

	/**
	 * Creates a compiler source parser for this editor and the currently selected
	 * instruction set.
	 * 
	 * @return The compiler source parser for this editor, not <code>null</code> .
	 */
	public CompilerSourceParser createCompilerSourceParser();
}
