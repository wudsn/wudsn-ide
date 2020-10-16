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

import java.util.List;

import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.viewers.ITreeContentProvider;
import org.eclipse.jface.viewers.Viewer;
import org.eclipse.ui.IEditorInput;

import com.wudsn.ide.asm.compiler.parser.CompilerSourceFile;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParser;
import com.wudsn.ide.asm.compiler.parser.CompilerSourceParserTreeObject;
import com.wudsn.ide.base.common.Profiler;

/**
 * Tree content provider to {@link AssemblerContentOutlinePage}.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
final class AssemblerContentOutlineTreeContentProvider implements ITreeContentProvider {

    /**
     * The surrounding content outline page.
     */
    private final AssemblerContentOutlinePage assemblerContentOutlinePage;

    /**
     * The last editor input which was parsed.
     */
    private IEditorInput input;

    /**
     * The result of the last parse process.
     */
    private CompilerSourceFile compilerSourceFile;

    /**
     * Called by
     * {@link AssemblerContentOutlinePage#createControl(org.eclipse.swt.widgets.Composite)}
     * .
     * 
     * @param assemblerContentOutlinePage
     *            The outline page, not <code>null</code>.
     */
    AssemblerContentOutlineTreeContentProvider(AssemblerContentOutlinePage assemblerContentOutlinePage) {
	if (assemblerContentOutlinePage == null) {
	    throw new IllegalArgumentException("Parameter 'assemblerContentOutlinePage' must not be null.");
	}
	this.assemblerContentOutlinePage = assemblerContentOutlinePage;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Object getParent(Object element) {
	if (element instanceof CompilerSourceParserTreeObject) {
	    return ((CompilerSourceParserTreeObject) element).getParent();
	}

	return null;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public boolean hasChildren(Object element) {
	if (element instanceof CompilerSourceParserTreeObject) {
	    return (((CompilerSourceParserTreeObject) element).hasChildren());
	}

	return false;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Object[] getChildren(Object parentElement) {
	if (parentElement instanceof CompilerSourceParserTreeObject) {
	    return ((CompilerSourceParserTreeObject) parentElement).getChildrenAsArray();
	}
	return null;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public Object[] getElements(Object inputElement) {
	Object[] result;
	if (inputElement == input && compilerSourceFile != null) {
	    List<CompilerSourceParserTreeObject> sections;
	    sections = compilerSourceFile.getSections();
	    result = sections.toArray(new Object[sections.size()]);
	} else {
	    result = new Object[0];
	}

	return result;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void dispose() {
	input = null;
    }

    /**
     * Gets the compiler source file of the last parse process.
     * 
     * @return The compiler source file of the last parse process or
     *         <code>null</code>.
     */
    CompilerSourceFile getCompilerSourceFile() {
	return compilerSourceFile;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
	if (oldInput instanceof IEditorInput) {
	    input = null;
	}

	if (newInput instanceof IEditorInput) {
	    input = (IEditorInput) newInput;
	    parse();
	}
    }

    /**
     * Parses the new input and builds up the parse tree.
     */
    private void parse() {

	AssemblerEditor editor = this.assemblerContentOutlinePage.editor;
	IDocument document = editor.getDocumentProvider().getDocument(editor.getEditorInput());

	if (document != null) {
	    CompilerSourceParser parser = editor.createCompilerSourceParser();
	    compilerSourceFile = parser.createCompilerSourceFile(editor.getCurrentFile(), document);
	    Profiler profiler = new Profiler(parser);
	    profiler.begin("parse", editor.getTitle());
	    parser.parse(compilerSourceFile, null);
	    profiler.end("parse");
	}

    }

}
