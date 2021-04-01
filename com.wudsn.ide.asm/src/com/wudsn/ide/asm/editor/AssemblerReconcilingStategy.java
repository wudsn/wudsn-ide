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

package com.wudsn.ide.asm.editor;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.reconciler.DirtyRegion;
import org.eclipse.jface.text.reconciler.IReconcilingStrategy;
import org.eclipse.jface.text.reconciler.IReconcilingStrategyExtension;

/**
 * The reconciling strategy for the AssemblerEditor. Builds the folding
 * structure for folding and notifies the editor.
 * 
 * @author Peter Dell
 * @author Andy Reek
 */
final class AssemblerReconcilingStategy implements IReconcilingStrategy, IReconcilingStrategyExtension {

    private final AssemblerEditor editor;
    private IDocument document;

    /**
     * Creates a new instance. Called by
     * {@link AssemblerSourceViewerConfiguration#getReconciler(org.eclipse.jface.text.source.ISourceViewer)}
     * .
     * 
     * * @param editor The underlying assembler editor, not <code>null</code>.
     */
    AssemblerReconcilingStategy(AssemblerEditor editor) {
	if (editor == null) {
	    throw new IllegalArgumentException("Parameter 'editor' must not be null.");
	}
	this.editor = editor;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void setDocument(IDocument document) {
	this.document = document;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public final void setProgressMonitor(final IProgressMonitor monitor) {
	// Not needed
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void initialReconcile() {
	parse();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void reconcile(DirtyRegion dirtyRegion, IRegion subRegion) {
	parse();
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public void reconcile(IRegion partition) {
	parse();
    }

    /**
     * Parses the current document for the content outline and the folding
     * structure.
     */
    private void parse() {
	if (document == null) {
	    return;
	}

	editor.updateContentOutlinePage();

    }
}
