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

//import java.io.StringReader;
//
//import javax.xml.parsers.DocumentBuilder;
//import javax.xml.parsers.DocumentBuilderFactory;

import org.eclipse.core.filebuffers.IDocumentSetupParticipant;
import org.eclipse.core.filebuffers.IDocumentSetupParticipantExtension;
import org.eclipse.core.filebuffers.LocationKind;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IMarker;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.jface.text.DocumentEvent;
import org.eclipse.jface.text.IDocument;
import org.eclipse.jface.text.IDocumentListener;
//import org.xml.sax.InputSource;
//import org.xml.sax.SAXParseException;

/**
 * 
 * @author Peter Dell
 * @since 1.7.1
 */
public class ValidatorDocumentSetupParticipant
		implements IDocumentSetupParticipant, IDocumentSetupParticipantExtension {

	private final class DocumentValidator implements IDocumentListener {
		private final IFile file;
		private IMarker marker;

		DocumentValidator(IFile file) {
			this.file = file;
		}

		@Override
		public void documentChanged(DocumentEvent event) {
			if (this.marker != null) {
				try {
					this.marker.delete();
				} catch (CoreException e) {
					e.printStackTrace();
				}
				this.marker = null;
			}
			// try {
			// String document=event.getDocument().get();
			// if (document.length()==0) {
			// document = "EMPTY";
			// }
			// // StringReader reader = new
			// StringReader(event.getDocument().get());) {
			// // DocumentBuilder documentBuilder =
			// // DocumentBuilderFactory.newInstance().newDocumentBuilder();
			// // documentBuilder.parse(new InputSource(reader));
			// } catch (Exception ex) {
			// try {
			// this.marker = file.createMarker(IMarker.PROBLEM);
			// this.marker.setAttribute(IMarker.SEVERITY,
			// IMarker.SEVERITY_ERROR);
			// this.marker.setAttribute(IMarker.MESSAGE, ex.getMessage());
			// if (ex instanceof SAXParseException) {
			// SAXParseException saxParseException = (SAXParseException) ex;
			// int lineNumber = saxParseException.getLineNumber();
			// int offset = event.getDocument().getLineInformation(lineNumber -
			// 1).getOffset()
			// + saxParseException.getColumnNumber() - 1;
			// this.marker.setAttribute(IMarker.LINE_NUMBER, lineNumber);
			// this.marker.setAttribute(IMarker.CHAR_START, offset);
			// this.marker.setAttribute(IMarker.CHAR_END, offset + 1);
			// }
			// } catch (Exception e) {
			// e.printStackTrace();
			// }
			// }
		}

		@Override
		public void documentAboutToBeChanged(DocumentEvent event) {
		}

	}

	@Override
	public void setup(IDocument document) {
	}

	@Override
	public void setup(IDocument document, IPath location, LocationKind locationKind) {
		if (locationKind == LocationKind.IFILE) {
			IFile file = ResourcesPlugin.getWorkspace().getRoot().getFile(location);
			document.addDocumentListener(new DocumentValidator(file));
		}
	}

}
