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
package com.wudsn.ide.lng.pas.editor;

//import org.eclipse.core.resources.IProjectNatureDescriptor;
//import org.eclipse.core.resources.IWorkspace;
//import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.text.IRegion;
import org.eclipse.jface.text.ITextHover;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.Region;

/**
 * 
 * @author Peter Dell
 * @since 1.7.1
 */
public class PascalHoverProvider implements ITextHover {

	@Override
	public String getHoverInfo(ITextViewer textViewer, IRegion hoverRegion) {
		// TODO this is logic for .project file to show nature description on hover.
		// Replace with your language logic!
		// String contents= textViewer.getDocument().get();
		// int offset= hoverRegion.getOffset();
//        int endIndex= contents.indexOf("</nature>", offset);
//        if (endIndex==-1) return "";
//        int startIndex= contents.substring(0, offset).lastIndexOf("<nature>");
//        if (startIndex==-1) return "";
//        String selection = contents.substring(startIndex+"<nature>".length(), endIndex);
//
//        IWorkspace workspace = ResourcesPlugin.getWorkspace();
//        IProjectNatureDescriptor[] natureDescriptors= workspace.getNatureDescriptors();
//        for (int i= 0; i < natureDescriptors.length; i++) {
//            if (natureDescriptors[i].getNatureId().equals(selection))
//                return natureDescriptors[i].getLabel();
//        }
		return "";
	}

	@Override
	public IRegion getHoverRegion(ITextViewer textViewer, int offset) {
		return new Region(offset, 0);
	}
}