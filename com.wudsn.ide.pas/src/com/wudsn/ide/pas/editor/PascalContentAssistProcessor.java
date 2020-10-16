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
package com.wudsn.ide.pas.editor;

import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IProjectNatureDescriptor;
import org.eclipse.core.resources.IWorkspace;
import org.eclipse.core.resources.ResourcesPlugin;

import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.CompletionProposal;
import org.eclipse.jface.text.contentassist.ICompletionProposal;
import org.eclipse.jface.text.contentassist.IContentAssistProcessor;
import org.eclipse.jface.text.contentassist.IContextInformation;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;

/**
 * 
 * @author Peter Dell
 * @since 1.7.1
 */
public class PascalContentAssistProcessor implements IContentAssistProcessor {

    @Override
    public ICompletionProposal[] computeCompletionProposals(ITextViewer viewer, int offset) {
    	// TODO this is logic for .project file to complete on nature and project references. Replace with your language logic!
        String text = viewer.getDocument().get();
        String natureTag= "<nature>";
        String projectReferenceTag="<project>";
        IWorkspace workspace = ResourcesPlugin.getWorkspace();
        if (text.length() >= natureTag.length() && text.substring(offset - natureTag.length(), offset).equals(natureTag)) {
            IProjectNatureDescriptor[] natureDescriptors= workspace.getNatureDescriptors();
            ICompletionProposal[] proposals = new ICompletionProposal[natureDescriptors.length];
            for (int i= 0; i < natureDescriptors.length; i++) {
                IProjectNatureDescriptor descriptor= natureDescriptors[i];
                proposals[i] = new CompletionProposal(descriptor.getNatureId(), offset, 0, descriptor.getNatureId().length());
            }
            return proposals;
        }
        if (text.length() >= projectReferenceTag.length() && text.substring(offset - projectReferenceTag.length(), offset).equals(projectReferenceTag)) {
            IProject[] projects= workspace.getRoot().getProjects();
            ICompletionProposal[] proposals = new ICompletionProposal[projects.length];
            for (int i= 0; i < projects.length; i++) {
                proposals[i]=new CompletionProposal(projects[i].getName(), offset, 0, projects[i].getName().length());
            }
            return proposals;
        }
        return new ICompletionProposal[0];
    }

    @Override
    public IContextInformation[] computeContextInformation(ITextViewer viewer, int offset) {
        return null;
    }

    @Override
    public char[] getCompletionProposalAutoActivationCharacters() {
        return new char[] { '"' }; //NON-NLS-1
    }

    @Override
    public char[] getContextInformationAutoActivationCharacters() {
        return null;
    }

    @Override
    public String getErrorMessage() {
        return null;
    }

    @Override
    public IContextInformationValidator getContextInformationValidator() {
        return null;
    }

}