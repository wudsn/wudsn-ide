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

import java.util.Date;
import java.util.List;

import org.eclipse.e4.ui.di.AboutToShow;
import org.eclipse.e4.ui.model.application.ui.menu.MDirectMenuItem;
import org.eclipse.e4.ui.model.application.ui.menu.MMenuElement;
import org.eclipse.e4.ui.model.application.ui.menu.MMenuFactory;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.ui.menus.WorkbenchWindowControlContribution;

// TODO: This should become a replacement for the action/actionSet based dynamic menu
// See also https://wiki.eclipse.org/Menu_Contributions
// Asked at https://www.eclipse.org/forums/index.php/m/1833428/#msg_1833428
public final class LanguageEditorCompileAndRunCommandMenu extends WorkbenchWindowControlContribution {

	public LanguageEditorCompileAndRunCommandMenu() {
		if (System.getProperty("user.name").equals("JAC")) {
//			new Exception("JAC! Test for Startup!").printStackTrace();
		}
	}

	@AboutToShow
	public void aboutToShow(List<MMenuElement> items) {
		MDirectMenuItem dynamicItem = MMenuFactory.INSTANCE.createDirectMenuItem();
		dynamicItem.setLabel("Dynamic Menu Item (" + new Date() + ")");
		dynamicItem.setContributorURI("platform:/plugin/at.descher.eclipse.bug389063");
		dynamicItem.setContributionURI(
				"bundleclass://at.descher.eclipse.bug389063/at.descher.eclipse.bug389063.dynamic.DirectMenuItemAHandler");
		items.add(dynamicItem);

	}

	@Override
	protected Control createControl(Composite parent) {
		return null;
	}

}
