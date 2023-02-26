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

import org.eclipse.core.expressions.PropertyTester;
import org.eclipse.core.resources.IFile;
import org.eclipse.ui.editors.text.TextEditor;

import com.wudsn.ide.lng.Language;

public class LanguageEditorPropertyTester extends PropertyTester {

	public LanguageEditorPropertyTester() {
	}

	@Override
	public boolean test(Object receiver, String property, Object[] args, Object expectedValue) {

		if (property.equals("IsLanguageEditor")) {

			if (receiver instanceof LanguageEditor) {
				return true;
			}
			if (receiver instanceof TextEditor) {

				var editor = (TextEditor) receiver;
				var input = editor.getEditorInput();
				var file = input.getAdapter(IFile.class);
				if (file != null && file.getName().toLowerCase().endsWith(".pas")) {
					return true;
				}

			}
		}
		return false;
	}

}
