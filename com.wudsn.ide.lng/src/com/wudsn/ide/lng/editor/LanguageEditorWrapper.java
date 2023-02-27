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
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorSite;
import org.eclipse.ui.IPropertyListener;
import org.eclipse.ui.IWorkbenchPartSite;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.part.FileEditorInput;
import org.eclipse.ui.texteditor.ITextEditor;

import com.wudsn.ide.base.hardware.Hardware;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguagePlugin;
import com.wudsn.ide.lng.compiler.Compiler;
import com.wudsn.ide.lng.compiler.CompilerDefinition;
import com.wudsn.ide.lng.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.lng.preferences.LanguageHardwareCompilerDefinitionPreferences;
import com.wudsn.ide.lng.preferences.LanguagePreferences;

/**
 * The language editor.
 * 
 * @author Peter Dell
 */
public class LanguageEditorWrapper implements ILanguageEditor {

	private ITextEditor delegate;

	private LanguagePlugin plugin;
	private Compiler compiler;

	private Hardware hardware;

	public LanguageEditorWrapper(ITextEditor delegate, String compilerClassName) {
		if (delegate == null) {
			throw new IllegalArgumentException("Parameter 'delegate' must not be null.");
		}
		if (compilerClassName == null) {
			throw new IllegalArgumentException("Parameter 'compilerClassName' must not be null.");
		}
		this.delegate = delegate;
		plugin = LanguagePlugin.getInstance();
		compiler = plugin.getCompilerRegistry().getCompilerByEditorClassName(compilerClassName);

	}

	@Override
	public final LanguagePlugin getPlugin() {
		if (plugin == null) {
			throw new IllegalStateException("Field 'plugin' must not be null.");
		}
		return plugin;
	}

	@Override
	public final Language getLanguage() {
		return getCompilerDefinition().getLanguage();
	}

	@Override
	public final LanguagePreferences getLanguagePreferences() {
		return getPlugin().getLanguagePreferences(getLanguage());
	}

	@Override
	public final Compiler getCompiler() {
		if (compiler == null) {
			throw new IllegalStateException("Field 'compiler' must not be null.");
		}
		return compiler;
	}

	@Override
	public final CompilerDefinition getCompilerDefinition() {
		return getCompiler().getDefinition();
	}

	/**
	 * Gets the default hardware for this editor.
	 * 
	 * @return The hardware for this editor, not <code>null</code>.
	 * 
	 * @since 1.6.1
	 */
	protected final Hardware getHardware() {
		if (hardware != null) {
			return hardware;
		}
		return getCompilerDefinition().getDefaultHardware();
	}

	@Override
	public final LanguageHardwareCompilerDefinitionPreferences getLanguageHardwareCompilerPreferences() {
		return getLanguagePreferences().getLanguageHardwareCompilerDefinitionPreferences(getHardware(),
				getCompilerDefinition());
	}

	@Override
	public final CompilerSourceParser createCompilerSourceParser() {
		return LanguageEditor.createCompilerSourceParser(this);
	}

	@Override
	public IDocument getDocument() {
		return delegate.getDocumentProvider().getDocument(getEditorInput());
	}

	@Override
	public final IFile getCurrentIFile() {
		IFile result;
		var editorInput = getEditorInput();
		if (editorInput instanceof FileEditorInput) {
			var fileEditorInput = (FileEditorInput) editorInput;
			result = fileEditorInput.getFile();

		} else {
			result = null;
		}
		return result;
	}

	@Override
	public final File getCurrentFile() {
		File result;
		var editorInput = getEditorInput();
		if (editorInput instanceof FileEditorInput) {
			var fileEditorInput = (FileEditorInput) editorInput;
			result = new File(fileEditorInput.getPath().toOSString());
		} else {
			result = null;
		}
		return result;
	}

	@Override
	public final File getCurrentDirectory() {
		var result = getCurrentFile();
		if (result != null) {
			result = result.getParentFile();
		}
		return result;
	}

	@Override
	public IEditorInput getEditorInput() {
		return delegate.getEditorInput();
	}

	@Override
	public IEditorSite getEditorSite() {
		return delegate.getEditorSite();
	}

	@Override
	public void init(IEditorSite site, IEditorInput input) throws PartInitException {
		delegate.init(site, input);

	}

	@Override
	public void addPropertyListener(IPropertyListener listener) {
		delegate.addPropertyListener(listener);

	}

	@Override
	public void createPartControl(Composite parent) {
		delegate.createPartControl(parent);

	}

	@Override
	public void dispose() {
		// TODO Auto-generated method stub

	}

	@Override
	public IWorkbenchPartSite getSite() {
		return delegate.getSite();
	}

	@Override
	public String getTitle() {
		return delegate.getTitle();
	}

	@Override
	public Image getTitleImage() {
		return delegate.getTitleImage();
	}

	@Override
	public String getTitleToolTip() {
		return delegate.getTitleToolTip();
	}

	@Override
	public void removePropertyListener(IPropertyListener listener) {
		delegate.removePropertyListener(listener);
	}

	@Override
	public void setFocus() {
		delegate.setFocus();
	}

	@Override
	public <T> T getAdapter(Class<T> adapter) {
		return delegate.getAdapter(adapter);
	}

	@Override
	public void doSave(IProgressMonitor monitor) {
		delegate.doSave(monitor);
	}

	@Override
	public void doSaveAs() {
		delegate.doSaveAs();

	}

	@Override
	public boolean isDirty() {
		return delegate.isDirty();
	}

	@Override
	public boolean isSaveAsAllowed() {
		return delegate.isSaveAsAllowed();
	}

	@Override
	public boolean isSaveOnCloseNeeded() {
		return delegate.isSaveOnCloseNeeded();
	}
}