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

import org.eclipse.core.runtime.Assert;
import org.eclipse.jface.text.BadLocationException;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.ICompletionProposalExtension6;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.viewers.StyledString;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Point;

/**
 * The standard implementation of the <code>ICompletionProposal</code>
 * interface.
 * 
 * @author Peter Dell
 */
final class AssemblerInstructionCompletionProposal implements ICompletionProposal, ICompletionProposalExtension6 {

    /** The string to be displayed in the completion proposal popup. */
    private String displayString;
    private StyledString styledDisplayString;

    /** The replacement string. */
    private String replacementString;
    /** The replacement offset. */
    private int replacementOffset;
    /** The replacement length. */
    private int replacementLength;
    /** The offset of the cursor after applying the replacement. */
    private int cursorOffset;

    /** The image to be displayed in the completion proposal popup. */
    private Image image;
    /** The context information of this proposal. */
    private IContextInformation contextInformation;

    /**
     * Creates a new completion proposal. All fields are initialized based on
     * the provided information.
     * 
     * @param replacementString
     *            The actual string to be inserted into the document.
     * @param replacementOffset
     *            The offset of the text to be replaced.
     * @param replacementLength
     *            The length of the text to be replaced.
     * @param cursorOffset
     *            The offset of the cursor after applying the replacement.
     * @param image
     *            The image to display for this proposal.
     * @param displayString
     *            The string to be displayed for the proposal.
     * @param styledDisplayString
     *            The styles display string for the proposal.
     * @param contextInformation
     *            The context information associated with this proposal.
     */
    AssemblerInstructionCompletionProposal(String replacementString, int replacementOffset, int replacementLength,
	    int cursorOffset, Image image, String displayString, StyledString styledDisplayString,
	    IContextInformation contextInformation) {
	Assert.isNotNull(replacementString);
	Assert.isNotNull(displayString);
	Assert.isTrue(replacementOffset >= 0);
	Assert.isTrue(replacementLength >= 0);
	Assert.isTrue(cursorOffset >= 0);

	this.replacementString = replacementString;
	this.replacementOffset = replacementOffset;
	this.replacementLength = replacementLength;
	this.cursorOffset = cursorOffset;
	this.image = image;
	this.displayString = displayString;
	this.styledDisplayString = styledDisplayString;
	this.contextInformation = contextInformation;
    }

    /*
     * @see ICompletionProposal#apply(IDocument)
     */
    @Override
    public void apply(IDocument document) {
	try {
	    document.replace(replacementOffset, replacementLength, replacementString);
	} catch (BadLocationException ex) {
	    throw new RuntimeException("Replacement offset " + replacementOffset + " no valid", ex);

	}
    }

    /*
     * @see ICompletionProposal#getSelection(IDocument)
     */
    @Override
    public Point getSelection(IDocument document) {
	return new Point(cursorOffset, 0);
    }

    /*
     * @see ICompletionProposal#getContextInformation()
     */
    @Override
    public IContextInformation getContextInformation() {
	return contextInformation;
    }

    /*
     * @see ICompletionProposal#getImage()
     */
    @Override
    public Image getImage() {
	return image;
    }

    /*
     * @see ICompletionProposal#getDisplayString()
     */
    @Override
    public String getDisplayString() {
	if (displayString != null)
	    return displayString;
	return replacementString;
    }

    /*
     * @see ICompletionProposalExtension6#getStyledDisplayString()
     */
    @Override
    public StyledString getStyledDisplayString() {

	return styledDisplayString;
    }

    /*
     * @see ICompletionProposal#getAdditionalProposalInfo()
     */
    @Override
    public String getAdditionalProposalInfo() {
	return "";
    }

}
