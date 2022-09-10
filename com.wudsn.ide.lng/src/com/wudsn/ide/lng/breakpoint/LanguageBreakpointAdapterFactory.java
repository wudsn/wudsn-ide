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

package com.wudsn.ide.lng.breakpoint;

import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.eclipse.debug.ui.actions.IToggleBreakpointsTarget;
import org.eclipse.debug.ui.actions.IToggleBreakpointsTargetFactory;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.ui.IWorkbenchPart;

import com.wudsn.ide.base.common.EnumUtility;
import com.wudsn.ide.base.common.TextUtility;
import com.wudsn.ide.lng.Language;
import com.wudsn.ide.lng.LanguageUtility;
import com.wudsn.ide.lng.Texts;
import com.wudsn.ide.lng.editor.LanguageEditor;

/**
 * Factory for {@LanguageBreakpointsTarget} instances. Used by extension
 * "org.eclipse.debug.ui.toggleBreakpointsTargetFactories"
 * 
 * @author Peter Dell
 * @since 1.6.1
 */
public final class LanguageBreakpointAdapterFactory implements IToggleBreakpointsTargetFactory {

	private String TARGET_ID_PREFIX = LanguageBreakpointsTarget.class.getName() + ".";

	public LanguageBreakpointAdapterFactory() {

	}

	@Override
	public Set<String> getToggleTargets(IWorkbenchPart part, ISelection selection) {
		if (part instanceof LanguageEditor) {
			Set<String> defaultSet = new HashSet<String>();
			defaultSet.add(getDefaultToggleTarget(part, selection));
			return defaultSet;
		}
		return Collections.emptySet();
	}

	@Override
	public String getDefaultToggleTarget(IWorkbenchPart part, ISelection selection) {
		if (part instanceof LanguageEditor) {
			LanguageEditor languageEditor = (LanguageEditor) part;
			return TARGET_ID_PREFIX + languageEditor.getLanguage().name();
		}
		return null;
	}

	@Override
	public IToggleBreakpointsTarget createToggleTarget(String targetID) {
		if (targetID.startsWith(TARGET_ID_PREFIX)) {
			return new LanguageBreakpointsTarget();
		}
		return null;
	}

	@Override
	public String getToggleTargetName(String targetID) {
		String languageName = targetID.substring(TARGET_ID_PREFIX.length());
		Language language = Language.valueOf(languageName);
		// INFO: {0} Breakpoints
		return TextUtility.format(Texts.LANGUAGE_BREAKPOINT_TOGGLE_TYPE_MENU_TEXT, LanguageUtility.getText(language));
	}

	@Override
	public String getToggleTargetDescription(String targetID) {
		return targetID;
	}

}
